import sqlite3

DB_NAME = "airport.db"

conn = sqlite3.connect(DB_NAME)
cursor = conn.cursor()

try:
    cursor.execute("ALTER TABLE maintenance_tickets ADD COLUMN updated_at TEXT")
    print("Đã thêm cột updated_at vào bảng maintenance_tickets.")
except sqlite3.OperationalError as e:
    if "duplicate column name" in str(e):
        print("Cột updated_at đã tồn tại, không cần thêm lại.")
    else:
        raise e

conn.commit()
conn.close()

print("Fix database completed.")