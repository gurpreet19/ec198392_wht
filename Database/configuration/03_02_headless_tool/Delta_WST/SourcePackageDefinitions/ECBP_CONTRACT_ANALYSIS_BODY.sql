CREATE OR REPLACE PACKAGE BODY EcBp_Contract_Analysis IS
/****************************************************************
** Package        :  EcBp_Contract_Analysis
**
** $Revision: 1.5 $
**
** Purpose        :
**
** Documentation  :  www.energy-components.com
**
** Created  : 14.10.2005 by Kristin Eide
**
** Modification history:
**
** Date       Whom  	 Change description:
** --------   ----- 	--------------------------------------
** 14.10.05   eideekri   Initial version
** 03.01.06   DN         TI2691: CLASS_NAME renamed to OBJECT_CLASS_NAME.
** 25-10-2016 thotesan   ECPD-37786: Modified update statements in generateCompMeter so that last_updated_date will be populated when function is triggered.
** 03.07.2017 asareswi   ECPD-45818: Replaced sysdate with Ecdp_Timestamp.getCurrentSysdate
******************************************************************/

--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : generateAnalysisDays                                                        --
-- Description    : Function to generate days for the selected analysis-month.
--                                                                                              --
-- Preconditions  :
-- Postcondition  :                                                                             --
-- Using Tables   :
--                                                                                              --
--
--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
PROCEDURE generateAnalysisDays(p_delivery_point_id VARCHAR2,
                               p_daytime           DATE,
                               p_analysis_type     VARCHAR2,
                               p_class_name        VARCHAR2,
                               p_user              VARCHAR2)

  --</EC-DOC>
 IS
  ld_end              DATE;
  ld_daytime          DATE;
  li_day_record_count INTEGER;

BEGIN

  ld_end     := LAST_DAY(p_daytime);
  ld_daytime := TRUNC(p_daytime, 'MONTH');

  WHILE ld_daytime <= ld_end LOOP

    SELECT COUNT(*)
      INTO li_day_record_count
      FROM object_fluid_analysis
     WHERE object_id = p_delivery_point_id
       AND sampling_method = 'DAY_SAMPLER'
       AND object_class_name = p_class_name
       AND analysis_type = p_analysis_type
       AND daytime = ld_daytime;

    IF li_day_record_count = 0 THEN

      INSERT INTO object_fluid_analysis
        (object_id,
         object_class_name,
         daytime,
         ANALYSIS_TYPE,
         sampling_method,
         PHASE,
         valid_from_date,
         created_by,
         created_date,
         analysis_status)
      VALUES
        (p_delivery_point_id,
         p_class_name,
         ld_daytime,
         p_analysis_type,
         'DAY_SAMPLER',
         'GAS',
         NULL,
         p_user,
         Ecdp_Timestamp.getCurrentSysdate,
         'NEW');

      generateComp(p_delivery_point_id,
                   ld_daytime,
                   'DAY_SAMPLER',
                   p_analysis_type,
                   p_class_name,
                   p_user);

    END IF;
    ld_daytime := ld_daytime + 1;
  END LOOP;

END generateAnalysisDays;
--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : generateComp                                                              --
-- Description    : Function generates components for each analysis record in object_fluid_analysis
--                  for sale-analysis?
--
-- Preconditions  : 																			--
-- Postcondition  :                                                                             --
-- Using Tables   : fluid_analysis_component / object_fluid_analysis / comp_list														--
--                                                                                              --
-- 										--
--                  																			--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
PROCEDURE generateComp(p_delivery_point_id VARCHAR2,
                       p_daytime           DATE,
                       p_sampling_method   VARCHAR2,
                       p_analysis_type     VARCHAR2,
                       p_class_name        VARCHAR2,
                       p_user              VARCHAR2)

 IS

  CURSOR c_component IS
    SELECT component_no
      FROM comp_set_list
     WHERE component_set = 'SALE_DEL_COMP';

  CURSOR c_analysis IS
    SELECT analysis_no
      FROM object_fluid_analysis
     WHERE object_id = p_delivery_point_id
       AND sampling_method = p_sampling_method
       AND object_class_name = p_class_name
       AND analysis_type = p_analysis_type
       AND daytime = p_daytime;

  ln_analysis c_analysis%ROWTYPE;

BEGIN

  IF NOT c_analysis%ISOPEN THEN
    OPEN c_analysis;
  END IF;

  FETCH c_analysis
    INTO ln_analysis;

  IF ln_analysis.analysis_no IS NOT NULL THEN
    FOR curComponent IN c_component LOOP
      IF curComponent.component_no IS NOT NULL THEN

        INSERT INTO fluid_analysis_component
          (ANALYSIS_NO,
           COMPONENT_NO,
           RECORD_STATUS,
           CREATED_BY,
           CREATED_DATE,
           MOL_PCT,
           WT_PCT)
        VALUES
          (ln_analysis.analysis_no,
           curComponent.component_no,
           'P',
           p_user,
           Ecdp_Timestamp.getCurrentSysdate,
           NULL,
           NULL);

      END IF;

    END LOOP;

  END IF;

END generateComp;

--<EC-DOC>

--------------------------------------------------------------------------------------------------
-- Procedure      : generateCompNP                                                              --
-- Description    : Function generates components for each analysis record in object_fluid_analysis
--                  for tran-analysis?
--
-- Preconditions  : 																			--
-- Postcondition  :                                                                             --
-- Using Tables   : fluid_analysis_component / object_fluid_analysis / comp_list														--
--                                                                                              --
-- 										--
--                  																			--
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
PROCEDURE generateCompNP(p_np_id VARCHAR2,
                       p_daytime           DATE,
                       p_sampling_method   VARCHAR2,
                       p_analysis_type     VARCHAR2,
                       p_class_name        VARCHAR2,
                       p_user              VARCHAR2)

 IS

  CURSOR c_component IS
    SELECT component_no
      FROM comp_set_list
     WHERE component_set = 'NP_DEL_COMP';

  CURSOR c_analysis IS
    SELECT analysis_no
      FROM object_fluid_analysis
     WHERE object_id = p_np_id
       AND sampling_method = p_sampling_method
       AND object_class_name = p_class_name
       AND analysis_type = p_analysis_type
       AND daytime = p_daytime;

  ln_analysis c_analysis%ROWTYPE;

BEGIN

  IF NOT c_analysis%ISOPEN THEN
    OPEN c_analysis;
  END IF;

  FETCH c_analysis
    INTO ln_analysis;

  IF ln_analysis.analysis_no IS NOT NULL THEN
    FOR curComponent IN c_component LOOP
      IF curComponent.component_no IS NOT NULL THEN

        INSERT INTO fluid_analysis_component
          (ANALYSIS_NO,
           COMPONENT_NO,
           RECORD_STATUS,
           CREATED_BY,
           CREATED_DATE,
           MOL_PCT,
           WT_PCT)
        VALUES
          (ln_analysis.analysis_no,
           curComponent.component_no,
           'P',
           p_user,
           Ecdp_Timestamp.getCurrentSysdate,
           NULL,
           NULL);

      END IF;

    END LOOP;

  END IF;

END generateCompNP;

--<EC-DOC>

--------------------------------------------------------------------------------------------------
-- Procedure      : generateCompMeter                                                           --
-- Description    : Function generates components for METER_DEL_COMP in object_fluid_analysis
--                  for tran-analysis?
--
-- Preconditions  : 																			                                      --
-- Postcondition  :                                                                             --
-- Using Tables   : fluid_analysis_component / object_fluid_analysis / comp_list								--
--                                                                                              --
-- 										                                                                          --
--                  																			                                      --
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
  PROCEDURE generateCompMeter(p_meter_id        VARCHAR2,
                              p_daytime         DATE,
                              p_sampling_method VARCHAR2,
                              p_analysis_type   VARCHAR2,
                              p_class_name      VARCHAR2,
                              p_user            VARCHAR2)

   IS

    CURSOR c_component IS
      SELECT component_no
        FROM comp_set_list
       WHERE component_set = 'METER_DEL_COMP';

    CURSOR c_analysis IS
      SELECT *
        FROM object_fluid_analysis
       WHERE object_id = p_meter_id
         AND sampling_method = p_sampling_method
         AND object_class_name = p_class_name
         AND analysis_type = p_analysis_type
         AND daytime = p_daytime;

    lr_analysis      object_fluid_analysis%ROWTYPE;
    lv_record_status VARCHAR2(16);

  BEGIN

    FOR mycur IN c_analysis LOOP
      lr_analysis := mycur;
    END LOOP;

    lv_record_status := ec_prosty_codes.alt_code(lr_analysis.analysis_status,
                                                 'ANALYSIS_STATUS');


    IF lr_analysis.analysis_no IS NOT NULL THEN
      FOR curComponent IN c_component LOOP
        IF curComponent.component_no IS NOT NULL THEN

          INSERT INTO fluid_analysis_component
            (ANALYSIS_NO,
             COMPONENT_NO,
             RECORD_STATUS,
             CREATED_BY,
             CREATED_DATE,
             MOL_PCT,
             WT_PCT)
          VALUES
            (lr_analysis.analysis_no,
             curComponent.component_no,
             lv_record_status,
             p_user,
             Ecdp_Timestamp.getCurrentSysdate,
             NULL,
             NULL);

        END IF;
      END LOOP;

  	  IF lr_analysis.record_status <> lv_record_status THEN
        -- update object_fluid_analysis
  		UPDATE object_fluid_analysis
  		SET record_status = lv_record_status, last_updated_by = p_user,last_updated_date = Ecdp_Timestamp.getCurrentSysdate
  		WHERE analysis_no = lr_analysis.analysis_no;
  	  END IF;

    END IF;

  END generateCompMeter;

END EcBp_Contract_Analysis;