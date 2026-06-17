from flask import Flask, jsonify
from flask_cors import CORS

from database import Database


app = Flask(__name__)
CORS(app)


def with_db(action):
    db = Database()
    try:
        return action(db)
    finally:
        db.close()


@app.get("/api/health")
def health() -> tuple[dict, int]:
    return {"status": "ok"}, 200


@app.post("/api/init-database")
def init_database():
    try:
        with_db(lambda db: db.initialize_database())
        return jsonify({"message": "Database initialized successfully"}), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.post("/api/create-dimensions")
def create_dimensions():
    try:
        with_db(lambda db: db.create_phase3_dimensions())
        return jsonify({"message": "Dimensions created successfully"}), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.post("/api/create-data-mart")
def create_data_mart():
    try:
        def _work(db: Database):
            db.create_sales_data_mart()
            db.populate_sales_data_mart()

        with_db(_work)
        return jsonify({"message": "Data mart created and populated successfully"}), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.get("/api/performance-comparison")
def performance_comparison():
    try:
        rows = with_db(lambda db: db.get_performance_comparison())
        return jsonify(rows), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.get("/api/customers")
def customers():
    try:
        rows = with_db(lambda db: db.fetch_all("SELECT * FROM Customers ORDER BY customer_id"))
        return jsonify(rows), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.get("/api/products")
def products():
    try:
        rows = with_db(lambda db: db.fetch_all("SELECT * FROM Products ORDER BY product_id"))
        return jsonify(rows), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.get("/api/locations")
def locations():
    try:
        rows = with_db(lambda db: db.fetch_all("SELECT * FROM Locations ORDER BY location_id"))
        return jsonify(rows), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.get("/api/sales")
def sales():
    try:
        rows = with_db(
            lambda db: db.fetch_all(
                """
                SELECT s.sale_id, s.sale_date, s.quantity, s.total_amount,
                       p.product_name, l.city AS location_city
                FROM Sales s
                JOIN Products p ON s.product_id = p.product_id
                JOIN Locations l ON s.location_id = l.location_id
                ORDER BY s.sale_id
                """
            )
        )
        return jsonify(rows), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.get("/api/data-mart")
def data_mart():
    try:
        rows = with_db(
            lambda db: db.fetch_all(
                """
                SELECT mart_id, product_name, location_name,
                       total_quantity, total_amount, avg_sale_amount, last_updated
                FROM Sales_Data_Mart
                ORDER BY mart_id
                """
            )
        )
        return jsonify(rows), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@app.get("/api/stats")
def stats():
    try:
        payload = with_db(lambda db: db.get_stats())
        return jsonify(payload), 200
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
