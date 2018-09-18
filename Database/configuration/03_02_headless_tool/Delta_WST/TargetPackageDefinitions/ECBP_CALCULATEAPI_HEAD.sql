CREATE OR REPLACE PACKAGE EcBp_CalculateAPI IS
/****************************************************************
** Package        :  EcBp_CalculateAPI, header part
** Calcuates API gravity and volume corection factors (VCF)
**  Date        Whom      Change description:
** ----------  --------  --------------------------------------
** 13.12.2010	madondin	ECPD-16071: Added new parameter to pass the event type
** 06.12.2011	mdondin		ECPD-19240: Added new function calcApiTruckTicket,calcApiNotApprovedTruckTicket and calcApiSinglePWEL
**										to provide VCF calculation from the package to screens Truck Ticket Single Transfer, Truck Ticket Single Load Multiple Offload and Single Production Well Test Result
** 23.12.2011   madondin	ECPD-19605:	Added new function getVCFForTruckTicket and getStdDensityForTruckTicket
** 07.11.2012   rajarsar	ECPD-20359: Added 2 new procedures calcNetVol and calcNetVolNotApproved
*****************************************************************/


PROCEDURE calcApiVal(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_event_type VARCHAR2,
   p_user VARCHAR2);

PROCEDURE calcApiNotApprVal(
   p_daytime           DATE,
   p_fcty_class_1_id   VARCHAR2,
   p_event_type VARCHAR2,
   p_user VARCHAR2);

PROCEDURE calcApiTruckTicket(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_event_no VARCHAR2,
   p_user VARCHAR2);

PROCEDURE calcApiNotApprovedTruckTicket(
   p_start_date        DATE,
   p_end_date          DATE,
   p_data_class_name   VARCHAR2,
   p_user VARCHAR2);

PROCEDURE calcApiSinglePWEL(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_result_no   VARCHAR2,
   p_class_name  VARCHAR2,
   p_user VARCHAR2);

FUNCTION getVCFForTruckTicket(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_event_no VARCHAR2)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getVCFForTruckTicket, WNDS, WNPS, RNPS);

FUNCTION getStdDensityForTruckTicket(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_event_no VARCHAR2)

RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (getStdDensityForTruckTicket, WNDS, WNPS, RNPS);

PROCEDURE calcNetVol(
   p_object_id  VARCHAR2,
   p_daytime    DATE,
   p_event_no   VARCHAR2,
   p_class_name  VARCHAR2,
   p_user VARCHAR2);

PROCEDURE calcNetVolNotApproved(
   p_start_date  DATE,
   p_end_date    DATE,
   p_data_class_name  VARCHAR2,
   p_user VARCHAR2);

END EcBp_CalculateAPI;