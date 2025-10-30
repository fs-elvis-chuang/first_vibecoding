@echo off
:: 顯示中文
@chcp 65001 >nul

:: 讀取環境變數--------------------------------------------------------------Begin
setlocal enabledelayedexpansion
set "ENV_FILE=my_env.env"
echo.
echo 讀取環境變數設定檔...

:: 使用 findstr 讀取非註解的行
for /f "tokens=*" %%A in ('findstr /r /c:"^[^#]" "%ENV_FILE%"') do (
    set "LINE=%%A"
    
    :: 檢查該行是否包含雙引號
    echo !LINE! | findstr /c:"""" >nul
    if not errorlevel 1 (
        :: 如果有雙引號，使用等號和雙引號來解析
        for /f "tokens=1,2 delims==" %%B in ("!LINE!") do (
            set "KEY=%%B"
            set "VALUE=%%C"
            
            :: 移除前後的雙引號
            set "VALUE=!VALUE:~1,-1!"
            
            :: 移除 Key 左右的空格
            for /f "tokens=*" %%D in ("!KEY!") do set "KEY=%%D"
            
            set "!KEY!=!VALUE!"
            echo 設定變數：!KEY!=!VALUE!
        )
    ) else (
        :: 如果沒有雙引號，使用一般的解析方法
        for /f "tokens=1* delims==" %%B in ("!LINE!") do (
            set "KEY=%%B"
            set "VALUE=%%C"
            
            :: 移除 Key/Value 左右的空格
            for /f "tokens=*" %%D in ("!KEY!") do set "KEY=%%D"
            for /f "tokens=*" %%E in ("!VALUE!") do set "VALUE=%%E"
            
            set "!KEY!=!VALUE!"
            echo 設定變數：!KEY!=!VALUE!
        )
    )
)

echo.
echo 所有變數已載入。
echo DATABASE_HOST=%DATABASE_HOST%
echo DATABASE_PORT=%DATABASE_PORT%
echo API_KEY=%API_KEY%
echo MY_PYTHON_VIRTURL_ENV_NAME=%MY_PYTHON_VIRTURL_ENV_NAME%
echo.
pause
:: 讀取環境變數----------------------------------------------------------------End

set "SCRIPT_DIR=%~dp0"
echo 批次檔的絕對路徑是：%SCRIPT_DIR%

:: 設定虛擬環境安裝目錄名稱
set "VTENV_DIR=%SCRIPT_DIR%%MY_PYTHON_VIRTURL_ENV_NAME%"
echo 預定虛擬環境安裝路徑：%VTENV_DIR%

:: 檢查虛擬環境是否已經安裝好了
:: 檢查該目錄是否存在
if exist "%VTENV_DIR%\" (
    echo 虛擬環境已經安裝在：💢"%VTENV_DIR%"
) else (
    echo 即將建立虛擬環境：%VTENV_DIR%
	conda env create --file .\environment.yml --prefix .\%MY_PYTHON_VIRTURL_ENV_NAME% -y
	conda activate %VTENV_DIR%
	echo 📒虛擬環境安裝路徑：〔 %VTENV_DIR% 〕
	python --version
	pip --version
	conda --version
)

pause