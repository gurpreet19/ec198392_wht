REM ======================================
REM ======== Energy Components ===========
REM ======================================
REM ======= D O  N O T  E D I T ==========
REM ======= (C) Tieto Norway AS ==========
REM ======================================
PROMPT **** ***************************** **** 
PROMPT **** Energy Component DB install script. 
PROMPT ****      (C) Tieto Norway AS 
PROMPT **** Release: 11.2
PROMPT **** SQLPlus: &_SQLPLUS_RELEASE 
PROMPT **** ***************************** **** 
PROMPT 
WHENEVER OSERROR EXIT -1
WHENEVER SQLERROR EXIT SQL.SQLCODE
TIMING START EnergyComponent_CLASS_UPGRADE
SET TIMING ON

set echo off newpage 0 space 0 pagesize 0  linesize 6000 feed off head off trimspool on

PROMPT Installing: [EXECUTE ecdp_pinc.enableInstallMode('&version_to');]
EXECUTE ecdp_pinc.enableInstallMode('&version_to')





