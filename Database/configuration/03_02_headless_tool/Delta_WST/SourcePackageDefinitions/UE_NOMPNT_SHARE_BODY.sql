CREATE OR REPLACE PACKAGE BODY ue_NOMPNT_SHARE IS
/******************************************************************************
** Package        :  ue_CNTR_CONTRACT_SHARE, body part
**
** $Revision: 1.6 $
**
** Purpose        :  Includes user-exit functionality for cntr contract share screen
**
** Documentation  :  www.energy-components.com
**
** Created  : 02.02.2012 Tommy Hassel
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- -----------------------------------------------------------------------------------------------
** 27.06.2012  sharawan ECPD-21296 : Added new procedure validateShare to regulate the share sum not exceeding 100.
*/


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : set_end_date
-- Description    : handles end date validation after insert
--
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
PROCEDURE set_end_date(p_object_id VARCHAR2, p_daytime DATE)

--</EC-DOC>
IS

cursor c_max_end_date( cp_object_id VARCHAR2) is
select max(end_date) end_date from dv_trnp_event_share
where object_id = cp_object_id
;

cursor c_daytime(cp_object_id VARCHAR2, cp_daytime DATE) is
select * from dv_trnp_event_share
where object_id = cp_object_id
and daytime >= cp_daytime;

e_max_end_date EXCEPTION;
ld_end_date DATE;
ld_start_date DATE;

BEGIN

-- Set End Date
ld_end_date := p_daytime;

FOR cur IN c_max_end_date(p_object_id) LOOP
  ld_end_date := cur.end_date;
END LOOP;

-- Enable this if we want to raise an error
IF p_daytime < ld_end_date THEN
  RAISE e_max_end_date;
END IF;


ld_start_date := p_daytime;
FOR cur IN c_daytime(p_object_id, p_daytime) LOOP
  ld_start_date := cur.daytime;
END LOOP;


IF p_daytime < ld_start_date THEN
  RAISE e_max_end_date;
END IF;


update dv_trnp_event_share
set end_date = p_daytime -1
where object_id = p_object_id
and end_date is null
and daytime < p_daytime;


EXCEPTION
  WHEN e_max_end_date THEN
       RAISE_APPLICATION_ERROR(-20566,'Not allowed to insert a record previous to the latest end date ['||ld_end_date||']');

  WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20567,'Unknown error occured in UE.');

END set_end_date;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : copy_prev_values
-- Description    : copy previous values after insert of new existing object
--
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
PROCEDURE copy_prev_values(p_object_id VARCHAR2, p_daytime DATE)

--</EC-DOC>
IS

-- Get the previous date for the nompnt if any
cursor c_prev_nompnt_date( cp_object_id VARCHAR2, cp_daytime DATE) is
select max(daytime) daytime from dv_trnp_event_share
where object_id = cp_object_id
and daytime < cp_daytime;

-- Get the previous valid split value
cursor c_event_share_split(cp_object_id VARCHAR2, cp_nompnt_id VARCHAR2, cp_daytime DATE) is
select * from dv_trnp_event_share_split
where OBJECT_ID = cp_object_id
and NOMPNT_ID = cp_nompnt_id
and daytime = cp_daytime;

-- Get the valid nomination point connections
cursor c_nompnt_connection(cp_object_id VARCHAR2, cp_daytime DATE, cp_bf_profile VARCHAR2) is
select nc.* from nompnt_connection nc, nomination_point np
where nc.object_id = cp_object_id
and nc.daytime <= cp_daytime
and np.object_id = nc.nompnt_id
and np.contract_id in (select c.object_id from ov_contract c where c.bf_profile = cp_bf_profile )
and nvl(nc.end_date, cp_daytime) >= cp_daytime;

cursor c_bf_profile is
select substr(t.component_ext_name,
              instr(t.component_ext_name, 'BF_PROFILE_2') +
              length('BF_PROFILE_2') + 1,
              (instr(t.component_ext_name, '?') -
              instr(t.component_ext_name, 'BF_PROFILE_2')) -
              (length('BF_PROFILE_2') + 1)) bf_profile
  from ctrl_tv_presentation t
 where component_id = 'GD_NOM_SHARE';

cursor c_bf_profile_code is
select * from bf_profile_setup
where bf_code = 'GD.0020';


ls_bf_profile VARCHAR2(2000);

BEGIN

FOR cur_pr IN c_bf_profile_code LOOP
  ls_bf_profile := cur_pr.profile_code;
END LOOP;

FOR cur_bf IN c_bf_profile LOOP
  ls_bf_profile := cur_bf.bf_profile;
    IF ls_bf_profile like '%/%' THEN
       ls_bf_profile := substr(ls_bf_profile,1,instr(ls_bf_profile, '/') -1);

    END IF;

END LOOP;


-- Insert rows for the valid nompnt connection, and copy prev values if any.
FOR cur_con IN c_nompnt_connection(p_object_id, p_daytime, ls_bf_profile) LOOP

  insert into dv_trnp_event_share_split( OBJECT_ID, DAYTIME, NOMPNT_ID)
  values(cur_con.nompnt_id, p_daytime, cur_con.object_id);

  FOR cur_prev IN c_prev_nompnt_date(p_object_id, p_daytime) LOOP
    FOR cur_split IN c_event_share_split(cur_con.nompnt_id, p_object_id ,cur_prev.daytime) LOOP
      update dv_trnp_event_share_split s
      set share_value = cur_split.share_value
      where s.OBJECT_ID = cur_con.nompnt_id
      and s.daytime = p_daytime
      and s.NOMPNT_ID = p_object_id;

    END LOOP;
  END LOOP;
END LOOP;


/*
EXCEPTION
  WHEN OTHERS THEN
       RAISE_APPLICATION_ERROR(-20568,'Unknown error occured in UE.');
*/
END copy_prev_values;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure       : validateShare
-- Description    : Used to validate the sum of share_value to not exceed 100. User exit function.
--
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
PROCEDURE validateShare(
  	p_nompnt_id   VARCHAR2,
    p_daytime     DATE)

--</EC-DOC>
IS

  ln_count NUMBER;
	ln_share_pct  NUMBER;

	cp_nompnt_id VARCHAR2(32);
	cp_daytime DATE;

	CURSOR c_share_pct (cp_nompnt_id VARCHAR2, cp_daytime DATE) IS
		SELECT share_value
		FROM nompnt_share_split
		WHERE nompnt_id = cp_nompnt_id
		AND daytime = cp_daytime
    AND share_value is not null;

BEGIN

  ln_share_pct := 0;
	ln_count :=0;

	cp_nompnt_id := p_nompnt_id;
	cp_daytime := p_daytime;

	FOR sumValue IN c_share_pct(cp_nompnt_id, cp_daytime) LOOP
      ln_count := ln_count + 1;
      ln_share_pct := ln_share_pct + ROUND(Nvl(sumValue.share_value,0),5);
	END LOOP;

	IF ln_share_pct <> 1 AND ln_count <> 0 THEN
		RAISE_APPLICATION_ERROR(-20570,'The sum of share value has to be 100');
	END IF;

END validateShare;

END ue_NOMPNT_SHARE;