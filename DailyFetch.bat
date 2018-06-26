::AUTHOR: Seven
::MAIL: stoneboy100200@126.com
::Env: WinSim
::BRIEF: Fetch src code from remote everyday
@echo off
title DailyFetch@Seven
set START_TIME=%time%
set NINCG3_STABI_PATH=D:\NavRepoVS2013\nincg3
set NINCG3_FEATURE_PATH=E:\Repositories\nincg3
set NAVI_DEVELOPMENT_PATH=D:\NavRepoVS2013\navi_development

if not exist %NINCG3_STABI_PATH% (
  echo=
  echo [Error] "%NINCG3_STABI_PATH%" doesn't exist^^!
  echo=
  goto :Error
)
if not exist %NAVI_DEVELOPMENT_PATH% (
  echo=
  echo [Error] "%NAVI_DEVELOPMENT_PATH%" doesn't exist^^!
  echo=
  goto :Error
)
if not exist %NINCG3_FEATURE_PATH% (
  echo=
  echo [Error] "%NINCG3_FEATURE_PATH%" doesn't exist^^!
  echo=
  goto :Error
)

rem fetch scope 2.0 stabi branch for nincg3
cd /d %NINCG3_STABI_PATH%
echo=
echo *************%NINCG3_STABI_PATH%*************
echo=
git fetch origin rn_aivi_16.3_stabi
if errorlevel 1 (
  echo=
  echo [Error][nincg3][stabi] git fetch origin rn_aivi_16.3_stabi failed :^(
  echo=
) else (
  echo=
  echo [OK][nincg3][stabi] git fetch origin rn_aivi_16.3_stabi successful :^)
  echo=
)

rem fetch scope 2.1 feature branch for nincg3
cd /d %NINCG3_FEATURE_PATH%
echo=
echo *************%NINCG3_FEATURE_PATH%*************
echo=
git fetch origin nissan_ncg3_int
if errorlevel 1 (
  echo=
  echo [Error][nincg3][feature] git fetch origin nissan_ncg3_int failed :^(
  echo=
) else (
  echo=
  echo [OK][nincg3][feature] git fetch origin nissan_ncg3_int successful :^)
  echo=
)

rem fetch scope 2.1 stabi branch for nincg3
cd /d %NINCG3_FEATURE_PATH%
echo=
echo *************%NINCG3_FEATURE_PATH%*************
echo=
git fetch origin nissan_ncg3_18_1_int
if errorlevel 1 (
  echo=
  echo [Error][nincg3][feature] git fetch origin nissan_ncg3_18_1_int failed :^(
  echo=
) else (
  echo=
  echo [OK][nincg3][feature] git fetch origin nissan_ncg3_18_1_int successful :^)
  echo=
)

rem fetch navi_developement
cd /d %NAVI_DEVELOPMENT_PATH%
echo=
echo *************%NAVI_DEVELOPMENT_PATH%*************
echo=
git fetch origin
if errorlevel 1 (
  echo=
  echo [Error][navi_development] git fetch origin failed :^(
  echo=
) else (
  echo=
  echo [OK][navi_development] git fetch origin successful :^)
  echo=
)

call :time0 "%START_TIME%" "%time%" "RunTime"
echo=
echo=
echo Total time: %RunTime%
echo=
goto :EOF

:time0
@echo off&setlocal&set /a n=0
for /f "tokens=1-8 delims=.: " %%a in ("%~1:%~2") do (
set /a n+=10%%a%%100*360000+10%%b%%100*6000+10%%c%%100*100+10%%d%%100
set /a n-=10%%e%%100*360000+10%%f%%100*6000+10%%g%%100*100+10%%h%%100)
set /a s=n/360000,n=n%%360000,f=n/6000,n=n%%6000,m=n/100,n=n%%100
set "ok=%s% hour %f% min %m% sec"
endlocal&set %~3=%ok:-=%&goto :EOF
