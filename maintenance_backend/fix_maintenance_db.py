import sqlite3

DB_NAME = "airport.db"

columns_to_add = {
    "issue_title": "TEXT",
    "issue_description": "TEXT",
    "priority": "TEXT DEFAULT 'normal'",
    "image_path": "TEXT",
    "created_by": "TEXT",
    "updated_at": "TEXT"
}

conn = sqlite3.connect(DB_NAME)
cursor = conn.cursor()

cursor.execute("PRAGMA table_info(maintenance_tickets)")
existing_columns = [row[1] for row in cursor.fetchall()]

print("Các cột hiện có trong maintenance_tickets:")
print(existing_columns)

for column_name, column_type in columns_to_add.items():
    if column_name not in existing_columns:
        cursor.execute(
            f"ALTER TABLE maintenance_tickets ADD COLUMN {column_name} {column_type}"
        )
        print(f"Đã thêm cột: {column_name}")
    else:
        print(f"Cột đã tồn tại: {column_name}")

conn.commit()
conn.close()

print("Hoàn tất sửa bảng maintenance_tickets.")