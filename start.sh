#!/bin/bash
# =============================================================
# Oracle Inventory R12.2 - Application Starter
# Starts both backend API and frontend React app
# =============================================================

echo "========================================================"
echo " Oracle Inventory R12.2 - Starting Application"
echo "========================================================"

# Install backend dependencies
echo ""
echo "[1/3] Installing backend dependencies..."
cd backend
npm install
cd ..

# Install frontend dependencies
echo ""
echo "[2/3] Installing frontend dependencies..."
cd frontend
npm install
cd ..

echo ""
echo "[3/3] Starting servers..."
echo "  Backend API  → http://localhost:5000"
echo "  Frontend App → http://localhost:3000"
echo ""

# Start backend in background
cd backend && npm start &
BACKEND_PID=$!

# Give backend a moment to start
sleep 2

# Start frontend
cd ../frontend && npm start &
FRONTEND_PID=$!

echo ""
echo "========================================================"
echo " ✅ Application running!"
echo " Open: http://localhost:3000"
echo ""
echo " Press Ctrl+C to stop both servers"
echo "========================================================"

# Wait for both
wait $BACKEND_PID $FRONTEND_PID
