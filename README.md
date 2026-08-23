# Fullstack Project (Flutter + FastAPI + PostgreSQL Docker)

Dự án Fullstack gồm ứng dụng di động **Flutter** áp dụng **Clean Architecture**, dịch vụ **Backend** sử dụng **Python FastAPI**, và cơ sở dữ liệu **PostgreSQL** chạy qua **Docker**.

---

## 📁 Cấu trúc Dự Án

```text
demo_watechs/
├── docker-compose.yml        # Cấu hình Docker cho PostgreSQL Container
├── backend/                  # Python FastAPI Backend
│   ├── app/
│   │   ├── api/              # API Endpoints & Routes (v1)
│   │   │   ├── v1/
│   │   │   │   ├── endpoints/ # health, auth, items
│   │   │   │   └── api.py
│   │   │   └── deps.py       # Auth & DB Dependencies
│   │   ├── core/             # Configuration, Security, DB session
│   │   ├── models/           # SQLAlchemy Models (User, Item)
│   │   ├── schemas/          # Pydantic Request/Response Schemas
│   │   ├── services/         # Business & Data Access Logic
│   │   └── main.py           # Entry point
│   ├── requirements.txt      # Python dependencies (fastapi, sqlalchemy, psycopg2, ...)
│   ├── .env.example          # Environment variables template
│   └── README.md
│
└── mobile/                   # Flutter Mobile App (Clean Architecture)
    ├── lib/
    │   ├── core/             # Shared constants, network client, errors, themes, DI
    │   │   ├── constants/    # API & App constants
    │   │   ├── di/           # GetIt service locator
    │   │   ├── error/        # Exceptions & Failures
    │   │   ├── network/      # Dio client & interceptors
    │   │   ├── theme/        # App Material 3 theme
    │   │   └── utils/        # UseCase interface
    │   ├── features/         # Feature-first Clean Architecture
    │   │   └── auth/
    │   │       ├── data/     # DataSources (Remote/Local), Models, Repo Impl
    │   │       ├── domain/   # Entities, Repo Interface, UseCases
    │   │       └── presentation/ # BLoC State Management, Pages, Widgets
    │   └── main.dart         # Flutter entry point
    └── pubspec.yaml
```

---

## 🚀 Hướng Dẫn Khởi Chạy

### 1. Khởi động PostgreSQL qua Docker
Tại thư mục gốc dự án:
```bash
docker compose up -d
```
Container `demo_postgres` sẽ được khởi chạy trên cổng `5432` với database `fastapi_db`.

---

### 2. Khởi động Backend (FastAPI)

```bash
cd backend

# 1. Kích hoạt virtualenv (nếu chưa có: python -m venv venv)
.\venv\Scripts\Activate.ps1   # Trên Windows PowerShell

# 2. Cài đặt thư viện (bao gồm psycopg2-binary)
pip install -r requirements.txt

# 3. Chạy server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- **API Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs)
- **Health Check**: [http://localhost:8000/api/v1/health/](http://localhost:8000/api/v1/health/)

---

### 3. Khởi động Mobile App (Flutter)

```bash
cd mobile

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

> **Lưu ý kết nối API từ Mobile:**
> - Android Emulator: sử dụng `http://10.0.2.2:8000/api/v1` (mặc định đã cấu hình trong `lib/core/constants/api_constants.dart`).
> - iOS Simulator: sử dụng `http://localhost:8000/api/v1`.
> - Thiết bị thật: đổi IP thành địa chỉ IP LAN của máy tính chạy server (ví dụ: `http://192.168.1.X:8000/api/v1`).
