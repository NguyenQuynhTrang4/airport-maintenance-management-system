import sqlite3
from datetime import datetime

DB_NAME = "airport.db"

conn = sqlite3.connect(DB_NAME)
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'technician',
    created_at TEXT
)
""")

sample_users = [
    ("Admin", "123456", "Quản trị hệ thống", "admin"),
    ("Trang", "123456", "Nguyễn Quỳnh Trang", "technician"),
    ("Supervisor", "123456", "Giám sát bảo trì", "supervisor"),
]

for username, password, full_name, role in sample_users:
    cursor.execute("""
    INSERT INTO users
    (username, password, full_name, role, created_at)
    VALUES (?, ?, ?, ?, ?)
    ON CONFLICT(username) DO UPDATE SET
        password = excluded.password,
        full_name = excluded.full_name,
        role = excluded.role
    """, (
        username,
        password,
        full_name,
        role,
        datetime.now().isoformat()
    ))

conn.commit()
conn.close()

print("Đã tạo/cập nhật bảng users và tài khoản mẫu.")