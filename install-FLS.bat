PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
 "Start-Process PowerShell -WorkingDirectory '%~dp0' -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0install-FLS.ps1""' -Verb RunAs"
