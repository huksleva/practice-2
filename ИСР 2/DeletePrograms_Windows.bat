@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion
cls

::===================================================
:: �������� �������� ����� winget (��� ������)
::===================================================

echo(
echo( ��������: ���� ������ ����� �������� ��������
echo( ����� ������� ��� ��������� ����������.
echo( ������� Ctrl+C, ����� ��������.
echo(
pause

:: �������� ���� ��������������
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo(
    echo(������: ��������� ����� ��������������.
    pause
    exit /b
)

echo(
echo(�������� �������� ��������...
echo(


:: ��������� ����������� �� ������ �� ��������:
:: Microsoft.VisualStudioCode JetBrains.PyCharm.Community Git.Git GitHub.GitHubDesktop Python.Python.3 MSYS2.MSYS2 7zip.7zip Microsoft.Edge

:: set "programs=MaximaTeam.Maxima Docker.DockerDesktopKNIMEAG.KNIMEAnalyticsPlatform GIMP.GIMP JuliaLang.Julia Rustlang.Rustup Zettlr.Zettlr MiKTeX.MiKTeX Chocolatey.Chocolatey TeXstudio.TeXstudio Anaconda.Anaconda3 FarManager.FarManager SumatraPDF.SumatraPDF Google.Chrome Flameshot.Flameshot Canonical.Ubuntu.2204 Qalculate.Qalculate Quadren.Arc.Prerelease Mozilla.Firefox Yandex.Browser"

for %%p in (%programs%) do (
    echo( �������: %%p
    call :UninstallApp "%%p"
    echo(
)













echo( ��� ��������� ����������.
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
        echo( �� ������� �������: %pkg%
    ) else (
        echo( ������� �������: %pkg%
    )
exit /b