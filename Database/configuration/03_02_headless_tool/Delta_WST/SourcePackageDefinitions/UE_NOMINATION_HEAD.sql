CREATE OR REPLACE PACKAGE ue_Nomination IS
/******************************************************************************
** Package        :  ue_Nomination, head part
**
** $Revision: 1.24 $
**
** Purpose        :  Business logic for nominations
**
** Documentation  :  www.energy-components.com
**
** Created        :  05.03.2008 Kari Sandvik
**
** Modification history:
**
** Date        Whom           Change description:
** --------    --------       -----------------------------------------------------------------------------------------------
** 25.04.2012  leeeewei       ECPD-19477: Added function getOperParam
** 14.05.2012  leeeewei		  ECPD-19477: Added function getSchedQty and getNominatedQty
** 13.06.2012  sharawan		  ECPD-19476: Added function getCapacityUOM
** 12.12.2013  farhaann	      ECPD-26073: Added function getTotalSchedInOutQtyPrBU and getTotalReqTransfInOutQtyPrBU
** 05.02.2014  leeeewei		  ECPD-26615: Added function getInputNominatedQty and getOutputNominatedQty
** 08.05.2014  chooysie		  ECPD-27225: Added function setFactorsEndDate and updateFactorsEndDate
** 21.10.2014  muhammah		  ECPD-28460: Added nomination cycle as parameter to getMatrixReceipt, getMatrixDelivery, getMatrixInventory
** 27.05.2015  asareswi		  ECPD-27052: Added p_nomination_seq as a parameter to the function getSchedQty, getNominatedQty, getInputNominatedQty, getOutputNominatedQty
** 17-06-2015  asareswi		  ECPD-27052: Removed all the IF, ELSE condition from the function getClassUniqueKey.
********************************************************************/

PROCEDURE extConfirmNom(p_nom_seq NUMBER);
PROCEDURE extRejectConfirmedNom(p_nom_seq NUMBER);

PROCEDURE submittNom(p_contract_id VARCHAR2, p_daytime DATE, p_nom_cycle_code VARCHAR2);
FUNCTION calculateBalance(p_input_qty NUMBER, p_output_qty Number) RETURN NUMBER;
FUNCTION calculateTransfBalance(p_contract_id VARCHAR2 DEFAULT NULL, p_date DATE DEFAULT NULL, p_input_qty NUMBER, p_output_qty Number, p_transf_qty NUMBER) RETURN NUMBER;
PROCEDURE getClassUniqueKey (p_class_name IN VARCHAR2, p_cursor OUT SYS_REFCURSOR);

FUNCTION getMatrixReceipt(p_object_id VARCHAR2, p_daytime DATE, p_qty_column VARCHAR2, p_nom_cycle VARCHAR2) RETURN NUMBER;
FUNCTION getMatrixDelivery(p_object_id VARCHAR2, p_daytime DATE, p_qty_column VARCHAR2, p_nom_cycle VARCHAR2) RETURN NUMBER;
FUNCTION getMatrixInventory(p_object_id VARCHAR2, p_daytime DATE, p_qty_column VARCHAR2, p_nom_cycle VARCHAR2) RETURN NUMBER;

-- Day
FUNCTION getTotalReqQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalAccQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalExtAccQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalAdjQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalExtAdjQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalConfQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalExtConfQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalSchedQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;

FUNCTION getTotalReqQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalAccQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalExtAccQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalAdjQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalExtAdjQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalConfQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalExtConfQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;
FUNCTION getTotalSchedQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE) RETURN INTEGER;

FUNCTION getTotalAdjQtyPrLocation(p_loc_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalExtAdjQtyPrLocation(p_loc_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalConfQtyPrLocation(p_loc_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalSchedQtyPrLocation(p_loc_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalAdjInOutQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,   p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalExtAdjInOutQtyPrDpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,   p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalConfInOutQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,   p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalSchedInOutQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,   p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalAdjInOutQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalExtAdjInOutQtyPrDstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalConfInOutQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;
FUNCTION getTotalSchedInOutQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE) RETURN INTEGER;

FUNCTION getTotalSchedInOutQtyPrBU(p_business_unit_id VARCHAR2, p_daytime DATE, p_nomination_type VARCHAR2) RETURN NUMBER;
FUNCTION getTotalReqTransfInOutQtyPrBU(p_business_unit_id VARCHAR2, p_daytime DATE, p_nomination_type VARCHAR2, p_nav_model VARCHAR2) RETURN NUMBER;

-- Sub Day
FUNCTION getSubDayReqQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;
FUNCTION getSubDayAccQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;
FUNCTION getSubDayExtAccQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;
FUNCTION getSubDayAdjQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;
FUNCTION getSubDayExtAdjQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;
FUNCTION getSubDayConfQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;
FUNCTION getSubDayExtConfQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;
FUNCTION getSubDaySchedQtyPrDelpnt(p_delpnt_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;

FUNCTION getSubDayAdjQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;
FUNCTION getSubDayConfQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;
FUNCTION getSubDaySchedQtyPrDelstrm(p_delstrm_id VARCHAR2,p_nom_cycle VARCHAR2,p_date DATE, p_summer_time VARCHAR2, p_nom_type VARCHAR2 DEFAULT 'ENTRY_EXIT') RETURN INTEGER;

FUNCTION getTotalSubDayAdjQtyPrLoc(p_loc_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE, p_summer_time VARCHAR2) RETURN INTEGER;
FUNCTION getTotalSubDayConfQtyPrLoc(p_loc_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE, p_summer_time VARCHAR2) RETURN INTEGER;
FUNCTION getTotalSubDaySchedQtyPrLoc(p_loc_id VARCHAR2,p_nom_cycle VARCHAR2, p_nom_type VARCHAR2, p_date DATE, p_summer_time VARCHAR2) RETURN INTEGER;

-- Nomination popups validation
FUNCTION valid_nompnt(p_nompnt_id VARCHAR2, p_nomination_category VARCHAR2 DEFAULT NULL,  p_bf_number VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
FUNCTION valid_counter_nompnt(p_nompnt_id VARCHAR2, p_ref_nompnt_id VARCHAR2, p_bf_profile VARCHAR2 DEFAULT NULL, p_nomination_category VARCHAR2 DEFAULT NULL, p_bf_number VARCHAR2 DEFAULT NULL, p_show_operational VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

-- Transfer
FUNCTION getTransferCounterQuantity(p_transfer_seq NUMBER, p_column VARCHAR2) RETURN NUMBER;
-- Transfer Summary
FUNCTION getTransferSumQuantity(p_nompnt_id VARCHAR2, p_counter_nompnt_id VARCHAR2,p_daytime DATE, p_column VARCHAR2) RETURN NUMBER;
FUNCTION get_nom_type(p_nompnt_id VARCHAR2, p_counter_nompnt_id VARCHAR2,p_daytime DATE, p_column VARCHAR2) RETURN VARCHAR2;
FUNCTION getTransferSummaryCounterQty(p_daytime DATE, p_nompnt_id VARCHAR2, p_counter_nompnt_id VARCHAR2,  p_column VARCHAR2, p_service VARCHAR2, p_transfer_type VARCHAR2) RETURN NUMBER;
FUNCTION getTransferSummaryDifference(p_nompnt_id VARCHAR2, p_qty NUMBER, p_counter_qty NUMBER, p_transfer_type VARCHAR2, p_daytime DATE) RETURN NUMBER;
FUNCTION qty_sig_converter(p_nompnt_id VARCHAR2, p_transfer_type VARCHAR2,  p_daytime DATE, p_qty NUMBER) RETURN NUMBER;

-- Sub Day Nomination Location Confirmation
PROCEDURE createSubdayConfHours(p_class_name VARCHAR2, p_object_id VARCHAR2, p_daytime DATE, p_contract_id VARCHAR2, p_confirmation_type VARCHAR2, p_day_con_seq NUMBER, p_con_status VARCHAR2);
PROCEDURE createNomConn(p_object_id VARCHAR2, p_daytime DATE, p_counter_nompnt_id VARCHAR2, p_shipper_code VARCHAR2);
PROCEDURE aggrSubDailyToDailyConf(p_object_id VARCHAR2, p_daytime DATE, p_contract_id VARCHAR2, p_summer_time VARCHAR2, p_production_day DATE, p_day_con_seq NUMBER);

--Sub Daily Location Summary
FUNCTION getOperUOM(p_object_id VARCHAR2,p_daytime DATE)RETURN VARCHAR2;
FUNCTION getNominatedQty(p_nomination_seq NUMBER) RETURN NUMBER;
FUNCTION getSchedQty(p_nomination_seq NUMBER)RETURN NUMBER;

--Sub Daily Nomination Location Capacity
FUNCTION getCapacityUOM(p_object_id VARCHAR2,p_daytime DATE) RETURN VARCHAR2;

--Nomination Location Delivery Events
PROCEDURE createCntrEventPrLocation(p_nomLoc_id VARCHAR2, p_daytime DATE, p_eventType VARCHAR2, p_eventSeq NUMBER);
FUNCTION getEventSchedQty(p_eventSeq NUMBER) RETURN NUMBER;
PROCEDURE calculateCntrEvent(p_eventSeq NUMBER);

--Forecast Nomination Location Delivery Events
PROCEDURE createCntrEventPrLocationFcst(p_nomLoc_id VARCHAR2, p_forecast_id   VARCHAR2, p_daytime   DATE, p_eventType VARCHAR2, p_eventSeq  NUMBER);
FUNCTION getEventSchedQtyFcst(p_eventSeq NUMBER, p_forecast_id VARCHAR2) RETURN NUMBER;
PROCEDURE calculateCntrEventFcst(p_eventSeq NUMBER, p_forecast_id VARCHAR2);

--Sub Daily Location Summary
FUNCTION getInputNominatedQty(p_nomination_seq NUMBER) RETURN NUMBER;
FUNCTION getOutputNominatedQty(p_nomination_seq NUMBER) RETURN NUMBER;

PROCEDURE setFactorsEndDate(p_nomination_point_id VARCHAR2, p_daytime DATE, p_class_name VARCHAR2);
PROCEDURE updateFactorsEndDate(p_nomination_point_id VARCHAR2, p_daytime DATE, p_end_date DATE, p_class_name VARCHAR2);
END ue_Nomination;