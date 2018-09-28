@echo off

echo Creating file.

set fullpath=%cd%

call .\01_Utility_File\BuildPrecheckScript.bat> "%fullpath%\Precheck.sql"

echo Script created

title=Running Precheck Scripts

sqlplus /nolog @"%fullpath%\Precheck.sql"

echo Prechecklog.csv file created.

Pause