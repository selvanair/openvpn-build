#!/bin/sh
file1=${1:?Usage signcode file.exe file-signed.exe [pass]}
file2=${2:?Usage signcode file.exe file-signed.exe [pass]}
pass=${3:-pass}
osslsigncode -certs ~/GlobalCA/GlobalRootCA/certs/selva-signing.crt \
             -key ~/GlobalCA/GlobalRootCA/certs/selva-signing.key \
	     -h sha256 -t http://timestamp.digicert.com \
	     -pass $pass "$file1" "$file2" || die "signing failed"

