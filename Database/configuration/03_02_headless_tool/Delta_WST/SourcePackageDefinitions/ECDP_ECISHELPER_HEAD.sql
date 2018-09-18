CREATE OR REPLACE PACKAGE EcDp_EcIsHelper IS
/****************************************************************
** Package        :  EcDp_EcIsHelper, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Support functions for ECIS Config
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.07.2009  Arild Vervik
**
** Modification history:
**
** Date        Whom  	Change description:
** ------      ----- 	-----------------------------------
** 21.07.2009  AV   	Initial version
*****************************************************************/

FUNCTION getProdDayIdFromTagid(p_source_id VARCHAR2,
                              p_tag_id    VARCHAR2,
                              p_pk_attr_1 VARCHAR2 DEFAULT NULL,
                              p_pk_val_1  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_2 VARCHAR2 DEFAULT NULL,
                              p_pk_val_2  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_3 VARCHAR2 DEFAULT NULL,
                              p_pk_val_3  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_4 VARCHAR2 DEFAULT NULL,
                              p_pk_val_4  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_5 VARCHAR2 DEFAULT NULL,
                              p_pk_val_5  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_6 VARCHAR2 DEFAULT NULL,
                              p_pk_val_6  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_7 VARCHAR2 DEFAULT NULL,
                              p_pk_val_7  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_8 VARCHAR2 DEFAULT NULL,
                              p_pk_val_8  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_9 VARCHAR2 DEFAULT NULL,
                              p_pk_val_9  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_10 VARCHAR2 DEFAULT NULL,
                              p_pk_val_10  VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;


FUNCTION getTZRegionFromTagid(p_source_id VARCHAR2,
                              p_tag_id    VARCHAR2,
                              p_pk_attr_1 VARCHAR2 DEFAULT NULL,
                              p_pk_val_1  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_2 VARCHAR2 DEFAULT NULL,
                              p_pk_val_2  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_3 VARCHAR2 DEFAULT NULL,
                              p_pk_val_3  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_4 VARCHAR2 DEFAULT NULL,
                              p_pk_val_4  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_5 VARCHAR2 DEFAULT NULL,
                              p_pk_val_5  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_6 VARCHAR2 DEFAULT NULL,
                              p_pk_val_6  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_7 VARCHAR2 DEFAULT NULL,
                              p_pk_val_7  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_8 VARCHAR2 DEFAULT NULL,
                              p_pk_val_8  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_9 VARCHAR2 DEFAULT NULL,
                              p_pk_val_9  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_10 VARCHAR2 DEFAULT NULL,
                              p_pk_val_10  VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;


FUNCTION calcnextread(p_source_id VARCHAR2,
                      p_tag_id    VARCHAR2,
                      p_pk_attr_1 VARCHAR2,
                      p_pk_val_1  VARCHAR2,
                      p_pk_attr_2 VARCHAR2,
                      p_pk_val_2  VARCHAR2,
                      p_pk_attr_3 VARCHAR2,
                      p_pk_val_3  VARCHAR2,
                      p_pk_attr_4 VARCHAR2,
                      p_pk_val_4  VARCHAR2,
                      p_pk_attr_5 VARCHAR2,
                      p_pk_val_5  VARCHAR2,
                      p_pk_attr_6 VARCHAR2,
                      p_pk_val_6  VARCHAR2,
                      p_pk_attr_7 VARCHAR2,
                      p_pk_val_7  VARCHAR2,
                      p_pk_attr_8 VARCHAR2,
                      p_pk_val_8  VARCHAR2,
                      p_pk_attr_9 VARCHAR2,
                      p_pk_val_9  VARCHAR2,
                      p_pk_attr_10 VARCHAR2,
                      p_pk_val_10  VARCHAR2,
                      p_last_transfer DATE,
                      p_prod_day_start  NUMBER,
                      p_target_interval NUMBER
                      )
RETURN DATE;

FUNCTION getNumberOfAttachedMappings(p_template_id VARCHAR2)
RETURN NUMBER;

FUNCTION getPKObjectRef(p_pk_attr_1 VARCHAR2,
                       p_pk_val_1  VARCHAR2,
                       p_pk_attr_2 VARCHAR2 DEFAULT NULL,
                       p_pk_val_2  VARCHAR2 DEFAULT NULL,
                       p_pk_attr_3 VARCHAR2 DEFAULT NULL,
                       p_pk_val_3  VARCHAR2 DEFAULT NULL,
                       p_pk_attr_4 VARCHAR2 DEFAULT NULL,
                       p_pk_val_4  VARCHAR2 DEFAULT NULL,
                       p_pk_attr_5 VARCHAR2 DEFAULT NULL,
                       p_pk_val_5  VARCHAR2 DEFAULT NULL,
                       p_pk_attr_6 VARCHAR2 DEFAULT NULL,
                       p_pk_val_6  VARCHAR2 DEFAULT NULL,
                       p_pk_attr_7 VARCHAR2 DEFAULT NULL,
                       p_pk_val_7  VARCHAR2 DEFAULT NULL,
                       p_pk_attr_8 VARCHAR2 DEFAULT NULL,
                       p_pk_attr_9 VARCHAR2 DEFAULT NULL,
                       p_pk_val_8  VARCHAR2 DEFAULT NULL,
                       p_pk_val_9  VARCHAR2 DEFAULT NULL,
                       p_pk_attr_10 VARCHAR2 DEFAULT NULL,
                       p_pk_val_10  VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;


END;