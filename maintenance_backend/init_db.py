import sqlite3
from datetime import datetime

conn = sqlite3.connect("airport.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS equipment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    system TEXT,
    location TEXT,
    floor TEXT,
    area TEXT,
    status TEXT DEFAULT 'normal',
    description TEXT,
    created_at TEXT
)
""")

cursor.execute("""
CREATE TABLE IF NOT EXISTS maintenance_tickets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    equipment_code TEXT NOT NULL,
    title TEXT,
    issue_type TEXT,
    priority TEXT,
    description TEXT,
    image_path TEXT,
    status TEXT DEFAULT 'open',
    created_by TEXT,
    created_at TEXT,
    FOREIGN KEY (equipment_code) REFERENCES equipment(code)
)
""")

cursor.execute("""
INSERT OR IGNORE INTO equipment
(code, name, system, location, floor, area, status, description, created_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
""", (
    "LTIA-CCTV-CAM-001",
    "Camera khu vực Check-in A",
    "CCTV",
    "Nhà ga hành khách - Check-in A",
    "Tầng 3",
    "Zone A",
    "normal",
    "Camera giám sát khu vực quầy check-in A",
    datetime.now().isoformat()
))

conn.commit()
conn.close()

print("Database initialized successfully.")