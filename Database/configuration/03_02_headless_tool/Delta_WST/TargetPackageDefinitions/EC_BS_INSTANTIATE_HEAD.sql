CREATE OR REPLACE PACKAGE ec_bs_instantiate IS
/***********************************************************************************************************************************************
** Package:   Ec_Bs_Instantiate
**
** $Revision: 1.24.12.2 $
**
** Purpose:   Calls Ec_Bs_Obj_Pop which generates dynamic SQL.
**
** Created:   14.10.99  Henk Nevland
**
** How-To: Se www.energy-components.com for full version
**
** Short how-to: Create cursor that finds the primary keys for those tables you want to instantiate. Use the same column sequence as this select:
**    select table_name, column_name, position
**    from user_cons_columns
**    where constraint_name like 'PK%'
**    and table_name='STRM_WATER_ANALYSIS'
**    order by POSITION;
**
** Modification history:
**
**
** Date:     Whom:  Change description:
** --------  ----- --------------------------------------------
** 18.02.04  HNE   Removed obsolete procedures.
** 16.08.04  DN    Removed i_object_item_comment.
** 18.02.2005 Hang  The following codes have been modified in function I_iwel_day_status:
**                  WHERE a.well_type IN ('GI', 'WG') AND p_daytime >= a.daytime to
**                  WHERE a.well_type IN ('OPGI', 'GPI', 'GI', 'WG') AND p_daytime >= a.daytime
**                  in order to accommodate new well types as per enhancement for TI#1874.
** 24.02.2005 Toha  Removed dead codes.
** 09.12.2005 DN    TI2288: Added new_mth_start.
** 26.03.2006 ZAKIIARI TI#3381: Added function i_wbi_day_status to instantiate Well Bore Intervals.
** 04.04.2006 kaurrnar TI#3296: Daily Pipeline Status
** 26.04.2006 Darren TI#2619 Added procedure i_object_item_comment
** 18.07.2006 SSK   TI 3948; Added procedure i_initiate_day
** 19.01.2007 RAJARSAR   Added procedure i_daily_deferment_summary
** 12.02.2007 LAU   ECPD-3632: Added procedure i_iwel_mth_status
** 13.05.2008 Liz   ECPD-5963: Added procedure i_strm_mth_pc_cpy and modified procedure new_month.
** 21.05.2008 Liz   ECPD-5768: Added procedure i_strm_day_pc_cp and modified procedure new_day_end.
** 21.05.2008 Liz   ECPD-5769: Added procedure i_strm_mth_pc_cp and modified procedure new_month.
** 15.09.2008 Farhaann ECPD-6540: Added procedure i_object_item_mth_comment
** 31.10.2008 Liz      ECPD-6067: Modified mostly all functions and procedures to cater for the local lock checking.
** 28.01.2010 Farhaann ECPD-13601: Added procedure i_chem_inj_point_status
** 24.03.2010 RAJARSAR ECPD-4828: Added procedure i_strm_day_asset_data
** 09.12.2010 KUMARSUR ECPD-16067: Added procedure  i_strm_day_pc_cpy
** 12.7.2012  KUMARSUR ECPD-21326: Added procedure  i_well_hookup_day_status
** 08.08.2012 makkkkam ECPD-21684: Added procedure i_defer_loss_acc_fcty
***********************************************************************************************************************************************/

FUNCTION date_string(p_daytime DATE) RETURN VARCHAR2;

-- For jobs that should be instantiated in the beginnng of the production day
PROCEDURE new_day_start             (p_daytime DATE);
-- For jobs that should be instantiated in the end of the production day
PROCEDURE new_day_end               (p_daytime DATE, p_to_daytime DATE DEFAULT NULL);

PROCEDURE new_mth_start(p_daytime DATE);

-- Create records for a new month
PROCEDURE new_month(p_daytime DATE, p_local_lock VARCHAR2);

PROCEDURE i_strm_day_stream         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_strm_water_analysis     (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_strm_mth_stream         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_fcty_day_hse            (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_fcty_day_pob            (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_object_day_weather      (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_pflw_day_status         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_well_hookup_day_status  (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_iflw_day_status         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_pwel_day_status         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_iwel_day_status         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_psep_day_status         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_eqpm_day_status         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_tank_measurement        (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_chem_tank_period_status (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_wbi_day_status          (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_pipe_day_status         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_object_item_comment     (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_daily_deferment_summary (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_iwel_mth_status         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_initiate_day	   		(p_daytime DATE, p_to_daytime DATE DEFAULT NULL);
PROCEDURE i_strm_day_pc_cpy         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_strm_mth_pc_cpy         (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_strm_day_pc_cp          (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_strm_mth_pc_cp          (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_object_item_mth_comment (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_chem_inj_point_status   (p_daytime DATE, p_local_lock VARCHAR2);
PROCEDURE i_strm_day_asset_data     (p_daytime DATE);
PROCEDURE i_defer_loss_accounting   (p_daytime DATE);
PROCEDURE i_defer_loss_acc_fcty     (p_daytime DATE);

END;