@echo off
cd /d %~dp0
set BACKEND_PORT=8765
python app.py
