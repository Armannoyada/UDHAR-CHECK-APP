# Backend Server Setup Guide

## Problem
When you click "Sign In" or "Submit" in the app, nothing happens because the backend server is not running.

## Solution: Start the Backend Server

### Step 1: Check if Backend Code Exists
According to your API documentation, the backend should be running on `http://localhost:5000`

### Step 2: Start Your Backend Server

#### If using Node.js/Express backend:
```bash
cd path/to/your/backend
npm install
npm start
# OR
node server.js
# OR
npm run dev
```

#### If using Python/Flask backend:
```bash
cd path/to/your/backend
pip install -r requirements.txt
python app.py
# OR
flask run --port=5000
```

### Step 3: Verify Backend is Running
Open a browser and go to:
- **API Docs**: http://localhost:5000/api-docs
- **Health Check**: http://localhost:5000/api/health (if available)

You should see the API documentation or a response from the server.

### Step 4: Test the App Again
1. Make sure the backend is running (you should see console logs)
2. Open the emulator
3. Try logging in again

## Quick Test Credentials
According to the login page, these test accounts should work:
- **Admin**: admin@udharcheck.com / admin123
- **Lender**: lender@udharcheck.com / lender123  
- **Borrower**: borrower@udharcheck.com / borrower123

## Common Issues

### Issue 1: Backend Not Found
**Error**: "No internet connection" or "Connection timeout"
**Solution**: Make sure backend is running on port 5000

### Issue 2: Port Already in Use
**Error**: "Port 5000 is already in use"
**Solution**: 
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :5000
kill -9 <PID>
```

### Issue 3: Android Emulator Can't Connect
The app uses `http://10.0.2.2:5000/api` which maps to `localhost:5000` on your computer.
This is correct for Android emulator.

### Issue 4: Real Device Testing
If testing on a real device, you need to:
1. Connect phone and computer to same WiFi
2. Find your computer's IP address
3. Update the baseUrl in `lib/core/utils/constants.dart` to use your IP:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:5000/api';
   ```

## Current App Configuration
- **Base URL**: `http://10.0.2.2:5000/api` (for emulator)
- **API Docs**: Port 5000
- **Login Endpoint**: `/api/auth/login`
- **Register Endpoint**: `/api/auth/register`

## Next Steps After Backend Starts
1. The app will connect to backend
2. Login/Register will work
3. After successful login as borrower, you'll see the onboarding flow
4. Complete the 3 steps: Address → ID Verification → Selfie
5. Wait for admin verification
6. Access full app features
