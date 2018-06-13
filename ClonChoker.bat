@echo off
setlocal ENABLEDELAYEDEXPANSION
If "%1"=="help" goto help
If "%1"=="-help" goto help
If "%1"=="/?" goto help
IF "%1"=="install" goto install
goto unsuported

:install
Echo: > ClonChockerTextStorage.txt
SHIFT
Set /A num=0
Set KCsource=%1
SET KCprerelease=
SET KCtest=false
SET KCask=false
SET KCfile=
SHIFT

:setloop
if "%1"=="" GOTO main
  IF "%1"=="-username" goto setuser
  if "%1"=="-user" goto setuser
  if "%1"=="--u" goto setuser

  IF "%1"=="-password" goto setpass
  if "%1"=="-pass" goto setpass
  if "%1"=="--p" goto setpass

  if "%1"=="-file" goto setfile
  if "%1"=="--f" goto setfile

  IF "%1"=="-test" goto settest
  if "%1"=="--t" goto settest

  IF "%1"=="-prerelease" goto setprerelease
  if "%1"=="-pre" goto setprerelease

  IF "%1"=="-debug" goto setecho


  REM ELSE

  IF "%2"=="-v" (
     Echo %1 %3 >> ClonChockerTextStorage.txt
     SHIFT
     SHIFT
     goto endsetloop
  )
  Echo %1 >> ClonChockerTextStorage.txt

  :endsetloop
  SHIFT

Goto setloop

:setuser
    SHIFT
    SET KCusername=%1
    GOTO endsetloop
:setfile
    SHIFT
    SET KCfile=%1
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

choco install nuget.commandline -y
SET success=0
if NOT "%KCsource%"=="" (
  if NOT "%KCusername%"=="" (
    if NOT "%KCpassword%"=="" (
      nuget sources add -Name "ClonChokerFeed" -Source "%KCsource%" -username "%KCusername%" -password "%KCpassword%" || echo "Unable to create credentials"
      GOTO postcredentials
    )
    echo You should enter both of username and password
  )
  nuget sources add -Name "ClonChokerFeed" -Source "%KCsource%"
  GOTO postcredentials
)
echo Source required
goto eof
:postcredentials

setlocal
SET /a num=0
If "%KCfile%"=="" SET KCfile=ClonChockerTextStorage.txt
for /f "usebackq tokens=1-4 delims= " %%a in ("%KCfile%") do (
  ECHO installing %%a %%b
  if NOT "%%b"=="" (
      nuget install %%a -version %%b -source ClonChokerFeed %KCprerelease% -OutputDirectory .\ClonChokerStorage || nuget install %%p -source %KCsource% %KCprerelease% -ExcludeVersion -OutputDirectory .\ClonChokerCache || goto error
      choco install %%a --version %%b -source ./ClonChokerStorage/ -pre -y || goto error
  )
  if "%%b"=="" (
      nuget install %%a -source ClonChokerFeed %KCprerelease% -OutputDirectory .\ClonChokerStorage || nuget install %%p -source %KCsource% %KCprerelease% -ExcludeVersion -OutputDirectory .\ClonChokerCache || goto error
      choco install %%a -source ./ClonChokerStorage/ -pre -y || goto error
  )

  del /f /s /q ".\ClonChokerStorage\%%a*" 1>nul
  IF %KCtest%==true (
      if NOT "%%b"=="" choco uninstall %%a --version %%b -y || goto error
      if "%%b"=="" choco uninstall %%a -y || goto error
  )
  SET /a success=!success! +1
  :error
  SET /a num=!num! +1
  echo:
)

rmdir /s /q ".\ClonChokerStorage"
if NOT "%KCsource%"=="" (
  if NOT "%KCusername%"=="" (
    if NOT "%KCpassword%"=="" (
      nuget sources remove -name "ClonChokerFeed" 1>nul
)))
del ClonChockerTextStorage.txt
echo:
echo:
Echo Succes: %success%/%num%

goto eof


:help
echo ClonChoker help:
echo:
echo This batch can download packages from private Klondike (or some other nuget) servers and install them by chocolatey.
echo:
echo:
echo ClonChoker install *source* [-params] [packagenames]
echo ClonChoker install *source* -file *filename* [-params]
echo:
echo -username, -user, --u
echo to set username
echo:
echo -password, -pass, --p
echo to set password
echo:
echo -prerelease, -pre
echo allow downloading prerelease versions
echo:
echo help, -help, /?
echo show this help
echo:
echo -debug, --d
echo sets echo on
echo:
echo -test, --t
echo automatically uninstalls package after installation, without any practical use
goto eof


:unsuported
echo You used wrong command. See ClonChoker -help for help.
goto eof




:eof