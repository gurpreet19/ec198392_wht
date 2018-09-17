CREATE OR REPLACE package ECDP_CONSTANT_STANDARD is
/****************************************************************
** Package        :  ECDP_CONSTANT_STANDARD, header part
**
** $Revision: 1.2 $
**
** Purpose        :  to cater for constant standard screens
**
** Documentation  :  www.energy-components.com
**
** Created  : 5/31/2007 5:10:52 PM  NURLIZA JAILUDDIN
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- -----------------------------------
** 	        01.10.2009  sharawan    ECPD-10161: Added new procedure copyStandardConstant to enable new functionality
**                                              to copy existing Constant Standard record
*****************************************************************/

FUNCTION next_daytime(
         p_object_id VARCHAR2,
         p_daytime DATE,
         p_class_name VARCHAR2,
         p_num_rows NUMBER DEFAULT 1) RETURN DATE;


FUNCTION prev_daytime(
         p_object_id VARCHAR2,
         p_daytime DATE,
         p_class_name VARCHAR2,
         p_num_rows NUMBER DEFAULT 1) RETURN DATE;

PROCEDURE copyStandardConstant(p_std_code      VARCHAR2,
                                 p_std_copy_code VARCHAR2,
                                 p_std_copy_name VARCHAR2,
                                 p_user_id       VARCHAR2);

end ECDP_CONSTANT_STANDARD;