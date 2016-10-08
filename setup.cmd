@echo off
::  Just download the base box and do the 'vagrant up' for the user already.
::
::  Author:  Kevin Ernst <ernstki@mail.uc.edu>
::  Date:    2. October 2016

setlocal
set VAGRANT_BOX=https://tf.cchmc.org/external/ern6xv/bioreactor-jessie.box
set BOX_NAME=bioreactor-jessie

cls
echo VM IMAGE PREPARATION
echo --------------------
echo.
echo   This script will download and install the '%BOX_NAME%' Vagrant base box
echo   and run 'vagrant up' for you. 
echo.
::read -p "Press ENTER now to continue or CTRL+C to abort... "
pause
echo.

:: Check to see if the box already exists in the user's Vagrant setup
vagrant box list 2>&1 | findstr %BOX_NAME% >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo Vagrant box '%BOX_NAME%' seems to be present already. Skipping download.
    goto :VagrantUp
)

vagrant box add %BOX_NAME% %VAGRANT_BOX%
if %ERRORLEVEL% neq 0 call :Error "the Vagrant box download"

:VagrantUp
vagrant up
if %ERRORLEVEL% neq 0 call :Error "the Vagrant box installation / provisioning"

echo.
echo Looks like everything was successful, at least as far as this part of
echo the setup goes. If Vagrant bailed out during the provisioning step, you
echo can safely run 'vagrant provision' here to retry.
echo.
echo Othersiwe, you may now use SSH to connect to the running VM on port 9922,
echo or try http://localhost:9980 to access the web server running on the VM.
echo.
goto :EOF

:Error
call :Bail %1 2>nul
:: This doesn't work like you'd expect, since we CALLed :Error and both EXIT
:: and GOTO :EOF have the same end effect of just returning from the CALL.
::exit /b 1

:Bail
echo.
:: Windows batch scripting magic: %~1 means "remove surrounding quotes"
:: source: ss64.com/nt/szntax-args.html
echo Looks like something went wrong with %~1.
echo Really sorry it didn't work out.
echo.
:: This just generates a syntax error to halt the script. It's complicated.
:: See http://stackoverflow.com/10534911 and http://stackoverflow.com/3227796
()

:: vim: ts=4 sw=4 tw=78 colorcolumn=78

