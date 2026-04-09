@echo off
echo Sincronizando arquivos para Debug...
xcopy /E /Y /I "dados"   "..\prj\Win32\Debug\files\dados\"
xcopy /E /Y /I "slider"  "..\prj\Win32\Debug\files\slider\"
xcopy /E /Y /I "niveis"  "..\prj\Win32\Debug\files\niveis\"
copy /Y "portal.html"    "..\prj\Win32\Debug\files\portal.html"
echo.
echo Pronto! Recarregue o portal.
pause
