CREATE OR REPLACE PACKAGE BODY EcDp_EcIsHelper IS
/****************************************************************
** Package        :  EcDp_EcIsHelper, header part
**
** $Revision: 1.1.30.1 $
**
** Purpose        :  Support functions for ECIS Config
**
** Documentation  :  www.energy-components.com
**
** Created  : 21.07.2009  Arild Vervik
**
** Modification history:
**
** Date        Whom  	Change description:
** ------      ----- 	-----------------------------------
** 21.07.2009  AV   	Initial version
*****************************************************************/




--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getPKObjectid
-- Description    : Returns object_id if configured in one of th PK columns
--
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
---------------------------------------------------------------------------------------------------
FUNCTION getPKObjectid(p_pk_attr_1 VARCHAR2,
                       p_pk_val_1  VARCHAR2,
                       p_pk_attr_2 VARCHAR2,
                       p_pk_val_2  VARCHAR2,
                       p_pk_attr_3 VARCHAR2,
                       p_pk_val_3  VARCHAR2,
                       p_pk_attr_4 VARCHAR2,
                       p_pk_val_4  VARCHAR2,
                       p_pk_attr_5 VARCHAR2,
                       p_pk_val_5  VARCHAR2,
                       p_pk_attr_6 VARCHAR2,
                       p_pk_val_6  VARCHAR2,
                       p_pk_attr_7 VARCHAR2,
                       p_pk_val_7  VARCHAR2,
                       p_pk_attr_8 VARCHAR2,
                       p_pk_val_8  VARCHAR2,
                       p_pk_attr_9 VARCHAR2,
                       p_pk_val_9  VARCHAR2,
                       p_pk_attr_10 VARCHAR2,
                       p_pk_val_10  VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>
IS
  lv2_object_id Trans_Mapping.pk_val_1%TYPE := NULL;

BEGIN


  IF LTRIM(RTRIM(UPPER(p_pk_attr_1))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_1;

  ELSIF LTRIM(RTRIM(UPPER(p_pk_attr_2))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_2;

  ELSIF LTRIM(RTRIM(UPPER(p_pk_attr_3))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_3;

  ELSIF LTRIM(RTRIM(UPPER(p_pk_attr_4))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_4;

  ELSIF LTRIM(RTRIM(UPPER(p_pk_attr_5))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_5;

  ELSIF LTRIM(RTRIM(UPPER(p_pk_attr_6))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_6;

  ELSIF LTRIM(RTRIM(UPPER(p_pk_attr_7))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_7;

  ELSIF LTRIM(RTRIM(UPPER(p_pk_attr_8))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_8;

  ELSIF LTRIM(RTRIM(UPPER(p_pk_attr_9))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_9;

  ELSIF LTRIM(RTRIM(UPPER(p_pk_attr_10))) = 'OBJECT_ID' THEN

    lv2_object_id := p_pk_val_10;
  END IF;

  RETURN lv2_object_id;

END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getProdDayIdFromTagid
-- Description    : Returns the Production day for an ECIS Tag mapping.
--
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
-- Behaviour      : Not straith forward, need to scan generic PK config for mapping
--                  Find an object_id reference and then check if object or parent have
--                  a link to a production day.
--                  If yes return the production day object.
---------------------------------------------------------------------------------------------------
FUNCTION getProdDayIdFromTagid(p_source_id VARCHAR2,
                              p_tag_id    VARCHAR2,
                              p_pk_attr_1 VARCHAR2 DEFAULT NULL,
                              p_pk_val_1  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_2 VARCHAR2 DEFAULT NULL,
                              p_pk_val_2  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_3 VARCHAR2 DEFAULT NULL,
                              p_pk_val_3  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_4 VARCHAR2 DEFAULT NULL,
                              p_pk_val_4  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_5 VARCHAR2 DEFAULT NULL,
                              p_pk_val_5  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_6 VARCHAR2 DEFAULT NULL,
                              p_pk_val_6  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_7 VARCHAR2 DEFAULT NULL,
                              p_pk_val_7  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_8 VARCHAR2 DEFAULT NULL,
                              p_pk_val_8  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_9 VARCHAR2 DEFAULT NULL,
                              p_pk_val_9  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_10 VARCHAR2 DEFAULT NULL,
                              p_pk_val_10  VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

  CURSOR c_mapping IS
  SELECT * FROM trans_mapping
  WHERE source_id = p_source_id
  AND   tag_id = p_tag_id;

  lv2_object_id   trans_mapping.pk_val_1%TYPE;
  lv2_prodday_id  production_day.object_id%TYPE := NULL;
  ld_daytime      DATE;

BEGIN

  -- Find if pk values is set, if not we need to look them up
  -- Then see if we can find the object_id of the owner object.

  IF p_pk_val_1 IS NULL AND p_pk_val_2 IS NULL THEN

    FOR cm IN c_mapping LOOP

      lv2_object_id := getPKObjectid(cm.pk_attr_1,cm.pk_val_1,cm.pk_attr_2, cm.pk_val_2,cm.pk_attr_3,cm.pk_val_3,
                                     cm.pk_attr_4,cm.pk_val_4,cm.pk_attr_5,cm.pk_val_5,cm.pk_attr_6,cm.pk_val_6,
									 cm.pk_attr_7,cm.pk_val_7,cm.pk_attr_8,cm.pk_val_8,cm.pk_attr_9,cm.pk_val_9,
									 cm.pk_attr_10,cm.pk_val_10);

    END LOOP;


  ELSE


    lv2_object_id := getPKObjectid(p_pk_attr_1,p_pk_val_1,p_pk_attr_2, p_pk_val_2,p_pk_attr_3,p_pk_val_3,
                                   p_pk_attr_4,p_pk_val_4,p_pk_attr_5,p_pk_val_5,p_pk_attr_6,p_pk_val_6,
                                   p_pk_attr_7,p_pk_val_7,p_pk_attr_8,p_pk_val_8,p_pk_attr_9,p_pk_val_9,
                                   p_pk_attr_10,p_pk_val_10);

  END IF;

  IF lv2_object_id IS NOT NULL THEN

    -- NOTYET  Handle that an object can belong to different production days over time.
    ld_daytime := Ecdp_Objects.GetObjStartDate(lv2_object_id);
    lv2_prodday_id := EcDp_productionday.findProductionDayDefinition(NULL, lv2_object_id,ld_daytime);

  END IF;

  RETURN lv2_prodday_id;


END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : getTZRegionFromTagid
-- Description    : Returns the time zone for an ECIS Tag mapping.
--
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
-- Behaviour      : Not straith forward, need to scan generic PK config for mapping
--                  Find an object_id reference and then find the type of the object,
--                  then check if object or parent have a link to a production day
--                  If yes return the time zone region for that Production day, if none can be
--                  found return the schema default time zone.
---------------------------------------------------------------------------------------------------
FUNCTION getTZRegionFromTagid(p_source_id VARCHAR2,
                              p_tag_id    VARCHAR2,
                              p_pk_attr_1 VARCHAR2 DEFAULT NULL,
                              p_pk_val_1  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_2 VARCHAR2 DEFAULT NULL,
                              p_pk_val_2  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_3 VARCHAR2 DEFAULT NULL,
                              p_pk_val_3  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_4 VARCHAR2 DEFAULT NULL,
                              p_pk_val_4  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_5 VARCHAR2 DEFAULT NULL,
                              p_pk_val_5  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_6 VARCHAR2 DEFAULT NULL,
                              p_pk_val_6  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_7 VARCHAR2 DEFAULT NULL,
                              p_pk_val_7  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_8 VARCHAR2 DEFAULT NULL,
                              p_pk_val_8  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_9 VARCHAR2 DEFAULT NULL,
                              p_pk_val_9  VARCHAR2 DEFAULT NULL,
                              p_pk_attr_10 VARCHAR2 DEFAULT NULL,
                              p_pk_val_10  VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
--</EC-DOC>
IS

  CURSOR c_preferanse IS
  SELECT pref_verdi FROM t_preferanse
  WHERE pref_id = 'TIME_ZONE_REGION';

  lv2_object_id   trans_mapping.pk_val_1%TYPE;
  lv2_prodday_id  production_day.object_id%TYPE;
  lv2_TZRegion    PRODUCTION_DAY_VERSION.TIME_ZONE_REGION%TYPE := NULL;
  ld_daytime      DATE;

BEGIN


  lv2_prodday_id := getProdDayIdFromTagid(p_source_id, p_tag_id,p_pk_attr_1,p_pk_val_1,p_pk_attr_2,p_pk_val_2,
                                          p_pk_attr_3,p_pk_val_3,p_pk_attr_4,p_pk_val_4,p_pk_attr_5,p_pk_val_5,
										  p_pk_attr_6,p_pk_val_6,p_pk_attr_7,p_pk_val_7,p_pk_attr_8,p_pk_val_8,
										  p_pk_attr_9,p_pk_val_9,p_pk_attr_10,p_pk_val_10);

  IF lv2_prodday_id IS NOT NULL THEN
       -- NOTYET  Handle that a production day can have different timezones over time.
       ld_daytime := ec_production_day.start_date(lv2_prodday_id);
       lv2_TZRegion := ec_PRODUCTION_DAY_VERSION.TIME_ZONE_REGION(lv2_prodday_id,ld_daytime);
  END IF;

  IF lv2_TZRegion IS NULL THEN

    FOR cp IN c_preferanse LOOP

      lv2_TZRegion := cp.pref_verdi;

    END LOOP;

  END IF;

  RETURN lv2_TZRegion;


END;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : calcnextread
-- Description    : Calculate the next read in UTC based on Last transfer in local time,
--                  Offset for production day, and timezone.
--
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
-- Behaviour      : This function is not very consistent, because it is using external production day
--                  from trhe transaction_template, and then it will try to find a production day object
--                  where it only will use the assosiated time zone.
--                  The reason for this is not make more waves then necessary if someone have used the
--                  trans_template.prod_day_start differently from the assosiated production day object.
---------------------------------------------------------------------------------------------------
FUNCTION calcnextread(p_source_id VARCHAR2,
                      p_tag_id    VARCHAR2,
                      p_pk_attr_1 VARCHAR2,
                      p_pk_val_1  VARCHAR2,
                      p_pk_attr_2 VARCHAR2,
                      p_pk_val_2  VARCHAR2,
                      p_pk_attr_3 VARCHAR2,
                      p_pk_val_3  VARCHAR2,
                      p_pk_attr_4 VARCHAR2,
                      p_pk_val_4  VARCHAR2,
                      p_pk_attr_5 VARCHAR2,
                      p_pk_val_5  VARCHAR2,
					  p_pk_attr_6 VARCHAR2,
					  p_pk_val_6  VARCHAR2,
					  p_pk_attr_7 VARCHAR2,
					  p_pk_val_7  VARCHAR2,
					  p_pk_attr_8 VARCHAR2,
					  p_pk_val_8  VARCHAR2,
					  p_pk_attr_9 VARCHAR2,
					  p_pk_val_9  VARCHAR2,
					  p_pk_attr_10 VARCHAR2,
					  p_pk_val_10  VARCHAR2,
                      p_last_transfer DATE,
                      p_prod_day_start  NUMBER,
                      p_target_interval NUMBER
                      )
RETURN DATE
--</EC-DOC>
IS
  lv2_prodday_id  Production_day.object_id%TYPE;
  ld_next_read    DATE;


BEGIN

  lv2_prodday_id := getProdDayIdFromTagid(p_source_id, p_tag_id,p_pk_attr_1,p_pk_val_1,p_pk_attr_2,p_pk_val_2,
                                          p_pk_attr_3,p_pk_val_3,p_pk_attr_4,p_pk_val_4,p_pk_attr_5,p_pk_val_5,
										  p_pk_attr_6,p_pk_val_6,p_pk_attr_7,p_pk_val_7,p_pk_attr_8,p_pk_val_8,
										  p_pk_attr_9,p_pk_val_9,p_pk_attr_10,p_pk_val_10);

  ld_next_read := p_last_transfer +Nvl(p_prod_day_start,0)/24+Nvl(p_target_interval,0)/86400;
  ld_next_read := ecdp_date_time.local2utc(ld_next_read,'N',lv2_prodday_id);

  RETURN ld_next_read;

--  Nvl(st.next_read,ecdp_date_time.local2utc(tt.last_transfer +Nvl(t.prod_day_start,0)/24+Nvl(t.target_interval,0)/86400,'N'))

END;

END;