CREATE OR REPLACE PACKAGE EcBp_Balancing IS

/****************************************************************
** Package        :  EcDp_Balancing, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Provide support for balancing
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.01.2016  Mawaddah
**
** Modification history:
**
** Date     Whom   		description:
** -------  ------ 		--------------------------------------
** 21.01.16 abdulmaw 	ECPD-30628: Added new function getProductUOM and validateBalancingAdj
** 21.02.16 dhavaalo 	ECPD-30030: Added new function getProductBalGroup
** 11.02.16 chaudgau    ECPD-38185: Added new function isWaterProductGroup
** 08.11.16 chaudgau    ECPD-39505: Added new function getAdjVolume
*****************************************************************/
FUNCTION getProductUOM (
   p_product_id     VARCHAR2,
   p_daytime        DATE,
   p_rate_type VARCHAR2)
RETURN VARCHAR2;


FUNCTION getProductBalGroup(
   p_product_balance  strm_version.product_id%TYPE,
   p_daytime          DATE,
   p_end_date 		    DATE,
   p_strm_bal_category  strm_version.strm_bal_category%TYPE,
   P_CODE_NAME VARCHAR2)
RETURN VARCHAR2;

PROCEDURE validateBalancingAdj(
   p_product_group_id VARCHAR2,
   p_product_id       VARCHAR2,
   p_strm_bal_category VARCHAR2,
   p_stream_id		  VARCHAR2,
   p_from_object_type VARCHAR2,
   p_from_object_id   VARCHAR2,
   p_to_object_type   VARCHAR2,
   p_to_object_id     VARCHAR2);

FUNCTION isWaterProductGroup(
    p_product_id         VARCHAR2
   ,p_daytime            DATE
   ,p_end_date           DATE
   ,p_strm_bal_category  VARCHAR2)
RETURN VARCHAR2;

FUNCTION getAdjVolume(
    p_strm_object_id     VARCHAR2
   ,p_daytime            DATE
   ,p_property           VARCHAR2 DEFAULT 'NET_VOL')
RETURN NUMBER;

END EcBp_Balancing;