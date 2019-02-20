@echo off
Echo Started Deploy script..

set homepath=%cd%



Echo **************************************************
Echo Running Post scripts..
Echo *************************************************

Echo ****************************************************
Echo Running Post Fixes
Echo ****************************************************

sqlplus /nolog @ InstallScript.sql
if errorlevel 1 (
      goto error 
				)
				
				
Echo ****************************************************
Echo Execution Completed for Post Fixes
Echo ****************************************************
Echo ****************************************************
Echo Execution Completed Post scripts..
Echo ****************************************************


cd %homepath%

:: no error, skip error message
goto end
:error
echo error occurred - check log file
cd %homepath%
:end

cd %homepath%