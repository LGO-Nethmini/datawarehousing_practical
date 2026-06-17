# Warehouse & Mining Management Application

Full-stack data warehousing practical project with:

- Oracle 23ai workflow (OLTP -> Dimensions -> Data Mart)
- Flask backend API
- Tailwind frontend dashboard
- Oracle dimension metadata and performance comparison endpoints

## Project Structure

```text
datawarehousing_practical/
|-- backend/
|   |-- app.py
|   |-- config.py
|   |-- database.py
|   `-- requirements.txt
|-- frontend/
|   `-- index.html
|-- 01_OLTP_schema.sql
|-- 02_StarSchema_DWH.sql
|-- 03_sample_data.sql
|-- 07_phase2_performance_comparison.sql
|-- 09_phase3_staging_and_datamart.sql
|-- 10_phase3_demo_queries.sql
|-- 14_oracle_create_dimension_metadata.sql
|-- 17_oracle_dimension_runpack.sql
|-- ORACLE_CREATE_DIMENSION_STEP_BY_STEP.md
|-- FULL_REPORT.md
`-- run_all.sql
```

## Features

- One-click database initialization from API
- Create dimensions from OLTP data
- Create and populate data mart with aggregates
- Run OLTP vs star schema vs data mart comparison endpoint
- Dashboard controls for all phase actions

## Prerequisites

- Python 3.10+
- Oracle 23ai instance (or compatible Oracle service)
- VS Code or any terminal

## Installation & Setup

### 1) Backend setup

```powershell
cd backend
python -m pip install -r requirements.txt
```

### 2) Optional: Configure database credentials

Defaults in `backend/config.py`:

- user: `system`
- password: `oracle`
- host: `localhost`
- port: `1521`
- service_name: `freepdb1`

You can override with environment variables:

- `DWH_DB_HOST`
- `DWH_DB_PORT`
- `DWH_DB_USER`
- `DWH_DB_PASSWORD`
- `DWH_DB_SERVICE`

### 3) Run backend

```powershell
cd backend
python app.py
```

Backend runs at `http://localhost:5000`.

### 4) Run frontend

Option A: Open `frontend/index.html` directly.

Option B (recommended):

```powershell
cd frontend
python -m http.server 8000
```

Then open `http://localhost:8000`.

## Usage

1. Open frontend dashboard.
2. Click **Initialize Database**.
3. Click **Create Dimensions**.
4. Click **Create Data Mart**.
5. Click **Run Performance Comparison**.
6. Review stats and sample records.

## API Endpoints

- `GET /api/health`
- `POST /api/init-database`
- `POST /api/create-dimensions`
- `POST /api/create-data-mart`
- `GET /api/performance-comparison`
- `GET /api/customers`
- `GET /api/products`
- `GET /api/locations`
- `GET /api/sales`
- `GET /api/data-mart`
- `GET /api/stats`

## Oracle Notes

- This backend uses Oracle SQL through `oracledb`.
- The separate scripts `14_oracle_create_dimension_metadata.sql` and `17_oracle_dimension_runpack.sql` are preserved for explicit `CREATE DIMENSION` command demonstrations.

## Troubleshooting

1. Backend cannot connect to DB:
   - Confirm Oracle instance is reachable.
   - Verify host/port/service_name/user/password in `backend/config.py`.

2. Frontend shows fetch errors:
   - Ensure backend is running on `localhost:5000`.
   - Refresh browser after backend startup.

3. Oracle login MFA issue:
   - If verification shows `passcode sent to null`, account MFA reset is required by Oracle admin/support.

## Notes

- Backend and frontend now align to the phase actions described in your documentation.
- Existing SQL scripts remain available as academic artifacts and references.
