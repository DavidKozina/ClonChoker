@echo off
If "%1"=="help" goto help
If "%1"=="-help" goto help
If "%1"=="/?" goto help
IF "%1"=="install" goto install
goto unsuported


:install
SHIFT
Set /A num=0
Set KCsource=%1
SET KCprerelease=
SET KCtest=false
SET KCask=false
SHIFT

:setloop
if "%1"=="" GOTO main
  IF "%1"=="-username" goto setuser
  if "%1"=="-user" goto setuser
  if "%1"=="--u" goto setuser

  IF "%1"=="-password" goto setpass
  if "%1"=="-pass" goto setpass
  if "%1"=="--p" goto setpass

  IF "%1"=="-test" goto settest
  if "%1"=="--t" goto settest

  IF "%1"=="-prerelease" goto setprerelease
  if "%1"=="-pre" goto setprerelease

  IF "%1"=="-debug" goto setecho


  REM ELSE

  SET KCpackages[%num%]=%1
  IF "%2"=="-v" (
     SET KCpackages[%num%]=%1 -version %3
     SHIFT
     SHIFT
  )
  SET /A num=%num%+1

  :endsetloop
  SHIFT

Goto setloop

:setuser
    SHIFT
    SET KCusername=%1
    GOTO endsetloop
:setpass
    SHIFT
    SET KCpassword=%1
    GOTO endsetloop
:settest
    SET KCtest=true
    GOTO endsetloop
:setprerelease
    SET KCprerelease=-Prerelease
    GOTO endsetloop
:setecho
    @ECHO ON
    GOTO endsetloop





:main

SET success=0
if NOT "%KCsource%"=="" (
  if NOT "%KCusername%"=="" (
    if NOT "%KCpassword%"=="" (
      nuget sources add -Name "Feed" -Source "%KCsource%" -username "%KCusername%" -password "%KCpassword%" || echo "Unable to create credentials"
      GOTO postcredentials
    )
    echo You should enter both of username and password
  )
  nuget sources add -Name "Feed" -Source "%KCsource%"
  GOTO postcredentials
)
echo Source required
goto eof
:postcredentials
set i=0
:mainloop
setlocal
if %i%==%num% goto :Continue
for /f "usebackq delims== tokens=2" %%p in (`set KCpackages[%i%]`) do (
  nuget install %%p -source Feed %KCprerelease% -OutputDirectory .\ClonChokerCache || nuget install %%p -source %KCsource% %KCprerelease% -ExcludeVersion -OutputDirectory .\ClonChokerCache || goto error
  choco install %%p -source ./ClonChokerCache/ -pre -y || goto error
  choco install %%p -source ./ClonChokerCache/ -pre -y || goto error
  del /f /s /q ".\ClonChokerCache\%%p" 1>nul
  rmdir /s /q ".\ClonChokerCache\%%p"
  IF %KCtest%==true (
    choco uninstall %%p -y || goto error
  )
)
Set /a success=%success%+1
:error
set /a i=%i%+1
goto mainloop


:Continue
rmdir /s /q ".\ClonChokerCache"
if NOT "%KCsource%"=="" (
  if NOT "%KCusername%"=="" (
    if NOT "%KCpassword%"=="" (
      nuget sources remove -name "Feed" 1>nul
)))
echo:
echo:
Echo Succes: %success%/%num%

goto eof


:help
echo ClonChoker help:
echo:
echo This batch can download packages from private Klondike server and install them by chocolatey.
echo:
echo:
echo ClonChoker install *source* [-params] [packagenames]
echo:
echo -username, -user, --u
echo set username
echo:
echo -password, -pass, --p
echo set password
echo:
echo -prerelease, -pre
echo allow downloading prerelease versions
echo:
echo help, -help, /?
echo show this help
echo:
echo -debug, --d
echo set echo on
echo:
echo -test, --t
echo automatically uninstall package after installation
goto eof


:unsuported
echo You used wrong command. See ClonChoker -help for help.
goto eof




:eof