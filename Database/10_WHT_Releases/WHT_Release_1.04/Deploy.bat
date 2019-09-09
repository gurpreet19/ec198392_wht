@echo off
Echo Started Deploy script..

set homepath=%cd%



Echo **************************************************
Echo Running WHT release 4 scripts..
Echo **************************************************

Echo ****************************************************
Echo Running WHT release 4 database defect scripts
Echo ****************************************************

sqlplus /nolog @ InstallScript.sql
if errorlevel 1 (
      goto error 
				)
				
		
Echo ****************************************************
Echo Execution Completed for database defect scripts
Echo ****************************************************

Echo ****************************************************
Echo Execution Completed WHT release 4 scripts..
Echo ****************************************************

				
cd %homepath%

:: no error, skip error message
goto end
:error
echo error occurred - check log file
cd %homepath%
:end

cd %homepath%