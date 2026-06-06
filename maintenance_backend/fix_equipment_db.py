import sqlite3

DB_NAME = "airport.db"

columns_to_add = {
    "equipment_type": "TEXT",
    "ip_address": "TEXT",
    "serial_number": "TEXT",
    "model": "TEXT",
    "manufacturer": "TEXT",
    "created_at": "TEXT"
}

conn = sqlite3.connect(DB_NAME)
cursor = conn.cursor()

cursor.execute("PRAGMA table_info(equipment)")
existing_columns = [row[1] for row in cursor.fetchall()]

print("Các cột hiện có trong bảng equipment:")
print(existing_columns)

for column_name, column_type in columns_to_add.items():
    if column_name not in existing_columns:
        sql = f"ALTER TABLE equipment ADD COLUMN {column_name} {column_type}"
        cursor.execute(sql)
        print(f"Đã thêm cột: {column_name}")
    else:
        print(f"Cột đã tồn tại: {column_name}")

conn.commit()
conn.close()

print("Hoàn tất sửa bảng equipment.")