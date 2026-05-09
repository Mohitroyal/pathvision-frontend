@echo off
echo ==================================================
echo   PATHVISION OS: NEURAL SUPABASE INITIALIZER
echo ==================================================
echo.
echo Initializing Cloud Database...
echo.

:: Point to the backend folder where 'pg' is installed
cd ..\backend

node -e "const { Pool } = require('pg'); const fs = require('fs'); const pool = new Pool({ host: 'db.bykivmvznqbgnnjlokxd.supabase.co', port: 5432, user: 'postgres', password: 'pathvision123', database: 'postgres', ssl: { rejectUnauthorized: false } }); const sql = fs.readFileSync('../flutter_project/supabase_schema.sql', 'utf8'); console.log('Connecting to Supabase...'); pool.query(sql, (err, res) => { if (err) { console.error('❌ Sync Failed:', err.message); } else { console.log('✅ NEURAL SYNC COMPLETE: Your AI OS is now LIVE on Supabase!'); } process.exit(); });"

cd ..\flutter_project

echo.
echo ==================================================
pause
