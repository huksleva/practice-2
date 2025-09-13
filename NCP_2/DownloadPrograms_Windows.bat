@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion
cls
::========================================================================
:: ������ ��� �������������� ���������/���������� Winget � �� � Windows
:: ������� ������� "�� ����� ��������������"
::========================================================================


echo �������� ��������� ������������ �����������...
echo.

:: �������� ���� ��������������
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo ? ������: ��������� ����� ��������������.
    pause
    exit /b
)
echo �������� ������� winget...

:: ���������, �������� �� winget
where winget >nul 2>&1
if %errorLevel% EQU 0 (
    echo winget ��� ����������.
) else (
    echo winget �� ������. ��������� ���������...
    call :InstallWinget
    if %errorLevel% NEQ 0 goto ErrorExit
)

echo.
echo ��������� ������ �������...
winget upgrade
winget source update

:: ������ �������� ��� ��������� (����� �� PackageIdentifier)
:: ����� �������� ���� �� https://winget.run

set "programs=MaximaTeam.Maxima Microsoft.VisualStudioCode Docker.DockerDesktop JetBrains.PyCharm.Community Git.Git GitHub.GitHubDesktop KNIMEAG.KNIMEAnalyticsPlatform GIMP.GIMP JuliaLang.Julia Python.Python.3 Rustlang.Rustup MSYS2.MSYS2 Zettlr.Zettlr MiKTeX.MiKTeX Chocolatey.Chocolatey TeXstudio.TeXstudio Anaconda.Anaconda3 FarManager.FarManager SumatraPDF.SumatraPDF Google.Chrome Flameshot.Flameshot Canonical.Ubuntu.2204 Qalculate.Qalculate Quadren.Arc.Prerelease 7zip.7zip Mozilla.Firefox Yandex.Browser Microsoft.Edge"

echo.
echo �������� ��������� ����������:
echo.

for %%p in (%programs%) do (
    echo �������������: %%p
    winget install --id "%%p" --silent --accept-package-agreements --accept-source-agreements --force
    if !errorlevel! EQU 0 (
        echo ������� ����������: %%p
    ) else (
        echo ������ ��� ���������: %%p
    )
    echo.
)





::============================================
:: ��������� ���������� ��� VISUAL STUDIO CODE
::============================================
echo.
echo ������������� ���������� ��� Visual Studio Code...
echo.

set "VSCODE_BIN=%LOCALAPPDATA%\Programs\Microsoft VS Code\bin"
set "PATH=%PATH%;%VSCODE_BIN%"

where code >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ?? ������: ������� 'code' �� �������.
    goto JazzInstall
)

set "EXTENSIONS=ms-python.python ms-python.debugpy ms-python.vscode-python-envs ms-vscode.cpptools ms-vscode.cpptools-extension-pack ms-vscode.cpptools-themes ms-azuretools.vscode-docker sidthesloth.html5-boilerplate ecmel.vscode-html-css george-alisson.html-preview-vscode skyran.js-jsx-snippets donjayamanne.git-extension-pack"

for %%e in (%EXTENSIONS%) do (
    echo ������������� ����������: %%e
    call code --install-extension "%%e" --force
    echo.
)






echo �������� ��������� Sber Jazz � Yandex.Telemost...
echo.

:: ��������� �����
set "TEMP_DIR=%TEMP%\installer_temp"
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

cd /d "%TEMP_DIR%"


::============================================
:: ���������: Sber Jazz
::============================================
:JazzInstall
echo ?? ������������� Sber Jazz...
echo.

:: ������ ������ �� ���������� Sber Jazz (��������� �� 2025)
set "JAZZ_URL=https://dl.salutejazz.ru/desktop/latest/jazz.exe"
set "JAZZ_EXE=%TEMP_DIR%\SberJazzSetup.exe"

echo ���������� Sber Jazz...
powershell -Command "Invoke-WebRequest -Uri '%JAZZ_URL%' -OutFile '%JAZZ_EXE%' -ErrorAction Stop" || (
    echo ?? �� ������� ������� Sber Jazz. ��������� �����������.
    goto TelemostInstall
)

echo ������ ��������� Sber Jazz...
start /wait "" "%JAZZ_EXE%" /S /allusers
if %errorlevel% EQU 0 (
    echo ? Sber Jazz ������� ����������.
) else (
    echo ?? ��������� Sber Jazz ����������� � ������� ��� ���������.
)







::============================================
:: ���������: Yandex.Telemost
::============================================
:TelemostInstall
echo.
echo ?? ������������� Yandex.Telemost...
echo.

set "TELEMOST_URL=https://github.com/huksleva/practice-2/raw/refs/heads/main/NCP_2/TelemostSetup.exe"
set "TELEMOST_EXE=%TEMP_DIR%\TelemostSetup.exe"

:: ������� ������ ������� � URL
set "TELEMOST_URL=%TELEMOST_URL: =%"

echo ���������� Yandex.Telemost...
powershell -Command "Invoke-WebRequest -Uri '%TELEMOST_URL%' -OutFile '%TELEMOST_EXE%'" || (
    echo ?? ������ ��� ���������� Yandex.Telemost.
    echo    ��������� �������� ��� URL �����.
    goto Cleanup
)

echo ������ ��������� Yandex.Telemost...

:: ������ ���������
start /wait "" "%TELEMOST_EXE%" /verysilent /allusers


if %errorlevel% EQU 0 (
    echo ? Yandex.Telemost ������� ����������.
) else (
    echo ?? ��������� Yandex.Telemost ����������� � �������.
)

echo.
echo ��������� ���������!
echo ��������� �������� � ���� �����.
echo ��� ���������� ����������!
pause
exit /b









::--------------------------------------------------------
:: ������������: ��������� Winget
::--------------------------------------------------------
:InstallWinget
    echo ���������� Microsoft.DesktopAppInstaller...

    :: ��������� ����
    set "TEMP_FILE=%TEMP%\DesktopAppInstaller.msixbundle"
    set "LOGO_URL=https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    set "DOWNLOAD_URL="

    :: ���������� PowerShell ��� ��������� ��������� ������ �� msixbundle
    for /f "tokens=*" %%i in ('powershell -Command "Invoke-RestMethod '%LOGO_URL%' | Select-Object -ExpandProperty assets | Where-Object { $_.name -like '*.msixbundle*' } | Select-Object -ExpandProperty browser_download_url"') do (
        set "DOWNLOAD_URL=%%i"
    )

    if "!DOWNLOAD_URL!"=="" (
        echo �� ������� �������� ������ ��� ���������� DesktopAppInstaller.
        exit /b 1
    )

    :: ��������� ����
    powershell -Command "Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -OutFile '!TEMP_FILE!'"
    if %errorLevel% NEQ 0 (
        echo ������ ��� ���������� �����.
        exit /b 1
    )

    echo ��������� ������ AppInstaller...
    powershell -Command "Add-AppxPackage -Path '!TEMP_FILE!'"
    if %errorLevel% NEQ 0 (
        echo ������ ��� ��������� ������.
        del "!TEMP_FILE!" >nul 2>&1
        exit /b 1
    )

    del "!TEMP_FILE!" >nul 2>&1
    echo winget ������� ����������!
exit /b 0

::--------------------------------------------------------
:: ��������� ������
::--------------------------------------------------------
:ErrorExit
    echo.
    echo ��������� ������ ��� ��������� winget.
    echo ���������, ��� ���� ����������� � ���������.
    pause
exit /b 1