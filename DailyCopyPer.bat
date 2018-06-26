::AUTHOR: Seven
::MAIL: stoneboy100200@126.com
::BRIEF: Daily copy for personal version
@echo off
title DailyCopyPer@Seven.Li
setlocal enableextensions enabledelayedexpansion
set NIGHTLY_BUILD_SERVER_BAN_PATH=\\10.47.3x.xxx\ecm\CI1\CB\Nissan_IVI
set NIGHTLY_BUILD_SERVER_COB_PATH=\\10.169.4x.xxx\ecm\CI1\RN-AIVI\RN_AIVI_HMI_nightlybuild
set NIGHTLY_BUILD_SERVER_HI_PATH=\\xxxxxx\dfsrb\DfsDE\DIV\CM\AI\SW_Releases\Nissan\0043_RN_AIVI_7513750800\00_SW\IMX6\test_builds\RN_AIVI_HMI_nightlybuild
set OFFICIAL_BUILD_SERVER_PATH=\\10.47.3x.xxx\ecm\CI1\Nissan\0043_RN_AIVI_7513750800\00_SW\IMX6
set YOUR_SERVER_PATH=ENTER_YOUR_PATH
set OFFICIAL_BUILD_STICK_PATH=Release\stick
set ROBOCOPY_OPTION=/E /ETA /COPY:DAT /MT:8
set CLIENT_PATH=E:\stick

:Start
if not exist %CLIENT_PATH% (
  echo=
  echo [Error] %CLIENT_PATH% doesn't exist^^!
  echo=
  goto :Error
)
rem net use \\10.47.3x.xxx\ecm\CI1 "xxx" /user:xxx

:Menu
echo=
echo             ================================
echo                            Menu
echo             ================================
echo=
echo             1.Download Official Software
echo=
echo             2.Download Nightly Build Software
echo=
echo             3.Others
echo=
echo             q.Quit
echo=
echo=
echo=

:Choice
set CHOICE=
set /p CHOICE=Please enter your choice :
if /i "%CHOICE%"=="1" goto :Project
if /i "%CHOICE%"=="2" goto :Project
if /i "%CHOICE%"=="3" goto :Others
if /i "%CHOICE%"=="q" goto :End
echo Incorrect input^^! Please enter again!
echo=
goto :Choice

:Project
echo=
echo             ================================
echo                           Project
echo             ================================
echo=
echo             1.A-IVI Nissan
echo=
echo             2.A-IVI Renault
echo=
echo             3.P-IVI
echo=
echo             b.Back
echo=
echo             q.Quit
echo=
echo=
echo=
set YOUR_PROJECT=
set /p YOUR_PROJECT=Please enter your project :
if /i "%YOUR_PROJECT%"=="1" (
  set PROJECT=rnaivi
  if /i "%CHOICE%"=="1" goto :CopyOfficialSW
  if /i "%CHOICE%"=="2" goto :CopyNightlySW
)
if /i "%YOUR_PROJECT%"=="2" (
  set PROJECT=rivie
  if /i "%CHOICE%"=="1" goto :CopyOfficialSW
  if /i "%CHOICE%"=="2" goto :CopyNightlySW
)
if /i "%YOUR_PROJECT%"=="3" (
  set PROJECT=npivi
  if /i "%CHOICE%"=="1" goto :CopyOfficialSW
  if /i "%CHOICE%"=="2" goto :CopyNightlySW
)
if /i "%YOUR_PROJECT%"=="b" goto :Menu
if /i "%YOUR_PROJECT%"=="q" goto :End
echo Incorrect input^^! Please enter again!
echo=
goto :Project

:CopyOfficialSW
if not exist %OFFICIAL_BUILD_SERVER_PATH% (
  echo=
  echo [Error] %OFFICIAL_BUILD_SERVER_PATH% doesn't exist^^!
  echo=
  goto :Error
)

set YOUR_VERSION=
set /p YOUR_VERSION=Please enter your version(e.g. 170015_170306) :
call :CheckVersion %OFFICIAL_BUILD_SERVER_PATH% %YOUR_VERSION% O_VERSION
if defined O_VERSION (
  call :CheckPath !OFFICIAL_BUILD_SERVER_PATH!\!O_VERSION!\!OFFICIAL_BUILD_STICK_PATH!\!PROJECT! STICK_PATH
  if defined STICK_PATH (
    robocopy !STICK_PATH! !CLIENT_PATH!\!O_VERSION!\!PROJECT! !ROBOCOPY_OPTION!
  ) else (
    goto :Error
  )
) else (
  echo=
  echo [Error] "!YOUR_VERSION!" is an invalid version^^!
  echo=
)
goto :End

:CopyNightlySW
if exist %NIGHTLY_BUILD_SERVER_BAN_PATH% (
  set NIGHTLY_BUILD_SERVER_PATH=%NIGHTLY_BUILD_SERVER_BAN_PATH%
) else if exist %NIGHTLY_BUILD_SERVER_COB_PATH% (
  set NIGHTLY_BUILD_SERVER_PATH=%NIGHTLY_BUILD_SERVER_COB_PATH%
) else if exist %NIGHTLY_BUILD_SERVER_HI_PATH% (
  set NIGHTLY_BUILD_SERVER_PATH=%NIGHTLY_BUILD_SERVER_HI_PATH%
) else (
  echo=
  echo [Error] Both "%NIGHTLY_BUILD_SERVER_BAN_PATH%" and "%NIGHTLY_BUILD_SERVER_COB_PATH%" didn't exist^^!
  echo=
  goto :Error
)

set YOUR_VERSION=
set /p YOUR_VERSION=Please enter your version(e.g. AIVI_NIGHTLY_S2STABI_2017_03_06_1/AIVI_NIGHTLY_2017_03_06_1) :
call :CheckVersion %NIGHTLY_BUILD_SERVER_PATH% %YOUR_VERSION% N_VERSION
if defined N_VERSION (
  call :CheckPath !NIGHTLY_BUILD_SERVER_PATH!\!N_VERSION! STICK_PATH
  if defined STICK_PATH (
    robocopy !STICK_PATH! !CLIENT_PATH!\!N_VERSION!\!PROJECT! !ROBOCOPY_OPTION!
  ) else (
    goto :Error
  )
) else (
  echo=
  echo [Error] "!YOUR_VERSION!" is an invalid version^^!
  echo=
)
goto :End

:Others
if not exist %YOUR_SERVER_PATH% (
  echo=
  echo [Error] %YOUR_SERVER_PATH% doesn't exist^^!
  echo=
  goto :Error
)
robocopy %YOUR_SERVER_PATH% %CLIENT_PATH% !ROBOCOPY_OPTION!
  
:End
pause
goto :EOF

:Error
pause
goto :EOF

:CheckVersion
for /f %%i in ('dir %1 /a /b ^|findstr "%2"') do (
  set %3=%%i
)
goto :EOF

:CheckPath
if "%CHOICE%"=="1" (
  if exist %1 (
    set %2=%1
  ) else (
    echo [Error] The path of "%1" doesn't exist^^!
  )
) else (
  if exist "%1\stick\%PROJECT%" (
    set %2="%1\stick\%PROJECT%"
  ) else if exist "%1\%PROJECT%" (
    set %2="%1\%PROJECT%"
  ) else (
    set %2="%1"
  )
)
goto :EOF
