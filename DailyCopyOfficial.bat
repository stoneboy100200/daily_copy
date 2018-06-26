::AUTHOR: Seven
::MAIL: stoneboy100200@126.com
::BRIEF: Daily copy for official release
::CMD EX: schtasks /create /tn "DailyCopyOfficial" /tr "D:\NavRepoVS2013\DailyCopyOfficial.bat" /sc hourly /mo 8 /st 06:30
@echo off
title DailyCopyOfficial@Seven.Li
setlocal enableextensions enabledelayedexpansion
set NIGHTLY_BUILD_SERVER_BAN_PATH=\\10.47.3x.xxx\ecm\CI1\Nissan\0044_RN_AIVI_7513750800\00_SW\IMX6
set NIGHTLY_BUILD_SERVER_COB_PATH=\\10.169.4x.xxx\ecm\CI1\NISSAN\03_RN-A_IVI\01_Binary
set NIGHTLY_BUILD_SERVER_HI_PATH=\\xxxxxx\dfsrb\DfsDE\DIV\CM\AI\SW_Releases\Nissan\0044_RN_AIVI_7513750800\00_SW\IMX6
set CLIENT_PATH=\\xxxxxx\01_Project\BinaryExchange\A-IVI\A-IVI_PRC\Official_release_SW
set PROJECT_NISSAN=rnaivi
set PROJECT_PIVI=npivi
set FOLDER_1=stick
set FOLDER_2=ai_sw_update
set ROBOCOPY_OPTION=/E /ETA /COPY:DAT /MT:64 /MIR
set SW_NUM=5
set SCOPE_2_0_STABI_LABEL_PREFIX=1603
set SCOPE_2_1_FEATURE_LABEL_PREFIX=1700
set SCOPE_2_1_STABI_LABEL_PREFIX=1801
set USE_INDIA_SERVER=YES

:Start
if not exist %CLIENT_PATH% (
  echo=
  echo [Error] "%CLIENT_PATH%" doesn't exist^^!
  echo=
  goto :Error
)

if exist %NIGHTLY_BUILD_SERVER_COB_PATH% (
  set SERVER_PATH=%NIGHTLY_BUILD_SERVER_COB_PATH%
) else if exist %NIGHTLY_BUILD_SERVER_BAN_PATH% (
  set SERVER_PATH=%NIGHTLY_BUILD_SERVER_BAN_PATH%
) else if exist %NIGHTLY_BUILD_SERVER_HI_PATH% (
  set SERVER_PATH=%NIGHTLY_BUILD_SERVER_HI_PATH%
) else (
  echo=
  echo [Error] "%NIGHTLY_BUILD_SERVER_BAN_PATH%" and "%NIGHTLY_BUILD_SERVER_COB_PATH%" and %NIGHTLY_BUILD_SERVER_HI_PATH% didn't exist^^!
  echo=
  goto :Error
)
rem net use \\10.47.3x.xxx "xxxxxx" /user:xxx

rem Delete the oldest SW if the number of SW greater than 5
call :Delete %SCOPE_2_1_STABI_LABEL_PREFIX%
call :Delete %SCOPE_2_1_FEATURE_LABEL_PREFIX%

:Main
rem Copy scope 2.1 stabi rnaivi SW
for /f %%i in ('dir %SERVER_PATH% /o:n /b ^|findstr "%SCOPE_2_1_STABI_LABEL_PREFIX%"') do (
  set VERSION_TMP=%%i
  if /i "!VERSION_TMP:~0,4!" equ "%SCOPE_2_1_STABI_LABEL_PREFIX%" (
    set VERSION=%%i
  )
)

if defined VERSION (
  call :Copy !VERSION!
) else (
  echo [Warnning] No official release for branch %SCOPE_2_1_STABI_LABEL_PREFIX%!
)

rem Copy scope 2.1 feature rnaivi SW
::for /f %%i in ('dir %SERVER_PATH% /o:n /b ^|findstr "%SCOPE_2_1_FEATURE_LABEL_PREFIX%"') do (
::  set VERSION=%%i
::)
::if defined VERSION (
::  call :Copy !VERSION!
::) else (
::  echo [Warnning] No official release for branch 1700!
::)

:End
goto :EOF

:Error
goto :EOF

:Delete
set NUM=0
for /f %%i in ('dir %CLIENT_PATH% /o:-n /b ^|findstr "%1"') do (
  set OLD_V=%%i
  set /a NUM+=1
)
if %NUM% geq %SW_NUM% (
  echo=
  echo [Warnning] Deleting %OLD_V%...
  echo=
  rd /s /q %CLIENT_PATH%\%OLD_V%
)
goto :EOF

:Copy
set O_VERSION_PATH=!SERVER_PATH!\%1
echo O_VERSION_PATH=!O_VERSION_PATH!
for /f "delims=" %%b in ('dir /ad /s /b "!O_VERSION_PATH!\%PROJECT_NISSAN%"') do (
  set COPY_PATH=%%b

  if exist %O_VERSION_PATH%\%PROJECT_NISSAN% (
    robocopy %O_VERSION_PATH%\%PROJECT_NISSAN% !CLIENT_PATH!\%1\%PROJECT_NISSAN% !ROBOCOPY_OPTION!
	goto :EOF
  ) else if /i "!COPY_PATH:~-13!" equ "\%FOLDER_1%\%PROJECT_NISSAN%" (
    robocopy !COPY_PATH! !CLIENT_PATH!\%1\%PROJECT_NISSAN% !ROBOCOPY_OPTION!
	goto :EOF
  ) else if /i "!COPY_PATH:~-25,12!" equ "%FOLDER_2%" (
    robocopy !COPY_PATH! !CLIENT_PATH!\%1\%PROJECT_NISSAN% !ROBOCOPY_OPTION!
	goto :EOF
  )
)
goto :EOF
