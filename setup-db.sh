#!/bin/bash
# =============================================================
# Oracle Inventory R12.2 - Database Setup Script
# Run this ONCE to create the database, schema, and seed data
# =============================================================

set -e

DB_NAME="oracle_inv"
DB_SUPERUSER="${PGUSER:-postgres}"

echo "========================================================"
echo " Oracle Inventory R12.2 - Database Setup"
echo "========================================================"

echo ""
echo "[1/3] Creating database '$DB_NAME'..."
psql -U "$DB_SUPERUSER" -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || echo "  (Database may already exist - continuing)"

echo ""
echo "[2/3] Applying schema (001_schema.sql)..."
psql -U "$DB_SUPERUSER" -d "$DB_NAME" -f migrations/001_schema.sql
echo "  ✓ Schema applied (tables, RLS policies, functions)"

echo ""
echo "[3/3] Loading seed data (002_seed_data.sql)..."
psql -U "$DB_SUPERUSER" -d "$DB_NAME" -f migrations/002_seed_data.sql
echo "  ✓ Seed data loaded"

echo ""
echo "========================================================"
echo " ✅ Database setup complete!"
echo " Database: $DB_NAME"
echo " App user: inv_app_user"
echo " Password: InvApp@2026!"
echo "========================================================"
echo ""
echo "Next: Run './start.sh' to start the application"
