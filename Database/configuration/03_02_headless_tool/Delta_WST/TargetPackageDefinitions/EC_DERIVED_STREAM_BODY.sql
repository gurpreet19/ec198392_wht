CREATE OR REPLACE PACKAGE BODY ec_derived_stream IS
/******************************************************************************
** Package        :  ec_derived_stream, bod part
**
** $Revision: 1.3 $
**
** Purpose        :  User exit package with a predefined and fixed function interface
**                   used to implement customer specific stream quantity
**                   calculations.
**
** Documentation  :  www.energy-components.com
**
** Created        :  Added to CVS 9-Mar-2006
**
** Modification history:
**
** Date        Whom      Change description:
** ----------  -----     -----------------------------------------------------------------------------------------------
** 26.09.2006  kaurrjes  TI#4547: Added new function math_energy
** 03.03.2008  rajarsar  ECPD-7127: Added new function math_power_consumption
********************************************************************/


FUNCTION math_net_vol(
         p_stream_id  VARCHAR2,
         p_from_day     DATE,
         p_to_day       DATE DEFAULT NULL,
         p_method       VARCHAR2 DEFAULT 'SUM') RETURN NUMBER IS

BEGIN

 RETURN NULL;

END math_net_vol;

------------------------------------------------------------------------------------

FUNCTION math_net_mass(
         p_stream_id  VARCHAR2,
         p_from_day     DATE,
         p_to_day       DATE DEFAULT NULL,
         p_method       VARCHAR2 DEFAULT 'SUM') RETURN NUMBER IS

BEGIN

 RETURN NULL;

END math_net_mass;

------------------------------------------------------------------------------------

FUNCTION math_grs_vol(
         p_stream_id  VARCHAR2,
         p_from_day     DATE,
         p_to_day       DATE DEFAULT NULL,
         p_method       VARCHAR2 DEFAULT 'SUM') RETURN NUMBER IS

BEGIN

 RETURN NULL;

END math_grs_vol;

------------------------------------------------------------------------------------

FUNCTION math_grs_mass(
         p_stream_id  VARCHAR2,
         p_from_day     DATE,
         p_to_day       DATE DEFAULT NULL,
         p_method       VARCHAR2 DEFAULT 'SUM') RETURN NUMBER IS

BEGIN

 RETURN NULL;

END math_grs_mass;

------------------------------------------------------------------------------------

FUNCTION math_energy(
         p_stream_id  VARCHAR2,
         p_from_day     DATE,
         p_to_day       DATE DEFAULT NULL,
         p_method       VARCHAR2 DEFAULT 'SUM') RETURN NUMBER IS


BEGIN

     RETURN NULL;

END math_energy;

------------------------------------------------------------------------------------

FUNCTION math_power_consumption(
         p_stream_id  VARCHAR2,
         p_from_day     DATE,
         p_to_day       DATE DEFAULT NULL,
         p_method       VARCHAR2 DEFAULT 'SUM') RETURN NUMBER IS


BEGIN

     RETURN NULL;

END math_power_consumption;


END ec_derived_stream;