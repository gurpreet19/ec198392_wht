@echo off
REM _Perl\bin\perl.exe "_Perl\upgrade.pl" 1 1,2,3,4,5,6,7,8,9,10,11,13,14,15

cd "10_WHT_Releases\WHT_Release_1.07"
call "BuildScript.bat"
call "Deploy.bat"
cd..
cd..
cd "10_WHT_Releases\WHT_Release_1.08"
call "BuildScript.bat"
call "Deploy.bat"
cd..
cd..
cd "10_WHT_Releases\WHT_Release_1.09"
call "BuildScript.bat"
call "Deploy.bat"
cd..
cd..