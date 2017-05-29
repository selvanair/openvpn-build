@echo off
set USER="sball"
set DOMAIN="global.local"
@echo off
REM Map drives using post-connect-script from GlobalAtomicVPN GUI
REM Save as configname_up.bat in the config folder
REM Selva Nov 2012 -- this copy maps Common and Global
REM Limitations: drive letters hard coded to M: and N: -- will fail if those are in use

IF NOT DEFINED smbserver (
set smbserver=global-fs-2.global.local
)

IF NOT DEFINED DOMAIN ( set DOMAIN=global.local )

REM Use echo save-domain-credential to save pass in cred store
REM "%PROGRAMFILES%\OpenVPN\bin\save-cred.exe" "%USER%" "%DOMAIN%"

REM this will prompt for user/pass if not in credentials store
net use \\%smbserver% 

REM now the user can map any share without user/pass

CALL :map M: Common
CALL :map S: Harte
REM CALL :map N: Global
REM CALL :map T: Romex
REM CALL :map U: Silvermet

exit /B 0

:map

if not exist %1\ (
net use %1 \\%smbserver%\%2 /YES /PERSISTENT:NO
)
exit /B 0
