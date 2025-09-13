@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion
cls

::===================================================
:: �������� �������� ����� winget
::===================================================

echo.
echo ��������: ���� ������ ����� �������� ��������
echo ����� ������� ��� ��������� ����������.
echo ������� Ctrl+C, ����� ��������.
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

echo
echo �������� �������� ��������...
echo


::============================================
:: �������� ���������� ��� VISUAL STUDIO CODE
::============================================
echo.
echo ������� ���������� ��� Visual Studio Code...
echo.


set "EXTENSIONS=ms-python.python ms-python.debugpy ms-python.vscode-python-envs ms-vscode.cpptools ms-vscode.cpptools-extension-pack ms-vscode.cpptools-themes ms-azuretools.vscode-docker sidthesloth.html5-boilerplate ecmel.vscode-html-css george-alisson.html-preview-vscode skyran.js-jsx-snippets donjayamanne.git-extension-pack"

for %%e in (%EXTENSIONS%) do (
    echo ������� ����������: %%e
    call code --uninstall-extension "%%e" --force
    echo.
)





::============================================
:: �������� ��������
::============================================

:: ��������� ����������� �� ������ �� ��������:
:: Microsoft.VisualStudioCode JetBrains.PyCharm.Community Git.Git GitHub.GitHubDesktop Python.Python.3 MSYS2.MSYS2 7zip.7zip Microsoft.Edge

set "programs=MaximaTeam.Maxima Docker.DockerDesktopKNIMEAG.KNIMEAnalyticsPlatform GIMP.GIMP JuliaLang.Julia Rustlang.Rustup Zettlr.Zettlr MiKTeX.MiKTeX Chocolatey.Chocolatey TeXstudio.TeXstudio Anaconda.Anaconda3 FarManager.FarManager SumatraPDF.SumatraPDF Google.Chrome Flameshot.Flameshot Canonical.Ubuntu.2204 Qalculate.Qalculate Quadren.Arc.Prerelease Mozilla.Firefox Yandex.Browser"

for %%p in (%programs%) do (
    echo �������: %%p
    call :UninstallApp "%%p"
    echo.
)




::========================================================================
:: �������������� �������� Sber Jazz � Yandex.Telemost
:: ������� ���������, ��������, ����� � ������
::========================================================================

echo �������� Sber Jazz � Yandex.Telemost...
echo.

:: �������� ���� ��������������
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ? ������: ��������� ����� ��������������.
    echo    ��������� �� ����� ��������������.
    pause
    exit /b 1
)

::--------------------------------------------
:: 1. ��������� ��������
::--------------------------------------------
echo [1/4] ���������� ���������� ���������...

taskkill /f /im jazz.exe >nul 2>&1
taskkill /f /im SberJazz*.exe >nul 2>&1
taskkill /f /im telemost.exe >nul 2>&1
taskkill /f /im TelemostSetup.exe >nul 2>&1

echo     �������� �����������.
echo.

::--------------------------------------------
:: 2. ��������� �������������� (���� ����)
::--------------------------------------------
echo [2/4] ������ �������������...

:: Yandex.Telemost
set "TELEMOST_UNINSTALL=C:\Program Files\Yandex\YandexTelemost\uninstaller.exe"
if exist "%TELEMOST_UNINSTALL%" (
    echo     ������ �������� Yandex.Telemost...
    call start "" /wait "%TELEMOST_UNINSTALL%" /S
    if %errorlevel% == 0 (
        echo     Yandex.Telemost ������� �����.
    ) else (
        echo     ?? ������ ��� �������� Yandex.Telemost.
    )
) else (
    echo     ?? ������������� Yandex.Telemost �� ������.
)

:: Sber Jazz
set "JAZZ_DIR=%LOCALAPPDATA%\Programs\jazz"
set "JAZZ_UNINSTALL=%JAZZ_DIR%\Uninstall Sber Jazz.exe"
if exist "%JAZZ_UNINSTALL%" (
    echo     ������ �������� Sber Jazz...
    call start "" /wait "%JAZZ_UNINSTALL%" /S
    if %errorlevel% == 0 (
        echo     Sber Jazz ������� �����.
    ) else (
        echo     ?? ������ ��� �������� Sber Jazz.
    )
) else (
    echo     ?? ������������� Sber Jazz �� ������: %JAZZ_UNINSTALL%
)

echo.

::--------------------------------------------
:: 3. ������� �����
::--------------------------------------------
echo [3/4] �������� ����������� �����...

if exist "C:\Program Files\Yandex\YandexTelemost" (
    rd /s /q "C:\Program Files\Yandex\YandexTelemost" >nul 2>&1
    echo     ������� �����: C:\Program Files\Yandex\YandexTelemost
)

if exist "%LOCALAPPDATA%\Programs\jazz" (
    rd /s /q "%LOCALAPPDATA%\Programs\jazz" >nul 2>&1
    echo     ������� �����: %LOCALAPPDATA%\Programs\jazz
)

if exist "%APPDATA%\Yandex\Telemost" (
    rd /s /q "%APPDATA%\Yandex\Telemost" >nul 2>&1
)

if exist "%APPDATA%\SberJazz" (
    rd /s /q "%APPDATA%\SberJazz" >nul 2>&1
)

echo.





::--------------------------------------------
:: 4. ������� ������
::--------------------------------------------
echo [4/4] �������� �������...

:: ����������� ���� �� ������ �� ������ (������ set)
set ^"SHORTCUTS=^
%DESKTOP%\Sber Jazz.lnk^
%DESKTOP%\Yandex Telemost.lnk^
%APPDATA%\Microsoft\Windows\Start Menu\���������\Sber Jazz.lnk^
%APPDATA%\Microsoft\Windows\Start Menu\���������\Yandex Telemost.lnk^
%PROGRAMDATA%\Microsoft\Windows\Start Menu\���������\Sber Jazz.lnk^
%PROGRAMDATA%\Microsoft\Windows\Start Menu\���������\Yandex Telemost.lnk^
%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Sber Jazz.lnk^
%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Yandex Telemost.lnk^
"%

:: ������������ ������ ����
for /f "tokens=* delims=" %%s in ("!SHORTCUTS!") do (
    if "%%s" neq "" (
        if exist "%%s" (
            del "%%s" >nul 2>&1
            echo     ����� �����: %%s
        )
    )
)

echo.

echo �������� ���������!
echo Sber Jazz � Yandex.Telemost ��������� ������� �� �������.











echo.
echo �������� ���������.
echo ��� ��������� � ��������� ����� ����������.
echo.
pause
exit /b




:: ���� ����� ������ ���� ����� � �������: winget uninstall --id "%pkg%" --silent --force >nul 2>&1
::--------------------------------------------------------
:UninstallApp
    set "pkg=%~1"
    winget uninstall --id "%pkg%" --silent --force --accept-source-agreements
    timeout /t 2 /nobreak >nul

    winget list --id "%pkg%" >nul 2>&1
    if %errorlevel% EQU 0 (
        echo �� ������� �������: %pkg%
    ) else (
        echo ������� �������: %pkg%
    )
exit /b