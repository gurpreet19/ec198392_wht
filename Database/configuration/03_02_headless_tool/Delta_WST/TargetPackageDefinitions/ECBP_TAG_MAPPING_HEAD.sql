CREATE OR REPLACE PACKAGE EcBp_Tag_Mapping IS

/****************************************************************
** Package        :   head part
**
** $Revision: 1.1 $
**
** Purpose        :  This package is responsible to generate new
**                   mapping for an object based on an existing object.
**
** Documentation  :  www.energy-components.com
**
** Created        :
**
** Modification history:
**
** Version  Date        Whom         Change description:
** -------  ----------  --------     --------------------------------------
** 1.0      28-04-2006  Lau          Added generateMapping
*****************************************************************/

PROCEDURE generateMapping(
     p_object_id    VARCHAR2,
     p_new_object_id VARCHAR2,
     p_last_transfer  DATE);

END;
