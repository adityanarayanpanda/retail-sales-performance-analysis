import pandas as pd
import mysql.connector

import pandas as pd
import mysql.connector

df = pd.read_csv("Sample - Superstore.csv",
    encoding="latin1"
)

print("Rows:", len(df))
print("Columns:", len(df.columns))


# Connect MySQL

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="Aditya06.com",
    database="retail_sales_analysis"
)

cursor = conn.cursor()

# Drop old table
cursor.execute("DROP TABLE IF EXISTS superstore")

# Create table
cursor.execute("""
CREATE TABLE superstore (
    row_id INT,
    order_id VARCHAR(30),
    order_date VARCHAR(20),
    ship_date VARCHAR(20),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(30),
    customer_name VARCHAR(255),
    segment VARCHAR(50),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(30),
    category VARCHAR(50),
    sub_category VARCHAR(100),
    product_name TEXT,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,4)
)
""")


# Insert Data
sql = """
INSERT INTO superstore VALUES (
%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,
%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s
)
"""

data = [tuple(row) for row in df.itertuples(index=False, name=None)]

cursor.executemany(sql, data)

conn.commit()

print("Data Imported Successfully!")
print("Rows Inserted:", cursor.rowcount)

cursor.close()
conn.close()