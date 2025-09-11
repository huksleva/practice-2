@echo off
chcp 1251 >nul
setlocal enabledelayedexpansion
cls
::========================================================================
:: Скрипт для автоматической установки/обновления Winget и ПО в Windows
:: Требует запуска "От имени администратора"
::========================================================================


echo Начинаем установку программного обеспечения...
echo.

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Ошибка: Этот скрипт должен быть запущен от имени администратора.
    pause
    exit /b
)

echo Проверка наличия winget...

:: Проверяем, доступен ли winget
where winget >nul 2>&1
if %errorLevel% EQU 0 (
    echo winget уже установлен.
) else (
    echo winget не найден. Выполняем установку...
    call :InstallWinget
    if %errorLevel% NEQ 0 goto ErrorExit
)

echo.
echo Обновляем список пакетов...
winget upgrade

:: Список программ для установки (через их PackageIdentifier)
:: Можно добавить свои из https://winget.run

set "programs=MaximaTeam.Maxima Microsoft.VisualStudioCode Docker.DockerDesktop JetBrains.PyCharm.Community Git.Git GitHub.GitHubDesktop KNIMEAG.KNIMEAnalyticsPlatform GIMP.GIMP JuliaLang.Julia Python.Python.3 Rustlang.Rustup MSYS2.MSYS2 Zettlr.Zettlr MiKTeX.MiKTeX Chocolatey.Chocolatey TeXstudio.TeXstudio Anaconda.Anaconda3 FarManager.FarManager SumatraPDF.SumatraPDF Google.Chrome Flameshot.Flameshot Canonical.Ubuntu.2204 Qalculate.Qalculate Quadren.Arc.Prerelease 7zip.7zip Mozilla.Firefox Yandex.Browser Microsoft.Edge"

echo.
echo Начинаем установку приложений:
echo.

for %%p in (%programs%) do (
    echo Устанавливаем: %%p
    winget install --id "%%p" --silent --accept-package-agreements --accept-source-agreements --force
    if !errorlevel! EQU 0 (
        echo Успешно установлен: %%p
    ) else (
        echo Ошибка при установке: %%p
    )
    echo.
)










echo ?? Начинаем установку Sber Jazz и Yandex.Telemost...
echo.

:: Временная папка
set "TEMP_DIR=%TEMP%\installer_temp"
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

cd /d "%TEMP_DIR%"

::============================================
:: УСТАНОВКА: Sber Jazz
::============================================
echo ?? Устанавливаем Sber Jazz...
echo.

:: Прямая ссылка на установщик Sber Jazz (проверена на 2025)
set "JAZZ_URL=https://downloads.sber.ru/jazz/SberJazzSetup.exe"
set "JAZZ_EXE=%TEMP_DIR%\SberJazzSetup.exe"

echo Скачивание Sber Jazz...
powershell -Command "Invoke-WebRequest -Uri '%JAZZ_URL%' -OutFile '%JAZZ_EXE%' -ErrorAction Stop" || (
    echo ?? Не удалось скачать Sber Jazz. Проверьте подключение.
    goto TelemostInstall
)

echo Запуск установки Sber Jazz...
start /wait "" "%JAZZ_EXE%" /S /allusers
if %errorlevel% EQU 0 (
    echo ? Sber Jazz успешно установлен.
) else (
    echo ?? Установка Sber Jazz завершилась с ошибкой или пропущена.
)

::============================================
:: УСТАНОВКА: Yandex.Telemost
::============================================
:TelemostInstall
echo.
echo ?? Устанавливаем Yandex.Telemost...
echo.

:: Прямая ссылка на установщик Telemost (актуальная)
set "TELEMOST_URL=https://telemost.yandex.ru/download/"
set "TELEMOST_EXE=%TEMP_DIR%\TelemostSetup.exe"

echo Скачивание Yandex.Telemost...
:: Используем PowerShell для получения редиректа (Telemost требует редирект)
for /f "tokens=3" %%a in ('powershell -Command "$r = Invoke-WebRequest '%TELEMOST_URL%' -MaximumRedirection 0 -ErrorAction SilentlyContinue; $r.Headers.Location"') do set "DIRECT_URL=%%a"

if not defined DIRECT_URL (
    echo ?? Не удалось получить ссылку на установщик Telemost.
    echo    Возможно, изменился URL. Перейдите вручную: https://telemost.yandex.ru
    goto Cleanup
)

echo Загружаем установщик с: !DIRECT_URL!
powershell -Command "Invoke-WebRequest -Uri '!DIRECT_URL!' -OutFile '%TELEMOST_EXE%'" || (
    echo ?? Ошибка при скачивании Telemost.
    goto Cleanup
)

echo Запуск установки Yandex.Telemost...
start /wait "" "%TELEMOST_EXE%" /verysilent /allusers
if %errorlevel% EQU 0 (
    echo ? Yandex.Telemost успешно установлен.
) else (
    echo ?? Установка Yandex.Telemost завершилась с ошибкой.
)

::============================================
:: Очистка временных файлов
::============================================
:Cleanup
echo.
echo ?? Очистка временных файлов...
if exist "%TEMP_DIR%" rd /s /q "%TEMP_DIR%" >nul 2>&1

echo.
echo Установка завершена!
echo Программы доступны в меню «Пуск».
echo Все приложения обработаны!
pause
exit /b









::--------------------------------------------------------
:: Подпрограмма: Установка Winget
::--------------------------------------------------------
:InstallWinget
    echo Скачивание Microsoft.DesktopAppInstaller...

    :: Временный путь
    set "TEMP_FILE=%TEMP%\DesktopAppInstaller.msixbundle"
    set "LOGO_URL=https://api.github.com/repos/microsoft/winget-cli/releases/latest"
    set "DOWNLOAD_URL="

    :: Используем PowerShell для получения последней ссылки на msixbundle
    for /f "tokens=*" %%i in ('powershell -Command "Invoke-RestMethod '%LOGO_URL%' | Select-Object -ExpandProperty assets | Where-Object { $_.name -like '*.msixbundle*' } | Select-Object -ExpandProperty browser_download_url"') do (
        set "DOWNLOAD_URL=%%i"
    )

    if "!DOWNLOAD_URL!"=="" (
        echo Не удалось получить ссылку для скачивания DesktopAppInstaller.
        exit /b 1
    )

    :: Скачиваем файл
    powershell -Command "Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -OutFile '!TEMP_FILE!'"
    if %errorLevel% NEQ 0 (
        echo Ошибка при скачивании файла.
        exit /b 1
    )

    echo Установка пакета AppInstaller...
    powershell -Command "Add-AppxPackage -Path '!TEMP_FILE!'"
    if %errorLevel% NEQ 0 (
        echo Ошибка при установке пакета.
        del "!TEMP_FILE!" >nul 2>&1
        exit /b 1
    )

    del "!TEMP_FILE!" >nul 2>&1
    echo winget успешно установлен!
exit /b 0

::--------------------------------------------------------
:: Обработка ошибки
::--------------------------------------------------------
:ErrorExit
    echo.
    echo Произошла ошибка при установке winget.
    echo Убедитесь, что есть подключение к интернету.
    pause
exit /b 1