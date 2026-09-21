import pymysql

passwords = ['', 'root', 'password', 'admin', '123456', '1234', 'root123', 'stufac', 'mysql']
connected = False

for p in passwords:
    try:
        conn = pymysql.connect(host='127.0.0.1', port=3306, user='root', password=p, connect_timeout=3)
        print(f"SUCCESS: Connected to MySQL with root / '{p}'")
        cur = conn.cursor()
        cur.execute("SHOW DATABASES;")
        print("Existing Databases:", [r[0] for r in cur.fetchall()])
        conn.close()
        connected = True
        break
    except Exception as e:
        # print(f"Failed with '{p}': {e}")
        pass

if not connected:
    print("Could not auto-detect MySQL password. Need user's password.")
