CREATE OR REPLACE PACKAGE BODY EcDp_STIM_Util IS
/****************************************************************
** Package        :  EcDp_synchronize_reports
**
** $Revision: 1.6 $
**
** Purpose        :  Infrastructure setup is replicated to report tables
**                   for performance, these report tables need to be updated when the
**                   infrastructure changes, this package takes care of that
**
** Documentation  :  www.energy-components.com
**
** Created  : 08.01.2004  Arild Vervik
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
** 1.2      26.01.04    AV    Added check on STREAM_ITEM_FORMULA, MASTER_UOM_GROUP .. IN syncObjectsAttribute
** 1.3      27.01.04    AV    Increasing count in loop for commit is nice.
** 1.4      28.01.04    AV    Added new procedure MismatchInfraStructMthSync
**          09.02.04    AV    Moved some of the help functions to EcDp_Dynsql
**                            Added new procedure ForceDayValueUpdate
**          19.02.04    AV    Made replication from Objects_attribute and objects_relation
**                            asyncron, introducing changes tables, and moved the update
**                            of the replication tables to Ecdp_reporting_layer, the purpose of this
**                            is to coordinate with the cascade update, to avoid locking when accessing
**                            the same resources.
**          26.02.04    AV    Toke out 2 procedures that should not be part of this release
**          08.03.04    AV    Rewrote ForceDayInfrastructureUpdate using less consuming strategi
**          29.03.04    AV    Changed getSISyncText to use SPLIT_KEY and not SP_SPLIT_KEY in replication
**                            Added more commits in updateMonthTabeles and updateDayTabeles to prevent
**                            deadlock situations
** 1.9      14.04.04    AV    Updated syncObjectsAttribute with Reporting_category
** 1.10     21.04.04    AV    Removed replication of infrastructure to stim_mth_actual, stim_mth_booked
**                            stim_mth_reported and stim_day_actual.
** 1.11     30.04.04    AV    Removed references to infrastructure columns in  stim_day_value
**                            Changed replication logic to pick infrastructure from last day in month
** 1.12     16.06.04    AV    Update of updatecompanyfull removed where criteria on STREAM_ITEM_CATEGORY = FFP
** 1.13     02.07.04    AV    Corrected bug in UpdateDayReportTables filter on column
**          11.10.06    DN    Deleted syncObjectsAttribute.
*****************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : FullUpdate
-- Description    : Force a full update of all the replicated columns in the database
--
--
-- Preconditions  :
-- Postcondition  :

-- Using Tables   :
--
--
--
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE FullUpdate (
 p_scope   varchar2  default NULL,  -- 'DAY', 'MONTH' or NULL (meaning all)
 p_production_period DATE default NULL
)
--</EC-DOC>
IS

   CURSOR c_STIM_MTH_VALUE_daytime IS
   SELECT DISTINCT daytime
   FROM STIM_MTH_VALUE
   ORDER BY daytime;

   ld_year_run  DATE;


BEGIN

     DELETE from t_temptext
     where id = 'REPL_FullUpdate';
     COMMIT;

     EcDp_DynSql.WriteTempText('REPL_FullUpdate','START EcDp_Synchronize_reports.FullUpdate ');

     IF nvl(p_scope,'MONTH') = 'MONTH' THEN

         FOR curMonth IN c_STIM_MTH_VALUE_daytime LOOP

           IF ld_year_run IS NULL OR ld_year_run <> TRUNC(curMonth.daytime,'YYYY') THEN

               ld_year_run := TRUNC(curMonth.daytime,'YYYY');
               EcDp_DynSql.WriteTempText('REPL_FullUpdate',' START YTDForceYearSync FOR '||TO_CHAR(ld_year_run,'dd.mm.yyyy'));
               EcDp_DynSql.WriteTempText('REPL_FullUpdate',' FINISHED YTDForceYearSync FOR '||TO_CHAR(ld_year_run,'dd.mm.yyyy'));

           END IF;

       END LOOP;



     END IF; -- scope month

     EcDp_DynSql.WriteTempText('REPL_FullUpdate',' Finished EcDp_Synchronize_reports.FullUpdate ');

END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : splitString
-- Description    : Split a string with the delimiter supplied and returns a vararry
--
--
-- Using functions:
--
---------------------------------------------------------------------------------------------------
FUNCTION splitString(
  p_text VARCHAR2,
  p_delimiter VARCHAR2
  ) RETURN t_elem
IS

lv2_text VARCHAR2(2000);
lv2_elem VARCHAR2(2000);
ln_pos NUMBER;

ltab_text t_elem := t_elem();

BEGIN

    lv2_text := p_text;

    IF (INSTR(lv2_text, p_delimiter) = 0 ) THEN

        -- Put element into tab
        ltab_text.extend;
        ltab_text(ltab_text.last) := lv2_text;

    ELSE

        WHILE (INSTR(lv2_text, p_delimiter) > 0) LOOP
            ln_pos := INSTR(lv2_text, p_delimiter);

            -- Assign element
            lv2_elem := SUBSTR(lv2_text, 1, ln_pos-1);

            -- Put element into tab
            ltab_text.extend;
            ltab_text(ltab_text.last) := lv2_elem;

            -- Go to next element
            lv2_text := SUBSTR(lv2_text, ln_pos+1);
        END LOOP;

        -- Add the last element
        IF lv2_text IS NOT NULL THEN
            -- Put element into tab
            ltab_text.extend;
            ltab_text(ltab_text.last) := lv2_text;
        END IF;

    END IF;

    RETURN ltab_text;


END splitString;

PROCEDURE SetPendingCalcStatus(
          p_pending_no NUMBER,
          p_period     VARCHAR2,
          p_pos        VARCHAR2 DEFAULT 'STARTING'
)
IS

  lv2_msg VARCHAR2(240);

BEGIN

  IF p_pos = 'STARTING' THEN

    lv2_msg := 'Calculation job queued for execution at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD HH24:MI:SS');

  ELSIF p_pos = 'ENDING' THEN

    lv2_msg := 'Calculation job finished executing at ' || to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD HH24:MI:SS');

  END IF;

  UPDATE stim_pending p SET p.update_job_status = lv2_msg WHERE p.stim_pending_no = p_pending_no AND p.period = p_period;

END SetPendingCalcStatus;



END EcDp_STIM_Util;