CREATE OR REPLACE PACKAGE BODY EcDp_Deferment IS

/****************************************************************
** Package        :  EcDp_Deferment, body part
**
** $Revision: 1.2 $
**
** Purpose        :  This package is responsible for supporting business functions
**                   related to Deferment.
** Documentation  :  www.energy-components.com
**
** Created  : 24.06.2014  Wong Kai Chun
**
** Modification history:
**
** Version  Date       Whom     Change description:
** -------  ----------  -------- --------------------------------------
**          24-06-2014  wonggkai ECPD-28018: Create trigger to populate wells.
**          30-07-2014  wonggkai ECPD-25669: Create insertTempWellDefermntAlloc and deleteTempWellDefermntAlloc for records in temp table TEMP_WELL_DEFERMENT_ALLOC
**                                           Update insertWells() with new cursor c2_getAllEpqmWells
**          24-07-2014  deshpadi ECDP-26044: Create approveWellDeferment function.
**          24-07-2014  deshpadi ECDP-26044: Create verifyWellDeferment
**          24-07-2014  deshpadi ECDP-26044: Create setLossRate
**          24-07-2014  deshpadi ECDP-26044: Create updateReasonCodeForChildEvent
**          24-07-2014  deshpadi ECDP-26044: Create updateEndDateForChildEvent
**          25-07-2014  deshpadi ECDP-26044: Create allocateGroupRateToWells
**          25-07-2014  deshpadi ECDP-26044: Create sumFromWells
**          25-07-2014  deshpadi ECDP-26044: Create updateStartDateForChildEvent
**          26-08-2014  wonggkai ECPD-25669: Update Logic insertWells() for new added object type (EQPM, EQPM CONN, WELL, WHK)
**          27-08-2014  leongwen ECDP-28035: Added procedure allocWellDeferredVolume, modified PROCEDURE setLossRate, allocateGroupRateToWells and sumFromWells.
**          09-09-2014  leongwen ECDP-28035: Added procedure calcDeferments, modified PROCEDURE allocWellDeferredVolume.
**          29-09-2014  wonggkai ECPD-26559: Update Logic insertWells(), cursor c2_getAllEpqmWells, to includes wells cross facility found in screen Allocation Network List
**          03-10-2014  wonggkai ECPD-28956: Update insertWells to allow user configure system attribute to auto insert wells.
**          11-09-2014  deshpadi ECDP-26044: Added procedure updateEventTypeForChildEvent, so that child event has the same event type as that of parent.
**          09-10-2014  deshpadi ECPD-28986: Added procedure updateScheduledForChildEvent, so that child event has the same scheduled value as that of parent.
**          09-10-2014  leongwen ECPD-28796: Modified the allocWellDeferredVolume procedure to calculate the deferment values for a well and period and output to the allocation table
**          17-10-2014  wonggkai ECPD-29028: Modified insertWells filtering date and system attribute DEFERMENT_OVERLAP when insert overlap DOWN event type record.
**          20-10-2014  wonggkai ECPD-29028: Modified insertWells excludes filtered CONSTRAINT event type record.
**          16-10-2014  leongwen ECDP-28993: Modified procedure insertTempWellDefermntAlloc to add parameter iud_action, removed the procedure deleteTempWellDefermntAlloc, added check on
**                                           procedure allocWellDeferredVolume to use LEAST function to compare the current loss_rate with previous row.
**          29-10-2014  kumarsur ECDP-29026: Added procedure checkLockInd and modified allocateGroupRateToWells, approveWellDeferment, approveWellDefermentbyWell, sumFromWells, verifyWellDeferment and verifyWellDefermentbyWell.
**          06-11-2014  wonggkai ECDP-28911: Modified updateReasonCodeForChildEvent to updated reason_code_type_1 to reason_code_type_4
**          09-12-2014  wonggkai ECPD-29261: Added user exit for insertWells
**          06-01-2015  abdulmaw ECPD-29236: Modified checkLockInd to support production day offset locking
**          13-02-2015  wonggkai ECPD-29261: Added uppercase to flag ue_flag.
**          17-02-2015  chaudgau ECPD-29773: Modified updateReasonCodeForChildEvent to support new columns reason_code_5 to reason_code_10
**          09-03-2015  dhavaalo ECPD-29807: Changes to improve Well Deferment Performance. And formatting done.
**          01-04-2015  kumarsur ECPD-29729: Modify insertWells to support swing well and add prev_equal_eventday.
**          17-04-2015  dhavaalo ECPD-29587: Modified allocWellDeferredVolume to include month lock check.
**          20-04-2015  abdulmaw ECPD-29729: Support for Swing Well Scenario
**          30-04-2015  dhavaalo ECPD-30864: Well Deferment : Fail to insert equipment record with error (ORA-01422: exact fetch returns more than requested number of rows)
**          04-05-2015  dhavaalo ECPD-30780: Added User Exit procedure sumFromWells
**          20-01-2015  dhavaalo ECPD-30842: Link to Event/Equipment doesn't show Group Events in Well Deferment by Well
**          18-02-2016  jainnraj ECPD-33854: Modified procedure allocWellDeferredVolume to enable deferment calculation on the start date of the well
**          11-04-2016  dhavaalo ECPD-30780: Support added to enter deferment for equipment ,when eqpm is connected to multiple well.
**          30-05-2016  shindani ECPD-34950: Modified procedure CalcDeferments to support calculation for wells available under selected facility.
**          15-06-2016  dhavaalo ECPD-30301: Deferments are not calculated for start date of well object.
**          04-10-2016  dhavaalo ECPD-30185: Modified insertWells to update loss rate volume for child records. Modified setLossRate to support deferment type as 'GROUP_CHILD'
**          04-10-2016  dhavaalo ECPD-31944: fun_Constraint_hrs Added to calculate non overlaapping hours between down and constraint events. Modified allocWellDeferredVolume.
**          04-10-2016  dhavaalo ECPD-31944: Modified allocWellDeferredVolume to add potential value check.Comments added for logic.
**          16-11-2016  dhavaalo ECPD-31944: Modified allocWellDeferredVolume. Support added if potential of well is NULL.
**          23-11-2016  dhavaalo ECPD-31944: Modified allocWellDeferredVolume,fun_Constraint_hrs and reCalcDeferments. For open event,calculate loss till sysdate.
**          03-01-2017  dhavaalo ECPD-42283: Modified fun_Constraint_hrs -added trunc to result variable.
**          24.01.2017  jainnraj ECPD-42731: Modified updateStartDateForChildEvent and updateEndDateForChildEvent to update child records startdate/enddate correctly after updating event's startdate/enddate.
**          03-01-2017  dhavaalo ECPD-42735: Modified fun_Constraint_hrs to handle 1 min issue.
**          03-01-2017  dhavaalo ECPD-42430: Temp data is not getting inserted into table TEMP_WELL_DEFERMENT_ALLOC which is input table for deferment calc.Modified insertWells procedure.
**          03-03-2017  dhavaalo ECPD-42673: Modified insertWells to add wells automatically when user insert record for well hookup.
**          20-03-2017  dhavaalo ECPD-42995: Deferment: Remove reference to PD.0020 in order to run calculation.Modified calcDeferments and reCalcDeferments
**          27-03-2017  dhavaalo ECPD-44149: EcDp_Deferment.reCalcDeferments improvements
**          13-04-2017  chaudgau ECPD-41164: Modified insertWells procedure to support auto insertion of well as child event for FCTY_CLASS_2 downtime.
**          18-05-2017  leongwen ECPD-43801: Modified procedures calcDeferments and reCalcDeferments to perform the calculations that the navigation can stop at any level in the navigator, also modified procedure allocWellDeferredVolume
**                                           to process the calculation even with any missing system days.
**          18.07.2017  kashisag ECPD-45817: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
**          24-07-2017  kashisag ECPD-43591: Added User Exit call to procedure allocateGroupRateToWells
**          07.08.2017  jainnraj ECPD-46835: Modified procedure sumFromWells,setLossRate to correct the error message.
**          01.09.2017  dhavaalo ECPD-48425: Modified fun_Constraint_hrs to findConstraintHrs. Modified allocWellDeferredVolume to fix daylight issue.
**          01.09.2017  dhavaalo ECPD-48377: Modified calcDeferments to fix negative value issues.
**          27.09.2017  dhavaalo ECPD-48637: Modified allocWellDeferredVolume to support daylight for deferment event.
**          12.10.2017  leongwen ECPD-49613: Added procedure verifyDefermentDayEvent and approveDefermentDayEvent
**          27-10-2017  kashisag ECPD-50026: Modified procedures and functions that are using the condition check with well_deferment table with extra condition to check with class_name is equal to WELL_DEFERMENT , WELL_DEFERMENT_CHILD. 
**          27.10.2017  dhavaalo ECPD-50208: Allocate to Wells button is not triggering temp data to insert into temp_well_deferment_alloc.
**          03.11.2017  leongwen ECPD-50437: Modified procedure verifyDefermentDayEvent to add the class_name with DEFERMENT_EVENT.
**          14.11.2017  chaudgau ECPD-50458: updateEndDateForChildEvent has been modified to handle NULL value input
**          14.11.2017  leongwen ECPD-50863: Modified procedure insertWells to skip the child well object where it has the deferred event at different daytime but overlapped with the current deferred event.
**          17.11.2017  dhavaalo ECPD-45043: Remove reference of well_equip_downtime.Remove un-used variable.
**          12.01.2018  leongwen ECPD-51978: Modified the procedure insertwells to fix the problem of not inserting wells with fcty_class_2 group. Also, fixed the runtime error when inserting wells with equipment on lv2_op_group_object_id.
**          16-01-2018  singishi ECPD-47302: Renamed all instances of table Well_deferment to deferment_event
**          09-02-2018  leongwen ECPD-52636: Moved procedures changeDefermentDay, deleteDefermentDay and AddRowsAtDefDayTable and function getSumLossMassDefDay from old EcDp_Deferment_Event package to this package.
**          08-02-2018  leongwen ECPD-45873: Modified procedure allocateGroupRateToWells, sumFromWells, setLossRate and allocWellDeferredVolume to include the logic to calculate the oil_loss_mass, gas_loss_mass, cond_loss_mass and water_loss_mass.
**          10.04.2018  leongwen ECPD-54613: Modified procedure reCalcDeferments and calcDeferments to handle other well objects belonged to different facility but connected to the equipment on the same facility.
**          29-04-2018  leongwen ECPD-55161: Modified procedure updateEndDateForChildEvent and updateStartDateForChildEvent with additional parameters and calcDeferments to support deferment recalculation on modified dates.
**          30.04.2018  kaushaak ECPD-54548: Journal does not capture for child events when parent is end dated even when journal rule syntax is true for the well_deferment_child class.
**          04-05-2018  khatrnit ECPD-55592: Modified function reCalcDeferments to support calculation of event loss for deferment when equipment's end date and deferment end date are null.
**          06.06.2018  kashisag ECPD-51971: Updated allocateGroupRateToWells to consider the loss rate at group level
**          19-06-2018  leongwen ECPD-56917: Added procedure reuseOverlappedRecords to insert the overlapped record again to the table temp_well_deferment_alloc for recalculation after deletion or modification on the existing event overlapped with others.
**          19-06-2018  leongwen ECPD-56917: Modified procedure insertTempWellDefermntAlloc to check and append the unique event no for recalculation only for better performance.
**                                           Modified procedure reCalcDeferments and procedure allocWellDeferredVolume to use order by daytime asc to fix inconsistent event loss after reinserted the same event due to cursor order by event_no, the reinserted event will have larger event_no with smaller start daytime, and also
**                                           to enhance exception handler not to suppress the exception by returning null to return the appropriate error message.
**                                           Modified procedure updateEndDateForChildEvent and updateStartDateForChildEvent to remove the logic to execute the procedure EcDp_Deferment.insertTempWellDefermntAlloc since other ECPD-54548 has changed to update data class, and its data class trigger already performed this procedure call.
**                                           Modified procedure allocWellDeferredVolume to fix negative event loss on the future open-ended event overlapped with the future ended event, and also 
**                                           to fix the problem of not able to calculate the modified child event with smaller start daytime or end daytime by using the trunc(p_from_date) and trunc(p_to_date) as the event days range for recalculation,
**                                           to stop using the condition check with system_days and well_object end date, and refactor on all instances to use cur_event_day instead of cur_prod_day, 
**                                           to enhance using the specific ln_rowcount to check record exists at target allocation table instead of sharing the ln_count,
**                                           to maintain the consistent event loss for open-ended event being alone or overlapped with other events, event loss will be calculated as at previous system date. (current system date minus one day).
**          01-09-2018  leongwen ECPD-56917: Modified procedure allocWellDeferredVolume and added t_basis_language support to display the proper error message.
**          04-09-2018  mehtajig ECPD-36644: Added parameter to reCalcDeferments procedure and added insert updaate statments for log table
**          25-09-2018  leongwen ECPD-59576: Modified procedure reCalcDeferments to support the open events with deferment event loss calculation continuously for everyday when the event end date is null.
**          01-10-2018  leongwen ECPD-59859: Modified procedure allocWellDeferredVolume to take potential rate if the loss rate is null.
**          05-10-2018  mehtajig ECPD-36644: removing parameter from reCalcDeferments procedure and moved IUD statementes for logs into EcDp_Deferment_Log package
**          16-10-2018  kaushaak ECPD-59504: Modified setLossRate.
**          10-12-2018  bagdeswa ECPD-61991: Modified procedure allocateGroupRateToWells not to check against the parent_daytime
**          21-12-2018  leongwen ECPD-56158: Implement the similar Deferment Calculation Logic from PD.0020 to Forecast Event PP.0047
**                                           Revised the incorrect description and indentation for readability
**          11-04-2019  leongwen ECPD-65709: Modified procedure allocWellDeferredVolume to use production day with cursor c_event_days. 
**          11-04-2019  leongwen ECPD-65918: Modified procedure setLossRate to use day, daytime and end_date to calculate loss rate instead of using day alone.
**          11-04-2019  leongwen ECPD-65921: Modified the procedure reuseOverlappedRecords to fine tune the associative arrays extension to avoid DB PGA memory used by the instance exceeds PGA_AGGRGATE_LIMIT 
****************************************************************************************/

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : findConstraintHrs
-- Description    : The Function populate non overlapping hours from Down and Constraints events.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
FUNCTION findConstraintHrs(cp_day DATE, cp_start_daytime DATE,p_object_id VARCHAR2,p_temp_end_Date date,p_temp_start_Date date,p_open_end_event VARCHAR2)
RETURN number IS

  CURSOR c_well_down_deferment_open (cp_day DATE, cp_start_daytime DATE) IS
  SELECT GREATEST(wd.daytime, cp_start_daytime) start_date, -- start_date is minimum start of production day to calc correct duration
         LEAST(NVL(wd.end_date,TO_DATE(TO_CHAR(Ecdp_Timestamp.getCurrentSysdate,'YYYY-MM-DD"T"HH24:MI'),'YYYY-MM-DD"T"HH24:MI')), cp_start_daytime+1) end_date -- end_date can be maximum end of production day to calc correct duration
  FROM deferment_event wd
  WHERE wd.object_id = p_object_id
  AND (wd.day = TRUNC(cp_day) OR
      (wd.day < TRUNC(cp_day) AND (wd.end_day IS NULL OR wd.end_day >= TRUNC(cp_day))))
  AND GREATEST(wd.daytime, cp_start_daytime)<=p_temp_end_Date
  AND LEAST(NVL(wd.end_date,TRUNC(Ecdp_Timestamp.getCurrentSysdate,'DD')), cp_start_daytime+1)>=p_temp_start_Date
  AND wd.event_type='DOWN'
  AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD')
  ORDER BY 2; -- Sort_event_type must come first than the asset type because the Downtime/Off events take the precedence!

  CURSOR c_well_down_deferment_close (cp_day DATE, cp_start_daytime DATE) IS
  SELECT GREATEST(wd.daytime, cp_start_daytime) start_date, -- start_date is minimum start of production day to calc correct duration
         LEAST(NVL(wd.end_date,TO_DATE(TO_CHAR(Ecdp_Timestamp.getCurrentSysdate,'YYYY-MM-DD"T"HH24:MI'),'YYYY-MM-DD"T"HH24:MI')), cp_start_daytime+1) end_date -- end_date can be maximum end of production day to calc correct duration
  FROM deferment_event wd
  WHERE wd.object_id = p_object_id
  AND wd.day <= TRUNC(cp_day) AND wd.end_day >= TRUNC(cp_day)
  AND GREATEST(wd.daytime, cp_start_daytime)<=p_temp_end_Date
  AND LEAST(wd.end_date, cp_start_daytime+1)>=p_temp_start_Date
  AND wd.event_type='DOWN'
  AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD')
  ORDER BY 2; -- Sort_event_type must come first than the asset type because the Downtime/Off events take the precedence!
 
  ld_input_start_Date   DATE;
  ld_input_end_Date     DATE;
  ld_process_date_start DATE;
  ld_process_date_end   DATE;
  ld_temp_result_date   DATE;
  ln_result             NUMBER;
  ln_one_minute         NUMBER;

  TYPE string_asc_arr_t IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
  lr_array string_asc_arr_t;

BEGIN
  ld_input_start_Date := p_temp_start_Date;
  ld_input_end_Date   := p_temp_end_Date;
  ln_one_minute:=1/1440;

  ld_temp_result_date:=trunc(Ecdp_Timestamp.getCurrentSysdate);--dummy date used while calulating no of hours from two dates.

  --create array for downtime hours in hours:minute format
  --Array populated as lr_array('00:00')=1 , lr_array('00:01')=1 , lr_array('00:03')=1 ....lr_array('nn:nn')=1  
  IF(p_open_end_event='Y')THEN
    FOR cur_down_event_open IN c_well_down_deferment_open(cp_day, cp_start_daytime) LOOP
      
      ld_process_date_start:=cur_down_event_open.start_date;
      
      IF (cur_down_event_open.end_Date>=p_temp_end_Date) THEN
        ld_process_date_end:=p_temp_end_Date;
      ELSE
        ld_process_date_end:=cur_down_event_open.end_Date;
      END IF;
    
      WHILE((ld_process_date_end-ln_one_minute) >= ld_process_date_start) LOOP
        lr_array(TO_CHAR(ld_process_date_start,'HH24:MI')):=1;
        ld_process_date_start:=ld_process_date_start+ln_one_minute;
      END LOOP;
    
    END LOOP;
  
  ELSIF(p_open_end_event='N') THEN
  
    FOR cur_down_event_close IN c_well_down_deferment_close(cp_day, cp_start_daytime) LOOP
     
      ld_process_date_start:=cur_down_event_close.start_date;
     
      IF (cur_down_event_close.end_Date>=p_temp_end_Date) THEN
        ld_process_date_end:=p_temp_end_Date;
      ELSE
        ld_process_date_end:=cur_down_event_close.end_Date;
      END IF;
    
      WHILE((ld_process_date_end-ln_one_minute) >= ld_process_date_start) LOOP
        lr_array(TO_CHAR(ld_process_date_start,'HH24:MI')):=1;
        ld_process_date_start:=ld_process_date_start+ln_one_minute;
      END LOOP;
  
    END LOOP;
  END IF;  

  WHILE((ld_input_end_Date-ln_one_minute) >= ld_input_start_Date) LOOP
  
    IF ( lr_array.EXISTS(TO_CHAR(ld_input_start_Date,'HH24:MI')) ) THEN --hrs:min matched with constraint hrs:min then do nothing as it it overlaapping hrs.
      NULL;
    ELSE--hrs:min not matched with constraint hrs:min then add it to dummy date to find non-overlapping hrs.
      ld_temp_result_date:=ld_temp_result_date+ln_one_minute;--find number of non-overlapping hours from down and constraint events.
    END IF;
 
    ld_input_start_Date:=ld_input_start_Date+ln_one_minute;
   
  END LOOP;

  ln_result:=(ld_temp_result_date-TRUNC(Ecdp_Timestamp.getCurrentSysdate));
  RETURN ln_result;
END findConstraintHrs ;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertWells
-- Description    : The Procedure populate wells which are not long term closed upon creation of a new group deferment event.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE insertWells(p_group_event_no number, p_event_type VARCHAR2, p_object_typ VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE DEFAULT NULL, p_username VARCHAR2 )
--</EC-DOC>
IS

  lv2_defer_overlap_flag         VARCHAR2(2000);
  lv2_defer_autoinsert_flag      VARCHAR2(2000);
  ue_flag CHAR;

  CURSOR c1_network (cp_object_id VARCHAR2) IS
  SELECT max(cce.object_id) AS object_id
  FROM calc_collection_element cce, calc_collection c
  WHERE c.object_id = cce.object_id
  AND c.class_name= 'ALLOC_NETWORK'
  AND cce.element_id = cp_object_id;

  CURSOR c1_eqpm_network IS
  SELECT max(cce.object_id) AS object_id
  FROM calc_collection_element cce
  INNER JOIN calc_collection c ON c.object_id = cce.object_id
  INNER JOIN ov_eqpm eqpm ON cce.element_id = eqpm.alloc_netw_node_id
  WHERE c.class_name= 'ALLOC_NETWORK'
  AND eqpm.object_id = p_object_id;

  lv2_getOverlappingWellsStr       VARCHAR2(4000);
  
  lv2_getAllWellsStr               VARCHAR2(20000);
  lv2_getAllWellsStr1              VARCHAR2(4000);
  lv2_getAllWellsStr2              VARCHAR2(4000);
  lv2_getAllWellsStr3              VARCHAR2(4000);
  lv2_getAllWellsStr4              VARCHAR2(4000);
  
  lv2_getAllEqpmConnWellsStr       VARCHAR2(20000);
  lv2_getAllEqpmConnWellsStr1      VARCHAR2(4000);
  lv2_getAllEqpmConnWellsStr2      VARCHAR2(4000);

  lv2_getAllEqpmWellsStr           VARCHAR2(20000);
  lv2_getAllEqpmWellsStr1          VARCHAR2(4000);
  lv2_getAllEqpmWellsStr2          VARCHAR2(4000);
  
  lv2_getAllTankWellsStr           VARCHAR2(20000);
  lv2_getAllTankWellsStr1          VARCHAR2(4000);
  
  lv2_skipOnlyEventTypeStr         VARCHAR2(200);
  lv2_TargetEventTypeStr           VARCHAR2(200);
  lv2_TargetDeferOverlapFlagStr    VARCHAR2(200); 
              
  rc_c2_getAllWellRec          SYS_REFCURSOR;            
  rc_c2_getAllEqpmConnWellsRec SYS_REFCURSOR; 
  rc_c2_getAllEqpmWellsRec SYS_REFCURSOR;  
  rc_c2_getAllTankWellsRec SYS_REFCURSOR;
  

  CURSOR c3_getWellVersions (cp_object_id VARCHAR2, cp3_object_id VARCHAR2, cp3_daytime DATE, cp3_end_date DATE) IS
  SELECT a.daytime, a.end_date
  FROM well_version a
  WHERE a.object_id = cp3_object_id
  AND a.daytime BETWEEN ec_well_version.prev_equal_daytime(a.object_id, cp3_daytime)
  AND ec_well_version.prev_equal_daytime(a.object_id, nvl(cp3_end_date, Ecdp_Timestamp.getCurrentSysdate))
  AND ( a.OP_FCTY_CLASS_1_ID = cp_object_id or
        a.OP_FCTY_CLASS_2_ID = cp_object_id or
        a.OP_WELL_HOOKUP_ID  = cp_object_id or
        a.OP_AREA_ID         = cp_object_id )
  ORDER BY a.daytime;

  CURSOR c_getChildRecords IS
  SELECT wde.event_no
  FROM deferment_event wde
  WHERE wde.parent_event_no = p_group_event_no
  AND wde.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  
  CURSOR c_getFC1List (cp_object_id VARCHAR2,  cp_daytime DATE, cp_end_date DATE) IS
  SELECT fv.object_id,fv.daytime, fv.end_date
  FROM fcty_version fv
  WHERE fv.op_fcty_class_2_id = cp_object_id
  AND fv.daytime BETWEEN ec_fcty_version.prev_equal_daytime(fv.object_id, cp_daytime)
  AND ec_fcty_version.prev_equal_daytime(fv.object_id, nvl(cp_end_date, Ecdp_Timestamp.getCurrentSysdate));

  ln_group_event_no             NUMBER;
  ln_WellVersions_cnt           NUMBER;
  ln_Rowcnt                     NUMBER;
  lc_eqpm_conn                  CHAR;
  lv2_op_group_object_id        VARCHAR2(32);                             -- Variable used for "EQPM" object_type

  lv2_alloc_netwk_id_c1         VARCHAR2(32);                             -- Variable  used for holding "c1_..." cursor value

  lv2_object_id_c2              deferment_event.OBJECT_ID%TYPE;            -- Variables used for holding "c2_..." cursor value
  lv2_object_type_c2            deferment_event.OBJECT_TYPE%TYPE;
  ln_parent_event_no_c2         deferment_event.PARENT_EVENT_NO%TYPE;
  lv2_parent_object_id_c2       deferment_event.PARENT_OBJECT_ID%TYPE;
  ld_parent_daytime_c2          deferment_event.PARENT_DAYTIME%TYPE;
  ld_daytime_c2                 deferment_event.DAYTIME%TYPE;
  ld_end_date_c2                deferment_event.END_DATE%TYPE;
  lv2_event_type_c2             deferment_event.EVENT_TYPE%TYPE;
  lv2_deferment_type_c2         deferment_event.DEFERMENT_TYPE%TYPE;
  lv2_created_by_c2             deferment_event.CREATED_BY%TYPE;

  ld_daytime_c3                 DATE;                                           -- Variables used for holding "c3_..." cursor value
  ld_end_date_c3                DATE;
  lv2_prev_object_id            VARCHAR2(32);
  ln_tmp_event_no               DEFERMENT_EVENT.EVENT_NO%TYPE;
  lv2_replaced_fcty1_id         FCTY_VERSION.OBJECT_ID%TYPE;
  lv2_replaced_cce_id           CALC_COLLECTION_ELEMENT.OBJECT_ID%TYPE;

  typ_object_id                 t_object_id                   := t_object_id();
  typ_object_type               t_object_type                 := t_object_type();
  typ_parent_event_no           t_parent_event_no             := t_parent_event_no();
  typ_parent_object_id          t_parent_object_id            := t_parent_object_id();
  typ_parent_daytime            t_parent_daytime              := t_parent_daytime();
  typ_daytime                   t_daytime                     := t_daytime();
  typ_end_date                  t_end_date                    := t_end_date();
  typ_event_type                t_event_type                  := t_event_type();
  typ_deferment_type            t_deferment_type              := t_deferment_type();
  typ_created_by                t_created_by                  := t_created_by();
  ln_connection_count            NUMBER:=0;
  TYPE rec_deferment IS RECORD (
                                event_no NUMBER,
                                parent_event_no NUMBER,
                                daytime DATE,
                                end_date DATE);
  TYPE T_DEFERMENT IS TABLE OF rec_deferment;
  typ_deferment T_DEFERMENT :=T_DEFERMENT();

BEGIN
  ue_Deferment.insertWells(p_group_event_no, p_event_type, p_object_typ, p_object_id, p_daytime, p_end_date, p_username, ue_flag );
  IF (upper(ue_flag) = 'N') THEN
    SELECT default_value INTO lv2_defer_autoinsert_flag
    FROM (
      SELECT default_value FROM (
        SELECT default_value_string default_value, to_date('01-01-1900', 'DD-MM-YYYY') daytime FROM ctrl_property_meta WHERE key = 'DEFERMENT_AUTOINSERT'
        UNION ALL
        SELECT value_string, daytime FROM ctrl_property WHERE key = 'DEFERMENT_AUTOINSERT' ORDER BY daytime DESC
      )ORDER BY daytime DESC
    ) WHERE rownum < 2;
    IF lv2_defer_autoinsert_flag = 'N' THEN
      RETURN;
    END IF;
    SELECT default_value into lv2_defer_overlap_flag from (
      SELECT default_value from (
        SELECT default_value_string default_value, to_date('01-01-1900', 'DD-MM-YYYY') daytime FROM ctrl_property_meta where key = 'DEFERMENT_OVERLAP'
        UNION ALL
        SELECT value_string, daytime from ctrl_property where key = 'DEFERMENT_OVERLAP' order by daytime desc
      )ORDER BY daytime desc
    ) WHERE rownum < 2;
    
    IF lv2_defer_overlap_flag IN ('N', 'Y') THEN
      lv2_skipOnlyEventTypeStr      := '(''' || 'CONSTRAINT' || ''', ''' || 'DOWN' || ''')'; -- ('CONSTRAINT', 'DOWN')
      lv2_TargetEventTypeStr        := '(''' || 'CONSTRAINT' || ''', ''' || 'DOWN' || ''')'; -- ('CONSTRAINT', 'DOWN')
      lv2_TargetDeferOverlapFlagStr := '(''' || 'N' || ''')'; -- ('N');
    ELSIF lv2_defer_overlap_flag = 'CONSTRAINT' THEN  
      IF p_event_type = 'CONSTRAINT' THEN
         lv2_skipOnlyEventTypeStr      := '(''' || 'DOWN' || ''')';
      ELSIF p_event_type = 'DOWN' THEN
         lv2_skipOnlyEventTypeStr      := '(''' || 'CONSTRAINT' || ''', ''' || 'DOWN' || ''')';
      END IF;
      lv2_TargetEventTypeStr        := '(''' || 'CONSTRAINT' || ''', ''' || 'DOWN' || ''')';
      lv2_TargetDeferOverlapFlagStr := '(''' || 'CONSTRAINT' || ''')'; 
    ELSIF lv2_defer_overlap_flag = 'DOWN_CONSTRAINT' THEN  
      lv2_defer_overlap_flag        := 'DOWN';                                     -- reset it to compare with lv2_TargetDeferOverlapFlagStr
      lv2_skipOnlyEventTypeStr      := '(''' || 'DOWN' || ''')'; 
      lv2_TargetEventTypeStr        := '(''' || 'DOWN' || ''')';
      lv2_TargetDeferOverlapFlagStr := '(''' || 'DOWN' || ''')';
    END IF;  
    
    ln_group_event_no := p_group_event_no;
    lc_eqpm_conn := 'N';
    ln_Rowcnt := 0;
    IF p_object_typ = 'EQPM' THEN
      SELECT COUNT(*) INTO ln_connection_count
      FROM EQPM_CONN
      WHERE object_id = p_object_id
      AND eqpm_conn_class = 'WELL'
      AND daytime <= p_daytime AND Nvl(end_date,Ecdp_Timestamp.getCurrentSysdate) >= Nvl(p_end_date,Ecdp_Timestamp.getCurrentSysdate);
      IF (ln_connection_count!=0) THEN
        lc_eqpm_conn := 'Y';
      ELSE
        lc_eqpm_conn := 'N';
      END IF;
    END IF;
    IF p_object_typ = 'FCTY_CLASS_1' OR p_object_typ = 'WELL_HOOKUP' THEN
      FOR mycur IN c1_network(p_object_id) LOOP
        lv2_alloc_netwk_id_c1 := mycur.object_id;
      END LOOP;
    ELSIF p_object_typ = 'EQPM' AND lc_eqpm_conn = 'N' THEN
      BEGIN
        SELECT ALLOC_NETW_NODE_ID INTO lv2_op_group_object_id
        FROM (SELECT ALLOC_NETW_NODE_ID
              FROM ov_eqpm
              WHERE object_id = p_object_id
              AND daytime <= p_daytime
              ORDER BY DAYTIME DESC)
        WHERE ROWNUM < 2;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        RETURN;
      END;
      FOR mycur IN c1_eqpm_network LOOP
        lv2_alloc_netwk_id_c1 := mycur.object_id;
      END LOOP;
    END IF;

    -- handle Facility group event
    lv2_getAllWellsStr1 := 
    'SELECT distinct w.object_id, ''' || 'WELL' || ''', ' || p_group_event_no || ', ''' || p_object_id || ''', to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || ', ' || 'GREATEST(w.start_date, to_date(''' || to_char(p_daytime , 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), LEAST(nvl(w.end_date,
    to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), ''' || p_event_type || ''', ''' || 'GROUP_CHILD' || ''', ''' || p_username || '''' || '
    FROM well w, well_version wv, well_swing_connection sc
    WHERE w.object_id = wv.object_id
    AND w.object_id = sc.object_id(+)
    AND wv.alloc_flag = ''' || 'Y' || '''-- only include wells that are part of allocation network
    AND ((wv.daytime BETWEEN ec_well_version.prev_equal_daytime(wv.object_id, to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')) ' || '
    AND ec_well_version.prev_equal_daytime(wv.object_id, nvl( to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'') ' || ', Ecdp_Timestamp.getCurrentSysdate))';
    
    lv2_getAllWellsStr2 := 'AND ( wv.OP_FCTY_CLASS_1_ID       = ''' || p_object_id || ''' or
          wv.OP_FCTY_CLASS_2_ID       = ''' || p_object_id || ''' or
          wv.OP_WELL_HOOKUP_ID        = ''' || p_object_id || ''' or
          wv.OP_AREA_ID               = ''' || p_object_id || '''  ))
          or (sc.event_day BETWEEN ecdp_deferment.prev_equal_eventday(wv.object_id, ecdp_productionday.getproductionday(NULL, wv.object_id, to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'') )) ' || '
          AND ecdp_deferment.prev_equal_eventday(wv.object_id, nvl(ecdp_productionday.getproductionday(NULL, wv.object_id, to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')),  Ecdp_Timestamp.getCurrentSysdate))
          AND ( sc.asset_id = ''' || p_object_id || ''')))';
    
    lv2_getAllWellsStr3 := 'AND w.object_id NOT IN (
                  SELECT object_id
                  FROM WELL_SWING_CONNECTION wsc
                  WHERE wsc.object_id = w.object_id
                  AND wsc.event_day = (SELECT MAX(wsc1.event_day)
                                      FROM WELL_SWING_CONNECTION wsc1
                                      WHERE wsc1.event_day <= ecdp_productionday.getproductionday(NULL, wv.object_id, to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')) ' || '
                                      AND wsc1.object_id = wsc.object_id)
                  AND wsc.asset_id <> ''' || p_object_id || ''')';
                  
    lv2_getAllWellsStr4 := 'AND EXISTS (SELECT 1
                FROM calc_collection_element cce, calc_collection c
                WHERE c.object_id = cce.object_id
                AND c.class_name= ''' || 'ALLOC_NETWORK' || '''
                AND (sc.asset_id = cce.element_id OR wv.op_well_hookup_id = cce.element_id OR wv.op_fcty_class_1_id = cce.element_id OR wv.op_fcty_class_2_id = cce.element_id)
                AND cce.element_id in (SELECT DISTINCT from_node_id FROM ov_stream START WITH from_node_id = ''' || p_object_id || '''
                                       CONNECT BY NOCYCLE PRIOR from_node_id=to_node_id
                                       UNION
                                       SELECT DISTINCT to_node_id FROM ov_stream START WITH to_node_id = ''' || p_object_id || '''
                                       CONNECT BY NOCYCLE PRIOR to_node_id=from_node_id)
                AND cce.object_id = ''' || lv2_alloc_netwk_id_c1 || ''') -- Alloc network id';
    
    lv2_getOverlappingWellsStr := 'AND NOT EXISTS (SELECT wd.object_id  -- exclude wells already down depending on the NOT EXISTS keyword, otherwise, it will allow all deferments.
                    FROM deferment_event wd
                    WHERE wd.object_id = w.object_id
                    AND   wd.EVENT_TYPE IN ' || lv2_skipOnlyEventTypeStr || '
                    AND ''' || p_event_type || ''' IN ' || lv2_TargetEventTypeStr || '
                    AND ''' || lv2_defer_overlap_flag || ''' IN ' || lv2_TargetDeferOverlapFlagStr || '
                    AND wd.DEFERMENT_TYPE in (''' || 'SINGLE' || ''', ''' || 'GROUP_CHILD''' || ')
                    AND wd.class_name IN (''' || 'WELL_DEFERMENT' || ''', ''' || 'WELL_DEFERMENT_CHILD''' || ')
                    AND Nvl(wd.end_date,Ecdp_Timestamp.getCurrentSysdate) >= to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS')||''' , ''YYYY-MM-DD"T"HH24:MI:SS'') 
                    AND wd.daytime <= Nvl( to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS')||''' , ''YYYY-MM-DD"T"HH24:MI:SS''), Ecdp_Timestamp.getCurrentSysdate))
    ORDER BY w.object_id';    
    
    lv2_getAllWellsStr := lv2_getAllWellsStr1 ||CHR(13)||''||CHR(10)|| lv2_getAllWellsStr2 ||CHR(13)||''||CHR(10)|| lv2_getAllWellsStr3 ||CHR(13)||''||CHR(10)|| lv2_getAllWellsStr4 ||CHR(13)||''||CHR(10)|| lv2_getOverlappingWellsStr;
    
    -- to handle Equipment Group Event with Equipment Connection
    lv2_getAllEqpmConnWellsStr1 := 
    'SELECT w.object_id, ''' || 'WELL' || ''', ' || p_group_event_no|| ', ''' || p_object_id || ''', to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || ', ' || 'GREATEST(w.start_date, to_date(''' || to_char(p_daytime , 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), 
    LEAST(nvl(w.end_date,to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), ''' || p_event_type || ''', ''' || 'GROUP_CHILD' || ''', ''' || p_username || '''' || '
    FROM well w, well_version wv
    WHERE w.object_id = wv.object_id
    AND wv.daytime BETWEEN ec_well_version.prev_equal_daytime(wv.object_id, to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')) ' || '
    AND ec_well_version.prev_equal_daytime(wv.object_id, nvl( to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'') ' || ', Ecdp_Timestamp.getCurrentSysdate))';
    
    lv2_getAllEqpmConnWellsStr2 := 
    'AND EXISTS (SELECT 1 FROM eqpm_conn
                WHERE object_id = ''' || p_object_id || '''
                AND daytime <= to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'')
                AND Nvl(end_date,Ecdp_Timestamp.getCurrentSysdate) >= Nvl( to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'') ' || ', Ecdp_Timestamp.getCurrentSysdate)
                AND eqpm_conn_name = w.object_id)';
        
    lv2_getAllEqpmConnWellsStr  := lv2_getAllEqpmConnWellsStr1 ||CHR(13)||''||CHR(10)|| lv2_getAllEqpmConnWellsStr2 ||CHR(13)||''||CHR(10)|| lv2_getOverlappingWellsStr;
    
    -- to handle Equipment group event
    lv2_getAllEqpmWellsStr1 :=
    'SELECT w.object_id, ''' || 'WELL' || ''', ' || p_group_event_no|| ', ''' || p_object_id || ''', to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || ', ' || 'GREATEST(w.start_date, to_date(''' || to_char(p_daytime , 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), 
    LEAST(nvl(w.end_date,to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), ''' || p_event_type || ''', ''' || 'GROUP_CHILD' || ''', ''' || p_username || '''' || '
    FROM well w, well_version wv
    WHERE w.object_id = wv.object_id
    AND wv.alloc_flag = ''' || 'Y' || ''' -- only include wells that are part of allocation network
    AND wv.daytime BETWEEN ec_well_version.prev_equal_daytime(wv.object_id, to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')) ' || '
    AND ec_well_version.prev_equal_daytime(wv.object_id, nvl( to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'') ' || ', Ecdp_Timestamp.getCurrentSysdate))';
    
    lv2_getAllEqpmWellsStr2 :=
    'AND EXISTS (SELECT 1
              FROM calc_collection_element cce, calc_collection c
              WHERE c.object_id = cce.object_id
              AND c.class_name= ''' || 'ALLOC_NETWORK' || '''
              AND (wv.op_well_hookup_id = cce.element_id OR wv.op_fcty_class_1_id = cce.element_id OR wv.op_fcty_class_2_id = cce.element_id)
              AND cce.element_id in (SELECT DISTINCT from_node_id FROM ov_stream START WITH from_node_id = ''' || lv2_op_group_object_id || '''
                                     CONNECT BY NOCYCLE PRIOR from_node_id=to_node_id))';
    
    lv2_getAllEqpmWellsStr := lv2_getAllEqpmWellsStr1 ||CHR(13)||''||CHR(10)|| lv2_getAllEqpmWellsStr2 ||CHR(13)||''||CHR(10)|| lv2_getOverlappingWellsStr;
    
    lv2_getAllTankWellsStr1 :=
    'SELECT w.object_id, ''' || 'WELL' || ''', ' || p_group_event_no|| ', ''' || p_object_id || ''', to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || ', ' || 'GREATEST(w.start_date, to_date(''' || to_char(p_daytime , 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), 
    LEAST(nvl(w.end_date,to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'')' || '), ''' || p_event_type || ''', ''' || 'GROUP_CHILD' || ''', ''' || p_username || '''' || '
    FROM tank t
    INNER JOIN tank_version tv on tv.object_id = t.object_id
    INNER JOIN well w on w.object_id = tv.tank_well
    INNER JOIN well_version wv on wv.object_id = w.object_id
    WHERE t.object_id = ''' || p_object_id || '''
    AND wv.daytime BETWEEN ec_well_version.prev_equal_daytime(wv.object_id, to_date(''' || to_char(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS') ||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')) ' || '
    AND ec_well_version.prev_equal_daytime(wv.object_id, nvl( to_date(''' || to_char(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS') || ''' , ''YYYY-MM-DD"T"HH24:MI:SS'') ' || ', Ecdp_Timestamp.getCurrentSysdate))';
    
    lv2_getAllTankWellsStr := lv2_getAllTankWellsStr1  ||CHR(13)||''||CHR(10)|| lv2_getOverlappingWellsStr;
                                     

    IF p_object_typ = 'EQPM' AND lc_eqpm_conn = 'Y' THEN
      OPEN rc_c2_getAllEqpmConnWellsRec FOR lv2_getAllEqpmConnWellsStr;
      LOOP
        FETCH rc_c2_getAllEqpmConnWellsRec INTO
          lv2_object_id_c2,
          lv2_object_type_c2,
          ln_parent_event_no_c2,
          lv2_parent_object_id_c2,
          ld_parent_daytime_c2,
          ld_daytime_c2,
          ld_end_date_c2,
          lv2_event_type_c2,
          lv2_deferment_type_c2,
          lv2_created_by_c2;
        EXIT WHEN rc_c2_getAllEqpmConnWellsRec%NOTFOUND;
        IF p_event_type = 'DOWN' THEN
          EcDp_System_Key.assignNextNumber('DEFERMENT_EVENT', ln_tmp_event_no);
        END IF;
        IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open
          IF lv2_prev_object_id IS NULL THEN
            lv2_prev_object_id := lv2_object_id_c2;
          ELSE
            IF lv2_prev_object_id = lv2_object_id_c2 THEN
              goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
            ELSE
              lv2_prev_object_id := lv2_object_id_c2;
            END IF;
          END IF;
          ln_Rowcnt := ln_Rowcnt + 1;
          ln_WellVersions_cnt := 0;
          OPEN c3_getWellVersions (p_object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
          LOOP
            FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
            EXIT WHEN c3_getWellVersions%NOTFOUND;
            ln_WellVersions_cnt := ln_WellVersions_cnt + 1;
            -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
            IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
              goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
            ELSE
              IF ld_end_date_c3 IS NOT NULL THEN
                IF ld_end_date_c3 <=  p_end_date THEN
                  ld_end_date_c2 := ld_end_date_c3;
                END IF;
              END IF;
              IF ld_daytime_c3 >=  p_daytime THEN
                ld_daytime_c2 := ld_daytime_c3;
              END IF;
            END IF;
            <<SKIP_LOOP_B>> NULL;
          END LOOP;
          CLOSE c3_getWellVersions;
            
          typ_object_id.EXTEND;
          typ_object_type.EXTEND;
          typ_parent_event_no.EXTEND;
          typ_parent_object_id.EXTEND;
          typ_parent_daytime.EXTEND;
          typ_daytime.EXTEND;
          typ_end_date.EXTEND;
          typ_event_type.EXTEND;
          typ_deferment_type.EXTEND;
          typ_created_by.EXTEND;
      
          typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
          typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
          typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
          typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
          typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
          typ_daytime(ln_Rowcnt) := ld_daytime_c2;
          typ_end_date(ln_Rowcnt) := ld_end_date_c2;
          typ_event_type(ln_Rowcnt) := lv2_event_type_c2;
          typ_deferment_type(ln_Rowcnt) := lv2_deferment_type_c2;
          typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
          <<SKIP_LOOP_A>> NULL;
          
        END IF;
      END LOOP;
      CLOSE rc_c2_getAllEqpmConnWellsRec;
    ELSIF p_object_typ = 'EQPM' THEN
      OPEN rc_c2_getAllEqpmWellsRec FOR lv2_getAllEqpmWellsStr;
      LOOP
        FETCH rc_c2_getAllEqpmWellsRec INTO
              lv2_object_id_c2,
              lv2_object_type_c2,
              ln_parent_event_no_c2,
              lv2_parent_object_id_c2,
              ld_parent_daytime_c2,
              ld_daytime_c2,
              ld_end_date_c2,
              lv2_event_type_c2,
              lv2_deferment_type_c2,
              lv2_created_by_c2;
            EXIT WHEN rc_c2_getAllEqpmWellsRec%NOTFOUND;
        IF p_event_type = 'DOWN' THEN
          EcDp_System_Key.assignNextNumber('DEFERMENT_EVENT', ln_tmp_event_no);
        END IF;
        IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open
          IF lv2_prev_object_id IS NULL THEN
            lv2_prev_object_id := lv2_object_id_c2;
          ELSE
            IF lv2_prev_object_id = lv2_object_id_c2 THEN
              goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
            ELSE
              lv2_prev_object_id := lv2_object_id_c2;
            END IF;
          END IF;
          ln_Rowcnt := ln_Rowcnt + 1;
          ln_WellVersions_cnt := 0;
          OPEN c3_getWellVersions (p_object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
          LOOP
            FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
            EXIT WHEN c3_getWellVersions%NOTFOUND;
            ln_WellVersions_cnt := ln_WellVersions_cnt + 1;
            -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
            IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
              goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
            ELSE
              IF ld_end_date_c3 IS NOT NULL THEN
                IF ld_end_date_c3 <=  p_end_date THEN
                  ld_end_date_c2 := ld_end_date_c3;
                END IF;
              END IF;
              IF ld_daytime_c3 >=  p_daytime THEN
                ld_daytime_c2 := ld_daytime_c3;
              END IF;
            END IF;
            <<SKIP_LOOP_B>> NULL;
          END LOOP;
          CLOSE c3_getWellVersions;
              
          typ_object_id.EXTEND;
          typ_object_type.EXTEND;
          typ_parent_event_no.EXTEND;
          typ_parent_object_id.EXTEND;
          typ_parent_daytime.EXTEND;
          typ_daytime.EXTEND;
          typ_end_date.EXTEND;
          typ_event_type.EXTEND;
          typ_deferment_type.EXTEND;
          typ_created_by.EXTEND;
    
          typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
          typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
          typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
          typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
          typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
          typ_daytime(ln_Rowcnt) := ld_daytime_c2;
          typ_end_date(ln_Rowcnt) := ld_end_date_c2;
          typ_event_type(ln_Rowcnt) := lv2_event_type_c2;
          typ_deferment_type(ln_Rowcnt) := lv2_deferment_type_c2;
          typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
          <<SKIP_LOOP_A>> NULL;
    
        END IF;
      END LOOP;
      CLOSE rc_c2_getAllEqpmWellsRec;
    ELSIF p_object_typ = 'FCTY_CLASS_1' OR p_object_typ = 'WELL_HOOKUP' THEN
      OPEN rc_c2_getAllWellRec FOR lv2_getAllWellsStr;
      LOOP
        FETCH rc_c2_getAllWellRec INTO
          lv2_object_id_c2,
          lv2_object_type_c2,
          ln_parent_event_no_c2,
          lv2_parent_object_id_c2,
          ld_parent_daytime_c2,
          ld_daytime_c2,
          ld_end_date_c2,
          lv2_event_type_c2,
          lv2_deferment_type_c2,
          lv2_created_by_c2;
        EXIT WHEN rc_c2_getAllWellRec%NOTFOUND;
        IF p_event_type = 'DOWN' THEN
          EcDp_System_Key.assignNextNumber('DEFERMENT_EVENT', ln_tmp_event_no);
        END IF;
        IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open
          IF lv2_prev_object_id IS NULL THEN
            lv2_prev_object_id := lv2_object_id_c2;
          ELSE
            IF lv2_prev_object_id = lv2_object_id_c2 THEN
              goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
            ELSE
              lv2_prev_object_id := lv2_object_id_c2;
            END IF;
          END IF;
          ln_Rowcnt := ln_Rowcnt + 1;
          ln_WellVersions_cnt := 0;
          OPEN c3_getWellVersions (p_object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
          LOOP
            FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
            EXIT WHEN c3_getWellVersions%NOTFOUND;
            ln_WellVersions_cnt := ln_WellVersions_cnt + 1;
            -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
            IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
              goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
            ELSE
              IF ld_end_date_c3 IS NOT NULL THEN
                IF ld_end_date_c3 <=  p_end_date THEN
                  ld_end_date_c2 := ld_end_date_c3;
                END IF;
              END IF;
              IF ld_daytime_c3 >=  p_daytime THEN
                ld_daytime_c2 := ld_daytime_c3;
              END IF;
            END IF;
            <<SKIP_LOOP_B>> NULL;
          END LOOP;
          CLOSE c3_getWellVersions;
    
          typ_object_id.EXTEND;
          typ_object_type.EXTEND;
          typ_parent_event_no.EXTEND;
          typ_parent_object_id.EXTEND;
          typ_parent_daytime.EXTEND;
          typ_daytime.EXTEND;
          typ_end_date.EXTEND;
          typ_event_type.EXTEND;
          typ_deferment_type.EXTEND;
          typ_created_by.EXTEND;
    
          typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
          typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
          typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
          typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
          typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
          typ_daytime(ln_Rowcnt) := ld_daytime_c2;
          typ_end_date(ln_Rowcnt) := ld_end_date_c2;
          typ_event_type(ln_Rowcnt) := lv2_event_type_c2;
          typ_deferment_type(ln_Rowcnt) := lv2_deferment_type_c2;
          typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
          <<SKIP_LOOP_A>> NULL;
          
        END IF;
      END LOOP;
      CLOSE rc_c2_getAllWellRec;
    ELSIF p_object_typ = 'FCTY_CLASS_2' THEN
      FOR lrec_fcty_class1 IN c_getFC1List (p_object_id,  p_daytime, p_end_date) 
      LOOP
        FOR mycur IN c1_network(lrec_fcty_class1.object_id) LOOP
          lv2_alloc_netwk_id_c1 := mycur.object_id;
        END LOOP;
        IF lv2_alloc_netwk_id_c1 IS NOT NULL THEN
          IF lv2_replaced_fcty1_id IS NULL THEN
            lv2_getAllWellsStr1 := replace(lv2_getAllWellsStr1, p_object_id, lrec_fcty_class1.object_id);
            lv2_getAllWellsStr2 := replace(lv2_getAllWellsStr2, p_object_id, lrec_fcty_class1.object_id);
            lv2_getAllWellsStr3 := replace(lv2_getAllWellsStr3, p_object_id, lrec_fcty_class1.object_id);
            lv2_getAllWellsStr4 := replace(lv2_getAllWellsStr4, p_object_id, lrec_fcty_class1.object_id);
            lv2_getAllWellsStr4 := replace(lv2_getAllWellsStr4, 'cce.object_id = ''''', 'cce.object_id = ''' || lv2_alloc_netwk_id_c1 || '''');
            lv2_getAllWellsStr := lv2_getAllWellsStr1 ||CHR(13)||''||CHR(10)|| lv2_getAllWellsStr2 ||CHR(13)||''||CHR(10)|| lv2_getAllWellsStr3 ||CHR(13)||''||CHR(10)|| lv2_getAllWellsStr4 ||CHR(13)||''||CHR(10)|| lv2_getOverlappingWellsStr;      
          ELSE
            lv2_getAllWellsStr1 := replace(lv2_getAllWellsStr1, lv2_replaced_fcty1_id, lrec_fcty_class1.object_id);
            lv2_getAllWellsStr2 := replace(lv2_getAllWellsStr2, lv2_replaced_fcty1_id, lrec_fcty_class1.object_id);
            lv2_getAllWellsStr3 := replace(lv2_getAllWellsStr3, lv2_replaced_fcty1_id, lrec_fcty_class1.object_id);
            lv2_getAllWellsStr4 := replace(lv2_getAllWellsStr4, lv2_replaced_fcty1_id, lrec_fcty_class1.object_id);
            IF lv2_replaced_cce_id <> lv2_alloc_netwk_id_c1 THEN
              lv2_getAllWellsStr4 := replace(lv2_getAllWellsStr4, lv2_replaced_cce_id, lv2_alloc_netwk_id_c1);
            END IF;  
            lv2_getAllWellsStr := lv2_getAllWellsStr1 ||CHR(13)||''||CHR(10)|| lv2_getAllWellsStr2 ||CHR(13)||''||CHR(10)|| lv2_getAllWellsStr3 ||CHR(13)||''||CHR(10)|| lv2_getAllWellsStr4 ||CHR(13)||''||CHR(10)|| lv2_getOverlappingWellsStr;      
          END IF;
          lv2_replaced_fcty1_id := lrec_fcty_class1.object_id;         
          lv2_replaced_cce_id :=  lv2_alloc_netwk_id_c1;
          
          OPEN rc_c2_getAllWellRec FOR lv2_getAllWellsStr;
          LOOP
          FETCH rc_c2_getAllWellRec INTO
            lv2_object_id_c2,
            lv2_object_type_c2,
            ln_parent_event_no_c2,
            lv2_parent_object_id_c2,
            ld_parent_daytime_c2,
            ld_daytime_c2,
            ld_end_date_c2,
            lv2_event_type_c2,
            lv2_deferment_type_c2,
            lv2_created_by_c2;
            EXIT WHEN rc_c2_getAllWellRec%NOTFOUND;
            IF p_event_type = 'DOWN' THEN
              EcDp_System_Key.assignNextNumber('DEFERMENT_EVENT', ln_tmp_event_no);
            END IF;
            IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open
              IF lv2_prev_object_id IS NULL THEN
                lv2_prev_object_id := lv2_object_id_c2;
              ELSE
               IF lv2_prev_object_id = lv2_object_id_c2 THEN
                  goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
                ELSE
                  lv2_prev_object_id := lv2_object_id_c2;
                END IF;
              END IF;
              ln_Rowcnt := ln_Rowcnt + 1;
              ln_WellVersions_cnt := 0;
              OPEN c3_getWellVersions (lrec_fcty_class1.object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
              LOOP
                FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
                EXIT WHEN c3_getWellVersions%NOTFOUND;
                ln_WellVersions_cnt := ln_WellVersions_cnt + 1;
                -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
                IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
                  goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
                ELSE
                  IF ld_end_date_c3 IS NOT NULL THEN
                    IF ld_end_date_c3 <=  p_end_date THEN
                      ld_end_date_c2 := ld_end_date_c3;
                    END IF;
                  END IF;
                  IF ld_daytime_c3 >=  p_daytime THEN
                    ld_daytime_c2 := ld_daytime_c3;
                  END IF;
                END IF;
                <<SKIP_LOOP_B>> NULL;
              END LOOP;
              CLOSE c3_getWellVersions;
          
              typ_object_id.EXTEND;
              typ_object_type.EXTEND;
              typ_parent_event_no.EXTEND;
              typ_parent_object_id.EXTEND;
              typ_parent_daytime.EXTEND;
              typ_daytime.EXTEND;
              typ_end_date.EXTEND;
              typ_event_type.EXTEND;
              typ_deferment_type.EXTEND;
              typ_created_by.EXTEND;
          
              typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
              typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
              typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
              typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
              typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
              typ_daytime(ln_Rowcnt) := ld_daytime_c2;
              typ_end_date(ln_Rowcnt) := ld_end_date_c2;
              typ_event_type(ln_Rowcnt) := lv2_event_type_c2;
              typ_deferment_type(ln_Rowcnt) := lv2_deferment_type_c2;
              typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
              <<SKIP_LOOP_A>> NULL;
              
            END IF;
          END LOOP;
          CLOSE rc_c2_getAllWellRec;
        END IF;  
      END LOOP;
    ELSIF p_object_typ = 'TANK' THEN
      OPEN rc_c2_getAllTankWellsRec FOR lv2_getAllTankWellsStr;
      LOOP
        FETCH rc_c2_getAllTankWellsRec INTO
          lv2_object_id_c2,
          lv2_object_type_c2,
          ln_parent_event_no_c2,
          lv2_parent_object_id_c2,
          ld_parent_daytime_c2,
          ld_daytime_c2,
          ld_end_date_c2,
          lv2_event_type_c2,
          lv2_deferment_type_c2,
          lv2_created_by_c2;
        EXIT WHEN rc_c2_getAllTankWellsRec%NOTFOUND;
        IF p_event_type = 'DOWN' THEN
          EcDp_System_Key.assignNextNumber('DEFERMENT_EVENT', ln_tmp_event_no);
        END IF;
        IF ecdp_well.IsWellOpen(lv2_object_id_c2, p_daytime) = 'Y' THEN -- Only include wells that are open
          IF lv2_prev_object_id IS NULL THEN
            lv2_prev_object_id := lv2_object_id_c2;
          ELSE
            IF lv2_prev_object_id = lv2_object_id_c2 THEN
              goto SKIP_LOOP_A; -- skip the same well object id in the loop when the same well object has multiple versions within the date range.
            ELSE
              lv2_prev_object_id := lv2_object_id_c2;
            END IF;
          END IF;
          ln_Rowcnt := ln_Rowcnt + 1;
          ln_WellVersions_cnt := 0;
          OPEN c3_getWellVersions (p_object_id, lv2_object_id_c2, ld_daytime_c2, ld_end_date_c2);
          LOOP
            FETCH c3_getWellVersions INTO ld_daytime_c3, ld_end_date_c3;
            EXIT WHEN c3_getWellVersions%NOTFOUND;
            ln_WellVersions_cnt := ln_WellVersions_cnt + 1;
            -- Check the correct Well Version's start and end date that related to the Deferment's start and end date
            IF c3_getWellVersions%ROWCOUNT > 1 AND ln_WellVersions_cnt > 1 THEN
              goto SKIP_LOOP_B; -- Skip the remaining rows of the well version, because it needs to avoid the same row to insert and hit the UK constraint violation in the DB commit.
            ELSE
              IF ld_end_date_c3 IS NOT NULL THEN
                IF ld_end_date_c3 <=  p_end_date THEN
                  ld_end_date_c2 := ld_end_date_c3;
                END IF;
              END IF;
              IF ld_daytime_c3 >=  p_daytime THEN
                ld_daytime_c2 := ld_daytime_c3;
              END IF;
            END IF;
            <<SKIP_LOOP_B>> NULL;
          END LOOP;
          CLOSE c3_getWellVersions;
    
          typ_object_id.EXTEND;
          typ_object_type.EXTEND;
          typ_parent_event_no.EXTEND;
          typ_parent_object_id.EXTEND;
          typ_parent_daytime.EXTEND;
          typ_daytime.EXTEND;
          typ_end_date.EXTEND;
          typ_event_type.EXTEND;
          typ_deferment_type.EXTEND;
          typ_created_by.EXTEND;
              
          typ_object_id(ln_Rowcnt) :=  lv2_object_id_c2;
          typ_object_type(ln_Rowcnt) := lv2_object_type_c2;
          typ_parent_event_no(ln_Rowcnt) := ln_parent_event_no_c2;
          typ_parent_object_id(ln_Rowcnt) := lv2_parent_object_id_c2;
          typ_parent_daytime(ln_Rowcnt) := ld_parent_daytime_c2;
          typ_daytime(ln_Rowcnt) := ld_daytime_c2;
          typ_end_date(ln_Rowcnt) := ld_end_date_c2;
          typ_event_type(ln_Rowcnt) := lv2_event_type_c2;
          typ_deferment_type(ln_Rowcnt) := lv2_deferment_type_c2;
          typ_created_by(ln_Rowcnt) := lv2_created_by_c2;
          <<SKIP_LOOP_A>> NULL;
          
        END IF;
      END LOOP;
      CLOSE rc_c2_getAllTankWellsRec;
    END IF;
    FORALL k IN 1..typ_object_id.COUNT
    INSERT INTO deferment_event
    (object_id, object_type, parent_event_no, parent_object_id, parent_daytime, daytime, end_date,
    event_type, deferment_type, created_by, class_name)
    VALUES
    (typ_object_id(k), typ_object_type(k), typ_parent_event_no(k), typ_parent_object_id(k), typ_parent_daytime(k), typ_daytime(k), typ_end_date(k),
    typ_event_type(k), typ_deferment_type(k), typ_created_by(k), 'WELL_DEFERMENT_CHILD')
    RETURNING event_no,parent_event_no,daytime,end_date BULK COLLECT INTO typ_deferment;
    FOR I IN 1..typ_deferment.COUNT LOOP
      EcDp_Deferment.insertTempWellDefermntAlloc(typ_deferment(I).event_no, typ_deferment(I).parent_event_no, typ_deferment(I).daytime, NULL, typ_deferment(I).end_date, NULL, 'I', p_username, Ecdp_Timestamp.getCurrentSysdate);
    END LOOP;
    FOR cur_getChildRecords IN c_getChildRecords LOOP
      EcDp_Deferment.setLossRate(cur_getChildRecords.Event_No, p_username );
    END LOOP;
  END IF;
END insertWells;

---------------------------------------------------------------------------------------------------
-- Procedure      : approveWellDeferment
-- Description    : The Procedure approve the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveWellDeferment(p_event_no NUMBER,
                               p_user_name VARCHAR2)
--</EC-DOC>
IS

  lv2_last_update_date VARCHAR2(20);
  ld_valid_from_date DATE;
  ld_valid_to_date DATE;
  lv2_object_id VARCHAR2(32);

BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

  ld_valid_from_date := ec_deferment_event.daytime(p_event_no);
  ld_valid_to_date := ec_deferment_event.end_date(p_event_no);
  lv2_object_id := ec_deferment_event.object_id(p_event_no);

  checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

  -- update parent
  UPDATE deferment_event
  SET record_status='A',
      last_updated_by = p_user_name,
      last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
      rev_text = 'Approved at ' ||  lv2_last_update_date
  WHERE event_no = p_event_no
  AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  -- update child
  UPDATE deferment_event  wed_child
  SET wed_child.record_status='A',
      last_updated_by = p_user_name,
      last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
      rev_text = 'Approved at ' ||   lv2_last_update_date
  WHERE wed_child.parent_event_no = p_event_no
  AND wed_child.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

END approveWellDeferment;

---------------------------------------------------------------------------------------------------
-- Procedure      : approveWellDefermentbyWell
-- Description    : The Procedure approve the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveWellDefermentbyWell(p_event_no NUMBER,
                                     p_user_name VARCHAR2)
--</EC-DOC>
IS

  lv2_last_update_date VARCHAR2(20);
  lv_Parent_ID         VARCHAR2(32);

  ld_valid_from_date DATE;
  ld_valid_to_date DATE;
  lv2_object_id VARCHAR2(32);
BEGIN

  lv_Parent_ID := ec_deferment_event.parent_object_id(p_event_no);

  ld_valid_from_date := ec_deferment_event.daytime(p_event_no);
  ld_valid_to_date := ec_deferment_event.end_date(p_event_no);
  lv2_object_id := ec_deferment_event.object_id(p_event_no);

  checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

  IF lv_Parent_ID IS NOT NULL then
    RAISE_APPLICATION_ERROR('-20666','Group Child Records cannot be approved here. It should be done at Well Deferment screen.');
  ELSE

    lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

    -- update parent
    UPDATE deferment_event
    SET record_status='A',
        last_updated_by = p_user_name,
        last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
        rev_text = 'Approved at ' ||  lv2_last_update_date
    WHERE event_no = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

    -- update child
    UPDATE deferment_event
    SET record_status='A',
        last_updated_by = p_user_name,
        last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
        rev_text = 'Approved at ' ||   lv2_last_update_date
    WHERE parent_event_no = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  END IF;

END approveWellDefermentbyWell;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyWellDeferment
-- Description    : The Procedure verifies the records for the selected object within the specified period.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE verifyWellDeferment(p_event_no NUMBER,
                              p_user_name VARCHAR2)
--</EC-DOC>
IS

  ln_exists NUMBER;
  lv2_last_update_date VARCHAR2(20);

  ld_valid_from_date DATE;
  ld_valid_to_date DATE;
  lv2_object_id VARCHAR2(32);

BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

  ld_valid_from_date := ec_deferment_event.daytime(p_event_no);
  ld_valid_to_date := ec_deferment_event.end_date(p_event_no);
  lv2_object_id := ec_deferment_event.object_id(p_event_no);

  checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

  SELECT COUNT(*) INTO ln_exists 
  FROM  deferment_event 
  WHERE event_no  = p_event_no
  AND record_status='A'
  AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  IF ln_exists = 0 THEN
  -- Update parent
    UPDATE  deferment_event
    SET record_status='V',
        last_updated_by = p_user_name,
        last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
        rev_text = 'Verified at ' ||  lv2_last_update_date
    WHERE event_no = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  -- update child
    UPDATE deferment_event  wed_child
    SET wed_child.record_status='V',
        last_updated_by = p_user_name,
        last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
        rev_text = 'Verified at ' ||  lv2_last_update_date
    WHERE wed_child.parent_event_no = p_event_no
    AND wed_child.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  ELSE
    RAISE_APPLICATION_ERROR('-20223','Record with Approved status cannot be Verified again.');
  END IF;

END verifyWellDeferment;

---------------------------------------------------------------------------------------------------
-- Procedure      : verifyWellDefermentbyWell
-- Description    : The Procedure verifies the records for the selected object within the specified period
--                            for Single Well records only. Group Child records will be rejected.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------------
PROCEDURE verifyWellDefermentbyWell(p_event_no NUMBER,
                                    p_user_name VARCHAR2)
--</EC-DOC>
IS

  ln_exists NUMBER;
  lv2_last_update_date VARCHAR2(20);
  lv_Parent_ID         VARCHAR2(32);

  ld_valid_from_date DATE;
  ld_valid_to_date DATE;
  lv2_object_id VARCHAR2(32);

BEGIN

  lv_Parent_ID := ec_deferment_event.parent_object_id(p_event_no);

  ld_valid_from_date := ec_deferment_event.daytime(p_event_no);
  ld_valid_to_date := ec_deferment_event.end_date(p_event_no);
  lv2_object_id := ec_deferment_event.object_id(p_event_no);

  checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

  IF lv_Parent_ID IS NOT NULL then
    RAISE_APPLICATION_ERROR('-20665','Group Child Records cannot be verified here. It should be done at Well Deferment screen.');
  ELSE
    lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

    SELECT COUNT(*) INTO ln_exists FROM  deferment_event WHERE event_no  = p_event_no AND record_status='A' AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

    IF ln_exists = 0 THEN
      -- Update parent
      UPDATE  deferment_event
      SET record_status='V',
          last_updated_by = p_user_name,
          last_updated_date = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
          rev_text = 'Verified at ' ||  lv2_last_update_date
      WHERE event_no = p_event_no
      AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

      -- update child
      UPDATE deferment_event
      SET record_status='V',
          last_updated_by = p_user_name,
          last_updated_date = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
          rev_text = 'Verified at ' ||  lv2_last_update_date
      WHERE parent_event_no = p_event_no;

    ELSE
      RAISE_APPLICATION_ERROR('-20223','Record with Approved status cannot be Verified again.');
    END IF;
  END IF;

END verifyWellDefermentbyWell;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : setLossRate                                                                    --
-- Description    : Updates Loss Rates and Loss Mass Rates 
-- Preconditions  :
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   : deferment_event
--                                                                                                 --
-- Using functions:
--
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE setLossRate (
  p_event_no        NUMBER,
  p_user            VARCHAR2)
--</EC-DOC>
IS

  CURSOR  c_group_loss  IS
  SELECT
    sum(wed.oil_loss_rate)            tot_oil_loss_rate,
    sum(wed.gas_loss_rate)            tot_gas_loss_rate,
    sum(wed.cond_loss_rate)           tot_cond_loss_rate,
    sum(wed.water_loss_rate)          tot_wat_loss_rate,
    sum(wed.water_inj_loss_rate)      tot_wat_inj_loss_rate,
    sum(wed.steam_inj_loss_rate)      tot_steam_inj_loss_rate,
    sum(wed.gas_inj_loss_rate)        tot_gas_inj_loss_rate,
    sum(wed.diluent_loss_rate)        tot_diluent_loss_rate,
    sum(wed.gas_lift_loss_rate)       tot_gas_lift_loss_rate,
    sum(wed.oil_loss_mass_rate)       tot_oil_loss_mass_rate,
    sum(wed.gas_loss_mass_rate)       tot_gas_loss_mass_rate,
    sum(wed.cond_loss_mass_rate)      tot_cond_loss_mass_rate,
    sum(wed.water_loss_mass_rate)     tot_wat_loss_mass_rate
  FROM deferment_event wed
  WHERE wed.parent_event_no = p_event_no
  AND wed.deferment_type = 'GROUP_CHILD'
  AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  ln_oil_loss_rate                NUMBER := null;
  ln_gas_loss_rate                NUMBER := null;
  ln_gas_inj_loss_rate            NUMBER := null;
  ln_cond_loss_rate               NUMBER := null;
  ln_wat_loss_rate                NUMBER := null;
  ln_wat_inj_loss_rate            NUMBER := null;
  ln_steam_inj_loss_rate          NUMBER := null;
  ln_diluent_loss_rate            NUMBER := null;
  ln_gas_lift_loss_rate           NUMBER := null;
        
  ln_oil_loss_mass_rate           NUMBER := null;  
  ln_gas_loss_mass_rate           NUMBER := null;
  ln_cond_loss_mass_rate          NUMBER := null;
  ln_wat_loss_mass_rate           NUMBER := null;

  ln_parent_oil_loss_rate         NUMBER ;
  ln_parent_gas_loss_rate         NUMBER ;
  ln_parent_gas_inj_loss_rate     NUMBER ;
  ln_parent_cond_loss_rate        NUMBER ;
  ln_parent_wat_loss_rate         NUMBER ;
  ln_parent_wat_inj_loss_rate     NUMBER ;
  ln_parent_steam_inj_loss_rate   NUMBER ;
  ln_parent_diluent_loss_rate     NUMBER ;
  ln_parent_gas_lift_loss_rate    NUMBER ;

  ln_parent_oil_loss_mass_rate    NUMBER ;
  ln_parent_gas_loss_mass_rate    NUMBER ;
  ln_parent_cond_loss_mass_rate   NUMBER ;
  ln_parent_wat_loss_mass_rate    NUMBER ;
  
  ln_tot_oil_loss_rate            NUMBER := null;
  ln_tot_gas_loss_rate            NUMBER := null;
  ln_tot_wat_loss_rate            NUMBER := null;
  ln_tot_gas_inj_loss_rate        NUMBER := null;
  ln_tot_cond_loss_rate           NUMBER := null;
  ln_tot_wat_inj_loss_rate        NUMBER := null;
  ln_tot_steam_inj_loss_rate      NUMBER := null;
  ln_tot_diluent_loss_rate        NUMBER := null;
  ln_tot_gas_lift_loss_rate       NUMBER := null;

  ln_tot_oil_loss_mass_rate       NUMBER := null;
  ln_tot_gas_loss_mass_rate       NUMBER := null;
  ln_tot_wat_loss_mass_rate       NUMBER := null;
  ln_tot_cond_loss_mass_rate      NUMBER := null;
  
  ln_event_loss_oil               NUMBER := null;
  ln_event_loss_gas               NUMBER := null;
  ln_event_loss_cond              NUMBER := null;
  ln_event_loss_water             NUMBER := null;
  ln_event_loss_water_inj         NUMBER := null;
  ln_event_loss_steam_inj         NUMBER := null;
  ln_event_loss_gas_inj           NUMBER := null;
  ln_event_loss_diluent           NUMBER := null;
  ln_event_loss_gas_lift          NUMBER := null;
  
  ln_event_loss_oil_mass          NUMBER := null;
  ln_event_loss_gas_mass          NUMBER := null;
  ln_event_loss_cond_mass         NUMBER := null;
  ln_event_loss_water_mass        NUMBER := null;

  ln_diff                         NUMBER := null;
  ln_chk_child                    NUMBER := null;
  lv2_deferment_type              VARCHAR2(32);
  lv2_object_id                   VARCHAR2(32);
  ld_day                          DATE;  
  ld_daytime                      DATE;
  ld_end_date                     DATE;

BEGIN

  BEGIN
    SELECT object_id,day,daytime,end_date,
           oil_loss_rate,gas_loss_rate,gas_inj_loss_rate,cond_loss_rate,water_loss_rate,water_inj_loss_rate,steam_inj_loss_rate,diluent_loss_rate,gas_lift_loss_rate,
           oil_loss_mass_rate,gas_loss_mass_rate,cond_loss_mass_rate,water_loss_mass_rate,
           deferment_type
    INTO lv2_object_id,ld_day,ld_daytime,ld_end_date,
         ln_oil_loss_rate,ln_gas_loss_rate,ln_gas_inj_loss_rate,ln_cond_loss_rate,ln_wat_loss_rate,ln_wat_inj_loss_rate,ln_steam_inj_loss_rate,ln_diluent_loss_rate,ln_gas_lift_loss_rate,
         ln_oil_loss_mass_rate,ln_gas_loss_mass_rate,ln_cond_loss_mass_rate,ln_wat_loss_mass_rate,
         lv2_deferment_type
    FROM deferment_event
    WHERE event_no  = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
  END;

  ln_event_loss_oil := EcBp_Deferment.getParentEventLossRate(p_event_no, 'OIL',lv2_deferment_type);
  ln_event_loss_gas := EcBp_Deferment.getParentEventLossRate(p_event_no, 'GAS',lv2_deferment_type);
  ln_event_loss_cond := EcBp_Deferment.getParentEventLossRate(p_event_no, 'COND',lv2_deferment_type);
  ln_event_loss_water := EcBp_Deferment.getParentEventLossRate(p_event_no, 'WATER',lv2_deferment_type);
  ln_event_loss_water_inj := EcBp_Deferment.getParentEventLossRate(p_event_no, 'WAT_INJ',lv2_deferment_type);
  ln_event_loss_steam_inj := EcBp_Deferment.getParentEventLossRate(p_event_no, 'STEAM_INJ',lv2_deferment_type);
  ln_event_loss_gas_inj := EcBp_Deferment.getParentEventLossRate(p_event_no, 'GAS_INJ',lv2_deferment_type);
  ln_event_loss_diluent := EcBp_Deferment.getParentEventLossRate(p_event_no, 'DILUENT',lv2_deferment_type);
  ln_event_loss_gas_lift := EcBp_Deferment.getParentEventLossRate(p_event_no, 'GAS_LIFT',lv2_deferment_type);
  
  ln_event_loss_oil_mass  := EcBp_Deferment.getParentEventLossMass(p_event_no, 'OIL',lv2_deferment_type);
  ln_event_loss_gas_mass  := EcBp_Deferment.getParentEventLossMass(p_event_no, 'GAS',lv2_deferment_type);
  ln_event_loss_cond_mass := EcBp_Deferment.getParentEventLossMass(p_event_no, 'COND',lv2_deferment_type);
  ln_event_loss_water_mass := EcBp_Deferment.getParentEventLossMass(p_event_no, 'WATER',lv2_deferment_type);

  ln_diff := abs((ld_end_date - ld_daytime)*24);

  IF lv2_deferment_type IN ('SINGLE','GROUP_CHILD') THEN

    -- This is to check that when the well is NOT INJECTOR and ISPRODCUCER is closed, then Oil, Gas, and Cond's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day) = 'N' then
      ln_oil_loss_rate       := NULL;
      ln_gas_loss_rate       := NULL;
      ln_cond_loss_rate      := NULL;
      ln_wat_loss_rate       := NULL;
      ln_diluent_loss_rate   := NULL;
      ln_gas_lift_loss_rate  := NULL;
      ln_oil_loss_mass_rate  := NULL;
      ln_gas_loss_mass_rate  := NULL;
      ln_cond_loss_mass_rate := NULL;
      ln_wat_loss_mass_rate  := NULL;
    END IF;

    -- This is to check that when the well is Gas Injector is closed, then the Gas Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'GI','OPEN',ld_day) = 'N' then
      ln_gas_inj_loss_rate  := NULL;
    END IF;

    -- This is to check that when the well is Water Injector is closed, then the Water Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'WI','OPEN',ld_day) = 'N' then
      ln_wat_inj_loss_rate  := NULL;
    END IF;

    -- This is to check that when the well is Steam Injector is closed, then the Steam Injector's loss rate value will be set to null
    IF ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'SI','OPEN',ld_day) = 'N' then
      ln_steam_inj_loss_rate  := NULL;
    END IF;

    UPDATE deferment_event
    SET oil_loss_rate = nvl(ln_oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findOilProductionPotential(lv2_object_id,ld_day),null)),
        gas_loss_rate = nvl(ln_gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findGasProductionPotential(lv2_object_id,ld_day), null)),
        gas_inj_loss_rate =  nvl(ln_gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'GI','OPEN',ld_day), 'Y', ecbp_well_potential.findGasInjectionPotential(lv2_object_id,ld_day), null)),
        cond_loss_rate = nvl(ln_cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findConProductionPotential(lv2_object_id,ld_day), null)),
        water_loss_rate = nvl(ln_wat_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findWatProductionPotential(lv2_object_id,ld_day), null)),
        water_inj_loss_rate = nvl(ln_wat_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'WI','OPEN',ld_day), 'Y', ecbp_well_potential.findWatInjectionPotential(lv2_object_id,ld_day), null)),
        steam_inj_loss_rate = nvl(ln_steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,'SI','OPEN',ld_day), 'Y', ecbp_well_potential.findSteamInjectionPotential(lv2_object_id,ld_day), null)),
        diluent_loss_rate = nvl(ln_diluent_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findDiluentPotential(lv2_object_id,ld_day),null)),
        gas_lift_loss_rate = nvl(ln_gas_lift_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findGasLiftPotential(lv2_object_id,ld_day), null)),
        oil_loss_mass_rate = nvl(ln_oil_loss_mass_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findOilMassProdPotential(lv2_object_id,ld_day),null)),
        gas_loss_mass_rate = nvl(ln_gas_loss_mass_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findGasMassProdPotential(lv2_object_id,ld_day), null)),
        cond_loss_mass_rate = nvl(ln_cond_loss_mass_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findCondMassProdPotential(lv2_object_id,ld_day), null)),
        water_loss_mass_rate = nvl(ln_wat_loss_mass_rate, decode(ecdp_well.isWellPhaseActiveStatus(lv2_object_id,null,'OPEN',ld_day), 'Y', ecbp_well_potential.findWaterMassProdPotential(lv2_object_id,ld_day), null)),
        last_updated_by = p_user
    WHERE event_no  = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  ELSIF (lv2_deferment_type ='GROUP') THEN
      SELECT count(1) into ln_chk_child FROM deferment_event WHERE parent_event_no  = p_event_no and (daytime <> ld_daytime or end_date <> ld_end_date) and class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
      ln_parent_oil_loss_rate         := ln_oil_loss_rate;
      ln_parent_gas_loss_rate         := ln_gas_loss_rate;
      ln_parent_gas_inj_loss_rate     := ln_gas_inj_loss_rate;
      ln_parent_cond_loss_rate        := ln_cond_loss_rate;
      ln_parent_wat_loss_rate         := ln_wat_loss_rate;
      ln_parent_wat_inj_loss_rate     := ln_wat_inj_loss_rate;
      ln_parent_steam_inj_loss_rate   := ln_steam_inj_loss_rate;
      ln_parent_diluent_loss_rate     := ln_diluent_loss_rate;
      ln_parent_gas_lift_loss_rate    := ln_gas_lift_loss_rate;
      
      ln_parent_oil_loss_mass_rate    := ln_oil_loss_mass_rate;
      ln_parent_gas_loss_mass_rate    := ln_gas_loss_mass_rate;
      ln_parent_cond_loss_mass_rate   := ln_cond_loss_mass_rate;
      ln_parent_wat_loss_mass_rate    := ln_wat_loss_mass_rate;

    -- Check total loss rates of all child with the same parent
    FOR c_group_tot_loss IN c_group_loss LOOP
      IF (ln_chk_child > 0) THEN
        ln_tot_oil_loss_rate        := (ln_event_loss_oil * 24/ln_diff);
        ln_tot_gas_loss_rate        := (ln_event_loss_gas * 24/ln_diff);
        ln_tot_gas_inj_loss_rate    := (ln_event_loss_gas_inj * 24/ln_diff);
        ln_tot_cond_loss_rate       := (ln_event_loss_cond * 24/ln_diff);
        ln_tot_wat_loss_rate        := (ln_event_loss_water * 24/ln_diff);
        ln_tot_wat_inj_loss_rate    := (ln_event_loss_water_inj * 24/ln_diff);
        ln_tot_steam_inj_loss_rate  := (ln_event_loss_steam_inj * 24/ln_diff);
        ln_tot_diluent_loss_rate    := (ln_event_loss_diluent * 24/ln_diff);
        ln_tot_gas_lift_loss_rate   := (ln_event_loss_gas_lift * 24/ln_diff);
        ln_tot_oil_loss_mass_rate   := (ln_event_loss_oil_mass * 24/ln_diff);
        ln_tot_gas_loss_mass_rate   := (ln_event_loss_gas_mass * 24/ln_diff);
        ln_tot_cond_loss_mass_rate  := (ln_event_loss_cond_mass * 24/ln_diff);
        ln_tot_wat_loss_mass_rate   := (ln_event_loss_water_mass * 24/ln_diff);
      ELSE
        ln_tot_oil_loss_rate        :=  c_group_tot_loss.tot_oil_loss_rate;
        ln_tot_gas_loss_rate        :=  c_group_tot_loss.tot_gas_loss_rate;
        ln_tot_gas_inj_loss_rate    :=  c_group_tot_loss.tot_gas_inj_loss_rate;
        ln_tot_cond_loss_rate       :=  c_group_tot_loss.tot_cond_loss_rate;
        ln_tot_wat_loss_rate        :=  c_group_tot_loss.tot_wat_loss_rate;
        ln_tot_wat_inj_loss_rate    :=  c_group_tot_loss.tot_wat_inj_loss_rate;
        ln_tot_steam_inj_loss_rate  :=  c_group_tot_loss.tot_steam_inj_loss_rate;
        ln_tot_diluent_loss_rate    :=  c_group_tot_loss.tot_diluent_loss_rate;
        ln_tot_gas_lift_loss_rate   :=  c_group_tot_loss.tot_gas_lift_loss_rate;
        ln_tot_oil_loss_mass_rate   :=  c_group_tot_loss.tot_oil_loss_mass_rate;
        ln_tot_gas_loss_mass_rate   :=  c_group_tot_loss.tot_gas_loss_mass_rate;
        ln_tot_cond_loss_mass_rate  :=  c_group_tot_loss.tot_cond_loss_mass_rate;
        ln_tot_wat_loss_mass_rate   :=  c_group_tot_loss.tot_wat_loss_mass_rate;
      END IF;
    END LOOP;

    -- Update parent with the value if it's value is not null.
    UPDATE deferment_event
    SET oil_loss_rate =  nvl(ln_parent_oil_loss_rate, ln_tot_oil_loss_rate),
        gas_loss_rate = nvl(ln_parent_gas_loss_rate, ln_tot_gas_loss_rate),
        gas_inj_loss_rate = nvl(ln_parent_gas_inj_loss_rate, ln_tot_gas_inj_loss_rate),
        cond_loss_rate = nvl(ln_parent_cond_loss_rate, ln_tot_cond_loss_rate),
        water_loss_rate = nvl(ln_parent_wat_loss_rate, ln_tot_wat_loss_rate),
        water_inj_loss_rate = nvl(ln_parent_wat_inj_loss_rate, ln_tot_wat_inj_loss_rate),
        steam_inj_loss_rate = nvl(ln_parent_steam_inj_loss_rate, ln_tot_steam_inj_loss_rate),
        diluent_loss_rate =  nvl(ln_parent_diluent_loss_rate, ln_tot_diluent_loss_rate),
        gas_lift_loss_rate = nvl(ln_parent_gas_lift_loss_rate, ln_tot_gas_lift_loss_rate),
        oil_loss_mass_rate =  nvl(ln_parent_oil_loss_mass_rate, ln_tot_oil_loss_mass_rate),
        gas_loss_mass_rate = nvl(ln_parent_gas_loss_mass_rate, ln_tot_gas_loss_mass_rate),
        cond_loss_mass_rate = nvl(ln_parent_cond_loss_mass_rate, ln_tot_cond_loss_mass_rate),        
        water_loss_mass_rate = nvl(ln_parent_wat_loss_mass_rate, ln_tot_wat_loss_mass_rate),        
        last_updated_by = p_user
    WHERE event_no = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  END IF;

END setLossRate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateReasonCodeForChildEvent
-- Description    : Update Reason Code of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateReasonCodeForChildEvent(p_event_no NUMBER,
                                        p_user VARCHAR2,
                                        p_last_updated_date DATE)
--</EC-DOC>
IS
  CURSOR c_reason_code IS
  SELECT wed.reason_code_1, wed.reason_code_2, wed.reason_code_3, wed.reason_code_4
         ,wed.reason_code_5, wed.reason_code_6, wed.reason_code_7, wed.reason_code_8
         ,wed.reason_code_9, wed.reason_code_10
         ,wed.reason_code_type_1, wed.reason_code_type_2, wed.reason_code_type_3, wed.reason_code_type_4
         ,wed.reason_code_type_5, wed.reason_code_type_6, wed.reason_code_type_7, wed.reason_code_type_8
         ,wed.reason_code_type_9, wed.reason_code_type_10
  FROM deferment_event wed
  WHERE wed.event_no = p_event_no
  AND wed.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

 BEGIN

  FOR cur_reason_code IN c_reason_code LOOP
    UPDATE deferment_event
    SET reason_code_1 = cur_reason_code.reason_code_1
        ,reason_code_2 = cur_reason_code.reason_code_2
        ,reason_code_3 = cur_reason_code.reason_code_3
        ,reason_code_4 = cur_reason_code.reason_code_4
        ,reason_code_5 = cur_reason_code.reason_code_5
        ,reason_code_6 = cur_reason_code.reason_code_6
        ,reason_code_7 = cur_reason_code.reason_code_7
        ,reason_code_8 = cur_reason_code.reason_code_8
        ,reason_code_9 = cur_reason_code.reason_code_9
        ,reason_code_10 = cur_reason_code.reason_code_10
        ,reason_code_type_1 = cur_reason_code.reason_code_type_1
        ,reason_code_type_2 = cur_reason_code.reason_code_type_2
        ,reason_code_type_3 = cur_reason_code.reason_code_type_3
        ,reason_code_type_4 = cur_reason_code.reason_code_type_4
        ,reason_code_type_5 = cur_reason_code.reason_code_type_5
        ,reason_code_type_6 = cur_reason_code.reason_code_type_6
        ,reason_code_type_7 = cur_reason_code.reason_code_type_7
        ,reason_code_type_8 = cur_reason_code.reason_code_type_8
        ,reason_code_type_9 = cur_reason_code.reason_code_type_9
        ,reason_code_type_10 = cur_reason_code.reason_code_type_10
        ,last_updated_by =  p_user
        ,last_updated_date = p_last_updated_date
    WHERE deferment_type = 'GROUP_CHILD'
    AND parent_event_no = p_event_no
    AND (
          NVL(reason_code_1,'null') <> NVL(cur_reason_code.reason_code_1,'null')
       OR NVL(reason_code_2,'null') <> NVL(cur_reason_code.reason_code_2,'null')
       OR NVL(reason_code_3,'null') <> NVL(cur_reason_code.reason_code_3,'null')
       OR NVL(reason_code_4,'null') <> NVL(cur_reason_code.reason_code_4,'null')
       OR NVL(reason_code_5,'null') <> NVL(cur_reason_code.reason_code_5,'null')
       OR NVL(reason_code_6,'null') <> NVL(cur_reason_code.reason_code_6,'null')
       OR NVL(reason_code_7,'null') <> NVL(cur_reason_code.reason_code_7,'null')
       OR NVL(reason_code_8,'null') <> NVL(cur_reason_code.reason_code_8,'null')
       OR NVL(reason_code_9,'null') <> NVL(cur_reason_code.reason_code_9,'null')
       OR NVL(reason_code_10,'null') <> NVL(cur_reason_code.reason_code_10,'null')
       )
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  END LOOP;

END updateReasonCodeForChildEvent;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateScheduledForChildEvent
-- Description    : Update scheduled field of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateScheduledForChildEvent(p_event_no      NUMBER,
                                       p_user              VARCHAR2,
                                       p_last_updated_date DATE)
--</EC-DOC>
IS

  lv_scheduled deferment_event.scheduled%type;

BEGIN

  BEGIN
    SELECT scheduled
    INTO lv_scheduled
    FROM deferment_event
    WHERE event_no  = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  UPDATE deferment_event
  SET scheduled         = lv_scheduled,
      last_updated_by   = p_user,
      last_updated_date = p_last_updated_date
  WHERE deferment_type = 'GROUP_CHILD'
  AND parent_event_no = p_event_no
  AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

END updateScheduledForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEventTypeForChildEvent
-- Description    : Update Event Type of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateEventTypeForChildEvent(p_event_no          NUMBER,
                                       p_user              VARCHAR2,
                                       p_last_updated_date DATE)
--</EC-DOC>
IS

  lv_event_type deferment_event.event_type%type;

BEGIN

  BEGIN
    SELECT event_type
    INTO lv_event_type
    FROM deferment_event
    WHERE event_no  = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  UPDATE dv_well_deferment_child
  SET event_type        = lv_event_type,
      last_updated_by   = p_user,
      last_updated_date = p_last_updated_date
  WHERE deferment_type = 'GROUP_CHILD'
  AND parent_event_no = p_event_no;

END updateEventTypeForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEndDateForWellDeferment
-- Description    : Update end date of chilf if it is null or empty
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateEndDateForChildEvent(p_event_no NUMBER, 
                                     p_n_daytime DATE DEFAULT NULL, 
                                     p_o_daytime DATE DEFAULT NULL, 
                                     p_n_end_date DATE, 
                                     p_o_end_date DATE, 
                                     p_iud_action VARCHAR2, 
                                     p_user VARCHAR2, 
                                     p_last_updated_date DATE)                                     
--</EC-DOC>
IS
  ld_parent_end_date DATE;
BEGIN

  BEGIN
    SELECT end_date
    INTO ld_parent_end_date
    FROM deferment_event
    WHERE event_no  = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
   
  IF ld_parent_end_date IS NULL THEN
    RETURN;
  END IF;

  UPDATE dv_well_deferment_child
  SET end_date = CASE WHEN end_date < ld_parent_end_date THEN end_date ELSE ld_parent_end_date END, last_updated_by =  p_user, last_updated_date = p_last_updated_date
  WHERE parent_event_no = p_event_no
  AND (end_date is null or end_date = '' or end_date <= NVL(p_o_end_date,end_date));

END updateEndDateForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : allocateGroupRateToWells
-- Description    : Allocates the group event deferment rate to all affected wells.
--
--
--
--
-- Preconditions  : Loss rate values from parent are allocated to child wells.
--
-- Postconditions : The loss rates of the child wells are updated.
--
-- Using tables   : deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       : -
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE allocateGroupRateToWells(p_event_no NUMBER,
                                   p_user_name VARCHAR2)
--</EC-DOC>
IS
  -- loss rates of parent
  CURSOR c_parent IS
  SELECT * from deferment_event w_parent where w_parent.event_no  = p_event_no and w_parent.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  -- total loss rates of all child that belongs to that parent
  CURSOR c_dt_potential_total IS
  SELECT  sum(OilProductionPotential)   as TotalOilProductionPotential,
          sum(GasProductionPotential)   as TotalGasProductionPotential,
          sum(GasInjectionPotential)    as TotalGasInjectionPotential,
          sum(ConProductionPotential)   as TotalConProductionPotential,
          sum(WaterProductionPotential) as TotalWaterProductionPotential,
          sum(WatInjectionPotential)    as TotalWatInjectionPotential,
          sum(SteamInjectionPotential)  as TotalSteamInjectionPotential,
          sum(DiluentPotential)         as TotalDiluentPotential,
          sum(GasLiftPotential)         as TotalGasLiftPotential,
          sum(OilMassProdPotential)     as TotalOilMassProdPotential,
          sum(GasMassProdPotential)     as TotalGasMassProdPotential,
          sum(CondMassProdPotential)    as TotalCondMassProdPotential,
          sum(WaterMassProdPotential)   as TotalWaterMassProdPotential
  FROM (
    SELECT well_dt.object_id, well_dt.daytime,
      nvl(well_dt.oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(well_dt.object_id, well_dt.daytime), null)) as OilProductionPotential,
      nvl(well_dt.gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(well_dt.object_id, well_dt.daytime), null)) as GasProductionPotential,
      nvl(well_dt.gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,'GI','OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(well_dt.object_id, well_dt.daytime), null)) as GasInjectionPotential,
      nvl(well_dt.cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findConProductionPotential(well_dt.object_id, well_dt.daytime), null)) as ConProductionPotential,
      nvl(well_dt.water_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(well_dt.object_id, well_dt.daytime), null)) as WaterProductionPotential,
      nvl(well_dt.water_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,'WI','OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(well_dt.object_id, well_dt.daytime), null)) as WatInjectionPotential,
      nvl(well_dt.steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,'SI','OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(well_dt.object_id, well_dt.daytime), null)) as SteamInjectionPotential,
      nvl(well_dt.diluent_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findDiluentPotential(well_dt.object_id, well_dt.daytime), null)) as DiluentPotential,
      nvl(well_dt.gas_lift_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findGasLiftPotential(well_dt.object_id, well_dt.daytime), null)) as GasLiftPotential,
      nvl(well_dt.oil_loss_mass, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findOilMassProdPotential(well_dt.object_id, well_dt.daytime), null)) as OilMassProdPotential,
      nvl(well_dt.gas_loss_mass, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findGasMassProdPotential(well_dt.object_id, well_dt.daytime), null)) as GasMassProdPotential,
      nvl(well_dt.cond_loss_mass, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findCondMassProdPotential(well_dt.object_id, well_dt.daytime), null)) as CondMassProdPotential,
      nvl(well_dt.water_loss_mass, decode(ecdp_well.isWellPhaseActiveStatus(well_dt.object_id,null,'OPEN',well_dt.daytime), 'Y', ecbp_well_potential.findWaterMassProdPotential(well_dt.object_id, well_dt.daytime), null)) as WaterMassProdPotential
    FROM deferment_event well_dt
    WHERE well_dt.parent_event_no = p_event_no
    AND well_dt.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'));

  -- Loss rate of each child that belongs to that parent
  CURSOR c_dt_potential IS
  SELECT well_dfmt.object_id, well_dfmt.daytime, well_dfmt.end_date,well_dfmt.event_no,
    nvl(well_dfmt.oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as OilProductionPotential,
    nvl(well_dfmt.gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as GasProductionPotential,
    nvl(well_dfmt.gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,'GI','OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as GasInjectionPotential,
    nvl(well_dfmt.cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findConProductionPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as ConProductionPotential,
    nvl(well_dfmt.water_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as WaterProductionPotential,
    nvl(well_dfmt.water_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,'WI','OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as WatInjectionPotential,
    nvl(well_dfmt.steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,'SI','OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as SteamInjectionPotential,
    nvl(well_dfmt.diluent_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findDiluentPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as DiluentPotential,
    nvl(well_dfmt.gas_lift_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findGasLiftPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as GasLiftPotential,
    nvl(well_dfmt.oil_loss_mass, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findOilMassProdPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as OilMassProdPotential, 
    nvl(well_dfmt.gas_loss_mass, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findGasMassProdPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as GasMassProdPotential,
    nvl(well_dfmt.cond_loss_mass, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findCondMassProdPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as CondMassProdPotential,
    nvl(well_dfmt.water_loss_mass, decode(ecdp_well.isWellPhaseActiveStatus(well_dfmt.object_id,null,'OPEN',well_dfmt.daytime), 'Y', ecbp_well_potential.findWaterMassProdPotential(well_dfmt.object_id, well_dfmt.daytime), null)) as WaterMassProdPotential 
  FROM deferment_event well_dfmt
  WHERE well_dfmt.parent_event_no = p_event_no
  AND well_dfmt.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  ln_well_oil_rate NUMBER;
  ln_well_gas_rate NUMBER;
  ln_well_cond_rate NUMBER;
  ln_well_water_rate NUMBER;
  ln_well_gas_inj_rate NUMBER;
  ln_well_water_inj_rate NUMBER;
  ln_well_steam_inj_rate NUMBER;
  lv2_object_id VARCHAR2(32);
  ld_daytime  DATE;
  lv2_last_update_date VARCHAR2(20);
  ln_well_diluent_rate NUMBER;
  ln_well_gas_lift_rate NUMBER;
  ln_well_oil_mass_rate NUMBER;
  ln_well_gas_mass_rate NUMBER;
  ln_well_cond_mass_rate NUMBER;
  ln_well_water_mass_rate NUMBER;  
  ld_valid_from_date DATE;
  ld_valid_to_date DATE;
  ue_flag CHAR;

BEGIN

  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS');
  ln_well_oil_rate := NULL;
  ln_well_gas_rate := NULL;
  ln_well_gas_inj_rate := NULL;
  ln_well_cond_rate := NULL;
  ln_well_water_rate :=NULL;
  ln_well_water_inj_rate := NULL;
  ln_well_steam_inj_rate := NULL;
  ln_well_diluent_rate := NULL;
  ln_well_gas_lift_rate := NULL;
  ln_well_oil_mass_rate := NULL; 
  ln_well_gas_mass_rate := NULL; 
  ln_well_cond_mass_rate := NULL;   
  ln_well_water_mass_rate := NULL;  

  lv2_object_id := ec_deferment_event.object_id(p_event_no);
  ld_daytime   := ec_deferment_event.daytime(p_event_no);
  -- ECPD 13176, Enhancement to Equip Off Deferment, 08.JAN.2010, Leongwen
  -- Followed Henk's comment to check for both Loss Volume and End Date and if one of them is missing, use Loss Rate.

  ld_valid_from_date := ec_deferment_event.daytime(p_event_no);
  ld_valid_to_date := ec_deferment_event.end_date(p_event_no);

  ue_deferment.allocateGroupRateToWells(p_event_no, p_user_name, ue_flag );
 
  IF (upper(ue_flag) = 'N') THEN
 
    checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

    FOR cur_parent IN c_parent LOOP
      FOR cur_total IN c_dt_potential_total LOOP
        FOR cur_potential IN c_dt_potential LOOP
          IF cur_total.TotalOilProductionPotential IS NOT NULL AND cur_total.TotalOilProductionPotential != 0 THEN
            IF cur_parent.oil_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_oil_rate := cur_parent.oil_loss_rate  * cur_potential.OilProductionPotential/cur_total.TotalOilProductionPotential;
            ELSE
              ln_well_oil_rate := (cur_parent.oil_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.OilProductionPotential/cur_total.TotalOilProductionPotential;
            END IF;
          ELSIF cur_total.TotalOilProductionPotential = 0 THEN
            ln_well_oil_rate := 0;
          END IF;
          IF cur_total.TotalGasProductionPotential IS NOT NULL AND cur_total.TotalGasProductionPotential != 0 THEN
            IF cur_parent.gas_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_gas_rate := cur_parent.gas_loss_rate  * cur_potential.GasProductionPotential/cur_total.TotalGasProductionPotential;
            ELSE
              ln_well_gas_rate := (cur_parent.gas_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.GasProductionPotential/cur_total.TotalGasProductionPotential;
            END IF;
          ELSIF cur_total.TotalGasProductionPotential = 0 THEN
            ln_well_gas_rate := 0;
          END IF;
          IF cur_total.TotalGasInjectionPotential IS NOT NULL AND cur_total.TotalGasInjectionPotential != 0 THEN
            IF cur_parent.gas_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_gas_inj_rate := cur_parent.gas_inj_loss_rate  * cur_potential.GasInjectionPotential/cur_total.TotalGasInjectionPotential;
            ELSE
              ln_well_gas_inj_rate := (cur_parent.gas_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.GasInjectionPotential/cur_total.TotalGasInjectionPotential;
            END IF;
          ELSIF cur_total.TotalGasInjectionPotential = 0 THEN
            ln_well_gas_inj_rate := 0;
          END IF;
          IF cur_total.TotalConProductionPotential IS NOT NULL AND cur_total.TotalConProductionPotential != 0 THEN
            IF cur_parent.cond_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_cond_rate:= cur_parent.cond_loss_rate  * cur_potential.ConProductionPotential/cur_total.TotalConProductionPotential;
            ELSE
              ln_well_cond_rate:= (cur_parent.cond_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.ConProductionPotential/cur_total.TotalConProductionPotential;
            END IF;
          ELSIF cur_total.TotalConProductionPotential = 0 THEN
            ln_well_cond_rate := 0;
          END IF;
          IF cur_total.TotalWaterProductionPotential IS NOT NULL AND cur_total.TotalWaterProductionPotential != 0 THEN
            IF cur_parent.water_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_water_rate:= cur_parent.water_loss_rate  * cur_potential.WaterProductionPotential/cur_total.TotalWaterProductionPotential;
            ELSE
              ln_well_water_rate:= (cur_parent.water_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.WaterProductionPotential/cur_total.TotalWaterProductionPotential;
            END IF;
          ELSIF cur_total.TotalWaterProductionPotential = 0 THEN
            ln_well_water_rate := 0;
          END IF;
          IF cur_total.TotalWatInjectionPotential IS NOT NULL AND cur_total.TotalWatInjectionPotential != 0 THEN
            IF cur_parent.water_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_water_inj_rate := cur_parent.water_inj_loss_rate  * cur_potential.WatInjectionPotential/cur_total.TotalWatInjectionPotential;
            ELSE
              ln_well_water_inj_rate := (cur_parent.water_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.WatInjectionPotential/cur_total.TotalWatInjectionPotential;
            END IF;
          ELSIF cur_total.TotalWatInjectionPotential = 0 THEN
            ln_well_water_inj_rate := 0;
          END IF;
          IF cur_total.TotalSteamInjectionPotential IS NOT NULL AND cur_total.TotalSteamInjectionPotential != 0 THEN
            IF cur_parent.steam_inj_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_steam_inj_rate := cur_parent.steam_inj_loss_rate  * cur_potential.SteamInjectionPotential/cur_total.TotalSteamInjectionPotential;
            ELSE
              ln_well_steam_inj_rate := (cur_parent.steam_inj_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',lv2_object_id, ld_daytime)) * cur_potential.SteamInjectionPotential/cur_total.TotalSteamInjectionPotential;
            END IF;
          ELSIF cur_total.TotalSteamInjectionPotential = 0 THEN
            ln_well_steam_inj_rate := 0;
          END IF;
          IF cur_total.TotalDiluentPotential IS NOT NULL AND cur_total.TotalDiluentPotential != 0 THEN
            IF cur_parent.diluent_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_diluent_rate := cur_parent.diluent_loss_rate  * cur_potential.DiluentPotential/cur_total.TotalDiluentPotential;
            ELSE
              ln_well_diluent_rate := (cur_parent.diluent_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.DiluentPotential/cur_total.TotalDiluentPotential;
            END IF;
          ELSIF cur_total.TotalDiluentPotential = 0 THEN
            ln_well_diluent_rate := 0;
          END IF;
          IF cur_total.TotalGasLiftPotential IS NOT NULL AND cur_total.TotalGasLiftPotential != 0 THEN
            IF cur_parent.gas_lift_loss_volume  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_gas_lift_rate := cur_parent.gas_lift_loss_rate  * cur_potential.GasLiftPotential/cur_total.TotalGasLiftPotential;
            ELSE
              ln_well_gas_lift_rate := (cur_parent.gas_lift_loss_volume/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.GasLiftPotential/cur_total.TotalGasLiftPotential;
            END IF;
          ELSIF cur_total.TotalGasLiftPotential = 0 THEN
            ln_well_gas_lift_rate := 0;
          END IF;
          IF cur_total.TotalOilMassProdPotential IS NOT NULL AND cur_total.TotalOilMassProdPotential != 0 THEN
            IF cur_parent.oil_loss_mass  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_oil_mass_rate := cur_parent.oil_loss_mass_rate  * cur_potential.OilMassProdPotential/cur_total.TotalOilMassProdPotential;
            ELSE
              ln_well_oil_mass_rate := (cur_parent.oil_loss_mass/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.OilMassProdPotential/cur_total.TotalOilMassProdPotential;
            END IF;
          ELSIF cur_total.TotalOilMassProdPotential = 0 THEN
            ln_well_oil_mass_rate := 0;
          END IF;
          IF cur_total.TotalGasMassProdPotential IS NOT NULL AND cur_total.TotalGasMassProdPotential != 0 THEN
            IF cur_parent.gas_loss_mass  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_gas_mass_rate := cur_parent.gas_loss_mass_rate  * cur_potential.GasMassProdPotential/cur_total.TotalGasMassProdPotential;
            ELSE
              ln_well_gas_mass_rate := (cur_parent.gas_loss_mass/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.GasMassProdPotential/cur_total.TotalGasMassProdPotential;
            END IF;
          ELSIF cur_total.TotalGasMassProdPotential = 0 THEN
            ln_well_gas_mass_rate := 0;
          END IF;
          IF cur_total.TotalCondMassProdPotential IS NOT NULL AND cur_total.TotalCondMassProdPotential != 0 THEN
            IF cur_parent.cond_loss_mass  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_cond_mass_rate := cur_parent.cond_loss_mass_rate  * cur_potential.CondMassProdPotential/cur_total.TotalCondMassProdPotential;
            ELSE
              ln_well_cond_mass_rate := (cur_parent.cond_loss_mass/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.CondMassProdPotential/cur_total.TotalCondMassProdPotential;
            END IF;
          ELSIF cur_total.TotalCondMassProdPotential = 0 THEN
            ln_well_cond_mass_rate := 0;
          END IF;
          IF cur_total.TotalWaterMassProdPotential IS NOT NULL AND cur_total.TotalWaterMassProdPotential != 0 THEN
            IF cur_parent.water_loss_mass  IS NULL OR cur_parent.end_date  IS NULL THEN
              ln_well_water_mass_rate := cur_parent.water_loss_mass_rate  * cur_potential.WaterMassProdPotential/cur_total.TotalWaterMassProdPotential;
            ELSE
              ln_well_water_mass_rate := (cur_parent.water_loss_mass/((cur_potential.end_date - cur_potential.daytime) * 24) * Ecdp_Timestamp.getNumHours('WELL',  lv2_object_id, ld_daytime)) * cur_potential.WaterMassProdPotential/cur_total.TotalWaterMassProdPotential;
            END IF;
          ELSIF cur_total.TotalWaterMassProdPotential = 0 THEN
            ln_well_water_mass_rate := 0;
          END IF;
      
          UPDATE deferment_event w
          SET w.oil_loss_rate        = ln_well_oil_rate,
              w.gas_loss_rate        = ln_well_gas_rate,
              w.gas_inj_loss_rate    = ln_well_gas_inj_rate,
              w.cond_loss_rate       = ln_well_cond_rate,
              w.water_loss_rate      = ln_well_water_rate,
              w.water_inj_loss_rate  = ln_well_water_inj_rate,
              w.steam_inj_loss_rate  = ln_well_steam_inj_rate,
              w.diluent_loss_rate    = ln_well_diluent_rate,
              w.gas_lift_loss_rate   = ln_well_gas_lift_rate,
              w.oil_loss_mass_rate   = ln_well_oil_mass_rate,
              w.gas_loss_mass_rate   = ln_well_gas_mass_rate,
              w.cond_loss_mass_rate  = ln_well_cond_mass_rate,
              w.water_loss_mass_rate = ln_well_water_mass_rate,
              w.last_updated_by      = p_user_name,
              w.last_updated_date    = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS')
          WHERE w.parent_event_no = p_event_no
          AND w.object_id = cur_potential.object_id
          AND w.daytime = cur_potential.daytime
          AND w.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
      
          EcDp_Deferment.insertTempWellDefermntAlloc(cur_potential.event_no, p_event_no, cur_potential.daytime, NULL, cur_potential.end_date, NULL, 'U', p_user_name, Ecdp_Timestamp.getCurrentSysdate);
                 
        END LOOP;
      END LOOP;
    END LOOP;
  END IF; 
END allocateGroupRateToWells;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : sumFromWells
-- Description    : Sums the loss rates from child events and updates the parent.
--
--
--
-- Preconditions  : --
--
-- Postconditions : Loss rates for parent are updated.
--
-- Using tables   : deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE sumFromWells(p_event_no NUMBER, p_user_name VARCHAR2 )
--</EC-DOC>
IS

  CURSOR c_dt_potential_total IS
  SELECT sum(OilProductionPotential)    as TotalOilProductionPotential,
         sum(GasProductionPotential)    as TotalGasProductionPotential,
         sum(GasInjectionPotential)     as TotalGasInjectionPotential,
         sum(ConProductionPotential)    as TotalConProductionPotential,
         sum(WaterProductionPotential)  as TotalWaterProductionPotential,
         sum(WatInjectionPotential)     as TotalWatInjectionPotential,
         sum(SteamInjectionPotential)   as TotalSteamInjectionPotential,
         sum(DiluentPotential)          as TotalDiluentPotential,
         sum(GasLiftPotential)          as TotalGasLiftPotential,
         sum(OilMassProdPotential)      as TotalOilMassProdPotential,
         sum(GasMassProdPotential)      as TotalGasMassProdPotential,
         sum(CondMassProdPotential)     as TotalCondMassProdPotential,
         sum(WaterMassProdPotential)    as TotalWaterMassProdPotential
  FROM (
      SELECT well_e_dt.object_id, well_e_dt.daytime,
      nvl(well_e_dt.oil_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findOilProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as OilProductionPotential,
      nvl(well_e_dt.gas_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as GasProductionPotential,
      nvl(well_e_dt.gas_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,'GI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasInjectionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as GasInjectionPotential,
      nvl(well_e_dt.cond_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findConProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as ConProductionPotential,
      nvl(well_e_dt.water_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findWatProductionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as WaterProductionPotential,
      nvl(well_e_dt.water_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,'WI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findWatInjectionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as WatInjectionPotential,
      nvl(well_e_dt.steam_inj_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,'SI','OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findSteamInjectionPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as SteamInjectionPotential,
      nvl(well_e_dt.diluent_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findDiluentPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as DiluentPotential,
      nvl(well_e_dt.gas_lift_loss_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasLiftPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as GasLiftPotential,
      nvl(well_e_dt.oil_loss_mass_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findOilMassProdPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as OilMassProdPotential,
      nvl(well_e_dt.gas_loss_mass_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findGasMassProdPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as GasMassProdPotential,
      nvl(well_e_dt.cond_loss_mass_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findCondMassProdPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as CondMassProdPotential,
      nvl(well_e_dt.water_loss_mass_rate, decode(ecdp_well.isWellPhaseActiveStatus(well_e_dt.object_id,null,'OPEN',well_e_dt.daytime), 'Y', ecbp_well_potential.findWaterMassProdPotential(well_e_dt.object_id, well_e_dt.daytime), null)) as WaterMassProdPotential
      FROM deferment_event well_e_dt
      WHERE well_e_dt.parent_event_no = p_event_no
      AND  well_e_dt.deferment_type = 'GROUP_CHILD'
      AND well_e_dt.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'));

  ln_well_oil_rate NUMBER;
  ln_well_gas_rate NUMBER;
  ln_well_cond_rate NUMBER;
  ln_well_water_rate NUMBER;
  ln_well_gas_inj_rate NUMBER;
  ln_well_water_inj_rate NUMBER;
  ln_well_steam_inj_rate NUMBER;
  ln_well_diluent_rate NUMBER;
  ln_well_gas_lift_rate NUMBER;
  ln_well_oil_mass_rate NUMBER;
  ln_well_gas_mass_rate NUMBER;
  ln_well_cond_mass_rate NUMBER;
  ln_well_water_mass_rate NUMBER;  
  lv2_object_id VARCHAR2(32);
  ln_event_loss_oil NUMBER := null;
  ln_event_loss_gas NUMBER := null;
  ln_event_loss_cond NUMBER := null;
  ln_event_loss_water NUMBER := null;
  ln_event_loss_water_inj NUMBER := null;
  ln_event_loss_steam_inj NUMBER := null;
  ln_event_loss_gas_inj NUMBER := null;
  ln_event_loss_diluent NUMBER := null;
  ln_event_loss_gas_lift NUMBER := null;
  ln_event_loss_oil_mass NUMBER := null;
  ln_event_loss_gas_mass NUMBER := null;
  ln_event_loss_cond_mass NUMBER := null;
  ln_event_loss_water_mass NUMBER := null;
  ln_diff     NUMBER := null;
  ln_chk_child NUMBER := null;
  ld_chk_parent_end_date DATE;

  ld_valid_from_date DATE;
  ld_valid_to_date DATE;
  lv_deferment_type deferment_event.deferment_type%TYPE;

BEGIN

  BEGIN
    SELECT object_id,daytime,end_date,deferment_type
    INTO lv2_object_id,ld_valid_from_date,ld_valid_to_date,lv_deferment_type
    FROM deferment_event
    WHERE event_no  = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  EXCEPTION
    WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20226, 'An error occurred while fetching data for event no- '||p_event_no);
  END;

  checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

  ln_event_loss_oil := EcBp_Deferment.getParentEventLossRate(p_event_no, 'OIL',lv_deferment_type);
  ln_event_loss_gas := EcBp_Deferment.getParentEventLossRate(p_event_no, 'GAS',lv_deferment_type);
  ln_event_loss_cond := EcBp_Deferment.getParentEventLossRate(p_event_no, 'COND',lv_deferment_type);
  ln_event_loss_water := EcBp_Deferment.getParentEventLossRate(p_event_no, 'WATER',lv_deferment_type);
  ln_event_loss_water_inj := EcBp_Deferment.getParentEventLossRate(p_event_no, 'WAT_INJ',lv_deferment_type);
  ln_event_loss_steam_inj := EcBp_Deferment.getParentEventLossRate(p_event_no, 'STEAM_INJ',lv_deferment_type);
  ln_event_loss_gas_inj := EcBp_Deferment.getParentEventLossRate(p_event_no, 'GAS_INJ',lv_deferment_type);
  ln_event_loss_diluent := EcBp_Deferment.getParentEventLossRate(p_event_no, 'DILUENT',lv_deferment_type);
  ln_event_loss_gas_lift := EcBp_Deferment.getParentEventLossRate(p_event_no, 'GAS_LIFT',lv_deferment_type);
  ln_event_loss_oil_mass := EcBp_Deferment.getParentEventLossMassRate(p_event_no, 'OIL',lv_deferment_type);
  ln_event_loss_gas_mass := EcBp_Deferment.getParentEventLossMassRate(p_event_no, 'GAS',lv_deferment_type);
  ln_event_loss_cond_mass := EcBp_Deferment.getParentEventLossMassRate(p_event_no, 'COND',lv_deferment_type);
  ln_event_loss_water_mass := EcBp_Deferment.getParentEventLossMassRate(p_event_no, 'WATER',lv_deferment_type);
    
  ln_diff := abs((ld_valid_to_date - ld_valid_from_date)*24);
  ld_chk_parent_end_date := ld_valid_to_date;

  SELECT COUNT(1) INTO ln_chk_child
  FROM deferment_event
  WHERE parent_event_no = p_event_no
  AND deferment_type = 'GROUP_CHILD'
  AND (daytime >= ld_valid_from_date OR (end_date < ld_valid_to_date OR (ld_valid_to_date IS NULL AND end_date IS NOT NULL)))
  AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  FOR cur_potential IN c_dt_potential_total LOOP
    IF (ln_chk_child > 0) AND
        ld_chk_parent_end_date IS NOT NULL THEN

      ln_well_oil_rate := (ln_event_loss_oil * 24/ln_diff);
      ln_well_gas_rate := (ln_event_loss_gas * 24/ln_diff);
      ln_well_gas_inj_rate := (ln_event_loss_gas_inj * 24/ln_diff);
      ln_well_cond_rate := (ln_event_loss_cond * 24/ln_diff);
      ln_well_water_rate := (ln_event_loss_water * 24/ln_diff);
      ln_well_water_inj_rate := (ln_event_loss_water_inj * 24/ln_diff);
      ln_well_steam_inj_rate := (ln_event_loss_steam_inj * 24/ln_diff);
      ln_well_diluent_rate := (ln_event_loss_diluent * 24/ln_diff);
      ln_well_gas_lift_rate := (ln_event_loss_gas_lift * 24/ln_diff);
      ln_well_oil_mass_rate := (ln_event_loss_oil_mass * 24/ln_diff);
      ln_well_gas_mass_rate := (ln_event_loss_gas_mass * 24/ln_diff);
      ln_well_cond_mass_rate := (ln_event_loss_cond_mass * 24/ln_diff);
      ln_well_water_mass_rate := (ln_event_loss_water_mass * 24/ln_diff);

    ELSE

      ln_well_oil_rate        := cur_potential.totaloilproductionpotential;
      ln_well_gas_rate        := cur_potential.totalgasproductionpotential;
      ln_well_gas_inj_rate    := cur_potential.totalgasinjectionpotential;
      ln_well_cond_rate       := cur_potential.totalconproductionpotential;
      ln_well_water_rate      := cur_potential.totalwaterproductionpotential;
      ln_well_water_inj_rate  := cur_potential.totalwatinjectionpotential;
      ln_well_steam_inj_rate  := cur_potential.totalsteaminjectionpotential;
      ln_well_diluent_rate    := cur_potential.TotalDiluentPotential;
      ln_well_gas_lift_rate   := cur_potential.TotalGasLiftPotential;
      ln_well_oil_mass_rate   := cur_potential.TotalOilMassProdPotential;      
      ln_well_gas_mass_rate   := cur_potential.TotalGasMassProdPotential;    
      ln_well_cond_mass_rate  := cur_potential.TotalCondMassProdPotential;     
      ln_well_water_mass_rate := cur_potential.TotalWaterMassProdPotential;      

     END IF;
  END LOOP;

  UPDATE deferment_event w
  SET w.oil_loss_rate        = ln_well_oil_rate,
      w.gas_loss_rate        = ln_well_gas_rate,
      w.gas_inj_loss_rate    = ln_well_gas_inj_rate,
      w.cond_loss_rate       = ln_well_cond_rate,
      w.water_loss_rate      = ln_well_water_rate,
      w.water_inj_loss_rate  = ln_well_water_inj_rate,
      w.steam_inj_loss_rate  = ln_well_steam_inj_rate,
      w.diluent_loss_rate    = ln_well_diluent_rate,
      w.gas_lift_loss_rate   = ln_well_gas_lift_rate,
      w.oil_loss_mass_rate   = ln_well_oil_mass_rate,
      w.gas_loss_mass_rate   = ln_well_gas_mass_rate,
      w.cond_loss_mass_rate  = ln_well_cond_mass_rate,      
      w.water_loss_mass_rate = ln_well_water_mass_rate,      
      w.last_updated_by     = p_user_name
  WHERE w.event_no = p_event_no
  AND w.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  ue_Deferment.sumFromWells(p_event_no, p_user_name);

END sumFromWells;


--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateStartDateForChildEvent
-- Description    : Update start date of child
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateStartDateForChildEvent(p_event_no NUMBER, 
                                       p_n_start_date DATE,  
                                       p_o_start_date DATE,
                                       p_n_end_date DATE DEFAULT NULL, 
                                       p_o_end_date DATE DEFAULT NULL, 
                                       p_iud_action VARCHAR2, 
                                       p_user VARCHAR2, 
                                       p_last_updated_date DATE)                                     
--</EC-DOC>
IS
  ld_parent_start_date DATE;
BEGIN
  BEGIN
    SELECT daytime
    INTO ld_parent_start_date
    FROM deferment_event
    WHERE event_no  = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  UPDATE dv_well_deferment_child
  SET daytime = CASE WHEN daytime > ld_parent_start_date THEN daytime ELSE ld_parent_start_date END, last_updated_by =  p_user, last_updated_date = p_last_updated_date
  WHERE parent_event_no = p_event_no
  AND daytime <= p_o_start_date;

END updateStartDateForChildEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : insertTempWellDefermntAlloc
-- Description    : Insert/updated record when record in deferment_event inserted or updated.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : TEMP_WELL_DEFERMENT_ALLOC
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------

PROCEDURE insertTempWellDefermntAlloc(p_event_no NUMBER, p_parent_event_no NUMBER DEFAULT NULL, p_n_daytime DATE, p_o_daytime DATE DEFAULT NULL, p_n_end_date DATE DEFAULT NULL, p_o_end_date DATE DEFAULT NULL, p_iud_action VARCHAR2, p_user_name VARCHAR2, p_last_updated_date date)
--</EC-DOC>
IS
  CURSOR cur_sameRow IS
  SELECT COUNT(*) AS sameRowCnt
  FROM TEMP_WELL_DEFERMENT_ALLOC a
  WHERE NVL(a.event_no,0)        = NVL(p_event_no,0) 
  AND NVL(a.parent_event_no,0)   = NVL(p_parent_event_no,0)
  AND NVL(a.new_daytime, TO_DATE('1900-01-01', 'YYYY-MM-DD'))  = NVL(p_n_daytime, TO_DATE('1900-01-01', 'YYYY-MM-DD'))
  AND NVL(a.old_daytime, TO_DATE('1900-01-01', 'YYYY-MM-DD'))  = NVL(p_o_daytime, TO_DATE('1900-01-01', 'YYYY-MM-DD'))
  AND NVL(a.new_end_date, TO_DATE('2100-01-01', 'YYYY-MM-DD')) = NVL(p_n_end_date, TO_DATE('2100-01-01', 'YYYY-MM-DD'))
  AND NVL(a.old_end_date, TO_DATE('2100-01-01', 'YYYY-MM-DD')) = NVL(p_o_end_date, TO_DATE('2100-01-01', 'YYYY-MM-DD'))
  AND a.iud_action = p_iud_action;
  ln_rowCount    NUMBER;
BEGIN
  -- This is to skip the duplicate same event to be placed in the temp_well_deferment_alloc for recalculation, and to improve the performance on calculations.
  FOR rowCur IN cur_sameRow LOOP
    ln_rowCount := rowCur.sameRowCnt;
  END LOOP;
  IF NVL(ln_rowCount,0) = 0 THEN 
    INSERT INTO TEMP_WELL_DEFERMENT_ALLOC (event_no, parent_event_no, new_daytime, old_daytime, new_end_date, old_end_date, iud_action, last_updated_by, last_updated_date)
    VALUES (p_event_no, p_parent_event_no, p_n_daytime, p_o_daytime, p_n_end_date, p_o_end_date, p_iud_action, p_user_name, p_last_updated_date);
  END IF;      
END insertTempWellDefermntAlloc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : reCalcDeferments
-- Description    : Procedure used to recalculate the deferment values in allocation table
--
-- Using tables   : deferment_event (READ), well_day_defer_alloc (WRITE)
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE reCalcDeferments(p_object_id VARCHAR2 DEFAULT NULL,p_nav_group_type VARCHAR2 DEFAULT NULL,p_nav_parent_class_name VARCHAR2 DEFAULT NULL,p_deferment_version VARCHAR2 DEFAULT NULL) IS
  -- Query the TEMP_WELL_DEFERMEMT_ALLOC table for all admendments on deferment_event table for all IUD actions
  CURSOR c_temp_alloc_recs IS
  SELECT a.event_no,
         LEAST(a.new_daytime, NVL(a.old_daytime, a.new_daytime)) daytime,
         GREATEST(a.new_end_date, NVL(a.old_end_date, a.new_end_date)) end_date
  FROM TEMP_WELL_DEFERMENT_ALLOC a
  ORDER BY daytime ASC;

  -- exclude the deferments belonged to fcty_class_2 when fcty_class_1 being used to calculate deferments
  -- exclude the deferments belonged to operator_route when collection_point being used to calculate deferments
  CURSOR c1_temp_alloc_recs_object_id (cp_nav_group_type VARCHAR2, cp_parent_classname VARCHAR2, cp_grandparent_classname VARCHAR2 ) IS 
  SELECT a.event_no,
         LEAST(a.new_daytime, NVL(a.old_daytime, a.new_daytime)) daytime,
         GREATEST(a.new_end_date, NVL(a.old_end_date, a.new_end_date)) end_date
  FROM TEMP_WELL_DEFERMENT_ALLOC a
  WHERE a.event_no IN 
    (SELECT b.event_no 
     FROM deferment_event  b
     WHERE (b.object_id=p_object_id AND b.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'))
     OR b.parent_object_id=p_object_id
     OR p_object_id=ecgp_group.findParentObjectId(cp_nav_group_type,
                                                  cp_parent_classname,
                                                  'WELL',
                                                  b.OBJECT_ID,
                                                  b.DAYTIME) 
     OR (b.parent_object_id IN (SELECT o.OBJECT_ID
                                FROM EQPM_VERSION oa
                                INNER JOIN EQUIPMENT o ON o.object_id = oa.object_id
                                AND (oa.OP_FCTY_CLASS_1_ID = p_object_id OR 
                                     oa.CP_COL_POINT_ID = p_object_id)
                                AND oa.DAYTIME  <= b.DAYTIME
                                AND NVL(oa.END_DATE, NVL(b.END_DATE,b.daytime)+1) >= NVL(b.END_DATE, b.DAYTIME+1)
                                )
        )                                                  
    )
     AND a.event_no NOT IN                                                  
    (SELECT c.event_no
     FROM deferment_event  c
     WHERE ecdp_objects.GetObjClassName(c.parent_object_id) = cp_grandparent_classname 
     AND ecdp_objects.GetObjClassName(p_object_id) = cp_parent_classname 
     AND p_object_id=ecgp_group.findParentObjectId(cp_nav_group_type,
                                                   cp_parent_classname,
                                                   'WELL',
                                                   c.OBJECT_ID,
                                                   c.DAYTIME)
     AND c.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD')                                                   
    )                                                  
  ORDER BY daytime ASC;
  
  CURSOR c2_temp_alloc_recs_object_id (cp_nav_group_type VARCHAR2, cp_parent_classname VARCHAR2 ) IS 
  SELECT a.event_no,
         LEAST(a.new_daytime, NVL(a.old_daytime, a.new_daytime)) daytime,
         GREATEST(a.new_end_date, NVL(a.old_end_date, a.new_end_date)) end_date
  FROM TEMP_WELL_DEFERMENT_ALLOC a
  WHERE a.event_no IN 
    (SELECT b.event_no 
     FROM deferment_event  b
     WHERE (b.object_id=p_object_id AND b.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'))
     OR b.parent_object_id=p_object_id
     OR p_object_id=ecgp_group.findParentObjectId(cp_nav_group_type,
                                                  cp_parent_classname,
                                                  'WELL',
                                                  b.OBJECT_ID,
                                                  b.DAYTIME) 
     OR (b.parent_object_id IN (SELECT o.OBJECT_ID
                                FROM EQPM_VERSION oa
                                INNER JOIN EQUIPMENT o ON o.object_id = oa.object_id
                                AND (oa.OP_FCTY_CLASS_1_ID = p_object_id OR 
                                     oa.CP_COL_POINT_ID = p_object_id)
                                AND oa.DAYTIME  <= b.DAYTIME
                                AND NVL(oa.END_DATE, NVL(b.END_DATE,b.daytime)+1) >= NVL(b.END_DATE, b.DAYTIME+1)
                                )
        )                                                  
    )
  ORDER BY daytime ASC;  
  
  lv2_nav_classname    VARCHAR2(32);
  lv2_grandparent_classname VARCHAR2(32);
  ln_run_no NUMBER:=ECDP_SYSTEM_KEY.assignNextNumber('CALC_DEFERMENT_LOG');
  ld_start_date DATE;
  ld_end_date DATE;
BEGIN
  EcDp_Deferment_Log.getStartEndDate(p_object_id, p_nav_group_type, p_nav_parent_class_name, p_deferment_version, ld_start_date, ld_end_date);
  EcDp_Deferment_Log.insertStatusLog(ln_run_no, ld_start_date, ld_end_date);
  IF (p_object_id IS NOT NULL) THEN
    --p_object_id is the last navigator object_id selected at the well deferment screen.
    IF ecdp_objects.GetObjClassName(p_object_id) = 'WELL' THEN
      lv2_nav_classname := p_nav_parent_class_name;
    ELSE -- 'WELL_HOOKUP, FCTY_CLASS_1 or even higher parent level of FCTY_CLASS_2, AREA or PRODUCTIONUNIT'
      lv2_nav_classname := ecdp_objects.GetObjClassName(p_object_id);
    END IF;
    IF lv2_nav_classname IN ('FCTY_CLASS_1', 'COLLECTION_POINT') THEN
      lv2_grandparent_classname := 
        CASE 
          WHEN lv2_nav_classname = 'FCTY_CLASS_1' THEN 'FCTY_CLASS_2'
          WHEN lv2_nav_classname = 'COLLECTION_POINT' THEN 'OPERATOR_ROUTE'
        END;
      FOR mycur IN c1_temp_alloc_recs_object_id(p_nav_group_type, lv2_nav_classname, lv2_grandparent_classname ) LOOP
        IF mycur.event_no IS NOT NULL THEN
          -- Leave all the validations to be done inside the calcDeferments procedure as a single control area.
          EcDp_Deferment.calcDeferments(mycur.event_no, NULL, mycur.daytime, mycur.end_date, p_object_id, p_deferment_version, NULL, NULL );
          DELETE FROM TEMP_WELL_DEFERMENT_ALLOC WHERE event_no=mycur.event_no and exists (select 1 from deferment_event e where e.event_no=mycur.event_no and e.end_date is not null);
        END IF;
      END LOOP;
    ELSE -- (when classname rank is higher than immediate parent object FCTY_CLASS_1)  
      FOR mycur IN c2_temp_alloc_recs_object_id(p_nav_group_type, lv2_nav_classname ) LOOP
        IF mycur.event_no IS NOT NULL THEN
          -- Leave all the validations to be done inside the calcDeferments procedure as a single control area.
          EcDp_Deferment.calcDeferments(mycur.event_no, NULL, mycur.daytime, mycur.end_date, p_object_id, p_deferment_version, p_nav_group_type, lv2_nav_classname );
          DELETE FROM TEMP_WELL_DEFERMENT_ALLOC WHERE event_no=mycur.event_no and exists (select 1 from deferment_event e where e.event_no=mycur.event_no and e.end_date is not null);
        END IF;
      END LOOP;
    END IF;  
  ELSE 
    FOR mycur IN c_temp_alloc_recs LOOP
      IF mycur.event_no IS NOT NULL THEN
         -- Leave all the validations to be done inside the calcDeferments procedure as a single control area.
        EcDp_Deferment.calcDeferments(mycur.event_no, NULL, mycur.daytime, mycur.end_date, p_object_id, p_deferment_version, NULL, NULL );
        DELETE FROM TEMP_WELL_DEFERMENT_ALLOC WHERE event_no=mycur.event_no and exists (select 1 from deferment_event e where e.event_no=mycur.event_no and e.end_date is not null);
      END IF;
    END LOOP;
  END IF;
  EcDp_Deferment_Log.updateStatusLog(ln_run_no,CASE ld_start_date WHEN '01-JAN-1900' THEN 'NO_CALC' ELSE 'SUCCESS' END);
  EXCEPTION WHEN OTHERS THEN
  EcDp_Deferment_Log.updateStatusLog(ln_run_no,'FAILURE');
  RAISE_APPLICATION_ERROR(-20000,'An error was encountered calculating the deferment event loss - ' || SQLCODE || ' -ERROR- ' || SQLERRM); 
END reCalcDeferments;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcDeferments
-- Description    : Procedure used to calculate the deferment values in allocation table
--
-- Using tables   : deferment_event (READ), well_day_defer_alloc (WRITE)
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
---------------------------------------------------------------------------------------------------
--</EC-DOC>
PROCEDURE calcDeferments(p_event_no VARCHAR2,
                         p_asset_id VARCHAR2 DEFAULT NULL,
                         p_from_date DATE DEFAULT NULL,
                         p_to_date DATE DEFAULT NULL,
                         p_object_id VARCHAR2 DEFAULT NULL,
                         p_deferment_version VARCHAR2 DEFAULT NULL,
                         p_nav_group_type VARCHAR2 DEFAULT NULL,
                         p_nav_classname VARCHAR2 DEFAULT NULL) IS

  -- Query the deferment_event table for parent event_no with object_type = 'EQPM'
  CURSOR c_EqpmParentEventNo (cp_event_no NUMBER) IS
  SELECT a.parent_event_no
  FROM deferment_event a
  WHERE a.event_no = cp_event_no
  AND a.parent_event_no IN (SELECT b.event_no
                            FROM deferment_event b
                            WHERE b.event_no = a.parent_event_no
                            AND b.object_type = 'EQPM');
                         
  -- get list of wells directly from deferment event_no
  CURSOR c_deferment_event IS
  SELECT object_id, day, end_day
  FROM deferment_event
  WHERE event_no = p_event_no
  AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

   -- This cursor filters records for selected facility
  CURSOR c_deferment_event_fcty (cp_EqpmParentEventNo NUMBER) IS
  SELECT wd.object_id, least(wd.day,p_from_date) day, greatest(wd.end_day, p_to_date) end_day
  FROM deferment_event wd, well_version wv
  WHERE wd.object_id= wv.object_id AND 
        wd.event_no = p_event_no AND 
        wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD') AND 
        p_from_date >= wv.daytime AND
        NVL(p_to_date,wv.daytime) < NVL(wv.end_date, NVL(p_to_date,wv.daytime)+ 1) AND       
        ((wd.parent_object_id = p_object_id) OR 
         (wd.object_id = p_object_id) OR 
         (p_object_id = ecgp_group.findParentObjectId(p_nav_group_type, p_nav_classname, 'WELL', wd.object_id, wd.daytime)) OR
          wv.op_fcty_class_1_id = p_object_id) OR
         (wd.parent_event_no = cp_EqpmParentEventNo AND
          wd.object_id= wv.object_id)         
  UNION
  SELECT wd.object_id, least(wd.day,p_from_date) day, greatest(wd.end_day, p_to_date) end_day
  FROM deferment_event wd, well_version wv
  WHERE wd.object_id= wv.object_id AND
        wd.event_no = p_event_no AND
        wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD') AND 
        p_from_date >= wv.daytime AND
        NVL(p_to_date,wv.daytime) < NVL(wv.end_date, NVL(p_to_date,wv.daytime)+ 1) AND
        ((wd.parent_object_id=p_object_id) OR 
         (wd.object_id = p_object_id) OR       
         (p_object_id = ecgp_group.findParentObjectId(p_nav_group_type, p_nav_classname, 'WELL', wd.object_id, wd.daytime)) OR
          wv.cp_col_point_id = p_object_id) OR
         (wd.parent_event_no = cp_EqpmParentEventNo AND           
          wd.object_id= wv.object_id)           
  UNION
  SELECT wd.object_id, least(wd.day,p_from_date) day, greatest(wd.end_day, p_to_date) end_day
  FROM deferment_event wd, well_version wv
  WHERE wd.object_id= wv.object_id AND
        wd.event_no = p_event_no AND
        wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD') AND
        p_from_date >= wv.daytime AND
        NVL(p_to_date,wv.daytime) < NVL(wv.end_date, NVL(p_to_date,wv.daytime)+ 1) AND
        ((wd.parent_object_id=p_object_id) OR
         (wd.object_id = p_object_id) OR 
         (p_object_id = ecgp_group.findParentObjectId(p_nav_group_type, p_nav_classname, 'WELL', wd.object_id, wd.daytime)) OR
          wv.geo_field_id = p_object_id) OR
         (wd.parent_event_no = cp_EqpmParentEventNo AND           
          wd.object_id= wv.object_id);
         
  -- maybe this cursor is faster than having one query with a long "OR" for asset_type
  CURSOR c_wells(cp_asset_type VARCHAR2) IS
  SELECT object_id
  FROM well_version wv
  WHERE p_from_date >= wv.daytime AND
        p_to_date < NVL(wv.end_date, p_to_date + 1) AND
        wv.op_pu_id = p_asset_id AND cp_asset_type = 'PRODUCTIONUNIT'
  UNION
  SELECT object_id
  FROM well_version wv
  WHERE p_from_date >= wv.daytime AND
        p_to_date < NVL(wv.end_date, p_to_date + 1) AND
        wv.op_sub_pu_id = p_asset_id AND cp_asset_type = 'PROD_SUB_UNIT'
  UNION
  SELECT object_id
  FROM well_version wv
  WHERE p_from_date >= wv.daytime AND
        p_to_date < NVL(wv.end_date, p_to_date + 1) AND
        wv.op_area_id = p_asset_id AND cp_asset_type = 'AREA'
  UNION
  SELECT object_id
  FROM well_version wv
  WHERE p_from_date >= wv.daytime AND
        p_to_date < NVL(wv.end_date, p_to_date + 1) AND
        wv.op_sub_area_id = p_asset_id AND cp_asset_type = 'SUB_AREA'
  UNION
  SELECT object_id
  FROM well_version wv
  WHERE p_from_date >= wv.daytime AND
        p_to_date < NVL(wv.end_date, p_to_date + 1) AND
        wv.op_fcty_class_2_id = p_asset_id AND cp_asset_type = 'FCTY_CLASS_2'
  UNION
  SELECT object_id
  FROM well_version wv
  WHERE p_from_date >= wv.daytime AND
        p_to_date < NVL(wv.end_date, p_to_date + 1) AND
        wv.op_fcty_class_1_id = p_asset_id AND cp_asset_type = 'FCTY_CLASS_1'
  UNION
  SELECT object_id
  FROM well_version wv
  WHERE p_from_date >= wv.daytime AND
        p_to_date < NVL(wv.end_date, p_to_date + 1) AND
        wv.op_well_hookup_id = p_asset_id AND cp_asset_type = 'WELL_HOOKUP';

  lv2_deferment_version VARCHAR2(32);
  lv2_asset_type        VARCHAR2(32);
  ld_start_daytime      DATE;
  ue_flag CHAR;
  ln_EqpmParentEventNo  NUMBER;

BEGIN
  ue_deferment.calcDeferments(p_event_no, p_asset_id, p_from_date, p_to_date,ue_flag);
  IF (upper(ue_flag) = 'N') THEN
  
  -- get deferment version from ctrl_system_attributes
  lv2_deferment_version := NVL(p_deferment_version,ec_ctrl_system_attribute.attribute_text(nvl(p_from_date, Ecdp_Timestamp.getCurrentSysdate), 'DEFERMENT_VERSION', '<='));
  IF lv2_deferment_version = 'PD.0020' THEN 
    -- New Deferment screen = 'PD.0020'
    IF (p_object_id IS NOT NULL AND p_event_no IS NOT NULL) THEN
      --Run for selected facility
      -- loop all wells available under selected facility
      FOR mycur1 IN c_EqpmParentEventNo (p_event_no) LOOP
        ln_EqpmParentEventNo := mycur1.parent_event_no;
      END LOOP;
      FOR mycur IN c_deferment_event_fcty (ln_EqpmParentEventNo) LOOP
        ld_start_daytime := Ecdp_Productionday.getProductionDayStart('WELL',mycur.object_id,mycur.day);
        IF EcDp_month_lock.withinLockedMonth(ld_start_daytime) IS NOT NULL THEN
            EcDp_Month_Lock.raiseValidationError('UPDATING', ld_start_daytime, ld_start_daytime, TRUNC(ld_start_daytime,'MONTH'), 'Cannot calculate deferments for a locked month.');
        END IF;
        EcDp_Month_Lock.localLockCheck('withinLockedMonth', mycur.object_id,
                                      ld_start_daytime, ld_start_daytime,
                                      'INSERTING', 'EcDp_Deferment.allocWellDeferredVolume: Cannot update the deferment allocation table in a locked local month.');
        IF NVL(ecdp_ctrl_property.getSystemProperty('DEFERMENT_OPEN_EVENT_CALC',TRUNC(Ecdp_Timestamp.getCurrentSysdate())),'Y')='Y' THEN                              
           allocWellDeferredVolume(mycur.object_id, mycur.day, NVL(mycur.end_day, TO_DATE(TO_CHAR(Ecdp_Productionday.getProductionDayStart('WELL',mycur.object_id,TRUNC(Ecdp_Timestamp.getCurrentSysdate,'DD')-1),'YYYY-MM-DD"T"HH24:MI'),'YYYY-MM-DD"T"HH24:MI') ) ); -- default is until SYSDATE-1 if event is open
        ELSE
          IF(mycur.end_day IS NOT NULL) THEN
            allocWellDeferredVolume(mycur.object_id, mycur.day, mycur.end_day); 
          END IF;           
        END IF;
      END LOOP;
    ELSIF (p_event_no IS NOT NULL AND p_object_id IS NULL ) THEN -- run for an event or an asset in the operational group model
      -- run for an event only
      -- loop all wells for the event_no and calculate deferments for all days between DAY and END_DAY
      FOR mycur IN c_deferment_event LOOP
        ld_start_daytime := Ecdp_Productionday.getProductionDayStart('WELL',mycur.object_id,mycur.day);
        IF EcDp_month_lock.withinLockedMonth(ld_start_daytime) IS NOT NULL THEN
            EcDp_Month_Lock.raiseValidationError('UPDATING', ld_start_daytime, ld_start_daytime, TRUNC(ld_start_daytime,'MONTH'), 'Cannot calculate deferments for a locked month.');
        END IF;
        EcDp_Month_Lock.localLockCheck('withinLockedMonth', mycur.object_id,
                                      ld_start_daytime, ld_start_daytime,
                                      'INSERTING', 'EcDp_Deferment.allocWellDeferredVolume: Cannot update the deferment allocation table in a locked local month.');
        IF NVL(ecdp_ctrl_property.getSystemProperty('DEFERMENT_OPEN_EVENT_CALC',TRUNC(Ecdp_Timestamp.getCurrentSysdate())),'Y')='Y' THEN                              
           allocWellDeferredVolume(mycur.object_id, mycur.day, NVL(mycur.end_day, TO_DATE(TO_CHAR(Ecdp_Productionday.getProductionDayStart('WELL',mycur.object_id,TRUNC(Ecdp_Timestamp.getCurrentSysdate,'DD')-1),'YYYY-MM-DD"T"HH24:MI'),'YYYY-MM-DD"T"HH24:MI') )); -- default is until SYSDATE-1 if event is open
        ELSE
          IF(mycur.end_day IS NOT NULL) THEN
            allocWellDeferredVolume(mycur.object_id, mycur.day, mycur.end_day); 
          END IF;           
        END IF;
      END LOOP;
    ELSIF (p_asset_id IS NOT NULL AND p_from_date IS NOT NULL) THEN
      lv2_asset_type := ecdp_objects.GetObjClassName(p_asset_id);
      FOR mycur IN c_wells(lv2_asset_type) LOOP
        allocWellDeferredVolume(mycur.object_id, p_from_date, NVL(p_to_date,p_from_date)); -- default is one day
      END LOOP;
    ELSE
      NULL; -- wrong parameters
    END IF;
  END IF;
  END IF;
END calcDeferments;

--<EC-DOC>
----------------------------------------------------------------------------------------------------------------------------------
-- Procedure      : allocWellDeferredVolume
-- Description    : Procedure used to calculate the deferment values for a well and period and output to the allocation table
--
-- Using tables   : deferment_event (READ), well_day_defer_alloc (WRITE)
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
----------------------------------------------------------------------------------------------------------------------------------
--</EC-DOC>

PROCEDURE allocWellDeferredVolume(p_object_id VARCHAR2, p_from_date DATE, p_to_date DATE ) IS

  CURSOR c_off_def_cnt_open (cp_day DATE ) IS
  SELECT count(*) as off_def_cnt
  FROM deferment_event wd
  WHERE wd.object_id = p_object_id
  AND (wd.day = cp_day OR
      (wd.day < cp_day AND (wd.end_day IS NULL OR wd.end_day >= cp_day)))
  AND wd.event_type = 'DOWN'
  AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  CURSOR c_off_def_cnt_closed (cp_day DATE ) IS
  SELECT count(*) as off_def_cnt
  FROM deferment_event wd
  WHERE wd.object_id = p_object_id
  AND wd.day <= cp_day AND wd.end_day >= cp_day
  AND wd.event_type = 'DOWN'
  AND wd.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  ld_ProdFromDay   DATE  := Ecdp_Productionday.getProductionDay('WELL',p_object_id,p_from_date);
  ld_ProdToDay     DATE  := Ecdp_Productionday.getProductionDay('WELL',p_object_id,p_to_date) ;
  
  CURSOR c_event_days IS
  SELECT ld_ProdFromDay - 1 + LEVEL AS daytime 
  FROM CTRL_DB_VERSION 
  WHERE DB_VERSION = 1
  CONNECT BY LEVEL <= (ld_ProdToDay - ld_ProdFromDay)+1;
  
  ln_count NUMBER;
  ln_rowcount NUMBER;
  i NUMBER;
  ln_duration NUMBER;
  ld_start_daytime DATE;

  TYPE myRec IS RECORD (event_no NUMBER,
                        daytime DATE,
                        end_date DATE,
                        oil_loss_rate NUMBER,
                        gas_loss_rate NUMBER,
                        water_loss_rate NUMBER,
                        cond_loss_rate NUMBER,
                        diluent_loss_rate NUMBER,
                        gas_lift_loss_rate NUMBER,
                        water_inj_loss_rate NUMBER,
                        gas_inj_loss_rate NUMBER,
                        steam_inj_loss_rate NUMBER,
                        oil_loss_mass_rate NUMBER,
                        gas_loss_mass_rate NUMBER,
                        cond_loss_mass_rate NUMBER,
                        water_loss_mass_rate NUMBER,
                        loss_oil NUMBER,
                        loss_gas NUMBER,
                        loss_water NUMBER,
                        loss_cond NUMBER,
                        loss_diluent NUMBER,
                        loss_gas_lift NUMBER,
                        loss_water_inj NUMBER,
                        loss_gas_inj NUMBER,
                        loss_steam_inj NUMBER,
                        loss_oil_mass NUMBER,
                        loss_gas_mass NUMBER,
                        loss_cond_mass NUMBER,
                        loss_water_mass NUMBER,
                        event_type VARCHAR2(32)
                        );
  TYPE myTable IS TABLE OF myRec INDEX BY BINARY_INTEGER;

  lr_defer_event myTable;

  ln_ctrl_duration NUMBER;
  ld_MaxEnd_date DATE;

  ln_off_def_cnt NUMBER;
  lb_found_off_def BOOLEAN;
  ln_constraint_hrs number;

  ln_oil_down_duration NUMBER; ln_gas_down_duration NUMBER; ln_water_down_duration NUMBER; ln_cond_down_duration NUMBER; ln_diluent_down_duration NUMBER; ln_gas_lift_down_duration NUMBER;
  ln_water_inj_down_duration NUMBER; ln_gas_inj_down_duration NUMBER; ln_steam_inj_down_duration NUMBER; 
  ln_oil_mass_down_duration NUMBER; ln_gas_mass_down_duration NUMBER; ln_cond_mass_down_duration NUMBER; ln_water_mass_down_duration NUMBER;

  ln_alloc_loss_oil_vol NUMBER; ln_alloc_loss_gas_vol NUMBER; ln_alloc_loss_water_vol NUMBER; ln_alloc_loss_cond_vol NUMBER; ln_alloc_loss_diluent_vol NUMBER; ln_alloc_loss_gas_lift_vol NUMBER;
  ln_alloc_loss_water_inj_vol NUMBER; ln_alloc_loss_gas_inj_vol NUMBER; ln_alloc_loss_steam_inj_vol NUMBER;
  ln_alloc_loss_oil_mass NUMBER; ln_alloc_loss_gas_mass NUMBER; ln_alloc_loss_cond_mass NUMBER; ln_alloc_loss_water_mass NUMBER;
  
  ln_ctrl_oil_loss_rate NUMBER;  ln_ctrl_gas_loss_rate NUMBER;  ln_ctrl_water_loss_rate NUMBER;  ln_ctrl_cond_loss_rate NUMBER;  ln_ctrl_diluent_loss_rate NUMBER;  ln_ctrl_gas_lift_loss_rate NUMBER;
  ln_ctrl_water_inj_loss_rate NUMBER;  ln_ctrl_gas_inj_loss_rate NUMBER;  ln_ctrl_steam_inj_loss_rate NUMBER;
  ln_ctrl_oil_loss_mass_rate NUMBER;  ln_ctrl_gas_loss_mass_rate NUMBER;  ln_ctrl_water_loss_mass_rate NUMBER;  ln_ctrl_cond_loss_mass_rate NUMBER;
  

  TYPE DefermentRec IS RECORD (daytime DATE,
                        start_date DATE,
                        end_date DATE,
                        event_type VARCHAR2(32),
                        sort_event_type NUMBER,
                        sort_scheduled NUMBER,
                        sort_deferment_type NUMBER,
                        event_no NUMBER,
                        parent_event_no NUMBER,
                        deferment_type VARCHAR2(32),
                        oil_loss_rate NUMBER,
                        gas_loss_rate NUMBER,
                        water_loss_rate NUMBER,
                        cond_loss_rate NUMBER,
                        water_inj_loss_rate NUMBER,
                        gas_inj_loss_rate NUMBER,
                        steam_inj_loss_rate NUMBER,
                        diluent_loss_rate NUMBER,
                        gas_lift_loss_rate NUMBER,
                        oil_loss_mass_rate NUMBER,
                        gas_loss_mass_rate NUMBER,
                        cond_loss_mass_rate NUMBER,
                        water_loss_mass_rate NUMBER,
                        day DATE,
                        end_day DATE              
                        );
 rec_deferment_event DefermentRec;    
 lv2_open_end_event  VARCHAR2(1);
 rc_deferment SYS_REFCURSOR;
 ld_in_fmt_start_daytime VARCHAR2(100);
 ld_in_fmt_end_date VARCHAR2(100);
  
  TYPE myProducts IS RECORD (oil NUMBER,
                             gas NUMBER,
                             water NUMBER,
                             cond NUMBER,
                             diluent NUMBER,
                             gas_lift NUMBER,
                             water_inj NUMBER,
                             gas_inj NUMBER,
                             steam_inj NUMBER,
                             oil_mass NUMBER,
                             gas_mass NUMBER,
                             cond_mass NUMBER,
                             water_mass NUMBER
                             );
  lr_potential myProducts;
  lr_remain_pot myProducts;
  lr_well_version WELL_VERSION%ROWTYPE;
  ln_getDayHours NUMBER;
  ln_getDayHoursTemp NUMBER;
  lv_daylight NUMBER:=0;
BEGIN

  lv2_open_end_event:=NVL(ecdp_ctrl_property.getSystemProperty('DEFERMENT_OPEN_EVENT_CALC',TRUNC(Ecdp_Timestamp.getCurrentSysdate())),'Y');
  -- loop all days
  FOR cur_event_day IN c_event_days LOOP -- this cursor loops all production days for the whole period.
    ld_start_daytime := Ecdp_Productionday.getProductionDayStart('WELL',p_object_id,cur_event_day.daytime);
    ld_in_fmt_start_daytime:='to_date('''||TO_CHAR(ld_start_daytime,'YYYY-MM-DD"T"HH24:MI:SS')||''' , ''YYYY-MM-DD"T"HH24:MI:SS'')';
	  ld_in_fmt_end_date:='to_date('''||TO_CHAR(Ecdp_Timestamp.getCurrentSysdate,'YYYY-MM-DD"T"HH24:MI')||''' , ''YYYY-MM-DD"T"HH24:MI'')';

    IF EcDp_month_lock.withinLockedMonth(ld_start_daytime) IS NOT NULL THEN
      EcDp_Month_Lock.raiseValidationError('UPDATING', ld_start_daytime, ld_start_daytime, TRUNC(ld_start_daytime,'MONTH'), 'Cannot calculate deferments for a locked month.');
    END IF;
    EcDp_Month_Lock.localLockCheck('withinLockedMonth', p_object_id,
                                   ld_start_daytime, ld_start_daytime,
                                   'INSERTING', 'Cannot update the deferment allocation table in a locked local month.');

    -- before processing new events, set old records to 0 for all records for that day and object.
    UPDATE well_day_defer_alloc
    SET deferred_gas_vol = 0,
        deferred_net_oil_vol = 0,
        deferred_water_vol = 0,
        deferred_cond_vol = 0,
        deferred_gl_vol = 0,
        deferred_diluent_vol = 0,
        deferred_steam_inj_vol = 0,
        deferred_gas_inj_vol = 0,
        deferred_water_inj_vol = 0,
        deferred_net_oil_mass = 0,
        deferred_gas_mass = 0,
        deferred_cond_mass = 0,
        deferred_water_mass = 0,
        last_updated_by = Nvl(ecdp_context.getAppUser(),USER),
        rev_no = rev_no+1
    WHERE object_id = p_object_id
    AND daytime = cur_event_day.daytime;

    -- check if there are any deferment event for the production_day. If not, we dont need to access well potential etc.
    SELECT COUNT(*)
    INTO ln_count
    FROM deferment_event wd
    WHERE wd.object_id = p_object_id
    AND (wd.day = cur_event_day.daytime OR
        (wd.day < cur_event_day.daytime AND nvl(wd.end_day, cur_event_day.daytime) >= cur_event_day.daytime ) )
    AND nvl(wd.end_date,ld_start_daytime+1) <> ld_start_daytime -- exclude events which ends exact at the beginning of the day we calculate. End_daytime is exclusive
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD'); 

    -- only process if there are any deferment records
    IF ln_count > 0 THEN
       
      --Handle daylight saving for deferment event
      ln_getDayHoursTemp:=Ecdp_Timestamp.getNumHours('WELL',p_object_id,cur_event_day.daytime);
      IF (ec_ctrl_system_attribute.attribute_text(cur_event_day.daytime, 'ADJUST_POTENTIAL_DST','<=')= 'Y') THEN
        lv_daylight:=1;
      END IF;
       
      IF  lv_daylight = 1 THEN 
       ln_getDayHours:=ln_getDayHoursTemp/24;
      ELSE
       ln_getDayHours:=1; 
      END IF;

      ln_ctrl_duration := ln_getDayHours;
      
      lr_well_version := ec_well_version.row_by_rel_operator(p_object_id, cur_event_day.daytime, '<=');
      -- initialise lr_potential
      lr_potential.oil := NULL; lr_potential.gas := NULL; lr_potential.water := NULL; lr_potential.cond := NULL;
      lr_potential.diluent := NULL; lr_potential.gas_lift := NULL;
      lr_potential.water_inj := NULL; lr_potential.gas_inj := NULL; lr_potential.steam_inj := NULL;
      lr_potential.oil_mass := NULL; lr_potential.gas_mass := NULL; lr_potential.water_mass := NULL; lr_potential.cond_mass := NULL;
      ln_off_def_cnt := NULL; lb_found_off_def := NULL;

      -- depending on type of well and configuration of well, get well potentials
      -- dont access well potential for a phase that is not configured for performance reasons
      IF lr_well_version.isOilProducer = 'Y' AND lr_well_version.potential_method IS NOT NULL THEN
        lr_potential.oil := (ecbp_well_potential.findOilProductionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_potential.gas := (ecbp_well_potential.findGasProductionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_potential.water := (ecbp_well_potential.findWatProductionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.oil := lr_potential.oil;
        lr_remain_pot.gas := lr_potential.gas;
        lr_remain_pot.water := lr_potential.water;
      END IF;

      IF lr_well_version.isOilProducer = 'Y' AND lr_well_version.potential_mass_method IS NOT NULL THEN
        lr_potential.oil_mass    := (ecbp_well_potential.findOilMassProdPotential(p_object_id, cur_event_day.daytime)  *24)/ln_getDayHoursTemp;
        lr_potential.gas_mass    := (ecbp_well_potential.findGasMassProdPotential(p_object_id, cur_event_day.daytime)  *24)/ln_getDayHoursTemp;
        lr_potential.water_mass  := (ecbp_well_potential.findWaterMassProdPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.oil_mass   := lr_potential.oil_mass;
        lr_remain_pot.gas_mass   := lr_potential.gas_mass;
        lr_remain_pot.water_mass := lr_potential.water_mass;
      END IF;      
      
      IF lr_well_version.isGasProducer = 'Y' AND lr_well_version.potential_method IS NOT NULL THEN
        lr_potential.cond := (ecbp_well_potential.findConProductionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_potential.gas := (ecbp_well_potential.findGasProductionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_potential.water := (ecbp_well_potential.findWatProductionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.cond := lr_potential.cond;
        lr_remain_pot.gas := lr_potential.gas;
        lr_remain_pot.water := lr_potential.water;
      END IF;

      IF lr_well_version.isGasProducer = 'Y' AND lr_well_version.potential_mass_method IS NOT NULL THEN
        lr_potential.cond_mass   := (ecbp_well_potential.findCondMassProdPotential(p_object_id, cur_event_day.daytime) *24)/ln_getDayHoursTemp;
        lr_potential.gas_mass    := (ecbp_well_potential.findGasMassProdPotential(p_object_id, cur_event_day.daytime)  *24)/ln_getDayHoursTemp;
        lr_potential.water_mass  := (ecbp_well_potential.findWaterMassProdPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.cond_mass  := lr_potential.cond_mass;
        lr_remain_pot.gas_mass   := lr_potential.gas_mass;
        lr_remain_pot.water_mass := lr_potential.water_mass;
      END IF;
      
      IF lr_well_version.isCondensateProducer = 'Y' AND lr_well_version.potential_method IS NOT NULL THEN
        lr_potential.cond := (ecbp_well_potential.findConProductionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_potential.gas := (ecbp_well_potential.findGasProductionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_potential.water := (ecbp_well_potential.findWatProductionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.cond := lr_potential.cond;
        lr_remain_pot.gas := lr_potential.gas;
        lr_remain_pot.water := lr_potential.water;
      END IF;

      IF lr_well_version.isCondensateProducer = 'Y' AND lr_well_version.potential_mass_method IS NOT NULL THEN
        lr_potential.cond_mass   := (ecbp_well_potential.findCondMassProdPotential(p_object_id, cur_event_day.daytime) *24)/ln_getDayHoursTemp;
        lr_potential.gas_mass    := (ecbp_well_potential.findGasMassProdPotential(p_object_id, cur_event_day.daytime)  *24)/ln_getDayHoursTemp;
        lr_potential.water_mass  := (ecbp_well_potential.findWaterMassProdPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.cond_mass  := lr_potential.cond_mass;
        lr_remain_pot.gas_mass   := lr_potential.gas_mass;
        lr_remain_pot.water_mass := lr_potential.water_mass;
      END IF;
      
      IF lr_well_version.isGasInjector = 'Y' THEN
        lr_potential.gas_inj := (ecbp_well_potential.findGasInjectionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.gas_inj := lr_potential.gas_inj;
      END IF;
      IF lr_well_version.isWaterInjector = 'Y' THEN
        lr_potential.water_inj := (ecbp_well_potential.findWatInjectionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.water_inj := lr_potential.water_inj;
      END IF;
      IF lr_well_version.isSteamInjector = 'Y' THEN
        lr_potential.steam_inj := (ecbp_well_potential.findSteamInjectionPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.steam_inj := lr_potential.steam_inj;
      END IF;
      IF lr_well_version.gas_lift_method IS NOT NULL THEN
        lr_potential.gas_lift := (ecbp_well_potential.findGasLiftPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.gas_lift := lr_potential.gas_lift;
      END IF;
      IF lr_well_version.diluent_method IS NOT NULL THEN
        lr_potential.diluent := (ecbp_well_potential.findDiluentPotential(p_object_id, cur_event_day.daytime)*24)/ln_getDayHoursTemp;
        lr_remain_pot.diluent := lr_potential.diluent;
      END IF;

      ln_oil_down_duration := 0; ln_gas_down_duration := 0; ln_water_down_duration := 0; ln_cond_down_duration := 0; ln_diluent_down_duration := 0; ln_gas_lift_down_duration := 0;
      ln_water_inj_down_duration := 0; ln_gas_inj_down_duration := 0; ln_steam_inj_down_duration := 0;
      ln_oil_mass_down_duration := 0; ln_gas_mass_down_duration := 0; ln_cond_mass_down_duration := 0; ln_water_mass_down_duration := 0;      

      ln_alloc_loss_oil_vol := 0; ln_alloc_loss_gas_vol := 0; ln_alloc_loss_water_vol := 0; ln_alloc_loss_cond_vol := 0; ln_alloc_loss_diluent_vol := 0; ln_alloc_loss_gas_lift_vol := 0;
      ln_alloc_loss_water_inj_vol := 0; ln_alloc_loss_gas_inj_vol := 0; ln_alloc_loss_steam_inj_vol := 0;
      ln_alloc_loss_oil_mass := 0; ln_alloc_loss_gas_mass := 0; ln_alloc_loss_cond_mass := 0; ln_alloc_loss_water_mass := 0;

      ln_ctrl_oil_loss_rate := 0;  ln_ctrl_gas_loss_rate := 0;  ln_ctrl_water_loss_rate := 0;  ln_ctrl_cond_loss_rate := 0;  ln_ctrl_diluent_loss_rate := 0;  ln_ctrl_gas_lift_loss_rate := 0;
      ln_ctrl_water_inj_loss_rate := 0;  ln_ctrl_gas_inj_loss_rate := 0;  ln_ctrl_steam_inj_loss_rate := 0;
      ln_ctrl_oil_loss_mass_rate := 0;  ln_ctrl_gas_loss_mass_rate := 0;  ln_ctrl_water_loss_mass_rate := 0;  ln_ctrl_cond_loss_mass_rate := 0;

      i:=0;
      -- fetch records that are involved in the current production day and well.
      -- deferment_event.day and end_day are calculated by triggers upon insert and holds production days for start and end of event.     
      IF lv2_open_end_event='Y' THEN
        OPEN rc_deferment FOR 'SELECT wd.daytime, -- record start daytime
        greatest(wd.daytime,'|| ld_in_fmt_start_daytime||') start_date, -- start_date is minimum start of production day to calc correct duration
        least(nvl(wd.end_date,'|| ld_in_fmt_end_date ||'),'||ld_in_fmt_start_daytime|| ' +1) end_date, -- end_date can be maximum end of production day to calc correct duration
        wd.event_type, -- OFF or LOW events
        decode(ec_deferment_event.event_type(wd.event_no), ''DOWN'', 1, ''CONSTRAINT'', 2, NULL, 99) sort_event_type,
        decode(ec_deferment_event.scheduled(wd.event_no), ''N'', 1, ''Y'', 2, NULL, 1) sort_scheduled,
        decode(ec_deferment_event.deferment_type(wd.event_no), ''SINGLE'',1, ''GROUP_CHILD'',2, ''GROUP'',3) sort_deferment_type,
        wd.event_no,
        wd.parent_event_no,
        wd.deferment_type,
        decode(wd.OIL_LOSS_VOLUME,NULL,wd.oil_loss_rate, wd.oil_loss_volume/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) oil_loss_rate,
        decode(wd.GAS_LOSS_VOLUME,NULL,wd.gas_loss_rate, wd.GAS_LOSS_VOLUME/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) gas_loss_rate,
        decode(wd.WATER_LOSS_VOLUME,NULL,wd.water_loss_rate, wd.WATER_LOSS_VOLUME/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) water_loss_rate,
        decode(wd.COND_LOSS_VOLUME,NULL,wd.cond_loss_rate, wd.COND_LOSS_VOLUME/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) cond_loss_rate,
        decode(wd.WATER_INJ_LOSS_VOLUME,NULL,wd.water_inj_loss_rate, wd.WATER_INJ_LOSS_VOLUME/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) water_inj_loss_rate,
        decode(wd.GAS_INJ_LOSS_VOLUME,NULL,wd.gas_inj_loss_rate, wd.GAS_INJ_LOSS_VOLUME/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) gas_inj_loss_rate,        
        decode(wd.STEAM_INJ_LOSS_VOLUME,NULL,wd.steam_inj_loss_rate, wd.STEAM_INJ_LOSS_VOLUME/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) steam_inj_loss_rate,        
        decode(wd.DILUENT_LOSS_VOLUME,NULL,wd.diluent_loss_rate, wd.DILUENT_LOSS_VOLUME/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) diluent_loss_rate,
        decode(wd.GAS_LIFT_LOSS_VOLUME,NULL,wd.gas_lift_loss_rate, wd.GAS_LIFT_LOSS_VOLUME/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) gas_lift_loss_rate,
        decode(wd.OIL_LOSS_MASS,NULL,wd.oil_loss_mass_rate, wd.oil_loss_mass/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) oil_loss_mass_rate,
        decode(wd.GAS_LOSS_MASS,NULL,wd.gas_loss_mass_rate, wd.gas_loss_mass/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) gas_loss_mass_rate,
        decode(wd.COND_LOSS_MASS,NULL,wd.cond_loss_mass_rate, wd.cond_loss_mass/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) cond_loss_mass_rate,
        decode(wd.WATER_LOSS_MASS,NULL,wd.water_loss_mass_rate, wd.water_loss_mass/(NVL(wd.end_date,'|| ld_in_fmt_end_date ||')-wd.daytime)) water_loss_mass_rate,
        wd.day,
        wd.end_day
        FROM deferment_event wd
        WHERE wd.object_id = '''||p_object_id||'''
        AND wd.class_name IN (''WELL_DEFERMENT'',''WELL_DEFERMENT_CHILD'')
        AND (wd.day = '''||cur_event_day.daytime||''' OR
            (wd.day < '''||cur_event_day.daytime||''' AND (wd.end_day IS NULL OR wd.end_day >= '''|| cur_event_day.daytime||''')))
        ORDER BY sort_event_type ASC, wd.daytime ASC, sort_scheduled ASC, sort_deferment_type ASC';                        

        FOR cur_off_def_cnt IN c_off_def_cnt_open(cur_event_day.daytime) LOOP
            ln_off_def_cnt := cur_off_def_cnt.off_def_cnt;
        END LOOP;

      ELSIF lv2_open_end_event='N' THEN
        OPEN rc_deferment FOR 'SELECT wd.daytime, -- record start daytime
        greatest(wd.daytime,'|| ld_in_fmt_start_daytime||') start_date, -- start_date is minimum start of production day to calc correct duration
        least(wd.end_date,'||ld_in_fmt_start_daytime|| '+1) end_date, -- end_date can be maximum end of production day to calc correct duration
        wd.event_type, -- OFF or LOW events
        decode(ec_deferment_event.event_type(wd.event_no), ''DOWN'', 1, ''CONSTRAINT'', 2, NULL, 99) sort_event_type,
        decode(ec_deferment_event.scheduled(wd.event_no), ''N'', 1, ''Y'', 2, NULL, 1) sort_scheduled,
        decode(ec_deferment_event.deferment_type(wd.event_no), ''SINGLE'',1, ''GROUP_CHILD'',2, ''GROUP'',3) sort_deferment_type,
        wd.event_no,
        wd.parent_event_no,
        wd.deferment_type,
        decode(wd.OIL_LOSS_VOLUME,NULL,wd.oil_loss_rate, wd.oil_loss_volume/(wd.end_date-wd.daytime)) oil_loss_rate,
        decode(wd.GAS_LOSS_VOLUME,NULL,wd.gas_loss_rate, wd.GAS_LOSS_VOLUME/(wd.end_date-wd.daytime)) gas_loss_rate,
        decode(wd.WATER_LOSS_VOLUME,NULL,wd.water_loss_rate, wd.WATER_LOSS_VOLUME/(wd.end_date-wd.daytime)) water_loss_rate,
        decode(wd.COND_LOSS_VOLUME,NULL,wd.cond_loss_rate, wd.COND_LOSS_VOLUME/(wd.end_date-wd.daytime)) cond_loss_rate,
        decode(wd.WATER_INJ_LOSS_VOLUME,NULL,wd.water_inj_loss_rate, wd.WATER_INJ_LOSS_VOLUME/(wd.end_date-wd.daytime)) water_inj_loss_rate,
        decode(wd.GAS_INJ_LOSS_VOLUME,NULL,wd.gas_inj_loss_rate, wd.GAS_INJ_LOSS_VOLUME/(wd.end_date-wd.daytime)) gas_inj_loss_rate,        
        decode(wd.STEAM_INJ_LOSS_VOLUME,NULL,wd.steam_inj_loss_rate, wd.STEAM_INJ_LOSS_VOLUME/(wd.end_date-wd.daytime)) steam_inj_loss_rate,        
        decode(wd.DILUENT_LOSS_VOLUME,NULL,wd.diluent_loss_rate, wd.DILUENT_LOSS_VOLUME/(wd.end_date-wd.daytime)) diluent_loss_rate,
        decode(wd.GAS_LIFT_LOSS_VOLUME,NULL,wd.gas_lift_loss_rate, wd.GAS_LIFT_LOSS_VOLUME/(wd.end_date-wd.daytime)) gas_lift_loss_rate,
        decode(wd.OIL_LOSS_MASS,NULL,wd.oil_loss_mass_rate, wd.oil_loss_mass/(wd.end_date-wd.daytime)) oil_loss_mass_rate,
        decode(wd.GAS_LOSS_MASS,NULL,wd.gas_loss_mass_rate, wd.gas_loss_mass/(wd.end_date-wd.daytime)) gas_loss_mass_rate,
        decode(wd.COND_LOSS_MASS,NULL,wd.cond_loss_mass_rate, wd.cond_loss_mass/(wd.end_date-wd.daytime)) cond_loss_mass_rate,        
        decode(wd.WATER_LOSS_MASS,NULL,wd.water_loss_mass_rate, wd.water_loss_mass/(wd.end_date-wd.daytime)) water_loss_mass_rate,
        wd.day,
        wd.end_day
        FROM deferment_event wd
        WHERE wd.object_id = '''||p_object_id||'''
        AND wd.class_name IN (''WELL_DEFERMENT'',''WELL_DEFERMENT_CHILD'')
        AND wd.day <= '''||cur_event_day.daytime||''' AND  wd.end_day >= '''|| cur_event_day.daytime||'''
        ORDER BY sort_event_type ASC, wd.daytime ASC, sort_scheduled ASC, sort_deferment_type ASC';

        FOR cur_off_def_cnt IN c_off_def_cnt_closed(cur_event_day.daytime) LOOP
            ln_off_def_cnt := cur_off_def_cnt.off_def_cnt;
        END LOOP;  
      END IF;

      IF ln_off_def_cnt > 0 THEN
        lb_found_off_def := TRUE;
      END IF;       

      LOOP
        FETCH rc_deferment INTO rec_deferment_event;
        EXIT WHEN rc_deferment%NOTFOUND;
        IF (rec_deferment_event.end_date <= rec_deferment_event.start_date) OR
           (rec_deferment_event.end_day IS NULL and cur_event_day.daytime = TRUNC(Ecdp_Timestamp.getCurrentSysdate)) THEN
          GOTO SKIP_CALC;
        END IF;                
        i:=i+1;
        lr_defer_event(i).event_no := rec_deferment_event.event_no;
        lr_defer_event(i).daytime := rec_deferment_event.start_date;
        lr_defer_event(i).end_date := rec_deferment_event.end_date;
        lr_defer_event(i).event_type := rec_deferment_event.event_type;
        
        IF i = 1 THEN
          ln_duration := rec_deferment_event.end_date - rec_deferment_event.start_date;
          ld_MaxEnd_date := rec_deferment_event.end_date;
        ELSIF i > 1 THEN
          IF lr_defer_event(i-1).event_type = 'DOWN' AND lr_defer_event(i).event_type = 'DOWN' THEN
            ld_MaxEnd_date := greatest(ld_MaxEnd_date, lr_defer_event(i-1).end_date);
            IF lr_defer_event(i).daytime >= lr_defer_event(i-1).daytime AND
              lr_defer_event(i).end_date <= ld_MaxEnd_date THEN
              ln_duration := 0;
            ELSIF lr_defer_event(i).daytime >= ld_MaxEnd_date AND
              lr_defer_event(i).end_date > ld_MaxEnd_date THEN
              ln_duration := lr_defer_event(i).end_date - lr_defer_event(i).daytime;
              ld_MaxEnd_date := lr_defer_event(i).end_date;
            ELSIF lr_defer_event(i).daytime < ld_MaxEnd_date AND
              lr_defer_event(i).end_date > ld_MaxEnd_date THEN
              ln_duration := lr_defer_event(i).end_date - ld_MaxEnd_date;
              ld_MaxEnd_date := lr_defer_event(i).end_date;
            END IF;
          ELSE
            -- Previous row is 'DOWN' AND current = 'CONSTRAINT' -- or -- Previous and current row is 'CONSTRAINT'
            ln_duration := rec_deferment_event.end_date - rec_deferment_event.start_date;
          END IF;
        END IF;

        IF  lv_daylight = 1 THEN 
          IF ln_duration = 1 THEN
            ln_duration:=ln_duration*ln_getDayHours;
          ELSIF ln_getDayHours < 1 THEN
           ln_duration:=LEAST(ln_duration, ln_getDayHours);
          END IF; 
        END IF;   

        IF lb_found_off_def = TRUE THEN
          IF i = 1 THEN
            -- First Row just update the ln_ctrl_duration value
            IF ln_duration > 0 THEN
              ln_ctrl_duration := ln_ctrl_duration - ln_duration;
            END IF;
          ELSE
            -- For second rows onwards, it needs more logic to adjust the remaining ln_duration that must not exist 24 hrs (which is 1 day)
            IF ln_duration > 0 THEN
              IF ln_ctrl_duration = 0 THEN
                ln_duration := ln_ctrl_duration;
              ELSE
                IF ln_duration > ln_ctrl_duration THEN
                  ln_duration := ln_ctrl_duration;
                  ln_ctrl_duration := 0;
                ELSE
                  ln_ctrl_duration := ln_ctrl_duration - ln_duration;
                END IF;
              END IF;
            END IF;
          END IF;
        END IF;

        --loss rate should be less than of equal to volume of potential as well can not produce more than potential.
        lr_defer_event(i).oil_loss_rate := LEAST(NVL(lr_potential.oil,999999),NVL(rec_deferment_event.oil_loss_rate,lr_potential.oil));
        lr_defer_event(i).gas_loss_rate := LEAST(NVL(lr_potential.gas,999999),NVL(rec_deferment_event.gas_loss_rate,lr_potential.gas));
        lr_defer_event(i).water_loss_rate := LEAST(NVL(lr_potential.water,999999),NVL(rec_deferment_event.water_loss_rate,lr_potential.water));
        lr_defer_event(i).cond_loss_rate := LEAST(NVL(lr_potential.cond,999999),NVL(rec_deferment_event.cond_loss_rate,lr_potential.cond));
        lr_defer_event(i).diluent_loss_rate := LEAST(NVL(lr_potential.diluent,999999),NVL(rec_deferment_event.diluent_loss_rate,lr_potential.diluent));
        lr_defer_event(i).gas_lift_loss_rate := LEAST(NVL(lr_potential.gas_lift,999999),NVL(rec_deferment_event.gas_lift_loss_rate,lr_potential.gas_lift));
        lr_defer_event(i).water_inj_loss_rate := LEAST(NVL(lr_potential.water_inj,999999),NVL(rec_deferment_event.water_inj_loss_rate,lr_potential.water_inj));
        lr_defer_event(i).gas_inj_loss_rate := LEAST(NVL(lr_potential.gas_inj,999999),NVL(rec_deferment_event.gas_inj_loss_rate,lr_potential.gas_inj));
        lr_defer_event(i).steam_inj_loss_rate := LEAST(NVL(lr_potential.steam_inj,999999),NVL(rec_deferment_event.steam_inj_loss_rate,lr_potential.steam_inj));
        lr_defer_event(i).oil_loss_mass_rate := LEAST(NVL(lr_potential.oil_mass,999999),NVL(rec_deferment_event.oil_loss_mass_rate,lr_potential.oil_mass));
        lr_defer_event(i).gas_loss_mass_rate := LEAST(NVL(lr_potential.gas_mass,999999),NVL(rec_deferment_event.gas_loss_mass_rate,lr_potential.gas_mass));
        lr_defer_event(i).cond_loss_mass_rate := LEAST(NVL(lr_potential.cond_mass,999999),NVL(rec_deferment_event.cond_loss_mass_rate,lr_potential.cond_mass));
        lr_defer_event(i).water_loss_mass_rate := LEAST(NVL(lr_potential.water_mass,999999),NVL(rec_deferment_event.water_loss_mass_rate,lr_potential.water_mass));        

        -- calculate how much loss the event has for the current period
        -- also check that we dont overallocate loss to the event, max loss = potential

        -- OIL
        IF lb_found_off_def = TRUE THEN--Block C
        --if get executed when we have combination of low and off deferment event.
          IF lr_defer_event(i).oil_loss_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_oil := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_oil := lr_defer_event(i).oil_loss_rate * ln_duration;
              ln_oil_down_duration := ln_oil_down_duration + ln_duration;
            ELSE--Block A
              IF ln_oil_down_duration < 1 THEN--Block B
                --find (ln_constraint_hrs) non-overlapping hours between off(all previous events of day) and low(current event which is getting process) events.
                --example 1st event is from 00:00 to 18:00 (off event)
                --and current event is from 16:00 to 23:00 (low event) 
                --then non-overlapping hours are 18:01 to 23:00 i.e total hours are 5 hours.
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.oil IS NOT NULL THEN--Block E--if potential is NULL then no need to check loss vol for maximum loss.
                  --Remaining potential of well >= loss volume of current event
                  IF lr_remain_pot.oil >= (lr_defer_event(i).oil_loss_rate * ln_constraint_hrs) THEN
                    --total allocated vol + loss volume of current event > potential of well 
                    IF ln_alloc_loss_oil_vol + (lr_defer_event(i).oil_loss_rate * ln_constraint_hrs) > lr_potential.oil THEN
                      --loss vol for current event= potential of well - total allocated vol(as we can not more than potentail of well)
                      lr_defer_event(i).loss_oil := lr_potential.oil - ln_alloc_loss_oil_vol;
                    ELSE
                      --loss vol for current event= loss volume of current event
                      lr_defer_event(i).loss_oil := lr_defer_event(i).oil_loss_rate * ln_constraint_hrs;
                    END IF;
                  --Remaining potential of well > 0 and loss rate for current event >0 
                  ELSIF lr_remain_pot.oil > 0 AND lr_defer_event(i).oil_loss_rate > 0 THEN
                    --loss vol for current event=Remaining potential of well (as we can not more than potentail of well)
                    lr_defer_event(i).loss_oil := lr_remain_pot.oil;
                  ELSE
                    lr_defer_event(i).loss_oil := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_oil := lr_defer_event(i).oil_loss_rate * ln_constraint_hrs;--as potentail is null, just calculate event loss.
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_oil := 0;
              END IF;--Block B
            END IF;--Block A
            --update Remaining potential of well, once we have allocated some loss oil vol to current event.
            lr_remain_pot.oil := lr_remain_pot.oil - lr_defer_event(i).loss_oil;
            --update total allocated vol for a day for processing well.
            ln_alloc_loss_oil_vol := ln_alloc_loss_oil_vol + lr_defer_event(i).loss_oil;  
          END IF;--Block D
        ELSE--Block C
          --else get executed when we have combination of low deferment event only.     
          IF lr_potential.oil IS NOT NULL THEN--if potential is NULL then no need to check loss vol for maximum loss.    
            --Remaining potential of well >= loss volume of current event
            IF lr_remain_pot.oil >= (lr_defer_event(i).oil_loss_rate * ln_duration) THEN
              --total allocated vol + loss volume of current event > potential of well 
              IF ln_alloc_loss_oil_vol + (lr_defer_event(i).oil_loss_rate * ln_duration) > lr_potential.oil THEN
                --loss vol for current event= potential of well - total allocated vol(as we can not more than potentail of well)
                lr_defer_event(i).loss_oil := lr_potential.oil - ln_alloc_loss_oil_vol;
              ELSE
                --loss vol for current event= loss volume of current event
                lr_defer_event(i).loss_oil := lr_defer_event(i).oil_loss_rate * ln_duration;
              END IF;
            --Remaining potential of well > 0 and loss rate for current event >0 
            ELSIF lr_remain_pot.oil > 0 AND lr_defer_event(i).oil_loss_rate > 0 THEN
              --loss vol for current event=Remaining potential of well (as we can not more than potentail of well)
              lr_defer_event(i).loss_oil := lr_remain_pot.oil;
            ELSE
              lr_defer_event(i).loss_oil := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_oil := lr_defer_event(i).oil_loss_rate * ln_duration;--as potentail is null, just calculate event loss.
          END IF;  
          --update Remaining potential of well, once we have allocated some loss oil vol to current event.
          lr_remain_pot.oil := lr_remain_pot.oil - lr_defer_event(i).loss_oil;
          --update total allocated vol for a day for processing well.
          ln_alloc_loss_oil_vol := ln_alloc_loss_oil_vol + lr_defer_event(i).loss_oil;       
        END IF;--Block C
               
        -- GAS
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).gas_loss_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_gas := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_gas := lr_defer_event(i).gas_loss_rate * ln_duration;
              ln_gas_down_duration := ln_gas_down_duration + ln_duration;
            ELSE--Block A
              IF ln_gas_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event );              
                IF lr_potential.gas IS NOT NULL THEN--Block E
                  IF lr_remain_pot.gas >= (lr_defer_event(i).gas_loss_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_gas_vol + (lr_defer_event(i).gas_loss_rate * ln_constraint_hrs) > lr_potential.gas THEN
                      lr_defer_event(i).loss_gas := lr_potential.gas - ln_alloc_loss_gas_vol;
                    ELSE
                      lr_defer_event(i).loss_gas := lr_defer_event(i).gas_loss_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.gas > 0 AND lr_defer_event(i).gas_loss_rate > 0 THEN
                    lr_defer_event(i).loss_gas := lr_remain_pot.gas;
                  ELSE
                    lr_defer_event(i).loss_gas := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_gas := lr_defer_event(i).gas_loss_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_gas := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.gas := lr_remain_pot.gas - lr_defer_event(i).loss_gas;
            ln_alloc_loss_gas_vol := ln_alloc_loss_gas_vol + lr_defer_event(i).loss_gas;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.gas IS NOT NULL THEN
            IF lr_remain_pot.gas >= (lr_defer_event(i).gas_loss_rate * ln_duration) THEN
              IF ln_alloc_loss_gas_vol + (lr_defer_event(i).gas_loss_rate * ln_duration) > lr_potential.gas THEN
                lr_defer_event(i).loss_gas := lr_potential.gas - ln_alloc_loss_gas_vol;
              ELSE
                lr_defer_event(i).loss_gas := lr_defer_event(i).gas_loss_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.gas > 0 AND lr_defer_event(i).gas_loss_rate > 0 THEN
              lr_defer_event(i).loss_gas := lr_remain_pot.gas;
            ELSE
              lr_defer_event(i).loss_gas := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_gas := lr_defer_event(i).gas_loss_rate * ln_duration;
          END IF;
          lr_remain_pot.gas := lr_remain_pot.gas - lr_defer_event(i).loss_gas;
          ln_alloc_loss_gas_vol := ln_alloc_loss_gas_vol + lr_defer_event(i).loss_gas;       
        END IF;--Block C
        
        -- WAT
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).water_loss_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_water := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_water := lr_defer_event(i).water_loss_rate * ln_duration;
              ln_water_down_duration := ln_water_down_duration + ln_duration;
            ELSE--Block A
              IF ln_water_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.water IS NOT NULL THEN--Block E
                  IF lr_remain_pot.water >= (lr_defer_event(i).water_loss_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_water_vol + (lr_defer_event(i).water_loss_rate * ln_constraint_hrs) > lr_potential.water THEN
                      lr_defer_event(i).loss_water := lr_potential.water - ln_alloc_loss_water_vol;
                    ELSE
                      lr_defer_event(i).loss_water := lr_defer_event(i).water_loss_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.water > 0 AND lr_defer_event(i).water_loss_rate > 0 THEN
                    lr_defer_event(i).loss_water := lr_remain_pot.water;
                  ELSE
                    lr_defer_event(i).loss_water := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_water := lr_defer_event(i).water_loss_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_water := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.water := lr_remain_pot.water - lr_defer_event(i).loss_water;
            ln_alloc_loss_water_vol := ln_alloc_loss_water_vol + lr_defer_event(i).loss_water;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.water IS NOT NULL THEN
            IF lr_remain_pot.water >= (lr_defer_event(i).water_loss_rate * ln_duration) THEN
              IF ln_alloc_loss_water_vol + (lr_defer_event(i).water_loss_rate * ln_duration) > lr_potential.water THEN
                lr_defer_event(i).loss_water := lr_potential.water - ln_alloc_loss_water_vol;
              ELSE
                lr_defer_event(i).loss_water := lr_defer_event(i).water_loss_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.water > 0 AND lr_defer_event(i).water_loss_rate > 0 THEN
              lr_defer_event(i).loss_water := lr_remain_pot.water;
            ELSE
              lr_defer_event(i).loss_water := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_water := lr_defer_event(i).water_loss_rate * ln_duration;
          END IF;
          lr_remain_pot.water := lr_remain_pot.water - lr_defer_event(i).loss_water;
          ln_alloc_loss_water_vol := ln_alloc_loss_water_vol + lr_defer_event(i).loss_water;       
        END IF;--Block C
        
        -- COND
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).cond_loss_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_cond := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_cond := lr_defer_event(i).cond_loss_rate * ln_duration;
              ln_cond_down_duration := ln_cond_down_duration + ln_duration;
            ELSE--Block A
              IF ln_cond_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.cond IS NOT NULL THEN--Block E
                  IF lr_remain_pot.cond >= (lr_defer_event(i).cond_loss_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_cond_vol + (lr_defer_event(i).cond_loss_rate * ln_constraint_hrs) > lr_potential.cond THEN
                      lr_defer_event(i).loss_cond := lr_potential.cond - ln_alloc_loss_cond_vol;
                    ELSE
                      lr_defer_event(i).loss_cond := lr_defer_event(i).cond_loss_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.cond > 0 AND lr_defer_event(i).cond_loss_rate > 0 THEN
                    lr_defer_event(i).loss_cond := lr_remain_pot.cond;
                  ELSE
                    lr_defer_event(i).loss_cond := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_cond := lr_defer_event(i).cond_loss_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_cond := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.cond := lr_remain_pot.cond - lr_defer_event(i).loss_cond;
            ln_alloc_loss_cond_vol := ln_alloc_loss_cond_vol + lr_defer_event(i).loss_cond;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.cond IS NOT NULL THEN
            IF lr_remain_pot.cond >= (lr_defer_event(i).cond_loss_rate * ln_duration) THEN
              IF ln_alloc_loss_cond_vol + (lr_defer_event(i).cond_loss_rate * ln_duration) > lr_potential.cond THEN
                lr_defer_event(i).loss_cond := lr_potential.cond - ln_alloc_loss_cond_vol;
              ELSE
                lr_defer_event(i).loss_cond := lr_defer_event(i).cond_loss_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.cond > 0 AND lr_defer_event(i).cond_loss_rate > 0 THEN
              lr_defer_event(i).loss_cond := lr_remain_pot.cond;
            ELSE
              lr_defer_event(i).loss_cond := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_cond := lr_defer_event(i).cond_loss_rate * ln_duration;
          END IF;
          lr_remain_pot.cond := lr_remain_pot.cond - lr_defer_event(i).loss_cond;
          ln_alloc_loss_cond_vol := ln_alloc_loss_cond_vol + lr_defer_event(i).loss_cond;       
        END IF;--Block C

        -- DILUENT
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).diluent_loss_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_diluent := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_diluent := lr_defer_event(i).diluent_loss_rate * ln_duration;
              ln_diluent_down_duration := ln_diluent_down_duration + ln_duration;
            ELSE--Block A
              IF ln_diluent_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.diluent IS NOT NULL THEN--Block E
                  IF lr_remain_pot.diluent >= (lr_defer_event(i).diluent_loss_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_diluent_vol + (lr_defer_event(i).diluent_loss_rate * ln_constraint_hrs) > lr_potential.diluent THEN
                      lr_defer_event(i).loss_diluent := lr_potential.diluent - ln_alloc_loss_diluent_vol;
                    ELSE
                      lr_defer_event(i).loss_diluent := lr_defer_event(i).diluent_loss_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.diluent > 0 AND lr_defer_event(i).diluent_loss_rate > 0 THEN
                    lr_defer_event(i).loss_diluent := lr_remain_pot.diluent;
                  ELSE
                    lr_defer_event(i).loss_diluent := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_diluent := lr_defer_event(i).diluent_loss_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_diluent := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.diluent := lr_remain_pot.diluent - lr_defer_event(i).loss_diluent;
            ln_alloc_loss_diluent_vol := ln_alloc_loss_diluent_vol + lr_defer_event(i).loss_diluent;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.diluent IS NOT NULL THEN
            IF lr_remain_pot.diluent >= (lr_defer_event(i).diluent_loss_rate * ln_duration) THEN
              IF ln_alloc_loss_diluent_vol + (lr_defer_event(i).diluent_loss_rate * ln_duration) > lr_potential.diluent THEN
                lr_defer_event(i).loss_diluent := lr_potential.diluent - ln_alloc_loss_diluent_vol;
              ELSE
                lr_defer_event(i).loss_diluent := lr_defer_event(i).diluent_loss_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.diluent > 0 AND lr_defer_event(i).diluent_loss_rate > 0 THEN
              lr_defer_event(i).loss_diluent := lr_remain_pot.diluent;
            ELSE
              lr_defer_event(i).loss_diluent := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_diluent := lr_defer_event(i).diluent_loss_rate * ln_duration;
          END IF;
          lr_remain_pot.diluent := lr_remain_pot.diluent - lr_defer_event(i).loss_diluent;
          ln_alloc_loss_diluent_vol := ln_alloc_loss_diluent_vol + lr_defer_event(i).loss_diluent;       
        END IF;--Block C

        -- GAS LIFT
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).gas_lift_loss_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_gas_lift := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_gas_lift := lr_defer_event(i).gas_lift_loss_rate * ln_duration;
              ln_gas_lift_down_duration := ln_gas_lift_down_duration + ln_duration;
            ELSE--Block A
              IF ln_gas_lift_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.gas_lift IS NOT NULL THEN--Block E
                  IF lr_remain_pot.gas_lift >= (lr_defer_event(i).gas_lift_loss_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_gas_lift_vol + (lr_defer_event(i).gas_lift_loss_rate * ln_constraint_hrs) > lr_potential.gas_lift THEN
                      lr_defer_event(i).loss_gas_lift := lr_potential.gas_lift - ln_alloc_loss_gas_lift_vol;
                    ELSE
                      lr_defer_event(i).loss_gas_lift := lr_defer_event(i).gas_lift_loss_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.gas_lift > 0 AND lr_defer_event(i).gas_lift_loss_rate > 0 THEN
                    lr_defer_event(i).loss_gas_lift := lr_remain_pot.gas_lift;
                  ELSE
                    lr_defer_event(i).loss_gas_lift := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_gas_lift := lr_defer_event(i).gas_lift_loss_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_gas_lift := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.gas_lift := lr_remain_pot.gas_lift - lr_defer_event(i).loss_gas_lift;
            ln_alloc_loss_gas_lift_vol := ln_alloc_loss_gas_lift_vol + lr_defer_event(i).loss_gas_lift;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.gas_lift IS NOT NULL THEN
            IF lr_remain_pot.gas_lift >= (lr_defer_event(i).gas_lift_loss_rate * ln_duration) THEN
              IF ln_alloc_loss_gas_lift_vol + (lr_defer_event(i).gas_lift_loss_rate * ln_duration) > lr_potential.gas_lift THEN
                lr_defer_event(i).loss_gas_lift := lr_potential.gas_lift - ln_alloc_loss_gas_lift_vol;
              ELSE
                lr_defer_event(i).loss_gas_lift := lr_defer_event(i).gas_lift_loss_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.gas_lift > 0 AND lr_defer_event(i).gas_lift_loss_rate > 0 THEN
              lr_defer_event(i).loss_gas_lift := lr_remain_pot.gas_lift;
            ELSE
              lr_defer_event(i).loss_gas_lift := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_gas_lift := lr_defer_event(i).gas_lift_loss_rate * ln_duration;
          END IF;
          lr_remain_pot.gas_lift := lr_remain_pot.gas_lift - lr_defer_event(i).loss_gas_lift;
          ln_alloc_loss_gas_lift_vol := ln_alloc_loss_gas_lift_vol + lr_defer_event(i).loss_gas_lift;       
        END IF;--Block C

        -- WATER INJ
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).water_inj_loss_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_water_inj := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_water_inj := lr_defer_event(i).water_inj_loss_rate * ln_duration;
              ln_water_inj_down_duration := ln_water_inj_down_duration + ln_duration;
            ELSE--Block A
              IF ln_water_inj_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.water_inj IS NOT NULL THEN--Block E
                  IF lr_remain_pot.water_inj >= (lr_defer_event(i).water_inj_loss_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_water_inj_vol + (lr_defer_event(i).water_inj_loss_rate * ln_constraint_hrs) > lr_potential.water_inj THEN
                      lr_defer_event(i).loss_water_inj := lr_potential.water_inj - ln_alloc_loss_water_inj_vol;
                    ELSE
                      lr_defer_event(i).loss_water_inj := lr_defer_event(i).water_inj_loss_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.water_inj > 0 AND lr_defer_event(i).water_inj_loss_rate > 0 THEN
                    lr_defer_event(i).loss_water_inj := lr_remain_pot.water_inj;
                  ELSE
                    lr_defer_event(i).loss_water_inj := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_water_inj := lr_defer_event(i).water_inj_loss_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_water_inj := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.water_inj := lr_remain_pot.water_inj - lr_defer_event(i).loss_water_inj;
            ln_alloc_loss_water_inj_vol := ln_alloc_loss_water_inj_vol + lr_defer_event(i).loss_water_inj;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.water_inj IS NOT NULL THEN
            IF lr_remain_pot.water_inj >= (lr_defer_event(i).water_inj_loss_rate * ln_duration) THEN
              IF ln_alloc_loss_water_inj_vol + (lr_defer_event(i).water_inj_loss_rate * ln_duration) > lr_potential.water_inj THEN
                lr_defer_event(i).loss_water_inj := lr_potential.water_inj - ln_alloc_loss_water_inj_vol;
              ELSE
                lr_defer_event(i).loss_water_inj := lr_defer_event(i).water_inj_loss_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.water_inj > 0 AND lr_defer_event(i).water_inj_loss_rate > 0 THEN
              lr_defer_event(i).loss_water_inj := lr_remain_pot.water_inj;
            ELSE
              lr_defer_event(i).loss_water_inj := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_water_inj := lr_defer_event(i).water_inj_loss_rate * ln_duration;
          END IF;
          lr_remain_pot.water_inj := lr_remain_pot.water_inj - lr_defer_event(i).loss_water_inj;
          ln_alloc_loss_water_inj_vol := ln_alloc_loss_water_inj_vol + lr_defer_event(i).loss_water_inj;       
        END IF;--Block C
        
        -- GAS INJ
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).gas_inj_loss_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_gas_inj := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_gas_inj := lr_defer_event(i).gas_inj_loss_rate * ln_duration;
              ln_gas_inj_down_duration := ln_gas_inj_down_duration + ln_duration;
            ELSE--Block A
              IF ln_gas_inj_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.gas_inj IS NOT NULL THEN--Block E
                  IF lr_remain_pot.gas_inj >= (lr_defer_event(i).gas_inj_loss_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_gas_inj_vol + (lr_defer_event(i).gas_inj_loss_rate * ln_constraint_hrs) > lr_potential.gas_inj THEN
                      lr_defer_event(i).loss_gas_inj := lr_potential.gas_inj - ln_alloc_loss_gas_inj_vol;
                    ELSE
                      lr_defer_event(i).loss_gas_inj := lr_defer_event(i).gas_inj_loss_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.gas_inj > 0 AND lr_defer_event(i).gas_inj_loss_rate > 0 THEN
                    lr_defer_event(i).loss_gas_inj := lr_remain_pot.gas_inj;
                  ELSE
                    lr_defer_event(i).loss_gas_inj := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_gas_inj := lr_defer_event(i).gas_inj_loss_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_gas_inj := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.gas_inj := lr_remain_pot.gas_inj - lr_defer_event(i).loss_gas_inj;
            ln_alloc_loss_gas_inj_vol := ln_alloc_loss_gas_inj_vol + lr_defer_event(i).loss_gas_inj;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.gas_inj IS NOT NULL THEN
            IF lr_remain_pot.gas_inj >= (lr_defer_event(i).gas_inj_loss_rate * ln_duration) THEN
              IF ln_alloc_loss_gas_inj_vol + (lr_defer_event(i).gas_inj_loss_rate * ln_duration) > lr_potential.gas_inj THEN
                lr_defer_event(i).loss_gas_inj := lr_potential.gas_inj - ln_alloc_loss_gas_inj_vol;
              ELSE
                lr_defer_event(i).loss_gas_inj := lr_defer_event(i).gas_inj_loss_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.gas_inj > 0 AND lr_defer_event(i).gas_inj_loss_rate > 0 THEN
              lr_defer_event(i).loss_gas_inj := lr_remain_pot.gas_inj;
            ELSE
              lr_defer_event(i).loss_gas_inj := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_gas_inj := lr_defer_event(i).gas_inj_loss_rate * ln_duration;
          END IF;
          lr_remain_pot.gas_inj := lr_remain_pot.gas_inj - lr_defer_event(i).loss_gas_inj;
          ln_alloc_loss_gas_inj_vol := ln_alloc_loss_gas_inj_vol + lr_defer_event(i).loss_gas_inj;       
        END IF;--Block C
        
        -- STEAM INJ
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).steam_inj_loss_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_steam_inj := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_steam_inj := lr_defer_event(i).steam_inj_loss_rate * ln_duration;
              ln_steam_inj_down_duration := ln_steam_inj_down_duration + ln_duration;
            ELSE--Block A
              IF ln_steam_inj_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.steam_inj IS NOT NULL THEN--Block E
                  IF lr_remain_pot.steam_inj >= (lr_defer_event(i).steam_inj_loss_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_steam_inj_vol + (lr_defer_event(i).steam_inj_loss_rate * ln_constraint_hrs) > lr_potential.steam_inj THEN
                      lr_defer_event(i).loss_steam_inj := lr_potential.steam_inj - ln_alloc_loss_steam_inj_vol;
                    ELSE
                      lr_defer_event(i).loss_steam_inj := lr_defer_event(i).steam_inj_loss_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.steam_inj > 0 AND lr_defer_event(i).steam_inj_loss_rate > 0 THEN
                    lr_defer_event(i).loss_steam_inj := lr_remain_pot.steam_inj;
                  ELSE
                    lr_defer_event(i).loss_steam_inj := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_steam_inj := lr_defer_event(i).steam_inj_loss_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_steam_inj := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.steam_inj := lr_remain_pot.steam_inj - lr_defer_event(i).loss_steam_inj;
            ln_alloc_loss_steam_inj_vol := ln_alloc_loss_steam_inj_vol + lr_defer_event(i).loss_steam_inj;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.steam_inj IS NOT NULL THEN
            IF lr_remain_pot.steam_inj >= (lr_defer_event(i).steam_inj_loss_rate * ln_duration) THEN
              IF ln_alloc_loss_steam_inj_vol + (lr_defer_event(i).steam_inj_loss_rate * ln_duration) > lr_potential.steam_inj THEN
                lr_defer_event(i).loss_steam_inj := lr_potential.steam_inj - ln_alloc_loss_steam_inj_vol;
              ELSE
                lr_defer_event(i).loss_steam_inj := lr_defer_event(i).steam_inj_loss_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.steam_inj > 0 AND lr_defer_event(i).steam_inj_loss_rate > 0 THEN
              lr_defer_event(i).loss_steam_inj := lr_remain_pot.steam_inj;
            ELSE
              lr_defer_event(i).loss_steam_inj := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_steam_inj := lr_defer_event(i).steam_inj_loss_rate * ln_duration;
          END IF;
          lr_remain_pot.steam_inj := lr_remain_pot.steam_inj - lr_defer_event(i).loss_steam_inj;
          ln_alloc_loss_steam_inj_vol := ln_alloc_loss_steam_inj_vol + lr_defer_event(i).loss_steam_inj;       
        END IF;--Block C
        
        -- OIL_MASS
        IF lb_found_off_def = TRUE THEN--Block C
        --if get executed when we have combination of low and off deferment event.
          IF lr_defer_event(i).oil_loss_mass_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_oil_mass := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_oil_mass := lr_defer_event(i).oil_loss_mass_rate * ln_duration;
              ln_oil_mass_down_duration := ln_oil_mass_down_duration + ln_duration;
            ELSE--Block A
              IF ln_oil_mass_down_duration < 1 THEN--Block B
                --find (ln_constraint_hrs) non-overlapping hours between off(all previous events of day) and low(current event which is getting process) events.
                --example 1st event is from 00:00 to 18:00 (off event)
                --and current event is from 16:00 to 23:00 (low event) 
                --then non-overlapping hours are 18:01 to 23:00 i.e total hours are 5 hours.
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.oil_mass IS NOT NULL THEN--Block E--if potential is NULL then no need to check loss vol for maximum loss.
                  --Remaining potential of well >= loss mass of current event
                  IF lr_remain_pot.oil_mass >= (lr_defer_event(i).oil_loss_mass_rate * ln_constraint_hrs) THEN
                    --total allocated mass + loss mass of current event > potential of well 
                    IF ln_alloc_loss_oil_mass + (lr_defer_event(i).oil_loss_mass_rate * ln_constraint_hrs) > lr_potential.oil_mass THEN
                      --loss mass for current event= potential of well - total allocated mass(as we cannot have loss mass more than potentail of well)
                      lr_defer_event(i).loss_oil_mass := lr_potential.oil_mass - ln_alloc_loss_oil_mass;
                    ELSE
                      --loss mass for current event= loss mass of current event
                      lr_defer_event(i).loss_oil_mass := lr_defer_event(i).oil_loss_mass_rate * ln_constraint_hrs;
                    END IF;
                  --Remaining potential of well > 0 and loss mass rate for current event > 0 
                  ELSIF lr_remain_pot.oil_mass > 0 AND lr_defer_event(i).oil_loss_mass_rate > 0 THEN
                    --loss mass for current event=Remaining potential of well (as we can not more than potentail of well)
                    lr_defer_event(i).loss_oil_mass := lr_remain_pot.oil_mass;
                  ELSE
                    lr_defer_event(i).loss_oil_mass := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_oil_mass := lr_defer_event(i).oil_loss_mass_rate * ln_constraint_hrs;--as potentail is null, just calculate event loss mass.
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_oil_mass := 0;
              END IF;--Block B
            END IF;--Block A
            --update Remaining potential of well, once we have allocated some loss oil mass to current event.
            lr_remain_pot.oil_mass := lr_remain_pot.oil_mass - lr_defer_event(i).loss_oil_mass;
            --update total allocated mass for a day for processing well.
            ln_alloc_loss_oil_mass := ln_alloc_loss_oil_mass + lr_defer_event(i).loss_oil_mass;  
          END IF;--Block D
        ELSE--Block C
          --else get executed when we have combination of low deferment event only.     
          IF lr_potential.oil_mass IS NOT NULL THEN--if potential is NULL then no need to check loss mass for maximum loss.    
            --Remaining potential of well >= loss mass of current event
            IF lr_remain_pot.oil_mass >= (lr_defer_event(i).oil_loss_mass_rate * ln_duration) THEN
              --total allocated mass + loss mass of current event > potential of well 
              IF ln_alloc_loss_oil_mass + (lr_defer_event(i).oil_loss_mass_rate * ln_duration) > lr_potential.oil_mass THEN
                --loss mass for current event= potential of well - total allocated mass(as we can not more than potentail of well)
                lr_defer_event(i).loss_oil_mass := lr_potential.oil_mass - ln_alloc_loss_oil_mass;
              ELSE
                --loss mass for current event= loss mass of current event
                lr_defer_event(i).loss_oil_mass := lr_defer_event(i).oil_loss_mass_rate * ln_duration;
              END IF;
            --Remaining potential of well > 0 and loss mass rate for current event >0 
            ELSIF lr_remain_pot.oil > 0 AND lr_defer_event(i).oil_loss_rate > 0 THEN
              --Mass vol for current event=Remaining potential of well (as we can not more than potentail of well)
              lr_defer_event(i).loss_oil_mass := lr_remain_pot.oil_mass;
            ELSE
              lr_defer_event(i).loss_oil_mass := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_oil_mass := lr_defer_event(i).oil_loss_mass_rate * ln_duration;--as potentail is null, just calculate event loss.
          END IF;  
          --update Remaining potential of well, once we have allocated some loss oil mass to current event.
          lr_remain_pot.oil_mass := lr_remain_pot.oil_mass - lr_defer_event(i).loss_oil_mass;
          --update total allocated mass for a day for processing well.
          ln_alloc_loss_oil_mass := ln_alloc_loss_oil_mass + lr_defer_event(i).loss_oil_mass;       
        END IF;--Block C

        -- GAS_MASS
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).gas_loss_mass_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_gas_mass := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_gas_mass := lr_defer_event(i).gas_loss_mass_rate * ln_duration;
              ln_gas_mass_down_duration := ln_gas_mass_down_duration + ln_duration;
            ELSE--Block A
              IF ln_gas_mass_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event );              
                IF lr_potential.gas_mass IS NOT NULL THEN--Block E
                  IF lr_remain_pot.gas_mass >= (lr_defer_event(i).gas_loss_mass_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_gas_mass + (lr_defer_event(i).gas_loss_mass_rate * ln_constraint_hrs) > lr_potential.gas_mass THEN
                      lr_defer_event(i).loss_gas_mass := lr_potential.gas_mass - ln_alloc_loss_gas_mass;
                    ELSE
                      lr_defer_event(i).loss_gas_mass := lr_defer_event(i).gas_loss_mass_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.gas_mass > 0 AND lr_defer_event(i).gas_loss_mass_rate > 0 THEN
                    lr_defer_event(i).loss_gas_mass := lr_remain_pot.gas_mass;
                  ELSE
                    lr_defer_event(i).loss_gas_mass := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_gas_mass := lr_defer_event(i).gas_loss_mass_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_gas_mass := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.gas_mass := lr_remain_pot.gas_mass - lr_defer_event(i).loss_gas_mass;
            ln_alloc_loss_gas_mass := ln_alloc_loss_gas_mass + lr_defer_event(i).loss_gas_mass;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.gas_mass IS NOT NULL THEN
            IF lr_remain_pot.gas_mass >= (lr_defer_event(i).gas_loss_mass_rate * ln_duration) THEN
              IF ln_alloc_loss_gas_mass + (lr_defer_event(i).gas_loss_mass_rate * ln_duration) > lr_potential.gas_mass THEN
                lr_defer_event(i).loss_gas_mass := lr_potential.gas_mass - ln_alloc_loss_gas_mass;
              ELSE
                lr_defer_event(i).loss_gas_mass := lr_defer_event(i).gas_loss_mass_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.gas_mass > 0 AND lr_defer_event(i).gas_loss_mass_rate > 0 THEN
              lr_defer_event(i).loss_gas_mass := lr_remain_pot.gas_mass;
            ELSE
              lr_defer_event(i).loss_gas_mass := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_gas_mass := lr_defer_event(i).gas_loss_mass_rate * ln_duration;
          END IF;
          lr_remain_pot.gas_mass := lr_remain_pot.gas_mass - lr_defer_event(i).loss_gas_mass;
          ln_alloc_loss_gas_mass := ln_alloc_loss_gas_mass + lr_defer_event(i).loss_gas_mass;       
        END IF;--Block C
        
        -- COND_MASS
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).cond_loss_mass_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_cond_mass := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_cond_mass := lr_defer_event(i).cond_loss_mass_rate * ln_duration;
              ln_cond_mass_down_duration := ln_cond_mass_down_duration + ln_duration;
            ELSE--Block A
              IF ln_cond_mass_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.cond_mass IS NOT NULL THEN--Block E
                  IF lr_remain_pot.cond_mass >= (lr_defer_event(i).cond_loss_mass_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_cond_mass + (lr_defer_event(i).cond_loss_mass_rate * ln_constraint_hrs) > lr_potential.cond_mass THEN
                      lr_defer_event(i).loss_cond_mass := lr_potential.cond_mass - ln_alloc_loss_cond_mass;
                    ELSE
                      lr_defer_event(i).loss_cond_mass := lr_defer_event(i).cond_loss_mass_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.cond_mass > 0 AND lr_defer_event(i).cond_loss_mass_rate > 0 THEN
                    lr_defer_event(i).loss_cond_mass := lr_remain_pot.cond_mass;
                  ELSE
                    lr_defer_event(i).loss_cond_mass := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_cond_mass := lr_defer_event(i).cond_loss_mass_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_cond_mass := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.cond_mass := lr_remain_pot.cond_mass - lr_defer_event(i).loss_cond_mass;
            ln_alloc_loss_cond_mass := ln_alloc_loss_cond_mass + lr_defer_event(i).loss_cond_mass;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.cond IS NOT NULL THEN
            IF lr_remain_pot.cond_mass >= (lr_defer_event(i).cond_loss_mass_rate * ln_duration) THEN
              IF ln_alloc_loss_cond_mass + (lr_defer_event(i).cond_loss_mass_rate * ln_duration) > lr_potential.cond_mass THEN
                lr_defer_event(i).loss_cond_mass := lr_potential.cond_mass - ln_alloc_loss_cond_mass;
              ELSE
                lr_defer_event(i).loss_cond_mass := lr_defer_event(i).cond_loss_mass_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.cond_mass > 0 AND lr_defer_event(i).cond_loss_mass_rate > 0 THEN
              lr_defer_event(i).loss_cond_mass := lr_remain_pot.cond_mass;
            ELSE
              lr_defer_event(i).loss_cond_mass := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_cond_mass := lr_defer_event(i).cond_loss_mass_rate * ln_duration;
          END IF;
          lr_remain_pot.cond_mass := lr_remain_pot.cond_mass - lr_defer_event(i).loss_cond_mass;
          ln_alloc_loss_cond_mass := ln_alloc_loss_cond_mass + lr_defer_event(i).loss_cond_mass;       
        END IF;--Block C

        -- WATER_MASS
        IF lb_found_off_def = TRUE THEN--Block C
          IF lr_defer_event(i).water_loss_mass_rate IS NULL THEN--Block D
            lr_defer_event(i).loss_water_mass := 0;
          ELSE--Block D
            IF rec_deferment_event.event_type = 'DOWN' THEN--Block A
              lr_defer_event(i).loss_water_mass := lr_defer_event(i).water_loss_mass_rate * ln_duration;
              ln_water_mass_down_duration := ln_water_mass_down_duration + ln_duration;
            ELSE--Block A
              IF ln_water_mass_down_duration < 1 THEN--Block B
                ln_constraint_hrs:=findConstraintHrs(cur_event_day.daytime, ld_start_daytime,p_object_id,rec_deferment_event.end_date,rec_deferment_event.start_date,lv2_open_end_event);              
                IF lr_potential.water_mass IS NOT NULL THEN--Block E
                  IF lr_remain_pot.water_mass >= (lr_defer_event(i).water_loss_mass_rate * ln_constraint_hrs) THEN
                    IF ln_alloc_loss_water_mass + (lr_defer_event(i).water_loss_mass_rate * ln_constraint_hrs) > lr_potential.water_mass THEN
                      lr_defer_event(i).loss_water_mass := lr_potential.water_mass - ln_alloc_loss_water_mass;
                    ELSE
                      lr_defer_event(i).loss_water_mass := lr_defer_event(i).water_loss_mass_rate * ln_constraint_hrs;
                    END IF;
                  ELSIF lr_remain_pot.water_mass > 0 AND lr_defer_event(i).water_loss_mass_rate > 0 THEN
                    lr_defer_event(i).loss_water_mass := lr_remain_pot.water_mass;
                  ELSE
                    lr_defer_event(i).loss_water_mass := 0;
                  END IF;
                ELSE--Block E
                  lr_defer_event(i).loss_water_mass := lr_defer_event(i).water_loss_mass_rate * ln_constraint_hrs;
                END IF;--Block E                          
              ELSE--Block B
                lr_defer_event(i).loss_water_mass := 0;
              END IF;--Block B
            END IF;--Block A
            lr_remain_pot.water_mass := lr_remain_pot.water_mass - lr_defer_event(i).loss_water_mass;
            ln_alloc_loss_water_mass := ln_alloc_loss_water_mass + lr_defer_event(i).loss_water_mass;  
          END IF;--Block D
        ELSE--Block C    
          IF lr_potential.water_mass IS NOT NULL THEN
            IF lr_remain_pot.water_mass >= (lr_defer_event(i).water_loss_mass_rate * ln_duration) THEN
              IF ln_alloc_loss_water_mass + (lr_defer_event(i).water_loss_mass_rate * ln_duration) > lr_potential.water_mass THEN
                lr_defer_event(i).loss_water_mass := lr_potential.water_mass - ln_alloc_loss_water_mass;
              ELSE
                lr_defer_event(i).loss_water_mass := lr_defer_event(i).water_loss_mass_rate * ln_duration;
              END IF;
            ELSIF lr_remain_pot.water_mass > 0 AND lr_defer_event(i).water_loss_mass_rate > 0 THEN
              lr_defer_event(i).loss_water_mass := lr_remain_pot.water_mass;
            ELSE
              lr_defer_event(i).loss_water_mass := 0;
            END IF;
          ELSE   
            lr_defer_event(i).loss_water_mass := lr_defer_event(i).water_loss_mass_rate * ln_duration;
          END IF;
          lr_remain_pot.water_mass := lr_remain_pot.water_mass - lr_defer_event(i).loss_water_mass;
          ln_alloc_loss_water_mass := ln_alloc_loss_water_mass + lr_defer_event(i).loss_water_mass;       
        END IF;--Block C
        
        BEGIN
          -- Write to database
          ln_rowcount := 0;
          SELECT COUNT(*) INTO ln_rowcount
          FROM WELL_DAY_DEFER_ALLOC wda
          WHERE wda.object_id=p_object_id
          AND wda.daytime=cur_event_day.daytime
          AND wda.event_no=lr_defer_event(i).event_no;
          -- Insert or update
          IF ln_rowcount=0 THEN
            INSERT INTO WELL_DAY_DEFER_ALLOC
              (object_id, daytime, event_no,
              deferred_gas_vol, deferred_net_oil_vol, deferred_water_vol, deferred_cond_vol,
              deferred_gl_vol, deferred_diluent_vol, deferred_steam_inj_vol, deferred_gas_inj_vol, deferred_water_inj_vol,
              deferred_net_oil_mass, deferred_gas_mass, deferred_cond_mass, deferred_water_mass, 
              created_by)
            VALUES
              (p_object_id, cur_event_day.daytime, lr_defer_event(i).event_no,
              NVL(lr_defer_event(i).loss_gas,0),NVL(lr_defer_event(i).loss_oil,0),NVL(lr_defer_event(i).loss_water,0), NVL(lr_defer_event(i).loss_cond,0),
              NVL(lr_defer_event(i).loss_gas_lift,0), NVL(lr_defer_event(i).loss_diluent,0), NVL(lr_defer_event(i).loss_steam_inj,0), NVL(lr_defer_event(i).loss_gas_inj,0), NVL(lr_defer_event(i).loss_water_inj,0),
              NVL(lr_defer_event(i).loss_oil_mass,0), NVL(lr_defer_event(i).loss_gas_mass,0), NVL(lr_defer_event(i).loss_cond_mass,0), NVL(lr_defer_event(i).loss_water_mass,0),
              NVL(ecdp_context.getAppUser(),USER));
          ELSE
            -- one event is part of several periods, then we have to update existing record for the wde_no and daytime
            UPDATE WELL_DAY_DEFER_ALLOC
            SET deferred_gas_vol = deferred_gas_vol + NVL(lr_defer_event(i).loss_gas,0),
                deferred_net_oil_vol = deferred_net_oil_vol + NVL(lr_defer_event(i).loss_oil,0),
                deferred_water_vol = deferred_water_vol + NVL(lr_defer_event(i).loss_water,0),
                deferred_cond_vol = deferred_cond_vol + NVL(lr_defer_event(i).loss_cond,0),
                deferred_gl_vol = deferred_gl_vol + NVL(lr_defer_event(i).loss_gas_lift,0),
                deferred_diluent_vol = deferred_diluent_vol + NVL(lr_defer_event(i).loss_diluent,0),
                deferred_steam_inj_vol = deferred_steam_inj_vol + NVL(lr_defer_event(i).loss_steam_inj,0),
                deferred_gas_inj_vol = deferred_gas_inj_vol + NVL(lr_defer_event(i).loss_gas_inj,0),
                deferred_water_inj_vol = deferred_water_inj_vol + NVL(lr_defer_event(i).loss_water_inj,0),
                deferred_gas_mass = deferred_gas_mass + NVL(lr_defer_event(i).loss_gas_mass,0),                            
                deferred_net_oil_mass = deferred_net_oil_mass + NVL(lr_defer_event(i).loss_oil_mass,0),                            
                deferred_cond_mass = deferred_cond_mass + NVL(lr_defer_event(i).loss_cond_mass,0),                            
                deferred_water_mass = deferred_water_mass + NVL(lr_defer_event(i).loss_water_mass,0),              
                last_updated_by = NVL(EcDp_Context.getAppUser,USER)
            WHERE object_id = p_object_id
            AND daytime = cur_event_day.daytime
            AND event_no = lr_defer_event(i).event_no;
          END IF;
        EXCEPTION 
          WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20358,'Fail inserting a duplicate record at WELL_DAY_DEFER_ALLOC table.');
        END;            
        <<SKIP_CALC>> NULL;
      END LOOP;
      CLOSE rc_deferment;
    END IF;
  END LOOP;
END allocWellDeferredVolume;


---------------------------------------------------------------------------------------------------
-- Procedure      : checkLockInd
-- Description    : Checks lock indicator from SYSTEM_MONTH, for given daytime value, Returns error if
--                  lock ind = Y
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE checkLockInd(p_result_no NUMBER, p_daytime DATE, p_end_date DATE, p_object_id VARCHAR2)
IS
  lv2_object_class_name VARCHAR2(32);
  ln_prod_day_offset NUMBER;
  ld_new_daytime DATE;
  ld_new_end_date DATE;

BEGIN

  lv2_object_class_name := ecdp_objects.GetObjClassName(p_object_id);
  ln_prod_day_offset := EcDp_ProductionDay.getProductionDayOffset(lv2_object_class_name,p_object_id, p_daytime)/24;

  ld_new_daytime := p_daytime - ln_prod_day_offset;
  ld_new_end_date := p_end_date - ln_prod_day_offset;

  EcDp_Month_Lock.validatePeriodForLockOverlap('UPDATING', ld_new_daytime, ld_new_end_date,
                                               'Event No:'|| p_result_no, p_object_id);

END checkLockInd;

---------------------------------------------------------------------------------------------------
-- Procedure      : prev_equal_eventday
-- Description    : To get the event date duration.
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION prev_equal_eventday(p_object_id VARCHAR2, p_daytime DATE, p_num_rows NUMBER DEFAULT 1)
RETURN DATE IS

  CURSOR c_compute IS
  SELECT event_day
  FROM well_swing_connection
  WHERE object_id = p_object_id
  AND event_day <= p_daytime
  ORDER BY event_day DESC;

  ld_return_val DATE := NULL;

BEGIN
  IF p_num_rows >= 1 THEN
    FOR cur_rec IN c_compute LOOP
      ld_return_val := cur_rec.event_day;
      IF c_compute%ROWCOUNT = p_num_rows THEN
        EXIT;
      END IF;
    END LOOP;
  END IF;
  RETURN ld_return_val;
END prev_equal_eventday;

---------------------------------------------------------------------------------------------------
-- Procedure      : checkSwingWell
-- Description    : To check if the well has been swing to another asset
-- Preconditions  :
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
FUNCTION checkSwingWell(p_swing VARCHAR2,
                        p_event VARCHAR2,
                        p_well VARCHAR2,
                        p_daytime DATE,
                        p_fcty_id VARCHAR2,
                        p_group_type VARCHAR2,
                        p_class_name VARCHAR2,
                        p_parent_type VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

  lv2_swing_fcty        VARCHAR2(32);
  lv2_isSwing           VARCHAR2(1);
  lv2_fcty_hookup       VARCHAR2(32);

  CURSOR c_swing_to_asset IS
  SELECT ASSET_ID as swing_fcty
  FROM well_swing_connection wsc
  WHERE wsc.object_id = p_well
  AND wsc.EVENT_DAY = (select max(wsc2.EVENT_DAY)
                      from well_swing_connection wsc2
                      where wsc2.EVENT_DAY <= p_daytime
                      and wsc2.OBJECT_ID = wsc.object_id)
  AND wsc.asset_id <> ec_well_version.op_fcty_class_1_id(p_well, p_daytime, '<=');

  CURSOR c_swing_out_asset IS
  SELECT ASSET_ID as swing_fcty
  FROM well_swing_connection wsc
  WHERE wsc.object_id = p_well
  AND wsc.EVENT_DAY = (select max(wsc2.EVENT_DAY)
                     from well_swing_connection wsc2
                     where wsc2.EVENT_DAY <= p_daytime
                     and wsc2.OBJECT_ID = wsc.object_id);

BEGIN

  lv2_isSwing := 'N';

  IF p_swing = 'IN' THEN
    FOR swing_to_asset in c_swing_to_asset LOOP
      lv2_swing_fcty := swing_to_asset.swing_fcty;

      IF ecdp_objects.getobjclassname(lv2_swing_fcty) = 'WELL_HOOKUP' AND p_event = 'GROUP' THEN
        IF p_parent_type = 'WELL_HOOKUP' THEN
           lv2_fcty_hookup := ecgp_group.findParentObjectId( p_group_type, p_class_name, 'WELL_HOOKUP', lv2_swing_fcty, p_daytime);
        END IF;
        IF lv2_fcty_hookup = p_fcty_id THEN
          lv2_isSwing := 'Y';
        END IF;
      ELSE
        IF lv2_swing_fcty = p_fcty_id THEN
          lv2_isSwing := 'Y';
        END IF;
      END IF;

    END LOOP;

  ELSIF p_swing = 'OUT' THEN
    FOR swing_out_asset in c_swing_out_asset LOOP
      lv2_swing_fcty := swing_out_asset.swing_fcty;

      IF ecdp_objects.getobjclassname(lv2_swing_fcty) = 'WELL_HOOKUP' THEN
        lv2_fcty_hookup := ecgp_group.findParentObjectId( p_group_type, p_class_name, 'WELL_HOOKUP', lv2_swing_fcty, p_daytime);
        IF lv2_fcty_hookup <> p_fcty_id THEN
          lv2_isSwing := 'Y';
        END IF;
      ELSE
        IF lv2_swing_fcty <> p_fcty_id THEN
          lv2_isSwing := 'Y';
        END IF;
      END IF;

    END LOOP;
  END IF;

  RETURN lv2_isSwing;

END checkSwingWell;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : updateEventEqpmForChild
-- Description    : Update Event,Eqpm link Code of child to be same as parent.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE updateEventEqpmForChild(p_event_no NUMBER,
                                        p_user VARCHAR2,
                                  p_last_updated_date DATE)
--</EC-DOC>
IS
  CURSOR c_link_code IS
  SELECT wed.master_event_id,wed.equipment_id
  FROM deferment_event wed
  WHERE wed.event_no = p_event_no
  AND wed.class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

 BEGIN

  FOR cur_link_code IN c_link_code LOOP
    UPDATE deferment_event
    SET master_event_id=cur_link_code.master_event_id
        ,equipment_id=cur_link_code.equipment_id
        ,last_updated_by =  p_user
        ,last_updated_date = p_last_updated_date
    WHERE deferment_type = 'GROUP_CHILD'
    AND parent_event_no = p_event_no
    AND class_name IN ('WELL_DEFERMENT','WELL_DEFERMENT_CHILD');

  END LOOP;

END updateEventEqpmForChild;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : verifyDefermentDayEvent
-- Description    : The Procedure verifies the records in both Event and Day sections of Deferment Day screen.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event and deferment_day
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE verifyDefermentDayEvent(p_event_no NUMBER,
                                  p_user_name VARCHAR2)
--</EC-DOC>
IS

  ln_exists NUMBER;
  lv2_last_update_date VARCHAR2(20);

  ld_valid_from_date DATE;
  ld_valid_to_date DATE;
  lv2_object_id VARCHAR2(32);
  
BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

  ld_valid_from_date := ec_deferment_event.daytime(p_event_no);
  ld_valid_to_date := ec_deferment_event.end_date(p_event_no);
  lv2_object_id := ec_deferment_event.object_id(p_event_no);

  EcDp_Deferment.checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

  SELECT COUNT(*) INTO ln_exists FROM deferment_event WHERE EVENT_NO  = p_event_no AND RECORD_STATUS = 'A' AND CLASS_NAME = 'DEFERMENT_EVENT';

  IF ln_exists = 0 THEN
  -- Update parent
    UPDATE deferment_event a
    SET a.RECORD_STATUS='V',
        a.LAST_UPDATED_BY = p_user_name,
        a.LAST_UPDATED_DATE = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
        a.REV_TEXT = 'Verified at ' ||  lv2_last_update_date
    WHERE a.EVENT_NO = p_event_no
    AND a.CLASS_NAME = 'DEFERMENT_EVENT';

  -- update child
    UPDATE DEFERMENT_DAY b
    SET b.RECORD_STATUS='V',
        b.LAST_UPDATED_BY = p_user_name,
        b.LAST_UPDATED_DATE = to_date (lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
        b.REV_TEXT = 'Verified at ' ||  lv2_last_update_date
    WHERE b.EVENT_NO = p_event_no
    AND b.CLASS_NAME = 'DEFERMENT_DAY';

  ELSE
    RAISE_APPLICATION_ERROR('-20223','Record with Approved status cannot be Verified again.');
  END IF;

END verifyDefermentDayEvent;

---------------------------------------------------------------------------------------------------
-- Procedure      : approveDefermentDayEvent
-- Description    : The Procedure approve the records in both Event and Day sections of Deferment Day screen.
--
-- Preconditions  :
-- Postconditions :
--
-- Using tables   : deferment_event and deferment_day
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      : -
--
---------------------------------------------------------------------------------------------------
PROCEDURE approveDefermentDayEvent(p_event_no NUMBER,
                                   p_user_name VARCHAR2)
--</EC-DOC>
IS

  lv2_last_update_date VARCHAR2(20);
  ld_valid_from_date DATE;
  ld_valid_to_date DATE;
  lv2_object_id VARCHAR2(32);

BEGIN
  lv2_last_update_date := to_char(Ecdp_Timestamp.getCurrentSysdate, 'YYYY-MM-DD"T"HH24:MI:SS')  ;

  ld_valid_from_date := ec_deferment_event.daytime(p_event_no);
  ld_valid_to_date := ec_deferment_event.end_date(p_event_no);
  lv2_object_id := ec_deferment_event.object_id(p_event_no);

  EcDp_Deferment.checkLockInd(p_event_no, ld_valid_from_date, ld_valid_to_date, lv2_object_id);

  -- update parent
  UPDATE deferment_event a
  SET a.RECORD_STATUS='A',
      a.LAST_UPDATED_BY = p_user_name,
      a.LAST_UPDATED_DATE = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
      a.REV_TEXT = 'Approved at ' ||  lv2_last_update_date
  WHERE a.EVENT_NO = p_event_no
  AND a.CLASS_NAME = 'DEFERMENT_EVENT';

  -- update child
  UPDATE DEFERMENT_DAY b
  SET b.RECORD_STATUS='A',
      b.LAST_UPDATED_BY = p_user_name,
      b.LAST_UPDATED_DATE = to_date(lv2_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS'),
      b.REV_TEXT = 'Approved at ' || lv2_last_update_date
  WHERE b.EVENT_NO = p_event_no
  AND b.CLASS_NAME = 'DEFERMENT_DAY';

END approveDefermentDayEvent;

--<EC-DOC>
---------------------------------------------------------------------------------------------------------
-- Procedure      : changeDefermentDay
-- Description    : change the Deferment Day records based on the Deferment Event Start and End 
--                : Daytime based on the change_type of "INSERT" or "UPDATE"
-- Preconditions  : 
-- Postconditions : 
--
-- Using tables   : deferment_day
--
--
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------------
PROCEDURE changeDefermentDay(p_change_type VARCHAR2, p_object_id VARCHAR2, p_event_no NUMBER, p_daytime DATE, p_end_daytime DATE DEFAULT NULL, p_user VARCHAR2)
IS
  ln_prod_day_offset NUMBER;    
  ld_pDayOfpStdaytime DATE;  
  ld_pDayOfpEndDaytime DATE;  
  -- This StFutureDate is the next day 00:00 or 06:00 of next day of current production day.
  ld_StFutureDate DATE := (Trunc(Ecdp_Timestamp.getCurrentSysdate) + 1 + (Ecdp_Productionday.getProductionDayOffset(null, p_object_id, p_daytime)/24));
  lb_hitNextDaySameTime BOOLEAN := FALSE;  
  ld_currentStDay DATE  := ec_deferment_day.next_equal_daytime(p_event_no, p_object_id, to_date('1800-01-01', 'YYYY-MM-DD'));
  ld_currentEndDay DATE := ec_deferment_day.prev_equal_daytime(p_event_no, p_object_id, to_date('2900-01-01', 'YYYY-MM-DD'));
  lb_futureDateEntry BOOLEAN := FALSE;  
  ld_StDateAddRows1stPart   DATE;
  ld_EndDateAddRows1stPart  DATE;
  ld_StDateAddRows2ndPart   DATE;
  ld_EndDateAddRows2ndPart  DATE;
  ld_StDateDelRows1stPart   DATE;
  ld_EndDateDelRows1stPart  DATE;
  ld_StDateDelRows2ndPart   DATE;
  ld_EndDateDelRows2ndPart  DATE;
BEGIN
  ln_prod_day_offset := Ecdp_Productionday.getProductionDayOffset(null, p_object_id, p_daytime)/24;
  ld_pDayOfpStdaytime := Ecdp_Productionday.getProductionDay(null, p_object_id, p_daytime);
  
  IF p_daytime > ld_StFutureDate THEN
    lb_futureDateEntry := TRUE;
  END IF;  
  -- Requirement on future date:
  -- If p_daytime is at future date and p_end_daytime is NULL, then save the row at deferment_event and do not add rows to deferment_day when insert.
  -- If p_daytime is at future date and p_end_daytime is NULL, then save the row at deferment_event and remove all existing rows at deferment_day when update.
  -- Note: future date is one day after current Production Day.

  IF p_end_daytime IS NULL AND lb_futureDateEntry = FALSE THEN
    --ld_pDayOfpEndDaytime := Ecdp_Timestamp.getCurrentSysdate + ln_prod_day_offset;
    ld_pDayOfpEndDaytime := (Trunc(Ecdp_Timestamp.getCurrentSysdate) + 1 + (ln_prod_day_offset));
    IF ld_pDayOfpEndDaytime - TRUNC(ld_pDayOfpEndDaytime) = ln_prod_day_offset THEN
      lb_hitNextDaySameTime := TRUE;
    END IF;
  ELSE
    ld_pDayOfpEndDaytime := Ecdp_Productionday.getProductionDay(null, p_object_id, p_end_daytime); 
    IF ln_prod_day_offset < 0 THEN
      IF p_end_daytime - TRUNC(p_end_daytime) = (1 - abs(ln_prod_day_offset)) THEN
        lb_hitNextDaySameTime := TRUE;
      END IF;        
    ELSE
      IF p_end_daytime - TRUNC(p_end_daytime) = ln_prod_day_offset THEN
        lb_hitNextDaySameTime := TRUE;
      END IF;
    END IF;  
  END IF;
  IF lb_hitNextDaySameTime = TRUE THEN
    ld_pDayOfpEndDaytime := ld_pDayOfpEndDaytime - 1;
  END IF;

  IF p_change_type = 'UPDATE' THEN
    -- Determine the days to insert the deferment day child records, and also to delete the unwanted child records.
    
    IF ld_pDayOfpEndDaytime < ld_currentStDay OR ld_pDayOfpStdaytime > ld_currentEndDay THEN
       -- When the new start and end date are both new dates, define the new start and end date to add rows, and define old dates for deletion. 
       -- (Refer to design logic for updating the dates position for all cases below at attachment - Detail test on different production day types on ECPD-43525)
       -- Case 1 or Case 2 
      ld_StDateAddRows1stPart  := ld_pDayOfpStdaytime;
      ld_EndDateAddRows1stPart := ld_pDayOfpEndDaytime;
      ld_StDateDelRows1stPart  := ld_currentStDay;
      ld_EndDateDelRows1stPart := ld_currentEndDay;
    ELSIF ld_pDayOfpStdaytime < ld_currentStDay AND ld_pDayOfpEndDaytime > ld_currentEndDay THEN
      -- When the new start and end dates are covering entire current start and end dates, new start date to current date are required, current end date +1 to new end date are required,
      -- else will be removed.
      -- Case 3
      ld_StDateAddRows1stPart  := ld_pDayOfpStdaytime;
      ld_EndDateAddRows1stPart := ld_currentStDay - 1;
      ld_StDateAddRows2ndPart  := ld_currentEndDay + 1;
      ld_EndDateAddRows2ndPart := ld_pDayOfpEndDaytime;
    ELSIF ld_pDayOfpStdaytime < ld_currentStDay AND ld_pDayOfpEndDaytime < ld_currentEndDay THEN
      -- Case 4
      ld_StDateAddRows1stPart  := ld_pDayOfpStdaytime;
      ld_EndDateAddRows1stPart := ld_currentStDay - 1;
      ld_StDateDelRows1stPart  := ld_pDayOfpEndDaytime + 1;
      ld_EndDateDelRows1stPart := ld_currentEndDay;
    ELSIF ld_pDayOfpStdaytime > ld_currentStDay AND ld_pDayOfpEndDaytime > ld_currentEndDay THEN
      -- Case 5
      ld_StDateAddRows1stPart  := ld_currentEndDay + 1;
      ld_EndDateAddRows1stPart := ld_pDayOfpEndDaytime;
      ld_StDateDelRows1stPart  := ld_currentStDay;
      ld_EndDateDelRows1stPart := ld_pDayOfpStdaytime - 1;
    ELSIF ld_pDayOfpStdaytime = ld_currentStDay AND ld_pDayOfpEndDaytime = ld_currentEndDay THEN
      -- Case 6
      NULL;
    ELSIF ld_pDayOfpStdaytime > ld_currentStDay AND ld_pDayOfpEndDaytime < ld_currentEndDay THEN 
      -- Case 7
      ld_StDateDelRows1stPart  := ld_currentStDay;
      ld_EndDateDelRows1stPart := ld_pDayOfpStdaytime - 1;
      ld_StDateDelRows2ndPart  := ld_pDayOfpEndDaytime + 1;
      ld_EndDateDelRows2ndPart := ld_currentEndDay;
    ELSIF ld_pDayOfpStdaytime < ld_currentStDay AND ld_pDayOfpEndDaytime = ld_currentEndDay THEN    
      -- Case 8
      ld_StDateAddRows1stPart  := ld_pDayOfpStdaytime;
      ld_EndDateAddRows1stPart := ld_currentStDay - 1;
    ELSIF ld_pDayOfpStdaytime = ld_currentStDay AND ld_pDayOfpEndDaytime > ld_currentEndDay THEN    
      -- Case 9
      ld_StDateAddRows1stPart  := ld_currentEndDay + 1;
      ld_EndDateAddRows1stPart := ld_pDayOfpEndDaytime;
    ELSIF ld_pDayOfpStdaytime = ld_currentStDay AND ld_pDayOfpEndDaytime < ld_currentEndDay THEN
      -- Case 10
      ld_StDateDelRows1stPart  := ld_pDayOfpEndDaytime + 1;
      ld_EndDateDelRows1stPart := ld_currentEndDay;
    ELSIF ld_pDayOfpStdaytime > ld_currentStDay AND ld_pDayOfpEndDaytime = ld_currentEndDay THEN
      -- Case 11
      ld_StDateDelRows1stPart  := ld_currentStDay;
      ld_EndDateDelRows1stPart := ld_pDayOfpStdaytime - 1;
    END IF;

    IF ld_StDateAddRows1stPart IS NOT NULL AND ld_EndDateAddRows1stPart IS NOT NULL THEN
      EcDp_Deferment.AddRowsAtDefDayTable(p_event_no, p_object_id, ld_StDateAddRows1stPart, ld_EndDateAddRows1stPart, p_user);
    END IF;
    
    IF ld_StDateAddRows2ndPart IS NOT NULL AND ld_EndDateAddRows2ndPart IS NOT NULL THEN
      EcDp_Deferment.AddRowsAtDefDayTable(p_event_no, p_object_id, ld_StDateAddRows2ndPart, ld_EndDateAddRows2ndPart, p_user);
    END IF; 
    
    -- Since the dates at deferment event can be changed to the different new dates, old child deferment day records should be deleted.
    -- However, the deferment day child records were created with truncated table 00:00, therefore the identified dates
    -- for deletion at deferment day should also be truncated by the previous offset added.
    IF ld_StDateDelRows1stPart <> TRUNC(ld_StDateDelRows1stPart) THEN
      IF ln_prod_day_offset > 0 THEN
         ld_StDateDelRows1stPart := ld_StDateDelRows1stPart - ln_prod_day_offset;
      ELSIF ln_prod_day_offset < 0 THEN    
      ld_StDateDelRows1stPart := ld_StDateDelRows1stPart - (1-abs(ln_prod_day_offset));    
      END IF;
    ELSIF ld_EndDateDelRows1stPart <> TRUNC(ld_EndDateDelRows1stPart) THEN
      IF ln_prod_day_offset > 0 THEN
        ld_EndDateDelRows1stPart := ld_EndDateDelRows1stPart - ln_prod_day_offset;
      ELSIF ln_prod_day_offset < 0 THEN  
        ld_EndDateDelRows1stPart := ld_EndDateDelRows1stPart - (1-abs(ln_prod_day_offset));    
      END IF;  
    ELSIF ld_StDateDelRows2ndPart <> TRUNC(ld_StDateDelRows2ndPart) THEN
      IF ln_prod_day_offset > 0 THEN
        ld_StDateDelRows2ndPart := ld_StDateDelRows2ndPart - ln_prod_day_offset;
      ELSIF ln_prod_day_offset < 0 THEN  
        ld_StDateDelRows2ndPart := ld_StDateDelRows2ndPart - (1-abs(ln_prod_day_offset));    
      END IF;  
    ELSIF ld_EndDateDelRows2ndPart <> TRUNC(ld_EndDateDelRows2ndPart) THEN
      IF ln_prod_day_offset > 0 THEN
        ld_EndDateDelRows2ndPart := ld_EndDateDelRows2ndPart - ln_prod_day_offset;
      ELSIF ln_prod_day_offset < 0 THEN  
        ld_EndDateDelRows2ndPart := ld_EndDateDelRows2ndPart - (1-abs(ln_prod_day_offset));  
      END IF;
    END IF;      
    
    IF ld_StDateDelRows1stPart IS NOT NULL AND ld_EndDateDelRows1stPart IS NOT NULL THEN
      DELETE FROM deferment_day a WHERE a.event_no = p_event_no AND a.daytime between ld_StDateDelRows1stPart AND ld_EndDateDelRows1stPart;
    END IF;
    
    IF ld_StDateDelRows2ndPart IS NOT NULL AND ld_EndDateDelRows2ndPart IS NOT NULL THEN    
      DELETE FROM deferment_day a WHERE a.event_no = p_event_no AND a.daytime between ld_StDateDelRows2ndPart AND ld_EndDateDelRows2ndPart;
    END IF;
    
    IF ld_currentStDay IS NULL and ld_currentEndDay IS NULL THEN
      -- if p_change_type is 'UPDATE' and without ld_currentStDay and ld_currentEndDay value, this entry probably hit the future date with NULL end daytime, and resulted no days populated.
      -- Now, user is trying to to fix here again, so the logic here should treat this 'UPDATE' as 'INSERT' to place the correct new entries.
      EcDp_Deferment.AddRowsAtDefDayTable(p_event_no, p_object_id, ld_pDayOfpStdaytime, ld_pDayOfpEndDaytime, p_user);
    END IF;
    
  ELSIF p_change_type = 'INSERT' THEN 
    IF ld_pDayOfpStdaytime IS NOT NULL AND ld_pDayOfpEndDaytime IS NOT NULL THEN
      EcDp_Deferment.AddRowsAtDefDayTable(p_event_no, p_object_id, ld_pDayOfpStdaytime, ld_pDayOfpEndDaytime, p_user);
    END IF;
  END IF;  
  
END changeDefermentDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deleteDefermentDay
-- Description    : Delete deferment day records
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : deferment_day
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deleteDefermentDay(p_event_no NUMBER)
--</EC-DOC>
IS
BEGIN

DELETE FROM deferment_day WHERE event_no = p_event_no;

END deleteDefermentDay;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : getSumLossMassDefDay
-- Description    : Get the Sum of Loss or Mass Volume on various production phase reported from the sum view based on the Deferment Day table
--
--
-- Preconditions  :
-- Postconditions :
--
-- Using view     : V_DEFERMENT_DAY_SUM
--
--
--
-- Using functions:
--
-- Configuration
-- required       : 
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
FUNCTION getSumLossMassDefDay(p_attribute VARCHAR2, p_event_no NUMBER) 
RETURN NUMBER
--</EC-DOC>
IS
  lv2_tmpSQL            VARCHAR2(1000);  
  ln_RETURNVal          NUMBER;
BEGIN  
  lv2_tmpSQL := 'SELECT ' || p_attribute || ' FROM V_DEFERMENT_DAY_SUM WHERE EVENT_NO = :p_event_no';
  
  IF lv2_tmpSQL IS NOT NULL THEN
    EXECUTE IMMEDIATE lv2_tmpSQL INTO ln_RETURNVal USING p_event_no;
  END IF;
  RETURN ln_RETURNVal;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;  
END getSumLossMassDefDay;  

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : AddRowsAtDefDayTable
-- Description    : Add rows at Deferment Event Day table
--
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : deferment_day
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE AddRowsAtDefDayTable(p_event_no NUMBER, p_object_id VARCHAR2, p_stDate DATE, p_endDate DATE, p_user VARCHAR2)
--</EC-DOC>
IS
  ln_loopStJulianDate  NUMBER := to_number(to_char(p_stDate, 'J'));
  ln_loopEndJulianDate NUMBER := to_number(to_char(p_endDate,'J')); 
BEGIN
  IF  ln_loopStJulianDate IS NOT NULL AND ln_loopEndJulianDate IS NOT NULL THEN
    FOR loopDate IN ln_loopStJulianDate..ln_loopEndJulianDate LOOP
      INSERT INTO deferment_day
      (event_no, object_id, daytime, created_by, created_date, class_name )
        VALUES
      (p_event_no, p_object_id, to_date(loopDate, 'j'), p_user, Ecdp_Timestamp.getCurrentSysdate, 'DEFERMENT_DAY');        
    END LOOP;
  END IF;  
END AddRowsAtDefDayTable;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : reuseOverlappedRecords
-- Description    : To reuse the overlapped deferment after changes on the current modified 
--                  deferment record or current deletion, so that Event Loss will be recalculated again
--
-- Preconditions  :
-- Postconditions : .
--
-- Using tables   : deferment_event
--
--
--
-- Using functions:
-- Configuration
-- required       :
--
-- Behavior       :
--
---------------------------------------------------------------------------------------------------
PROCEDURE reuseOverlappedRecords(p_event_no NUMBER, p_object_id VARCHAR2, p_daytime DATE, p_end_date DATE DEFAULT NULL, p_object_type VARCHAR2, p_deferment_type VARCHAR2, p_user VARCHAR2, p_last_updated_date DATE)
--</EC-DOC>
IS
  CURSOR cur_getChildDeferment (cp_event_no NUMBER) IS 
  SELECT a.event_no, a.object_id, a.daytime, a.end_date 
  FROM deferment_event a 
  WHERE a.parent_event_no = cp_event_no
  AND a.object_type = 'WELL';
  
  CURSOR cur_getOverlappedEvents (cp_event_no NUMBER, cp_wellobjectId VARCHAR2, cp_daytime DATE, cp_enddate DATE DEFAULT NULL, cp_currSysDTMinusOne DATE) IS
  SELECT a.event_no, a.parent_event_no, a.daytime, a.end_date
  FROM deferment_event a
  WHERE a.event_no <> cp_event_no
  AND a.object_id = cp_wellObjectId 
  AND NOT
  (
  a.daytime < cp_daytime AND NVL(a.end_date, cp_currSysDTMinusOne) <= cp_daytime
  OR
  a.daytime >= NVL(cp_enddate, cp_currSysDTMinusOne) AND NVL(a.end_date, cp_currSysDTMinusOne) > NVL(cp_enddate, cp_currSysDTMinusOne)
  );
  
  ln_Event_no              DEFERMENT_EVENT.EVENT_NO%TYPE;
  lv2_object_id            DEFERMENT_EVENT.OBJECT_ID%TYPE; 
  ld_daytime               DEFERMENT_EVENT.DAYTIME%TYPE; 
  ld_end_date              DEFERMENT_EVENT.END_DATE%TYPE;
  ln_OverlappedEvent_no    DEFERMENT_EVENT.EVENT_NO%TYPE;
  ln_OverlappedParentE_no  DEFERMENT_EVENT.PARENT_EVENT_NO%TYPE;
  ld_OverlappedDaytime     DEFERMENT_EVENT.DAYTIME%TYPE;
  ld_OverlappedEnd_date    DEFERMENT_EVENT.END_DATE%TYPE;
  
  ln_aCount_no             NUMBER;
  ln_bCount_no             NUMBER;
  lb_foundMatchedEvent     BOOLEAN := FALSE; 
  ld_currSysDtMinusOne     DATE;
  
  typ_srcEventNoforReCalc      t_sourceEventNoforReCalc      := t_sourceEventNoforReCalc();  
  typ_srcEventObjectID         t_sourceEventObjectID         := t_sourceEventObjectID();     
  typ_srcEventDaytime          t_sourceEventDaytime          := t_sourceEventDaytime();      
  typ_srcEventEnd_date         t_sourceEventEnd_date         := t_sourceEventEnd_date();     
  typ_tgtEventNoforReCalc      t_targetEventNoforReCalc      := t_targetEventNoforReCalc();  
  typ_tgtParentENoforReCalc    t_targetParentENoforReCalc    := t_targetParentENoforReCalc();
  typ_tgtDaytimeforReCalc      t_targetDaytimeforReCalc      := t_targetDaytimeforReCalc();  
  typ_tgtEnd_dateforReCalc     t_targetEnd_dateforReCalc     := t_targetEnd_dateforReCalc(); 

BEGIN
  -- Delete a group of deferment events and that will loop thru each child to check with its related events to be reused for recalculation
  ln_aCount_no := 0;
  ln_bCount_no := 0;
  
  IF p_deferment_type = 'GROUP' THEN
    OPEN cur_getChildDeferment(p_event_no);
    LOOP
      FETCH cur_getChildDeferment INTO ln_event_no, lv2_object_id, ld_daytime, ld_end_date;
      EXIT WHEN cur_getChildDeferment%NOTFOUND; 
      ln_aCount_no := ln_aCount_no + 1;
      typ_srcEventNoforReCalc.EXTEND;
      typ_srcEventObjectID.EXTEND;   
      typ_srcEventDaytime.EXTEND;    
      typ_srcEventEnd_date.EXTEND;   
      typ_srcEventNoforReCalc(ln_aCount_no) :=  ln_event_no;
      typ_srcEventObjectID(ln_aCount_no)    :=  lv2_object_id;
      typ_srcEventDaytime(ln_aCount_no)     :=  ld_daytime;
      typ_srcEventEnd_date(ln_aCount_no)    :=  ld_end_date;
    END LOOP;
    CLOSE cur_getChildDeferment;
  ELSE
    IF p_object_type = 'WELL' THEN
      typ_srcEventNoforReCalc.EXTEND;
      typ_srcEventObjectID.EXTEND;   
      typ_srcEventDaytime.EXTEND;    
      typ_srcEventEnd_date.EXTEND;   
      typ_srcEventNoforReCalc(1)           :=  p_event_no;      
      typ_srcEventObjectID(1)              :=  p_object_id;
      typ_srcEventDaytime(1)               :=  p_daytime;
      typ_srcEventEnd_date(1)              :=  p_end_date;
    END IF;  
  END IF;
  
  FOR j IN 1..typ_srcEventNoforReCalc.COUNT LOOP
    -- To be used for open-ended deferment NULL end date
    ld_currSysDtMinusOne := TRUNC(Ecdp_Timestamp.getCurrentSysdate) - 1;
    OPEN cur_getOverlappedEvents(typ_srcEventNoforReCalc(j), typ_srcEventObjectID(j), typ_srcEventDaytime(j), typ_srcEventEnd_date(j), ld_currSysDtMinusOne);
    LOOP
      FETCH cur_getOverlappedEvents INTO ln_OverlappedEvent_no, ln_OverlappedParentE_no, ld_OverlappedDaytime, ld_OverlappedEnd_date;
      EXIT WHEN cur_getOverlappedEvents%NOTFOUND; 
      
      FOR k IN 1..typ_tgtEventNoforReCalc.COUNT LOOP
        IF typ_tgtEventNoforReCalc(k) = ln_OverlappedEvent_no THEN 
          lb_foundMatchedEvent := TRUE;
          EXIT;
        END IF;          
      END LOOP;  
      IF lb_foundMatchedEvent = FALSE THEN
        ln_bCount_no := ln_bCount_no + 1;
        typ_tgtEventNoforReCalc.EXTEND;
        typ_tgtParentENoforReCalc.EXTEND;
        typ_tgtDaytimeforReCalc.EXTEND;
        typ_tgtEnd_dateforReCalc.EXTEND;
        typ_tgtEventNoforReCalc(ln_bCount_no)   := ln_OverlappedEvent_no;
        typ_tgtParentENoforReCalc(ln_bCount_no) := ln_OverlappedParentE_no;
        typ_tgtDaytimeforReCalc(ln_bCount_no)   := ld_OverlappedDaytime;
        typ_tgtEnd_dateforReCalc(ln_bCount_no)  := ld_OverlappedEnd_date;
      END IF; 
      
    END LOOP;
    CLOSE cur_getOverlappedEvents;
  END LOOP;
  
  FOR m IN 1..typ_tgtEventNoforReCalc.COUNT LOOP
    EcDp_Deferment.insertTempWellDefermntAlloc(typ_tgtEventNoforReCalc(m), 
                                               typ_tgtParentENoforReCalc(m),
                                               typ_tgtDaytimeforReCalc(m),
                                               NULL,
                                               typ_tgtEnd_dateforReCalc(m),
                                               NULL,
                                               'X',
                                               p_user,
                                               p_last_updated_date);
  END LOOP;

  -- Letter 'X' is used for Reuse, letter 'R' is supposed to be ideal for Reuse but it is not applicable because 'U' is after the 'R' in the ascending order of I, U, R.
  -- So, if there are multiple temp records for the same event no with IRU, it would not be processed in the right ascending order,
  -- if it uses I Insert, U Update, and X Reuse, then these temp records with the same event no will be processed in the right ascending order if we implement this.

END reuseOverlappedRecords;

END  EcDp_Deferment;
/
