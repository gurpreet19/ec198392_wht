CREATE OR REPLACE PACKAGE EcDp_Stream_DPT_Value IS

/****************************************************************
** Package        :  EcDp_Stream_DPT_Value (HEAD)
**
** $Revision: 1.5 $
**
** Purpose        :  This package provide data access service to:
**                   - STRM_DPT_CONVERSION table
**
** Documentation  :  www.energy-components.com
**
** Created  : 08.01.2008  Arief Zaki
**
** Modification history:
**
** Date        Whom     Change description:
** ------      ----     --------------------------------------
** 08.01.2008  zakiiari ECPD-7226: Initial version
** 14.05.09    oonnnng  ECPD-11791: Added copyToNewDaytime() function.
** 03.08.09    embonhaf ECPD-11153 Added interpolation calculation support for VCF.
*****************************************************************/

FUNCTION COL_BO RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (COL_BO, WNDS,  WNPS, RNPS);

FUNCTION COL_BW RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (COL_BW, WNDS,  WNPS, RNPS);

FUNCTION COL_BG RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (COL_BG, WNDS,  WNPS, RNPS);

FUNCTION COL_RS RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (COL_RS, WNDS,  WNPS, RNPS);

FUNCTION COL_SP_GRAV RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (COL_SP_GRAV, WNDS,  WNPS, RNPS);

FUNCTION COL_VCF RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (COL_VCF, WNDS,  WNPS, RNPS);

FUNCTION getInvertedFactor(p_object_id STREAM.OBJECT_ID%TYPE,
                            p_daytime DATE,
                            p_density NUMBER,
                            p_pressure NUMBER,
                            p_temperature NUMBER,
                            p_inv_factor_col_name VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getInvertedFactor, WNDS,  WNPS, RNPS);

FUNCTION findInvertedFactorFromDPT(p_object_id STREAM.OBJECT_ID%TYPE,
                                    p_daytime DATE,
                                    p_density NUMBER,
                                    p_pressure NUMBER,
                                    p_temperature NUMBER,
                                    p_inv_factor_col_name VARCHAR2)        -- BO / BG / BW / RS / SP_GRAV / VCF
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findInvertedFactorFromDPT, WNDS,  WNPS, RNPS);

PROCEDURE copyToNewDaytime (
   p_object_id    stream.object_id%TYPE,
   p_daytime      DATE,
   p_density      NUMBER,
   p_press        NUMBER,
   p_temp         NUMBER);


END EcDp_Stream_DPT_Value;