@echo off
Echo Started Deploy script..
cd "01_12.1.0.PATCH01"

Echo **************************************************
Echo Running EC Patch scripts..
Echo **************************************************
cd "01_12.1.0.PATCH01"
exit | sqlplus -s <CONNECTSTRING> @"install-patch.sql" ../../configuration/operation_parameters.sql
cd..
cd "02_12.1.0.PATCH03"
exit | sqlplus -s <CONNECTSTRING> @"install-patch.sql" ../../configuration/operation_parameters.sql
	
Echo ****************************************************
Echo Execution Completed for EC Patch scripts
Echo ****************************************************


:: no error, skip error message
goto end
:error
echo error occurred - check log file
cd %homepath%
:end

cd %homepath%




