@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion
cls

::===================================================
:: Удаление программ через winget
::===================================================

echo.
echo ВНИМАНИЕ: Этот скрипт начнёт удаление программ
echo Будут удалены все указанные приложения.
echo Нажмите Ctrl+C, чтобы отменить.
echo.
pause

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo Ошибка: Требуются права администратора.
    pause
    exit /b
)

echo
echo Начинаем удаление программ...
echo


::============================================
:: УДАЛЕНИЕ РАСШИРЕНИЙ ДЛЯ VISUAL STUDIO CODE
::============================================
echo.
echo Удаляем расширения для Visual Studio Code...
echo.


set "EXTENSIONS=ms-python.python ms-python.debugpy ms-python.vscode-python-envs ms-vscode.cpptools ms-vscode.cpptools-extension-pack ms-vscode.cpptools-themes ms-azuretools.vscode-docker sidthesloth.html5-boilerplate ecmel.vscode-html-css george-alisson.html-preview-vscode skyran.js-jsx-snippets donjayamanne.git-extension-pack"

for %%e in (%EXTENSIONS%) do (
    echo Удаляем расширение: %%e
    call code --uninstall-extension "%%e" --force
    echo.
)





::============================================
:: УДАЛЕНИЕ ПРОГРАММ
::============================================

:: Программы исключённые из списка на удаление:
:: Microsoft.VisualStudioCode JetBrains.PyCharm.Community Git.Git GitHub.GitHubDesktop Python.Python.3 MSYS2.MSYS2 7zip.7zip Microsoft.Edge

set "programs=MaximaTeam.Maxima Docker.DockerDesktopKNIMEAG.KNIMEAnalyticsPlatform GIMP.GIMP JuliaLang.Julia Rustlang.Rustup Zettlr.Zettlr MiKTeX.MiKTeX Chocolatey.Chocolatey TeXstudio.TeXstudio Anaconda.Anaconda3 FarManager.FarManager SumatraPDF.SumatraPDF Google.Chrome Flameshot.Flameshot Canonical.Ubuntu.2204 Qalculate.Qalculate Quadren.Arc.Prerelease Mozilla.Firefox Yandex.Browser"

for %%p in (%programs%) do (
    echo Удаляем: %%p
    call :UninstallApp "%%p"
    echo.
)




::========================================================================
:: Принудительное удаление Sber Jazz и Yandex.Telemost
:: Включая программы, процессы, папки и ярлыки
::========================================================================

echo Удаление Sber Jazz и Yandex.Telemost...
echo.

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ? Ошибка: Требуются права администратора.
    echo    Запустите от имени администратора.
    pause
    exit /b 1
)

::--------------------------------------------
:: 1. Завершаем процессы
::--------------------------------------------
echo [1/4] Завершение работающих процессов...

taskkill /f /im jazz.exe >nul 2>&1
taskkill /f /im SberJazz*.exe >nul 2>&1
taskkill /f /im telemost.exe >nul 2>&1
taskkill /f /im TelemostSetup.exe >nul 2>&1

echo     Процессы остановлены.
echo.

::--------------------------------------------
:: 2. Запускаем деинсталляторы (если есть)
::--------------------------------------------
echo [2/4] Запуск деинсталляции...

:: Yandex.Telemost
set "TELEMOST_UNINSTALL=C:\Program Files\Yandex\YandexTelemost\uninstaller.exe"
if exist "%TELEMOST_UNINSTALL%" (
    echo     Запуск удаления Yandex.Telemost...
    call start "" /wait "%TELEMOST_UNINSTALL%" /S
    if %errorlevel% == 0 (
        echo     Yandex.Telemost успешно удалён.
    ) else (
        echo     ?? Ошибка при удалении Yandex.Telemost.
    )
) else (
    echo     ?? Деинсталлятор Yandex.Telemost не найден.
)

:: Sber Jazz
set "JAZZ_DIR=%LOCALAPPDATA%\Programs\jazz"
set "JAZZ_UNINSTALL=%JAZZ_DIR%\Uninstall Sber Jazz.exe"
if exist "%JAZZ_UNINSTALL%" (
    echo     Запуск удаления Sber Jazz...
    call start "" /wait "%JAZZ_UNINSTALL%" /S
    if %errorlevel% == 0 (
        echo     Sber Jazz успешно удалён.
    ) else (
        echo     ?? Ошибка при удалении Sber Jazz.
    )
) else (
    echo     ?? Деинсталлятор Sber Jazz не найден: %JAZZ_UNINSTALL%
)

echo.

::--------------------------------------------
:: 3. Удаляем папки
::--------------------------------------------
echo [3/4] Удаление программных папок...

if exist "C:\Program Files\Yandex\YandexTelemost" (
    rd /s /q "C:\Program Files\Yandex\YandexTelemost" >nul 2>&1
    echo     Удалена папка: C:\Program Files\Yandex\YandexTelemost
)

if exist "%LOCALAPPDATA%\Programs\jazz" (
    rd /s /q "%LOCALAPPDATA%\Programs\jazz" >nul 2>&1
    echo     Удалена папка: %LOCALAPPDATA%\Programs\jazz
)

if exist "%APPDATA%\Yandex\Telemost" (
    rd /s /q "%APPDATA%\Yandex\Telemost" >nul 2>&1
)

if exist "%APPDATA%\SberJazz" (
    rd /s /q "%APPDATA%\SberJazz" >nul 2>&1
)

echo.





::--------------------------------------------
:: 4. Удаляем ярлыки
::--------------------------------------------
echo [4/4] Удаление ярлыков...

:: Перечисляем пути по одному на строку (внутри set)
set ^"SHORTCUTS=^
%DESKTOP%\Sber Jazz.lnk^
%DESKTOP%\Yandex Telemost.lnk^
%APPDATA%\Microsoft\Windows\Start Menu\Программы\Sber Jazz.lnk^
%APPDATA%\Microsoft\Windows\Start Menu\Программы\Yandex Telemost.lnk^
%PROGRAMDATA%\Microsoft\Windows\Start Menu\Программы\Sber Jazz.lnk^
%PROGRAMDATA%\Microsoft\Windows\Start Menu\Программы\Yandex Telemost.lnk^
%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Sber Jazz.lnk^
%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Yandex Telemost.lnk^
"%

:: Обрабатываем каждый путь
for /f "tokens=* delims=" %%s in ("!SHORTCUTS!") do (
    if "%%s" neq "" (
        if exist "%%s" (
            del "%%s" >nul 2>&1
            echo     Удалён ярлык: %%s
        )
    )
)

echo.

echo Удаление завершено!
echo Sber Jazz и Yandex.Telemost полностью удалены из системы.











echo.
echo Удаление завершено.
echo Все программы и временные файлы обработаны.
echo.
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
        echo Не удалось удалить: %pkg%
    ) else (
        echo Успешно удалено: %pkg%
    )
exit /b