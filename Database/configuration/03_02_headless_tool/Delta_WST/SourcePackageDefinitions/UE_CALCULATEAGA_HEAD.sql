CREATE OR REPLACE PACKAGE Ue_CalculateAGA AS
/****************************************************************
** Package        :  Ue_CalculateAGA, body part.
**
** $Revision:
**
** Purpose        :  Customer specific implementation for AGA3
**
** Documentation  :  www.energy-components.com
**
** Created  : 16.12.2016  shindani
**
** Modification history:
**
** Date       Whom     Change description:
** ------     -------- --------------------------------------
** 16.12.2016  shindani  Initial version

*****************************************************************/
FUNCTION calculateTdevFlowDensity(
   p_object_id  VARCHAR2,
   p_daytime DATE,
   p_static_pressure NUMBER,
   p_temp     NUMBER,
   p_compress NUMBER,
   p_grs      NUMBER,
   p_class_name  VARCHAR2)
RETURN NUMBER;

FUNCTION calculateTdevStdDensity(
   p_object_id  VARCHAR2,
   p_daytime DATE,
   p_pressure NUMBER,
   p_temp     NUMBER,
   p_compress NUMBER,
   p_grs      NUMBER)
RETURN NUMBER;

END Ue_CalculateAGA;