CREATE OR REPLACE EDITIONABLE TRIGGER "IU_STIM_FCST_MTH_VALUE" 
BEFORE INSERT OR UPDATE ON STIM_FCST_MTH_VALUE
FOR EACH ROW
DECLARE

   no_uom EXCEPTION;
   no_conv_uom EXCEPTION;
   no_valid_master_uom EXCEPTION;
   no_valid_extra_uom EXCEPTION;
   no_master_qty EXCEPTION;

   invalid_split_share EXCEPTION;

   lv2_master_uom VARCHAR2(16);
   lv2_uom_group VARCHAR2(16);
   lv2_conversion_method VARCHAR2(32);

   lv2_extra1_uom_group VARCHAR2(16);
   lv2_extra2_uom_group VARCHAR2(16);
   lv2_extra3_uom_group VARCHAR2(16);
   lv2_extra1_uom_subgroup ctrl_unit.uom_subgroup%type;
   lv2_extra2_uom_subgroup ctrl_unit.uom_subgroup%type;
   lv2_extra3_uom_subgroup ctrl_unit.uom_subgroup%type;
   lv2_energy_uom_subgroup ctrl_unit.uom_subgroup%type;

   ib_vol_master BOOLEAN;
   ib_mass_master BOOLEAN;
   ib_energy_master BOOLEAN;

    CURSOR c_member IS
    SELECT t.member_no,t.stream_item_id
    FROM fcst_member t
    WHERE t.object_id = :New.forecast_id
    AND t.stream_item_id = :New.object_id;

    lv2_member_no VARCHAR2(32);

BEGIN

-- HS 20.09.02: Important note: Change from using "updating(<col>)" to testing explicit between old vs new to detect change
--                              This because logic should only apply if a value has really changed !

    -- $Revision: 1.10 $
    -- Basis
    IF Inserting THEN
      :new.record_status := 'P';

      IF :new.created_by IS NULL THEN
         :new.created_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
      END IF;
      :new.created_date := Ecdp_Timestamp.getCurrentSysdate;
      :new.rev_no := 0;

      -- Replicated code values
      :new.MASTER_UOM_GROUP := ecdp_revn_forecast.getStreamItemAttribute(:New.forecast_id, :New.object_id, :New.daytime, 'MASTER_UOM_GROUP');

    ELSE


	 IF :New.last_updated_by != 'REPLICATE' THEN -- No trigger logic when replicating code values


	   IF :New.last_updated_by != 'INSTANTIATE' THEN -- do not apply during instantiation

     ----------------------------------------------------------------------------------------------
	   -- perform basic check on consistency between qty and UOM
     IF :New.VOLUME_UOM_CODE IS NULL AND :New.NET_VOLUME_VALUE IS NOT NULL THEN RAISE no_uom; END IF;
     IF :New.MASS_UOM_CODE IS NULL   AND :New.NET_MASS_VALUE   IS NOT NULL THEN RAISE no_uom; END IF;
     IF :New.ENERGY_UOM_CODE IS NULL AND :New.NET_ENERGY_VALUE IS NOT NULL THEN RAISE no_uom; END IF;
     IF :New.EXTRA1_UOM_CODE IS NULL AND :New.NET_EXTRA1_VALUE IS NOT NULL THEN RAISE no_uom; END IF;
     IF :New.EXTRA2_UOM_CODE IS NULL AND :New.NET_EXTRA2_VALUE IS NOT NULL THEN RAISE no_uom; END IF;
     IF :New.EXTRA3_UOM_CODE IS NULL AND :New.NET_EXTRA3_VALUE IS NOT NULL THEN RAISE no_uom; END IF;

	   IF :New.DENSITY IS NOT NULL AND (:New.density_mass_uom IS NULL OR :New.DENSITY_VOLUME_UOM IS NULL) THEN RAISE no_conv_uom; END IF;
	   IF :New.GCV     IS NOT NULL AND (:New.gcv_energy_uom   IS NULL OR :New.GCV_VOLUME_UOM     IS NULL) THEN RAISE no_conv_uom; END IF;
	   IF :New.MCV     IS NOT NULL AND (:New.mcv_energy_uom   IS NULL OR :New.MCV_MASS_UOM       IS NULL) THEN RAISE no_conv_uom; END IF;

     ----------------------------------------------------------------------------------------------
	   -- Apply calc_method logic
	   IF nvl(:Old.CALC_METHOD,ecdp_revn_forecast.getStreamItemAttribute(:new.forecast_id,:new.object_id,:new.daytime,'CALC_METHOD')) = 'DE' AND :New.Created_by != 'PERIOD_GEN' THEN

        -- User has overwritten a number generated from period
        :New.CALC_METHOD := 'OW';
        :New.PERIOD_REF_ITEM := NULL;

     END IF;

     ----------------------------------------------------------------------------------------------
	   -- Find master UOM Group and calculate accruals
	   lv2_master_uom := ecdp_revn_forecast.getStreamItemAttribute(:New.forecast_id, :New.object_id, :New.daytime, 'MASTER_UOM_GROUP');

	   IF lv2_master_uom NOT IN ('V','M','E') OR lv2_master_uom IS NULL THEN RAISE no_valid_master_uom; END IF;

     ----------------------------------------------------------------------------------------------
     -- split share handling
     IF Ecdp_Utilities.isNumberUpdated(:Old.SPLIT_SHARE,:New.SPLIT_SHARE) AND NOT Ecdp_Utilities.isVarcharUpdated(nvl(:Old.CALC_METHOD,ecdp_revn_forecast.getStreamItemAttribute(:new.forecast_id,:new.object_id,:new.daytime,'CALC_METHOD')), nvl(:New.CALC_METHOD,ecdp_revn_forecast.getStreamItemAttribute(:new.forecast_id,:new.object_id,:new.daytime,'CALC_METHOD'))) THEN

	   	  IF :New.SPLIT_SHARE IS NULL THEN RAISE invalid_split_share; END IF;

		    IF nvl(:Old.CALC_METHOD,ecdp_revn_forecast.getStreamItemAttribute(:new.forecast_id,:new.object_id,:new.daytime,'CALC_METHOD')) NOT IN ('SK','EK') THEN RAISE invalid_split_share; END IF;

	      -- change calc method from SK to EK
	      IF nvl(:Old.CALC_METHOD,ecdp_revn_forecast.getStreamItemAttribute(:new.forecast_id,:new.object_id,:new.daytime,'CALC_METHOD')) = 'SK' AND :New.created_by != 'CASCADE' THEN
            :New.calc_method := 'EK';
        END IF;

	   END IF;

     ----------------------------------------------------------------------------------------------
	   -- Apply master UOM Group logic
       IF Nvl(:New.NET_VOLUME_VALUE,-99999) <> Nvl(:Old.NET_VOLUME_VALUE,-99999) OR ( :New.VOLUME_UOM_CODE <> :Old.VOLUME_UOM_CODE AND :New.NET_VOLUME_VALUE IS NOT NULL) THEN

			 -- check if master
  			 IF lv2_master_uom = 'V' THEN

           ib_vol_master := TRUE;

  			 ELSE

				 -- prevent any updates (eccept setting to null) if master is NULL
            IF :New.NET_VOLUME_VALUE IS NOT NULL THEN
  			      IF lv2_master_uom = 'M' AND :New.NET_MASS_VALUE IS NULL THEN RAISE no_master_qty; END IF;
  			      IF lv2_master_uom = 'E' AND :New.NET_ENERGY_VALUE IS NULL THEN RAISE no_master_qty; END IF;
            END IF;

            -- do not blank out conv_factors if si in use in SP
			-- Using NA because Calc method on object will never be OW/SP
            IF nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN

              IF :New.NET_VOLUME_VALUE IS NOT NULL AND :New.NET_MASS_VALUE IS NOT NULL THEN

      			 	 -- do not apply any conversions
      				 :New.density := NULL;
      				 :New.density_mass_uom := NULL;
      				 :New.density_volume_uom := NULL;
      				 :New.density_source_id := NULL;
               END IF;

              IF :New.NET_VOLUME_VALUE IS NOT NULL AND :New.NET_ENERGY_VALUE IS NOT NULL THEN

      				 :New.gcv := NULL;
      				 :New.gcv_energy_uom := NULL;
      				 :New.gcv_volume_uom := NULL;
               :New.gcv_source_id := NULL;

              END IF;

              END IF;

  		     END IF;

           IF nvl(:Old.CALC_METHOD,ecdp_revn_forecast.getStreamItemAttribute(:new.forecast_id,:new.object_id,:new.daytime,'CALC_METHOD')) IN ('SK','EK','FO') AND :New.created_by != 'CASCADE' AND nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN  -- Using NA because Calc method on object will never be OW/SP
              :New.CALC_METHOD := 'OW';
           END IF;

		  END IF;


    ----------------------------------------------------------------------------------------------
	   -- Apply master UOM Group logic
		  IF Nvl(:New.NET_MASS_VALUE,-99999) <> Nvl(:Old.NET_MASS_VALUE,-99999) OR ( :New.MASS_UOM_CODE <> :Old.MASS_UOM_CODE AND :New.NET_MASS_VALUE IS NOT NULL) THEN

			 -- check if master
			 IF lv2_master_uom = 'M'  THEN

           ib_mass_master := TRUE;

        ELSE

				 -- prevent any updates (accept setting to null) if master is NULL
          IF :New.NET_MASS_VALUE IS NOT NULL THEN
  	        IF lv2_master_uom = 'V' AND :New.NET_VOLUME_VALUE IS NULL THEN RAISE no_master_qty; END IF;
  	        IF lv2_master_uom = 'E' AND :New.NET_ENERGY_VALUE IS NULL THEN RAISE no_master_qty; END IF;
          END IF;

          -- do not blank out conv_factors if si in use in SP
	      -- Using NA because Calc method on object will never be OW/SP
          IF nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN

            IF :New.NET_MASS_VALUE IS NOT NULL AND :New.NET_VOLUME_VALUE IS NOT NULL THEN

    			 	 -- do not apply any conversions
    				 :New.density := NULL;
    				 :New.density_mass_uom := NULL;
    				 :New.density_volume_uom := NULL;
      			 :New.density_source_id := NULL;
            END IF;

            IF :New.NET_MASS_VALUE IS NOT NULL AND :New.NET_ENERGY_VALUE IS NOT NULL THEN

    				 :New.mcv := NULL;
    				 :New.mcv_energy_uom := NULL;
    				 :New.mcv_mass_uom := NULL;
      			 :New.mcv_source_id := NULL;

            END IF;

          END IF;

		  	 END IF;

         IF nvl(:Old.CALC_METHOD,ecdp_revn_forecast.getStreamItemAttribute(:new.forecast_id,:new.object_id,:new.daytime,'CALC_METHOD')) IN ('SK','EK','FO') AND :New.created_by != 'CASCADE' AND nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN
              :New.CALC_METHOD := 'OW';
           END IF;

		  END IF;


    ----------------------------------------------------------------------------------------------
	   -- Apply master UOM Group logic
		  IF Nvl(:New.NET_ENERGY_VALUE,-99999) <> Nvl(:Old.NET_ENERGY_VALUE,-99999) OR ( :New.ENERGY_UOM_CODE <> :Old.ENERGY_UOM_CODE AND :New.NET_ENERGY_VALUE IS NOT NULL) THEN

			 -- check if master
			 IF lv2_master_uom = 'E' THEN

           ib_energy_master := TRUE;


			 ELSE

				-- prevent any updates (accept setting to null) if master is NULL
         IF :New.NET_ENERGY_VALUE IS NOT NULL THEN
 			      IF lv2_master_uom = 'M' AND :New.NET_MASS_VALUE IS NULL THEN RAISE no_master_qty; END IF;
  			    IF lv2_master_uom = 'V' AND :New.NET_VOLUME_VALUE IS NULL THEN RAISE no_master_qty; END IF;
         END IF;

         -- do not blank out conv_factors if si in use in SP
		 -- Using NA because Calc method on object will never be OW/SP
         IF nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN

            IF :New.NET_ENERGY_VALUE IS NOT NULL AND :New.NET_VOLUME_VALUE IS NOT NULL THEN

    			 	 -- do not apply any conversions
    				 :New.gcv := NULL;
    				 :New.gcv_energy_uom := NULL;
    				 :New.gcv_volume_uom := NULL;
      			 :New.gcv_source_id := NULL;
            END IF;

            IF :New.NET_ENERGY_VALUE IS NOT NULL AND :New.NET_MASS_VALUE IS NOT NULL THEN

    				 :New.mcv := NULL;
    				 :New.mcv_energy_uom := NULL;
    				 :New.mcv_mass_uom := NULL;
      			 :New.mcv_source_id := NULL;

            END IF;

          END IF;

		  	 END IF;

         IF nvl(:Old.CALC_METHOD,ecdp_revn_forecast.getStreamItemAttribute(:new.forecast_id,:new.object_id,:new.daytime,'CALC_METHOD')) IN ('SK','EK','FO') AND :New.created_by != 'CASCADE' AND nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN
              :New.CALC_METHOD := 'OW';
           END IF;

		  END IF;

     ----------------------------------------------------------------------------------------------
	   -- Apply Extra logic
      IF Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999) OR Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999) OR Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999)  THEN

			 	-- prevent any updates if master is NULL
        -- The initial if-statement was added to be able to reset calculated stream items (ECPD-8897)
         IF :New.NET_EXTRA1_VALUE IS NOT NULL OR :New.NET_EXTRA2_VALUE IS NOT NULL OR :New.NET_EXTRA3_VALUE IS NOT NULL THEN
            IF lv2_master_uom = 'M' AND :New.NET_MASS_VALUE IS NULL THEN RAISE no_master_qty; END IF;
            IF lv2_master_uom = 'V' AND :New.NET_VOLUME_VALUE IS NULL THEN RAISE no_master_qty; END IF;
            IF lv2_master_uom = 'E' AND :New.NET_ENERGY_VALUE IS NULL THEN RAISE no_master_qty; END IF;
          END IF;

		   IF nvl(:Old.CALC_METHOD,ecdp_revn_forecast.getStreamItemAttribute(:new.forecast_id,:new.object_id,:new.daytime,'CALC_METHOD')) IN ('SK','EK','FO') AND :New.created_by != 'CASCADE' AND nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN
              :New.CALC_METHOD := 'OW';
           END IF;

		  END IF;

     ----------------------------------------------------------------------------------------------
	   -- If master was changed, reset other values (must do this after any other processing above)
     -- but only extras if si in use in SP.

      IF  ib_vol_master THEN

  			 	-- delete any previous dependent data
			    -- Using NA because Calc method on object will never be OW/SP
           IF nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN
              IF NOT Nvl(:New.NET_MASS_VALUE,-99999) <> Nvl(:Old.NET_MASS_VALUE,-99999) THEN :New.NET_MASS_VALUE := NULL; END IF;
  				    IF NOT Nvl(:New.NET_ENERGY_VALUE,-99999) <> Nvl(:Old.NET_ENERGY_VALUE,-99999) THEN :New.NET_ENERGY_VALUE := NULL; END IF;
           END IF;

  				 IF NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999) THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
  				 IF NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999) THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
  				 IF NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999) THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

      ELSIF  ib_mass_master THEN

           			 	-- delete any previous dependent data
						-- Using NA because Calc method on object will never be OW/SP
         IF nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN
    				 IF NOT Nvl(:New.NET_VOLUME_VALUE,-99999) <> Nvl(:Old.NET_VOLUME_VALUE,-99999) THEN :New.NET_VOLUME_VALUE := NULL; END IF;
		    		 IF NOT Nvl(:New.NET_ENERGY_VALUE,-99999) <> Nvl(:Old.NET_ENERGY_VALUE,-99999) THEN :New.NET_ENERGY_VALUE := NULL; END IF;
         END IF;

         IF NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999) THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
				 IF NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999) THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
				 IF NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999) THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

      ELSIF  ib_energy_master THEN

  			 	-- delete any previous dependent data
				-- Using NA because Calc method on object will never be OW/SP
           IF nvl(:New.CALC_METHOD,'NA') <> 'SP' THEN
  			      IF NOT Nvl(:New.NET_MASS_VALUE,-99999) <> Nvl(:Old.NET_MASS_VALUE,-99999) THEN :New.NET_MASS_VALUE := NULL; END IF;
				      IF NOT Nvl(:New.NET_VOLUME_VALUE,-99999) <> Nvl(:Old.NET_VOLUME_VALUE,-99999) THEN :New.NET_VOLUME_VALUE := NULL; END IF;
           END IF;

  				 IF NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999) THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
  				 IF NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999) THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
  				 IF NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999) THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

       END IF;

       lv2_extra1_uom_subgroup := ec_ctrl_unit.uom_subgroup(:New.EXTRA1_UOM_CODE);
       lv2_extra2_uom_subgroup := ec_ctrl_unit.uom_subgroup(:New.EXTRA2_UOM_CODE);
       lv2_extra3_uom_subgroup := ec_ctrl_unit.uom_subgroup(:New.EXTRA3_UOM_CODE);
       lv2_energy_uom_subgroup := ec_ctrl_unit.uom_subgroup(:New.ENERGY_UOM_CODE);

     ----------------------------------------------------------------------------------------------
		 -- Apply any consequences of changing conversion factors

     IF Nvl(:New.DENSITY,-99999) <> Nvl(:Old.DENSITY,-99999) OR ( (Nvl(:New.DENSITY_VOLUME_UOM,'XXX') <> Nvl(:Old.DENSITY_VOLUME_UOM,'XXX') OR Nvl(:New.DENSITY_MASS_UOM,'XXX') <> Nvl(:Old.DENSITY_MASS_UOM,'XXX')) AND :New.DENSITY IS NOT NULL ) THEN

       -- need these in subsequent logic
       lv2_extra1_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA1_UOM_CODE);
       lv2_extra2_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA2_UOM_CODE);
       lv2_extra3_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA3_UOM_CODE);

       -- overriding
       -- :New.DENSITY_SOURCE := 'Manual';
       :New.DENSITY_SOURCE_ID := NULL;

  		 -- force recalculation of any dependants
  		 IF lv2_master_uom = 'V' THEN

  		 	-- delete any previous dependent data
  			 IF NOT Nvl(:New.NET_MASS_VALUE,-99999) <> Nvl(:Old.NET_MASS_VALUE,-99999) THEN :New.NET_MASS_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999)) AND lv2_extra1_uom_group IN ('M','V') THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999)) AND lv2_extra2_uom_group IN ('M','V') THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999)) AND lv2_extra3_uom_group IN ('M','V') THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

  		 ELSIF lv2_master_uom = 'M' THEN

  		 	 -- delete any previous dependent data
  			 IF NOT Nvl(:New.NET_VOLUME_VALUE,-99999) <> Nvl(:Old.NET_VOLUME_VALUE,-99999) THEN :New.NET_VOLUME_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999)) AND lv2_extra1_uom_group IN ('M','V') THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999)) AND lv2_extra2_uom_group IN ('M','V') THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999)) AND lv2_extra3_uom_group IN ('M','V') THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

  	   END IF;

     END IF;


       IF Nvl(:New.GCV,-99999) <> Nvl(:Old.GCV,-99999) OR ( (Nvl(:New.GCV_VOLUME_UOM,'XXX') <> Nvl(:Old.GCV_VOLUME_UOM,'XXX') OR Nvl(:New.GCV_ENERGY_UOM,'XXX') <> Nvl(:Old.GCV_ENERGY_UOM,'XXX')) AND :New.GCV IS NOT NULL ) THEN

         -- need these in subsequent logic
         lv2_extra1_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA1_UOM_CODE);
         lv2_extra2_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA2_UOM_CODE);
         lv2_extra3_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA3_UOM_CODE);

         -- overriding
         -- :New.GCV_SOURCE := 'Manual';
         :New.GCV_SOURCE_ID := NULL;

				 -- force recalculation of any dependants
				 IF lv2_master_uom = 'V' THEN

				 	-- delete any previous dependent data
					 IF NOT Nvl(:New.NET_ENERGY_VALUE,-99999) <> Nvl(:Old.NET_ENERGY_VALUE,-99999) THEN :New.NET_ENERGY_VALUE := NULL; END IF;
					 IF (NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999)) AND lv2_extra1_uom_group IN ('E','V') THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
					 IF (NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999)) AND lv2_extra2_uom_group IN ('E','V') THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
					 IF (NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999)) AND lv2_extra3_uom_group IN ('E','V') THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

				 ELSIF lv2_master_uom = 'E' THEN

				 	 -- delete any previous dependent data
					 IF NOT Nvl(:New.NET_VOLUME_VALUE,-99999) <> Nvl(:Old.NET_VOLUME_VALUE,-99999) THEN :New.NET_VOLUME_VALUE := NULL; END IF;
					 IF (NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999)) AND lv2_extra1_uom_group IN ('E','V') THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
					 IF (NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999)) AND lv2_extra2_uom_group IN ('E','V') THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
					 IF (NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999)) AND lv2_extra3_uom_group IN ('E','V') THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

			  END IF;

		END IF;

     IF Nvl(:New.MCV,-99999) <> Nvl(:Old.MCV,-99999) OR ( (Nvl(:New.MCV_MASS_UOM,'XXX') <> Nvl(:Old.MCV_MASS_UOM,'XXX') OR Nvl(:New.MCV_ENERGY_UOM,'XXX') <> Nvl(:Old.MCV_ENERGY_UOM,'XXX')) AND :New.MCV IS NOT NULL ) THEN

       -- need these in subsequent logic
       lv2_extra1_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA1_UOM_CODE);
       lv2_extra2_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA2_UOM_CODE);
       lv2_extra3_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA3_UOM_CODE);

         -- overriding
         -- :New.MCV_SOURCE := 'Manual';
         :New.MCV_SOURCE_ID := NULL;

  		 -- force recalculation of any dependants
  		 IF lv2_master_uom = 'M' THEN

  		 	-- delete any previous dependent data
  			 IF NOT Nvl(:New.NET_ENERGY_VALUE,-99999) <> Nvl(:Old.NET_ENERGY_VALUE,-99999) THEN :New.NET_ENERGY_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999)) AND lv2_extra1_uom_group IN ('E','M') THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999)) AND lv2_extra2_uom_group IN ('E','M') THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999)) AND lv2_extra3_uom_group IN ('E','M') THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

  		 ELSIF lv2_master_uom = 'E' THEN

  		 	 -- delete any previous dependent data
  			 IF NOT Nvl(:New.NET_MASS_VALUE,-99999) <> Nvl(:Old.NET_MASS_VALUE,-99999) THEN :New.NET_MASS_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999)) AND lv2_extra1_uom_group IN ('E','M') THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999)) AND lv2_extra2_uom_group IN ('E','M') THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
  			 IF (NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999)) AND lv2_extra3_uom_group IN ('E','M') THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

  	   END IF;

		  END IF;


      IF (Nvl(:New.BOE_FACTOR,-99999) <> Nvl(:Old.BOE_FACTOR,-99999)
      OR  Nvl(:New.BOE_FROM_UOM_CODE,'XXX') <> Nvl(:Old.BOE_FROM_UOM_CODE,'XXX'))
      AND :New.BOE_FACTOR IS NOT NULL THEN


          :New.BOE_SOURCE_ID := NULL; -- 'Manual'


       -- force recalculation of any dependants
         IF (NOT Nvl(:New.NET_EXTRA1_VALUE,-99999) <> Nvl(:Old.NET_EXTRA1_VALUE,-99999)) AND lv2_extra1_uom_subgroup IN ('BE') THEN :New.NET_EXTRA1_VALUE := NULL; END IF;
         IF (NOT Nvl(:New.NET_EXTRA2_VALUE,-99999) <> Nvl(:Old.NET_EXTRA2_VALUE,-99999)) AND lv2_extra2_uom_subgroup IN ('BE') THEN :New.NET_EXTRA2_VALUE := NULL; END IF;
         IF (NOT Nvl(:New.NET_EXTRA3_VALUE,-99999) <> Nvl(:Old.NET_EXTRA3_VALUE,-99999)) AND lv2_extra3_uom_subgroup IN ('BE') THEN :New.NET_EXTRA3_VALUE := NULL; END IF;

      END IF;

		  -- Across calculation - calculate UOM Group dependents from master
      -- This is only applied to stream items that use conversion_method CONVERSION_FACTOR
      -- Otherwise the calulation is done downwards by the cascade logic
      -- For EXTRAn values this rule does not apply.
      lv2_conversion_method := ec_stream_item_version.conversion_method(:new.object_id,:new.daytime,'<=');

      IF lv2_conversion_method = 'CALCULATED' THEN
         NULL;
      ELSE

		  IF :New.NET_VOLUME_VALUE IS NULL AND :New.VOLUME_UOM_CODE IS NOT NULL THEN

           BEGIN

             IF lv2_master_uom = 'M' AND :New.DENSITY IS NOT NULL THEN
              :New.NET_VOLUME_VALUE := EcDp_Revn_Unit.convertValue(EcDp_Revn_Unit.convertValue(:New.NET_MASS_VALUE,:New.MASS_UOM_CODE, :New.DENSITY_MASS_UOM, :New.object_id, :New.daytime) / :New.DENSITY, :New.DENSITY_VOLUME_UOM, :New.VOLUME_UOM_CODE, :New.object_id, :New.daytime);
             ELSIF lv2_master_uom = 'E' AND :New.GCV IS NOT NULL THEN
              :New.NET_VOLUME_VALUE := EcDp_Revn_Unit.convertValue(EcDp_Revn_Unit.convertValue(:New.NET_ENERGY_VALUE,:New.ENERGY_UOM_CODE, :New.GCV_ENERGY_UOM, :New.object_id, :New.daytime) / :New.GCV, :New.GCV_VOLUME_UOM, :New.VOLUME_UOM_CODE, :New.object_id, :New.daytime);
             END IF;

         EXCEPTION

          WHEN ZERO_DIVIDE THEN

             :New.NET_VOLUME_VALUE := NULL; -- unknown

         END;

		  END IF;


		  IF :New.NET_MASS_VALUE IS NULL AND :New.MASS_UOM_CODE IS NOT NULL THEN

         BEGIN

           IF lv2_master_uom = 'V' AND :New.DENSITY IS NOT NULL THEN
            :New.NET_MASS_VALUE := EcDp_Revn_Unit.convertValue(EcDp_Revn_Unit.convertValue(:New.NET_VOLUME_VALUE,:New.VOLUME_UOM_CODE, :New.DENSITY_VOLUME_UOM, :New.object_id, :New.daytime) * :New.DENSITY, :New.DENSITY_MASS_UOM, :New.MASS_UOM_CODE, :New.object_id, :New.daytime);
           ELSIF lv2_master_uom = 'E' AND :New.MCV IS NOT NULL THEN
            :New.NET_MASS_VALUE := EcDp_Revn_Unit.convertValue(EcDp_Revn_Unit.convertValue(:New.NET_ENERGY_VALUE,:New.ENERGY_UOM_CODE, :New.MCV_ENERGY_UOM, :New.object_id, :New.daytime) / :New.MCV, :New.MCV_MASS_UOM, :New.MASS_UOM_CODE, :New.object_id, :New.daytime);
           END IF;


         EXCEPTION

          WHEN ZERO_DIVIDE THEN

             :New.NET_MASS_VALUE := NULL; -- unknown

         END;


		  END IF;


		  IF :New.NET_ENERGY_VALUE IS NULL AND :New.ENERGY_UOM_CODE IS NOT NULL THEN

         BEGIN

          -- Pending BOE Conversion
          IF lv2_energy_uom_subgroup = 'BE' THEN
              :New.NET_ENERGY_VALUE := NULL;
           ELSE

             IF lv2_master_uom = 'V' AND :New.GCV IS NOT NULL THEN
              :New.NET_ENERGY_VALUE := EcDp_Revn_Unit.convertValue(EcDp_Revn_Unit.convertValue(:New.NET_VOLUME_VALUE,:New.VOLUME_UOM_CODE, :New.GCV_VOLUME_UOM, :New.object_id, :New.daytime) * :New.GCV, :New.GCV_ENERGY_UOM, :New.ENERGY_UOM_CODE, :New.object_id, :New.daytime);
             ELSIF lv2_master_uom = 'M' AND :New.MCV IS NOT NULL THEN
              :New.NET_ENERGY_VALUE := EcDp_Revn_Unit.convertValue(EcDp_Revn_Unit.convertValue(:New.NET_MASS_VALUE,:New.MASS_UOM_CODE, :New.MCV_MASS_UOM, :New.object_id, :New.daytime) * :New.MCV, :New.MCV_ENERGY_UOM, :New.ENERGY_UOM_CODE, :New.object_id, :New.daytime);
             END IF;
           END IF;

         EXCEPTION

          WHEN ZERO_DIVIDE THEN

             :New.NET_ENERGY_VALUE := NULL; -- unknown

         END;

		  END IF;

		  -- calculate any extra fields from same UOM Group
		  IF :New.NET_EXTRA1_VALUE IS NULL AND :New.EXTRA1_UOM_CODE IS NOT NULL THEN

		 	lv2_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA1_UOM_CODE);
		  	IF lv2_uom_group NOT IN ('V','M','E') OR lv2_uom_group IS NULL THEN RAISE no_valid_extra_uom; END IF;

          -- Pending BOE Conversion
          IF lv2_extra1_uom_subgroup = 'BE' THEN
              :New.NET_EXTRA1_VALUE := NULL;
           ELSE

            IF lv2_uom_group = 'V' THEN
               :New.NET_EXTRA1_VALUE := EcDp_Revn_Unit.convertValue(:New.NET_VOLUME_VALUE,:New.VOLUME_UOM_CODE,:New.EXTRA1_UOM_CODE, :New.object_id, :New.DAYTIME);
            ELSIF lv2_uom_group = 'M' THEN
               :New.NET_EXTRA1_VALUE := EcDp_Revn_Unit.convertValue(:New.NET_MASS_VALUE,:New.MASS_UOM_CODE,:New.EXTRA1_UOM_CODE, :New.object_id, :New.DAYTIME);
            ELSE
                 IF lv2_energy_uom_subgroup = 'BE' THEN
                    :New.NET_EXTRA1_VALUE := NULL;
                  ELSE
                 :New.NET_EXTRA1_VALUE := EcDp_Revn_Unit.convertValue(:New.NET_ENERGY_VALUE,:New.ENERGY_UOM_CODE,:New.EXTRA1_UOM_CODE, :New.object_id, :New.DAYTIME);
                 END IF;
            END IF;
          END IF;

		   END IF;

		  IF :New.NET_EXTRA2_VALUE IS NULL AND :New.EXTRA2_UOM_CODE IS NOT NULL THEN

		 	lv2_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA2_UOM_CODE);
		  	IF lv2_uom_group NOT IN ('V','M','E') OR lv2_uom_group IS NULL THEN RAISE no_valid_extra_uom; END IF;

            -- Pending BOE Conversion
            IF lv2_extra2_uom_subgroup = 'BE' THEN
                :New.NET_EXTRA2_VALUE := NULL;
             ELSE
              IF lv2_uom_group = 'V' THEN
                     :New.NET_EXTRA2_VALUE := EcDp_Revn_Unit.convertValue(:New.NET_VOLUME_VALUE,:New.VOLUME_UOM_CODE,:New.EXTRA2_UOM_CODE, :New.object_id, :New.DAYTIME);
              ELSIF lv2_uom_group = 'M' THEN
               :New.NET_EXTRA2_VALUE := EcDp_Revn_Unit.convertValue(:New.NET_MASS_VALUE,:New.MASS_UOM_CODE,:New.EXTRA2_UOM_CODE, :New.object_id, :New.DAYTIME);
            ELSE
                IF lv2_energy_uom_subgroup = 'BE' THEN
                     :New.NET_EXTRA2_VALUE := NULL;
                ELSE
                   :New.NET_EXTRA2_VALUE := EcDp_Revn_Unit.convertValue(:New.NET_ENERGY_VALUE,:New.ENERGY_UOM_CODE,:New.EXTRA2_UOM_CODE, :New.object_id, :New.DAYTIME);
                END IF;
            END IF;

          END IF;
		   END IF;

		   IF :New.NET_EXTRA3_VALUE IS NULL AND :New.EXTRA3_UOM_CODE IS NOT NULL THEN
		 	lv2_uom_group := EcDp_Unit.GetUOMGroup(:New.EXTRA3_UOM_CODE);

		  	IF lv2_uom_group NOT IN ('V','M','E') OR lv2_uom_group IS NULL THEN RAISE no_valid_extra_uom; END IF;


        -- Pending BOE Conversion
        IF lv2_extra3_uom_subgroup = 'BE' THEN
            :New.NET_EXTRA3_VALUE := NULL;
         ELSE

          IF lv2_uom_group = 'V' THEN
               :New.NET_EXTRA3_VALUE := EcDp_Revn_Unit.convertValue(:New.NET_VOLUME_VALUE,:New.VOLUME_UOM_CODE,:New.EXTRA3_UOM_CODE, :New.object_id, :New.DAYTIME);
          ELSIF lv2_uom_group = 'M' THEN
           :New.NET_EXTRA3_VALUE := EcDp_Revn_Unit.convertValue(:New.NET_MASS_VALUE,:New.MASS_UOM_CODE,:New.EXTRA3_UOM_CODE, :New.object_id, :New.DAYTIME);
            ELSE
                IF lv2_energy_uom_subgroup = 'BE' THEN
                   :New.NET_EXTRA3_VALUE := NULL;
                 ELSE
               :New.NET_EXTRA3_VALUE := EcDp_Revn_Unit.convertValue(:New.NET_ENERGY_VALUE,:New.ENERGY_UOM_CODE,:New.EXTRA3_UOM_CODE, :New.object_id, :New.DAYTIME);
               END IF;
            END IF;
          END IF;
		   END IF;
    END IF;


     -- Applying BOE conversion
    IF :New.NET_ENERGY_VALUE IS NULL AND :New.ENERGY_UOM_CODE IS NOT NULL THEN

      IF lv2_energy_uom_subgroup = 'BE' THEN
                :New.NET_ENERGY_VALUE := ecdp_stream_item.getboestimvalue(:new.object_id,
                                                                          :new.daytime,
                                                                          :new.net_volume_value,
                                                                          :new.volume_uom_code,
                                                                          :new.net_mass_value,
                                                                          :new.mass_uom_code,
                                                                          :new.net_energy_value,
                                                                          :new.energy_uom_code,
                                                                          :new.net_extra1_value,
                                                                          :new.extra1_uom_code,
                                                                          :new.net_extra2_value,
                                                                          :new.extra2_uom_code,
                                                                          :new.net_extra3_value,
                                                                          :new.extra3_uom_code,
                                                                          :new.boe_from_uom_code,
                                                                          :new.energy_uom_code,
                                                                          :new.boe_factor);
      END IF;
    END IF;


    IF :New.NET_EXTRA1_VALUE IS NULL AND :New.EXTRA1_UOM_CODE IS NOT NULL THEN
      IF lv2_extra1_uom_subgroup = 'BE' THEN
                :New.NET_EXTRA1_VALUE := ecdp_stream_item.getboestimvalue(:new.object_id,
                                                                          :new.daytime,
                                                                          :new.net_volume_value,
                                                                          :new.volume_uom_code,
                                                                          :new.net_mass_value,
                                                                          :new.mass_uom_code,
                                                                          :new.net_energy_value,
                                                                          :new.energy_uom_code,
                                                                          :new.net_extra1_value,
                                                                          :new.extra1_uom_code,
                                                                          :new.net_extra2_value,
                                                                          :new.extra2_uom_code,
                                                                          :new.net_extra3_value,
                                                                          :new.extra3_uom_code,
                                                                          :new.boe_from_uom_code,
                                                                          :new.extra1_uom_code,
                                                                          :new.boe_factor);
      END IF;
    END IF;

    IF :New.NET_EXTRA2_VALUE IS NULL AND :New.EXTRA2_UOM_CODE IS NOT NULL THEN
      IF lv2_extra2_uom_subgroup = 'BE' THEN
                :New.NET_EXTRA2_VALUE := ecdp_stream_item.getboestimvalue(:new.object_id,
                                                                          :new.daytime,
                                                                          :new.net_volume_value,
                                                                          :new.volume_uom_code,
                                                                          :new.net_mass_value,
                                                                          :new.mass_uom_code,
                                                                          :new.net_energy_value,
                                                                          :new.energy_uom_code,
                                                                          :new.net_extra1_value,
                                                                          :new.extra1_uom_code,
                                                                          :new.net_extra2_value,
                                                                          :new.extra2_uom_code,
                                                                          :new.net_extra3_value,
                                                                          :new.extra3_uom_code,
                                                                          :new.boe_from_uom_code,
                                                                          :new.extra2_uom_code,
                                                                          :new.boe_factor);
      END IF;
    END IF;

    IF :New.NET_EXTRA3_VALUE IS NULL AND :New.EXTRA3_UOM_CODE IS NOT NULL THEN

      IF lv2_extra3_uom_subgroup = 'BE' THEN
                :New.NET_EXTRA3_VALUE := ecdp_stream_item.getboestimvalue(:new.object_id,
                                                                          :new.daytime,
                                                                          :new.net_volume_value,
                                                                          :new.volume_uom_code,
                                                                          :new.net_mass_value,
                                                                          :new.mass_uom_code,
                                                                          :new.net_energy_value,
                                                                          :new.energy_uom_code,
                                                                          :new.net_extra1_value,
                                                                          :new.extra1_uom_code,
                                                                          :new.net_extra2_value,
                                                                          :new.extra2_uom_code,
                                                                          :new.net_extra3_value,
                                                                          :new.extra3_uom_code,
                                                                          :new.boe_from_uom_code,
                                                                          :new.extra3_uom_code,
                                                                          :new.boe_factor);
      END IF;
    END IF;



    -- Applying across logic to stream items having master UOM in BE sub-group (BOE Volumes)
    IF lv2_master_uom = 'E' AND lv2_energy_uom_subgroup = 'BE' THEN

        IF :New.NET_MASS_VALUE IS NULL AND :New.MASS_UOM_CODE IS NOT NULL THEN

            :New.NET_MASS_VALUE := ecdp_stream_item.getBOEInvertUnitValue(:new.object_id,
                                                                      :new.daytime,
                                                                      :new.net_energy_value,
                                                                      :new.mass_uom_code,
                                                                      :new.boe_from_uom_code,
                                                                      :new.energy_uom_code,
                                                                      :new.boe_factor);

        END IF;

        IF :New.NET_VOLUME_VALUE IS NULL AND :New.VOLUME_UOM_CODE IS NOT NULL THEN


            :New.NET_VOLUME_VALUE := ecdp_stream_item.getBOEInvertUnitValue(:new.object_id,
                                                                      :new.daytime,
                                                                      :new.net_energy_value,
                                                                      :new.energy_uom_code,
                                                                      :new.boe_from_uom_code,
                                                                      :new.energy_uom_code,
                                                                      :new.boe_factor);


        END IF;

        IF :New.NET_EXTRA1_VALUE IS NULL AND :New.EXTRA1_UOM_CODE IS NOT NULL THEN

            :New.NET_EXTRA1_VALUE := ecdp_stream_item.getBOEInvertUnitValue(:new.object_id,
                                                                        :new.daytime,
                                                                        :new.net_energy_value,
                                                                        :new.extra1_uom_code,
                                                                        :new.boe_from_uom_code,
                                                                        :new.energy_uom_code,
                                                                        :new.boe_factor);

        END IF;

        IF :New.NET_EXTRA2_VALUE IS NULL AND :New.EXTRA2_UOM_CODE IS NOT NULL THEN

            :New.NET_EXTRA2_VALUE := ecdp_stream_item.getBOEInvertUnitValue(:new.object_id,
                                                                        :new.daytime,
                                                                        :new.net_energy_value,
                                                                        :new.extra2_uom_code,
                                                                        :new.boe_from_uom_code,
                                                                        :new.energy_uom_code,
                                                                        :new.boe_factor);

        END IF;

        IF :New.NET_EXTRA3_VALUE IS NULL AND :New.EXTRA3_UOM_CODE IS NOT NULL THEN

            :New.NET_EXTRA3_VALUE := ecdp_stream_item.getBOEInvertUnitValue(:new.object_id,
                                                                        :new.daytime,
                                                                        :new.net_energy_value,
                                                                        :new.extra3_uom_code,
                                                                        :new.boe_from_uom_code,
                                                                        :new.energy_uom_code,
                                                                        :new.boe_factor);

        END IF;


    END IF;

       -- Only set the status to final if any of the "numbers" are updated
       IF (:New.NET_VOLUME_VALUE IS NOT NULL OR
           :New.NET_MASS_VALUE   IS NOT NULL OR
           :New.NET_ENERGY_VALUE IS NOT NULL OR
           :New.NET_EXTRA1_VALUE IS NOT NULL OR
           :New.NET_EXTRA2_VALUE IS NOT NULL OR
           :New.NET_EXTRA3_VALUE IS NOT NULL) THEN
             ----------------------------------------------------------------------------------------------
             -- set status to default '(FINAL) if missing
             IF :New.STATUS IS NULL THEN :New.STATUS := 'FINAL'; END IF;
       END IF;

	   END IF; -- end not instantiate user

    ELSE -- :New.last_updated_by = 'REPLICATE'

       :New.last_updated_by := :Old.last_updated_by; -- set to old, do not want to change this when replicating code values

    END IF; -- :New.last_updated_by != 'REPLICATE'

     -- TODO: Put on class....
  	 IF :Old.last_updated_by != 'INSTANTIATE' AND :New.last_updated_by != 'SYSTEM' THEN
        :new.rev_no := :old.rev_no + 1;
     END IF;

     IF UPDATING('CREATED_BY') THEN
       :new.created_by := :old.created_by; -- avoid any effects of application usage of this field
     END IF;

     IF NOT UPDATING('LAST_UPDATED_BY') THEN
       :new.last_updated_by := COALESCE(SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER'),USER);
     END IF;

       :new.last_updated_date := Ecdp_Timestamp.getCurrentSysdate;

    END IF;

-- Trigger of FCST update
  IF (:New.created_by = 'CASCADE' OR :New.created_by = 'INSTANTIATE') THEN
      -- Do Nothing if created_by = INTERNAL, only set id back to old
      IF (:Old.created_by IS NOT NULL) THEN
          :New.created_by := :Old.created_by;
      END IF;
  END IF; -- created by

  IF (:New.last_updated_by NOT IN ('INTERNAL','INSTANTIATE')) THEN

    IF (:New.MASTER_UOM_GROUP = 'M') THEN -- Mass update

        IF (Updating('NET_MASS_VALUE') OR Updating('MASS_UOM_CODE')) THEN
            FOR curMemberM IN c_member LOOP
                lv2_member_no := curMemberM.member_no;
            END LOOP;

            UPDATE fcst_mth_status t
               SET t.net_qty         = ecdp_unit.convertValue(:New.NET_MASS_VALUE,
                                                              :New.MASS_UOM_CODE,
                                                              t.uom,
                                                              :New.DAYTIME),
                   t.last_updated_by = 'INTERNAL'
             WHERE t.object_id = :New.forecast_id
               AND t.daytime = :New.daytime
               AND t.member_no = lv2_member_no
               AND t.record_status NOT IN ('V', 'A');

        END IF;

    ELSIF (:New.MASTER_UOM_GROUP = 'V') THEN -- Volume update

        IF (Updating('NET_VOLUME_VALUE') OR Updating('VOLUME_UOM_CODE')) THEN
            FOR curMemberV IN c_member LOOP
                lv2_member_no := curMemberV.member_no;
            END LOOP;

            UPDATE fcst_mth_status t
               SET t.net_qty         = ecdp_unit.convertValue(:New.NET_VOLUME_VALUE,
                                                              :New.VOLUME_UOM_CODE,
                                                              t.uom,
                                                              :New.DAYTIME),
                   t.last_updated_by = 'INTERNAL'
             WHERE object_id = :New.forecast_id
               AND t.daytime = :New.daytime
               AND t.member_no = lv2_member_no
               AND t.record_status NOT IN ('V', 'A');

        END IF;

    ELSIF (:New.MASTER_UOM_GROUP = 'E') THEN -- Energy update

        IF (Updating('NET_ENERGY_VALUE') OR Updating('ENERGY_UOM_CODE')) THEN
            FOR curMemberE IN c_member LOOP
                lv2_member_no := curMemberE.member_no;
            END LOOP;

            UPDATE fcst_mth_status t
               SET t.net_qty         = ecdp_unit.convertValue(:New.NET_ENERGY_VALUE,
                                                              :New.ENERGY_UOM_CODE,
                                                              t.uom,
                                                              :New.DAYTIME),
                   t.last_updated_by = 'INTERNAL'
             WHERE object_id = :New.forecast_id
               AND t.daytime = :New.daytime
               AND t.member_no = lv2_member_no
               AND t.record_status NOT IN ('V', 'A');

        END IF;

    END IF; -- Master UOM Group
  END IF; -- last_updated_by

EXCEPTION

		 WHEN no_uom THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'One or more quantity fields have no UOM for stream item: ' || Nvl( ec_stream_item.object_code(:New.object_id), ' ') || '    ' || Nvl( Ec_Stream_Item_version.name(:New.object_id,:New.Daytime), ' ')  ) ;

		 WHEN no_conv_uom THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'One or more conversion factors have no UOM for stream item: ' || Nvl( ec_stream_item.object_code(:New.object_id), ' ') || '    ' || Nvl( Ec_Stream_Item_version.name(:New.object_id,:New.Daytime), ' ')  ) ;

		 WHEN no_valid_master_uom THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'No valid UOM master for stream item: '|| Nvl( ec_stream_item.object_code(:New.object_id), ' ') || '    ' || Nvl( Ec_Stream_Item_version.name(:New.object_id,:New.Daytime), ' ')  ) ;

		 WHEN no_valid_extra_uom THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'One or more of the Extra fields are not associated with a valid UOM group for stream item: ' || Nvl( ec_stream_item.object_code(:New.object_id), ' ') || '    ' || Nvl( Ec_Stream_Item_version.name(:New.object_id,:New.Daytime), ' ')  ) ;

		 WHEN no_master_qty THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'One or more quantity fields have no master quantity for stream item: '|| Nvl( ec_stream_item.object_code(:New.object_id), ' ') || '    ' || Nvl( Ec_Stream_Item_version.name(:New.object_id,:New.Daytime), ' ')  ) ;

		 WHEN invalid_split_share THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Not a valid split share for stream item: '|| Nvl( ec_stream_item.object_code(:New.object_id), ' ') || '    ' || Nvl( Ec_Stream_Item_version.name(:New.object_id,:New.Daytime), ' ')  ) ;

END;
