@echo off

echo Creating file.
set fullpath=%cd%
call .\01_Utility_File\BuildScript_01.bat> "%fullpath%\InstallScript.sql"
echo Script created
