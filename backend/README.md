# Backend API (Python FastAPI + PostgreSQL Docker)

Dự án Backend sử dụng FastAPI với kiến trúc chuẩn, hỗ trợ JWT Authentication, CRUD REST API và cơ sở dữ liệu PostgreSQL.

## 🛠️ Cài đặt & Khởi chạy

### 1. Khởi động PostgreSQL qua Docker
Từ thư mục gốc dự án:
```bash
docker compose up -d
```

### 2. Tạo môi trường ảo & Cài đặt dependencies
```bash
cd backend
python -m venv venv
# Windows (PowerShell):
.\venv\Scripts\Activate.ps1
# Windows (cmd):
.\venv\Scripts\activate.bat
# Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt
```

### 3. Cấu hình biến môi trường
File `.env` mặc định đã trỏ tới PostgreSQL Docker:
```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/fastapi_db
```

### 4. Khởi chạy Server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- Swagger UI docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
- Health Check: http://localhost:8000/api/v1/health/
