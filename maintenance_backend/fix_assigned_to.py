import sqlite3

DB_NAME = "airport.db"

conn = sqlite3.connect(DB_NAME)
cursor = conn.cursor()

cursor.execute("PRAGMA table_info(maintenance_tickets)")
columns = [row[1] for row in cursor.fetchall()]

if "assigned_to" not in columns:
    cursor.execute("ALTER TABLE maintenance_tickets ADD COLUMN assigned_to TEXT")
    print("Đã thêm cột assigned_to vào bảng maintenance_tickets.")
else:
    print("Cột assigned_to đã tồn tại.")

conn.commit()
conn.close()

print("Hoàn tất cập nhật database.")