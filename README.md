# Oracle Inventory R12.2 – Training Data Manager

A full-stack ReactJS + Node.js + PostgreSQL application for managing Oracle Inventory R12.2 training data, with Row-Level Security (RLS) policies enforced at the database level.

---

## 📦 Contents

```
oracle-inv-app/
├── migrations/
│   ├── 001_schema.sql        # PostgreSQL schema + RLS policies
│   └── 002_seed_data.sql     # All training data from New_Project.xlsx
├── backend/
│   ├── src/
│   │   ├── index.js          # Express API server
│   │   ├── config/db.js      # PostgreSQL connection + RLS context
│   │   ├── middleware/rlsContext.js
│   │   └── routes/           # CRUD routes for all 37 tables
│   └── package.json
├── frontend/
│   ├── src/
│   │   ├── App.js            # Main app + all routes
│   │   ├── App.css           # Styling
│   │   ├── api/index.js      # Axios API client
│   │   ├── context/UserContext.js
│   │   ├── components/
│   │   │   ├── DataTable.js  # Generic CRUD table
│   │   │   ├── Sidebar.js    # Navigation
│   │   │   └── Header.js     # RLS user switcher
│   │   └── pages/
│   │       ├── Dashboard.js
│   │       └── OnhandPage.js
│   └── package.json
├── setup-db.sh               # One-time DB setup
├── start.sh                  # Start both servers
└── README.md
```

---

## 🛠 Prerequisites

1. **Node.js** v16+ — https://nodejs.org
2. **PostgreSQL** v13+ — https://www.postgresql.org/download
3. npm (comes with Node.js)

---

## 🚀 Quick Start

### Step 1 — Setup Database (run once)

```bash
# Make sure PostgreSQL is running
# Update PGUSER if your postgres superuser is different
chmod +x setup-db.sh
./setup-db.sh
```

This will:
- Create database `oracle_inv`
- Create all 37 tables with proper FK relationships
- Apply PostgreSQL RLS policies
- Create `inv_app_user` role
- Load all training data (2,400+ rows)

### Step 2 — Start Application

```bash
chmod +x start.sh
./start.sh
```

Or start manually:

```bash
# Terminal 1 - Backend
cd backend
npm install
npm start       # Runs on http://localhost:5000

# Terminal 2 - Frontend
cd frontend
npm install
npm start       # Runs on http://localhost:3000
```

### Step 3 — Open Browser

Navigate to **http://localhost:3000**

---

## 🔐 Row-Level Security (RLS) Architecture

### How it works

PostgreSQL RLS is configured at the database level. Every query runs within an authenticated session context, and PostgreSQL automatically filters rows based on the user's security profile.

```
User Login → Profile Assigned → security_profile_access defines allowed org access
→ PostgreSQL set_app_context() called → RLS policies filter every SELECT/INSERT/UPDATE/DELETE
```

### Security Profiles

| Profile | User | Access Scope |
|---------|------|-------------|
| PRF00001 (ALL_ACCESS) | INV_ADMIN_VVSPL | All 3 business types, all 3 inv orgs |
| PRF00002 (Medical_ACCESS) | INV_USER_MEDICAL | Medical only → INV00001 (Civil) |
| PRF00003 (Hardware_ACCESS) | INV_USER_HARDWARE | Hardware only → INV00002 (Gandhi) |
| PRF00004 (Hotel_ACCESS) | INV_USER_HOTEL | Hotel only → INV00003 (Janata) |

### Tables with RLS Applied

- `item_master` — filtered by `business_type_id`
- `item_org_assignment` — filtered by `inv_org_id`
- `subinventory` — filtered by `inv_org_id`
- `locator` — filtered by `inv_org_id`
- `onhand_balance` — filtered by `inv_org_id` *(most critical)*
- `item_subinventory_restriction` — filtered by `inv_org_id`
- `item_transaction_defaults` — filtered by `inv_org_id`
- `accounting_period` — filtered by `inv_org_id`
- `org_parameters` — filtered by `inv_org_id`
- `category` — filtered by `business_type_id`
- `category_set` — filtered by `business_type_id`

### Testing RLS

In the top-right header, click the user name dropdown to **switch RLS context**:

1. Select **Admin (All Access)** → Dashboard shows ~900 onhand records across 3 orgs
2. Select **Medical User** → Dashboard shows only ~300 records for INV00001 (Civil)
3. Select **Hardware User** → Dashboard shows only ~300 records for INV00002 (Gandhi)

---

## 📊 Data Overview

| Table | Records | RLS |
|-------|---------|-----|
| COMPANY | 1 | — |
| SECURITY_PROFILE | 5 | — |
| SECURITY_USER | 5 | — |
| BUSINESS_TYPE | 3 | — |
| LEGAL_ENTITY | 3 | — |
| OPERATING_UNIT | 6 | — |
| INV_ORGANIZATION | 3 | — |
| LOCATION | 13 | — |
| ITEM_MASTER | 300 | ✅ |
| ITEM_ORG_ASSIGNMENT | 300 | ✅ |
| SUBINVENTORY | 12 | ✅ |
| LOCATOR | 72 | ✅ |
| ITEM_SUBINVENTORY_RESTRICTION | 600 | ✅ |
| ITEM_TRANSACTION_DEFAULTS | 300 | ✅ |
| ONHAND_BALANCE | 900 | ✅ |
| CATEGORY | 30 | ✅ |
| UOM | 7 | — |
| ... and more | | |

---

## 🏢 Organization Hierarchy

```
VVSPL (Company)
└── BusinessGroup_ArjunTower
    ├── LE_Medical → OU_Bapat, OU_Jatpura → InventoryOrg_Civil (INV00001)
    ├── LE_Hardware → OU_Bangali, OU_Sarkar → InventoryOrg_Gandhi (INV00002)
    └── LE_Hotel → OU_Pathanpura, OU_Giranar → InventoryOrg_Janata (INV00003)
```

---

## 🌐 API Endpoints

All endpoints require RLS context headers:

```
X-User-Id: USR00001
X-Company-Id: COMP00001
X-Profile-Id: PRF00001
```

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/items | List items (RLS filtered) |
| POST | /api/items | Create item |
| PUT | /api/items/:id | Update item |
| DELETE | /api/items/:id | Delete item |
| GET | /api/onhand/detailed | Onhand with joins + filters |
| GET | /api/onhand/summary-by-org | Aggregated onhand per org |
| GET | /api/organization/hierarchy | Full org tree |
| GET | /api/security/users-with-profiles | Users with profile info |

---

## ⚙️ Configuration

Backend config in `backend/.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=oracle_inv
DB_USER=inv_app_user
DB_PASSWORD=InvApp@2026!
PORT=5000
```

---

## 🔧 Troubleshooting

**PostgreSQL connection refused?**
```bash
sudo service postgresql start
# or on macOS:
brew services start postgresql
```

**Permission denied on shell scripts?**
```bash
chmod +x setup-db.sh start.sh
```

**Port 3000 or 5000 already in use?**
```bash
# Kill the process using the port
lsof -ti:3000 | xargs kill -9
lsof -ti:5000 | xargs kill -9
```

**`psql: error: role "postgres" does not exist`?**
```bash
# Use your system username
PGUSER=$(whoami) ./setup-db.sh
```
