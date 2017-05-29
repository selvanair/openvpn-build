@echo off
REM Map drives using post-connect-script from GlobalAtomicVPN GUI
REM Save as configname_up.bat in the config folder
REM Selva Nov 2012 -- this copy maps Common and Global
REM Limitations: drive letters hard coded to M: and N: -- will fail if those are in use

save-cred.exe rlehari global.local

IF NOT DEFINED smbserver (
set smbserver=global-fs-2.global.local
)

REM this will prompt for user/pass if not in credentials store
net use \\%smbserver% 

REM now the user can map any share without user/pass

if not exist M:\ (
net use M: \\%smbserver%\Common /YES /PERSISTENT:NO
)

REM map Harte
if not exist S:\ (
net use S: \\%smbserver%\Harte /YES /PERSISTENT:NO
)

REM map Global
if not exist N:\ (
net use N: \\%smbserver%\Global /YES /PERSISTENT:NO
)

REM map Romex 
if not exist T:\ (
net use T: \\%smbserver%\Romex /YES /PERSISTENT:NO
)

REM map Silvermet
if not exist U:\ (
net use U: \\%smbserver%\Silvermet /YES /PERSISTENT:NO
)
