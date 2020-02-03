CREATE OR REPLACE PACKAGE ue_ct_trigger_action IS
  /****************************************************************
  ** Package        :  Ue_CT_Trigger_Action
  **
  ** $Revision: 1.1.2.1 $
  **
  ** Purpose        :
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created  : 29.10.2008  Geir Olav Hagen
  **
  ** Modification history:
  **
  ** Date       Whom             Change description:
  ** ------     --------         -------------------------------------
  ** July2009   M Berkstresser   Added fuctions for Single Sign-on
  ** 11/09/2012 RYGX             Added functions for C5_C9 component analysis
  ** Q4 2013    SWGN             Added import functions for PIMS interface
  ** 06/02/2014 SWGN             Added logic to hook up domgas contracts to their messages
  ** 26/05/2014 UDFD             Added logic to calculate stream adjustments
  ** 25/11/2014 udfd             Added logic to import well analysis
  ** 17/12/2014 EQYP             Added UpdateValidNominationFlag TFS WI 92748
  ** 03/06/2016 KOIJ             Added function to check Out Of Service Flag for Dry/Wet Flares
  ** 19/04/2018 gedv             Item 127684: ISWR02316: Added procedure  cfwd_tdds to calculate tank density based on current streams and day-1 tank.
  ** 16/04/2017 KAWF             Item 127455: ISWR02297: Added procedure auCargoTransport()
  *****************************************************************/
  -- should be added for proper ventflare handling
    PROCEDURE calc_musp_ventflare (
        p_object_id   IN   stream.object_id%TYPE,
        p_daytime     IN   DATE
    );

    FUNCTION populatepassword RETURN VARCHAR2;

    FUNCTION setpasswordexpiry RETURN VARCHAR2;

    PROCEDURE genericscheduledaction (
        p_action_name      VARCHAR2,
        p_parameter_1      VARCHAR2,
        p_parameter_2      VARCHAR2,
        p_date_parameter   DATE
    );

    PROCEDURE createassociatedcalcsample (
        p_analysis_no NUMBER
    );

    PROCEDURE synchronizecalcsample (
        p_gc_analysis_no     NUMBER,
        p_calc_analysis_no   NUMBER,
        p_spot_analysis_no   NUMBER,
        p_component_no       VARCHAR2 DEFAULT NULL
    );

    PROCEDURE handlegcsampledelete (
        p_gc_sample_no NUMBER
    );

    PROCEDURE handlespotsampledelete (
        p_spot_sample_date   DATE,
        p_object_id          VARCHAR2,
        p_spot_sample_no     NUMBER
    );

    PROCEDURE cleanstagedanalysis (
        p_stage_sample_number NUMBER
    );

    PROCEDURE importstagedanalysis (
        p_stage_sample_number NUMBER
    );

    FUNCTION getanalysis_no RETURN VARCHAR2;

    PROCEDURE importstagedflare (
        p_object_id   VARCHAR2,
        p_daytime     DATE
    );

    PROCEDURE importstagedwellanalysis (
        p_stage_sample_number NUMBER
    );
  -- disabled for testing purposes
  --PROCEDURE SynchronizeCntrMsgDistr(p_contract_id VARCHAR2);

    PROCEDURE calcadjmass (
        p_object_id          IN   stream.object_id%TYPE,
        p_daytime            IN   DATE,
        p_profit_centre_id   VARCHAR2 DEFAULT NULL,
        p_corr_method        VARCHAR2,
        p_corr_factor        NUMBER
    );

    PROCEDURE resetnomvalidflag (
        p_parcel_number   NUMBER,
        p_forecast_id     VARCHAR2
    );

    PROCEDURE resetallnomvalidflags (
        p_forecast_id VARCHAR2
    );

    PROCEDURE checkebocdemurragestatus (
        p_cargo_id NUMBER
    );

    PROCEDURE synccargoanalcomp (
        p_analysis_no NUMBER
    );

    PROCEDURE checkoosflag (
        p_daytime DATE
    );
  --Item 127684: Begin

    PROCEDURE cfwd_tdds (
        p_daytime     DATE,
        p_object_id   VARCHAR2
    );
  --Item 127684: End
  --Item 127455

    PROCEDURE aucargotransport (
        p_cargo_no           NUMBER,
        p_old_cargo_status   VARCHAR2,
        p_new_cargo_status   VARCHAR2,
        p_user               VARCHAR2 DEFAULT NULL
    );

END ue_ct_trigger_action;
/
CREATE OR REPLACE PACKAGE BODY ue_ct_trigger_action IS
  /****************************************************************
  ** Package        :  Ue_CT_Trigger_Action
  **
  ** $Revision: 1.1.2.1 $
  **
  ** Purpose        :
  **
  ** Documentation  :  www.energy-components.com
  **
  ** Created  : 29.10.2008  Geir Olav Hagen
  **
  ** Modification history:
  **
  ** Date       Whom             Change description:
  ** ------     --------         --------------------------------------
  ** July2009   M Berkstresser   Added fuctions for Single Sign-on
  ** 11/09/2012 RYGX             Added functions for C5_C9 component analysis
  ** 24/04/2014 udfd             Added MoltoWt procedure, changed CleanNormalize
  ** 26/05/2014 udfd             Added CalcAdjMass procedure
  ** 25/11/2014 udfd             Added ImportStagedWellAnalysis, changes to ImportStagedAnalysis, GenericScheduledAction
  ** 17/12/2014 EQYP             Added UpdateValidNominationFlag TFS WI 92748
  ** 21/05/2015 udfd             Changed ImportStagedAnalysis, SyncronizeCalcSample (use mol_pct to prorate C5-C9)
  ** 16/07/2015 udfd             Changed ImportStagedAnalysis to Calculate C3+, C4+, C5+ during LNG Cargo analysis import
  ** 03/06/2016 KOIJ             Added function to check Out Of Service Flag for Dry/Wet Flares
  ** 03/22/2017 cvmk             Item 113805 - Modified ImportStagedAnalysis()
  ** 29/11/2017 kawf             Item 125197 - Modified ImportStagedAnalysis() to add second Online GC
  ** 22/01/2018 gedv             ISWR02315: Added a line of code to auto reject comp analysis where normalised components do not add up to 100%
  ** 24/01/2018 gedv             ISWR02333: Added logic to avoid updating of already existing stream comp analysis and stop new inserts for a locked month.
  ** 20/03/2018 gedv             Item 127684: ISWR02329: Added conditions in importStagedAnalysis to update the Cargo Analysis Overwriting Mechanism
  ** 19/04/2018 gedv             Item 127684: ISWR02316: Added procedure  cfwd_tdds to calculate tank density based on current streams and day-1 tank.
  ** 16/04/2017 kawf             Item 127455: ISWR02297: Added procedure auCargoTransport()
  ** 17/05/2018 gedv      Item 127925: ISWR02513: Req 2. Added condition to not process any stream analysis with analysis date less than current day - 15 days.
  ** 17/05/2018 gedv      Item 127925: ISWR02513: Req 3. Corrected thrown during update of Stream analysis from GC or Lab.
  ** 25/05/2018 gedv             Item 127926: INC000016821440: Correct conditions that trigger sync calc to avoid data overwriting.
  ** 07/08/2018 gedv      Item 128873: INC000017771458: Mapping for bsw_wt is updated to be mapped to bs_w from staging.
  ** 03/10/2018 gedv             Item 129523: ISWR02796: To avoid Unwarranted updates of Vent and Flare Events.
  ** 03/10/2018 gedv             Item 129523: ISWR02795: Disable Updates to User-Defined Calculated Analysis
  ** 08/04/2018 wvic             Item 131809: ISWR02715: Added more EXCEPTION WHEN OTHERS in GenericScheduledAction to handle errors.
  ** 16/09/2019 rjfv      Item 133157: ADO649171: Removed NVL for HG where it defaults the value to zero when it’s NULL.
  *****************************************************************/

    p_global_analysis_no   VARCHAR2(30);
    gb_err_test            BOOLEAN := false; --Item 131809: Added a global variable to help mimic exceptions in PL/SQL procedures
  --<EC-DOC>
  -----------------------------------------------------------------------------------------------------
  -- Function       : PopulatePassord                                                               --
  -- Description    :
  -- Preconditions  :
  -- Postconditions :                                                                                --
  --                                                                                                 --
  -- Using tables   : t_basis_user
  --                                                                                                 --
  -- Using functions:
  --
  --                                                                                                 --
  -- Configuration                                                                                   --
  -- required       :                                                                                --
  --                                                                                                 --
  -- Behaviour      :  Used in Single Sign-on configuration                                          --
  --                                                                                                 --
  -----------------------------------------------------------------------------------------------------
    FUNCTION populatepassword
    --</EC-DOC>

     RETURN VARCHAR2 IS
    BEGIN
    /*  EC does not encrypt or use a password that is exactly 32 characters long            */
    /*  So by storing a password of exactly this lenght it forces the use of Single Sign-on */
        RETURN 'Use Active Directory Authenicati';
    END populatepassword;

    FUNCTION setpasswordexpiry
    --</EC-DOC>
    -----------------------------------------------------------------------------------------------------
    -- Function       : SetPasswordExpiry                                                              --
    -- Description    :
    -- Preconditions  :
    -- Postconditions :                                                                                --
    --                                                                                                 --
    -- Using tables   : t_basis_user
    --                                                                                                 --
    -- Using functions:
    --
    --                                                                                                 --
    -- Configuration                                                                           --
    -- required       :                                                                                --
    --                                                                                                 --
    -- Behaviour      :  Used in Single Sign-on configuration                                         --
    --                                                                                                 --
    -----------------------------------------------------------------------------------------------------

     RETURN VARCHAR2 IS
    BEGIN
    /*  This sets the password expiry way into the future so it does not conflict with Single Sign-on          */
    /*  There is a bug in EC with the T_BASIS_USER class with the password_expiry_date being defined as STRING */
    /*   So this funtion must be VARCHARS                                                                      */
        RETURN '31-Dec-2099';
    END setpasswordexpiry;

    PROCEDURE calc_musp_ventflare (
        p_object_id   stream.object_id%TYPE,
        p_daytime     DATE
    )
    --</EC-DOC>
     IS

        v_mus_flare_stream_id      VARCHAR2(32) := ecdp_objects.getobjidfromcode('STREAM', 'SW_PL_T0_MSEP_FLARE');
        v_wi_mus_flare_stream_id   VARCHAR2(32) := ecdp_objects.getobjidfromcode('STREAM', 'SW_PL_WST_MSEP_FLARE');
        v_jb_mus_flare_stream_id   VARCHAR2(32) := ecdp_objects.getobjidfromcode('STREAM', 'SW_PL_WA356P_MSEP_FLARE');
        n_wi_mus_flare_mass        NUMBER;
        n_jb_mus_flare_mass        NUMBER;
    BEGIN
        IF ( p_object_id = v_mus_flare_stream_id ) THEN
            n_wi_mus_flare_mass := ecbp_stream_fluid.findgrsstdmass(v_wi_mus_flare_stream_id, p_daytime);
            n_jb_mus_flare_mass := ecbp_stream_fluid.findgrsstdmass(v_jb_mus_flare_stream_id, p_daytime);
            UPDATE strm_day_stream
            SET
                grs_mass = n_wi_mus_flare_mass
            WHERE
                object_id = v_wi_mus_flare_stream_id
                AND daytime = p_daytime;

            UPDATE strm_day_stream
            SET
                grs_mass = n_jb_mus_flare_mass
            WHERE
                object_id = v_jb_mus_flare_stream_id
                AND daytime = p_daytime;

        END IF;
    END calc_musp_ventflare;



    PROCEDURE updatestatusautonomous (
        p_table_name    VARCHAR2,
        p_from_status   VARCHAR2,
        p_to_status     VARCHAR2,
        p_and_other     VARCHAR2 DEFAULT NULL
    ) IS
        PRAGMA autonomous_transaction;
        v_sql_string VARCHAR2(20000) := '';
    BEGIN
        v_sql_string := 'UPDATE '
                        || p_table_name
                        || ' SET record_status = '''
                        || p_to_status
                        || ''' WHERE record_status = '''
                        || p_from_status
                        || ''' AND '
                        || nvl(p_and_other, '1 = 1');
    --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_TRIGGER_ACTION','v_sql_string='||v_sql_string);

        EXECUTE IMMEDIATE v_sql_string;
        COMMIT;
    END updatestatusautonomous; -- ue_ct_trigger_action

    PROCEDURE genericscheduledaction (
        p_action_name      VARCHAR2,
        p_parameter_1      VARCHAR2,
        p_parameter_2      VARCHAR2,
        p_date_parameter   DATE
    ) IS

        CURSOR staging_analysis IS
        SELECT
            class_name,
            stage_comp_analysis_no
        FROM
            ct_stage_comp_analysis
        WHERE
            record_status = 'V';

        CURSOR staging_flare IS
        SELECT
            object_id,
            daytime
        FROM
            ct_stage_stream_event
        WHERE
            record_status = 'V'
        ORDER BY
            daytime;

        CURSOR flare_parent (
            cp_child_obj_id VARCHAR2
        ) IS
        SELECT
            object_id,
            child_obj_id
        FROM
            object_group_conn
        WHERE
            parent_group_type = 'VF_NR'
            AND child_obj_id = cp_child_obj_id;

        CURSOR staging_well_analysis IS
        SELECT
            stage_comp_analysis_no
        FROM
            ct_stage_well_analysis
        WHERE
            record_status = 'V';

        v_error_string    VARCHAR2(20000) := NULL;
        lv_error_string   VARCHAR2(20000) := NULL;
        v_error_cursor    VARCHAR2(2000) := NULL; -- Item 131809: Add place holder for marker
        v_count           NUMBER := 0;
    BEGIN
    -- TLXT: 11-MAY-2016
        IF ( p_action_name = 'AGGREGATE_SUBDAILY' ) THEN
            ecbp_stream_subdaily.aggregatesubdaily(trunc(ecdp_date_time.getcurrentsysdate - 1), ecdp_objects.getobjidfromcode('STREAM'
            , 'SW_GP_DG_SALES'), 'STRM_SUB_DAY_STATUS_GAS', 'STRM_DAY_STREAM_MEAS_GAS', 'ON_STREAM', '/com.ec.prod.po.screens/sub_daily_gas_stream_status/summarizeStrmSubToDailyButtonID'
            );
        END IF;

        IF ( p_action_name = 'ECIS_STAGING' ) THEN
      --COMP STAGING
            updatestatusautonomous('ct_stage_comp_analysis', 'P', 'V'); -- First, set all provisional records to verified
      --UPDATE ct_stage_comp_analysis SET record_status = 'V' WHERE record_status = 'P';
            v_error_cursor := 'Error at cursor staging_analysis: '; -- Item 131809
            FOR item IN staging_analysis LOOP BEGIN
                IF item.class_name = 'CT_STAGE_COMP_ANALYSIS' THEN
                    importstagedanalysis(item.stage_comp_analysis_no);
                ELSIF item.class_name = 'CT_STAGE_COMP_ANALY_TXT' THEN
                    cleanstagedanalysis(item.stage_comp_analysis_no);
                    importstagedanalysis(item.stage_comp_analysis_no);
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
          -- Item 131809 Begin
                    lv_error_string := substr(lv_error_string
                                              || chr(13)
                                              || chr(10)
                                              || v_error_cursor
                                              || replace(sqlerrm, 'ORA-20101:', NULL), 1, 20000);

                    CONTINUE; -- this is so that it continues with the next record
          -- Item 131809 End
            END;
            END LOOP;
      -- Item 131809 Begin

            IF length(lv_error_string) > 0 AND instr(lv_error_string, v_error_cursor) > 0 THEN
                v_error_string := substr(v_error_cursor
                                         || replace(lv_error_string, v_error_cursor, NULL), 1, 20000);

                lv_error_string := NULL;
            END IF;
      -- Item 131809 End

            updatestatusautonomous('ct_stage_comp_analysis', 'V', 'A'); -- Now that we're done, set all verified records to approved
      --COMP STAGING
      --FLARE STAGING
      --UPDATE ct_stage_comp_analysis SET record_status = 'A' WHERE record_status = 'V';
            updatestatusautonomous('ct_stage_stream_event', 'P', 'V', 'daytime <= trunc(sysdate)'); -- First, set all provisional records to verified
      --UPDATE ct_stage_stream_event SET record_status = 'V' WHERE record_status = 'P';
            v_error_cursor := 'Error at cursor staging_flare: '; -- Item 131809
            FOR item IN staging_flare LOOP BEGIN
                importstagedflare(item.object_id, item.daytime);
            EXCEPTION
                WHEN OTHERS THEN
          -- Item 131809 Begin
                    lv_error_string := substr(lv_error_string
                                              || chr(13)
                                              || chr(10)
                                              || v_error_cursor
                                              || replace(sqlerrm, 'ORA-20101:', NULL), 1, 20000);

                    CONTINUE; -- this is so that it continues with the next record
          -- Item 131809 End
            END;
            END LOOP;

            FOR staging_item IN staging_flare LOOP
        --Trigger the "Save and Update Button"

             FOR flaring IN flare_parent(staging_item.object_id) LOOP
                BEGIN
                    ecbp_stream_ventflare.calcgrsvolmass(flaring.object_id, trunc(staging_item.daytime, 'DD'), ecdp_context.getappuser
                    ());

                EXCEPTION
                    WHEN OTHERS THEN
            -- Item 131809 Begin
                        lv_error_string := substr(lv_error_string
                                                  || chr(13)
                                                  || chr(10)
                                                  || v_error_cursor
                                                  || replace(sqlerrm, 'ORA-20101:', NULL), 1, 20000);

                        CONTINUE; -- this is so that it continues with the next record
            -- Item 131809 End
                END;
            END LOOP;
            END LOOP;
      -- Item 131809 Begin

            IF length(lv_error_string) > 0 AND instr(lv_error_string, v_error_cursor) > 0 THEN
                v_error_string := substr(v_error_string
                                         ||(
                    CASE
                        WHEN length(v_error_string) > 0 THEN
                            chr(13)
                            || chr(10)
                    END
                )
                                         || v_error_cursor
                                         || replace(lv_error_string, v_error_cursor, NULL), 1, 20000);

                lv_error_string := NULL;
            END IF;
      -- Item 131809 End

            updatestatusautonomous('ct_stage_stream_event', 'V', 'A', 'text_1 = ''Y'''); -- Now that we're done, set all verified records to approved
      --UPDATE ct_stage_stream_event SET record_status = 'A' WHERE record_status = 'V' AND text_1 = 'Y';
      --FLARE STAGING
      --WELL STAGING
            updatestatusautonomous('ct_stage_well_analysis', 'P', 'V');
      --UPDATE ct_stage_well_analysis SET record_status = 'V' WHERE record_status = 'P';
            v_error_cursor := 'Error at cursor staging_well_analysis: '; -- Item 131809
            FOR item IN staging_well_analysis LOOP
        --Item 131809: ISWR02715 Begin
             BEGIN
                importstagedwellanalysis(item.stage_comp_analysis_no);
            EXCEPTION
                WHEN OTHERS THEN
          -- Item 131809 Begin
                    lv_error_string := substr(lv_error_string
                                              || chr(13)
                                              || chr(10)
                                              || v_error_cursor
                                              || replace(sqlerrm, 'ORA-20101:', NULL), 1, 20000);

                    CONTINUE; -- this is so that it continues with the next record
          -- Item 131809 End
            END;
            END LOOP;
      -- Item 131809 Begin

            IF length(lv_error_string) > 0 AND instr(lv_error_string, v_error_cursor) > 0 THEN
                v_error_string := substr(v_error_string
                                         ||(
                    CASE
                        WHEN length(v_error_string) > 0 THEN
                            chr(13)
                            || chr(10)
                    END
                )
                                         || v_error_cursor
                                         || replace(lv_error_string, v_error_cursor, NULL), 1, 20000);

                lv_error_string := NULL;
            END IF;
      -- Item 131809 End

            updatestatusautonomous('ct_stage_well_analysis', 'V', 'A');
      --UPDATE ct_stage_well_analysis SET record_status = 'A' WHERE record_status = 'V';
      --WELL STAGING
        END IF;
    -- If any of the records failed we raise an error. But because each procedure is an autonomous transaction, successful loads still hapepend

        v_error_string := replace(v_error_string, 'ORA-0000: normal, successful completion', NULL);
        IF length(v_error_string) > 0 THEN
            raise_application_error(-20101, v_error_string);
        END IF;

    END genericscheduledaction;

    PROCEDURE cleannormalize (
        p_analysis_no NUMBER
    ) IS
        v_wt_factor    NUMBER;
        v_mol_factor   NUMBER;
        sum_wt_pct     NUMBER;
        sum_mol_pct    NUMBER;
        lv_sql         VARCHAR2(4000);
    BEGIN
    -- changed by UDFD, original script:
    /* SELECT SUM(wt_pct) / 100, SUM(mol_pct) / 100 INTO v_wt_factor, v_mol_factor
    FROM FLUID_ANALYSIS_COMPONENT
    WHERE analysis_no = p_analysis_no; */
        SELECT
            SUM(wt_pct)
        INTO sum_wt_pct
        FROM
            fluid_analysis_component
        WHERE
            analysis_no = p_analysis_no;

        IF ( nvl(sum_wt_pct, 0) <> 0 AND sum_wt_pct <> 100 ) THEN
            SELECT
                100 / SUM(wt_pct)
            INTO v_wt_factor
            FROM
                fluid_analysis_component
            WHERE
                analysis_no = p_analysis_no;

            UPDATE fluid_analysis_component
            SET
                wt_pct = wt_pct * v_wt_factor
            WHERE
                analysis_no = p_analysis_no;

        END IF;

        SELECT
            SUM(mol_pct)
        INTO sum_mol_pct
        FROM
            fluid_analysis_component
        WHERE
            analysis_no = p_analysis_no;

        IF ( nvl(sum_mol_pct, 0) <> 0 AND sum_mol_pct <> 100 ) THEN
            SELECT
                100 / SUM(mol_pct)
            INTO v_mol_factor
            FROM
                fluid_analysis_component
            WHERE
                analysis_no = p_analysis_no;

            UPDATE fluid_analysis_component
            SET
                mol_pct = mol_pct * v_mol_factor
            WHERE
                analysis_no = p_analysis_no;

        END IF;

    END cleannormalize;

    PROCEDURE moltowt (
        p_analysis_no NUMBER
    ) IS

        CURSOR components_in_analysis (
            cp_analysis_no NUMBER
        ) IS
        SELECT
            *
        FROM
            fluid_analysis_component
        WHERE
            analysis_no = cp_analysis_no;

        ln_tot_mass_frac         NUMBER := 0;
        ln_count_blank_mol       NUMBER := 0;
    BEGIN
        FOR comp_item IN components_in_analysis(p_analysis_no) LOOP IF comp_item.mol_pct IS NULL THEN
            ln_count_blank_mol := ln_count_blank_mol + 1;
        END IF;
        END LOOP;

        ln_tot_mass_frac := ecbp_comp_analysis.calctotmassfrac(p_analysis_no);
        FOR comp_rec IN components_in_analysis(p_analysis_no) LOOP IF ln_count_blank_mol = 0 THEN
                IF ln_tot_mass_frac > 0 THEN
                    UPDATE fluid_analysis_component
                    SET
                    wt_pct = 100 * ( ecbp_comp_analysis.calccompmassfrac(ec_object_fluid_analysis.object_id(p_analysis_no), ec_object_fluid_analysis
                    .daytime(p_analysis_no), comp_rec.component_no, ec_object_fluid_analysis.analysis_type(p_analysis_no), ec_object_fluid_analysis
                    .sampling_method(p_analysis_no),
                                                                         comp_rec.mol_pct) / ln_tot_mass_frac )
                    WHERE
                        analysis_no = p_analysis_no
                        AND component_no = comp_rec.component_no;

                END IF;

            END IF;

        END LOOP; -- component

    END moltowt;
-- added by UDFD

    PROCEDURE createassociatedcalcsample (
        p_analysis_no NUMBER
    ) IS

        v_new_analysis_no NUMBER;
        CURSOR analysis_samples IS
        SELECT
            *
        FROM
            dv_strm_analysis
        WHERE
            analysis_no = p_analysis_no
            AND NOT EXISTS (
                SELECT
                    1
                FROM
                    dv_strm_analysis x
                WHERE
                    x.sampling_method = 'CALC_COMP'
                    AND x.gc_analysis_no = p_analysis_no
            );

    BEGIN
        FOR item IN analysis_samples LOOP
      -- Double check to ensure that this is a GC sample
            IF item.sampling_method <> 'GC' OR item.analysis_type NOT IN (
                'STRM_LNG_COMP',
                'STRM_OIL_COMP',
                'STRM_GAS_COMP'
            ) THEN
                return;
            END IF;
      -- Create a new sample

            ecdp_system_key.assignnextnumber('OBJECT_FLUID_ANALYSIS', v_new_analysis_no);
      --Insert the appropriate calculated record
            INSERT INTO dv_strm_analysis (
                analysis_no,
                object_id,
                daytime,
                analysis_type,
                sampling_method,
                phase,
                valid_from_date,
                analysis_status,
                density,
                gc_analysis_no
            ) VALUES (
                v_new_analysis_no,
                item.object_id,
                item.daytime,
                item.analysis_type,
                'CALC_COMP',
                item.phase,
                item.valid_from_date,
                'APPROVED',
                item.density,
                p_analysis_no
            );
      --Create the comp analysis records in Fluid Analysis

            ecdp_fluid_analysis.createcompsetforanalysis(item.analysis_type, v_new_analysis_no, item.daytime);
      -- Link the two samples together by analysis no
            UPDATE dv_strm_analysis
            SET
                gc_analysis_no = v_new_analysis_no
            WHERE
                analysis_no = p_analysis_no;

        END LOOP;
    END createassociatedcalcsample;

    FUNCTION validatecalcsample (
        p_sample_no NUMBER
    ) RETURN VARCHAR2 IS

        CURSOR components_in_analysis (
            cp_comp_set_code VARCHAR2
        ) IS
        SELECT
            set_list.component_no
        FROM
            comp_set_list set_list
        WHERE
            set_list.component_set = cp_comp_set_code;

        v_return_value   VARCHAR2(1) := 'N';
        v_stream_id      VARCHAR2(32) := ec_object_fluid_analysis.object_id(p_sample_no);
        v_daytime        DATE := ec_object_fluid_analysis.daytime(p_sample_no);
    BEGIN
        IF v_stream_id IS NULL OR v_daytime IS NULL THEN
            RETURN v_return_value;
        END IF;
    -- 106940:  Don't validate if this sample is rejected, or if it is a spot sample that isn't accepted
        IF ec_object_fluid_analysis.analysis_status(p_sample_no) = 'REJECTED' OR ( ec_object_fluid_analysis.sampling_method(p_sample_no
        ) = 'SPOT' AND ec_object_fluid_analysis.analysis_status(p_sample_no) <> 'APPROVED' ) THEN
            RETURN v_return_value;
        END IF;

        FOR item IN components_in_analysis(ec_strm_version.comp_set_code(v_stream_id, v_daytime, '<=')) LOOP IF ec_fluid_analysis_component
        .wt_pct(p_sample_no, item.component_no) IS NULL THEN
        --ecdp_dynsql.writetemptext('COMP_ANALYSIS', 'NO GOOD: sample_no [' || p_sample_no || '], stream_code [' || ec_stream.object_code(ec_object_fluid_analysis.object_id(p_sample_no)) || '], set_list [' || ec_strm_version.comp_set_code(v_stream_id, v_daytime, '<=') || '], component_no [' || item.component_no || '], wt_pct [' || ec_fluid_analysis_component.wt_pct(p_sample_no, item.component_no) || ']');
            v_return_value := 'N';
            EXIT;
        ELSE
        --ecdp_dynsql.writetemptext('COMP_ANALYSIS', 'GOOD: sample_no [' || p_sample_no || '], stream_code [' || ec_stream.object_code(ec_object_fluid_analysis.object_id(p_sample_no)) || '], set_list [' || ec_strm_version.comp_set_code(v_stream_id, v_daytime, '<=') || '], component_no [' || item.component_no || '], wt_pct [' || ec_fluid_analysis_component.wt_pct(p_sample_no, item.component_no) || ']');
            v_return_value := 'Y';
        END IF;
        END LOOP;

        RETURN v_return_value;
    END validatecalcsample;

    PROCEDURE synchronizecalcsample (
        p_gc_analysis_no     NUMBER,
        p_calc_analysis_no   NUMBER,
        p_spot_analysis_no   NUMBER,
        p_component_no       VARCHAR2 DEFAULT NULL
    ) IS

        CURSOR all_spot_analyses IS
        SELECT
            analysis_no
        FROM
            dv_strm_analysis
        WHERE
            sampling_method = 'SPOT'
        ORDER BY
            daytime ASC;

        CURSOR single_analysis_info (
            cp_analysis_no NUMBER
        ) IS
        SELECT
            *
        FROM
            dv_strm_analysis
        WHERE
            analysis_no = cp_analysis_no;

        CURSOR gc_analysis_in_range (
            cp_from_date   DATE,
            cp_to_date     DATE,
            cp_object_id   VARCHAR2
        ) IS
        SELECT
            *
        FROM
            dv_strm_analysis
        WHERE
            valid_from_date >= cp_from_date
            AND valid_from_date < cp_to_date
            AND object_id = cp_object_id
            AND sampling_method = 'GC';

        CURSOR spot_analysis_prior (
            cp_gc_analysis_no NUMBER
        ) IS
        SELECT
            analysis_no
        FROM
            dv_strm_analysis
        WHERE
            valid_from_date <= ec_object_fluid_analysis.valid_from_date(cp_gc_analysis_no)
            AND sampling_method = 'SPOT'
            AND object_id = (
                SELECT
                    x.object_id
                FROM
                    dv_strm_analysis x
                WHERE
                    x.analysis_no = cp_gc_analysis_no
            )
            AND analysis_status = 'APPROVED' --106940 not able to reject an analysis
        ORDER BY
            valid_from_date DESC;

        CURSOR components_in_analysis (
            cp_analysis_no NUMBER
        ) IS
        SELECT
            *
        FROM
            fluid_analysis_component
        WHERE
            analysis_no = cp_analysis_no
            AND component_no = nvl(p_component_no, component_no)
        ORDER BY
            regexp_replace(component_no, '[A-Z\+]', '');

        v_next_spot_analysis_date   DATE;
        v_gc_analysis_no            NUMBER;
        v_calc_analysis_no          NUMBER;
        v_spot_analysis_no          NUMBER;
        v_density                   NUMBER;
        TYPE comp_factor_table IS
            TABLE OF NUMBER INDEX BY VARCHAR2(8);
        TYPE comp_value_table IS
            TABLE OF VARCHAR2(1) INDEX BY VARCHAR2(8);
        comp_factors                comp_factor_table;
        comp_values                 comp_value_table;
        v_c5up_total                NUMBER;
        v_gc_ic5                    NUMBER;
        v_final_component           VARCHAR2(8);
        v_temp                      NUMBER;
        v_found                     VARCHAR2(1) := 'N';
        v_count_users               NUMBER;
    BEGIN
  -- If these are all null, we re-evaluate the entire historical analytical set. Hey, you asked for it.
        IF p_gc_analysis_no IS NULL AND p_calc_analysis_no IS NULL AND p_spot_analysis_no IS NULL THEN
            FOR item IN all_spot_analyses LOOP
                synchronizecalcsample(NULL, NULL, item.analysis_no, p_component_no);
            END LOOP;
        END IF;
-- Set the internal variable references to the parameters

        v_gc_analysis_no := p_gc_analysis_no;
        v_calc_analysis_no := p_calc_analysis_no;
        v_spot_analysis_no := p_spot_analysis_no;
-- If gc XOR calc is null, set the other with an easy lookup
        IF v_calc_analysis_no IS NULL AND v_gc_analysis_no IS NOT NULL THEN
            v_calc_analysis_no := ec_object_fluid_analysis.text_1(v_gc_analysis_no);
        END IF;

        IF v_gc_analysis_no IS NULL AND v_calc_analysis_no IS NOT NULL THEN
            v_gc_analysis_no := ec_object_fluid_analysis.text_1(v_calc_analysis_no);
        END IF;
-- If spot is null and the others are not null, find the most recent spot analysis

        IF v_spot_analysis_no IS NULL AND v_calc_analysis_no IS NOT NULL AND v_gc_analysis_no IS NOT NULL THEN
            FOR item IN spot_analysis_prior(v_gc_analysis_no) LOOP
                v_spot_analysis_no := item.analysis_no;
                EXIT;
            END LOOP;
  -- 106940 not able to reject an analysis: If we couldn't find a spot analysis, then we give up. We set the spot analysis number to -1, which
  -- is a special flag that we'll look for later

            IF v_spot_analysis_no IS NULL THEN
                v_spot_analysis_no := -1;
            END IF;
        END IF;
-- If spot is not null and the others are null, this is a full sync until the next spot sample. Loop using recursion

        IF v_spot_analysis_no IS NOT NULL AND v_calc_analysis_no IS NULL AND v_gc_analysis_no IS NULL THEN
            FOR spot_item IN single_analysis_info(v_spot_analysis_no) LOOP
                SELECT
                    nvl(MIN(valid_from_date), sysdate + 2 * 365)
                INTO v_next_spot_analysis_date
                FROM
                    dv_strm_analysis
                WHERE
                    object_id = spot_item.object_id
                    AND valid_from_date > spot_item.valid_from_date
                    AND analysis_status = 'APPROVED'
                    AND sampling_method = 'SPOT'
                    AND analysis_no <> v_spot_analysis_no;
    -- Recursion! This will update each individual calc sample (see below - "if all three populated...")

                FOR update_item IN gc_analysis_in_range(spot_item.valid_from_date, v_next_spot_analysis_date, spot_item.object_id
                ) LOOP synchronizecalcsample(update_item.analysis_no, update_item.gc_analysis_no, v_spot_analysis_no, p_component_no
                );
                END LOOP;

            END LOOP;

            UPDATE dv_strm_analysis
            SET
                spot_analysis_no = v_spot_analysis_no,
                analysis_status =
                    CASE
                        WHEN analysis_status = 'REJECTED' THEN
                            'REJECTED'
                        ELSE
                            'APPROVED'
                    END --106940
            WHERE
                analysis_no IN (
                    v_calc_analysis_no
                );

            UPDATE dv_strm_analysis
            SET
                spot_analysis_no = v_spot_analysis_no,
                analysis_status =
                    CASE
                        WHEN nvl(analysis_status, 'N') = 'N' THEN
                            'APPROVED'
                        ELSE
                            analysis_status
                    END --if it is null, it means it is inserted from staging and it needs to be updated as approved
            WHERE
                analysis_no IN (
                    v_spot_analysis_no
                );

        END IF;
-- If all three populated, this is easy! Do a single update

        IF v_spot_analysis_no IS NOT NULL AND v_calc_analysis_no IS NOT NULL AND v_gc_analysis_no IS NOT NULL THEN
            IF v_spot_analysis_no = -1 THEN
    -- 106940: -1 is a flag indicating that there were no APPROVED spot analysis samples prior to loading this from the GC.
    -- This variable stores the heaviest component that had a non-zero value in the GC sample.
    -- By setting it to the heaviest possible component that this code can handle,
    -- the final loop in the algorithm will end up simply copying the GC sample into the CALC sample
                v_final_component := 'C9+';
            ELSE
    -- Only do this transformation if the spot and GC analysis have a full component set
    -- Otherwise do nothing
                IF validatecalcsample(v_spot_analysis_no) = 'N' OR validatecalcsample(v_gc_analysis_no) = 'N' THEN
                    ecdp_dynsql.writetemptext('SIOBI', 'VALIDATE FAILED, SPOT='
                                                       || validatecalcsample(v_spot_analysis_no)
                                                       || ', GC='
                                                       || validatecalcsample(v_gc_analysis_no));

                    return;
                END IF;

                IF nvl(p_component_no, 'C9+') IN (
                    'IC5',
                    'NC5',
                    'NC6',
                    'NC7',
                    'NC8',
                    'C9+'
                ) THEN
      -- Logic:
      -- 1) Find the last component in the C5-C9 list for the GC analysis that has a non-zero value.
      -- 2) Proportion that value across C5-C9 based on the proportions found in the related SPOT analysis
      -- WARNING: This assumes that the GC will not distinguish between IC5 and NC5 if it stops at C5
      -- and that the value will be put in the IC5 slot.
                    v_final_component := 'IC4';
                    FOR comp_item IN components_in_analysis(v_gc_analysis_no) LOOP
                        comp_values(comp_item.component_no) := 'N';
                        IF comp_item.component_no IN (
                            'IC5',
                            'NC5',
                            'NC6',
                            'NC7',
                            'NC8',
                            'C9+'
                        ) THEN
                            IF v_found = 'N' THEN
            --IF NVL(comp_item.wt_pct, 0) = 0 THEN
                                IF nvl(comp_item.mol_pct, 0) = 0 THEN
                                    v_found := 'Y';
                                    comp_values(comp_item.component_no) := 'Y';
                                ELSE
                                    comp_values(comp_item.component_no) := 'N';
                                    v_final_component := comp_item.component_no;
                                END IF;

                            ELSE
            --IF NVL(comp_item.wt_pct, 0) > 0 THEN
                                IF nvl(comp_item.mol_pct, 0) > 0 THEN
                                    v_found := 'N';
              -- Item 127925: ISWR02513: Begin
              --comp_values.delete();
                                    comp_values.DELETE(comp_item.component_no);
              /* REQ3*/
              -- Item 127925: ISWR02513: End
                                    v_final_component := comp_item.component_no;
                                    comp_values(comp_item.component_no) := 'N';
                                ELSE
                                    comp_values(comp_item.component_no) := 'Y';
                                END IF;
                            END IF;

                        END IF;

                    END LOOP;
      /* -- select * from dv_strm_comp_analysis where object_code = 'SG_COND_STAB_A'
      -- Handle the NC5 properly
      comp_values('NC5') := comp_values('IC5');
      IF v_final_component = 'IC5' THEN
      comp_values('NC5') := 'Y';
      END IF;  */
      -- Get the total of the values to proportion from the spot

                    IF v_final_component <> 'C9+' THEN
                        v_c5up_total := 0;
                        FOR comp_item IN components_in_analysis(v_spot_analysis_no) LOOP IF nvl(comp_values(comp_item.component_no
                        ), 'N') = 'Y' OR comp_item.component_no = v_final_component THEN
            --v_c5up_total := v_c5up_total + comp_item.wt_pct;
                            v_c5up_total := v_c5up_total + comp_item.mol_pct;
                        END IF;
                        END LOOP;

                        FOR comp_item IN components_in_analysis(v_spot_analysis_no) LOOP IF ( nvl(comp_values(comp_item.component_no
                        ), 'N') = 'Y' OR comp_item.component_no = v_final_component ) THEN
                            IF v_c5up_total = 0 THEN
                                comp_factors(comp_item.component_no) := 0;
                            ELSE
              --comp_factors(comp_item.component_no) := comp_item.wt_pct / v_c5up_total;
                                comp_factors(comp_item.component_no) := comp_item.mol_pct / v_c5up_total;
                            END IF;

                        ELSE
                            comp_factors(comp_item.component_no) := 1;
                        END IF;
                        END LOOP;
        -- Get the final component value from the GC
        --v_gc_ic5 := NVL(ec_fluid_analysis_component.wt_pct(v_gc_analysis_no, v_final_component), 0);

                        v_gc_ic5 := nvl(ec_fluid_analysis_component.mol_pct(v_gc_analysis_no, v_final_component), 0);
                    END IF;

                END IF;

            END IF;
  -- Update!
  -- Item 129523 ISWR02795: Starts...

            v_count_users := 0;
            SELECT
                COUNT(*)
            INTO v_count_users
            FROM
                (
                    SELECT
                        last_updated_by
                    FROM
                        fluid_analysis_component
                    WHERE
                        analysis_no = v_calc_analysis_no
                    UNION
                    SELECT
                        last_updated_by
                    FROM
                        dv_strm_analysis
                    WHERE
                        analysis_no = v_calc_analysis_no
                )
            WHERE
                last_updated_by NOT LIKE 'ENERGYX%';

            IF v_count_users = 0 THEN
    -- Item 129523  ISWR02795: Ends.
                FOR comp_item IN components_in_analysis(v_gc_analysis_no) LOOP
                    IF v_final_component <> 'C9+' AND ( nvl(comp_values(comp_item.component_no), 'N') = 'Y' OR comp_item.component_no
                    = v_final_component ) THEN
                        v_temp := v_gc_ic5 * comp_factors(comp_item.component_no);
                    ELSE
      --v_temp := comp_item.wt_pct;
                        v_temp := comp_item.mol_pct;
                    END IF;

                    UPDATE fluid_analysis_component
      --SET wt_pct = v_temp
                    SET
                        mol_pct = v_temp
                    WHERE
                        analysis_no = v_calc_analysis_no
                        AND component_no = comp_item.component_no;

                END LOOP;

                moltowt(v_calc_analysis_no);
                cleannormalize(v_calc_analysis_no);
                UPDATE dv_strm_analysis
                SET
                    spot_analysis_no = v_spot_analysis_no,
                    analysis_status = 'INFO'
                WHERE
                    analysis_no = v_gc_analysis_no;
  -- udfd: in GORGON DENSITY value in Calc sample is not updated according the new GC DENSITY

                SELECT
                    density
                INTO v_density
                FROM
                    dv_strm_analysis
                WHERE
                    analysis_no = v_gc_analysis_no;

                UPDATE dv_strm_analysis
                SET
                    density = v_density,
                    spot_analysis_no = v_spot_analysis_no,
                    analysis_status =
                        CASE
                            WHEN analysis_status = 'REJECTED' THEN
                                'REJECTED'
                            ELSE
                                'APPROVED'
                        END --106940:  If it's rejected, leave it rejected (but continue to update it)
                WHERE
                    analysis_no = v_calc_analysis_no;

            END IF;

        END IF;

    END synchronizecalcsample;

    PROCEDURE handlegcsampledelete (
        p_gc_sample_no NUMBER
    ) IS
        v_calc_sample_no NUMBER := ec_object_fluid_analysis.text_1(p_gc_sample_no);
    BEGIN
  --IF THE RECORD HAS BEEN DELETED, WE COULDNT FIND HTE RELAVANT CALC ANALYSIS_NO FROM THE DELETED GC
        IF v_calc_sample_no IS NULL THEN
            FOR analysis_item IN (
                SELECT
                    analysis_no
                FROM
                    object_fluid_analysis
                WHERE
                    text_1 = p_gc_sample_no
            ) LOOP
                DELETE FROM dv_strm_analysis
                WHERE
                    analysis_no = analysis_item.analysis_no;

                DELETE FROM fluid_analysis_component
                WHERE
                    analysis_no = analysis_item.analysis_no;

                DELETE FROM object_fluid_analysis
                WHERE
                    analysis_no = analysis_item.analysis_no;

            END LOOP;

        ELSE
            DELETE FROM dv_strm_analysis
            WHERE
                analysis_no = v_calc_sample_no;

            DELETE FROM fluid_analysis_component
            WHERE
                analysis_no = v_calc_sample_no;

            DELETE FROM object_fluid_analysis
            WHERE
                analysis_no = v_calc_sample_no;

        END IF;
    END handlegcsampledelete;

    PROCEDURE handlespotsampledelete (
        p_spot_sample_date   DATE,
        p_object_id          VARCHAR2,
        p_spot_sample_no     NUMBER
    ) IS

        CURSOR spot_analysis_prior IS
        SELECT
            analysis_no
        FROM
            dv_strm_analysis
        WHERE
            valid_from_date < p_spot_sample_date
            AND ( p_object_id IS NULL
                  OR p_object_id = object_id )
            AND sampling_method = 'SPOT'
            AND analysis_status = 'APPROVED'
        ORDER BY
            valid_from_date DESC;

        CURSOR gc_analysis_affected IS
        SELECT
            analysis_no
        FROM
            dv_strm_analysis
        WHERE
            spot_analysis_no = p_spot_sample_no
            AND sampling_method = 'GC'
        ORDER BY
            valid_from_date;

        v_analysis_no NUMBER;
    BEGIN
        FOR item IN spot_analysis_prior LOOP
            v_analysis_no := item.analysis_no;
            EXIT;
        END LOOP;
        IF v_analysis_no IS NOT NULL THEN
            synchronizecalcsample(NULL, NULL, v_analysis_no, NULL);
        ELSE
    -- IF THERE IS MORE SPOT SAMPLE, WE JUST NEED TO UPDATE THE CALC COMP AS PER GC
            FOR item IN gc_analysis_affected LOOP
                v_analysis_no := item.analysis_no;
                synchronizecalcsample(v_analysis_no, NULL, NULL, NULL);
            END LOOP;
        END IF;

    END handlespotsampledelete;

    PROCEDURE cleanstagedanalysis (
        p_stage_sample_number NUMBER
    ) IS

        PRAGMA autonomous_transaction;
        CURSOR attributes_to_clean IS
        SELECT
            attribute_name
        FROM
            class_attr_property_cnfg
        WHERE
            class_name = 'CT_STAGE_COMP_ANALY_TXT'
            AND property_code = 'DESCRIPTION'
            AND property_value = 'CONVERT';

        v_intermediate      VARCHAR2(256);
        v_first             VARCHAR2(256);
        v_second            VARCHAR2(256);
        v_third             VARCHAR2(256);
        v_cargo_ref         VARCHAR2(256);
        v_dummy_number      NUMBER;
        v_sql               VARCHAR2(2000);
        v_stream_id         VARCHAR2(32);
        v_sampling_method   VARCHAR2(256);
        v_phase             VARCHAR2(256);
        v_analysis_type     VARCHAR2(256);
    BEGIN
  -- Convert the attributes marked ready to convert
  -- Conversion pattern: SAMPLE_DATE,VALUE,CARGO_REF
        SELECT
            object_id
        INTO v_stream_id
        FROM
            dv_ct_stage_comp_analy_txt
        WHERE
            stage_comp_analysis_no = p_stage_sample_number;

        FOR attribute_item IN attributes_to_clean LOOP
            v_sql := 'SELECT '
                     || ec_class_attribute_cnfg.db_sql_syntax('CT_STAGE_COMP_ANALY_TXT', attribute_item.attribute_name)
                     || ' FROM ct_stage_comp_analysis WHERE STAGE_COMP_ANALYSIS_NO = '
                     || p_stage_sample_number;

            v_intermediate := '';
    --ecdp_dynsql.writetemptext('UE_CT_TRIGGER_ACTION', v_sql);
            v_intermediate := ecdp_dynsql.execute_singlerow_varchar2(v_sql);
            IF v_intermediate IS NOT NULL AND length(v_intermediate) > 0 THEN
                v_first := '';
                v_second := '';
                v_third := '';
      -- Get the first, second, and third values
                v_first := substr(v_intermediate, 1, instr(v_intermediate, '|') - 1);

                v_second := substr(v_intermediate, instr(v_intermediate, '|') + 1, instr(v_intermediate, '|', -1) - instr(v_intermediate
                , '|') - 1);

                v_third := substr(v_intermediate, instr(v_intermediate, '|', -1) + 1);
      -- The first becomes SAMPLE_DATE, the second becomes the new value, the third becomes CARGO_REF
      -- Note the PI Timestamp Format is expected to be MON DD YYYY HH:MIAM
      -- E.g., "Feb 17 2014  3:27PM" : MON DD YYYY HH:MIAM
      --date format changed to "DD-MON-YY HH24:MI:SS"

                v_sql := 'UPDATE ct_stage_comp_analysis SET ANALYSIS_DATE = TO_DATE('''
                         || v_first
                         || ''', ''DD-MON-YY HH24:MI:SS''), '
                         || 'TEXT_1 = '''
                         || v_third
                         || ''', '
                         || ec_class_attribute_cnfg.db_sql_syntax('CT_STAGE_COMP_ANALY_TXT', attribute_item.attribute_name)
                         || ' = '''
                         || v_second
                         || ''' WHERE '
                         || 'STAGE_COMP_ANALYSIS_NO = '
                         || p_stage_sample_number;
      --ecdp_dynsql.writetemptext('UE_CT_TRIGGER_ACTION', v_sql);

                ecdp_dynsql.execute_statement(v_sql);
                COMMIT;
            END IF;

        END LOOP;
  -- Set the last remaining values

        v_sampling_method := 'SPOT';
        v_phase := ec_strm_version.stream_phase(v_stream_id, sysdate, '<=');
        IF ( ec_stream.object_code(v_stream_id) IN (
            'SW_GP_LNG_CARGO',
            'SW_GP_COND_CARGO'
        ) ) THEN
            v_analysis_type := 'WST_LAB';
            v_sampling_method := 'CONT_SAMPLING';
        ELSIF ec_stream.object_code(v_stream_id) IN (
            'SW_GP_LNG_CARGO_LOC_GC',
            'SW_GP_LNG_CARGO_LOC_GC_B',
            'SW_GP_COND_CARGO_LOC_GC'
        ) THEN
            v_analysis_type := 'ONLINE_GC';
            v_sampling_method := 'CONT_SAMPLING';
        ELSIF v_phase = 'LNG' THEN
            v_analysis_type := 'STRM_LNG_COMP';
        ELSIF v_phase = 'GAS' THEN
            v_analysis_type := 'STRM_GAS_COMP';
        ELSE
            v_analysis_type := 'STRM_OIL_COMP';
        END IF;

        UPDATE ct_stage_comp_analysis
        SET
            analysis_type = v_analysis_type,
            sampling_method = v_sampling_method,
            phase = v_phase
        WHERE
            stage_comp_analysis_no = p_stage_sample_number;
  /*--Commented off by tlxt on 28-Apr-2015 (WorkItem: 97009)
  -- Once all of the data has been cleaned, run the import
  --UE_CT_TRIGGER_ACTION.ImportStagedAnalysis(p_stage_sample_number);
  */

        COMMIT;
    END cleanstagedanalysis;

    PROCEDURE importstagedanalysis (
        p_stage_sample_number NUMBER
    ) IS

        PRAGMA autonomous_transaction;
        CURSOR analysis_rows_group IS
        SELECT
            *
        FROM
            ct_stage_comp_analysis
        WHERE
            object_id = ec_ct_stage_comp_analysis.object_id(p_stage_sample_number)
            AND import_date BETWEEN ec_ct_stage_comp_analysis.import_date(p_stage_sample_number) - ( 5 / 24 / 60 / 60 ) AND ec_ct_stage_comp_analysis
            .import_date(p_stage_sample_number) + ( 5 / 24 / 60 / 60 );

        CURSOR analysis_rows IS
        SELECT
            *
        FROM
            ct_stage_comp_analysis
        WHERE
            stage_comp_analysis_no = p_stage_sample_number;

        CURSOR lookup_cargos (
            cp_cargo_ref VARCHAR2
        ) IS
        SELECT
            *
        FROM
            dv_cargo_info
        WHERE
            to_char(cargo_no) = cp_cargo_ref
            OR cargo_name = cp_cargo_ref;
  /* OR cargo_no IN
  (
  SELECT x.cargo_no
  FROM dv_storage_lift_nomination x
  WHERE x.reference_lifting_no = cp_cargo_ref
  );*/
  -- Assumption made here that valid_from_date is a valid key field (as opposed to daytime)

        CURSOR lookup_analyses (
            cp_object_id       VARCHAR2,
            cp_analysis_date   DATE
        ) IS
        SELECT
            analysis_no,
            sampling_method
        FROM
            dv_strm_analysis
        WHERE
            valid_from_date = cp_analysis_date
            AND object_id = cp_object_id
            AND sampling_method IN (
                'GC',
                'SPOT'
            );
  -- 125197: added sample_source filtering

        CURSOR existing_cargo_analysis (
            cp_cargo_no        NUMBER,
            cp_official_ind    VARCHAR2,
            cp_analysis_type   VARCHAR2,
            cp_sample_source   VARCHAR2 DEFAULT NULL
        ) IS
        SELECT
            analysis_no
        FROM
            dv_cargo_analysis
        WHERE
            cargo_no = cp_cargo_no
            AND ( nvl(official_ind, 'N') = nvl(cp_official_ind, 'N')
                  OR 'ALL' = cp_official_ind )
            AND nvl(analysis_type, 'XXX') = coalesce(cp_analysis_type, analysis_type, 'XXX')
            AND nvl(sample_source, 'XXX') = coalesce(cp_sample_source, sample_source, 'XXX');

        v_existing_analysis_no   NUMBER;
        v_existing_anlys_flag    NUMBER; -- added as part of ISWR02333
        v_cargo                  VARCHAR2(1) := 'N';
        v_default_rec_status     VARCHAR2(1) := 'V';
        v_temp_bl_date           DATE;
        v_total_components       NUMBER;
        v_propane_plus           NUMBER;
        v_butane_plus            NUMBER;
        v_pentane_plus           NUMBER;
        v_sample_source          VARCHAR2(20);
        p_response_text          VARCHAR2(30) := 'COND:' || p_stage_sample_number;
        p_response_code          NUMBER;
        p_parcel_no              NUMBER;
        p_lockind                VARCHAR2(1) := 'N';       -- added as part of ISWR02333
        lr_next_analysis         object_fluid_analysis%rowtype; -- added as part of ISWR02333
        v_parcel_count           NUMBER;                          -- Item 127684:ISWR02329
        v_total_comps            NUMBER;                          -- Item 127684:ISWR02329
        v_process_flag           VARCHAR2(1);                     -- Item 129926: INC000016821440
    BEGIN
        IF gb_err_test THEN -- Item 131809 error test
            raise_application_error(-20101, 'Test error at ImportStagedAnalysis for stage_sample_number['
                                            || to_char(p_stage_sample_number)
                                            || ']');
        END IF;

        FOR item IN analysis_rows LOOP
    -- Is this a cargo?
            FOR cargo_item IN lookup_cargos(item.text_1) LOOP
                v_cargo := 'Y';
      -- Item 127684:ISWR02329 :Begin
                SELECT
                    nvl(COUNT(run_no), 0)
                INTO v_parcel_count
                FROM
                    tv_calc_tran_to_log
                WHERE
                    exit_status = 'SUCCESS'
                    AND event_type = 'LOAD'
                    AND parcel_no IN (
                        SELECT
                            parcel_no
                        FROM
                            storage_lift_nomination
                        WHERE
                            cargo_no = cargo_item.cargo_no
                    );

                IF v_parcel_count = 0 THEN
        -- Item 127684:ISWR02329 :End
        -- We will assume that the cargo in question already has an analysis record created. This happens automatically when the
        -- cargo gets set to "Ready for Harbour"
                    IF ec_stream.object_code(item.object_id) = 'SW_GP_LNG_CARGO' OR ec_stream.object_code(item.object_id) = 'SW_GP_COND_CARGO'
                    THEN
                        FOR analy_item IN existing_cargo_analysis(cargo_item.cargo_no, 'Y', NULL) LOOP v_existing_analysis_no := analy_item
                        .analysis_no;
                        END LOOP;

                        IF v_existing_analysis_no IS NULL THEN
            -- If there is not an existing official analysis, we need to create one
                            raise_application_error(-20101, 'Error at ImportStagedAnalysis for stage_sample_number['
                                                            || to_char(p_stage_sample_number)
                                                            || ']:There is no existing official cargo analysis record for this particular cargo!'
                                                            );
                        END IF;
          -- Set the basic info
          --Item 113805: Begin
          --UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.text_10, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'H2S';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = item.text_10
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'H2S';
          --Item 113805: End

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = nvl(item.text_9, 0)
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'MERCAPTAN';
          --Item 113805: Begin
          --UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.text_8, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'SULFUR';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = item.text_8
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'SULFUR';
          --Item 113805: End
          --Item ADO649171: Begin

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = item.text_7
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'HG';
          --Item ADO649171: End
          -- udfd UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.text_6, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'SOLIDS';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = nvl(item.text_5, 0)
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'OXYGEN';
          --assuming we are receiving CO2 in ppm
          --Item 113805: Begin
          --UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.co2_mol, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'CO2';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = item.co2_mol
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'CO2';
          --Item 113805: End
          --Item 113805: Begin

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = item.text_11
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'H2S_UOP212';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = item.text_12
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'CO2_ISO';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = item.text_13
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'SULFUR_D6667';
          --Item 113805: End
          -- added by udfd - needed for Condensate Analysis

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = nvl(item.rvp, 0)
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'RVP';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = nvl(item.bs_w, 0)
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'BS_W';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = nvl(item.density, 0)
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'DENSITY';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = nvl(item.text_2, 0)
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'SALT';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = nvl(item.text_7, 0)
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'MERCURY';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = nvl(item.text_6, 0)
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'API';

                        UPDATE dv_cargo_analysis_basic
                        SET
                            analysis_value = nvl(item.text_8, 0)
                        WHERE
                            analysis_no = v_existing_analysis_no
                            AND nvl(analysis_value, 0) = 0
                            AND analysis_item_code = 'COND_SULFUR';
          -- removed by udfd - by request from the business
          --UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.text_4, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'MEG';
          --UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.text_3, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'METHANOL';
          --UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.text_5, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'OXYGEN';
          -- Set the component info

                        IF ec_cargo_analysis.analysis_type(v_existing_analysis_no) = 'WST_LAB' THEN -- Assume this means that the official record should receive data from the lab
            -- 125197 start
            -- Set the component info
            -- Item 127684:ISWR02329 :Begin: IF condition added to avoid divide by zero error.
                            v_total_comps := nvl(item.c1_mol, 0) + nvl(item.c2_mol, 0) + nvl(item.c3_mol, 0) + nvl(item.ic4_mol, 0
                            ) + nvl(item.nc4_mol, 0) + nvl(item.ic5_mol, 0) + nvl(item.nc5_mol, 0) + nvl(item.nc6_mol, 0) + nvl(item
                            .nc7_mol, 0) + nvl(item.nc8_mol, 0) + nvl(item.c9_plus_mol, 0);

                            IF v_total_comps > 0 THEN
                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c1_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c1_mol), 0)
                                WHERE
                                    analysis_item_code = 'C1'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c2_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c2_mol), 0)
                                WHERE
                                    analysis_item_code = 'C2'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c3_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c3_mol), 0)
                                WHERE
                                    analysis_item_code = 'C3'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.ic4_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.ic4_mol), 0)
                                WHERE
                                    analysis_item_code = 'IC4'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc4_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc4_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC4'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.ic5_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.ic5_mol), 0)
                                WHERE
                                    analysis_item_code = 'IC5'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc5_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc5_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC5'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc6_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc6_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC6'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc7_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc7_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC7'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc8_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc8_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC8'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c9_plus_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c9_plus_mol), 0)
                                WHERE
                                    analysis_item_code = 'C9+'
                                    AND analysis_no = v_existing_analysis_no;
              -- UPDATE dv_cargo_analysis_component SET analysis_value = 0, analysis_value_raw = NVL(round(to_number(item.co2_mol), 3), 0) WHERE analysis_item_code = 'CO2' AND analysis_no = v_existing_analysis_no;
              -- UPDATE dv_cargo_analysis_component SET analysis_value = 0, analysis_value_raw = NVL(round(to_number(item.o2_mol), 3), 0) WHERE analysis_item_code = 'O2' AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.n2_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.n2_mol), 0)
                                WHERE
                                    analysis_item_code = 'N2'
                                    AND analysis_no = v_existing_analysis_no;
              -- 125197 end
              -- Normalize components

                                SELECT
                                    SUM(nvl(analysis_value, 0))
                                INTO v_total_components
                                FROM
                                    dv_cargo_analysis_component
                                WHERE
                                    analysis_no = v_existing_analysis_no;

                                v_total_components := 100 / v_total_components;
                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = round(analysis_value * v_total_components, 2)
                                WHERE
                                    analysis_no = v_existing_analysis_no
                                    AND nvl(analysis_value, 0) > 0;

                                SELECT
                                    SUM(nvl(analysis_value, 0))
                                INTO v_total_components
                                FROM
                                    dv_cargo_analysis_component
                                WHERE
                                    analysis_no = v_existing_analysis_no;

                                v_total_components := 100 - v_total_components;
                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = analysis_value + v_total_components
                                WHERE
                                    analysis_no = v_existing_analysis_no
                                    AND analysis_item_code = (
                                        SELECT
                                            x1.analysis_item_code
                                        FROM
                                            (
                                                SELECT
                                                    x2.analysis_item_code,
                                                    RANK() OVER(
                                                        PARTITION BY x2.analysis_no
                                                        ORDER BY
                                                            x2.analysis_value DESC, x2.analysis_item_code ASC
                                                    ) rankx
                                                FROM
                                                    dv_cargo_analysis_component x2
                                                WHERE
                                                    x2.analysis_no = v_existing_analysis_no
                                            ) x1
                                        WHERE
                                            x1.rankx = 1
                                    );

                            END IF;
            -- Item 127684:ISWR02329 :End: IF condition ends.
            -- udfd Calculate C3+, C4+, C5+

                            SELECT
                                SUM(nvl(analysis_value, 0))
                            INTO v_propane_plus
                            FROM
                                dv_cargo_analysis_component
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND analysis_item_code IN (
                                    'C3',
                                    'IC4',
                                    'NC4',
                                    'IC5',
                                    'NC5',
                                    'NC6',
                                    'NC7',
                                    'NC8',
                                    'C9+'
                                );

                            SELECT
                                SUM(nvl(analysis_value, 0))
                            INTO v_butane_plus
                            FROM
                                dv_cargo_analysis_component
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND analysis_item_code IN (
                                    'IC4',
                                    'NC4',
                                    'IC5',
                                    'NC5',
                                    'NC6',
                                    'NC7',
                                    'NC8',
                                    'C9+'
                                );

                            SELECT
                                SUM(nvl(analysis_value, 0))
                            INTO v_pentane_plus
                            FROM
                                dv_cargo_analysis_component
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND analysis_item_code IN (
                                    'IC5',
                                    'NC5',
                                    'NC6',
                                    'NC7',
                                    'NC8',
                                    'C9+'
                                );

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = v_propane_plus
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'C3+';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = v_butane_plus
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'C4+';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = v_pentane_plus
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'C5+';

                        END IF;
          -- Update the Wheatstone Lab record as well

                        FOR analy_item IN existing_cargo_analysis(cargo_item.cargo_no, 'N', 'WST_LAB') LOOP v_existing_analysis_no
                        := analy_item.analysis_no;
                        END LOOP;

                        IF v_existing_analysis_no IS NOT NULL THEN
            -- Set the basic info
            --Item 113805: Begin
            --UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.text_10, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'H2S';
                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = item.text_10
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'H2S';
            --Item 113805: End

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = nvl(item.text_9, 0)
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'MERCAPTAN';
            --Item 113805: Begin
            --UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.text_8, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'SULFUR';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = item.text_8
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'SULFUR';
            --Item 113805: End
            --Item ADO649171: Begin

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = item.text_7
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'HG';
            --Item ADO649171: End

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = nvl(item.text_5, 0)
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'OXYGEN';
            --Item 113805: Begin
            --UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.co2_mol, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'CO2';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = item.co2_mol
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'CO2';
            --Item 113805: End
            -- udfd UPDATE dv_cargo_analysis_basic SET analysis_value = NVL(item.text_6, 0) WHERE analysis_no = v_existing_analysis_no AND NVL(analysis_value,0) = 0  AND analysis_item_code = 'SOLIDS';
            --Item 113805: Begin

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = item.text_11
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'H2S_UOP212';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = item.text_12
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'CO2_ISO';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = item.text_13
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'SULFUR_D6667';
            --Item 113805: End
            -- Item 127684:ISWR02329 :Begin: IF condition added to avoid divide by zero error.

                            v_total_comps := nvl(item.c1_mol, 0) + nvl(item.c2_mol, 0) + nvl(item.c3_mol, 0) + nvl(item.ic4_mol,
                            0) + nvl(item.nc4_mol, 0) + nvl(item.ic5_mol, 0) + nvl(item.nc5_mol, 0) + nvl(item.nc6_mol, 0) + nvl(
                            item.nc7_mol, 0) + nvl(item.nc8_mol, 0) + nvl(item.c9_plus_mol, 0);

                            IF v_total_comps > 0 THEN
              -- Set the component info
                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c1_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c1_mol), 0)
                                WHERE
                                    analysis_item_code = 'C1'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c2_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c2_mol), 0)
                                WHERE
                                    analysis_item_code = 'C2'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c3_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c3_mol), 0)
                                WHERE
                                    analysis_item_code = 'C3'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.ic4_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.ic4_mol), 0)
                                WHERE
                                    analysis_item_code = 'IC4'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc4_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc4_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC4'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.ic5_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.ic5_mol), 0)
                                WHERE
                                    analysis_item_code = 'IC5'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc5_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc5_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC5'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc6_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc6_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC6'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc7_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc7_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC7'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc8_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc8_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC8'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c9_plus_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c9_plus_mol), 0)
                                WHERE
                                    analysis_item_code = 'C9+'
                                    AND analysis_no = v_existing_analysis_no;
              -- UPDATE dv_cargo_analysis_component SET analysis_value = 0, analysis_value_raw = NVL(round(to_number(item.co2_mol), 3), 0) WHERE analysis_item_code = 'CO2' AND analysis_no = v_existing_analysis_no;
              -- UPDATE dv_cargo_analysis_component SET analysis_value = 0, analysis_value_raw = NVL(round(to_number(item.o2_mol), 3), 0) WHERE analysis_item_code = 'O2' AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.n2_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.n2_mol), 0)
                                WHERE
                                    analysis_item_code = 'N2'
                                    AND analysis_no = v_existing_analysis_no;
              -- Normalize components

                                SELECT
                                    SUM(nvl(analysis_value, 0))
                                INTO v_total_components
                                FROM
                                    dv_cargo_analysis_component
                                WHERE
                                    analysis_no = v_existing_analysis_no;

                                v_total_components := 100 / v_total_components;
                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = round(analysis_value * v_total_components, 2)
                                WHERE
                                    analysis_no = v_existing_analysis_no
                                    AND nvl(analysis_value, 0) > 0;

                                SELECT
                                    SUM(nvl(analysis_value, 0))
                                INTO v_total_components
                                FROM
                                    dv_cargo_analysis_component
                                WHERE
                                    analysis_no = v_existing_analysis_no;

                                v_total_components := 100 - v_total_components;
                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = analysis_value + v_total_components
                                WHERE
                                    analysis_no = v_existing_analysis_no
                                    AND analysis_item_code = (
                                        SELECT
                                            x1.analysis_item_code
                                        FROM
                                            (
                                                SELECT
                                                    x2.analysis_item_code,
                                                    RANK() OVER(
                                                        PARTITION BY x2.analysis_no
                                                        ORDER BY
                                                            x2.analysis_value DESC, x2.analysis_item_code ASC
                                                    ) rankx
                                                FROM
                                                    dv_cargo_analysis_component x2
                                                WHERE
                                                    x2.analysis_no = v_existing_analysis_no
                                            ) x1
                                        WHERE
                                            x1.rankx = 1
                                    );

                            END IF;
            -- Item 127684:ISWR02329 :End: IF condition ends

                            SELECT
                                SUM(nvl(analysis_value, 0))
                            INTO v_propane_plus
                            FROM
                                dv_cargo_analysis_component
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND analysis_item_code IN (
                                    'C3',
                                    'IC4',
                                    'NC4',
                                    'IC5',
                                    'NC5',
                                    'NC6',
                                    'NC7',
                                    'NC8',
                                    'C9+'
                                );

                            SELECT
                                SUM(nvl(analysis_value, 0))
                            INTO v_butane_plus
                            FROM
                                dv_cargo_analysis_component
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND analysis_item_code IN (
                                    'IC4',
                                    'NC4',
                                    'IC5',
                                    'NC5',
                                    'NC6',
                                    'NC7',
                                    'NC8',
                                    'C9+'
                                );

                            SELECT
                                SUM(nvl(analysis_value, 0))
                            INTO v_pentane_plus
                            FROM
                                dv_cargo_analysis_component
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND analysis_item_code IN (
                                    'IC5',
                                    'NC5',
                                    'NC6',
                                    'NC7',
                                    'NC8',
                                    'C9+'
                                );

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = v_propane_plus
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'C3+';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = v_butane_plus
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'C4+';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = v_pentane_plus
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'C5+';

                        END IF;

                    END IF;

                    IF ec_stream.object_code(item.object_id) = 'SW_GP_LNG_CARGO_LOC_GC' OR ec_stream.object_code(item.object_id)
                    = 'SW_GP_LNG_CARGO_LOC_GC_B' OR ec_stream.object_code(item.object_id) = 'SW_GP_COND_CARGO_LOC_GC' THEN
                        SELECT
                            CASE
                                WHEN ec_stream.object_code(item.object_id) = 'SW_GP_LNG_CARGO_LOC_GC'   THEN
                                    'Online GC A'
                                WHEN ec_stream.object_code(item.object_id) = 'SW_GP_LNG_CARGO_LOC_GC_B' THEN
                                    'Online GC B'
                                ELSE
                                    NULL
                            END
                        INTO v_sample_source
                        FROM
                            dual;

                        FOR analy_item IN existing_cargo_analysis(cargo_item.cargo_no, 'ALL', 'ONLINE_GC', v_sample_source) LOOP
                        v_existing_analysis_no := analy_item.analysis_no;
                        END LOOP;

                        IF v_existing_analysis_no IS NOT NULL THEN
            -- Item 127684:ISWR02329 :Begin: IF condition added to avoid divide by zero error.
                            v_total_comps := nvl(item.c1_mol, 0) + nvl(item.c2_mol, 0) + nvl(item.c3_mol, 0) + nvl(item.ic4_mol, 0
                            ) + nvl(item.nc4_mol, 0) + nvl(item.ic5_mol, 0) + nvl(item.nc5_mol, 0) + nvl(item.nc6_mol, 0) + nvl(item
                            .nc7_mol, 0) + nvl(item.nc8_mol, 0) + nvl(item.c9_plus_mol, 0);

                            IF v_total_comps > 0 THEN
              -- Set the component info
                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c1_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c1_mol), 0)
                                WHERE
                                    analysis_item_code = 'C1'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c2_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c2_mol), 0)
                                WHERE
                                    analysis_item_code = 'C2'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c3_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c3_mol), 0)
                                WHERE
                                    analysis_item_code = 'C3'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.ic4_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.ic4_mol), 0)
                                WHERE
                                    analysis_item_code = 'IC4'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc4_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc4_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC4'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.ic5_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.ic5_mol), 0)
                                WHERE
                                    analysis_item_code = 'IC5'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc5_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc5_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC5'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc6_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc6_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC6'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc7_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc7_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC7'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.nc8_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.nc8_mol), 0)
                                WHERE
                                    analysis_item_code = 'NC8'
                                    AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.c9_plus_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.c9_plus_mol), 0)
                                WHERE
                                    analysis_item_code = 'C9+'
                                    AND analysis_no = v_existing_analysis_no;
              -- UPDATE dv_cargo_analysis_component SET analysis_value = 0, analysis_value_raw = NVL(round(to_number(item.co2_mol), 3), 0) WHERE analysis_item_code = 'CO2' AND analysis_no = v_existing_analysis_no;
              -- UPDATE dv_cargo_analysis_component SET analysis_value = 0, analysis_value_raw = NVL(round(to_number(item.o2_mol), 3), 0) WHERE analysis_item_code = 'O2' AND analysis_no = v_existing_analysis_no;

                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = nvl(round(to_number(item.n2_mol), 20), 0),
                                    analysis_value_raw = nvl(to_number(item.n2_mol), 0)
                                WHERE
                                    analysis_item_code = 'N2'
                                    AND analysis_no = v_existing_analysis_no;
              -- Normalize components

                                SELECT
                                    SUM(nvl(analysis_value, 0))
                                INTO v_total_components
                                FROM
                                    dv_cargo_analysis_component
                                WHERE
                                    analysis_no = v_existing_analysis_no;

                                v_total_components := 100 / v_total_components;
                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = round(analysis_value * v_total_components, 2)
                                WHERE
                                    analysis_no = v_existing_analysis_no
                                    AND nvl(analysis_value, 0) > 0;

                                SELECT
                                    SUM(nvl(analysis_value, 0))
                                INTO v_total_components
                                FROM
                                    dv_cargo_analysis_component
                                WHERE
                                    analysis_no = v_existing_analysis_no;

                                v_total_components := 100 - v_total_components;
                                UPDATE dv_cargo_analysis_component
                                SET
                                    analysis_value = analysis_value + v_total_components
                                WHERE
                                    analysis_no = v_existing_analysis_no
                                    AND analysis_item_code = (
                                        SELECT
                                            x1.analysis_item_code
                                        FROM
                                            (
                                                SELECT
                                                    x2.analysis_item_code,
                                                    RANK() OVER(
                                                        PARTITION BY x2.analysis_no
                                                        ORDER BY
                                                            x2.analysis_value DESC, x2.analysis_item_code ASC
                                                    ) rankx
                                                FROM
                                                    dv_cargo_analysis_component x2
                                                WHERE
                                                    x2.analysis_no = v_existing_analysis_no
                                            ) x1
                                        WHERE
                                            x1.rankx = 1
                                    );

                            END IF;
            --Item 127684:ISWR02329: End
            -- udfd Calculate C3+, C4+, C5+

                            SELECT
                                SUM(nvl(analysis_value, 0))
                            INTO v_propane_plus
                            FROM
                                dv_cargo_analysis_component
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND analysis_item_code IN (
                                    'C3',
                                    'IC4',
                                    'NC4',
                                    'IC5',
                                    'NC5',
                                    'NC6',
                                    'NC7',
                                    'NC8',
                                    'C9+'
                                );

                            SELECT
                                SUM(nvl(analysis_value, 0))
                            INTO v_butane_plus
                            FROM
                                dv_cargo_analysis_component
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND analysis_item_code IN (
                                    'IC4',
                                    'NC4',
                                    'IC5',
                                    'NC5',
                                    'NC6',
                                    'NC7',
                                    'NC8',
                                    'C9+'
                                );

                            SELECT
                                SUM(nvl(analysis_value, 0))
                            INTO v_pentane_plus
                            FROM
                                dv_cargo_analysis_component
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND analysis_item_code IN (
                                    'IC5',
                                    'NC5',
                                    'NC6',
                                    'NC7',
                                    'NC8',
                                    'C9+'
                                );

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = v_propane_plus
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'C3+';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = v_butane_plus
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'C4+';

                            UPDATE dv_cargo_analysis_basic
                            SET
                                analysis_value = v_pentane_plus
                            WHERE
                                analysis_no = v_existing_analysis_no
                                AND nvl(analysis_value, 0) = 0
                                AND analysis_item_code = 'C5+';

                        END IF;

                    END IF;

                END IF;

            END LOOP;
    --tlxt: 10-oct-2016: when receive CONd analysis, it should be inserted directly into PA

            IF v_cargo = 'Y' AND ( ec_stream.object_code(item.object_id) = 'SW_GP_COND_CARGO' OR ec_stream.object_code(item.object_id
            ) = 'SW_GP_COND_CARGO_LOC_GC' ) AND v_parcel_count = 0 THEN -- Item 127684:ISWR02329: v_parcel_count ADDED
      --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_TRIGGER_ACTION',p_response_text);
                SELECT
                    MAX(parcel_no)
                INTO p_parcel_no
                FROM
                    dv_storage_lift_nomination
                WHERE
                    cargo_no = item.text_1;
      --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_TRIGGER_ACTION','p_parcel_no='||p_parcel_no);
      --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_TRIGGER_ACTION','p_response_text='||p_response_text);

                p_global_analysis_no := p_response_text;
      --ECDP_DYNSQL.WRITETEMPTEXT('UE_CT_TRIGGER_ACTION','p_Global_analysis_no='||p_Global_analysis_no);
                ue_ct_cargo_info.transfercargoanalysis(p_parcel_no, p_response_code, p_response_text);
            END IF;

            IF v_cargo = 'N' THEN
                FOR lookup_item IN lookup_analyses(item.object_id, item.analysis_date) LOOP
        --tlxt:get the analisis no based on the right sampling method
                 IF ( ( item.class_name = 'CT_STAGE_COMP_ANALYSIS' ) AND ( lookup_item.sampling_method = 'GC' ) ) OR ( ( item.class_name = 'CT_STAGE_COMP_ANALY_TXT'
                ) AND ( lookup_item.sampling_method = 'SPOT' ) ) THEN
                    v_existing_analysis_no := lookup_item.analysis_no;
                END IF;
                END LOOP;
      --tlxt: group the staging data into single row for the same object that splits by seconds

                FOR same_item IN analysis_rows_group LOOP
                    v_existing_anlys_flag := v_existing_analysis_no;
        --ISWR02333 : Check for the lock period
                    p_lockind := nvl(ec_system_month.lock_ind(trunc(to_date(same_item.analysis_date), 'MM')), 'N');

                    lr_next_analysis := ecdp_fluid_analysis.getnextanalysissample(same_item.object_id, same_item.analysis_type, same_item
                    .sampling_method, same_item.analysis_date);

                    v_process_flag := 'N'; -- Item 129926: INC000016821440: Initiate flag
                    IF p_lockind <> 'Y' AND ecdp_month_lock.lockedmonthaffected(same_item.analysis_date, lr_next_analysis.valid_from_date
                    ) IS NULL
          -- Item 127925: ISWR02513: Begin
                     AND ( trunc(sysdate - 15) <= trunc(same_item.analysis_date) )
          /* REQ2*/
          -- Item 127925: ISWR02513: End
                     THEN
                        v_process_flag := 'Y'; -- Item 129926: INC000016821440: Initiate flag
                        IF v_existing_analysis_no IS NULL THEN
                            v_existing_analysis_no := ecdp_system_key.assignnextnumber('OBJECT_FLUID_ANALYSIS');
            --dbms_output.put_line('assigned no = '||v_existing_analysis_no||' sampling method:'||SAME_ITEM.sampling_method);
            -- Insert Base
                            INSERT INTO dv_strm_analysis (
                                analysis_no,
                                object_id,
                                daytime,
                                analysis_type,
                                sampling_method,
                                phase,
                                sample_press,
                                sample_temp,
                                valid_from_date,
                                density,
                                rvp,
                                bsw_wt
                            ) VALUES (
                                v_existing_analysis_no,
                                same_item.object_id,
                                same_item.analysis_date,
                                same_item.analysis_type,
                                same_item.sampling_method,
                                same_item.phase,
                                same_item.sample_pressure,
                                same_item.sample_temp,
                                same_item.analysis_date,
                                same_item.density,
                                same_item.rvp,
                -- Item 128873: INC000017771458: Starts
                                same_item.bs_w
                -- Item 128873: INC000017771458: Ends
                            );
            -- Insert Analysis

                            INSERT INTO dv_strm_comp_analysis (
                                object_id,
                                daytime,
                                analysis_type,
                                sampling_method,
                                phase,
                                analysis_no,
                                wt_pct,
                                mol_pct,
                                component_no
                            )
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.c1_wt, 0),
                                    nvl(same_item.c1_mol, 0),
                                    'C1'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'C1'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.c2_wt, 0),
                                    nvl(same_item.c2_mol, 0),
                                    'C2'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'C2'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.c3_wt, 0),
                                    nvl(same_item.c3_mol, 0),
                                    'C3'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'C3'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.ic4_wt, 0),
                                    nvl(same_item.ic4_mol, 0),
                                    'IC4'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'IC4'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.nc4_wt, 0),
                                    nvl(same_item.nc4_mol, 0),
                                    'NC4'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'NC4'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.ic5_wt, 0),
                                    nvl(same_item.ic5_mol, 0),
                                    'IC5'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'IC5'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.nc5_wt, 0),
                                    nvl(same_item.nc5_mol, 0),
                                    'NC5'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'NC5'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.nc6_wt, 0),
                                    nvl(same_item.nc6_mol, 0),
                                    'NC6'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'NC6'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.nc7_wt, 0),
                                    nvl(same_item.nc7_mol, 0),
                                    'NC7'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'NC7'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.nc8_wt, 0),
                                    nvl(same_item.nc8_mol, 0),
                                    'NC8'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'NC8'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.c9_plus_wt, 0),
                                    nvl(same_item.c9_plus_mol, 0),
                                    'C9+'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'C9+'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.o2_wt, 0),
                                    nvl(same_item.o2_mol, 0),
                                    'O2'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'O2'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.n2_wt, 0),
                                    nvl(same_item.n2_mol, 0),
                                    'N2'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'N2'
                                    )
                                UNION ALL
                                SELECT
                                    same_item.object_id,
                                    same_item.analysis_date,
                                    same_item.analysis_type,
                                    same_item.sampling_method,
                                    same_item.phase,
                                    v_existing_analysis_no,
                                    nvl(same_item.co2_wt, 0),
                                    nvl(same_item.co2_mol, 0),
                                    'CO2'
                                FROM
                                    dual
                                WHERE
                                    EXISTS (
                                        SELECT
                                            1
                                        FROM
                                            tv_component_set_list
                                        WHERE
                                            code = ec_strm_version.comp_set_code(same_item.object_id, same_item.analysis_date, '<='
                                            )
                                            AND component_no = 'CO2'
                                    );

                            IF same_item.sampling_method = 'GC' THEN
                                createassociatedcalcsample(v_existing_analysis_no);
                            END IF;
            -- Updated as part of ISWR02333 to stop updation of already existing stream component analysis
            /*
            ELSE
            -- Update Base
            --If there is NULL value, we do not change the existing value
            UPDATE dv_strm_analysis
            SET sample_press = NVL(SAME_ITEM.sample_pressure,sample_press),
            sample_temp = NVL(SAME_ITEM.sample_temp,sample_temp),
            density = NVL(SAME_ITEM.density,density),
            rvp = NVL(SAME_ITEM.rvp,rvp),
            bsw_wt = NVL(SAME_ITEM.value_10,bsw_wt)
            WHERE analysis_no = v_existing_analysis_no;
            -- Update analysis
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.c1_wt,NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.c1_mol, NVL(mol_pct,0)) WHERE component_no = 'C1' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.c2_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.c2_mol, NVL(mol_pct,0)) WHERE component_no = 'C2' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.c3_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.c3_mol, NVL(mol_pct,0)) WHERE component_no = 'C3' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.ic4_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.ic4_mol, NVL(mol_pct,0)) WHERE component_no = 'IC4' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.nc4_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.nc4_mol, NVL(mol_pct,0)) WHERE component_no = 'NC4' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.ic5_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.ic5_mol, NVL(mol_pct,0)) WHERE component_no = 'IC5' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.nc5_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.nc5_mol, NVL(mol_pct,0)) WHERE component_no = 'NC5' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.Nc6_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.Nc6_mol, NVL(mol_pct,0)) WHERE component_no = 'NC6' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.Nc7_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.Nc7_mol, NVL(mol_pct,0)) WHERE component_no = 'NC7' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.Nc8_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.Nc8_mol, NVL(mol_pct,0)) WHERE component_no = 'NC8' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.c9_PLUS_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.c9_PLUS_mol, NVL(mol_pct,0)) WHERE component_no = 'C9+' AND analysis_no = v_existing_analysis_no;
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.co2_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.co2_mol, NVL(mol_pct,0)) WHERE component_no = 'CO2' AND analysis_no = v_existing_analysis_no;
            -- added by UDFD - was missing in GORGON
            UPDATE fluid_analysis_component SET wt_pct = NVL(SAME_ITEM.n2_wt, NVL(wt_pct,0)), mol_pct = NVL(SAME_ITEM.n2_mol, NVL(mol_pct,0)) WHERE component_no = 'N2' AND analysis_no = v_existing_analysis_no;
            --
            */
                        END IF;

                    END IF;

                END LOOP;

                cleannormalize(v_existing_analysis_no);
                IF v_existing_anlys_flag IS NULL -- ADDED condition to process only the records that dont have pre-existing analysis records
                 AND v_process_flag = 'Y'   -- Item 127926: INC000016821440: added condition to check for flag before syncing calc.
                 THEN
                    IF item.sampling_method = 'GC' THEN
                        synchronizecalcsample(v_existing_analysis_no, NULL, NULL, NULL);
                    ELSIF item.sampling_method = 'SPOT' THEN
                        synchronizecalcsample(NULL, NULL, v_existing_analysis_no, NULL);
                    END IF;
                END IF;

                moltowt(v_existing_analysis_no);
                zp_stagingdata.analysisstatuscheck(v_existing_analysis_no); -- ISWR02315: Added to auto reject the comp analysis that do not normalize to 100
            END IF;

        END LOOP;
  -- Autonomous

        COMMIT;
    END importstagedanalysis;

    FUNCTION getanalysis_no RETURN VARCHAR2 AS
    BEGIN
        RETURN p_global_analysis_no;
    END getanalysis_no;

    PROCEDURE importstagedflare (
        p_object_id   VARCHAR2,
        p_daytime     DATE
    ) IS

        v_value                NUMBER := ec_ct_stage_stream_event.event_mass('CT_STAGE_FLARE_EVENT', p_object_id, p_daytime);
        v_previous_daytime     DATE := ec_ct_stage_stream_event.prev_daytime('CT_STAGE_FLARE_EVENT', p_object_id, p_daytime);
        v_previous_value       NUMBER := ec_ct_stage_stream_event.event_mass('CT_STAGE_FLARE_EVENT', p_object_id, v_previous_daytime);
        v_next_value           NUMBER := ec_ct_stage_stream_event.event_mass('CT_STAGE_FLARE_EVENT', p_object_id, ec_ct_stage_stream_event.next_daytime
        ('CT_STAGE_FLARE_EVENT', p_object_id, p_daytime));
        v_previous_processed   VARCHAR2(100) := ec_ct_stage_stream_event.text_1('CT_STAGE_FLARE_EVENT', p_object_id, v_previous_daytime
        );
        v_next_processed       VARCHAR2(100) := ec_ct_stage_stream_event.text_1('CT_STAGE_FLARE_EVENT', p_object_id, ec_ct_stage_stream_event
        .next_daytime('CT_STAGE_FLARE_EVENT', p_object_id, p_daytime));
        CURSOR parent_object IS
        SELECT
            object_id,
            child_obj_id
        FROM
            object_group_conn
        WHERE
            parent_group_type = 'VF_NR'
            AND child_obj_id = p_object_id;

        v_count                NUMBER;
        v_verified_stat        NUMBER; --Item 129523 ISWR02796
    BEGIN
        IF gb_err_test THEN -- Item 131809 error test
            raise_application_error(-20101, 'Test error at ImportStagedFlare');
        END IF;
  -- This is either an "up" or "down" records. New entries should be written on "down" records, unless records were written out of order...
        IF v_value = 0 THEN -- "Down Record"
    -- Ensure that the previous record is an unprocessed "up" record
            IF v_previous_value > 0 AND nvl(v_previous_processed, 'N') = 'N' THEN
                FOR item IN parent_object LOOP
        -- Item 129523 ISWR02796:Starts
                    v_verified_stat := 0;
                    SELECT
                        COUNT(*)
                    INTO v_verified_stat
                    FROM
                        stat_process_status
                    WHERE
                        ( process_id = 'DAY_VER'
                          AND daytime = ecdp_productionday.getproductionday(NULL, item.object_id, v_previous_daytime, 'N') )
                        OR ( process_id IN (
                            'MTH_APV_V',
                            'MTH_APV_A'
                        )
                             AND daytime = trunc(ecdp_productionday.getproductionday(NULL, item.object_id, v_previous_daytime, 'N'
                             ), 'MM') );

                    IF v_verified_stat = 0 THEN
          -- Item 129523 ISWR02796: Ends
                        INSERT INTO dv_strm_day_nr_other (
                            class_name,
                            object_id,
                            daytime,
                            start_daytime,
                            end_daytime,
                            asset_id,
                            asset_type,
                            prod_day_release
                        ) VALUES (
                            'STRM_DAY_NR_OTHER',
                            item.object_id,
                            ecdp_productionday.getproductionday(NULL, item.object_id, v_previous_daytime, 'N'),
                            v_previous_daytime,
                            p_daytime,
                            item.child_obj_id,
                            'STREAM',
                            v_previous_value
                        );

                    END IF;

                END LOOP;

                UPDATE ct_stage_stream_event
                SET
                    text_1 = 'Y'
                WHERE
                    object_id = p_object_id
                    AND ( daytime = p_daytime
                          OR daytime = v_previous_daytime )
                    AND class_name = 'CT_STAGE_FLARE_EVENT';

            END IF;

            IF v_previous_value = 0 THEN
      -- This means that records were written out of order; the "up" record is going to be written next
                NULL; -- Ignore this situation
            END IF;
        ELSE    -- "Up Record"
            NULL; -- Ignore this situation
        END IF;

    END importstagedflare;

    PROCEDURE importstagedwellanalysis (
        p_stage_sample_number NUMBER
    ) IS

        CURSOR analysis_rows IS
        SELECT
            *
        FROM
            ct_stage_well_analysis
        WHERE
            stage_comp_analysis_no = p_stage_sample_number;
  -- Assumption made here that valid_from_date is a valid key field (as opposed to daytime)

        CURSOR lookup_analyses (
            cp_object_id       VARCHAR2,
            cp_analysis_date   DATE,
            cp_phase           VARCHAR2
        ) IS
        SELECT
            analysis_no
        FROM
            dv_well_analysis
        WHERE
            valid_from_date = cp_analysis_date
            AND object_id = cp_object_id
            AND phase = cp_phase;

        v_existing_analysis_no   NUMBER;
        v_total_components       NUMBER;
    BEGIN
        IF gb_err_test THEN -- Item 131809 error test
            raise_application_error(-20101, 'Test error at ImportStagedAnalysis for stage_sample_number['
                                            || to_char(p_stage_sample_number)
                                            || ']');
        END IF;

        FOR item IN analysis_rows LOOP
            FOR lookup_item IN lookup_analyses(item.object_id, item.analysis_date, item.phase) LOOP v_existing_analysis_no := lookup_item
            .analysis_no;
            END LOOP;

            IF v_existing_analysis_no IS NULL THEN
                v_existing_analysis_no := ecdp_system_key.assignnextnumber('OBJECT_FLUID_ANALYSIS');
      -- Insert Base
                IF item.phase = 'OIL' THEN
                    INSERT INTO dv_well_analysis (
                        analysis_no,
                        object_id,
                        daytime,
                        analysis_type,
                        analysis_status,
                        sampling_method,
                        phase,
                        sample_press,
                        sample_temp,
                        valid_from_date,
                        density
                    ) VALUES (
                        v_existing_analysis_no,
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        'APPROVED',
                        item.sampling_method,
                        item.phase,
                        item.sample_pressure,
                        item.sample_temp,
                        item.analysis_date,
                        item.density
                    );

                ELSE
                    INSERT INTO dv_well_analysis (
                        analysis_no,
                        object_id,
                        daytime,
                        analysis_type,
                        analysis_status,
                        sampling_method,
                        phase,
                        sample_press,
                        sample_temp,
                        valid_from_date,
                        gas_density
                    ) VALUES (
                        v_existing_analysis_no,
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        'APPROVED',
                        item.sampling_method,
                        item.phase,
                        item.sample_pressure,
                        item.sample_temp,
                        item.analysis_date,
                        item.density
                    );

                END IF;
      -- Insert Analysis

                INSERT INTO dv_well_comp_analysis (
                    object_id,
                    daytime,
                    analysis_type,
                    sampling_method,
                    phase,
                    analysis_no,
                    wt_pct,
                    mol_pct,
                    component_no
                )
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.c1_wt, 0),
                        nvl(item.c1_mol, 0),
                        'C1'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'C1'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.c2_wt, 0),
                        nvl(item.c2_mol, 0),
                        'C2'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'C2'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.c3_wt, 0),
                        nvl(item.c3_mol, 0),
                        'C3'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'C3'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.ic4_wt, 0),
                        nvl(item.ic4_mol, 0),
                        'IC4'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'IC4'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.nc4_wt, 0),
                        nvl(item.nc4_mol, 0),
                        'NC4'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'NC4'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.ic5_wt, 0),
                        nvl(item.ic5_mol, 0),
                        'IC5'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'IC5'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.nc5_wt, 0),
                        nvl(item.nc5_mol, 0),
                        'NC5'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'NC5'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.nc6_wt, 0),
                        nvl(item.nc6_mol, 0),
                        'NC6'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'NC6'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.nc7_wt, 0),
                        nvl(item.nc7_mol, 0),
                        'NC7'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'NC7'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.nc8_wt, 0),
                        nvl(item.nc8_mol, 0),
                        'NC8'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'NC8'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.c9_plus_wt, 0),
                        nvl(item.c9_plus_mol, 0),
                        'C9+'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'C9+'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.o2_wt, 0),
                        nvl(item.o2_mol, 0),
                        'O2'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'O2'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.n2_wt, 0),
                        nvl(item.n2_mol, 0),
                        'N2'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'N2'
                        )
                    UNION ALL
                    SELECT
                        item.object_id,
                        item.analysis_date,
                        item.analysis_type,
                        item.sampling_method,
                        item.phase,
                        v_existing_analysis_no,
                        nvl(item.co2_wt, 0),
                        nvl(item.co2_mol, 0),
                        'CO2'
                    FROM
                        dual
                    WHERE
                        EXISTS (
                            SELECT
                                1
                            FROM
                                tv_component_set_list
                            WHERE
                                code = ec_well_version.comp_gas_code(item.object_id, item.analysis_date, '<=')
                                AND component_no = 'CO2'
                        );

            ELSE
      -- Update Base
                IF item.phase = 'OIL' THEN
                    UPDATE dv_well_analysis
                    SET
                        sample_press = item.sample_pressure,
                        sample_temp = item.sample_temp,
                        density = item.density
                    WHERE
                        analysis_no = v_existing_analysis_no;

                ELSE
                    UPDATE dv_well_analysis
                    SET
                        sample_press = item.sample_pressure,
                        sample_temp = item.sample_temp,
                        gas_density = item.density
                    WHERE
                        analysis_no = v_existing_analysis_no;

                END IF;
      -- Update analysis

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.c1_wt, 0),
                    mol_pct = nvl(item.c1_mol, 0)
                WHERE
                    component_no = 'C1'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.c2_wt, 0),
                    mol_pct = nvl(item.c2_mol, 0)
                WHERE
                    component_no = 'C2'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.c3_wt, 0),
                    mol_pct = nvl(item.c3_mol, 0)
                WHERE
                    component_no = 'C3'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.ic4_wt, 0),
                    mol_pct = nvl(item.ic4_mol, 0)
                WHERE
                    component_no = 'IC4'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.nc4_wt, 0),
                    mol_pct = nvl(item.nc4_mol, 0)
                WHERE
                    component_no = 'NC4'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.ic5_wt, 0),
                    mol_pct = nvl(item.ic5_mol, 0)
                WHERE
                    component_no = 'IC5'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.nc5_wt, 0),
                    mol_pct = nvl(item.nc5_mol, 0)
                WHERE
                    component_no = 'NC5'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.nc6_wt, 0),
                    mol_pct = nvl(item.nc6_mol, 0)
                WHERE
                    component_no = 'NC6'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.nc7_wt, 0),
                    mol_pct = nvl(item.nc7_mol, 0)
                WHERE
                    component_no = 'NC7'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.nc8_wt, 0),
                    mol_pct = nvl(item.nc8_mol, 0)
                WHERE
                    component_no = 'NC8'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.c9_plus_wt, 0),
                    mol_pct = nvl(item.c9_plus_mol, 0)
                WHERE
                    component_no = 'C9+'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.co2_wt, 0),
                    mol_pct = nvl(item.co2_mol, 0)
                WHERE
                    component_no = 'CO2'
                    AND analysis_no = v_existing_analysis_no;

                UPDATE fluid_analysis_component
                SET
                    wt_pct = nvl(item.n2_wt, 0),
                    mol_pct = nvl(item.n2_mol, 0)
                WHERE
                    component_no = 'N2'
                    AND analysis_no = v_existing_analysis_no;

            END IF;

            cleannormalize(v_existing_analysis_no);
            moltowt(v_existing_analysis_no);
        END LOOP;

    END importstagedwellanalysis;

    PROCEDURE calcadjmass (
        p_object_id          IN   stream.object_id%TYPE,
        p_daytime            IN   DATE,
        p_profit_centre_id   VARCHAR2 DEFAULT NULL,
        p_corr_method        VARCHAR2,
        p_corr_factor        NUMBER
    ) IS

        ln_total_mass_adj   NUMBER;
        ln_c1_mass_adj      NUMBER;
        ln_c2_mass_adj      NUMBER;
        ln_c3_mass_adj      NUMBER;
        ln_ic4_mass_adj     NUMBER;
        ln_nc4_mass_adj     NUMBER;
        ln_ic5_mass_adj     NUMBER;
        ln_nc5_mass_adj     NUMBER;
        ln_nc6_mass_adj     NUMBER;
        ln_nc7_mass_adj     NUMBER;
        ln_nc8_mass_adj     NUMBER;
        ln_c9p_mass_adj     NUMBER;
        ln_co2_mass_adj     NUMBER;
        ln_n2_mass_adj      NUMBER;
    BEGIN
  -- Check the adjustment method
        IF p_corr_method = 'CORR_FACTOR' THEN
    -- Apply correction factor to stream
            IF p_profit_centre_id IS NULL THEN
      -- Calculate adjusted mass
                ln_total_mass_adj := nvl(ec_strm_day_alloc.net_mass(p_object_id, p_daytime), 0) * p_corr_factor;

                ln_c1_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'C1', p_daytime), 0) * p_corr_factor;

                ln_c2_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'C2', p_daytime), 0) * p_corr_factor;

                ln_c3_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'C3', p_daytime), 0) * p_corr_factor;

                ln_ic4_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'IC4', p_daytime), 0) * p_corr_factor;

                ln_nc4_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'NC4', p_daytime), 0) * p_corr_factor;

                ln_ic5_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'IC5', p_daytime), 0) * p_corr_factor;

                ln_nc5_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'NC5', p_daytime), 0) * p_corr_factor;

                ln_nc6_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'NC6', p_daytime), 0) * p_corr_factor;

                ln_nc7_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'NC7', p_daytime), 0) * p_corr_factor;

                ln_nc8_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'NC8', p_daytime), 0) * p_corr_factor;

                ln_c9p_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'C9+', p_daytime), 0) * p_corr_factor;

                ln_co2_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'CO2', p_daytime), 0) * p_corr_factor;

                ln_n2_mass_adj := nvl(ec_strm_day_comp_alloc.net_mass(p_object_id, 'N2', p_daytime), 0) * p_corr_factor;
      -- Update table with adjusted mass

                UPDATE ct_strm_day_adj
                SET
                    total_mass_adj = ln_total_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    c1_mass_adj = ln_c1_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    c2_mass_adj = ln_c2_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    c3_mass_adj = ln_c3_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    ic4_mass_adj = ln_ic4_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    nc4_mass_adj = ln_nc4_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    ic5_mass_adj = ln_ic5_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    nc5_mass_adj = ln_nc5_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    nc6_mass_adj = ln_nc6_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    nc7_mass_adj = ln_nc7_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    nc8_mass_adj = ln_nc8_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    c9p_mass_adj = ln_c9p_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    co2_mass_adj = ln_co2_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_adj
                SET
                    n2_mass_adj = ln_n2_mass_adj
                WHERE
                    object_id = p_object_id
                    AND daytime = p_daytime;

            END IF;
    --  Apply correction factor to profit centre part of the stream

            IF p_profit_centre_id IS NOT NULL THEN
      -- Calculate adjusted mass
                ln_total_mass_adj := nvl(ec_strm_day_pc_alloc.net_mass(p_object_id, p_profit_centre_id, p_daytime), 0) * p_corr_factor
                ;

                ln_c1_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'C1', p_daytime), 0) * p_corr_factor
                ;

                ln_c2_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'C2', p_daytime), 0) * p_corr_factor
                ;

                ln_c3_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'C3', p_daytime), 0) * p_corr_factor
                ;

                ln_ic4_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'IC4', p_daytime), 0) *
                p_corr_factor;

                ln_nc4_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'NC4', p_daytime), 0) *
                p_corr_factor;

                ln_ic5_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'IC5', p_daytime), 0) *
                p_corr_factor;

                ln_nc5_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'NC5', p_daytime), 0) *
                p_corr_factor;

                ln_nc6_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'NC6', p_daytime), 0) *
                p_corr_factor;

                ln_nc7_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'NC7', p_daytime), 0) *
                p_corr_factor;

                ln_nc8_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'NC8', p_daytime), 0) *
                p_corr_factor;

                ln_c9p_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'C9+', p_daytime), 0) *
                p_corr_factor;

                ln_co2_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'CO2', p_daytime), 0) *
                p_corr_factor;

                ln_n2_mass_adj := nvl(ec_strm_day_pc_cp_alloc.net_mass(p_object_id, p_profit_centre_id, 'N2', p_daytime), 0) * p_corr_factor
                ;
      -- Update table with adjusted mass

                UPDATE ct_strm_day_pc_adj
                SET
                    total_mass_adj = ln_total_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    c1_mass_adj = ln_c1_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    c2_mass_adj = ln_c2_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    c3_mass_adj = ln_c3_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    ic4_mass_adj = ln_ic4_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    nc4_mass_adj = ln_nc4_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    ic5_mass_adj = ln_ic5_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    nc5_mass_adj = ln_nc5_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    nc6_mass_adj = ln_nc6_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    nc7_mass_adj = ln_nc7_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    nc8_mass_adj = ln_nc8_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    c9p_mass_adj = ln_c9p_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    co2_mass_adj = ln_co2_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

                UPDATE ct_strm_day_pc_adj
                SET
                    n2_mass_adj = ln_n2_mass_adj
                WHERE
                    object_id = p_object_id
                    AND profit_centre_id = p_profit_centre_id
                    AND daytime = p_daytime;

            END IF;

        ELSIF p_corr_method = 'MANUAL' THEN
            IF p_profit_centre_id IS NULL THEN
                NULL;
            END IF;
            IF p_profit_centre_id IS NOT NULL THEN
                NULL;
            END IF;
        END IF;
    END calcadjmass;
-----------------------------------------------------------------------------------------------------
-- Function       : ResetNomValidFlag
-- Description    : Package is called from the trigger 9700 on FCST_STOR_LIFT_NOM_SCHED and
--                        FCST_STOR_LIFT_NOM. Trigger checks if attributes have been updated and if
--                        the nomination has been assigned a cargo number. If so this package is called.
--                        This package takes the Cargo Number of the updated nomination, and sets the
--                        NOM_VALID and VALIDATION_ISSUES attribute to null only if the record
--                        is in provisonal status
-- Author         :Euan Milne (eqyp)
-- Date           :23/Jan/2015
-- TFS Work Item  :94343 CP - Defect - Reset Nomination Valid Flag
-----------------------------------------------------------------------------------------------------

    PROCEDURE resetnomvalidflag (
        p_parcel_number   NUMBER,
        p_forecast_id     VARCHAR2
    ) IS
    BEGIN
  --Check if we have been passed parameters
        IF ( p_parcel_number IS NOT NULL AND p_forecast_id IS NOT NULL ) THEN
    --Update NOM_VALID flag for the passed in PARCEL_NO and FORECAST_ID
            UPDATE dv_fcst_stor_lift_nom
            SET
                nom_valid = NULL,
                validation_issues = NULL
            WHERE
                parcel_no = p_parcel_number
                AND forecast_id = p_forecast_id
                AND ( record_status = 'P'
                      OR record_status IS NULL );

        END IF;
    END resetnomvalidflag;
-----------------------------------------------------------------------------------------------------
-- Function       : ResetAllNomValidFlags
-- Description    : Package is called from the trigger 9800 on FCST_STOR_LIFT_NOM_SCHED and
--                        FCST_STOR_LIFT_NOM. Trigger checks if nomination has been deleted.  Sets the
--                        NOM_VALID and VALIDATION_ISSUES attribute to null for all of the records in the scenario
--                        is in provisonal status
-- Author         :Euan Milne (eqyp)
-- Date           :23/Jan/2015
-- TFS Work Item  :94343 CP - Defect - Reset Nomination Valid Flag
-----------------------------------------------------------------------------------------------------

    PROCEDURE resetallnomvalidflags (
        p_forecast_id VARCHAR2
    ) IS
    BEGIN
  --Check if we have been passed parameters
        IF ( p_forecast_id IS NOT NULL ) THEN
    --Update NOM_VALID flag for ALL of the nominations in the scenario
            UPDATE dv_fcst_stor_lift_nom
            SET
                nom_valid = NULL,
                validation_issues = NULL
            WHERE
                forecast_id = p_forecast_id
                AND ( record_status = 'P'
                      OR record_status IS NULL );

        END IF;
    END resetallnomvalidflags;
-----------------------------------------------------------------------------------------------------
-- Function       : CheckEBOCDemurrageStatus
-- Description    : Package is called from the trigger ON demurrage and cargo_harbour_dues
--                    If the passed in cargo ID has a status of Cancelled, or any deriviate of cancelled
--                    display error.
-- Author         :Euan Milne (eqyp)
-- Date           :10/Nov/2015
-- TFS Work Item  :104662 MA - Class Cargo Harbour Dues - Creation of Prior Trigger
-----------------------------------------------------------------------------------------------------

    PROCEDURE checkebocdemurragestatus (
        p_cargo_id NUMBER
    ) IS
        lv_status VARCHAR(32);
    BEGIN
        SELECT
            status
        INTO lv_status
        FROM
            dv_cargo_info
        WHERE
            cargo_no = p_cargo_id;

        IF ec_prosty_codes.alt_code(lv_status, 'TRAN_CARGO_STATUS') = 'D' THEN
            raise_application_error(-20854, 'Demurrage or EBOC worksheets can only be created for cargos with cargo status other than Cancelled'
            );
        END IF;

    END checkebocdemurragestatus;

    PROCEDURE synccargoanalcomp (
        p_analysis_no NUMBER
    ) IS
        v_propane_plus   NUMBER;
        v_butane_plus    NUMBER;
        v_pentane_plus   NUMBER;
    BEGIN
        SELECT
            SUM(nvl(analysis_value, 0))
        INTO v_propane_plus
        FROM
            dv_cargo_analysis_component
        WHERE
            analysis_no = p_analysis_no
            AND analysis_item_code IN (
                'C3',
                'IC4',
                'NC4',
                'IC5',
                'NC5',
                'NC6',
                'NC7',
                'NC8',
                'C9+'
            );

        SELECT
            SUM(nvl(analysis_value, 0))
        INTO v_butane_plus
        FROM
            dv_cargo_analysis_component
        WHERE
            analysis_no = p_analysis_no
            AND analysis_item_code IN (
                'IC4',
                'NC4',
                'IC5',
                'NC5',
                'NC6',
                'NC7',
                'NC8',
                'C9+'
            );

        SELECT
            SUM(nvl(analysis_value, 0))
        INTO v_pentane_plus
        FROM
            dv_cargo_analysis_component
        WHERE
            analysis_no = p_analysis_no
            AND analysis_item_code IN (
                'IC5',
                'NC5',
                'NC6',
                'NC7',
                'NC8',
                'C9+'
            );

        UPDATE dv_cargo_analysis_basic
        SET
            analysis_value = v_propane_plus
        WHERE
            analysis_no = p_analysis_no
            AND analysis_item_code = 'C3+';

        UPDATE dv_cargo_analysis_basic
        SET
            analysis_value = v_butane_plus
        WHERE
            analysis_no = p_analysis_no
            AND analysis_item_code = 'C4+';

        UPDATE dv_cargo_analysis_basic
        SET
            analysis_value = v_pentane_plus
        WHERE
            analysis_no = p_analysis_no
            AND analysis_item_code = 'C5+';

    END synccargoanalcomp;

    PROCEDURE checkoosflag (
        p_daytime DATE
    ) IS
        lv_count VARCHAR(32);
    BEGIN
        SELECT
            COUNT(*)
        INTO lv_count
        FROM
            dv_strm_day_stream_meas_gas
        WHERE
            oos_flag = 'Y'
            AND daytime = p_daytime
            AND object_code LIKE '%GP%FLR_METER%';

        IF lv_count = 2 THEN
            raise_application_error(-20854, 'Out Of Service Flag can either be set on Wet or Dry Flare but not both at the same time'
            );
        END IF;
    END checkoosflag;
--Item 127684:ISWR02329 :Begin
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : cfwd_tdds
-- Description    : To calculate tank density based on current streams and day-1 tank
--
-- Preconditions  :
-- Postconditions : Uncommited changes
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

    PROCEDURE cfwd_tdds (
        p_daytime     DATE,
        p_object_id   VARCHAR2
    ) IS

        lv_bf_usage            VARCHAR2(32);
        lv_fcty_2              VARCHAR2(32);
        p_corr_density         NUMBER;
        p_tot_mass             NUMBER;
        p_tot_vol              NUMBER;
        p_tot_mass_tank        NUMBER;
        p_tot_vol_tank         NUMBER;
        p_count                NUMBER := NULL;
        v_cargo_anlysis_flag   NUMBER := 0;
        CURSOR read_tank_prev_day_cond IS
        SELECT
            object_code,
            daytime,
            wat_dip_level,
            bsw_vol,
            corr_density
        FROM
            dv_tank_day_dip_status
        WHERE
            daytime = p_daytime - 1
            AND object_code IN (
                SELECT
                    code
                FROM
                    ov_tank
                WHERE
                    p_daytime >= daytime
                    AND p_daytime < nvl(end_date, p_daytime + 1)
                    AND bf_usage = 'PO.0005.02'
                    AND op_fcty_1_code IN (
                        'FC1_WS1_STL_2300'
                    )
            );

        CURSOR read_stream_data IS
        SELECT
            (
                SELECT
                    MAX(density) AS density
                FROM
                    object_fluid_analysis
                WHERE
                    daytime = (
                        SELECT
                            MAX(daytime)
                        FROM
                            object_fluid_analysis
                        WHERE
                            object_id = ab.object_id
                            AND daytime <= ab.daytime
                            AND analysis_status = 'APPROVED'
                    )
                    AND object_id = ab.object_id
                    AND analysis_status = 'APPROVED'
            ) AS density,
            ecbp_stream_fluid.findnetstdmass(ab.object_id, ab.daytime) AS net_mass_oil
        FROM
            strm_day_stream ab
        WHERE
            object_id IN (
                SELECT DISTINCT
                    object_id
                FROM
                    ov_stream
                WHERE
                    to_node_code = 'FC1_WS1_STL_2300'
                    AND end_date IS NULL
                    AND alloc_period <> 'NONE'
                    AND alloc_data_freq IS NOT NULL
            )
            AND daytime = ( to_date(p_daytime) );

    BEGIN
        SELECT
            COUNT(analysis_no)
        INTO v_cargo_anlysis_flag
        FROM
            dv_cargo_analysis
        WHERE
            trunc(daytime) = trunc(p_daytime)
            AND official_ind = 'Y'
            AND product_code = 'COND'
            AND ec_cargo_analysis_item.analysis_value(analysis_no, 'DENSITY') IS NOT NULL;

        IF v_cargo_anlysis_flag = 0 THEN
            SELECT
                COUNT(object_id)
            INTO p_count
            FROM
                ov_stream
            WHERE
                to_node_code = 'FC1_WS1_STL_2300'
                AND end_date IS NULL
                AND alloc_period <> 'NONE'
                AND alloc_data_freq IS NOT NULL
                AND object_id = p_object_id;

            IF p_count > 0 THEN
                FOR tank_dip IN read_tank_prev_day_cond LOOP
                    p_corr_density := NULL;
                    p_tot_mass := 0;
                    p_tot_vol := 0;
          -- Try to get density based previous day stream data
                    FOR stream_data IN read_stream_data LOOP IF nvl(stream_data.density, 0) > 0 AND nvl(stream_data.net_mass_oil,
                    0) > 0 THEN
                        p_tot_mass := p_tot_mass + stream_data.net_mass_oil;
                        p_tot_vol := p_tot_vol + ( stream_data.net_mass_oil * 1000 / stream_data.density );
                    END IF;
                    END LOOP;

                    SELECT
                        nvl(SUM(std_net_vol_oil), 0),
                        nvl(SUM(calc_net_mass), 0)
                    INTO
                        p_tot_vol_tank,
                        p_tot_mass_tank
                    FROM
                        dv_tank_day_dip_status
                    WHERE
                        daytime = p_daytime - 1
                        AND object_code IN (
                            SELECT
                                code
                            FROM
                                ov_tank
                            WHERE
                                p_daytime >= daytime
                                AND p_daytime < nvl(end_date, p_daytime + 1)
                                AND bf_usage = 'PO.0005.02'
                                AND op_fcty_1_code IN (
                                    'FC1_WS1_STL_2300'
                                )
                        );

                    IF nvl(p_tot_vol, 0) > 0 OR p_tot_vol_tank > 0 THEN
                        p_corr_density := round((p_tot_mass + p_tot_mass_tank) * 1000 /(p_tot_vol + p_tot_vol_tank), 6);
                    END IF;

                    UPDATE dv_tank_day_dip_status
                    SET
                        corr_density = nvl(p_corr_density, tank_dip.corr_density)
                    WHERE
                        daytime = p_daytime
                        AND object_code = tank_dip.object_code;

                END LOOP;

            END IF;

        END IF;

    END cfwd_tdds;
  --Item 127684:ISWR02329 :End
  --Item 127455: Begin
  --<EC-DOC>
  ---------------------------------------------------------------------------------------------------
  -- Procedure      : auCargoTransport
  -- Description    :
  --
  -- Preconditions  :
  -- Postconditions : Uncommited changes
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

    PROCEDURE aucargotransport (
        p_cargo_no           NUMBER,
        p_old_cargo_status   VARCHAR2,
        p_new_cargo_status   VARCHAR2,
        p_user               VARCHAR2 DEFAULT NULL
    )
    --</EC-DOC>
     IS

        CURSOR cur_analysis_no IS
        SELECT
            analysis_no
        FROM
            cargo_analysis
        WHERE
            cargo_no = p_cargo_no;

        lv_old_cargo_status   VARCHAR2(1);
        lv_new_cargo_status   VARCHAR2(1);
    BEGIN
    -- get the EC cargo status
        lv_old_cargo_status := ecbp_cargo_status.geteccargostatus(p_old_cargo_status);
        lv_new_cargo_status := ecbp_cargo_status.geteccargostatus(p_new_cargo_status);
    -- if status has changed
        IF nvl(p_old_cargo_status, 'XXX') <> nvl(p_new_cargo_status, 'XXX') THEN
            IF lv_old_cargo_status = 'C' AND lv_new_cargo_status = 'R' THEN
                FOR cur IN cur_analysis_no LOOP
                    UPDATE cargo_analysis
                    SET
                        record_status = 'P',
                        last_updated_by = p_user
                    WHERE
                        analysis_no = cur.analysis_no;

                    UPDATE cargo_analysis_item
                    SET
                        record_status = 'P',
                        last_updated_by = p_user
                    WHERE
                        analysis_no = cur.analysis_no;

                END LOOP;

            END IF;
        END IF;

    END aucargotransport;
--Item 127455: End

END ue_ct_trigger_action;
/