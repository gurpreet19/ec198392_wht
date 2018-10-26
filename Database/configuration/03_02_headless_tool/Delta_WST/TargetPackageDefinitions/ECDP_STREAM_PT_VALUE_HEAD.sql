CREATE OR REPLACE PACKAGE EcDp_Stream_PT_Value IS
/****************************************************************
** Package        :  EcDp_Stream_PT_Value; head part
**
** $Revision: 1.6 $
**
** Purpose        :  This package is responsible for data access to
**                   the strm_pt_value
**
** Documentation  :  www.energy-components.com
**
** Created        :  11.06.01  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -----    --------------------------------------
** 11.06.01   CFS      First version.
** 11.08.2004 mazrina  removed sysnam and update as necessary
** 18.04.05   MOT      Added copyToNewDaytime
** 21.04.05   DN       Removed old functions towards strm_pt_value.
** 03.08.09   embonhaf ECPD-11153 Added interpolation calculation support for VCF.
** 23.02.11   amirrasn ECPD-15842 Added support for more columns when accessing data from strm_pt_conversion.
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
                            p_pressure NUMBER,
                            p_temperature NUMBER,
                            p_inv_factor_col_name VARCHAR2)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getInvertedFactor, WNDS,  WNPS, RNPS);

FUNCTION findInvertedFactorFromPT(p_object_id STREAM.OBJECT_ID%TYPE,
                                    p_daytime DATE,
                                    p_pressure NUMBER,
                                    p_temperature NUMBER,
                                    p_inv_factor_col_name VARCHAR2)        -- VCF
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (findInvertedFactorFromPT, WNDS,  WNPS, RNPS);

PROCEDURE copyToNewDaytime (
   p_object_id    stream.object_id%TYPE,
   p_daytime      DATE,
   p_press        NUMBER,
   p_temp        	NUMBER);

END EcDp_Stream_PT_Value;