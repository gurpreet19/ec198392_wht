CREATE OR REPLACE PACKAGE EcDp_Revn_Stim_Fcst IS
/**************************************************************
** Package        :  EcDp_Revn_Stim_Fcst, header part
**
** $Revision: 1.7 $
**
**
** Purpose	:  Forecast functionality
**
** General Logic:
**
** Modification history:
**
** See body part
**
**************************************************************/

PROCEDURE InstantiateStimFcstMthYear(p_forecast_id VARCHAR2, p_stream_item_id VARCHAR2, p_daytime DATE);

PROCEDURE InstantiateStimFcstMth(p_forecast_id VARCHAR2, p_stream_item_id VARCHAR2, p_daytime DATE);

PROCEDURE PopulateStimFcstMth(p_forecast_id VARCHAR2, p_daytime DATE);

PROCEDURE updateSplitKeys(p_forecast_id VARCHAR2);

PROCEDURE ReEstablishStimFcstMth(p_forecast_code VARCHAR2);

END EcDp_Revn_Stim_Fcst;