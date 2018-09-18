CREATE OR REPLACE PACKAGE transfer_web_util IS
/****************************************************************
** Package        :  TRANSFER_WEB_UTIL, header part
**
** $Revision: 1.1 $
**
** Purpose        :  Definition of date and time methods
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.02.2004  Harald Kaada
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------
** 16.02.2004  HAK   Initial version
**                   for function summertime flag
*****************************************************************/

FUNCTION getPrimKey(map_no VARCHAR2)
RETURN VARCHAR2;

FUNCTION getPrimKeyValues(map_no VARCHAR2)
RETURN VARCHAR2;

END;