@echo off

echo ===========================================================================
echo  Installing [ DQ Tool ] 
echo ===========================================================================
echo Start [%date%, %time%]
exit | sqlplus -s <CONNECTSTRING> @install.sql ../../configuration/operation_parameters.sql

echo Done [%date%, %time%]