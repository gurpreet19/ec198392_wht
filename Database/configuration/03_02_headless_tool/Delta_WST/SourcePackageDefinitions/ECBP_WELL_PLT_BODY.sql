CREATE OR REPLACE package body ECBP_WELL_PLT is

/****************************************************************
** Package        :  EcBp_Well_PLT, body part
**
** $Revision: 1.4 $
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
** 1.0     05.10.2004   kaurrnar    Initial version
** 1.1     29.10.2004   Toha        reference to tables instead of views
*****************************************************************/
--<EC-DOC>


-----------------------------------------------------------------
--  Function:    calcPercent
--  Description: Returns the percentage for a phase of a well bore.
--               The phase may be "OIL" or "GAS" or "WATER".
-----------------------------------------------------------------

FUNCTION calcPercent(
	p_object_id        webo_interval.object_id%TYPE,
  p_perf_interval_id perf_interval.object_id%TYPE,
  p_phase            VARCHAR2,
  p_daytime          DATE)

RETURN NUMBER IS
CURSOR c_webo_result (cp_object_id webo_interval.object_id%TYPE,
                      cp_perf_interval_id perf_interval.object_id%TYPE,
                      cp_daytime date) IS
  SELECT * FROM webo_interval_plt_result
    WHERE object_id = cp_object_id
    AND perf_interval_id = cp_perf_interval_id
    AND daytime = cp_daytime;

ln_return NUMBER;

ln_total number;
BEGIN

ln_total := calcTotal(p_object_id, p_phase, p_daytime);

if ln_total = 0 then -- div/0
  return 0;
end if;

ln_return := 0;

FOR mycur IN c_webo_result(p_object_id, p_perf_interval_id, p_daytime) LOOP
  if p_phase = 'OIL' then
   ln_return := mycur.oil_rate/ln_total*100;

  elsif p_phase = 'GAS' then
   ln_return := mycur.gas_rate/ln_total*100;

  elsif p_phase = 'WATER' then
   ln_return := mycur.water_rate/ln_total*100;

  end if;
END LOOP;

    RETURN ln_return;

END calcPercent;


-----------------------------------------------------------------
--  Function:    calcTotal
--  Description: Returns the total for a phase of a well bore.
--               The phase may be "OIL" or "GAS" or "WATER".
-----------------------------------------------------------------

FUNCTION calcTotal(

	p_object_id        webo_interval.object_id%TYPE,
  p_phase            VARCHAR2,
  p_daytime          DATE)

RETURN number IS

cursor c_plt_phase_total (cp_object_id webo_interval.object_id%TYPE,
                          cp_daytime date) is
         select
                --nvl(sum(oil_rate), 0),
                oil_rate,
                --nvl(sum(gas_rate), 0),
                gas_rate,
                --nvl(sum(water_rate), 0)
                water_rate
                --from dv_webo_plt_test_result
                from webo_interval_plt_result r
                WHERE object_id = cp_object_id
                AND daytime = cp_daytime;

ln_total NUMBER;

BEGIN
ln_total := 0;
for c_cur in c_plt_phase_total (p_object_id, p_daytime) loop
if p_phase = 'OIL' then
--  ln_total := c_cur.oil_rate;
  ln_total := ln_total + c_cur.oil_rate;
elsif p_phase = 'GAS' then
--  ln_total := c_cur.gas_rate;
  ln_total := ln_total + c_cur.gas_rate;
elsif p_phase = 'WATER' then
--  ln_total := c_cur.water_rate;
  ln_total := ln_total + c_cur.water_rate;
else
  ln_total := 0;
end if;

end loop;

   RETURN ln_total;

END calcTotal;

end ECBP_WELL_PLT;