import sqlite3

DB_NAME = "airport.db"

conn = sqlite3.connect(DB_NAME)
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS maintenance_notes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ticket_id INTEGER NOT NULL,
    note TEXT NOT NULL,
    created_by TEXT,
    created_at TEXT,
    FOREIGN KEY (ticket_id) REFERENCES maintenance_tickets(id)
)
""")

conn.commit()
conn.close()

print("Đã tạo bảng maintenance_notes.")