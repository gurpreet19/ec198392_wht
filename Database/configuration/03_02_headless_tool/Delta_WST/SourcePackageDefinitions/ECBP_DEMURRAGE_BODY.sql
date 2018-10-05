CREATE OR REPLACE PACKAGE BODY EcBp_Demurrage IS
/**************************************************************************************************
** Package  :  EcBp_Cargo_Status
**
** $Revision: 1.21 $
**
** Purpose  :  This package handles the business logic for changing the cargo status
**
**
**
** General Logic:
**
** Created:     05.11.2004 Egil ?berrg
**
** Modification history:
**
** Date:       Whom: Rev.  Change description:
** ----------  ----- ----  ------------------------------------------------------------------------
** 11.05.2009  oonnnng  10.0  Update findStartLoadingRange() function to return the correct Cargo Range Type's value.
** 01.07.2009  lauuufus 10.1  Update function findCommencedLaytime, findCompletedLaytime and findLaytime to support multiple Run No.
** 21.12.2012  chooysie 10.2  Add demurrage_type as parameter to ue_demurrage.findCarrierLaytimeAllowance in findDemurrageTime
**************************************************************************************************/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getRunNo
-- Description    : Gets the maximal run no for the cargo
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : lifting_activity
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION getRunNo (p_cargo_no NUMBER)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_run_no(p_cargo_no NUMBER) IS
         SELECT distinct run_no
         FROM lifting_activity
         WHERE cargo_no = p_cargo_no;

  ln_run_no NUMBER;

BEGIN

     FOR curRunNo IN c_run_no(p_cargo_no) LOOP
         ln_run_no := curRunNo.run_no;
     END LOOP;

     RETURN ln_run_no;

END getRunNo;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findStartLoadingRange
-- Description    : Finds the minimum nomination date adjusted for the date range.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       : Needs the customise property '/com/ec/tran/cargo/cargo_range_type'
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findStartLoadingRange(p_cargo_no NUMBER,
            p_lifting_event VARCHAR2)
RETURN DATE
--</EC-DOC>
IS

  CURSOR c_start_loading_range(p_cargo_no NUMBER, p_adjust_factor NUMBER) IS
         SELECT min(nom_firm_date + p_adjust_factor*nvl(nom_firm_date_range, 0)) AS start_loading_range
         FROM storage_lift_nomination n
         WHERE cargo_no = p_cargo_no;

  ld_cargo_date DATE;
  ld_start_loading_range DATE;
  ld_range_type VARCHAR2(100);
  ld_range_adjust NUMBER;

BEGIN

     ld_range_adjust := 0;

     SELECT nvl(max(nom_firm_date),max(requested_date)) into ld_cargo_date
     FROM storage_lift_nomination
     WHERE cargo_no = p_cargo_no;

     ld_range_type:= ecdp_ctrl_property.getSystemProperty('/com/ec/tran/cargo/cargo_range_type',ld_cargo_date);

     IF (ld_range_type = 'CARGO_RANGE_END') OR (ld_range_type =  'CARGO_RANGE_MIDDLE') THEN
          ld_range_adjust := -1;
     END IF;

     FOR curStartLoadingRange IN c_start_loading_range(p_cargo_no, ld_range_adjust) LOOP
         ld_start_loading_range := curStartLoadingRange.start_loading_range;
     END LOOP;

     RETURN ld_start_loading_range;

END findStartLoadingRange;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCommencedLaytime
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findCommencedLaytime (p_cargo_no NUMBER,
                p_demurrage_type VARCHAR2,
                p_activity VARCHAR2,
                p_boundary VARCHAR2,
                p_lifting_event VARCHAR2,
				p_laytime_start_run_no NUMBER DEFAULT NULL)
RETURN DATE
--</EC-DOC>
IS
  CURSOR c_dates(cp_cargo_no NUMBER, cp_demurrage_type VARCHAR2, cp_activity VARCHAR2, cp_lifting_event VARCHAR2, cp_run_no NUMBER) IS
    SELECT  a.activity_code, a.from_daytime, a.to_daytime
    FROM  lifting_activity a,
        lifting_activity_code c,
        cargo_demurrage d
    WHERE  a.cargo_no = cp_cargo_no
    AND   a.activity_code = c.activity_code
    AND   c.lifting_event = cp_lifting_event
    AND   a.cargo_no = d.cargo_no
    AND    d.demurrage_type = cp_demurrage_type
    AND   c.lifting_event = d.lifting_event
    AND   a.activity_code = cp_activity
    AND   a.run_no = cp_run_no;


  ld_commenced_laytime DATE;
  ln_run_no NUMBER;

BEGIN
  --ln_run_no := getRunNo(p_cargo_no);
  IF(p_laytime_start_run_no IS NULL) THEN
	   ln_run_no := 1;
	ELSE
	   ln_run_no := p_laytime_start_run_no;
	END IF;

  FOR curDate IN c_dates(p_cargo_no, p_demurrage_type, p_activity, p_lifting_event, ln_run_no) LOOP
    IF p_boundary = 'START' THEN
       ld_commenced_laytime := curDate.from_daytime;
     ELSIF p_boundary = 'END' THEN
       ld_commenced_laytime := curDate.to_daytime;
     END IF;
  END LOOP;

  RETURN ld_commenced_laytime;

END findCommencedLaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCompletedLaytime
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findCompletedLaytime (p_cargo_no NUMBER,
                p_demurrage_type VARCHAR2,
                p_activity VARCHAR2,
                p_boundary VARCHAR2,
                p_lifting_event VARCHAR2,
				p_laytime_end_run_no NUMBER DEFAULT NULL)
RETURN DATE
--</EC-DOC>
IS
CURSOR c_dates(cp_cargo_no NUMBER, cp_demurrage_type VARCHAR2, cp_activity VARCHAR2, cp_lifting_event VARCHAR2, cp_run_no NUMBER) IS
    SELECT  a.activity_code, a.from_daytime, a.to_daytime
    FROM  lifting_activity a,
        lifting_activity_code c,
        cargo_demurrage d
    WHERE  a.cargo_no = cp_cargo_no
    AND   a.activity_code = c.activity_code
    AND   c.lifting_event = cp_lifting_event
    AND   a.cargo_no = d.cargo_no
    AND    d.demurrage_type = cp_demurrage_type
    AND   c.lifting_event = d.lifting_event
    AND   a.activity_code = cp_activity
    AND   a.run_no = cp_run_no;

  ld_completed_laytime DATE;
  ln_run_no NUMBER;

BEGIN
  --ln_run_no := getRunNo(p_cargo_no);
  IF(p_laytime_end_run_no IS NULL) THEN
	   ln_run_no := 1;
	ELSE
	   ln_run_no := p_laytime_end_run_no;
	END IF;

  FOR curDate IN c_dates(p_cargo_no, p_demurrage_type, p_activity, p_lifting_event, ln_run_no) LOOP
    IF p_boundary = 'START' THEN
       ld_completed_laytime := curDate.from_daytime;
     ELSIF p_boundary = 'END' THEN
       ld_completed_laytime := curDate.to_daytime;
     END IF;
  END LOOP;

  RETURN ld_completed_laytime;

END findCompletedLaytime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findLaytime
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findLaytime(p_cargo_no NUMBER,
          p_demurrage_type VARCHAR2,
          p_start_activity VARCHAR2,
          p_start_boundary VARCHAR2,
          p_end_activity VARCHAR2,
          p_end_boundary VARCHAR2,
          p_lifting_event VARCHAR2,
		  p_laytime_end_run_no NUMBER DEFAULT NULL,
		  p_laytime_start_run_no NUMBER DEFAULT NULL)
RETURN NUMBER
--</EC-DOC>
IS

BEGIN

  RETURN findCompletedLaytime (p_cargo_no, p_demurrage_type, p_end_activity, p_end_boundary, p_lifting_event, p_laytime_end_run_no) - findCommencedLaytime (p_cargo_no, p_demurrage_type, p_start_activity, p_start_boundary, p_lifting_event, p_laytime_start_run_no);

END findLaytime;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCarrierLaytimeAllowance
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findCarrierLaytimeAllowance(p_cargo_no NUMBER,
            p_lifting_event VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_laytime(p_cargo_no NUMBER) IS
         SELECT nvl(max_laytime, 0) laytime
         FROM laytime_limit l, cargo_transport c
         WHERE l.laytime (+) = c.laytime
         and c.cargo_no = p_cargo_no;

  ln_laytime NUMBER;

BEGIN

  IF p_lifting_event = 'LOAD' THEN
    ln_laytime := 0;

    FOR curLaytime IN c_laytime(p_cargo_no) LOOP
      ln_laytime := curLaytime.LAYTIME;
    END LOOP;
   END IF;

  /* laytime for carrier is stored in hours and is converted to days */
  RETURN ln_laytime/24.0;

END findCarrierLaytimeAllowance;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findDelayFromTimesheet
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findDelayFromTimesheet(p_cargo_no NUMBER,
            p_demurrage_type VARCHAR2,
            p_lifting_event VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_demurrage_delay(cp_cargo_no NUMBER, p_lifting_event VARCHAR2) IS
         SELECT FROM_DAYTIME, TO_DAYTIME
         FROM cargo_lifting_delay
         WHERE cargo_no = cp_cargo_no AND
               reason_code = 'SELLER' AND
               lifting_event = p_lifting_event;

  CURSOR c_ebo_delay(cp_cargo_no NUMBER, p_lifting_event VARCHAR2) IS
         SELECT FROM_DAYTIME, TO_DAYTIME
         FROM cargo_lifting_delay
         WHERE cargo_no = cp_cargo_no AND
               reason_code = 'CARRIER' AND
               lifting_event = p_lifting_event;

  ln_delayFromTimesheet NUMBER;

BEGIN

  ln_delayFromTimesheet := 0;

  /*sum delays(carrier)*/
  IF p_demurrage_type = 'EBO' THEN

    FOR curDelay IN c_ebo_delay(p_cargo_no, p_lifting_event) LOOP
        ln_delayFromTimesheet := ln_delayFromTimesheet + (curDelay.TO_DAYTIME - curDelay.FROM_DAYTIME);
    END LOOP;

  ELSE

    /*sum delays(seller)*/
    FOR curDelay IN c_demurrage_delay(p_cargo_no, p_lifting_event) LOOP
        ln_delayFromTimesheet := ln_delayFromTimesheet + (curDelay.TO_DAYTIME - curDelay.FROM_DAYTIME);
    END LOOP;

  END IF;

  RETURN NVL(ln_delayFromTimesheet, 0);

END findDelayFromTimesheet;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findDemurrageTime
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findDemurrageTime (p_cargo_no NUMBER,
            p_demurrage_type VARCHAR2,
            p_lifting_event VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS

CURSOR c_demurrage_time(cp_cargo_no NUMBER, cp_demurrage_type VARCHAR2, cp_lifting_event VARCHAR2) IS
  SELECT   findLaytime(cargo_no, demurrage_type, LAYTIME_START_ACTIVITY, LAYTIME_START_BOUNDARY, LAYTIME_END_ACTIVITY, LAYTIME_END_BOUNDARY, lifting_event, lt_end_boundary_run_no, lt_start_activity_run_no)
          - findDelayFromTimesheet(cargo_no, demurrage_type, lifting_event)
          - nvl(manual_adjustment, 0)
          - NVL(laytime_allowance, ue_demurrage.findCarrierLaytimeAllowance(cargo_no, lifting_event, demurrage_type)) AS demurrage_time
    FROM   cargo_demurrage
    WHERE   cargo_no = cp_cargo_no AND
        demurrage_type = cp_demurrage_type AND
        lifting_event = cp_lifting_event;

  ln_demurrage_time NUMBER;

BEGIN

    ln_demurrage_time := 0;

    FOR curc_demurrage_time IN c_demurrage_time(p_cargo_no, p_demurrage_type, p_lifting_event) LOOP
    ln_demurrage_time := curc_demurrage_time.demurrage_time;
  END LOOP;

  IF ln_demurrage_time < 0 THEN
    ln_demurrage_time := 0;
  END IF;

  RETURN NVL(ln_demurrage_time, 0);

END findDemurrageTime;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : findCalculatedClaim
-- Description    :
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION findCalculatedClaim(p_cargo_no NUMBER,
            p_demurrage_type VARCHAR2,
            p_lifting_event VARCHAR2)
RETURN NUMBER
--</EC-DOC>
IS
  CURSOR c_demurrage_claim(p_cargo_no NUMBER, p_demurrage_type VARCHAR2, p_lifting_event VARCHAR2) IS
         SELECT findDemurrageTime(cargo_no, demurrage_type, lifting_event) * Nvl(demurrage_rate, ue_demurrage.finDefaultDemurrageRate(cargo_no, demurrage_type, lifting_event)) AS calculated_demurage
         FROM cargo_demurrage
         WHERE cargo_no = p_cargo_no AND
               demurrage_type = p_demurrage_type
               AND lifting_event = p_lifting_event;

  ln__calculated_demurrage NUMBER;

BEGIN

  ln__calculated_demurrage := 0;

  FOR curc_demurrage_claim IN c_demurrage_claim(p_cargo_no, p_demurrage_type, p_lifting_event) LOOP
    ln__calculated_demurrage := curc_demurrage_claim.calculated_demurage;
  END LOOP;

  RETURN NVL(ln__calculated_demurrage, 0);

END findCalculatedClaim;

END EcBp_Demurrage;