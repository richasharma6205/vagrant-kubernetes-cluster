@echo off

:main

rem Check for the first argument
if "%1%" EQU "create" (
  ssh-keygen -t rsa -b 4096 -N "" -f ./id_rsa
  vagrant up
  goto :eof
) else if "%1%" EQU "start" (
  vagrant up
  goto :eof
)else if "%1%" EQU "resume" (
  vagrant resume
  goto :eof
) else if "%1%" EQU "sleep" (
  vagrant suspend
  goto :eof
) else if "%1%" EQU "shutdown" (
  vagrant halt
  goto :eof
) else if "%1%" EQU "destroy" (
  vagrant destroy -f
  goto :eof
) else (
  echo Usage:
  echo.
  echo  create   : When running project for the first time
  echo  start    : To create vagrant VMs from scratch or boot up VMs from shutdown state
  echo  resume   : Wake up all VMs from sleep state
  echo  sleep    : Pause all running VMs
  echo  shutdown : Shuts down all running VMs
  echo  destroy  : Destroy all running VMs
  echo. 
  goto :eof
)

:eof

endlocal
