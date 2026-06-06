from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import sqlite3
import os
from datetime import datetime

app = FastAPI()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    conn = sqlite3.connect("airport.db")
    conn.row_factory = sqlite3.Row
    return conn

@app.get("/")
def root():
    return {"message": "Airport Maintenance API is running"}

@app.get("/api/equipment/{code}")
def get_equipment(code: str):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM equipment WHERE code = ?", (code,))
    equipment = cursor.fetchone()

    if not equipment:
        conn.close()
        raise HTTPException(status_code=404, detail="Equipment not found")

    cursor.execute("""
        SELECT * FROM maintenance_tickets 
        WHERE equipment_code = ?
        ORDER BY id DESC
    """, (code,))
    tickets = cursor.fetchall()

    conn.close()

    return {
        "equipment": dict(equipment),
        "maintenance_history": [dict(ticket) for ticket in tickets]
    }

@app.get("/api/equipment")
def list_equipment():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM equipment ORDER BY id DESC")
    rows = cursor.fetchall()

    conn.close()
    return [dict(row) for row in rows]

@app.post("/api/maintenance")
async def create_maintenance_ticket(
    equipment_code: str = Form(...),
    title: str = Form(...),
    issue_type: str = Form(...),
    priority: str = Form(...),
    description: str = Form(...),
    created_by: str = Form("staff"),
    image: UploadFile | None = File(None)
):
    image_path = None

    if image:
        filename = f"{datetime.now().strftime('%Y%m%d%H%M%S')}_{image.filename}"
        file_path = os.path.join(UPLOAD_DIR, filename)

        with open(file_path, "wb") as buffer:
            buffer.write(await image.read())

        image_path = f"/uploads/{filename}"

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO maintenance_tickets
        (equipment_code, title, issue_type, priority, description, image_path, status, created_by, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        equipment_code,
        title,
        issue_type,
        priority,
        description,
        image_path,
        "open",
        created_by,
        datetime.now().isoformat()
    ))

    conn.commit()
    ticket_id = cursor.lastrowid
    conn.close()

    return {
        "message": "Maintenance ticket created successfully",
        "ticket_id": ticket_id
    }
    
@app.get("/api/maintenance")
def list_maintenance_tickets(
    status: str = "",
    system: str = "",
    keyword: str = "",
    assigned_to: str = ""
):
    conn = get_db()
    cursor = conn.cursor()

    query = """
        SELECT 
            mt.id,
            mt.equipment_code,
            mt.issue_title,
            mt.issue_description,
            mt.priority,
            mt.status,
            mt.image_path,
            mt.created_by,
            mt.assigned_to,
            u.full_name AS assigned_full_name,
            mt.created_at,
            mt.updated_at,
            e.name AS equipment_name,
            e.system AS equipment_system,
            e.location AS equipment_location,
            e.floor AS equipment_floor
        FROM maintenance_tickets mt
        LEFT JOIN equipment e ON mt.equipment_code = e.code
        LEFT JOIN users u ON mt.assigned_to = u.username
        WHERE 1 = 1
    """

    params = []

    if status:
        query += " AND mt.status = ?"
        params.append(status)

    if system:
        query += " AND e.system = ?"
        params.append(system)

    if assigned_to:
        query += " AND mt.assigned_to = ?"
        params.append(assigned_to)

    if keyword:
        query += """
            AND (
                mt.equipment_code LIKE ?
                OR e.name LIKE ?
                OR mt.issue_title LIKE ?
                OR mt.issue_description LIKE ?
                OR mt.assigned_to LIKE ?
            )
        """
        search_value = f"%{keyword}%"
        params.extend([
            search_value,
            search_value,
            search_value,
            search_value,
            search_value
        ])

    query += " ORDER BY mt.id DESC"

    cursor.execute(query, params)
    rows = cursor.fetchall()
    conn.close()

    return [dict(row) for row in rows]

@app.get("/api/maintenance/{ticket_id}")
def get_maintenance_ticket(ticket_id: int):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
            mt.*,
            mt.assigned_to,
            u.full_name AS assigned_full_name,
            e.name AS equipment_name,
            e.system AS equipment_system,
            e.location AS equipment_location
        FROM maintenance_tickets mt
        LEFT JOIN equipment e ON mt.equipment_code = e.code
        LEFT JOIN users u ON mt.assigned_to = u.username
        WHERE mt.id = ?
    """, (ticket_id,))

    ticket = cursor.fetchone()
    conn.close()

    if not ticket:
        raise HTTPException(
            status_code=404,
            detail=f"Không tìm thấy phiếu bảo trì ID: {ticket_id}"
        )

    return dict(ticket)


@app.put("/api/maintenance/{ticket_id}/status")
def update_maintenance_status(
    ticket_id: int,
    status: str = Form(...),
    updated_by: str = Form("")
):
    allowed_status = ["open", "in_progress", "done", "cancelled"]

    if status not in allowed_status:
        raise HTTPException(
            status_code=400,
            detail="Trạng thái không hợp lệ"
        )

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, status
        FROM maintenance_tickets
        WHERE id = ?
    """, (ticket_id,))

    ticket = cursor.fetchone()

    if not ticket:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy phiếu bảo trì"
        )

    old_status = ticket["status"]
    now = datetime.now().isoformat()

    cursor.execute("""
        UPDATE maintenance_tickets
        SET status = ?, updated_at = ?
        WHERE id = ?
    """, (
        status,
        now,
        ticket_id
    ))

    status_text = {
        "open": "Mới tạo",
        "in_progress": "Đang xử lý",
        "done": "Hoàn thành",
        "cancelled": "Đã hủy"
    }

    note = (
        f"Cập nhật trạng thái từ "
        f"{status_text.get(old_status, old_status)} "
        f"sang {status_text.get(status, status)}"
    )

    cursor.execute("""
        INSERT INTO maintenance_notes
        (ticket_id, note, created_by, created_at)
        VALUES (?, ?, ?, ?)
    """, (
        ticket_id,
        note,
        updated_by.strip() if updated_by.strip() else "Hệ thống",
        now
    ))

    conn.commit()
    conn.close()

    return {
        "message": "Cập nhật trạng thái thành công",
        "ticket_id": ticket_id,
        "status": status
    }
    
@app.post("/api/login")
def login(
    username: str = Form(...),
    password: str = Form(...)
):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, username, full_name, role, active
        FROM users
        WHERE username = ? AND password = ?
    """, (username, password))

    user = cursor.fetchone()
    conn.close()

    if not user:
        raise HTTPException(
            status_code=401,
            detail="Sai tên đăng nhập hoặc mật khẩu"
        )
    
    if user["active"] == 0:
        raise HTTPException(
            status_code=403,
            detail="Tài khoản đã bị khóa"
    )    

    return {
        "message": "Đăng nhập thành công",
        "user": dict(user)
    }
    
@app.get("/api/dashboard")
def get_dashboard(
    username: str = "",
    role: str = ""
):
    conn = get_db()
    cursor = conn.cursor()

    role = role.strip().lower()
    username = username.strip()

    # Tổng số thiết bị
    cursor.execute("SELECT COUNT(*) AS total_equipment FROM equipment")
    total_equipment = cursor.fetchone()["total_equipment"]

    # Điều kiện lọc phiếu theo role
    where_clause = "WHERE 1 = 1"
    params = []

    if role == "technician" and username:
        where_clause += " AND assigned_to = ?"
        params.append(username)

    # Tổng số phiếu bảo trì
    cursor.execute(f"""
        SELECT COUNT(*) AS total_tickets
        FROM maintenance_tickets
        {where_clause}
    """, params)
    total_tickets = cursor.fetchone()["total_tickets"]

    # Số phiếu theo trạng thái
    cursor.execute(f"""
        SELECT status, COUNT(*) AS count
        FROM maintenance_tickets
        {where_clause}
        GROUP BY status
    """, params)
    status_rows = cursor.fetchall()

    ticket_status = {
        "open": 0,
        "in_progress": 0,
        "done": 0,
        "cancelled": 0
    }

    for row in status_rows:
        ticket_status[row["status"]] = row["count"]

    # Số thiết bị theo hệ thống
    # Admin/supervisor: toàn bộ thiết bị
    # Technician: thống kê theo hệ thống của các phiếu được giao
    if role == "technician" and username:
        cursor.execute("""
            SELECT e.system, COUNT(DISTINCT e.id) AS count
            FROM maintenance_tickets mt
            LEFT JOIN equipment e ON mt.equipment_code = e.code
            WHERE mt.assigned_to = ?
            GROUP BY e.system
            ORDER BY e.system
        """, (username,))
    else:
        cursor.execute("""
            SELECT system, COUNT(*) AS count
            FROM equipment
            GROUP BY system
            ORDER BY system
        """)

    system_rows = cursor.fetchall()

    equipment_by_system = [
        {
            "system": row["system"] or "Unknown",
            "count": row["count"]
        }
        for row in system_rows
    ]

    conn.close()

    return {
        "total_equipment": total_equipment,
        "total_tickets": total_tickets,
        "ticket_status": ticket_status,
        "equipment_by_system": equipment_by_system,
        "username": username,
        "role": role
    }
    
@app.post("/api/equipment")
def create_equipment(
    code: str = Form(...),
    name: str = Form(...),
    system: str = Form(""),
    equipment_type: str = Form(""),
    location: str = Form(""),
    floor: str = Form(""),
    area: str = Form(""),
    ip_address: str = Form(""),
    serial_number: str = Form(""),
    model: str = Form(""),
    manufacturer: str = Form(""),
    status: str = Form("normal"),
    description: str = Form("")
):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id FROM equipment
        WHERE code = ?
    """, (code,))

    existing = cursor.fetchone()

    if existing:
        conn.close()
        raise HTTPException(
            status_code=400,
            detail=f"Mã thiết bị đã tồn tại: {code}"
        )

    now = datetime.now().isoformat()

    cursor.execute("""
        INSERT INTO equipment
        (
            code, name, system, equipment_type, location, floor, area,
            ip_address, serial_number, model, manufacturer, status,
            description, created_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        code,
        name,
        system,
        equipment_type,
        location,
        floor,
        area,
        ip_address,
        serial_number,
        model,
        manufacturer,
        status,
        description,
        now
    ))

    conn.commit()
    equipment_id = cursor.lastrowid
    conn.close()

    return {
        "message": "Đã thêm thiết bị thành công",
        "equipment_id": equipment_id,
        "code": code
    }    
    
@app.put("/api/equipment/{code}")
def update_equipment(
    code: str,
    name: str = Form(...),
    system: str = Form(""),
    equipment_type: str = Form(""),
    location: str = Form(""),
    floor: str = Form(""),
    area: str = Form(""),
    ip_address: str = Form(""),
    serial_number: str = Form(""),
    model: str = Form(""),
    manufacturer: str = Form(""),
    status: str = Form("normal"),
    description: str = Form("")
):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id FROM equipment
        WHERE code = ?
    """, (code,))

    equipment = cursor.fetchone()

    if not equipment:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail=f"Không tìm thấy thiết bị có mã: {code}"
        )

    cursor.execute("""
        UPDATE equipment
        SET 
            name = ?,
            system = ?,
            equipment_type = ?,
            location = ?,
            floor = ?,
            area = ?,
            ip_address = ?,
            serial_number = ?,
            model = ?,
            manufacturer = ?,
            status = ?,
            description = ?
        WHERE code = ?
    """, (
        name,
        system,
        equipment_type,
        location,
        floor,
        area,
        ip_address,
        serial_number,
        model,
        manufacturer,
        status,
        description,
        code
    ))

    conn.commit()
    conn.close()

    return {
        "message": "Đã cập nhật thiết bị thành công",
        "code": code
    }   
    
@app.get("/api/users")
def list_users():
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, username, full_name, role, created_at, active
        FROM users
        ORDER BY id DESC
    """)

    rows = cursor.fetchall()
    conn.close()

    return [dict(row) for row in rows]     

@app.post("/api/users")
def create_user(
    username: str = Form(...),
    password: str = Form(...),
    full_name: str = Form(""),
    role: str = Form("technician")
):
    allowed_roles = ["admin", "technician", "supervisor"]

    if role not in allowed_roles:
        raise HTTPException(
            status_code=400,
            detail="Role không hợp lệ"
        )

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id FROM users
        WHERE username = ?
    """, (username,))

    existing = cursor.fetchone()

    if existing:
        conn.close()
        raise HTTPException(
            status_code=400,
            detail=f"Tài khoản đã tồn tại: {username}"
        )

    cursor.execute("""
        INSERT INTO users
        (username, password, full_name, role, created_at)
        VALUES (?, ?, ?, ?, ?)
    """, (
        username,
        password,
        full_name,
        role,
        datetime.now().isoformat()
    ))

    conn.commit()
    user_id = cursor.lastrowid
    conn.close()

    return {
        "message": "Đã tạo tài khoản thành công",
        "user_id": user_id,
        "username": username,
        "role": role
    }
    
@app.put("/api/users/{user_id}")
def update_user(
    user_id: int,
    username: str = Form(...),
    password: str = Form(""),
    full_name: str = Form(""),
    role: str = Form("technician")
):
    allowed_roles = ["admin", "technician", "supervisor"]

    if role not in allowed_roles:
        raise HTTPException(
            status_code=400,
            detail="Role không hợp lệ"
        )

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id FROM users
        WHERE id = ?
    """, (user_id,))

    user = cursor.fetchone()

    if not user:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy tài khoản"
        )

    cursor.execute("""
        SELECT id FROM users
        WHERE username = ? AND id != ?
    """, (username, user_id))

    existing = cursor.fetchone()

    if existing:
        conn.close()
        raise HTTPException(
            status_code=400,
            detail=f"Username đã tồn tại: {username}"
        )

    if password.strip():
        cursor.execute("""
            UPDATE users
            SET username = ?, password = ?, full_name = ?, role = ?
            WHERE id = ?
        """, (
            username,
            password,
            full_name,
            role,
            user_id
        ))
    else:
        cursor.execute("""
            UPDATE users
            SET username = ?, full_name = ?, role = ?
            WHERE id = ?
        """, (
            username,
            full_name,
            role,
            user_id
        ))

    conn.commit()
    conn.close()

    return {
        "message": "Đã cập nhật tài khoản thành công",
        "user_id": user_id
    }    
    
@app.put("/api/users/{user_id}/active")
def update_user_active(
    user_id: int,
    active: int = Form(...)
):
    if active not in [0, 1]:
        raise HTTPException(
            status_code=400,
            detail="Giá trị active không hợp lệ"
        )

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, username
        FROM users
        WHERE id = ?
    """, (user_id,))

    user = cursor.fetchone()

    if not user:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy tài khoản"
        )

    if user["username"] == "admin" and active == 0:
        conn.close()
        raise HTTPException(
            status_code=400,
            detail="Không nên khóa tài khoản admin mặc định"
        )

    cursor.execute("""
        UPDATE users
        SET active = ?
        WHERE id = ?
    """, (active, user_id))

    conn.commit()
    conn.close()

    return {
        "message": "Đã cập nhật trạng thái tài khoản",
        "user_id": user_id,
        "active": active
    }
    
@app.put("/api/maintenance/{ticket_id}/assign")
def assign_maintenance_ticket(
    ticket_id: int,
    assigned_to: str = Form(...),
    assigned_by: str = Form("")
):
    if not assigned_to.strip():
        raise HTTPException(
            status_code=400,
            detail="Người phụ trách không được rỗng"
        )

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, assigned_to
        FROM maintenance_tickets
        WHERE id = ?
    """, (ticket_id,))

    ticket = cursor.fetchone()

    if not ticket:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy phiếu bảo trì"
        )

    old_assigned_to = ticket["assigned_to"] or "Chưa gán"
    new_assigned_to = assigned_to.strip()
    now = datetime.now().isoformat()

    cursor.execute("""
        UPDATE maintenance_tickets
        SET assigned_to = ?, updated_at = ?
        WHERE id = ?
    """, (
        new_assigned_to,
        now,
        ticket_id
    ))

    note = f"Gán người phụ trách từ {old_assigned_to} sang {new_assigned_to}"

    cursor.execute("""
        INSERT INTO maintenance_notes
        (ticket_id, note, created_by, created_at)
        VALUES (?, ?, ?, ?)
    """, (
        ticket_id,
        note,
        assigned_by.strip() if assigned_by.strip() else "Hệ thống",
        now
    ))

    conn.commit()
    conn.close()

    return {
        "message": "Đã gán người phụ trách",
        "ticket_id": ticket_id,
        "assigned_to": new_assigned_to
    }   
    
@app.get("/api/maintenance/{ticket_id}/notes")
def get_maintenance_notes(ticket_id: int):
    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id
        FROM maintenance_tickets
        WHERE id = ?
    """, (ticket_id,))

    ticket = cursor.fetchone()

    if not ticket:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy phiếu bảo trì"
        )

    cursor.execute("""
        SELECT id, ticket_id, note, created_by, created_at
        FROM maintenance_notes
        WHERE ticket_id = ?
        ORDER BY id DESC
    """, (ticket_id,))

    rows = cursor.fetchall()
    conn.close()

    return [dict(row) for row in rows]

@app.post("/api/maintenance/{ticket_id}/notes")
def create_maintenance_note(
    ticket_id: int,
    note: str = Form(...),
    created_by: str = Form("")
):
    if not note.strip():
        raise HTTPException(
            status_code=400,
            detail="Nội dung ghi chú không được rỗng"
        )

    conn = get_db()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id
        FROM maintenance_tickets
        WHERE id = ?
    """, (ticket_id,))

    ticket = cursor.fetchone()

    if not ticket:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy phiếu bảo trì"
        )

    now = datetime.now().isoformat()

    cursor.execute("""
        INSERT INTO maintenance_notes
        (ticket_id, note, created_by, created_at)
        VALUES (?, ?, ?, ?)
    """, (
        ticket_id,
        note.strip(),
        created_by,
        now
    ))

    cursor.execute("""
        UPDATE maintenance_tickets
        SET updated_at = ?
        WHERE id = ?
    """, (
        now,
        ticket_id
    ))

    conn.commit()
    note_id = cursor.lastrowid
    conn.close()

    return {
        "message": "Đã thêm ghi chú xử lý",
        "note_id": note_id,
        "ticket_id": ticket_id
    }  
    
@app.get("/api/equipment/{code}/maintenance")
def get_equipment_maintenance_history(
    code: str,
    username: str = "",
    role: str = ""
):
    conn = get_db()
    cursor = conn.cursor()

    role = role.strip().lower()
    username = username.strip()

    cursor.execute("""
        SELECT id
        FROM equipment
        WHERE code = ?
    """, (code,))

    equipment = cursor.fetchone()

    if not equipment:
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy thiết bị"
        )

    query = """
        SELECT 
            mt.id,
            mt.equipment_code,
            mt.issue_title,
            mt.issue_description,
            mt.priority,
            mt.status,
            mt.image_path,
            mt.created_by,
            mt.assigned_to,
            u.full_name AS assigned_full_name,
            mt.created_at,
            mt.updated_at,
            e.name AS equipment_name,
            e.system AS equipment_system,
            e.location AS equipment_location,
            e.floor AS equipment_floor
        FROM maintenance_tickets mt
        LEFT JOIN equipment e ON mt.equipment_code = e.code
        LEFT JOIN users u ON mt.assigned_to = u.username
        WHERE mt.equipment_code = ?
    """

    params = [code]

    if role == "technician" and username:
        query += " AND mt.assigned_to = ?"
        params.append(username)

    query += " ORDER BY mt.id DESC"

    cursor.execute(query, params)
    rows = cursor.fetchall()
    conn.close()

    return [dict(row) for row in rows]      