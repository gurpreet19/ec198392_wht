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
** Created        :  11.06.01  Carl-Fredrik S?sen
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
** 03.08.17   singishi ECPD-42422: Added a procedure(checkPVTInputParameters) to handle error message if values are outside PT table values.
*****************************************************************/
FUNCTION COL_BO RETURN VARCHAR2;

FUNCTION COL_BW RETURN VARCHAR2;

FUNCTION COL_BG RETURN VARCHAR2;

FUNCTION COL_RS RETURN VARCHAR2;

FUNCTION COL_SP_GRAV RETURN VARCHAR2;

FUNCTION COL_VCF RETURN VARCHAR2;

FUNCTION getInvertedFactor(p_object_id STREAM.OBJECT_ID%TYPE,
                            p_daytime DATE,
                            p_pressure NUMBER,
                            p_temperature NUMBER,
                            p_inv_factor_col_name VARCHAR2)
RETURN NUMBER;

FUNCTION findInvertedFactorFromPT(p_object_id STREAM.OBJECT_ID%TYPE,
                                    p_daytime DATE,
                                    p_pressure NUMBER,
                                    p_temperature NUMBER,
                                    p_inv_factor_col_name VARCHAR2)        -- VCF
RETURN NUMBER;

PROCEDURE copyToNewDaytime (
   p_object_id    stream.object_id%TYPE,
   p_daytime      DATE,
   p_press        NUMBER,
   p_temp        	NUMBER);

PROCEDURE checkPVTInputParameters (
   p_object_id     STREAM.OBJECT_ID%TYPE,
   p_daytime       DATE,
   p_press         NUMBER,
   p_temp          NUMBER);

END EcDp_Stream_PT_Value;