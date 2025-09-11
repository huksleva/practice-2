@echo off
chcp 1251 >nul
cls
setlocal enabledelayedexpansion

::===================================================
:: Скрипт для массового удаления программ через winget
:: Удаляет все программы из списка
:: Требует запуска "От имени администратора"
::===================================================

color 0C
echo.
echo ??  ВНИМАНИЕ: Этот скрипт начнёт удаление программ!
echo    Будут удалены все указанные приложения.
echo    Нажмите Ctrl+C, если хотите отменить.
echo.
pause

:: Проверка прав администратора
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo ? Ошибка: Требуются права администратора.
    pause
    exit /b
)

echo.
echo ?? Ищем установленные программы...
echo.

:: Список ID программ для удаления (те же, что устанавливали)
set "programs=Notepad++.Notepad++ Mozilla.Firefox Git.Git VideoLAN.VLC Google.Chrome"

for %%p in (%programs%) do (
    echo ?? Проверяем и удаляем: %%p
    winget uninstall --id "%%p" --silent --accept-package-agreements --force >nul 2>&1
    if !errorlevel! EQU 0 (
        echo ? Удалено: %%p
    ) else (
        winget list --id "%%p" >nul 2>&1
        if !errorlevel! EQU 0 (
            echo ??  Не удалось удалить: %%p (возможно, требуется перезагрузка или ручное удаление)
        ) else (
            echo ?? Программа не найдена: %%p (ничего удалять не нужно)
        )
    )
    echo.
)







::===================================================
:: Удаление Sber Jazz и Yandex.Telemost
:: Запускать от имени администратора
::===================================================

color 0C
echo.
echo ВНИМАНИЕ: Этот скрипт удалит Sber Jazz и Yandex.Telemost!
echo    Нажмите Ctrl+C и выберите "Нет", чтобы отменить.
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

echo.
echo Начинаем удаление программ...
echo.

::============================================
:: УДАЛЕНИЕ: Sber Jazz
::============================================
echo Удаляем Sber Jazz...

:: Путь к uninstall.exe (стандартное расположение)
set "JAZZ_UNINSTALL=%ProgramFiles%\Sber Jazz\uninstall.exe"
set "JAZZ_UNINSTALL_X86=%ProgramFiles(x86)%\Sber Jazz\uninstall.exe"

if exist "%JAZZ_UNINSTALL%" (
    echo   Найден деинсталлятор. Запуск...
    start /wait "" "%JAZZ_UNINSTALL%" /S
    echo Sber Jazz успешно удалён.
) else if exist "%JAZZ_UNINSTALL_X86%" (
    echo   Найден деинсталлятор (x86). Запуск...
    start /wait "" "%JAZZ_UNINSTALL_X86%" /S
    echo Sber Jazz успешно удалён.
) else (
    echo Sber Jazz не найден — возможно, уже удалён или не устанавливался.
)

::============================================
:: УДАЛЕНИЕ: Yandex.Telemost
::============================================
echo.
echo Удаляем Yandex.Telemost...

:: Ищем в реестре ключ удаления через msiexec или exe
for /f "skip=2 tokens=2,*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Yandex Telemost" /v UninstallString 2^>nul') do (
    set "UNINSTALL_CMD=%%b"
)

if defined UNINSTALL_CMD (
    echo   Найдена команда удаления. Запуск...
    call !UNINSTALL_CMD! /verysilent /allusers
    echo Yandex.Telemost успешно удалён.
    goto TelemostCleanup
)

:: Альтернатива: поиск по стандартному пути
set "TELEMOST_DIR=%AppData%\Local\Yandex\Telemost"
if exist "%TELEMOST_DIR%\Update.exe" (
    echo   Найден Update.exe — используем его для удаления.
    "%TELEMOST_DIR%\Update.exe" --uninstall --system-level --delete-data
    echo Yandex.Telemost удалён через Update.exe.
) else (
    echo Yandex.Telemost не найден — возможно, уже удалён или не устанавливался.
)

::============================================
:: Дополнительная очистка (остатки)
::============================================
:TelemostCleanup
echo.
echo Выполняем очистку остатков...

:: Удаляем папки с данными (по желанию, можно закомментировать)
rmdir /s /q "%ProgramFiles%\Sber Jazz" 2>nul
rmdir /s /q "%ProgramFiles(x86)%\Sber Jazz" 2>nul
rmdir /s /q "%AppData%\SberJazz" 2>nul
rmdir /s /q "%AppData%\Local\Yandex\Telemost" 2>nul
rmdir /s /q "%ProgramData%\Yandex\Telemost" 2>nul

echo.
echo Удаление завершено!
echo Программы и их основные файлы удалены.
echo Все программы обработаны.
echo Если были ошибки — проверьте, возможно, программа уже удалена.
pause