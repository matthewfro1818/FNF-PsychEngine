@echo off
setlocal enabledelayedexpansion

set "base=assets\base_game"
set "backup=scripts\broken_links_backup"

echo Base dir: %base%
echo Backup root: %backup%

if not exist "%base%" (
    echo Base directory missing: %base%
    exit /b 1
)

mkdir "%backup%" 2>nul

set moved=0
set errors=0

for /d %%i in ("%base%\*") do (
    set "child=%%i"
    set "name=%%~nxi"
    
    if exist "%%i" (
        dir "%%i" >nul 2>&1
        if errorlevel 1 (
            set "dest=%backup%\!name!"
            move "%%i" "!dest!" >nul 2>&1
            if errorlevel 1 (
                echo Error moving !name!: move failed
                set /a errors+=1
            ) else (
                echo Moved broken entry: %%i -^> !dest!
                set /a moved+=1
            )
        )
    ) else (
        echo Error: !name! does not exist
        set /a errors+=1
    )
)

echo.
echo Summary:
echo Moved: %moved%
if %errors% gtr 0 (
    echo Errors: %errors%
) else (
    echo No errors.
)

pause