@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion
cls

::===================================================
:: Удаление программ через winget (без ошибок)
::===================================================

echo(
echo( ВНИМАНИЕ: Этот скрипт начнёт удаление программ
echo( Будут удалены все указанные приложения.
echo( Нажмите Ctrl+C, чтобы отменить.
echo(
pause

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo(
    echo(Ошибка: Требуются права администратора.
    pause
    exit /b
)

echo(
echo(Начинаем удаление программ...
echo(


:: Программы исключённые из списка на удаление:
:: Microsoft.VisualStudioCode JetBrains.PyCharm.Community Git.Git GitHub.GitHubDesktop Python.Python.3 MSYS2.MSYS2 7zip.7zip Microsoft.Edge

:: set "programs=MaximaTeam.Maxima Docker.DockerDesktopKNIMEAG.KNIMEAnalyticsPlatform GIMP.GIMP JuliaLang.Julia Rustlang.Rustup Zettlr.Zettlr MiKTeX.MiKTeX Chocolatey.Chocolatey TeXstudio.TeXstudio Anaconda.Anaconda3 FarManager.FarManager SumatraPDF.SumatraPDF Google.Chrome Flameshot.Flameshot Canonical.Ubuntu.2204 Qalculate.Qalculate Quadren.Arc.Prerelease Mozilla.Firefox Yandex.Browser"

for %%p in (%programs%) do (
    echo( Удаляем: %%p
    call :UninstallApp "%%p"
    echo(
)













echo( Все программы обработаны.
pause
exit /b


:: Если нужно убрать весь вывод в консоль: winget uninstall --id "%pkg%" --silent --force >nul 2>&1
::--------------------------------------------------------
:UninstallApp
    set "pkg=%~1"
    winget uninstall --id "%pkg%" --silent --force --accept-source-agreements
    timeout /t 2 /nobreak >nul

    winget list --id "%pkg%" >nul 2>&1
    if %errorlevel% EQU 0 (
        echo( Не удалось удалить: %pkg%
    ) else (
        echo( Успешно удалено: %pkg%
    )
exit /b