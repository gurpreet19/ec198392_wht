CREATE OR REPLACE PACKAGE EcDp_Well_Swing_Theoretical IS

/****************************************************************
** Package        :  EcDp_Well_Swing_Theoretical, header part
**
** $Revision: 1.6 $
**
** Purpose        :  Calculate volumes for Swing Wells
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.03.2010  aliassit
**
** Modification history:
**
** Version  Date       Whom  Change description:
** -------  --------   ----  --------------------------------------
** 1.0      11.3.10   aliassit   Initial version
*           26.3.10   aliassit   ECPD-14305: Remove unused parameter
*  2.0      13.5.11   musthram   ECPD-16989: Added calcStreamWellMassDay,calcWellGasMassDay,calcWellWatMassDay,calcWellCondMassDay
*****************************************************************/


FUNCTION getGasStdRateToAsset(
         p_object_id well.object_id%TYPE,
         p_fromday DATE,
         p_today DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getGasStdRateToAsset, WNDS, WNPS, RNPS);

FUNCTION getCondStdRateToAsset(
         p_object_id well.object_id%TYPE,
         p_fromday DATE,
         p_today DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getCondStdRateToAsset, WNDS, WNPS, RNPS);

FUNCTION getWatStdRateToAsset(
         p_object_id well.object_id%TYPE,
         p_fromday DATE,
         p_today DATE DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getWatStdRateToAsset, WNDS, WNPS, RNPS);

FUNCTION calcWellWatDay(
    p_object_id       well.object_id%TYPE,
    p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellWatDay, WNDS, WNPS, RNPS);

FUNCTION calcWellGasDay(
    p_object_id       well.object_id%TYPE,
    p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellGasDay, WNDS, WNPS, RNPS);

FUNCTION calcWellCondDay(
    p_object_id       well.object_id%TYPE,
    p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellCondDay, WNDS, WNPS, RNPS);

FUNCTION calcWellOilDay(
    p_object_id       well.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellOilDay, WNDS, WNPS, RNPS);

FUNCTION calcStreamWellDay (
    p_object_id       well.object_id%TYPE,
    p_asset_id        VARCHAR2,
    p_daytime  DATE,
    p_stream_id  stream.object_id%TYPE DEFAULT NULL)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcStreamWellDay , WNDS, WNPS, RNPS);

FUNCTION calcWellWatMassDay(
    p_object_id       well.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellWatMassDay , WNDS, WNPS, RNPS);

FUNCTION calcWellCondMassDay(
    p_object_id       well.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellCondMassDay , WNDS, WNPS, RNPS);

FUNCTION calcWellGasMassDay(
    p_object_id       well.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  VARCHAR2 DEFAULT NULL)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcWellGasMassDay , WNDS, WNPS, RNPS);

FUNCTION calcStreamWellMassDay (
    p_object_id       well.object_id%TYPE,
    p_daytime  DATE,
    p_stream_id  stream.object_id%TYPE DEFAULT NULL)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (calcStreamWellMassDay , WNDS, WNPS, RNPS);

END EcDp_Well_Swing_Theoretical;
