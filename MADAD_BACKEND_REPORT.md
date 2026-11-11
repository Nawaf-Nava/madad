# MADAD Backend & Integration Report

This report describes backend source code only. It is not evidence that PostgreSQL, migrations, dependencies, the API server, or Flutter integration have been run successfully.

---

## 1. Backend Server Architecture
- **Framework**: Node.js with Express.js REST API.
- **Structure**:
  - `src/index.js`: Main server entry point and health check endpoint (`/health`).
  - `src/routes/`: Modular routing (`authRoutes.js`, `walletRoutes.js`).
  - `src/controllers/`: Business logic controllers (`authController.js`).
  - `src/middleware/`: Security and JWT verification middleware (`auth.js`).
- **Features**: CORS, JSON body parsing, and environment configuration via `dotenv`.

## 2. PostgreSQL Database & Prisma ORM
- **ORM**: Prisma ORM with PostgreSQL.
- **Schema Entities**:
  - `User` & `UserProfile`: User credentials, verification, and profile metadata.
  - `Wallet`: Multi-currency wallet accounts with balances and status.
  - `Transaction`: Ledger records supporting transfers, payments, gifts, and deposits with **Idempotency Keys**.
  - `TransferRequest`, `Beneficiary`, `Bill`, `SavingsGoal`, `Gift`, `Notification`, `Device`, `UserSession`, `AuditLog`, `AppSetting`.
- **Integrity**: Declared primary/unique constraints and relational foreign keys.

## 3. Authentication & Security
- **Password Security**: Bcrypt password hashing (`salt rounds: 10`).
- **Token Management**: JWT Access Tokens (`15m` expiry) and Refresh Tokens (`7d` expiry).
- **Protected Routes**: Middleware verifying Bearer tokens on sensitive financial endpoints.

## 4. Environment & Secret Management
- Configured via `.env` and `.env.example`.
- Secrets separated from code (JWT secrets, database connection strings).

## 5. Current verification boundary

- Startup requires a database URL and non-placeholder JWT secrets, then checks the PostgreSQL connection before listening.
- New users receive an empty wallet; signup does not mint demo funds.
- Transfers return `503 FINANCIAL_PROVIDER_UNAVAILABLE` until an authorized provider and settlement flow are configured.
- PostgreSQL availability, Prisma migrations/client generation, API requests, and Flutter integration remain unverified.
- Docker and Docker Compose are not part of this project. PostgreSQL is intended to run as a separate Linux service.

---
*Generated for MADAD (مَدَد) Independent Reconstruction Project.*
