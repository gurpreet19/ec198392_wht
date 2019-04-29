create or replace 
PACKAGE ue_bs_instantiate IS
/******************************************************************************
** Package        :  ue_bs_instantiate, header part
**
** $Revision: 1.2 $
**
** Purpose        :  User-exit package for instantiation purposes
**
** Documentation  :  www.energy-components.com
**
** Created        : 18.07.2006
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 18.07.2006	SSK  initial version (TI 3948)
** 20.08.2013  KUMARSUR ECPD-24470: Added procedure new_month.
********************************************************************/

PROCEDURE new_day_end               (p_daytime DATE, p_to_daytime DATE DEFAULT NULL);

PROCEDURE new_month					(p_daytime DATE, p_local_lock VARCHAR2);

END ue_bs_instantiate;
/

create or replace 
PACKAGE BODY ue_bs_instantiate IS
/******************************************************************************
** Package        :  ue_bs_instantiate, body part
**
** $Revision: 1.2 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created        :  18.07.2006
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- -----------------------------------------------------------------------------------------------
** 18.07.2006	SSK  initial version (TI 3948)
** 20.08.2013  KUMARSUR ECPD-24470: Added procedure new_month().
  ** 01.03.2012  BERK Inserted logic to instantiate daily equipment records into equipment event BF
  ** 08.07.2012  RYGX Added Instantiate logic to carry forward the "Source" from the previous day to aid in
  **                  calculation of gas, cond and water theoretical rates.
  ** 06.09.2012 RYGX  Added the cfwd_sdgvc_run_hours procedure to carry
  **                  forward the run hours for the stream day gas volume
  **                  calculation business function.
  ** 28.10.2013 tlxt  Added the init_ventflare to intitialize the vent and flare
  ** 05.07.2015 ulse  Added daily instantiation value for carry forward - Daily Gas Stream Profit Centre Status
  ** 12.JUL-2017 koij Call ue_ct_bs_instantiate.init_strm_day_stream_meas to initialize SW_PL_DEHY_GAIN_LOSS to zero
********************************************************************/

 PROCEDURE new_day_end(p_daytime    DATE,
                          p_to_daytime DATE DEFAULT NULL)
   --</EC-DOC>
   IS
  CURSOR c_daytime
        IS
           SELECT daytime
             FROM system_days
            WHERE daytime BETWEEN p_daytime
                              AND NVL (p_to_daytime,
                                       TRUNC (ecdp_date_time.getcurrentsysdate, 'DD' )
                                      );
  
        ld_day          DATE;
        ld_end_date     DATE;
        lr_system_day   system_days%ROWTYPE;
     BEGIN
  -- Lock check
        IF ecdp_month_lock.withinlockedmonth (p_daytime) IS NOT NULL
        THEN
           ecdp_month_lock.raisevalidationerror
              ('INSERTING',
               p_daytime,
               p_daytime,
               TRUNC (p_daytime, 'MONTH'),
               'ec_bs_instantiate.new_day_end: Can not instantiate in a locked month'
              );
        END IF;
  
        -- exclude future dates
        IF p_daytime <= TRUNC (ecdp_date_time.getcurrentsysdate, 'DD')
        THEN
           -- make sure all rows are present in system_days
           IF (p_to_daytime IS NULL OR p_to_daytime < p_daytime)
           THEN
              ld_end_date := p_daytime;
           ELSE
              ld_end_date := p_to_daytime;
           END IF;
  
           FOR mycur IN c_daytime
           LOOP
            --Release 3 deployment
              ue_ct_bs_instantiate.i_eqpm_event (mycur.daytime);
              ue_ct_bs_instantiate.cfwd_pwds_source (mycur.daytime);
              --ue_ct_bs_instantiate.cfwd_sdgvc_run_hours (mycur.daytime);
        -- ue_ct_bs_instantiate.cfwd_venflare(mycur.daytime); -- tlxt: 23-aug-2016: commented off and this logic has been grought to UE_CT_BS_INSTANTIATE.new_day_start
        --ue_ct_bs_instantiate.cfwd_sdsmg_mass(mycur.daytime);
        --Release 4 deployment
              --ue_ct_bs_instantiate.cfwd_vessel_comments (mycur.daytime);
            --Carry forward Stream Component Split Daily by Profit Centre
              ue_ct_bs_instantiate.cfwd_day_component_split(mycur.daytime);
              ue_ct_bs_instantiate.i_strm_day_pc_status_gas(mycur.daytime);
              ue_ct_bs_instantiate.cfwd_strm_day_pc_status_gas(mycur.daytime);
        ue_ct_bs_instantiate.cfwd_tdds(mycur.daytime);
          ue_ct_bs_instantiate.init_strm_day_stream_meas(mycur.daytime);
           END LOOP;
        END IF;
  
  END new_day_end;   

PROCEDURE new_month(p_daytime DATE, p_local_lock VARCHAR2)
 --</EC-DOC>
IS

BEGIN

NULL;

END new_month;

END ue_bs_instantiate;
/