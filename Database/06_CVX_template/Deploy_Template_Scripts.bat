@echo off
Echo Started Deploy script..

set homepath=%cd%

Echo **************************************************
Echo Running CVX template scripts..
Echo **************************************************


 sqlplus /nolog @ Pre-Install-EC_CVX_12.sql
if errorlevel 1 (
      goto error
				)
               
 sqlplus /nolog @ Install-EC_CVX_12.sql
 if errorlevel 1 (
      goto error
				)
                
Echo ****************************************************
Echo Execution Completed for CVX Template scripts
Echo ****************************************************


:: no error, skip error message
goto end
:error
echo error occurred - check log file
cd %homepath%
:end

cd %homepath%