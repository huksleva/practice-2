@echo off
chcp 1251 >nul
cls
setlocal enabledelayedexpansion

::===================================================
:: ������ ��� ��������� �������� �������� ����� winget
:: ������� ��� ��������� �� ������
:: ������� ������� "�� ����� ��������������"
::===================================================

color 0C
echo.
echo ??  ��������: ���� ������ ����� �������� ��������!
echo    ����� ������� ��� ��������� ����������.
echo    ������� Ctrl+C, ���� ������ ��������.
echo.
pause

:: �������� ���� ��������������
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo ? ������: ��������� ����� ��������������.
    pause
    exit /b
)

echo.
echo ?? ���� ������������� ���������...
echo.

:: ������ ID �������� ��� �������� (�� ��, ��� �������������)
set "programs=Notepad++.Notepad++ Mozilla.Firefox Git.Git VideoLAN.VLC Google.Chrome"

for %%p in (%programs%) do (
    echo ?? ��������� � �������: %%p
    winget uninstall --id "%%p" --silent --accept-package-agreements --force >nul 2>&1
    if !errorlevel! EQU 0 (
        echo ? �������: %%p
    ) else (
        winget list --id "%%p" >nul 2>&1
        if !errorlevel! EQU 0 (
            echo ??  �� ������� �������: %%p (��������, ��������� ������������ ��� ������ ��������)
        ) else (
            echo ?? ��������� �� �������: %%p (������ ������� �� �����)
        )
    )
    echo.
)







::===================================================
:: �������� Sber Jazz � Yandex.Telemost
:: ��������� �� ����� ��������������
::===================================================

color 0C
echo.
echo ��������: ���� ������ ������ Sber Jazz � Yandex.Telemost!
echo    ������� Ctrl+C � �������� "���", ����� ��������.
echo.
pause

:: �������� ���� ��������������
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo ������: ��������� ����� ��������������.
    pause
    exit /b
)

echo.
echo �������� �������� ��������...
echo.

::============================================
:: ��������: Sber Jazz
::============================================
echo ������� Sber Jazz...

:: ���� � uninstall.exe (����������� ������������)
set "JAZZ_UNINSTALL=%ProgramFiles%\Sber Jazz\uninstall.exe"
set "JAZZ_UNINSTALL_X86=%ProgramFiles(x86)%\Sber Jazz\uninstall.exe"

if exist "%JAZZ_UNINSTALL%" (
    echo   ������ �������������. ������...
    start /wait "" "%JAZZ_UNINSTALL%" /S
    echo Sber Jazz ������� �����.
) else if exist "%JAZZ_UNINSTALL_X86%" (
    echo   ������ ������������� (x86). ������...
    start /wait "" "%JAZZ_UNINSTALL_X86%" /S
    echo Sber Jazz ������� �����.
) else (
    echo Sber Jazz �� ������ � ��������, ��� ����� ��� �� ��������������.
)

::============================================
:: ��������: Yandex.Telemost
::============================================
echo.
echo ������� Yandex.Telemost...

:: ���� � ������� ���� �������� ����� msiexec ��� exe
for /f "skip=2 tokens=2,*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Yandex Telemost" /v UninstallString 2^>nul') do (
    set "UNINSTALL_CMD=%%b"
)

if defined UNINSTALL_CMD (
    echo   ������� ������� ��������. ������...
    call !UNINSTALL_CMD! /verysilent /allusers
    echo Yandex.Telemost ������� �����.
    goto TelemostCleanup
)

:: ������������: ����� �� ������������ ����
set "TELEMOST_DIR=%AppData%\Local\Yandex\Telemost"
if exist "%TELEMOST_DIR%\Update.exe" (
    echo   ������ Update.exe � ���������� ��� ��� ��������.
    "%TELEMOST_DIR%\Update.exe" --uninstall --system-level --delete-data
    echo Yandex.Telemost ����� ����� Update.exe.
) else (
    echo Yandex.Telemost �� ������ � ��������, ��� ����� ��� �� ��������������.
)

::============================================
:: �������������� ������� (�������)
::============================================
:TelemostCleanup
echo.
echo ��������� ������� ��������...

:: ������� ����� � ������� (�� �������, ����� ����������������)
rmdir /s /q "%ProgramFiles%\Sber Jazz" 2>nul
rmdir /s /q "%ProgramFiles(x86)%\Sber Jazz" 2>nul
rmdir /s /q "%AppData%\SberJazz" 2>nul
rmdir /s /q "%AppData%\Local\Yandex\Telemost" 2>nul
rmdir /s /q "%ProgramData%\Yandex\Telemost" 2>nul

echo.
echo �������� ���������!
echo ��������� � �� �������� ����� �������.
echo ��� ��������� ����������.
echo ���� ���� ������ � ���������, ��������, ��������� ��� �������.
pause