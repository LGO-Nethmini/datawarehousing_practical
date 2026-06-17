import os


DB_CONFIG = {
    "user": os.getenv("DWH_DB_USER", "dwhapp"),
    "password": os.getenv("DWH_DB_PASSWORD", "Dwhapp@2026"),
    "host": os.getenv("DWH_DB_HOST", "localhost"),
    "port": int(os.getenv("DWH_DB_PORT", "1521")),
    "service_name": os.getenv("DWH_DB_SERVICE", "freepdb1"),
}

APP_CONFIG = {
    "oracle_client_mode": os.getenv("DWH_ORACLE_CLIENT_MODE", "thin"),
}
