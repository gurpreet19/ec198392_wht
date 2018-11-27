CREATE OR REPLACE PACKAGE EcDp_Stream_Analysis IS

/****************************************************************
** Package        :  EcDp_Stream_Analysis
**
** $Revision: 1.11 $
**
** Purpose        :  This package is responsible for data access to
**                   stream analysis properties.
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.02.2000  Carl-Fredrik Sørensen
**
** Modification history:
**
** Date       Whom  Change description:
** ------     ----- --------------------------------------
** 01.02.00   CFS   First version
** 18.05.00   DN    New function getCargoBswVolFrac
** 15.06.00   PGI   Added function getCondWatFrac
** 01.05.2001 FBa   Added function getCargoDensity
** 22.02.2001 HVe   Added function getDayOilInWater
** 27.05.2004 DN    Removed function getCondWatFrac.
** 04.08.2004       removed sysnam and stream_code and update as necessary
** 21.10.2004 DN    Removed getCargo-functions.
** 28.10.2004 Toha  Added GetAgaAnalysis, GetAgaAnalysisItem
** 01.11.2004 Toha  Fixed getAgaAnalysis, refering to table instead of view
** 10.05.2005 DN    Added pragmas to functions getAGAAnalysis and getAGAAnalysisItem.
** 25.07.2005 Ron Boh   Added new function getPrevAnalysisDaytime
** 16.12.2005 Dn    Added getNextAGAAnalysisSample.
** 11.09.2007 idrussab    ECPD-6295: Added getSaltWeightFrac
*****************************************************************/

--

FUNCTION getBswVolFrac (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getBswVolFrac, WNDS, WNPS, RNPS);

--

FUNCTION getBswWeightFrac (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getBswWeightFrac, WNDS, WNPS, RNPS);

--

FUNCTION getSaltWeightFrac (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getSaltWeightFrac, WNDS, WNPS, RNPS);

--

FUNCTION getDayOilInWater (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (getDayOilInWater, WNDS, WNPS, RNPS);

--
FUNCTION getAGAAnalysis(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN object_aga_analysis%ROWTYPE
;
PRAGMA RESTRICT_REFERENCES (getAGAAnalysis, WNDS, WNPS, RNPS);


FUNCTION getAGAAnalysisItem(p_object_id stream.object_id%TYPE,
                            p_item     VARCHAR2,
                            p_daytime  DATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getAGAAnalysisItem, WNDS, WNPS, RNPS);

FUNCTION getNextAGAAnalysisSample(p_object_id stream.object_id%TYPE, p_daytime DATE)
RETURN object_aga_analysis%ROWTYPE;
PRAGMA RESTRICT_REFERENCES (getNextAGAAnalysisSample, WNDS, WNPS, RNPS);

--

FUNCTION getPrevAnalysisDaytime (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE,
   p_analysis_type VARCHAR2,
   p_num_rows NUMBER DEFAULT 1)

RETURN DATE;

PRAGMA RESTRICT_REFERENCES (getPrevAnalysisDaytime, WNDS, WNPS, RNPS);


FUNCTION getCompositeAnalysisStatus (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getCompositeAnalysisStatus, WNDS, WNPS, RNPS);

FUNCTION getCompositeAnalysisComment (
   p_object_id stream.object_id%TYPE,
   p_daytime     DATE)

RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (getCompositeAnalysisComment, WNDS, WNPS, RNPS);

END EcDp_Stream_Analysis;