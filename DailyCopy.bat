::AUTHOR: Seven
::MAIL: stoneboy100200@126.com
::BRIEF: Daily copy for nightly build
::CMD EX: schtasks /create /tn "DailyCopy" /tr "D:\NavRepoVS2013\DailyCopy.bat" /sc hourly /mo 6 /st 04:00
@echo off
title DailyCopy@Seven.Li
setlocal enableextensions enabledelayedexpansion
set NIGHTLY_BUILD_SERVER_BAN_PATH=\\10.47.3x.xxx\ecm\CI1\CB\Nissan_IVI
set NIGHTLY_BUILD_SERVER_COB_PATH=\\10.169.4x.xxx\ecm\CI1\RN-AIVI\RN_AIVI_HMI_nightlybuild
set NIGHTLY_BUILD_SERVER_HI_PATH=\\xxxxxx\dfsrb\DfsDE\DIV\CM\AI\SW_Releases\Nissan\0043_RN_AIVI_7513750800\00_SW\IMX6\test_builds\RN_AIVI_HMI_nightlybuild
set CLIENT_PATH=\\xxxx\01_Project\BinaryExchange\A-IVI\A-IVI_PRC\NightlyBuild
set PROJECT_NISSAN=rnaivi
set PROJECT_PIVI=npivi
set PROJECT_RIVI=rivie
set ROBOCOPY_OPTION=/E /ETA /COPY:DAT /MT:64
set SW_NUM=5
set ONE_DAY_AGO=1

rem Get yesterday's date(the format of date should be mm/dd/yyyy)
call :DateToDays %date:~10,4% %date:~4,2% %date:~7,2% YESTERDAY
set /a YESTERDAY-=%ONE_DAY_AGO%
call :DaysToDate %YESTERDAY% DstYear DstMonth DstDay

set NIGHTLY_BUILD_SCOPE_2_1_STABI_PREFIX=AIVI_NIGHTLY_18_1_
set NIGHTLY_BUILD_SCOPE_2_1_FEATURE_PREFIX=AIVI_NIGHTLY_%DstYear%_

:Start
if not exist %CLIENT_PATH% (
  echo=
  echo [Error] "%CLIENT_PATH%" doesn't exist^^!
  echo=
  goto :Error
)

if exist %NIGHTLY_BUILD_SERVER_COB_PATH% (
  set NIGHTLY_BUILD_SERVER_PATH=%NIGHTLY_BUILD_SERVER_COB_PATH%
) else if exist %NIGHTLY_BUILD_SERVER_BAN_PATH% (
  set NIGHTLY_BUILD_SERVER_PATH=%NIGHTLY_BUILD_SERVER_BAN_PATH%
) else if exist %NIGHTLY_BUILD_SERVER_HI_PATH% (
  set NIGHTLY_BUILD_SERVER_PATH=%NIGHTLY_BUILD_SERVER_HI_PATH%
) else (
  echo=
  echo [Error] "%NIGHTLY_BUILD_SERVER_BAN_PATH%" and "%NIGHTLY_BUILD_SERVER_COB_PATH%" and %NIGHTLY_BUILD_SERVER_HI_PATH% didn't exist^^!
  echo=
  goto :Error
)
rem net use \\10.47.3x.xxx "xxxxxxx" /user:xxx

rem Delete the oldest SW if the number of SW greater than 5
call :Delete %NIGHTLY_BUILD_SCOPE_2_1_STABI_PREFIX%
call :Delete %NIGHTLY_BUILD_SCOPE_2_1_FEATURE_PREFIX%

set NIGHTLY_BUILD_STABI_INFO=%NIGHTLY_BUILD_SCOPE_2_1_STABI_PREFIX%%DstYear%_%DstMonth%_%DstDay%
set NIGHTLY_BUILD_FEATURE_INFO=%NIGHTLY_BUILD_SCOPE_2_1_FEATURE_PREFIX%%DstMonth%_%DstDay%
echo NIGHTLY_BUILD_STABI_INFO=!NIGHTLY_BUILD_STABI_INFO!
echo NIGHTLY_BUILD_FEATURE_INFO=!NIGHTLY_BUILD_FEATURE_INFO!
call :CheckVersion !NIGHTLY_BUILD_STABI_INFO! S_VERSION
call :CheckVersion !NIGHTLY_BUILD_FEATURE_INFO! F_VERSION
if not defined S_VERSION (
  if not defined F_VERSION (
    echo=
    echo [Warnning] Both "!NIGHTLY_BUILD_STABI_INFO!_X" and "!NIGHTLY_BUILD_FEATURE_INFO!_X" haven't been generated yet^^!
    echo=
    goto :End
  )
)

rem Copy scope 2.1 stabi SW
if defined S_VERSION (
  set S_VERSION_PATH=!NIGHTLY_BUILD_SERVER_PATH!\!NIGHTLY_BUILD_STABI_INFO!
  call :Copy !S_VERSION_PATH! !PROJECT_NISSAN!
  call :Copy !S_VERSION_PATH! !PROJECT_PIVI!
  call :Copy !S_VERSION_PATH! !PROJECT_RIVI!
) else (
  echo=
  echo [Warnning] "!NIGHTLY_BUILD_STABI_INFO!_X" haven't been generated yet^^!
  echo=
)

rem Copy scope 2.1 feature SW
::if defined F_VERSION (
::  set F_VERSION_PATH=!NIGHTLY_BUILD_SERVER_PATH!\!NIGHTLY_BUILD_FEATURE_INFO!
::  call :Copy !F_VERSION_PATH! !PROJECT_NISSAN!
::) else (
::  echo=
::  echo [Warnning] "!NIGHTLY_BUILD_FEATURE_INFO!_X" haven't been generated yet^^!
::  echo=
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
for /d %%i in ("%1*") do (
  call :CheckPath %%i %2 STICK_PATH
  if defined STICK_PATH (
    robocopy !STICK_PATH! !CLIENT_PATH!\%%~ni\%2 !ROBOCOPY_OPTION!
  )
)
goto :EOF

:CheckPath
if exist "%1\stick\%2" (
  set %3="%1\stick\%2"
) else if exist "%1\%2" (
  set %3="%1\%2"
) else (
  set %3="%1"
)
goto :EOF

:CheckVersion
for /f %%i in ('dir %NIGHTLY_BUILD_SERVER_PATH% /a /b ^|findstr "%1"') do (
  set %2=%%i
)
goto :EOF

:DateToDays %yy% %mm% %dd% days
setlocal ENABLEEXTENSIONS
set yy=%1&set mm=%2&set dd=%3
if 1%yy% LSS 200 if 1%yy% LSS 170 (set yy=20%yy%) else (set yy=19%yy%)
set /a dd=100%dd%%%100,mm=100%mm%%%100
set /a z=14-mm,z/=12,y=yy+4800-z,m=mm+12*z-3,j=153*m+2
set /a j=j/5+dd+y*365+y/4-y/100+y/400-2472633
endlocal&set %4=%j%&goto :EOF

:DaysToDate %days% yy mm dd
setlocal ENABLEEXTENSIONS
set /a a=%1+2472632,b=4*a+3,b/=146097,c=-b*146097,c/=4,c+=a
set /a d=4*c+3,d/=1461,e=-1461*d,e/=4,e+=c,m=5*e+2,m/=153,dd=153*m+2,dd/=5
set /a dd=-dd+e+1,mm=-m/10,mm*=12,mm+=m+3,yy=b*100+d-4800+m/10
(if %mm% LSS 10 set mm=0%mm%)&(if %dd% LSS 10 set dd=0%dd%)
endlocal&set %2=%yy%&set %3=%mm%&set %4=%dd%&goto :EOF

