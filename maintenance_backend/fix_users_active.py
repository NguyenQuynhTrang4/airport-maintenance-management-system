import sqlite3

DB_NAME = "airport.db"

conn = sqlite3.connect(DB_NAME)
cursor = conn.cursor()

cursor.execute("PRAGMA table_info(users)")
columns = [row[1] for row in cursor.fetchall()]

if "active" not in columns:
    cursor.execute("ALTER TABLE users ADD COLUMN active INTEGER DEFAULT 1")
    print("Đã thêm cột active vào bảng users.")
else:
    print("Cột active đã tồn tại.")

cursor.execute("""
    UPDATE users
    SET active = 1
    WHERE active IS NULL
""")

conn.commit()
conn.close()

print("Hoàn tất cập nhật bảng users.")