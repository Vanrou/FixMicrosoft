@echo off
:: ==============================================
::  Add/Remove "Open with Code" Context Menu
::  Works for folders, background, and files
::  Supports both system-wide & user installs
:: ==============================================

setlocal EnableDelayedExpansion

:: --- Check for admin rights ---
net session >nul 2>&1a
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: --- Menu for user ---
echo.
echo [1] Add "Open with Code" to context menu
echo [2] Remove "Open with Code" from context menu
echo.
set /p choice="Enter choice (1/2): "

:: --- Detect VS Code path ---
set "vscode_path="
for %%d in (
    "%ProgramFiles%\Microsoft VS Code\Code.exe"
    "%LocalAppData%\Programs\Microsoft VS Code\Code.exe"
) do if exist "%%~d" set "vscode_path=%%~d"

if not defined vscode_path (
    if "%choice%"=="1" (
        echo.
        echo Error: VS Code not found in:
        echo - "%ProgramFiles%\Microsoft VS Code\Code.exe"
        echo - "%LocalAppData%\Programs\Microsoft VS Code\Code.exe"
        pause
        exit /b
    )
)

:: --- Registry actions ---
if "%choice%"=="1" (
    echo Adding "Open with Code"...

    (
        echo Windows Registry Editor Version 5.00
        echo;
        echo [-HKEY_CLASSES_ROOT\Directory\shell\OpenWithCode]
        echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\OpenWithCode]
        echo [-HKEY_CLASSES_ROOT\*\shell\OpenWithCode]
        echo;
        echo [HKEY_CLASSES_ROOT\Directory\shell\OpenWithCode]
        echo @="Open with Code"
        echo "Icon"="\"%vscode_path:\=\\%\",0"
        echo;
        echo [HKEY_CLASSES_ROOT\Directory\shell\OpenWithCode\command]
        echo @="\"%vscode_path:\=\\%\" \"%%1\""
        echo;
        echo [HKEY_CLASSES_ROOT\Directory\Background\shell\OpenWithCode]
        echo @="Open with Code"
        echo "Icon"="\"%vscode_path:\=\\%\",0"
        echo;
        echo [HKEY_CLASSES_ROOT\Directory\Background\shell\OpenWithCode\command]
        echo @="\"%vscode_path:\=\\%\" \"%%V\""
        echo;
        echo [HKEY_CLASSES_ROOT\*\shell\OpenWithCode]
        echo @="Open with Code"
        echo "Icon"="\"%vscode_path:\=\\%\",0"
        echo;
        echo [HKEY_CLASSES_ROOT\*\shell\OpenWithCode\command]
        echo @="\"%vscode_path:\=\\%\" \"%%1\""
    ) > "%temp%\OpenWithCode.reg"

    regedit /s "%temp%\OpenWithCode.reg"
    del "%temp%\OpenWithCode.reg"

    echo Done! Context menu added.

) else if "%choice%"=="2" (
    echo Removing "Open with Code"...

    (
        echo Windows Registry Editor Version 5.00
        echo;
        echo [-HKEY_CLASSES_ROOT\Directory\shell\OpenWithCode]
        echo [-HKEY_CLASSES_ROOT\Directory\Background\shell\OpenWithCode]
        echo [-HKEY_CLASSES_ROOT\*\shell\OpenWithCode]
    ) > "%temp%\RemoveOpenWithCode.reg"

    regedit /s "%temp%\RemoveOpenWithCode.reg"
    del "%temp%\RemoveOpenWithCode.reg"

    echo Done! Context menu removed.
) else (
    echo Invalid choice.
    exit /b
)

:: --- Refresh shell without killing Explorer ---
ie4uinit.exe -ClearIconCache >nul 2>&1
powershell -Command "$null = New-Object -ComObject Shell.Application; Start-Sleep -Milliseconds 500"

echo.
echo Changes applied successfully.
pause
