CREATE OR REPLACE PACKAGE ue_report IS
/******************************************************************************
** Package        :  ue_report, header part
**
** $Revision: 1.4 $
**
** Purpose        :  License specific package to provide customer specific report functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 06.10.2004 Egil �berg
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -------------------------------------------
** #.#   DD.MM.YYYY  <initials>
********************************************************************/


FUNCTION getZipFileName(
	p_report_no NUMBER,
	p_exec_order NUMBER)
RETURN VARCHAR2
;

FUNCTION getAttachmentName(
	p_report_no NUMBER)
RETURN VARCHAR2;

 FUNCTION generateXml(   p_arg1      VARCHAR2,
                         p_arg2      VARCHAR2,
                         p_arg3      VARCHAR2,
                         p_arg4      VARCHAR2,
                         p_arg5      VARCHAR2,
                         p_arg6      VARCHAR2,
                         p_arg7      VARCHAR2) RETURN CLOB;

END ue_report;