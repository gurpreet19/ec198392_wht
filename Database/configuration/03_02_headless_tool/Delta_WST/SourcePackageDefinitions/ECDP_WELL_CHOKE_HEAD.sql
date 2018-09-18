CREATE OR REPLACE PACKAGE EcDp_Well_Choke IS
/****************************************************************
** Package        :  EcDp_Well_Choke, header part
**
** $Revision: 1.4 $
**
** Purpose        :  Provides choke data serviced
**
** Documentation  :  www.energy-components.com
**
** Created  : 12.05.2000  Carl-Fredrik S?sen
**
** Modification history:
**
** Date     Whom Change description:
** ------   ---- --------------------------------------
** 10.07.01 KEJ  Added function FindMostRecentConfigDate
** 10.07.01 KEJ  Added function FindMostRecentChokeCode
** 02.10.03 DN   Added criticalOpening. Rel. 7.2.
** 05.10.07 LAU  ECPD-6519: Adapted to new table structure.
** 21.12.11 kumarsur ECPD-18142: FindMostRecentConfigDate now returns the actual date of choketype change, instead of just the last well_version date
*****************************************************************/
FUNCTION criticalOpening(
                                                                        p_object_id well.object_id%TYPE,
                  p_daytime DATE)
RETURN NUMBER;


FUNCTION FindMostRecentConfigDate(
              p_object_id     well.object_id%TYPE,
        p_daytime DATE)
RETURN DATE ;


FUNCTION FindMostRecentChokeCode(
        p_object_id     well.object_id%TYPE,
  p_daytime DATE)
RETURN VARCHAR2;


END EcDp_Well_Choke;