CREATE OR REPLACE PACKAGE ecbp_well_plt IS
/****************************************************************
** Package        :  EcBp_Well_PLT, header part
**
** $Revision: 1.3 $
**
** Purpose        :  This package is responsible for calculating the percentage
**                   that is not achievable directly in the well bore objects.
**
** Documentation  :  www.energy-components.com
**
** Created  : 05.10.2004  Narinder Kaur
**
** Modification history:
**
** Version  Date        Whom       Change description:
** -------  ------      -----      --------------------------------------
** 1.0     05.10.2004	kaurrnar    Initial version
*****************************************************************/
--<EC-DOC>

FUNCTION calcPercent(
	p_object_id        webo_interval.object_id%TYPE,
  p_perf_interval_id perf_interval.object_id%TYPE,
  p_phase            VARCHAR2,
  p_daytime          DATE)

RETURN NUMBER;

---

FUNCTION calcTotal(
	p_object_id        webo_interval.object_id%TYPE,
  p_phase            VARCHAR2,
  p_daytime          DATE)

RETURN NUMBER;

end ECBP_WELL_PLT;