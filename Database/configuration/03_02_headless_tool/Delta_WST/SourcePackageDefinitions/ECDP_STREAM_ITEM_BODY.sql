CREATE OR REPLACE PACKAGE BODY EcDp_Stream_Item IS
/****************************************************************
** Package        :  EcDp_StreamItem, body part
**
** $Revision: 1.64 $
**
** Purpose        :  Provide special functions on Stream_Item. Use EcDp_Objects for basis functions
**
** Documentation  :  www.energy-components.com
**
** Created  : 01.07.2002  Henning Stokke
**
** Modification history:
**
** Date         Whom  Change description:
** ------       ----- --------------------------------------
** 20.08.2006   sra   Initial version on 9.1
** 15.01.2007   DN    fcst_product_setup.stream_item_id renamed to cpy_adj_stream_item_id.
*****************************************************************************************/

-- Loop through all versions since we can not determine which version is updated from the application
  CURSOR gc_factors(cp_object_id VARCHAR2, cd_daytime DATE) IS
    SELECT pnv.daytime,
           pnv.end_date,
           pn.product_id,
           pn.conversion_type,
           density,
           density_volume_uom,
           density_mass_uom,
           gcv,
           gcv_volume_uom,
           gcv_energy_uom,
           mcv,
           mcv_mass_uom,
           mcv_energy_uom,
           boe_factor,
           boe_from_uom,
           boe_to_uom
      FROM product_node_version pnv, product_node pn
     WHERE pnv.object_id = cp_object_id
       AND pn.object_id = pnv.object_id
       AND pnv.daytime = (SELECT MAX(daytime)
                            FROM product_node_version
                           WHERE object_id = pnv.object_id
                             AND daytime <= cd_daytime)
    UNION
    SELECT pfv.daytime,
           pfv.end_date,
           pf.product_id, -- Field Level
           pf.conversion_type,
           density,
           density_volume_uom,
           density_mass_uom,
           gcv,
           gcv_volume_uom,
           gcv_energy_uom,
           mcv,
           mcv_mass_uom,
           mcv_energy_uom,
           boe_factor,
           boe_from_uom,
           boe_to_uom
      FROM product_field_version pfv, product_field pf
     WHERE pfv.object_id = cp_object_id
       AND pfv.object_id = pf.object_id
       AND pfv.daytime = (SELECT MAX(daytime)
                            FROM product_field_version
                           WHERE object_id = pfv.object_id
                             AND daytime <= cd_daytime)
    UNION
    SELECT pcv.daytime,
           pcv.end_date,
           pc.product_id, -- Country Level
           pc.conversion_type,
           density,
           density_volume_uom,
           density_mass_uom,
           gcv,
           gcv_volume_uom,
           gcv_energy_uom,
           mcv,
           mcv_mass_uom,
           mcv_energy_uom,
           boe_factor,
           boe_from_uom,
           boe_to_uom
      FROM product_country_version pcv, product_country pc
     WHERE pcv.object_id = cp_object_id
       AND pcv.object_id = pc.object_id
       AND pcv.daytime = (SELECT MAX(daytime)
                            FROM product_country_version
                           WHERE object_id = pcv.object_id
                             AND daytime <= cd_daytime);


FUNCTION getProductNodeId(
   p_product_id VARCHAR2,
   p_node_id VARCHAR2,
   p_daytime   DATE,
   p_conversion_type VARCHAR2 DEFAULT 'DENSITY_GCV_MCV' -- Pass BOE for BOE conversion
)
RETURN VARCHAR2
IS


CURSOR cRelCur IS
SELECT object_id FROM product_node t
WHERE t.product_id = p_product_id
AND t.node_id = p_node_id
AND t.conversion_type = p_conversion_type
AND t.start_date <= p_daytime
AND NVL (t.end_date, p_daytime+1) >= p_daytime;



lv2_object_id VARCHAR(32);

BEGIN

    lv2_object_id := NULL;

    FOR Rel IN cRelCur LOOP
        lv2_object_id := Rel.object_id;
    END LOOP;

    RETURN lv2_object_id;

END getProductNodeId;

FUNCTION getProductFieldId(
   p_product_id VARCHAR2,
   p_field_id VARCHAR2,
   p_daytime   DATE,
   p_conversion_type VARCHAR2 DEFAULT 'DENSITY_GCV_MCV' -- Pass BOE for BOE conversion
)
RETURN VARCHAR2
IS


CURSOR cRelCur IS
SELECT object_id FROM product_field t
WHERE t.product_id = p_product_id
AND t.field_id = p_field_id
AND t.conversion_type = p_conversion_type
AND t.start_date <= p_daytime
AND NVL (t.end_date, p_daytime+1) >= p_daytime;

lv2_object_id VARCHAR(32);

BEGIN

    lv2_object_id := NULL;

    FOR Rel IN cRelCur LOOP
        lv2_object_id := Rel.object_id;
    END LOOP;

    RETURN lv2_object_id;

END getProductFieldId;

FUNCTION getProductCountryId(
   p_product_id VARCHAR2,
   p_country_id VARCHAR2,
   p_daytime   DATE,
   p_conversion_type VARCHAR2 DEFAULT 'DENSITY_GCV_MCV' -- Pass BOE for BOE conversion
)
RETURN VARCHAR2
IS


CURSOR cRelCur IS
SELECT object_id FROM product_country t
WHERE t.product_id = p_product_id
AND t.country_id = p_country_id
AND t.conversion_type = p_conversion_type
AND t.start_date <= p_daytime
AND NVL (t.end_date, p_daytime+1) >= p_daytime;



lv2_object_id VARCHAR(32);

BEGIN

    lv2_object_id := NULL;

    FOR Rel IN cRelCur LOOP
        lv2_object_id := Rel.object_id;
    END LOOP;

    RETURN lv2_object_id;

END getProductCountryId;

FUNCTION GetProductCodeLabel(
   p_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_daytime   DATE
)

RETURN VARCHAR2

IS
/*
CURSOR c_product IS
    select ecdp_objects.getobjattrtext(p_s.from_object_id, p_daytime, 'CODE') PRODUCT_CODE
          ,ecdp_objects.getobjattrtext(p_s.from_object_id, p_daytime, 'PRODUCT_GROUP_CODE') PRODUCT_GROUP_CODE
          ,ecdp_objects.getobjattrtext(sic_si.from_object_id, p_daytime, 'CODE') STREAM_ITEM_CATEGORY_CODE
    from    objects_relation p_s
           ,objects_relation s_si
           ,objects_relation sic_si
           ,objects_attribute a_s_scc
    where
        -- product -> stream
           p_s.role_name = 'PRODUCT'
    and    p_s.from_object_id = p_product_object_id
    and    p_s.from_class_name = 'PRODUCT'
    and    p_s.to_object_id = s_si.from_object_id
    and    p_daytime BETWEEN Nvl(p_s.start_date,p_daytime-1) AND Nvl(p_s.end_date,p_daytime+1)
    -- stream -> stream_item
    and    s_si.role_name = 'STREAM'
    and    p_daytime BETWEEN Nvl(s_si.start_date,p_daytime-1) AND Nvl(s_si.end_date, p_daytime+1)
     -- stream_item_category -> stream_item
    and    s_si.to_object_id = sic_si.to_object_id
    and    sic_si.role_name = 'STREAM_ITEM_CATEGORY'
    and    sic_si.from_class_name = 'STREAM_ITEM_CATEGORY'
    and    s_si.to_object_id = p_object_id
    and    p_daytime BETWEEN Nvl(sic_si.start_date,p_daytime-1) AND Nvl(sic_si.end_date, p_daytime+1)
    -- attribute: stream_category.stream_category_code
    and    s_si.from_object_id = a_s_scc.object_id
    and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE';
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
  /*
  FOR c_rec_p in c_product LOOP
      IF c_rec_p.stream_item_category_code NOT IN ('GCV') THEN
        IF (c_rec_p.product_group_code = '120') THEN

           RETURN '1Liquid - C'||chr(38)||'C production';

        ELSIF (c_rec_p.product_group_code = '150') THEN

           RETURN '2Liquid - NGL production';

        ELSIF (c_rec_p.product_group_code = '200') THEN

          IF (c_rec_p.product_code = '2006') THEN

             RETURN '3Wet gas production';

          ELSE

             RETURN '4Dry gas production';

          END IF;

        ELSE

           RETURN null;

        END IF;

      ELSE
        IF c_rec_p.stream_item_category_code IN ('GCV') and c_rec_p.product_group_code = '200' THEN

           RETURN '5Gas sale';

         ELSE

           RETURN null;

        END IF;

  END IF;

END LOOP;
*/
END GetProductCodeLabel;

-- --------------------------------------------------------------------
-- GetNWIObjectId
-- --------------------------------------------------------------------
FUNCTION GetNWIObjectId(
   p_object_id	         VARCHAR2,
   p_daytime             DATE
      )
RETURN VARCHAR2 IS
/*
CURSOR c_nwi IS
select fi_si.from_object_id nwi_object_id
from   objects_relation fi_si
       ,objects_relation sic_si_nwi
       ,objects_relation sic_si_gwi
       ,objects_attribute a_sic_c_nwi
       ,objects_attribute a_sic_c_gwi
where  fi_si.role_name = 'FORMULA_ITEM'
and    fi_si.from_class_name = 'STREAM_ITEM'
and    fi_si.to_object_id = p_object_id
-- stream_item_category -> stream_item
and    sic_si_nwi.from_class_name = 'STREAM_ITEM_CATEGORY'
and    sic_si_nwi.role_name = 'STREAM_ITEM_CATEGORY'
and    sic_si_nwi.to_object_id = fi_si.from_object_id
-- stream_item_category -> stream_item
and    sic_si_gwi.from_class_name = 'STREAM_ITEM_CATEGORY'
and    sic_si_gwi.role_name = 'STREAM_ITEM_CATEGORY'
and    sic_si_gwi.to_object_id = fi_si.to_object_id
-- attribute
and    sic_si_nwi.from_object_id = a_sic_c_nwi.object_id
and    p_daytime >= a_sic_c_nwi.daytime
and    p_daytime < Nvl(a_sic_c_nwi.end_date, p_daytime+1)
and    a_sic_c_nwi.attribute_type = 'CODE'
AND    a_sic_c_nwi.Attribute_Text = 'NWI'
-- attribute
and    sic_si_gwi.from_object_id = a_sic_c_gwi.object_id
and    p_daytime >= a_sic_c_gwi.daytime
and    p_daytime < Nvl(a_sic_c_gwi.end_date, p_daytime+1)
and    a_sic_c_gwi.attribute_type = 'CODE'
AND    a_sic_c_gwi.Attribute_Text = 'GWI';
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
   FOR NWICur IN c_nwi LOOP

      -- Return NWI stream item object_id for specified GWI stream item
      return NWICur.nwi_object_id;

   END LOOP;

   -- Return null if a NWI stream item doesn't exists for specified GWI stream item
   RETURN NULL;
*/
END GetNWIObjectId;

-- --------------------------------------------------------------------
-- GetStimParentChildFieldInd
-- --------------------------------------------------------------------

FUNCTION GetParentChildFieldIndicator(
   p_object_id         VARCHAR2,
   p_field_object_id   VARCHAR2,
   p_daytime           DATE,
   p_SIC_OBJECT_ID     VARCHAR2 DEFAULT NULL,
   p_product_object_id VARCHAR2 DEFAULT NULL,
   p_company_object_id VARCHAR2 DEFAULT NULL
)

RETURN VARCHAR2

IS
/*
  CURSOR c_parent_or_child(cp_field_object_id VARCHAR2) IS
  SELECT '1_PARENT' rel_type ,
         o_r.*
  FROM   objects_relation o_r
  WHERE  from_class_name = 'FIELD'
  AND    to_class_name = 'FIELD'
  AND    role_name = 'PARENT_FIELD'
  AND    from_object_id = cp_field_object_id
  AND    (p_daytime >= Nvl(o_r.start_date,p_daytime-1) AND p_daytime < Nvl(o_r.end_date, p_daytime+1))
  UNION ALL
  SELECT '2_CHILD' rel_type,
         o_r.*
  FROM   objects_relation o_r
  WHERE  from_class_name = 'FIELD'
  AND    to_class_name = 'FIELD'
  AND    role_name = 'PARENT_FIELD'
  AND    to_object_id = cp_field_object_id
  AND    (p_daytime >= Nvl(o_r.start_date,p_daytime-1) AND p_daytime < Nvl(o_r.end_date, p_daytime+1))
  ORDER BY 1;

   CURSOR c_childExists(p_field_object_id VARCHAR2, p_SIC_OBJECT_ID VARCHAR2,
                        p_product_object_id VARCHAR2, p_company_object_id VARCHAR2 ) IS
   SELECT si.object_id
   FROM  objects si
         ,objects_relation f_f
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
         ,objects_relation sic_si
         ,objects_relation c_si
   WHERE
   --     parent_field -> field
          f_f.from_object_id = p_field_object_id
   AND    f_f.from_class_name = 'FIELD'
   and    f_f.to_class_name = 'FIELD'
   and    f_f.role_name = 'PARENT_FIELD'
   AND    (p_daytime >= Nvl(f_f.start_date,p_daytime-1) AND p_daytime < Nvl(f_f.end_date, p_daytime+1))
   --     field -> stream_item
   and    f_f.to_object_id = f_si.from_object_id
   and    f_si.role_name = 'FIELD'
   and    f_si.to_class_name = 'STREAM_ITEM'
   AND    (p_daytime >= Nvl(f_si.start_date,p_daytime-1) AND p_daytime < Nvl(f_si.end_date, p_daytime+1))
   AND    f_si.to_object_id = si.object_id
   -- stream -> stream_item
   and    si.object_id = s_si.to_object_id
   and    s_si.role_name = 'STREAM'
   and    s_si.from_class_name = 'STREAM'
   AND    (p_daytime >= Nvl(s_si.start_date,p_daytime-1) AND p_daytime < Nvl(s_si.end_date, p_daytime+1))
   -- product  -> stream
   and    p_s.to_object_id = s_si.from_object_id
   and    p_s.role_name = 'PRODUCT'
   and    p_s.to_class_name = 'STREAM'
   and    p_s.from_class_name = 'PRODUCT'
   AND    (p_daytime >= Nvl(p_s.start_date,p_daytime-1) AND p_daytime < Nvl(p_s.end_date, p_daytime+1))
   AND    p_s.from_object_id = p_product_object_id
   -- stream_item_category -> stream_item
   and    si.object_id = sic_si.to_object_id
   and    sic_si.role_name = 'STREAM_ITEM_CATEGORY'
   and    sic_si.from_class_name = 'STREAM_ITEM_CATEGORY'
   AND    (p_daytime >= Nvl(sic_si.start_date,p_daytime-1) AND p_daytime < Nvl(sic_si.end_date, p_daytime+1))
   AND    sic_si.from_object_id = p_SIC_OBJECT_ID
   -- company -> stream_item
   and    si.object_id = c_si.to_object_id
   and    c_si.role_name = 'COMPANY'
   and    c_si.from_class_name = 'COMPANY'
   AND    (p_daytime >= Nvl(c_si.start_date,p_daytime-1) AND p_daytime < Nvl(c_si.end_date, p_daytime+1))
   AND    c_si.from_object_id = p_company_object_id ;

   CURSOR c_ParentExists(p_field_object_id VARCHAR2, p_SIC_OBJECT_ID VARCHAR2,
                         p_product_object_id VARCHAR2, p_company_object_id VARCHAR2 ) IS
   SELECT si.object_id
   FROM  objects si
         ,objects_relation f_f
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
         ,objects_relation sic_si
         ,objects_relation c_si
   WHERE
   --     field -> parent_field
          f_f.to_object_id = p_field_object_id
   AND    f_f.from_class_name = 'FIELD'
   and    f_f.to_class_name = 'FIELD'
   and    f_f.role_name = 'PARENT_FIELD'
   AND    (p_daytime >= Nvl(f_f.start_date,p_daytime-1) AND p_daytime < Nvl(f_f.end_date, p_daytime+1))
   --     field -> stream_item
   and    f_f.from_object_id = f_si.from_object_id
   and    f_si.role_name = 'FIELD'
   and    f_si.to_class_name = 'STREAM_ITEM'
   AND    (p_daytime >= Nvl(f_si.start_date,p_daytime-1) AND p_daytime < Nvl(f_si.end_date, p_daytime+1))
   AND    f_si.to_object_id = si.object_id
   -- stream -> stream_item
   and    si.object_id = s_si.to_object_id
   and    s_si.role_name = 'STREAM'
   and    s_si.from_class_name = 'STREAM'
   AND    (p_daytime >= Nvl(s_si.start_date,p_daytime-1) AND p_daytime < Nvl(s_si.end_date, p_daytime+1))
   -- product  -> stream
   and    p_s.to_object_id = s_si.from_object_id
   and    p_s.role_name = 'PRODUCT'
   and    p_s.to_class_name = 'STREAM'
   and    p_s.from_class_name = 'PRODUCT'
   AND    (p_daytime >= Nvl(p_s.start_date,p_daytime-1) AND p_daytime < Nvl(p_s.end_date, p_daytime+1))
   AND    p_s.from_object_id = p_product_object_id
   -- stream_item_category -> stream_item
   and    si.object_id = sic_si.to_object_id
   and    sic_si.role_name = 'STREAM_ITEM_CATEGORY'
   and    sic_si.from_class_name = 'STREAM_ITEM_CATEGORY'
   AND    (p_daytime >= Nvl(sic_si.start_date,p_daytime-1) AND p_daytime < Nvl(sic_si.end_date, p_daytime+1))
   AND    sic_si.from_object_id = p_SIC_OBJECT_ID
   -- company -> stream_item
   and    si.object_id = c_si.to_object_id
   and    c_si.role_name = 'COMPANY'
   and    c_si.from_class_name = 'COMPANY'
   AND    (p_daytime >= Nvl(c_si.start_date,p_daytime-1) AND p_daytime < Nvl(c_si.end_date, p_daytime+1))
   AND    c_si.from_object_id = p_company_object_id ;



   lv2_field_object_id   objects.object_id%TYPE;
   lv2_SIC_OBJECT_ID     objects.object_id%TYPE;
   lv2_product_object_id objects.object_id%TYPE;
   lv2_company_object_id objects.object_id%TYPE;

  lv2_pfi                VARCHAR2(30) := 'NONE';
  ln_isparent            NUMBER := 0;
  ln_parent_found        NUMBER := 0;
  ln_child_found         NUMBER := 0;
*/
BEGIN
--  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     IF p_field_object_id IS NOT NULL THEN

         lv2_field_object_id := p_field_object_id;

      ELSE

         lv2_field_object_id := EcDp_synchronize_reports.getSISyncText('FIELD_OBJECT_ID', p_object_id, p_daytime);

      END IF;



  -- First let's check if the field is a parent or child

  FOR cur_rel IN c_parent_or_child(lv2_field_object_id) LOOP


     -- First need parents Stream_item_category, product(via stream) and company
     -- These can have been provided as parameters, if not need to look them up


     IF p_SIC_OBJECT_ID IS NOT NULL THEN

         lv2_SIC_OBJECT_ID := p_SIC_OBJECT_ID;

      ELSE

         lv2_SIC_OBJECT_ID := EcDp_synchronize_reports.getSISyncText('STREAM_ITEM_CATEGORY_OBJECT_ID', p_object_id, p_daytime);

      END IF;

      IF p_product_object_id IS NOT NULL THEN

         lv2_product_object_id := p_product_object_id;

      ELSE

         lv2_product_object_id := EcDp_synchronize_reports.getSISyncText('PRODUCT_OBJECT_ID', p_object_id, p_daytime);

      END IF;

      IF p_company_object_id IS NOT NULL THEN

         lv2_company_object_id := p_company_object_id;

      ELSE

         lv2_company_object_id := EcDp_synchronize_reports.getSISyncText('COMPANY_OBJECT_ID', p_object_id, p_daytime);

      END IF;



    IF cur_rel.rel_type = '1_PARENT' THEN

       ln_isparent := 1;

       -- Need to find if there are any children



      -- Using a cursor to find if there are any children

      FOR curChild IN c_childExists(lv2_field_object_id, lv2_SIC_OBJECT_ID, lv2_product_object_id, lv2_company_object_id ) LOOP

         ln_child_found := 1;
         EXIT;

      END LOOP;

      IF ln_child_found = 1 THEN

          lv2_pfi := 'PARENT';

      ELSE

          lv2_pfi := 'PARENTNOCHILD';

      END IF;

      EXIT;  -- If it is a parent no point in checking if it also is a child

    END IF;


    -- Child, check if assosiated stream items exists.
    IF ln_isparent = 0 THEN

      -- Need to find if parent is present in the same result set

      FOR curParent IN c_parentExists(lv2_field_object_id, lv2_SIC_OBJECT_ID, lv2_product_object_id, lv2_company_object_id) LOOP

         ln_parent_found := 1;
         EXIT;

      END LOOP;

      IF ln_parent_found = 1 THEN

          lv2_pfi := 'CHILD';

      ELSE

          lv2_pfi := 'CHILDNOPARENT';

      END IF;


      EXIT;

    END IF;

  END LOOP;


  RETURN lv2_pfi;




-- return none if a field is not a PARENT or a CHILD field.
  RETURN 'NONE';
*/
END GetParentChildFieldIndicator;    -- end function

FUNCTION GenDayAccrual(
   p_object_id VARCHAR2, -- The list object_id which the procedure should run for
   p_daytime DATE, -- Date to run for
   p_type VARCHAR2,
   p_user VARCHAR2
) RETURN VARCHAR2
IS

CURSOR c_stim_list_input IS
  SELECT t.object_id,
         t.mass_uom_code,
         t.volume_uom_code,
         t.energy_uom_code,
         ec_stream_item_version.master_uom_group(t.object_id, t.daytime, '<=') master_uom_group,
         t.extra1_uom_code,
         t.extra2_uom_code,
         t.extra3_uom_code,
         ec_stream_item_version.conversion_method(t.object_id, t.daytime, '<=') conversion_method,
         ec_stream_item_version.use_mass_ind(t.object_id, t.daytime, '<=') use_mass_ind,
         ec_stream_item_version.use_volume_ind(t.object_id, t.daytime, '<=') use_volume_ind,
         ec_stream_item_version.use_energy_ind(t.object_id, t.daytime, '<=') use_energy_ind,
         ec_stream_item_version.use_extra1_ind(t.object_id, t.daytime, '<=') use_extra1_ind,
         ec_stream_item_version.use_extra2_ind(t.object_id, t.daytime, '<=') use_extra2_ind,
         ec_stream_item_version.use_extra3_ind(t.object_id, t.daytime, '<=') use_extra3_ind
    FROM stim_day_value t
   WHERE t.object_id IN (select x.stream_item_id
                         from stim_collection_setup x
                        where x.object_id = p_object_id
                          and x.daytime <= p_daytime)
     and t.daytime = p_daytime
     and nvl(t.calc_method,
             ec_stream_item_version.calc_method(t.object_id, t.daytime, '<=')) in
         ('IP', 'DE')
     and (t.status IS NULL OR t.status = 'ACCRUAL');

CURSOR c_stim_list_overview IS
  SELECT t.object_id,
         t.mass_uom_code,
         t.volume_uom_code,
         t.energy_uom_code,
         ec_stream_item_version.master_uom_group(t.object_id,
                                                 t.daytime,
                                                 '<=') master_uom_group,
         t.extra1_uom_code,
         t.extra2_uom_code,
         t.extra3_uom_code,
         ec_stream_item_version.conversion_method(t.object_id,
                                                  t.daytime,
                                                  '<=') conversion_method,
         ec_stream_item_version.use_mass_ind(t.object_id, t.daytime, '<=') use_mass_ind,
         ec_stream_item_version.use_volume_ind(t.object_id, t.daytime, '<=') use_volume_ind,
         ec_stream_item_version.use_energy_ind(t.object_id, t.daytime, '<=') use_energy_ind,
         ec_stream_item_version.use_extra1_ind(t.object_id, t.daytime, '<=') use_extra1_ind,
         ec_stream_item_version.use_extra2_ind(t.object_id, t.daytime, '<=') use_extra2_ind,
         ec_stream_item_version.use_extra3_ind(t.object_id, t.daytime, '<=') use_extra3_ind
    FROM stim_day_value t
   WHERE t.object_id IN (select x.stream_item_id
                           from stim_collection_setup x
                          where x.object_id = p_object_id
                            and x.daytime <= p_daytime)
     and t.daytime = p_daytime
     and (t.status IS NULL OR t.status = 'ACCRUAL');

CURSOR c_stim_stream_input IS
  SELECT t.object_id,
         t.mass_uom_code,
         t.volume_uom_code,
         t.energy_uom_code,
         ec_stream_item_version.master_uom_group(t.object_id,
                                                 t.daytime,
                                                 '<=') master_uom_group,
         t.extra1_uom_code,
         t.extra2_uom_code,
         t.extra3_uom_code,
         ec_stream_item_version.conversion_method(t.object_id,
                                                  t.daytime,
                                                  '<=') conversion_method,
         ec_stream_item_version.use_mass_ind(t.object_id, t.daytime, '<=') use_mass_ind,
         ec_stream_item_version.use_volume_ind(t.object_id, t.daytime, '<=') use_volume_ind,
         ec_stream_item_version.use_energy_ind(t.object_id, t.daytime, '<=') use_energy_ind,
         ec_stream_item_version.use_extra1_ind(t.object_id, t.daytime, '<=') use_extra1_ind,
         ec_stream_item_version.use_extra2_ind(t.object_id, t.daytime, '<=') use_extra2_ind,
         ec_stream_item_version.use_extra3_ind(t.object_id, t.daytime, '<=') use_extra3_ind
    FROM stim_day_value t
   WHERE t.object_id IN (select x.object_id
                           from stream_item x
                          where x.stream_id = p_object_id
                            and x.start_date <= p_daytime)
     and t.daytime = p_daytime
     and nvl(t.calc_method,
             ec_stream_item_version.calc_method(t.object_id, t.daytime, '<=')) in
         ('IP', 'DE')
     and (t.status IS NULL OR t.status = 'ACCRUAL');

CURSOR c_stim_stream_overview IS
  SELECT t.object_id,
         t.mass_uom_code,
         t.volume_uom_code,
         t.energy_uom_code,
         ec_stream_item_version.master_uom_group(t.object_id,
                                                 t.daytime,
                                                 '<=') master_uom_group,
         t.extra1_uom_code,
         t.extra2_uom_code,
         t.extra3_uom_code,
         ec_stream_item_version.conversion_method(t.object_id,
                                                  t.daytime,
                                                  '<=') conversion_method,
         ec_stream_item_version.use_mass_ind(t.object_id, p_daytime, '<=') use_mass_ind,
         ec_stream_item_version.use_volume_ind(t.object_id, t.daytime, '<=') use_volume_ind,
         ec_stream_item_version.use_energy_ind(t.object_id, t.daytime, '<=') use_energy_ind,
         ec_stream_item_version.use_extra1_ind(t.object_id, t.daytime, '<=') use_extra1_ind,
         ec_stream_item_version.use_extra2_ind(t.object_id, t.daytime, '<=') use_extra2_ind,
         ec_stream_item_version.use_extra3_ind(t.object_id, t.daytime, '<=') use_extra3_ind
    FROM stim_day_value t
   WHERE t.object_id IN (select x.object_id
                         from stream_item x
                        where x.stream_id = p_object_id
                          and x.start_date <= p_daytime)
     and daytime = p_daytime
     and (t.status IS NULL OR t.status = 'ACCRUAL');

  ltab_stim t_stim := t_stim();

  ln_updated NUMBER := 0;
  ln_processed NUMBER := 0;
  ln_qty NUMBER;

BEGIN

     IF (p_type = 'LIST_INPUT') THEN
        FOR AccrualCur IN c_stim_list_input LOOP
            ltab_stim.extend;
            ltab_stim(ltab_stim.last).object_id := AccrualCur.object_id;
            ltab_stim(ltab_stim.last).mass_uom_code := AccrualCur.mass_uom_code;
            ltab_stim(ltab_stim.last).volume_uom_code := AccrualCur.volume_uom_code;
            ltab_stim(ltab_stim.last).energy_uom_code := AccrualCur.energy_uom_code;
            ltab_stim(ltab_stim.last).extra1_uom_code := AccrualCur.extra1_uom_code;
            ltab_stim(ltab_stim.last).extra2_uom_code := AccrualCur.extra2_uom_code;
            ltab_stim(ltab_stim.last).extra3_uom_code := AccrualCur.extra3_uom_code;
            ltab_stim(ltab_stim.last).master_uom_group := AccrualCur.master_uom_group;
            ltab_stim(ltab_stim.last).conversion_method := AccrualCur.conversion_method;
            ltab_stim(ltab_stim.last).use_mass_ind := AccrualCur.use_mass_ind;
            ltab_stim(ltab_stim.last).use_volume_ind := AccrualCur.use_volume_ind;
            ltab_stim(ltab_stim.last).use_energy_ind := AccrualCur.use_energy_ind;
            ltab_stim(ltab_stim.last).use_extra1_ind := AccrualCur.use_extra1_ind;
            ltab_stim(ltab_stim.last).use_extra2_ind := AccrualCur.use_extra2_ind;
            ltab_stim(ltab_stim.last).use_extra3_ind := AccrualCur.use_extra3_ind;
        END LOOP;
     ELSIF (p_type = 'LIST_OVERVIEW') THEN
        FOR AccrualCur IN c_stim_list_overview LOOP
            ltab_stim.extend;
            ltab_stim(ltab_stim.last).object_id := AccrualCur.object_id;
            ltab_stim(ltab_stim.last).mass_uom_code := AccrualCur.mass_uom_code;
            ltab_stim(ltab_stim.last).volume_uom_code := AccrualCur.volume_uom_code;
            ltab_stim(ltab_stim.last).energy_uom_code := AccrualCur.energy_uom_code;
            ltab_stim(ltab_stim.last).extra1_uom_code := AccrualCur.extra1_uom_code;
            ltab_stim(ltab_stim.last).extra2_uom_code := AccrualCur.extra2_uom_code;
            ltab_stim(ltab_stim.last).extra3_uom_code := AccrualCur.extra3_uom_code;
            ltab_stim(ltab_stim.last).master_uom_group := AccrualCur.master_uom_group;
            ltab_stim(ltab_stim.last).conversion_method := AccrualCur.conversion_method;
            ltab_stim(ltab_stim.last).use_mass_ind := AccrualCur.use_mass_ind;
            ltab_stim(ltab_stim.last).use_volume_ind := AccrualCur.use_volume_ind;
            ltab_stim(ltab_stim.last).use_energy_ind := AccrualCur.use_energy_ind;
            ltab_stim(ltab_stim.last).use_extra1_ind := AccrualCur.use_extra1_ind;
            ltab_stim(ltab_stim.last).use_extra2_ind := AccrualCur.use_extra2_ind;
            ltab_stim(ltab_stim.last).use_extra3_ind := AccrualCur.use_extra3_ind;
        END LOOP;
     ELSIF (p_type = 'STREAM_INPUT') THEN
        FOR AccrualCur IN c_stim_stream_input LOOP
            ltab_stim.extend;
            ltab_stim(ltab_stim.last).object_id := AccrualCur.object_id;
            ltab_stim(ltab_stim.last).mass_uom_code := AccrualCur.mass_uom_code;
            ltab_stim(ltab_stim.last).volume_uom_code := AccrualCur.volume_uom_code;
            ltab_stim(ltab_stim.last).energy_uom_code := AccrualCur.energy_uom_code;
            ltab_stim(ltab_stim.last).extra1_uom_code := AccrualCur.extra1_uom_code;
            ltab_stim(ltab_stim.last).extra2_uom_code := AccrualCur.extra2_uom_code;
            ltab_stim(ltab_stim.last).extra3_uom_code := AccrualCur.extra3_uom_code;
            ltab_stim(ltab_stim.last).master_uom_group := AccrualCur.master_uom_group;
            ltab_stim(ltab_stim.last).conversion_method := AccrualCur.conversion_method;
            ltab_stim(ltab_stim.last).use_mass_ind := AccrualCur.use_mass_ind;
            ltab_stim(ltab_stim.last).use_volume_ind := AccrualCur.use_volume_ind;
            ltab_stim(ltab_stim.last).use_energy_ind := AccrualCur.use_energy_ind;
            ltab_stim(ltab_stim.last).use_extra1_ind := AccrualCur.use_extra1_ind;
            ltab_stim(ltab_stim.last).use_extra2_ind := AccrualCur.use_extra2_ind;
            ltab_stim(ltab_stim.last).use_extra3_ind := AccrualCur.use_extra3_ind;
        END LOOP;
     ELSIF (p_type = 'STREAM_OVERVIEW') THEN
        FOR AccrualCur IN c_stim_stream_overview LOOP
            ltab_stim.extend;
            ltab_stim(ltab_stim.last).object_id := AccrualCur.object_id;
            ltab_stim(ltab_stim.last).mass_uom_code := AccrualCur.mass_uom_code;
            ltab_stim(ltab_stim.last).volume_uom_code := AccrualCur.volume_uom_code;
            ltab_stim(ltab_stim.last).energy_uom_code := AccrualCur.energy_uom_code;
            ltab_stim(ltab_stim.last).extra1_uom_code := AccrualCur.extra1_uom_code;
            ltab_stim(ltab_stim.last).extra2_uom_code := AccrualCur.extra2_uom_code;
            ltab_stim(ltab_stim.last).extra3_uom_code := AccrualCur.extra3_uom_code;
            ltab_stim(ltab_stim.last).master_uom_group := AccrualCur.master_uom_group;
            ltab_stim(ltab_stim.last).conversion_method := AccrualCur.conversion_method;
            ltab_stim(ltab_stim.last).use_mass_ind := AccrualCur.use_mass_ind;
            ltab_stim(ltab_stim.last).use_volume_ind := AccrualCur.use_volume_ind;
            ltab_stim(ltab_stim.last).use_energy_ind := AccrualCur.use_energy_ind;
            ltab_stim(ltab_stim.last).use_extra1_ind := AccrualCur.use_extra1_ind;
            ltab_stim(ltab_stim.last).use_extra2_ind := AccrualCur.use_extra2_ind;
            ltab_stim(ltab_stim.last).use_extra3_ind := AccrualCur.use_extra3_ind;
        END LOOP;
     END IF;
     ln_processed := ltab_stim.count;

     FOR i IN 1..ltab_stim.count LOOP

        IF (ltab_stim(i).conversion_method = 'CONVERSION_FACTOR') THEN
         IF (ltab_stim(i).master_uom_group = 'V') THEN
           ln_qty := GetDayAccrualVol(ltab_stim(i).object_id, p_daytime, ltab_stim(i).volume_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_day_value SET
               status = 'ACCRUAL',
               net_volume_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        ELSIF (ltab_stim(i).master_uom_group = 'M') THEN
           ln_qty := GetDayAccrualMass(ltab_stim(i).object_id, p_daytime, ltab_stim(i).mass_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_day_value SET
               status = 'ACCRUAL',
               net_mass_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        ELSIF (ltab_stim(i).master_uom_group = 'E') THEN
           ln_qty := GetDayAccrualEnergy(ltab_stim(i).object_id, p_daytime, ltab_stim(i).energy_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_day_value SET
               status = 'ACCRUAL',
               net_energy_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;

       ELSE --conversion_method = 'CALCULATED')

        IF (ltab_stim(i).use_volume_ind = 'Y') THEN
           ln_qty := GetDayAccrualVol(ltab_stim(i).object_id, p_daytime, ltab_stim(i).volume_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_day_value SET
               status = 'ACCRUAL',
               net_volume_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_mass_ind = 'Y') THEN
           ln_qty := GetDayAccrualMass(ltab_stim(i).object_id, p_daytime, ltab_stim(i).mass_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_day_value SET
               status = 'ACCRUAL',
               net_mass_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_energy_ind = 'Y') THEN
           ln_qty := GetDayAccrualEnergy(ltab_stim(i).object_id, p_daytime, ltab_stim(i).energy_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_day_value SET
               status = 'ACCRUAL',
               net_energy_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_extra1_ind = 'Y') THEN
           ln_qty := GetDayAccrualExtra1(ltab_stim(i).object_id, p_daytime, ltab_stim(i).extra1_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_day_value SET
               status = 'ACCRUAL',
               net_extra1_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_extra2_ind = 'Y') THEN
           ln_qty := GetDayAccrualExtra2(ltab_stim(i).object_id, p_daytime, ltab_stim(i).extra2_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_day_value SET
               status = 'ACCRUAL',
               net_extra2_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_extra3_ind = 'Y') THEN
           ln_qty := GetDayAccrualExtra3(ltab_stim(i).object_id, p_daytime, ltab_stim(i).extra3_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_day_value SET
               status = 'ACCRUAL',
               net_extra3_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;

       END IF;
        -- Insert into stim_cascade to mark SIs to run cascade for
        INSERT INTO stim_cascade (object_id,period,daytime) VALUES (ltab_stim(i).object_id, 'DAY', p_daytime);
     END LOOP;
     RETURN ln_processed || ' records processed, and ' || ln_updated || ' records updated';

END GenDayAccrual;

FUNCTION GetDayAccrualVol(
   p_object_id	         VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER IS

CURSOR c_last_actual IS
SELECT EcDp_Revn_Unit.convertValue(net_volume_value, volume_uom_code, p_uom_code, p_object_id, p_daytime) vol
FROM stim_day_value x
WHERE object_id = p_object_id
  AND daytime = (SELECT Max(daytime)
                 FROM stim_day_value
                 WHERE object_id = x.object_id
                   AND status != 'ACCRUAL'
                   AND daytime <= p_daytime);

CURSOR c_avg_actual IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_volume_value), Max(volume_uom_code), p_uom_code, p_object_id, p_daytime) vol
FROM stim_day_value
WHERE object_id = p_object_id
  AND status != 'ACCRUAL'
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);


unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_day(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast and divide by number of days in month to get daily accrual
        lv2_return_val := GetMthPlanVol(p_object_id,p_daytime,'OFF',p_uom_code, NULL) / (Last_Day(Trunc(p_daytime,'MM')) + 1 - Trunc(p_daytime,'MM'));

     ELSIF lv2_Accrual_Method = 'LAST_ACTUAL' THEN

        -- take last available daily actual to get daily accrual
        FOR LastActualCur IN c_last_actual LOOP

            lv2_return_val := LastActualCur.vol;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'AVG_ACTUAL' THEN

        -- take average daily actual to get daily accrual
        FOR AvgActualCur IN c_avg_actual LOOP

            lv2_return_val := AvgActualCur.vol;

        END LOOP;

     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetDayAccrualVol;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDayAccrualMAss                                                               --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_DAY_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanMass                                              --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetDayAccrualMass(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER IS
--<EC-DOC>

CURSOR c_last_actual IS
SELECT EcDp_Revn_Unit.convertValue(net_mass_value, mass_uom_code, p_uom_code, p_object_id, p_daytime) mass
FROM stim_day_value x
WHERE object_id = p_object_id
  AND daytime = (SELECT Max(daytime)
                 FROM stim_day_value
                 WHERE object_id = x.object_id
                   AND status != 'ACCRUAL'
                   AND daytime <= p_daytime);

CURSOR c_avg_actual IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_mass_value), Max(mass_uom_code), p_uom_code, p_object_id, p_daytime) mass
FROM stim_day_value
WHERE object_id = p_object_id
  AND status != 'ACCRUAL'
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_day(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast and divide by number of days in month to get daily accrual
        lv2_return_val := GetMthPlanMass(p_object_id,p_daytime,'OFF',p_uom_code, NULL) / (Last_Day(Trunc(p_daytime,'MM')) + 1 - Trunc(p_daytime,'MM'));

     ELSIF lv2_Accrual_Method = 'LAST_ACTUAL' THEN

        -- take last available daily actual to get daily accrual
        FOR LastActualCur IN c_last_actual LOOP

            lv2_return_val := LastActualCur.mass;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'AVG_ACTUAL' THEN

        -- take average daily actual to get daily accrual
        FOR AvgActualCur IN c_avg_actual LOOP

            lv2_return_val := AvgActualCur.mass;

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetDayAccrualMass;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDayAccrualEnergy                                                              --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_DAY_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanMass                                              --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetDayAccrualEnergy(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER

--<EC-DOC>

IS
CURSOR c_last_actual IS
SELECT EcDp_Revn_Unit.convertValue(net_energy_value, energy_uom_code, p_uom_code, p_object_id, p_daytime) energy
FROM stim_day_value x
WHERE object_id = p_object_id
  AND daytime = (SELECT Max(daytime)
                 FROM stim_day_value
                 WHERE object_id = x.object_id
                   AND status != 'ACCRUAL'
                   AND daytime <= p_daytime);

CURSOR c_avg_actual IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_energy_value), Max(energy_uom_code), p_uom_code, p_object_id, p_daytime) energy
FROM stim_day_value
WHERE object_id = p_object_id
  AND status != 'ACCRUAL'
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_day(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast and divide by number of days in month to get daily accrual
        lv2_return_val := GetMthPlanEnergy(p_object_id,p_daytime,'OFF',p_uom_code, NULL) / (Last_Day(Trunc(p_daytime)) + 1 - Trunc(p_daytime,'MM'));

     ELSIF lv2_Accrual_Method = 'LAST_ACTUAL' THEN

        -- take last available daily actual to get daily accrual
        FOR LastActualCur IN c_last_actual LOOP

            lv2_return_val := LastActualCur.energy;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'AVG_ACTUAL' THEN

        -- take average daily actual to get daily accrual
        FOR AvgActualCur IN c_avg_actual LOOP

            lv2_return_val := AvgActualCur.energy;

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetDayAccrualEnergy;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDayAccrualExtra1                                                              --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_DAY_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanExtra1                                             --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetDayAccrualExtra1(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER IS
--<EC-DOC>

CURSOR c_last_actual IS
SELECT EcDp_Revn_Unit.convertValue(net_extra1_value, extra1_uom_code, p_uom_code, p_object_id, p_daytime) extra1
FROM stim_day_value x
WHERE object_id = p_object_id
  AND daytime = (SELECT Max(daytime)
                 FROM stim_day_value
                 WHERE object_id = x.object_id
                   AND status != 'ACCRUAL'
                   AND daytime <= p_daytime);

CURSOR c_avg_actual IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_extra1_value), Max(extra1_uom_code), p_uom_code, p_object_id, p_daytime) extra1
FROM stim_day_value
WHERE object_id = p_object_id
  AND status != 'ACCRUAL'
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_day(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast and divide by number of days in month to get daily accrual
        lv2_return_val := GetMthPlanExtra1(p_object_id,p_daytime,'OFF',p_uom_code, NULL) / (Last_Day(Trunc(p_daytime,'MM')) + 1 - Trunc(p_daytime,'MM'));

     ELSIF lv2_Accrual_Method = 'LAST_ACTUAL' THEN

        -- take last available daily actual to get daily accrual
        FOR LastActualCur IN c_last_actual LOOP

            lv2_return_val := LastActualCur.extra1;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'AVG_ACTUAL' THEN

        -- take average daily actual to get daily accrual
        FOR AvgActualCur IN c_avg_actual LOOP

            lv2_return_val := AvgActualCur.extra1;

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetDayAccrualExtra1;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDayAccrualExtra2                                                              --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_DAY_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanExtra2                                             --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetDayAccrualExtra2(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER IS
--<EC-DOC>

CURSOR c_last_actual IS
SELECT EcDp_Revn_Unit.convertValue(net_extra2_value, extra2_uom_code, p_uom_code, p_object_id, p_daytime) extra2
FROM stim_day_value x
WHERE object_id = p_object_id
  AND daytime = (SELECT Max(daytime)
                 FROM stim_day_value
                 WHERE object_id = x.object_id
                   AND status != 'ACCRUAL'
                   AND daytime <= p_daytime);

CURSOR c_avg_actual IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_extra2_value), Max(extra2_uom_code), p_uom_code, p_object_id, p_daytime) extra2
FROM stim_day_value
WHERE object_id = p_object_id
  AND status != 'ACCRUAL'
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_day(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast and divide by number of days in month to get daily accrual
        lv2_return_val := GetMthPlanExtra2(p_object_id,p_daytime,'OFF',p_uom_code, NULL) / (Last_Day(Trunc(p_daytime,'MM')) + 1 - Trunc(p_daytime,'MM'));

     ELSIF lv2_Accrual_Method = 'LAST_ACTUAL' THEN

        -- take last available daily actual to get daily accrual
        FOR LastActualCur IN c_last_actual LOOP

            lv2_return_val := LastActualCur.extra2;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'AVG_ACTUAL' THEN

        -- take average daily actual to get daily accrual
        FOR AvgActualCur IN c_avg_actual LOOP

            lv2_return_val := AvgActualCur.extra2;

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetDayAccrualExtra2;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDayAccrualExtra3                                                              --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_DAY_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanExtra3                                             --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetDayAccrualExtra3(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER IS
--<EC-DOC>

CURSOR c_last_actual IS
SELECT EcDp_Revn_Unit.convertValue(net_extra3_value, extra3_uom_code, p_uom_code, p_object_id, p_daytime) extra3
FROM stim_day_value x
WHERE object_id = p_object_id
  AND daytime = (SELECT Max(daytime)
                 FROM stim_day_value
                 WHERE object_id = x.object_id
                   AND status != 'ACCRUAL'
                   AND daytime <= p_daytime);

CURSOR c_avg_actual IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_extra3_value), Max(extra3_uom_code), p_uom_code, p_object_id, p_daytime) extra3
FROM stim_day_value
WHERE object_id = p_object_id
  AND status != 'ACCRUAL'
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_day(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast and divide by number of days in month to get daily accrual
        lv2_return_val := GetMthPlanExtra3(p_object_id,p_daytime,'OFF',p_uom_code, NULL) / (Last_Day(Trunc(p_daytime,'MM')) + 1 - Trunc(p_daytime,'MM'));

     ELSIF lv2_Accrual_Method = 'LAST_ACTUAL' THEN

        -- take last available daily actual to get daily accrual
        FOR LastActualCur IN c_last_actual LOOP

            lv2_return_val := LastActualCur.extra3;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'AVG_ACTUAL' THEN

        -- take average daily actual to get daily accrual
        FOR AvgActualCur IN c_avg_actual LOOP

            lv2_return_val := AvgActualCur.extra3;

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetDayAccrualExtra3;

FUNCTION GenMthAccrual(
   p_object_id VARCHAR2, -- The list object_id which the procedure should run for
   p_daytime DATE, -- Date to run for
   p_type VARCHAR2,
   p_user VARCHAR2
) RETURN VARCHAR2
IS

CURSOR c_stim_list_input IS
  SELECT t.object_id,
         t.mass_uom_code,
         t.volume_uom_code,
         t.energy_uom_code,
         ec_stream_item_version.master_uom_group(t.object_id,
                                                 t.daytime,
                                                 '<=') master_uom_group,
         t.extra1_uom_code,
         t.extra2_uom_code,
         t.extra3_uom_code,
         ec_stream_item_version.conversion_method(t.object_id,
                                                  t.daytime,
                                                  '<=') conversion_method,
         ec_stream_item_version.use_mass_ind(t.object_id, t.daytime, '<=') use_mass_ind,
         ec_stream_item_version.use_volume_ind(t.object_id, t.daytime, '<=') use_volume_ind,
         ec_stream_item_version.use_energy_ind(t.object_id, t.daytime, '<=') use_energy_ind,
         ec_stream_item_version.use_extra1_ind(t.object_id, t.daytime, '<=') use_extra1_ind,
         ec_stream_item_version.use_extra2_ind(t.object_id, t.daytime, '<=') use_extra2_ind,
         ec_stream_item_version.use_extra3_ind(t.object_id, t.daytime, '<=') use_extra3_ind
    FROM stim_mth_value t
   WHERE t.object_id IN (select x.stream_item_id
                           from stim_collection_setup x
                          where x.object_id = p_object_id
                            and x.daytime <= p_daytime)
     and t.daytime = p_daytime
     and nvl(t.calc_method,
             ec_stream_item_version.calc_method(t.object_id, t.daytime, '<=')) in
         ('IP', 'DE')
     and (t.status IS NULL OR t.status = 'ACCRUAL');

CURSOR c_stim_list_overview IS
  SELECT t.object_id,
         t.mass_uom_code,
         t.volume_uom_code,
         t.energy_uom_code,
         ec_stream_item_version.master_uom_group(t.object_id,
                                                 t.daytime,
                                                 '<=') master_uom_group,
         t.extra1_uom_code,
         t.extra2_uom_code,
         t.extra3_uom_code,
         ec_stream_item_version.conversion_method(t.object_id,
                                                    t.daytime,
                                                    '<=') conversion_method,
         ec_stream_item_version.use_mass_ind(t.object_id, t.daytime, '<=') use_mass_ind,
         ec_stream_item_version.use_volume_ind(t.object_id, t.daytime, '<=') use_volume_ind,
         ec_stream_item_version.use_energy_ind(t.object_id, t.daytime, '<=') use_energy_ind,
         ec_stream_item_version.use_extra1_ind(t.object_id, t.daytime, '<=') use_extra1_ind,
         ec_stream_item_version.use_extra2_ind(t.object_id, t.daytime, '<=') use_extra2_ind,
         ec_stream_item_version.use_extra3_ind(t.object_id, t.daytime, '<=') use_extra3_ind
    FROM stim_mth_value t
   WHERE t.object_id IN (select x.stream_item_id
                           from stim_collection_setup x
                          where x.object_id = p_object_id
                            and x.daytime <= p_daytime)
     and t.daytime = p_daytime
     and (t.status IS NULL OR t.status = 'ACCRUAL');

CURSOR c_stim_stream_input IS
  SELECT t.object_id,
         t.mass_uom_code,
         t.volume_uom_code,
         t.energy_uom_code,
         ec_stream_item_version.master_uom_group(t.object_id,
                                                 t.daytime,
                                                 '<=') master_uom_group,
         t.extra1_uom_code,
         t.extra2_uom_code,
         t.extra3_uom_code,
         ec_stream_item_version.conversion_method(t.object_id,
                                                  t.daytime,
                                                  '<=') conversion_method,
         ec_stream_item_version.use_mass_ind(t.object_id, t.daytime, '<=') use_mass_ind,
         ec_stream_item_version.use_volume_ind(t.object_id, t.daytime, '<=') use_volume_ind,
         ec_stream_item_version.use_energy_ind(t.object_id, t.daytime, '<=') use_energy_ind,
         ec_stream_item_version.use_extra1_ind(t.object_id, t.daytime, '<=') use_extra1_ind,
         ec_stream_item_version.use_extra2_ind(t.object_id, t.daytime, '<=') use_extra2_ind,
         ec_stream_item_version.use_extra3_ind(t.object_id, t.daytime, '<=') use_extra3_ind
    FROM stim_mth_value t
   WHERE t.object_id IN (select x.object_id
                           from stream_item x
                          where x.stream_id = p_object_id
                            and x.start_date <= p_daytime)
     and t.daytime = p_daytime
     and nvl(t.calc_method,
             ec_stream_item_version.calc_method(t.object_id, t.daytime, '<=')) in
         ('IP', 'DE')
     and (t.status IS NULL OR t.status = 'ACCRUAL');

CURSOR c_stim_stream_overview IS
  SELECT t.object_id,
         t.mass_uom_code,
         t.volume_uom_code,
         t.energy_uom_code,
         ec_stream_item_version.master_uom_group(t.object_id,
                                                 t.daytime,
                                                 '<=') master_uom_group,
         t.extra1_uom_code,
         t.extra2_uom_code,
         t.extra3_uom_code,
         ec_stream_item_version.conversion_method(t.object_id,
                                                  t.daytime,
                                                  '<=') conversion_method,
         ec_stream_item_version.use_mass_ind(t.object_id, t.daytime, '<=') use_mass_ind,
         ec_stream_item_version.use_volume_ind(t.object_id, t.daytime, '<=') use_volume_ind,
         ec_stream_item_version.use_energy_ind(t.object_id, t.daytime, '<=') use_energy_ind,
         ec_stream_item_version.use_extra1_ind(t.object_id, t.daytime, '<=') use_extra1_ind,
         ec_stream_item_version.use_extra2_ind(t.object_id, t.daytime, '<=') use_extra2_ind,
         ec_stream_item_version.use_extra3_ind(t.object_id, t.daytime, '<=') use_extra3_ind
    FROM stim_mth_value t
   WHERE t.object_id IN (select x.object_id
                           from stream_item x
                          where x.stream_id = p_object_id
                            and x.start_date <= p_daytime)
     and t.daytime = p_daytime
     and (t.status IS NULL OR t.status = 'ACCRUAL');


    ltab_stim t_stim := t_stim();

    ln_updated NUMBER := 0;
    ln_processed NUMBER := 0;

    ln_qty NUMBER;

BEGIN

     IF (p_type = 'LIST_INPUT') THEN
        FOR AccrualCur IN c_stim_list_input LOOP
            ltab_stim.extend;
            ltab_stim(ltab_stim.last).object_id := AccrualCur.object_id;
            ltab_stim(ltab_stim.last).mass_uom_code := AccrualCur.mass_uom_code;
            ltab_stim(ltab_stim.last).volume_uom_code := AccrualCur.volume_uom_code;
            ltab_stim(ltab_stim.last).energy_uom_code := AccrualCur.energy_uom_code;
            ltab_stim(ltab_stim.last).extra1_uom_code := AccrualCur.extra1_uom_code;
            ltab_stim(ltab_stim.last).extra2_uom_code := AccrualCur.extra2_uom_code;
            ltab_stim(ltab_stim.last).extra3_uom_code := AccrualCur.extra3_uom_code;
            ltab_stim(ltab_stim.last).master_uom_group := AccrualCur.master_uom_group;
            ltab_stim(ltab_stim.last).conversion_method := AccrualCur.conversion_method;
            ltab_stim(ltab_stim.last).use_mass_ind := AccrualCur.use_mass_ind;
            ltab_stim(ltab_stim.last).use_volume_ind := AccrualCur.use_volume_ind;
            ltab_stim(ltab_stim.last).use_energy_ind := AccrualCur.use_energy_ind;
            ltab_stim(ltab_stim.last).use_extra1_ind := AccrualCur.use_extra1_ind;
            ltab_stim(ltab_stim.last).use_extra2_ind := AccrualCur.use_extra2_ind;
            ltab_stim(ltab_stim.last).use_extra3_ind := AccrualCur.use_extra3_ind;
        END LOOP;
     ELSIF (p_type = 'LIST_OVERVIEW') THEN
        FOR AccrualCur IN c_stim_list_overview LOOP
            ltab_stim.extend;
            ltab_stim(ltab_stim.last).object_id := AccrualCur.object_id;
            ltab_stim(ltab_stim.last).mass_uom_code := AccrualCur.mass_uom_code;
            ltab_stim(ltab_stim.last).volume_uom_code := AccrualCur.volume_uom_code;
            ltab_stim(ltab_stim.last).energy_uom_code := AccrualCur.energy_uom_code;
            ltab_stim(ltab_stim.last).extra1_uom_code := AccrualCur.extra1_uom_code;
            ltab_stim(ltab_stim.last).extra2_uom_code := AccrualCur.extra2_uom_code;
            ltab_stim(ltab_stim.last).extra3_uom_code := AccrualCur.extra3_uom_code;
            ltab_stim(ltab_stim.last).master_uom_group := AccrualCur.master_uom_group;
            ltab_stim(ltab_stim.last).conversion_method := AccrualCur.conversion_method;
            ltab_stim(ltab_stim.last).use_mass_ind := AccrualCur.use_mass_ind;
            ltab_stim(ltab_stim.last).use_volume_ind := AccrualCur.use_volume_ind;
            ltab_stim(ltab_stim.last).use_energy_ind := AccrualCur.use_energy_ind;
            ltab_stim(ltab_stim.last).use_extra1_ind := AccrualCur.use_extra1_ind;
            ltab_stim(ltab_stim.last).use_extra2_ind := AccrualCur.use_extra2_ind;
            ltab_stim(ltab_stim.last).use_extra3_ind := AccrualCur.use_extra3_ind;
        END LOOP;
     ELSIF (p_type = 'STREAM_INPUT') THEN
        FOR AccrualCur IN c_stim_stream_input LOOP
            ltab_stim.extend;
            ltab_stim(ltab_stim.last).object_id := AccrualCur.object_id;
            ltab_stim(ltab_stim.last).mass_uom_code := AccrualCur.mass_uom_code;
            ltab_stim(ltab_stim.last).volume_uom_code := AccrualCur.volume_uom_code;
            ltab_stim(ltab_stim.last).energy_uom_code := AccrualCur.energy_uom_code;
            ltab_stim(ltab_stim.last).extra1_uom_code := AccrualCur.extra1_uom_code;
            ltab_stim(ltab_stim.last).extra2_uom_code := AccrualCur.extra2_uom_code;
            ltab_stim(ltab_stim.last).extra3_uom_code := AccrualCur.extra3_uom_code;
            ltab_stim(ltab_stim.last).master_uom_group := AccrualCur.master_uom_group;
            ltab_stim(ltab_stim.last).conversion_method := AccrualCur.conversion_method;
            ltab_stim(ltab_stim.last).use_mass_ind := AccrualCur.use_mass_ind;
            ltab_stim(ltab_stim.last).use_volume_ind := AccrualCur.use_volume_ind;
            ltab_stim(ltab_stim.last).use_energy_ind := AccrualCur.use_energy_ind;
            ltab_stim(ltab_stim.last).use_extra1_ind := AccrualCur.use_extra1_ind;
            ltab_stim(ltab_stim.last).use_extra2_ind := AccrualCur.use_extra2_ind;
            ltab_stim(ltab_stim.last).use_extra3_ind := AccrualCur.use_extra3_ind;
        END LOOP;
     ELSIF (p_type = 'STREAM_OVERVIEW') THEN
        FOR AccrualCur IN c_stim_stream_overview LOOP
            ltab_stim.extend;
            ltab_stim(ltab_stim.last).object_id := AccrualCur.object_id;
            ltab_stim(ltab_stim.last).mass_uom_code := AccrualCur.mass_uom_code;
            ltab_stim(ltab_stim.last).volume_uom_code := AccrualCur.volume_uom_code;
            ltab_stim(ltab_stim.last).energy_uom_code := AccrualCur.energy_uom_code;
            ltab_stim(ltab_stim.last).extra1_uom_code := AccrualCur.extra1_uom_code;
            ltab_stim(ltab_stim.last).extra2_uom_code := AccrualCur.extra2_uom_code;
            ltab_stim(ltab_stim.last).extra3_uom_code := AccrualCur.extra3_uom_code;
            ltab_stim(ltab_stim.last).master_uom_group := AccrualCur.master_uom_group;
            ltab_stim(ltab_stim.last).conversion_method := AccrualCur.conversion_method;
            ltab_stim(ltab_stim.last).use_mass_ind := AccrualCur.use_mass_ind;
            ltab_stim(ltab_stim.last).use_volume_ind := AccrualCur.use_volume_ind;
            ltab_stim(ltab_stim.last).use_energy_ind := AccrualCur.use_energy_ind;
            ltab_stim(ltab_stim.last).use_extra1_ind := AccrualCur.use_extra1_ind;
            ltab_stim(ltab_stim.last).use_extra2_ind := AccrualCur.use_extra2_ind;
            ltab_stim(ltab_stim.last).use_extra3_ind := AccrualCur.use_extra3_ind;
        END LOOP;
     END IF;

     ln_processed := ltab_stim.count;

     FOR i IN 1..ltab_stim.count LOOP
      IF (ltab_stim(i).conversion_method = 'CONVERSION_FACTOR') THEN
        IF (ltab_stim(i).master_uom_group = 'V') THEN
           ln_qty := GetMthAccrualVol(ltab_stim(i).object_id, p_daytime, ltab_stim(i).volume_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_mth_value SET
               status = 'ACCRUAL',
               net_volume_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        ELSIF (ltab_stim(i).master_uom_group = 'M') THEN
           ln_qty := GetMthAccrualMass(ltab_stim(i).object_id, p_daytime, ltab_stim(i).mass_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_mth_value SET
               status = 'ACCRUAL',
               net_mass_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        ELSIF (ltab_stim(i).master_uom_group = 'E') THEN
           ln_qty := GetMthAccrualEnergy(ltab_stim(i).object_id, p_daytime, ltab_stim(i).energy_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_mth_value SET
               status = 'ACCRUAL',
               net_energy_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;

     ELSE --conversion_method = 'CALCULATED')
        IF (ltab_stim(i).use_volume_ind = 'Y') THEN
           ln_qty := GetMthAccrualVol(ltab_stim(i).object_id, p_daytime, ltab_stim(i).volume_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_mth_value SET
               status = 'ACCRUAL',
               net_volume_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_mass_ind = 'Y') THEN
           ln_qty := GetMthAccrualMass(ltab_stim(i).object_id, p_daytime, ltab_stim(i).mass_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_mth_value SET
               status = 'ACCRUAL',
               net_mass_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_energy_ind = 'Y') THEN
           ln_qty := GetMthAccrualEnergy(ltab_stim(i).object_id, p_daytime, ltab_stim(i).energy_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_mth_value SET
               status = 'ACCRUAL',
               net_energy_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_extra1_ind = 'Y') THEN
           ln_qty := GetMthAccrualExtra1(ltab_stim(i).object_id, p_daytime, ltab_stim(i).extra1_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_mth_value SET
               status = 'ACCRUAL',
               net_extra1_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_extra2_ind = 'Y') THEN
           ln_qty := GetMthAccrualExtra2(ltab_stim(i).object_id, p_daytime, ltab_stim(i).extra2_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_mth_value SET
               status = 'ACCRUAL',
               net_extra2_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;
        IF (ltab_stim(i).use_extra3_ind = 'Y') THEN
           ln_qty := GetMthAccrualExtra3(ltab_stim(i).object_id, p_daytime, ltab_stim(i).extra3_uom_code);
           IF (ln_qty IS NOT NULL) THEN
               ln_updated := ln_updated + 1;
               UPDATE stim_mth_value SET
               status = 'ACCRUAL',
               net_extra3_value = ln_qty,
               last_updated_by = p_user
               WHERE object_id = ltab_stim(i).object_id
               AND daytime = p_daytime;
           END IF;
        END IF;

       END IF;
        -- Insert into stim_cascade to mark SIs to run cascade for
        INSERT INTO stim_cascade (object_id,period,daytime) VALUES (ltab_stim(i).object_id, 'MTH', p_daytime);
     END LOOP;
     RETURN ln_processed || ' records processed, and ' || ln_updated || ' records updated';

END GenMthAccrual;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthAccrualVol                                                               --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_MTH_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanVol                                              --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthAccrualVol(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER

--<EC-DOC>

IS

CURSOR c_prev_mth( pc_daytime DATE) IS
SELECT EcDp_Revn_Unit.convertValue(net_volume_value, volume_uom_code, p_uom_code, p_object_id, p_daytime) vol
FROM stim_mth_value x
WHERE object_id = p_object_id
  AND daytime = pc_daytime;

CURSOR c_sum_day IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_volume_value), Max(volume_uom_code), p_uom_code, p_object_id, p_daytime)  vol
FROM stim_day_value
WHERE object_id = p_object_id
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_mth(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast
        lv2_return_val := GetMthPlanVol(p_object_id,p_daytime,'OFF',p_uom_code, NULL);

     ELSIF lv2_Accrual_Method = 'PREV_MTH' THEN

        -- take previous months available value
        FOR PrevMthCur IN c_prev_mth (Add_Months(p_daytime,-1)) LOOP

            lv2_return_val := PrevMthCur.vol;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'SUM_DAY' THEN

        -- take average daily number and multiply with number of days in month
        FOR AvgActualCur IN c_sum_day LOOP

            lv2_return_val := AvgActualCur.vol * (Last_Day(Trunc(p_daytime)) + 1 - Trunc(p_daytime,'MM'));

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetMthAccrualVol;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthAccrualMass                                                              --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_MTH_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanMass                                              --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthAccrualMass(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER

--<EC-DOC>

IS

CURSOR c_prev_mth( pc_daytime DATE) IS
SELECT EcDp_Revn_Unit.convertValue(net_mass_value, mass_uom_code, p_uom_code, p_object_id, p_daytime) mass
FROM stim_mth_value x
WHERE object_id = p_object_id
  AND daytime = pc_daytime;

CURSOR c_sum_day IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_mass_value), Max(mass_uom_code), p_uom_code, p_object_id, p_daytime) mass
FROM stim_day_value
WHERE object_id = p_object_id
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_mth(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast
        lv2_return_val := GetMthPlanMass(p_object_id,p_daytime,'OFF',p_uom_code, NULL);

     ELSIF lv2_Accrual_Method = 'PREV_MTH' THEN

        -- take previous months available value
        FOR PrevMthCur IN c_prev_mth (Add_Months(p_daytime,-1)) LOOP

            lv2_return_val := PrevMthCur.mass;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'SUM_DAY' THEN

        -- take average daily number and multiply with number of days in month
        FOR AvgActualCur IN c_sum_day LOOP

            lv2_return_val := AvgActualCur.mass * (Last_Day(Trunc(p_daytime)) + 1 - Trunc(p_daytime,'MM'));

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetMthAccrualMass;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthAccrualExtra1                                                              --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_MTH_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanExtra1                                              --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthAccrualExtra1(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER

--<EC-DOC>

IS

CURSOR c_prev_mth( pc_daytime DATE) IS
SELECT EcDp_Revn_Unit.convertValue(net_extra1_value, extra1_uom_code, p_uom_code, p_object_id, p_daytime) extra1
FROM stim_mth_value x
WHERE object_id = p_object_id
  AND daytime = pc_daytime;

CURSOR c_sum_day IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_extra1_value), Max(extra1_uom_code), p_uom_code, p_object_id, p_daytime) extra1
FROM stim_day_value
WHERE object_id = p_object_id
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_mth(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast
        lv2_return_val := GetMthPlanExtra1(p_object_id,p_daytime,'OFF',p_uom_code, NULL);

     ELSIF lv2_Accrual_Method = 'PREV_MTH' THEN

        -- take previous months available value
        FOR PrevMthCur IN c_prev_mth (Add_Months(p_daytime,-1)) LOOP

            lv2_return_val := PrevMthCur.extra1;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'SUM_DAY' THEN

        -- take average daily number and multiply with number of days in month
        FOR AvgActualCur IN c_sum_day LOOP

            lv2_return_val := AvgActualCur.extra1 * (Last_Day(Trunc(p_daytime)) + 1 - Trunc(p_daytime,'MM'));

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetMthAccrualExtra1;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthAccrualExtra2                                                              --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_MTH_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanExtra2                                              --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthAccrualExtra2(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER

--<EC-DOC>

IS

CURSOR c_prev_mth( pc_daytime DATE) IS
SELECT EcDp_Revn_Unit.convertValue(net_extra2_value, extra2_uom_code, p_uom_code, p_object_id, p_daytime) extra2
FROM stim_mth_value x
WHERE object_id = p_object_id
  AND daytime = pc_daytime;

CURSOR c_sum_day IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_extra2_value), Max(extra2_uom_code), p_uom_code, p_object_id, p_daytime) extra2
FROM stim_day_value
WHERE object_id = p_object_id
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_mth(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast
        lv2_return_val := GetMthPlanExtra2(p_object_id,p_daytime,'OFF',p_uom_code, NULL);

     ELSIF lv2_Accrual_Method = 'PREV_MTH' THEN

        -- take previous months available value
        FOR PrevMthCur IN c_prev_mth (Add_Months(p_daytime,-1)) LOOP

            lv2_return_val := PrevMthCur.extra2;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'SUM_DAY' THEN

        -- take average daily number and multiply with number of days in month
        FOR AvgActualCur IN c_sum_day LOOP

            lv2_return_val := AvgActualCur.extra2 * (Last_Day(Trunc(p_daytime)) + 1 - Trunc(p_daytime,'MM'));

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetMthAccrualExtra2;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthAccrualExtra3                                                              --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_MTH_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanExtra3                                              --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthAccrualExtra3(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER

--<EC-DOC>

IS

CURSOR c_prev_mth( pc_daytime DATE) IS
SELECT EcDp_Revn_Unit.convertValue(net_extra3_value, extra3_uom_code, p_uom_code, p_object_id, p_daytime) extra3
FROM stim_mth_value x
WHERE object_id = p_object_id
  AND daytime = pc_daytime;

CURSOR c_sum_day IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_extra3_value), Max(extra3_uom_code), p_uom_code, p_object_id, p_daytime) extra3
FROM stim_day_value
WHERE object_id = p_object_id
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_mth(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast
        lv2_return_val := GetMthPlanExtra3(p_object_id,p_daytime,'OFF',p_uom_code, NULL);

     ELSIF lv2_Accrual_Method = 'PREV_MTH' THEN

        -- take previous months available value
        FOR PrevMthCur IN c_prev_mth (Add_Months(p_daytime,-1)) LOOP

            lv2_return_val := PrevMthCur.extra3;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'SUM_DAY' THEN

        -- take average daily number and multiply with number of days in month
        FOR AvgActualCur IN c_sum_day LOOP

            lv2_return_val := AvgActualCur.extra3 * (Last_Day(Trunc(p_daytime)) + 1 - Trunc(p_daytime,'MM'));

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetMthAccrualExtra3;

FUNCTION GetMthAccrualFromDays(
   p_object_id           VARCHAR2,
   p_daytime             DATE, -- The month which days should be calculated from
   p_uom_code            VARCHAR2
)
RETURN NUMBER
IS

CURSOR c_days IS
SELECT
   net_mass_value,
   mass_uom_code,
   net_volume_value,
   volume_uom_code,
   net_energy_value,
   energy_uom_code
FROM
   stim_day_value
WHERE
   object_id = p_object_id
   AND daytime >= TRUNC(p_daytime, 'MM')
   AND daytime <= LAST_DAY(TRUNC(p_daytime, 'MM'));

ln_counter NUMBER := 0;
ln_value NUMBER := 0;
ln_avg_value NUMBER := 0;
ln_days_in_month NUMBER;

lv2_master_uom VARCHAR2(32) := NULL;
lv2_uom_code VARCHAR2(32) := NULL;

BEGIN

     lv2_master_uom := EcDp_Unit.GetUOMGroup(p_uom_code);
     -- EcDp_Objects.GetObjAttrText(p_object_id, p_daytime, 'MASTER_UOM_GROUP');

     FOR DayCur IN c_days LOOP
         IF (lv2_master_uom = 'M') THEN
             IF (DayCur.net_mass_value IS NOT NULL) THEN
                 ln_counter := ln_counter + 1;
                 ln_value := ln_value + DayCur.net_mass_value;
                 lv2_uom_code := DayCur.mass_uom_code;
             END IF;
         ELSIF (lv2_master_uom = 'V') THEN
             IF (DayCur.net_volume_value IS NOT NULL) THEN
                 ln_counter := ln_counter + 1;
                 ln_value := ln_value + DayCur.net_volume_value;
                 lv2_uom_code := DayCur.volume_uom_code;
             END IF;
         ELSIF (lv2_master_uom = 'E') THEN
             IF (DayCur.net_energy_value IS NOT NULL) THEN
                 ln_counter := ln_counter + 1;
                 ln_value := ln_value + DayCur.net_energy_value;
                 lv2_uom_code := DayCur.energy_uom_code;
             END IF;
         END IF;
     END LOOP;

     ln_days_in_month := (LAST_DAY(TRUNC(p_daytime, 'MM')) + 1) - TRUNC(p_daytime, 'MM');

     IF (ln_counter > 0) THEN
          ln_avg_value := ln_value / ln_counter; -- Avg per day for days with numbers
          ln_value := ln_avg_value * ln_days_in_month; -- Multiply by number of days in month
          ln_value := EcDp_Unit.convertValue(ln_value, lv2_uom_code, p_uom_code, p_daytime);
     END IF;

     RETURN ln_value;

END GetMthAccrualFromDays;


FUNCTION GetMthAccrualTextFromDays(
   p_object_id           VARCHAR2,
   p_daytime             DATE, -- The month which days should be calculated from
   p_uom_code            VARCHAR2
)
RETURN VARCHAR2
IS

CURSOR c_days IS
SELECT
   net_mass_value,
   mass_uom_code,
   net_volume_value,
   volume_uom_code,
   net_energy_value,
   energy_uom_code
FROM
   stim_day_value
WHERE
   object_id = p_object_id
   AND daytime >= TRUNC(p_daytime, 'MM')
   AND daytime <= LAST_DAY(TRUNC(p_daytime, 'MM'));

ln_counter NUMBER := 0;

lv2_master_uom VARCHAR2(32) := NULL;

lv2_text VARCHAR2(255) := NULL;

lv2_day_text VARCHAR2(32) := 'days';

BEGIN
     lv2_master_uom := EcDp_Unit.GetUOMGroup(p_uom_code);

     FOR DayCur IN c_days LOOP
         IF (lv2_master_uom = 'M') THEN
             IF (DayCur.net_mass_value IS NOT NULL) THEN
                 ln_counter := ln_counter + 1;
             END IF;
         ELSIF (lv2_master_uom = 'V') THEN
             IF (DayCur.net_volume_value IS NOT NULL) THEN
                 ln_counter := ln_counter + 1;
             END IF;
         ELSIF (lv2_master_uom = 'E') THEN
             IF (DayCur.net_energy_value IS NOT NULL) THEN
                 ln_counter := ln_counter + 1;
             END IF;
         END IF;
     END LOOP;

     IF (ln_counter = 1) THEN
        lv2_day_text := 'day';
     END IF;

     lv2_text := 'Accrual quantities based on ' || ln_counter || ' ' || lv2_day_text || ' of VO quantities.';

     RETURN lv2_text;

END GetMthAccrualTextFromDays;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthAccrualEnergy                                                              --
-- Description    : Get the accrual value according to accrual method defined at stream item level --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_MTH_VALUE                                                                       --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjAttrText                                                                              --
--                   EcDp_Stream_Item.GetMthPlanEnergy                                              --
--                   EcDp_UOM.unit_convert                                                        --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthAccrualEnergy(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_uom_code            VARCHAR2
)

RETURN NUMBER

--<EC-DOC>

IS

CURSOR c_prev_mth( pc_daytime DATE) IS
SELECT EcDp_Revn_Unit.convertValue(net_energy_value, energy_uom_code, p_uom_code, p_object_id, p_daytime) energy
FROM stim_mth_value x
WHERE object_id = p_object_id
  AND daytime = pc_daytime;

CURSOR c_sum_day IS
SELECT EcDp_Revn_Unit.convertValue(Avg(net_energy_value), Max(energy_uom_code), p_uom_code, p_object_id, p_daytime) energy
FROM stim_day_value
WHERE object_id = p_object_id
  AND daytime BETWEEN Trunc(p_daytime,'MM') AND Last_day(p_daytime);

unknown_accrual_method EXCEPTION;

lv2_Accrual_Method VARCHAR2(32) := ec_stream_item_version.accrual_method_mth(p_object_id,p_daytime,'<=');

lv2_return_val NUMBER;

BEGIN

     IF lv2_Accrual_Method IS NULL THEN RETURN NULL; END IF;

     IF lv2_Accrual_Method = 'PLAN_MTH' THEN

        -- take month's official forecast
        lv2_return_val := GetMthPlanEnergy(p_object_id,p_daytime,'OFF',p_uom_code, NULL);

     ELSIF lv2_Accrual_Method = 'PREV_MTH' THEN

        -- take previous months available value
        FOR PrevMthCur IN c_prev_mth (Add_Months(p_daytime,-1)) LOOP

            lv2_return_val := PrevMthCur.energy;

        END LOOP;


     ELSIF lv2_Accrual_Method = 'SUM_DAY' THEN

        -- take average daily number and multiply with number of days in month
        FOR AvgActualCur IN c_sum_day LOOP

            lv2_return_val := AvgActualCur.energy * (Last_Day(Trunc(p_daytime)) + 1 - Trunc(p_daytime,'MM'));

        END LOOP;
     ELSIF lv2_Accrual_Method IN ('MANUAL','MANUAL_ENTRY') THEN

           RETURN NULL;

     ELSE

         RAISE unknown_accrual_method;

     END IF;

     RETURN lv2_return_val;

EXCEPTION

         WHEN unknown_accrual_method THEN

              Raise_Application_Error(-20000,'Unknown accrual method ' || lv2_Accrual_Method || ' defined for stream item ' || Nvl(ec_stream_item.object_code(p_object_id) || ' - ' || ec_stream_item_version.name(p_object_id,p_daytime,'<=') , p_object_id) );

END GetMthAccrualEnergy;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthPlanVol                                                                  --
-- Description    : Get the planned volume from a stream item value                                --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  OBJECTS                                                                       --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthPlanVol(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER

--<EC-DOC>

IS

ln_return_val NUMBER;

BEGIN
  RETURN NULL; -- TODO: Implement proper method
/*
  IF p_company IS NULL THEN
    ln_return_val := 100;
  ELSE
    ln_return_val := 10;
  END IF;

  RETURN ln_return_val;
*/
END GetMthPlanVol;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthPlanMass                                                                 --
-- Description    : Get the planned volume from a stream item value                                --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  OBJECTS                                                                       --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthPlanMass(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER

--<EC-DOC>

IS

ln_return_val NUMBER;

BEGIN
  RETURN NULL; -- TODO: Implement proper method
/*
  IF p_company IS NULL THEN
    ln_return_val := 100;
  ELSE
    ln_return_val := 10;
  END IF;

  RETURN ln_return_val;
*/
END GetMthPlanMass;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthPlanEnergy                                                                --
-- Description    : Get the planned volume from a stream item value                                --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  OBJECTS                                                                       --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthPlanEnergy(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER

--<EC-DOC>

IS

ln_return_val NUMBER;

BEGIN
  RETURN NULL; -- TODO: Implement proper method
/*
  IF p_company IS NULL THEN
    ln_return_val := 100;
  ELSE
    ln_return_val := 10;
  END IF;

  RETURN ln_return_val;
*/
END GetMthPlanEnergy;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthPlanExtra1                                                               --
-- Description    : Get the planned volume from a stream item value                                --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  OBJECTS                                                                       --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthPlanExtra1(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER

--<EC-DOC>

IS

ln_return_val NUMBER;

BEGIN
  RETURN NULL; -- TODO: Implement proper method
/*
  IF p_company IS NULL THEN
    ln_return_val := 100;
  ELSE
    ln_return_val := 10;
  END IF;

  RETURN ln_return_val;
*/
END GetMthPlanExtra1;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthPlanExtra1                                                               --
-- Description    : Get the planned volume from a stream item value                                --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  OBJECTS                                                                       --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthPlanExtra2(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER

--<EC-DOC>

IS

ln_return_val NUMBER;

BEGIN
  RETURN NULL; -- TODO: Implement proper method
/*
  IF p_company IS NULL THEN
    ln_return_val := 100;
  ELSE
    ln_return_val := 10;
  END IF;

  RETURN ln_return_val;
*/
END GetMthPlanExtra2;
--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetMthPlanExtra1                                                               --
-- Description    : Get the planned volume from a stream item value                                --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  OBJECTS                                                                       --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetMthPlanExtra3(
   p_object_id           VARCHAR2,
   p_daytime             DATE,
   p_forecast_case       VARCHAR2,
   p_uom_code          VARCHAR2,
   p_company             VARCHAR2)

RETURN NUMBER

--<EC-DOC>

IS

ln_return_val NUMBER;

BEGIN
  RETURN NULL; -- TODO: Implement proper method
/*
  IF p_company IS NULL THEN
    ln_return_val := 100;
  ELSE
    ln_return_val := 10;
  END IF;

  RETURN ln_return_val;
*/
END GetMthPlanExtra3;

FUNCTION GetMthQtyByUOM(
   p_object_id           VARCHAR2,
   p_uom_code            VARCHAR2,
   p_daytime             DATE,
   p_allow_null          VARCHAR2 DEFAULT 'N'
      )

RETURN NUMBER

IS

can_not_convert EXCEPTION;

ln_return_val NUMBER := NULL;
ln_source_val NUMBER;

lv2_uom_grp VARCHAR2(32);
lv2_uom VARCHAR2(32) := p_uom_code;
lv2_stream_item_code VARCHAR2(32) := ec_stream_item.object_code(p_object_id);

BEGIN

     lv2_uom_grp := EcDp_Unit.GetUOMGroup(p_uom_code);
     BEGIN
       SELECT Decode(lv2_uom_grp,'V',EcDp_Unit.convertValue(net_volume_value, volume_uom_code, p_uom_code, p_daytime)
       ,'M',EcDp_Unit.convertValue(net_mass_value, mass_uom_code, p_uom_code, p_daytime)
       ,'E',EcDp_Unit.convertValue(net_energy_value, energy_uom_code, p_uom_code, p_daytime))
       ,Decode(lv2_uom_grp
       ,'V',net_volume_value
       ,'M',net_mass_value
       ,'E',net_energy_value)
       INTO ln_return_val, ln_source_val
       FROM stim_mth_value
       WHERE object_id = p_object_id
         AND daytime = TRUNC(p_daytime,'MM');
     EXCEPTION
         WHEN no_data_found THEN
             IF NOT 'Y' = p_allow_null THEN
                 Raise_Application_Error(-20000,'Stream Item not Instantiated : ' || lv2_stream_item_code);
             END IF;
     END;

     IF (ln_return_val IS NULL AND ln_source_val IS NOT NULL) THEN
        RAISE can_not_convert;
     END IF;
     RETURN ln_return_val;

EXCEPTION

WHEN can_not_convert THEN
   Raise_Application_Error(-20000,'Can not convert value to this UOM : ' || lv2_uom || ' for Stream Item : ' || lv2_stream_item_code);

END GetMthQtyByUOM;

FUNCTION GetMthMasterQty(
   p_object_id           VARCHAR2,
   p_daytime             DATE
      )

RETURN NUMBER

IS

ln_return_val NUMBER;

lv2_master_uom VARCHAR2(32) := ec_stream_item_version.master_uom_group(p_object_id, p_daytime, '<=');

BEGIN

     SELECT
            Decode(lv2_master_uom,'V',net_volume_value,'M',net_mass_value,'E',net_energy_value)
     INTO ln_return_val
     FROM stim_mth_value
     WHERE object_id = p_object_id
       AND daytime = TRUNC(p_daytime,'MM');

     RETURN ln_return_val;
END GetMthMasterQty;

FUNCTION GetMthMasterUom(
   p_object_id           VARCHAR2,
   p_daytime             DATE
      )
RETURN VARCHAR2

IS

lv2_return_val VARCHAR2(32);

lv2_master_uom VARCHAR2(32) := ec_stream_item_version.master_uom_group(p_object_id, p_daytime, '<=');
BEGIN

     SELECT
            Decode(lv2_master_uom,'V',volume_uom_code,'M',mass_uom_code,'E',energy_uom_code)
     INTO lv2_return_val
     FROM stim_mth_value
     WHERE object_id = p_object_id
       AND daytime = TRUNC(p_daytime,'MM');

     RETURN lv2_return_val;

END GetMthMasterUom;

FUNCTION GetDayMasterQty(
   p_object_id           VARCHAR2,
   p_daytime             DATE
      )
RETURN NUMBER

IS

ln_return_val NUMBER;

lv2_master_uom VARCHAR2(32) := ec_stream_item_version.master_uom_group(p_object_id, p_daytime, '<=');

BEGIN

     SELECT
            Decode(lv2_master_uom,'V',net_volume_value,'M',net_mass_value,'E',net_energy_value)
     INTO ln_return_val
     FROM stim_day_value
     WHERE object_id = p_object_id
       AND daytime = TRUNC(p_daytime,'DD');

     RETURN ln_return_val;

END GetDayMasterQty;

FUNCTION GetDayMasterUom(
   p_object_id           VARCHAR2,
   p_daytime             DATE
      )
RETURN VARCHAR2

IS

lv2_return_val VARCHAR2(32);

lv2_master_uom VARCHAR2(32) := ec_stream_item_version.master_uom_group(p_object_id, p_daytime, '<=');

BEGIN

     SELECT
            Decode(lv2_master_uom,'V',volume_uom_code,'M',mass_uom_code,'E',energy_uom_code)
     INTO lv2_return_val
     FROM stim_day_value
     WHERE object_id = p_object_id
       AND daytime = TRUNC(p_daytime,'DD');

     RETURN lv2_return_val;

END GetDayMasterUom;


---------------------------------------------------------------------------
--  FUNCTION isCalcMethodEditable
--
---------------------------------------------------------------------------

FUNCTION isCalcMethodEditable(
   p_calc_method      VARCHAR2
) RETURN varchar2
IS

BEGIN

     IF (p_calc_method = 'SP') THEN

        RETURN 'false';

     ELSE

        RETURN 'true';

     END IF;

END isCalcMethodEditable;

---------------------------------------------------------------------------
--  FUNCTION isStreamItemEditable
--
---------------------------------------------------------------------------

FUNCTION isStreamItemEditable(
   p_object_id        VARCHAR2,
   p_daytime          DATE,
   p_attribute_name   VARCHAR2,
   p_calc_method      VARCHAR2
) RETURN varchar2
IS

lv2_use VARCHAR2(32) := NULL;

BEGIN
     IF (p_attribute_name = 'USE_MASS') THEN
         lv2_use := ec_stream_item_version.use_mass_ind(p_object_id, p_daytime, '<=');
     ELSIF (p_attribute_name = 'USE_VOLUME') THEN
         lv2_use := ec_stream_item_version.use_volume_ind(p_object_id, p_daytime, '<=');
     ELSIF (p_attribute_name = 'USE_ENERGY') THEN
         lv2_use := ec_stream_item_version.use_energy_ind(p_object_id, p_daytime, '<=');
     ELSIF (p_attribute_name = 'USE_EXTRA1') THEN
         lv2_use := ec_stream_item_version.use_extra1_ind(p_object_id, p_daytime, '<=');
     ELSIF (p_attribute_name = 'USE_EXTRA2') THEN
         lv2_use := ec_stream_item_version.use_extra2_ind(p_object_id, p_daytime, '<=');
     ELSIF (p_attribute_name = 'USE_EXTRA3') THEN
         lv2_use := ec_stream_item_version.use_extra3_ind(p_object_id, p_daytime, '<=');
     -- 2010-02-05: Logic used from STIM_MTH_VALUE_CONV and STIM_DAY_VALUE_CONV:
     ELSIF (p_attribute_name = 'USE_DENSITY') THEN
       IF nvl(ec_stream_item_version.use_volume_ind(p_object_id, p_daytime, '<='),'N') = 'Y'
           AND nvl(ec_stream_item_version.use_mass_ind(p_object_id, p_daytime, '<='),'N') = 'Y' THEN
         RETURN 'true';
       END IF;
     ELSIF (p_attribute_name = 'USE_GCV') THEN
       IF nvl(ec_stream_item_version.use_volume_ind(p_object_id, p_daytime, '<='),'N') = 'Y'
           AND nvl(ec_stream_item_version.use_energy_ind(p_object_id, p_daytime, '<='),'N') = 'Y' THEN
         RETURN 'true';
       END IF;
     ELSIF (p_attribute_name = 'USE_MCV') THEN
       IF nvl(ec_stream_item_version.use_mass_ind(p_object_id, p_daytime, '<='),'N') = 'Y'
           AND nvl(ec_stream_item_version.use_energy_ind(p_object_id, p_daytime, '<='),'N') = 'Y' THEN
         RETURN 'true';
       END IF;
     ELSIF (p_attribute_name = 'USE_BOE') THEN
       RETURN 'true';
     END IF;

     IF ((lv2_use = 'Y') AND NOT (p_calc_method = 'SP')) THEN

        RETURN 'true';

     ELSE

        RETURN 'false';

     END IF;

END isStreamItemEditable;

---------------------------------------------------------------------------
--  FUNCTION GetSplitShareDay
--
---------------------------------------------------------------------------
FUNCTION GetSplitShareDay(
   p_object_id VARCHAR2,
   p_daytime   DATE
) RETURN NUMBER
IS

ln_share NUMBER;

CURSOR c_split(cp_object_id VARCHAR2, cp_member_id VARCHAR2) IS
SELECT t.object_id object_id, t.split_share_day split_share_day
  FROM split_key_setup t
 WHERE t.object_id = cp_object_id
   AND t.split_member_id = cp_member_id
   AND t.daytime = (SELECT MAX(daytime)
                      FROM split_key_setup t
                     WHERE t.object_id = cp_object_id
                       AND t.split_member_id = cp_member_id
                       AND t.daytime <= p_daytime)
;

lv2_split_key VARCHAR2(32) := ec_stream_item_version.split_key_id(p_object_id, p_daytime, '<=');
lv2_sk_type VARCHAR2(32);
lv2_member_id VARCHAR2(32);
BEGIN

    lv2_sk_type := ec_split_key_version.split_type(lv2_split_key, p_daytime, '<=');

    IF (lv2_sk_type = 'COMPANY') THEN
        lv2_member_id := ec_stream_item_version.split_company_id(p_object_id, p_daytime, '<=');
    ELSIF (lv2_sk_type = 'PRODUCT') THEN
        lv2_member_id := ec_stream_item_version.split_product_id(p_object_id, p_daytime, '<=');
    ELSIF (lv2_sk_type = 'FIELD') THEN
        lv2_member_id := ec_stream_item_version.split_field_id(p_object_id, p_daytime, '<=');
    ELSIF (lv2_sk_type = 'STREAM_ITEM_CATEGORY') THEN
        lv2_member_id := ec_stream_item_version.stream_item_category_id(p_object_id, p_daytime, '<=');
    ELSIF (lv2_sk_type = 'SPLIT_ITEM_OTHER') THEN
        lv2_member_id := ec_stream_item_version.split_item_other_id(p_object_id, p_daytime, '<=');
    END IF;

    FOR rSplit IN c_split(lv2_split_key, lv2_member_id) LOOP
        ln_share := rSplit.Split_Share_Day;
    END LOOP;

    RETURN ln_share;

END GetSplitShareDay;

---------------------------------------------------------------------------
--  FUNCTION GetSplitShareMth
--
---------------------------------------------------------------------------
FUNCTION GetSplitShareMth(
   p_object_id VARCHAR2,
   p_daytime   DATE
) RETURN NUMBER

IS

ln_share NUMBER;

CURSOR c_split(cp_object_id VARCHAR2, cp_member_id VARCHAR2) IS
SELECT t.object_id object_id, t.split_share_mth split_share_mth
  FROM split_key_setup t
 WHERE t.object_id = cp_object_id
   AND t.split_member_id = cp_member_id
   AND t.daytime = (SELECT MAX(daytime)
                      FROM split_key_setup t
                     WHERE t.object_id = cp_object_id
                       AND t.split_member_id = cp_member_id
                       AND t.daytime <= p_daytime);

lv2_split_key VARCHAR2(32) := ec_stream_item_version.split_key_id(p_object_id, p_daytime, '<=');
lv2_sk_type VARCHAR2(32);
lv2_member_id VARCHAR2(32);

BEGIN

    lv2_sk_type := ec_split_key_version.split_type(lv2_split_key, p_daytime, '<=');

    IF (lv2_sk_type = 'COMPANY') THEN
        lv2_member_id := ec_stream_item_version.split_company_id(p_object_id, p_daytime, '<=');
    ELSIF (lv2_sk_type = 'PRODUCT') THEN
        lv2_member_id := ec_stream_item_version.split_product_id(p_object_id, p_daytime, '<=');
    ELSIF (lv2_sk_type = 'FIELD') THEN
        lv2_member_id := ec_stream_item_version.split_field_id(p_object_id, p_daytime, '<=');
    ELSIF (lv2_sk_type = 'STREAM_ITEM_CATEGORY') THEN
        lv2_member_id := ec_stream_item_version.stream_item_category_id(p_object_id, p_daytime, '<=');
    ELSIF (lv2_sk_type = 'SPLIT_ITEM_OTHER') THEN
        lv2_member_id := ec_stream_item_version.split_item_other_id(p_object_id, p_daytime, '<=');
    END IF;

    FOR rSplit IN c_split(lv2_split_key, lv2_member_id) LOOP
        ln_share := rSplit.Split_Share_Mth;
    END LOOP;

    RETURN ln_share;

END GetSplitShareMth;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDefDensity                                                                  --
-- Description    : Get the valid default density value of a stream_item. Implements default logic --
--                  in following order: For a given product, 1. Look at any default at node level, --
--                  then at Field and finally at country.                                          --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                                                --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjIDFromRel                                                  --
--                   EcDp_Objects.GetObjIDFromRel                                                  --
--                   EcDp_Objects.GetObjRelAttrValue                                               --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetDefDensity(
   p_object_id           VARCHAR2,
   p_daytime             DATE
)

RETURN t_conversion

--<EC-DOC>

IS

lv2_product_id objects.object_id%TYPE;
lv2_node_id    objects.object_id%TYPE;
lv2_field_id objects.object_id%TYPE;
lv2_country_id objects.object_id%TYPE;
lv2_prod_obj_id objects.object_id%TYPE;

l_ConvFact t_conversion;

BEGIN
  -- Find product (via stream)

  lv2_product_id := ec_stream_item_version.product_id(p_object_id, p_daytime, '<=');

    -- 1. First see if density can be found at node level?
    IF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'TO_NODE') THEN
        lv2_node_id := ec_strm_version.to_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    ELSIF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'FROM_NODE') THEN
        lv2_node_id := ec_strm_version.from_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    END IF;
    lv2_prod_obj_id := getProductNodeId(lv2_product_id, lv2_node_id, p_daytime);
    l_ConvFact.factor := ec_product_node_version.density(lv2_prod_obj_id, p_daytime, '<=');

  IF l_ConvFact.factor IS NULL THEN

     -- 2. Then see if density can be found at Field level
    lv2_field_id := ec_stream_item_version.field_id(p_object_id, p_daytime, '<=');

    lv2_prod_obj_id := getProductFieldId(lv2_product_id, lv2_field_id, p_daytime);
    l_ConvFact.factor := ec_product_field_version.density(lv2_prod_obj_id, p_daytime, '<=');

    IF l_ConvFact.factor IS NULL THEN
          -- 3. Use country level default density (go via field)
        lv2_country_id := ec_field_version.country_id(lv2_field_id, p_daytime, '<=');

        lv2_prod_obj_id := getProductCountryId(lv2_product_id, lv2_country_id, p_daytime);
        l_ConvFact.factor := ec_product_country_version.density(lv2_prod_obj_id, p_daytime, '<=');

        IF l_ConvFact.factor IS NOT NULL THEN

            -- get additional info
          l_ConvFact.from_uom := ec_product_country_version.density_volume_uom(lv2_prod_obj_id, p_daytime, '<=');
          l_ConvFact.to_uom := ec_product_country_version.density_mass_uom(lv2_prod_obj_id, p_daytime, '<=');
          l_ConvFact.source := 'Country';
          l_ConvFact.source_object_id := lv2_prod_obj_id;

        END IF;

    ELSE -- we found a density at Field level

      -- get additional info
      l_ConvFact.from_uom := ec_product_field_version.density_volume_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.to_uom := ec_product_field_version.density_mass_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.source := 'Field';
      l_ConvFact.source_object_id := lv2_prod_obj_id;

      END IF;

   ELSE -- we found a density at node level

       -- get additional info
      l_ConvFact.from_uom := ec_product_node_version.density_volume_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.to_uom := ec_product_node_version.density_mass_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.source := 'Node';
      l_ConvFact.source_object_id := lv2_prod_obj_id;

   END IF;

  RETURN l_ConvFact;

END GetDefDensity;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDefMCV                                                                      --
-- Description    : Get the valid default MCV value of a stream_item. Implements default logic     --
--                  in following order: For a given product, 1. Look at any default at node level, --
--                  then at Field and finally at country.                                          --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                                                --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjIDFromRel                                                  --
--                   EcDp_Objects.GetObjIDFromRel                                                  --
--                   EcDp_Objects.GetObjRelAttrValue                                               --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetDefMCV(
   p_object_id           VARCHAR2,
   p_daytime             DATE
)

RETURN t_conversion

--<EC-DOC>

IS

lv2_product_id objects.object_id%TYPE;
lv2_node_id    objects.object_id%TYPE;
lv2_field_id objects.object_id%TYPE;
lv2_country_id objects.object_id%TYPE;
lv2_prod_obj_id objects.object_id%TYPE;

l_ConvFact t_conversion;

BEGIN

  -- Find product (via stream)

  lv2_product_id := ec_stream_item_version.product_id(p_object_id, p_daytime, '<=');

    -- 1. First see if MCV can be found at node level?
    IF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'TO_NODE') THEN
        lv2_node_id := ec_strm_version.to_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    ELSIF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'FROM_NODE') THEN
        lv2_node_id := ec_strm_version.from_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    END IF;
    lv2_prod_obj_id := getProductNodeId(lv2_product_id, lv2_node_id, p_daytime);
    l_ConvFact.factor := ec_product_node_version.mcv(lv2_prod_obj_id, p_daytime, '<=');

  IF l_ConvFact.factor IS NULL THEN

     -- 2. Then see if MCV can be found at Field level
     lv2_field_id := ec_stream_item_version.field_id(p_object_id, p_daytime, '<=');

     lv2_prod_obj_id := getProductFieldId(lv2_product_id, lv2_field_id, p_daytime);
     l_ConvFact.factor := ec_product_field_version.mcv(lv2_prod_obj_id, p_daytime, '<=');

    IF l_ConvFact.factor IS NULL THEN

          -- 3. Use country level default MCV (go via field)
         lv2_country_id := ec_field_version.country_id(lv2_field_id, p_daytime, '<=');

         lv2_prod_obj_id := getProductCountryId(lv2_product_id, lv2_country_id, p_daytime);
         l_ConvFact.factor := ec_product_country_version.mcv(lv2_prod_obj_id, p_daytime, '<=');

        IF l_ConvFact.factor IS NOT NULL THEN

            -- get additional info
          l_ConvFact.from_uom := ec_product_country_version.mcv_mass_uom(lv2_prod_obj_id, p_daytime, '<=');
          l_ConvFact.to_uom := ec_product_country_version.mcv_energy_uom(lv2_prod_obj_id, p_daytime, '<=');
          l_ConvFact.source := 'Country';
          l_ConvFact.source_object_id := lv2_prod_obj_id;

        END IF;


    ELSE -- we found a MCV at Field level

      -- get additional info
      l_ConvFact.from_uom := ec_product_field_version.mcv_mass_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.to_uom := ec_product_field_version.mcv_energy_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.source := 'Field';
      l_ConvFact.source_object_id := lv2_prod_obj_id;

      END IF;

   ELSE -- we found a MCV at node level

       -- get additional info
    l_ConvFact.from_uom := ec_product_node_version.mcv_mass_uom(lv2_prod_obj_id, p_daytime, '<=');
    l_ConvFact.to_uom := ec_product_node_version.mcv_energy_uom(lv2_prod_obj_id, p_daytime, '<=');
     l_ConvFact.source := 'Node';
    l_ConvFact.source_object_id := lv2_prod_obj_id;

   END IF;

  RETURN l_ConvFact;

END GetDefMCV;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDefGCV                                                                      --
-- Description    : Get the valid default GCV value of a stream_item. Implements default logic     --
--                  in following order: For a given product, 1. Look at any default at node level, --
--                  then at Field and finally at country.                                          --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                                                --
--                                                                                                 --
-- Using functions:  EcDp_Objects.GetObjIDFromRel                                                  --
--                   EcDp_Objects.GetObjIDFromRel                                                  --
--                   EcDp_Objects.GetObjRelAttrValue                                               --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetDefGCV(
   p_object_id           VARCHAR2,
   p_daytime             DATE
)

RETURN t_conversion

--<EC-DOC>

IS

lv2_product_id objects.object_id%TYPE;
lv2_node_id    objects.object_id%TYPE;
lv2_field_id objects.object_id%TYPE;
lv2_country_id objects.object_id%TYPE;
lv2_prod_obj_id objects.object_id%TYPE;

l_ConvFact     t_conversion;

BEGIN

  -- Find product (via stream)

  lv2_product_id := ec_stream_item_version.product_id(p_object_id, p_daytime, '<=');

    -- 1. First see if GCV can be found at node level?
    IF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'TO_NODE') THEN
        lv2_node_id := ec_strm_version.to_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    ELSIF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'FROM_NODE') THEN
        lv2_node_id := ec_strm_version.from_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    END IF;
    lv2_prod_obj_id := getProductNodeId(lv2_product_id, lv2_node_id, p_daytime);
    l_ConvFact.factor := ec_product_node_version.gcv(lv2_prod_obj_id, p_daytime, '<=');

  IF l_ConvFact.factor IS NULL THEN

     -- 2. Then see if GCV can be found at Field level
     lv2_field_id := ec_stream_item_version.field_id(p_object_id, p_daytime, '<=');

     lv2_prod_obj_id := getProductFieldId(lv2_product_id, lv2_field_id, p_daytime);
     l_ConvFact.factor := ec_product_field_version.gcv(lv2_prod_obj_id, p_daytime, '<=');

    IF l_ConvFact.factor IS NULL THEN

          -- 3. Use country level default GCV (go via field)
         lv2_country_id := ec_field_version.country_id(lv2_field_id, p_daytime, '<=');

         lv2_prod_obj_id := getProductCountryId(lv2_product_id, lv2_country_id, p_daytime);
         l_ConvFact.factor := ec_product_country_version.gcv(lv2_prod_obj_id, p_daytime, '<=');

        IF l_ConvFact.factor IS NOT NULL THEN

            -- get additional info
          l_ConvFact.from_uom := ec_product_country_version.gcv_volume_uom(lv2_prod_obj_id, p_daytime, '<=');
          l_ConvFact.to_uom := ec_product_country_version.gcv_energy_uom(lv2_prod_obj_id, p_daytime, '<=');
          l_ConvFact.source := 'Country';
          l_ConvFact.source_object_id := lv2_prod_obj_id;

        END IF;


    ELSE -- we found a GCV at Field level

      -- get additional info
      l_ConvFact.from_uom := ec_product_field_version.gcv_volume_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.to_uom := ec_product_field_version.gcv_energy_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.source := 'Field';
      l_ConvFact.source_object_id := lv2_prod_obj_id;

      END IF;

   ELSE -- we found a GCV at node level

       -- get additional info
      l_ConvFact.from_uom := ec_product_node_version.gcv_volume_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.to_uom := ec_product_node_version.gcv_energy_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.source := 'Node';
      l_ConvFact.source_object_id := lv2_prod_obj_id;

   END IF;

  RETURN l_ConvFact;

END GetDefGCV;




--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetDefBOE                                                                  --
-- Description    : Get the valid default BOE value of a stream_item. Implements default logic --
--                  in following order: For a given product, 1. Look at any default at node level, --
--                  then at Field and finally at country.                                          --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                                                --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION GetDefBOE(p_object_id VARCHAR2, p_daytime DATE)

RETURN t_conversion

--<EC-DOC>

IS

lv2_product_id objects.object_id%TYPE;
lv2_node_id    objects.object_id%TYPE;
lv2_field_id objects.object_id%TYPE;
lv2_country_id objects.object_id%TYPE;
lv2_prod_obj_id objects.object_id%TYPE;

l_ConvFact t_conversion;

BEGIN
  -- Find product (via stream)
  lv2_product_id := ec_stream_item_version.product_id(p_object_id, p_daytime, '<=');


    -- 1. First see if density can be found at node level?
    IF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'TO_NODE') THEN
        lv2_node_id := ec_strm_version.to_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    ELSIF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'FROM_NODE') THEN
        lv2_node_id := ec_strm_version.from_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    END IF;
    lv2_prod_obj_id := getProductNodeId(lv2_product_id, lv2_node_id, p_daytime,'BOE');
    l_ConvFact.factor := ec_product_node_version.boe_factor(lv2_prod_obj_id, p_daytime, '<=');

  IF l_ConvFact.factor IS NULL THEN

     -- 2. Then see if density can be found at Field level
    lv2_field_id := ec_stream_item_version.field_id(p_object_id, p_daytime, '<=');

    lv2_prod_obj_id := getProductFieldId(lv2_product_id, lv2_field_id, p_daytime,'BOE');
    l_ConvFact.factor := ec_product_field_version.boe_factor(lv2_prod_obj_id, p_daytime, '<=');

    IF l_ConvFact.factor IS NULL THEN
          -- 3. Use country level default density (go via field)
        lv2_country_id := ec_field_version.country_id(lv2_field_id, p_daytime, '<=');

        lv2_prod_obj_id := getProductCountryId(lv2_product_id, lv2_country_id, p_daytime,'BOE');
        l_ConvFact.factor := ec_product_country_version.boe_factor(lv2_prod_obj_id, p_daytime, '<=');

        IF l_ConvFact.factor IS NOT NULL THEN

            -- get additional info
          l_ConvFact.from_uom := ec_product_country_version.boe_from_uom(lv2_prod_obj_id, p_daytime, '<=');
          l_ConvFact.to_uom := ec_product_country_version.boe_to_uom(lv2_prod_obj_id, p_daytime, '<=');
          l_ConvFact.source := 'Country';
          l_ConvFact.source_object_id := lv2_prod_obj_id;

        END IF;

    ELSE -- we found a density at Field level

      -- get additional info
      l_ConvFact.from_uom := ec_product_field_version.boe_from_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.to_uom := ec_product_field_version.boe_to_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.source := 'Field';
      l_ConvFact.source_object_id := lv2_prod_obj_id;

      END IF;

   ELSE -- we found a density at node level

       -- get additional info
      l_ConvFact.from_uom := ec_product_node_version.boe_from_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.to_uom := ec_product_node_version.boe_to_uom(lv2_prod_obj_id, p_daytime, '<=');
      l_ConvFact.source := 'Node';
      l_ConvFact.source_object_id := lv2_prod_obj_id;

   END IF;

  RETURN l_ConvFact;

END GetDefBOE;


PROCEDURE InsGenPeriodFromSIList(
   p_list_id             VARCHAR2,
   p_start_date          DATE,
   p_end_date            DATE,
   p_period_type         VARCHAR2
)

IS
/*
CURSOR c_list IS
SELECT to_object_id id
FROM objects_relation
WHERE from_object_id = p_list_id
  AND p_start_date <= Nvl(end_date,p_start_date+1)
  AND p_end_date >= Nvl(start_date,p_end_date-1);
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
     FOR StrmItmCur IN c_list LOOP

         -- for each stream item in list insert new records
         INSERT INTO STIM_PERIOD_GEN_VALUE
            (object_id, daytime, end_date, period, created_by)
          VALUES
            (StrmItmCur.id, p_start_date, p_end_date, p_period_type, 'SYSTEM' );

     END LOOP;
*/

END InsGenPeriodFromSIList;

PROCEDURE DelEmptyGenPeriod

IS

BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
     DELETE FROM STIM_PERIOD_GEN_VALUE
     WHERE status IS NULL; -- any records which has been used has a set status
*/
END DelEmptyGenPeriod;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : Gen_Period_Day                                                                 --
-- Description    : This procedure will generate dayly data in STIM_DAY_VALUE based on total       --
--                  figures for a period                                                           --
--                                                                                                 --
-- Preconditions  :  Records instantiated in STIM_DAY_VALUE                                        --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_DAY_VALUE                                                                --
--                                                                                                 --
-- Using functions:                                                                                --
--                                                                                                 --
--                                                                                                 --
--                                                                                                 --
-- Configuration  : Call this procedure from trigger on STIM_PERIOD_GEN_VALUE                      --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
/*
PROCEDURE GenPeriodDay(
   p_stim_gen_period_rec stim_period_gen_value%ROWTYPE
)

--<EC-DOC>

IS

no_valid_master_uom EXCEPTION;
no_data EXCEPTION;

li_count INTEGER;
li_num_days INTEGER := Trunc(p_stim_gen_period_rec.end_date - p_stim_gen_period_rec.daytime);

ib_done BOOLEAN := FALSE;
lv2_master_uom VARCHAR2(32);

BEGIN

   FOR li_count IN 0..li_num_days LOOP

    IF  p_stim_gen_period_rec.status = 'ACCRUAL' THEN

       ----------------------------------------------------------------------------------------------
       -- Find master UOM Group and calculate accruals
       lv2_master_uom := EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id, p_stim_gen_period_rec.daytime, 'MASTER_UOM_GROUP');
       IF lv2_master_uom NOT IN ('V','M','E') OR lv2_master_uom IS NULL THEN RAISE no_valid_master_uom; END IF;

       IF lv2_master_uom = 'V' AND p_stim_gen_period_rec.NET_VOLUME_VALUE IS NULL THEN

          UPDATE stim_day_value
            SET STATUS     =  p_stim_gen_period_rec.status
            ,PERIOD_REF_ITEM = 'Generated from period ' || to_char(p_stim_gen_period_rec.daytime,'dd.mm.yyyy') || ' - ' ||  to_char(p_stim_gen_period_rec.end_date,'dd.mm.yyyy')
            ,CALC_METHOD     = 'DE'
            ,NET_VOLUME_VALUE  = EcDp_Stream_Item.GetDayAccrualVol(object_id,daytime,p_stim_gen_period_rec.volume_uom_code)
            ,VOLUME_UOM_CODE   = p_stim_gen_period_rec.volume_uom_code
            ,LAST_UPDATED_BY   = p_stim_gen_period_rec.last_updated_by
          WHERE object_id = p_stim_gen_period_rec.object_id
            AND daytime = p_stim_gen_period_rec.daytime + li_count
            AND calc_method IN ('IP','DE');

          IF SQL%NOTFOUND THEN

             -- Not being able to update a row either because it has been changed by user (calc_methd = 'OW') or not instantiated
             -- should result in error situation

             RAISE no_data;

          END IF;

          ib_done := TRUE;

       ELSIF lv2_master_uom = 'M' AND p_stim_gen_period_rec.NET_MASS_VALUE IS NULL THEN

          UPDATE stim_day_value
            SET STATUS     =  p_stim_gen_period_rec.status
            ,PERIOD_REF_ITEM = 'Generated from period ' || to_char(p_stim_gen_period_rec.daytime,'dd.mm.yyyy') || ' - ' ||  to_char(p_stim_gen_period_rec.end_date,'dd.mm.yyyy')
            ,CALC_METHOD     = 'DE'
            ,NET_MASS_VALUE  = EcDp_Stream_Item.GetDayAccrualMass(object_id,daytime,p_stim_gen_period_rec.volume_uom_code)
            ,MASS_UOM_CODE   = p_stim_gen_period_rec.mass_uom_code
            ,LAST_UPDATED_BY   = p_stim_gen_period_rec.last_updated_by
          WHERE object_id = p_stim_gen_period_rec.object_id
            AND daytime = p_stim_gen_period_rec.daytime + li_count
            AND calc_method IN ('IP','DE');

          IF SQL%NOTFOUND THEN

             -- Not being able to update a row either because it has been changed by user (calc_methd = 'OW') or not instantiated
             -- should result in error situation

             RAISE no_data;

          END IF;

          ib_done := TRUE;

       ELSIF lv2_master_uom = 'E' AND p_stim_gen_period_rec.NET_ENERGY_VALUE IS NULL THEN

          UPDATE stim_day_value
            SET STATUS     =  p_stim_gen_period_rec.status
            ,PERIOD_REF_ITEM = 'Generated from period ' || to_char(p_stim_gen_period_rec.daytime,'dd.mm.yyyy') || ' - ' ||  to_char(p_stim_gen_period_rec.end_date,'dd.mm.yyyy')
            ,CALC_METHOD     = 'DE'
            ,NET_ENERGY_VALUE  = EcDp_Stream_Item.GetDayAccrualEnergy(object_id,daytime,p_stim_gen_period_rec.volume_uom_code)
            ,ENERGY_UOM_CODE   = p_stim_gen_period_rec.energy_uom_code
            ,LAST_UPDATED_BY   = p_stim_gen_period_rec.last_updated_by
          WHERE object_id = p_stim_gen_period_rec.object_id
            AND daytime = p_stim_gen_period_rec.daytime + li_count
            AND calc_method IN ('IP','DE');

          IF SQL%NOTFOUND THEN

             -- Not being able to update a row either because it has been changed by user (calc_methd = 'OW') or not instantiated
             -- should result in error situation

             RAISE no_data;

          END IF;

          ib_done := TRUE;

       ELSE

           ib_done := FALSE; -- continue

       END IF;

     END IF;

     IF NOT ib_done THEN

      UPDATE stim_day_value
        SET STATUS     =  p_stim_gen_period_rec.status
        ,PERIOD_REF_ITEM = 'Generated from period ' || to_char(p_stim_gen_period_rec.daytime,'dd.mm.yyyy') || ' - ' ||  to_char(p_stim_gen_period_rec.end_date,'dd.mm.yyyy')
        ,CALC_METHOD     = 'DE'
        ,NET_MASS_VALUE    = p_stim_gen_period_rec.net_mass_value /  (li_num_days+1)    -- divide by number of days to get a daily figure
        ,MASS_UOM_CODE     = p_stim_gen_period_rec.mass_uom_code
        ,NET_VOLUME_VALUE  = p_stim_gen_period_rec.net_volume_value /  (li_num_days+1)    -- divide by number of days to get a daily figure
        ,VOLUME_UOM_CODE   = p_stim_gen_period_rec.volume_uom_code
        ,NET_ENERGY_VALUE  = p_stim_gen_period_rec.net_energy_value /  (li_num_days+1)    -- divide by number of days to get a daily figure
        ,ENERGY_UOM_CODE   = p_stim_gen_period_rec.energy_uom_code
        ,NET_EXTRA1_VALUE  = p_stim_gen_period_rec.net_extra1_value /  (li_num_days+1)   -- divide by number of days to get a daily figure
        ,EXTRA1_UOM_CODE   = p_stim_gen_period_rec.extra1_uom_code
        ,NET_EXTRA2_VALUE  = p_stim_gen_period_rec.net_extra2_value /  (li_num_days+1)    -- divide by number of days to get a daily figure
        ,EXTRA2_UOM_CODE   = p_stim_gen_period_rec.extra2_uom_code
        ,NET_EXTRA3_VALUE  = p_stim_gen_period_rec.net_extra3_value /  (li_num_days+1)    -- divide by number of days to get a daily figure
        ,EXTRA3_UOM_CODE   = p_stim_gen_period_rec.extra3_uom_code
        ,CREATED_BY        = 'PERIOD_GEN' -- use this to inform trigger !
        ,LAST_UPDATED_BY   = p_stim_gen_period_rec.last_updated_by
        ,COMMENTS          = p_stim_gen_period_rec.comments
    WHERE object_id = p_stim_gen_period_rec.object_id
            AND daytime = p_stim_gen_period_rec.daytime + li_count
      AND calc_method IN ('IP','DE');

      IF SQL%NOTFOUND THEN

         -- Not being able to update a row either because it has been changed by user (calc_methd = 'OW') or not instantiated
         -- should result in error situation

         RAISE no_data; -- standard exception

      END IF;

    END IF;

  END LOOP;

     -- No transaction management here, may be called from trigger

EXCEPTION

     WHEN no_data THEN

         RAISE_APPLICATION_ERROR(-20000,'Cannot generate period data due to data not being instantiated or records being overwritten (OW) for stream item: '|| Nvl( EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id,p_stim_gen_period_rec.daytime,'CODE'), ' ') || '    ' || Nvl( EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id,p_stim_gen_period_rec.daytime,'NAME'), ' ')  ) ;

     WHEN no_valid_master_uom THEN

         RAISE_APPLICATION_ERROR(-20000,'No valid UOM master for stream item: '|| Nvl( EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id,p_stim_gen_period_rec.daytime,'CODE'), ' ') || '    ' || Nvl( EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id,p_stim_gen_period_rec.daytime,'NAME'), ' ')  ) ;

END GenPeriodDay;

*/

PROCEDURE InstantiateMths(p_start_date DATE,
          p_end_date DATE,
          p_company_id VARCHAR2 DEFAULT NULL)
IS

ln_from_month NUMBER;
ln_from_year NUMBER;
ln_to_month NUMBER;
ln_to_year NUMBER;
ln_count NUMBER;
BEGIN

     -- Count the number of days between start and end date

     ln_from_month := to_number(to_char(p_start_date,'MM'));
      ln_from_year := to_number(to_char(p_start_date,'yyyy'));
      ln_to_month := to_number(to_char(p_end_date,'MM'));
      ln_to_year := to_number(to_char(p_end_date,'yyyy'));

      IF ln_from_month < ln_to_month then
         ln_count := (ln_to_month - ln_from_month) + ((ln_to_year - ln_from_year )*12);
      elsif ln_to_month = ln_from_month then
         ln_count := ((ln_to_year - ln_from_year) * 12 ) ;
      else
         ln_count := ((ln_to_year - ln_from_year)*12) - (ln_from_month - ln_to_month );
      end if;
     -- Loop through every day and instantiate
     FOR ln_counter IN 0..ln_count LOOP
         InstantiateMth(add_months(p_start_date, ln_counter),p_company_id );
     END LOOP;

end InstantiateMths;

/*
PROCEDURE GenPeriodMth(
   p_stim_gen_period_rec stim_period_gen_value%ROWTYPE
)

--<EC-DOC>

IS

CURSOR c_last_mth IS
SELECT Max(daytime) daytime
FROM stim_mth_value
WHERE object_id = p_stim_gen_period_rec.object_id
  AND (net_volume_value IS NULL AND net_mass_value IS NULL AND net_energy_value IS NULL) -- do not count empty records
  AND daytime BETWEEN Trunc(p_stim_gen_period_rec.daytime,'YYYY') AND p_stim_gen_period_rec.end_date;


no_valid_master_uom EXCEPTION;
no_data EXCEPTION;

li_count INTEGER;
li_num_mths INTEGER;

ld_last_mth DATE;

ib_done BOOLEAN := FALSE;
lv2_master_uom VARCHAR2(32);

lrec_siv t_siv_net;


BEGIN

   -- Get last month
   FOR LstMthCur IN c_last_mth LOOP

      ld_last_mth := LstMthCur.daytime;

   END LOOP;

   -- if no last month, set
   IF ld_last_mth IS NULL THEN
      ld_last_mth := p_stim_gen_period_rec.end_date;
   END IF;

   IF p_stim_gen_period_rec.end_date = ld_last_mth THEN

      -- First month of year
      li_num_mths := 1;

   ELSE

       li_num_mths := Trunc( Months_Between(p_stim_gen_period_rec.end_date, ld_last_mth) );

   END IF;


     FOR li_count IN 1 .. li_num_mths LOOP

        IF  p_stim_gen_period_rec.status = 'ACCRUAL' THEN

       ----------------------------------------------------------------------------------------------
       -- Find master UOM Group and calculate accruals
       lv2_master_uom := EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id, p_stim_gen_period_rec.daytime, 'MASTER_UOM_GROUP');
       IF lv2_master_uom NOT IN ('V','M','E') OR lv2_master_uom IS NULL THEN RAISE no_valid_master_uom; END IF;

       IF lv2_master_uom = 'V' AND p_stim_gen_period_rec.NET_VOLUME_VALUE IS NULL THEN

        UPDATE stim_mth_value
          SET STATUS     =  p_stim_gen_period_rec.status
          ,PERIOD_REF_ITEM = 'Generated from period ' || to_char(p_stim_gen_period_rec.daytime,'dd.mm.yyyy') || ' - ' ||  to_char(p_stim_gen_period_rec.end_date,'dd.mm.yyyy')
          ,CALC_METHOD     = 'DE'
          ,NET_VOLUME_VALUE  = EcDp_Stream_Item.GetMthAccrualVol(object_id,daytime,p_stim_gen_period_rec.volume_uom_code)
          ,VOLUME_UOM_CODE   = p_stim_gen_period_rec.volume_uom_code
          ,LAST_UPDATED_BY   = p_stim_gen_period_rec.last_updated_by
        WHERE object_id = p_stim_gen_period_rec.object_id
          AND calc_method IN ('IP','DE');

        IF SQL%NOTFOUND THEN

           -- Not being able to update a row either because it has been changed by user (calc_methd = 'OW') or not instantiated
           -- should result in error situation

           RAISE no_data;

        END IF;

          ib_done := TRUE;

       ELSIF lv2_master_uom = 'M' AND p_stim_gen_period_rec.NET_MASS_VALUE IS NULL THEN

        UPDATE stim_mth_value
          SET STATUS     =  p_stim_gen_period_rec.status
          ,PERIOD_REF_ITEM = 'Generated from period ' || to_char(p_stim_gen_period_rec.daytime,'dd.mm.yyyy') || ' - ' ||  to_char(p_stim_gen_period_rec.end_date,'dd.mm.yyyy')
          ,CALC_METHOD     = 'DE'
          ,NET_MASS_VALUE  = EcDp_Stream_Item.GetMthAccrualMass(object_id,daytime,p_stim_gen_period_rec.volume_uom_code)
          ,MASS_UOM_CODE   = p_stim_gen_period_rec.mass_uom_code
          ,LAST_UPDATED_BY   = p_stim_gen_period_rec.last_updated_by
        WHERE object_id = p_stim_gen_period_rec.object_id
          AND daytime = Add_Months(p_stim_gen_period_rec.end_date, 1 - li_count)
          AND calc_method IN ('IP','DE');

        IF SQL%NOTFOUND THEN

           -- Not being able to update a row either because it has been changed by user (calc_methd = 'OW') or not instantiated
           -- should result in error situation

           RAISE no_data;

        END IF;

          ib_done := TRUE;

       ELSIF lv2_master_uom = 'E' AND p_stim_gen_period_rec.NET_ENERGY_VALUE IS NULL THEN

        UPDATE stim_mth_value
          SET STATUS     =  p_stim_gen_period_rec.status
          ,PERIOD_REF_ITEM = 'Generated from period ' || to_char(p_stim_gen_period_rec.daytime,'dd.mm.yyyy') || ' - ' ||  to_char(p_stim_gen_period_rec.end_date,'dd.mm.yyyy')
          ,CALC_METHOD     = 'DE'
          ,NET_ENERGY_VALUE  = EcDp_Stream_Item.GetMthAccrualEnergy(object_id,daytime,p_stim_gen_period_rec.volume_uom_code)
          ,ENERGY_UOM_CODE   = p_stim_gen_period_rec.energy_uom_code
          ,LAST_UPDATED_BY   = p_stim_gen_period_rec.last_updated_by
        WHERE object_id = p_stim_gen_period_rec.object_id
          AND daytime = Add_Months(p_stim_gen_period_rec.end_date, 1 - li_count)
          AND calc_method IN ('IP','DE');

        IF SQL%NOTFOUND THEN

           -- Not being able to update a row either because it has been changed by user (calc_methd = 'OW') or not instantiated
           -- should result in error situation

           RAISE no_data;

        END IF;

          ib_done := TRUE;

       ELSE

           ib_done := FALSE; -- continue

       END IF;

     END IF;

    lrec_siv.net_mass_value  := ( p_stim_gen_period_rec.net_mass_value
                                           - Nvl( ec_stim_mth_value.math_net_mass_value(p_stim_gen_period_rec.object_id, trunc(p_stim_gen_period_rec.daytime,'YYYY'), p_stim_gen_period_rec.end_date),0 ) )
                                                                    /  li_num_mths;

    lrec_siv.net_volume_value := ( p_stim_gen_period_rec.net_volume_value
                                           - Nvl( ec_stim_mth_value.math_net_volume_value(p_stim_gen_period_rec.object_id, trunc(p_stim_gen_period_rec.daytime,'YYYY'), p_stim_gen_period_rec.end_date),0 ) )
                                                                    /  li_num_mths;

    lrec_siv.net_energy_value := ( p_stim_gen_period_rec.net_energy_value
                                           - Nvl( ec_stim_mth_value.math_net_energy_value(p_stim_gen_period_rec.object_id, trunc(p_stim_gen_period_rec.daytime,'YYYY'), p_stim_gen_period_rec.end_date),0 ) )
                                                                    /  li_num_mths;

    lrec_siv.net_extra1_value  := ( p_stim_gen_period_rec.net_extra1_value
                                           - Nvl( ec_stim_mth_value.math_net_extra1_value(p_stim_gen_period_rec.object_id, trunc(p_stim_gen_period_rec.daytime,'YYYY'), p_stim_gen_period_rec.end_date),0 ) )
                                                                    /  li_num_mths;

    lrec_siv.net_extra2_value  := ( p_stim_gen_period_rec.net_extra2_value
                                           - Nvl( ec_stim_mth_value.math_net_extra2_value(p_stim_gen_period_rec.object_id, trunc(p_stim_gen_period_rec.daytime,'YYYY'), p_stim_gen_period_rec.end_date),0 ) )
                                                                    /  li_num_mths;

    lrec_siv.net_extra3_value  := ( p_stim_gen_period_rec.net_extra3_value
                                           - Nvl( ec_stim_mth_value.math_net_extra3_value(p_stim_gen_period_rec.object_id, trunc(p_stim_gen_period_rec.daytime,'YYYY'), p_stim_gen_period_rec.end_date),0 ) )
                                                                    /  li_num_mths;

      UPDATE stim_mth_value
        SET STATUS     =  p_stim_gen_period_rec.status
        ,PERIOD_REF_ITEM = 'Generated from period ' || to_char(p_stim_gen_period_rec.daytime,'mm.yyyy') || ' - ' ||  to_char(p_stim_gen_period_rec.end_date,'mm.yyyy')
        ,CALC_METHOD     = 'DE'
        ,NET_MASS_VALUE    = Nvl(NET_MASS_VALUE,0) + lrec_siv.net_mass_value
        ,MASS_UOM_CODE     = p_stim_gen_period_rec.mass_uom_code
        ,NET_VOLUME_VALUE  = Nvl(NET_VOLUME_VALUE,0) + lrec_siv.net_volume_value
        ,VOLUME_UOM_CODE   = p_stim_gen_period_rec.volume_uom_code
        ,NET_ENERGY_VALUE  = Nvl(NET_ENERGY_VALUE,0) + lrec_siv.net_energy_value
        ,ENERGY_UOM_CODE   = p_stim_gen_period_rec.energy_uom_code
        ,NET_EXTRA1_VALUE  = Nvl(NET_EXTRA1_VALUE,0) + lrec_siv.net_extra1_value
        ,EXTRA1_UOM_CODE   = p_stim_gen_period_rec.extra1_uom_code
        ,NET_EXTRA2_VALUE  = Nvl(NET_EXTRA2_VALUE,0) + lrec_siv.net_extra2_value
        ,EXTRA2_UOM_CODE   = p_stim_gen_period_rec.extra2_uom_code
        ,NET_EXTRA3_VALUE  = Nvl(NET_EXTRA3_VALUE,0) + lrec_siv.net_extra3_value
        ,EXTRA3_UOM_CODE   = p_stim_gen_period_rec.extra3_uom_code
        ,CREATED_BY        = 'PERIOD_GEN' -- use this to inform trigger !
        ,LAST_UPDATED_BY   = p_stim_gen_period_rec.last_updated_by
        ,COMMENTS          = p_stim_gen_period_rec.comments
    WHERE object_id = p_stim_gen_period_rec.object_id
          AND daytime = Add_Months(p_stim_gen_period_rec.end_date, 1 - li_count)
      AND calc_method IN ('IP','DE');

    IF SQL%NOTFOUND THEN

       -- Not being able to update a row either because it has been changed by user (calc_methd = 'OW') or not instantiated
       -- should result in error situation

       RAISE no_data;

    END IF;

     END LOOP;

     -- No transaction management here, may be called from trigger
EXCEPTION

     WHEN no_data THEN

         RAISE_APPLICATION_ERROR(-20000,'Cannot generate period data due to data not being instantiated or records being overwritten (OW) for stream item: '|| Nvl( EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id,p_stim_gen_period_rec.daytime,'CODE'), ' ') || '    ' || Nvl( EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id,p_stim_gen_period_rec.daytime,'NAME'), ' ')  ) ;

     WHEN no_valid_master_uom THEN

         RAISE_APPLICATION_ERROR(-20000,'No valid UOM master for stream item: '|| Nvl( EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id,p_stim_gen_period_rec.daytime,'CODE'), ' ') || '    ' || Nvl( EcDp_Objects.GetObjAttrText(p_stim_gen_period_rec.object_id,p_stim_gen_period_rec.daytime,'NAME'), ' ')  ) ;

END GenPeriodMth;
*/
/**
InstantiateVO will pass the parameters to InstantiateDay and InstantiateMth procedures for processing  Object_List and Company.
**/

PROCEDURE InstantiateVO(p_daytime DATE, p_company_id VARCHAR2 DEFAULT NULL, p_object_list VARCHAR2 DEFAULT NULL, p_type VARCHAR2) IS

CURSOR c_object_id is
SELECT
        a.object_id as COMPANY_ID,
        a.object_code as COMPANY_CODE
FROM company a, OBJECT_LIST_SETUP b, ov_object_list c
WHERE a.object_code=b.generic_object_code and a.class_name = 'COMPANY'
        and c.generic_class_name = 'COMPANY' and b.object_id =c.object_id
        and c.object_id = NVL(p_object_list,'1')
UNION
SELECT object_id,object_code from company where object_id = NVL(p_company_id,'1');

BEGIN
  -- If user does not select OBJECT_LIST
 IF p_object_list IS NULL THEN
     IF p_type ='DAY' THEN
       InstantiateDay(p_daytime, p_company_id);
     ELSIF p_type ='MTH' THEN
       InstantiateMth(p_daytime, p_company_id);
     END IF;

 ELSE
        FOR comp_rec IN c_object_id LOOP
          IF p_type ='DAY' THEN
            InstantiateDay(p_daytime, comp_rec.COMPANY_ID);
          ELSIF p_type ='MTH' THEN
            InstantiateMth(p_daytime, comp_rec.COMPANY_ID);
          END IF;
        END LOOP;
   END IF;
END InstantiateVO;


PROCEDURE InstantiateDay(p_daytime DATE, p_company_id VARCHAR2 DEFAULT NULL, p_si_object_id VARCHAR2 DEFAULT NULL) IS

CURSOR c_stream_items IS
SELECT object_id, ec_stream_item_version.conversion_method(object_id,daytime,'<=') conversion_method
FROM stim_day_value
WHERE daytime = trunc(p_daytime,'DD')
AND last_updated_by = 'INSTANTIATE'
AND DECODE(p_company_id,NULL,'1', ec_stream_item_version.company_id(object_id, daytime, '<=')) = NVL(p_company_id,'1')
AND (p_si_object_id IS NULL OR object_id = p_si_object_id);


CURSOR c_prevDay(p_object_id varchar2) IS
SELECT *
FROM  stim_day_value
WHERE object_id = p_object_id
AND daytime = trunc(p_daytime,'DD') - 1;

l_ConvFact               t_conversion;
l_stim_day_value         stim_day_value%ROWTYPE;
lv2_set_to_zero          varchar2(240);
ld2_daytime DATE := trunc(p_daytime,'DD');

lv2_status stim_day_value.status%TYPE := NULL;
ln_value NUMBER;
lv2_status_flag VARCHAR2(240);

BEGIN
  -- insert all valid stream_items for a given day
    INSERT INTO stim_day_value
        (OBJECT_ID
        ,DAYTIME
        ,CREATED_BY
        ,LAST_UPDATED_BY -- include this during insert to allow for standard processing in subsequent updates
        ,REV_TEXT
        )
       SELECT
         OBJECT_ID
        ,ld2_daytime
        ,'INSTANTIATE'
        ,'INSTANTIATE'
        ,'Instantiated record'
       FROM stream_item x
       WHERE ld2_daytime BETWEEN Nvl(start_date,ld2_daytime-1) AND Nvl(end_date,ld2_daytime+1)
       AND DECODE(p_company_id,NULL,'1', ec_stream_item_version.company_id(object_id, ld2_daytime, '<=')) = NVL(p_company_id,'1')
       AND (p_si_object_id IS NULL OR object_id = p_si_object_id)
       AND NOT EXISTS (SELECT 'x' FROM stim_day_value WHERE object_id = x.object_id AND daytime = ld2_daytime);


    ---------------------------------------------------------------------------
    -- Need to set default UOM from Stream_Item Attributes
    --
    ---------------------------------------------------------------------------

    -- AV 10.03.2004  To avoid trigging the cascade logic 4 times, rewrote logic here to do
    --                everyting in one update, to get this right have to handle one stream item at the time
    --                this will make it less resource demanding on rollback segments, having commits at regular
    --                intervals will also allow the cascade process to run in parallell with instatiation.

    FOR StrmItm IN c_stream_items LOOP -- loop all to avoid 4 calls per entry

        l_stim_day_value.CALC_METHOD := ec_stream_item_version.calc_method(StrmItm.object_id, ld2_daytime, '<=');

        lv2_status := null;

        lv2_set_to_zero := ec_stream_item_version.set_to_zero_method_day(StrmItm.object_id, ld2_daytime, '<=');


         ---------------------------------------------------------------------------
      -- Default UOMs
      ---------------------------------------------------------------------------
        l_stim_day_value.VOLUME_UOM_CODE := ec_stream_item_version.default_uom_volume(StrmItm.Object_Id, ld2_daytime, '<=');
        l_stim_day_value.MASS_UOM_CODE   := ec_stream_item_version.default_uom_mass(StrmItm.Object_Id, ld2_daytime, '<=');
        l_stim_day_value.ENERGY_UOM_CODE := ec_stream_item_version.default_uom_energy(StrmItm.Object_Id, ld2_daytime, '<=');
        l_stim_day_value.EXTRA1_UOM_CODE := ec_stream_item_version.default_uom_extra1(StrmItm.Object_Id, ld2_daytime, '<=');
        l_stim_day_value.EXTRA2_UOM_CODE := ec_stream_item_version.default_uom_extra2(StrmItm.Object_Id, ld2_daytime, '<=');
        l_stim_day_value.EXTRA3_UOM_CODE := ec_stream_item_version.default_uom_extra3(StrmItm.Object_Id, ld2_daytime, '<=');

        --'Set-To-Zero logic for setting Stream Items to zero
        IF lv2_set_to_zero = 'ACCRUAL' THEN
               ln_value := 0;
               lv2_status_flag :='ACCRUAL';
            END IF;

            IF lv2_set_to_zero = 'FINAL' THEN
               ln_value := 0;
               lv2_status_flag :='FINAL';
            END IF;

            IF lv2_set_to_zero IS NULL THEN
               ln_value := NULL;
               lv2_status_flag := NULL;
            END IF;


               IF (l_stim_day_value.VOLUME_UOM_CODE IS NOT NULL) THEN
                    l_stim_day_value.NET_VOLUME_VALUE   := ln_value;
                    l_stim_day_value.GROSS_VOLUME_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                IF (l_stim_day_value.MASS_UOM_CODE IS NOT NULL) THEN
                    l_stim_day_value.NET_MASS_VALUE   := ln_value;
                    l_stim_day_value.GROSS_MASS_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                IF (l_stim_day_value.ENERGY_UOM_CODE IS NOT NULL) THEN
                    l_stim_day_value.NET_ENERGY_VALUE   := ln_value;
                    l_stim_day_value.GROSS_ENERGY_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                IF (l_stim_day_value.EXTRA1_UOM_CODE IS NOT NULL) THEN
                    l_stim_day_value.NET_EXTRA1_VALUE   := ln_value;
                    l_stim_day_value.GROSS_EXTRA1_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                IF (l_stim_day_value.EXTRA2_UOM_CODE IS NOT NULL) THEN
                    l_stim_day_value.NET_EXTRA2_VALUE   := ln_value;
                    l_stim_day_value.GROSS_EXTRA2_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                IF (l_stim_day_value.EXTRA3_UOM_CODE IS NOT NULL) THEN
                    l_stim_day_value.NET_EXTRA3_VALUE   := ln_value;
                    l_stim_day_value.GROSS_EXTRA3_VALUE   := ln_value;
                    lv2_status := lv2_status_flag;
                END IF;
                -- Insert into cascade table to make the cascade update SI set to zero
                INSERT INTO stim_cascade (object_id,period,daytime) VALUES (StrmItm.object_id, 'DAY', ld2_daytime);

        --End of Set-To-Zero logic

        IF l_stim_day_value.CALC_METHOD = 'CO' THEN

         FOR prevStrmItm IN c_prevDay(StrmItm.object_id) LOOP



             l_stim_day_value.NET_MASS_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_MASS_VALUE,prevStrmItm.MASS_UOM_CODE,
                                                                           l_stim_day_value.MASS_UOM_CODE,
                                                                           ld2_daytime);

                 l_stim_day_value.GROSS_MASS_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_MASS_VALUE,prevStrmItm.MASS_UOM_CODE,
                                                                           l_stim_day_value.MASS_UOM_CODE,
                                                                           ld2_daytime);

                 l_stim_day_value.NET_VOLUME_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_VOLUME_VALUE,prevStrmItm.VOLUME_UOM_CODE,
                                                                           l_stim_day_value.VOLUME_UOM_CODE,
                                                                           ld2_daytime);


                 l_stim_day_value.GROSS_VOLUME_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_VOLUME_VALUE,prevStrmItm.VOLUME_UOM_CODE,
                                                                           l_stim_day_value.VOLUME_UOM_CODE,
                                                                           ld2_daytime);

                 l_stim_day_value.NET_ENERGY_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_ENERGY_VALUE,prevStrmItm.ENERGY_UOM_CODE,
                                                                           l_stim_day_value.ENERGY_UOM_CODE,
                                                                           ld2_daytime);


                l_stim_day_value.GROSS_ENERGY_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_ENERGY_VALUE,prevStrmItm.ENERGY_UOM_CODE,
                                                                           l_stim_day_value.ENERGY_UOM_CODE,
                                                                           ld2_daytime);


                l_stim_day_value.NET_EXTRA1_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_EXTRA1_VALUE,prevStrmItm.EXTRA1_UOM_CODE,
                                                                           l_stim_day_value.EXTRA1_UOM_CODE,
                                                                           ld2_daytime);

                l_stim_day_value.GROSS_EXTRA1_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_EXTRA1_VALUE,prevStrmItm.EXTRA1_UOM_CODE,
                                                                           l_stim_day_value.EXTRA1_UOM_CODE,
                                                                           ld2_daytime);


                l_stim_day_value.NET_EXTRA2_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_EXTRA2_VALUE,prevStrmItm.EXTRA2_UOM_CODE,
                                                                           l_stim_day_value.EXTRA2_UOM_CODE,
                                                                           ld2_daytime);

                l_stim_day_value.GROSS_EXTRA2_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_EXTRA2_VALUE,prevStrmItm.EXTRA2_UOM_CODE,
                                                                           l_stim_day_value.EXTRA2_UOM_CODE,
                                                                           ld2_daytime);


                l_stim_day_value.NET_EXTRA3_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_EXTRA3_VALUE,prevStrmItm.EXTRA3_UOM_CODE,
                                                                           l_stim_day_value.EXTRA3_UOM_CODE,
                                                                           ld2_daytime);

                l_stim_day_value.GROSS_EXTRA3_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_EXTRA3_VALUE,prevStrmItm.EXTRA3_UOM_CODE,
                                                                           l_stim_day_value.EXTRA3_UOM_CODE,
                                                                           ld2_daytime);



              lv2_status             := prevStrmItm.STATUS;

                -- Force cascade update on CO stream items
                INSERT INTO stim_cascade (object_id,period,daytime) VALUES (StrmItm.object_id, 'DAY', ld2_daytime);



        END LOOP;  -- prevStrmItm

     END IF; -- Constants



        IF l_stim_day_value.CALC_METHOD = 'SK' THEN
            l_stim_day_value.SPLIT_SHARE  := GetSplitShareDay(StrmItm.object_id,ld2_daytime);
        END IF;


        ---------------------------------------------------------------------------
        -- set default conversion factors
        -- For each factor set UOM from and to.
        ---------------------------------------------------------------------------

        IF StrmItm.conversion_method = 'CONVERSION_FACTOR' THEN

          l_ConvFact := GetDefDensity(StrmItm.object_id, ld2_daytime);
          l_stim_day_value.density := l_ConvFact.factor;
          l_stim_day_value.density_volume_uom := l_ConvFact.from_uom;
          l_stim_day_value.density_mass_uom := l_ConvFact.to_uom;
          l_stim_day_value.density_source_id := l_ConvFact.source_object_id;

          l_ConvFact := GetDefGCV(StrmItm.object_id, ld2_daytime);
          l_stim_day_value.gcv := l_ConvFact.factor;
          l_stim_day_value.gcv_volume_uom := l_ConvFact.from_uom;
          l_stim_day_value.gcv_energy_uom := l_ConvFact.to_uom;
          l_stim_day_value.gcv_source_id := l_ConvFact.source_object_id;


          l_ConvFact := GetDefMCV(StrmItm.object_id, ld2_daytime);
          l_stim_day_value.mcv := l_ConvFact.factor;
          l_stim_day_value.mcv_mass_uom := l_ConvFact.from_uom;
          l_stim_day_value.mcv_energy_uom := l_ConvFact.to_uom;
          l_stim_day_value.mcv_source_id := l_ConvFact.source_object_id;

        END IF;

          l_ConvFact := GetDefBOE(StrmItm.object_id, ld2_daytime);
          l_stim_day_value.boe_factor := l_ConvFact.factor;
          l_stim_day_value.boe_from_uom_code := l_ConvFact.from_uom;
          l_stim_day_value.boe_to_uom_code := l_ConvFact.to_uom;
          l_stim_day_value.boe_source_id := l_ConvFact.source_object_id;


        -- Update everyting in one update
        update stim_day_value
           set volume_uom_code    = l_stim_day_value.volume_uom_code,
               mass_uom_code      = l_stim_day_value.mass_uom_code,
               energy_uom_code    = l_stim_day_value.energy_uom_code,
               extra1_uom_code    = l_stim_day_value.extra1_uom_code,
               extra2_uom_code    = l_stim_day_value.extra2_uom_code,
               extra3_uom_code    = l_stim_day_value.extra3_uom_code,
               net_mass_value     = l_stim_day_value.net_mass_value,
               gross_mass_value   = l_stim_day_value.gross_mass_value,
               net_volume_value   = l_stim_day_value.net_volume_value,
               gross_volume_value = l_stim_day_value.gross_volume_value,
               net_energy_value   = l_stim_day_value.net_energy_value,
               gross_energy_value = l_stim_day_value.gross_energy_value,
               net_extra1_value   = l_stim_day_value.net_extra1_value,
               gross_extra1_value = l_stim_day_value.gross_extra1_value,
               net_extra2_value   = l_stim_day_value.net_extra2_value,
               gross_extra2_value = l_stim_day_value.gross_extra2_value,
               net_extra3_value   = l_stim_day_value.net_extra3_value,
               gross_extra3_value = l_stim_day_value.gross_extra3_value,
               gcv                = l_stim_day_value.gcv,
               gcv_energy_uom     = l_stim_day_value.gcv_energy_uom,
               gcv_volume_uom     = l_stim_day_value.gcv_volume_uom,
               density            = l_stim_day_value.density,
               density_mass_uom   = l_stim_day_value.density_mass_uom,
               density_volume_uom = l_stim_day_value.density_volume_uom,
               mcv                = l_stim_day_value.mcv,
               mcv_energy_uom     = l_stim_day_value.mcv_energy_uom,
               mcv_mass_uom       = l_stim_day_value.mcv_mass_uom,
               density_source_id  = l_stim_day_value.density_source_id,
               gcv_source_id      = l_stim_day_value.gcv_source_id,
               mcv_source_id      = l_stim_day_value.mcv_source_id,
               boe_factor         = l_stim_day_value.boe_factor,
               boe_from_uom_code  = l_stim_day_value.boe_from_uom_code,
               boe_to_uom_code    = l_stim_day_value.boe_to_uom_code,
               boe_source_id      = l_stim_day_value.boe_source_id,
               split_share        = l_stim_day_value.split_share,
               status             = lv2_status,
               last_updated_by    = 'INSTANTIATE'
         where object_id = strmitm.object_id
           and daytime = ld2_daytime
           and last_updated_by = 'INSTANTIATE';

        l_stim_day_value := NULL; -- reset for next iteration

    END LOOP;

END InstantiateDay;

/**
InstantiateNextVO will pass the parameters to InstantiateNextDay and InstantiateNextMth procedures for processing  Object_List and Company.
**/

PROCEDURE InstantiateNextVO(p_company_id VARCHAR2 DEFAULT NULL,  p_object_list VARCHAR2 DEFAULT NULL,  p_type VARCHAR2) IS

CURSOR c_object_id is
SELECT
        a.object_id as COMPANY_ID,
        a.object_code as COMPANY_CODE
FROM company a, OBJECT_LIST_SETUP b, ov_object_list c
WHERE a.object_code=b.generic_object_code and a.class_name = 'COMPANY'
        and c.generic_class_name = 'COMPANY' and b.object_id =c.object_id
        and c.object_id = NVL(p_object_list,'1')
UNION
SELECT object_id,object_code from company where object_id = NVL(p_company_id,'1');


BEGIN
   -- If user does not select OBJECT_LIST
 IF p_object_list IS NULL THEN
     IF p_type ='DAY' THEN
            InstantiateNextDay(p_company_id);
     ELSIF p_type ='MTH' THEN
            InstantiateNextMth(p_company_id);
     END IF;

 ELSE
       FOR comp_rec IN c_object_id LOOP
          IF p_type ='DAY' THEN
            InstantiateNextDay(comp_rec.COMPANY_ID);
          ELSIF p_type ='MTH' THEN
            InstantiateNextMth(comp_rec.COMPANY_ID);
          END IF;
        END LOOP;
  END IF;
END InstantiateNextVO;


PROCEDURE InstantiateNextDay(p_company_id VARCHAR2) IS
BEGIN
   -- This routine will do instatiation of daily numbers for the next day based on sysdate
   InstantiateDay(TRUNC(Ecdp_Timestamp.getCurrentSysdate+1,'DD'), p_company_id);
END InstantiateNextDay;

PROCEDURE InstantiateDays(p_start_date DATE,
p_end_date DATE,
p_company_id VARCHAR2) IS
ln_days NUMBER;

BEGIN

     -- Count the number of days between start and end date
     ln_days := p_end_date - p_start_date;

     -- Loop through every day and instantiate
     FOR ln_counter IN 0..ln_days LOOP
         InstantiateDay(p_start_date + ln_counter, p_company_id);
     END LOOP;

END InstantiateDays;

/**
InstantiateAllVO will pass the parameters to InstantiateDays and InstantiateMths procedures for processing  Object_List and Company.
**/
PROCEDURE InstantiateAllVO( p_start_date DATE, p_end_date DATE, p_company_id VARCHAR2 DEFAULT NULL, p_object_list VARCHAR2 DEFAULT NULL, p_type VARCHAR2) IS

CURSOR c_object_id is
SELECT
        a.object_id as COMPANY_ID,
        a.object_code as COMPANY_CODE
FROM company a, OBJECT_LIST_SETUP b, ov_object_list c
WHERE a.object_code=b.generic_object_code and a.class_name = 'COMPANY'
        and c.generic_class_name = 'COMPANY' and b.object_id =c.object_id
        and c.object_id = NVL(p_object_list,'1')
UNION
SELECT object_id,object_code from company where object_id = NVL(p_company_id,'1');

BEGIN
 IF p_object_list IS NULL THEN
     IF p_type ='DAY' THEN
           InstantiateDays(p_start_date, p_end_date, p_company_id);
     ELSIF p_type ='MTH' THEN
           InstantiateMths(p_start_date, p_end_date, p_company_id);
     END IF;

 ELSE
       FOR comp_rec IN c_object_id LOOP
         IF p_type ='DAY' THEN
            InstantiateDays(p_start_date, p_end_date, comp_rec.COMPANY_ID);
          ELSIF p_type ='MTH' THEN
            InstantiateMths(p_start_date, p_end_date, comp_rec.COMPANY_ID);
          END IF;
       END LOOP;
   END IF;
END InstantiateAllVO;

----------------------
PROCEDURE InstantiateMth(p_daytime DATE, p_company_id VARCHAR2 DEFAULT NULL, p_si_object_id VARCHAR2 DEFAULT NULL) IS

CURSOR c_stream_items IS
SELECT object_id, ec_stream_item_version.conversion_method(object_id,daytime,'<=') conversion_method
FROM stim_mth_value
WHERE daytime = TRUNC(p_daytime,'MM')
AND last_updated_by = 'INSTANTIATE'
AND DECODE(p_company_id,NULL,'1', ec_stream_item_version.company_id(object_id, daytime, '<=')) = NVL(p_company_id,'1')
AND (p_si_object_id IS NULL OR object_id = p_si_object_id);

CURSOR c_prevMonth(p_object_id varchar2) IS
SELECT *
FROM  stim_mth_value
WHERE object_id = p_object_id
AND daytime = Add_Months(Trunc(p_daytime,'MM'),-1);

l_ConvFact t_conversion;
l_stim_mth_value stim_mth_value%ROWTYPE;
lv2_set_to_zero          varchar2(200);
lv2_status stim_mth_value.status%TYPE := NULL;
ln_value NUMBER;
lv2_status_flag VARCHAR2(240);

BEGIN

    BEGIN

         ecdp_fin_period.instantiatePeriod(p_daytime, '');

    END;

  -- insert all valid stream_items for a given month
  INSERT INTO stim_mth_value
     (OBJECT_ID
    ,DAYTIME
    ,CREATED_BY
    ,LAST_UPDATED_BY -- include this during insert to allow for standard processing in subsequent updates
    ,REV_TEXT
     )
  SELECT
     OBJECT_ID
    ,Trunc(p_daytime,'MM')
    ,'INSTANTIATE'
    ,'INSTANTIATE'
    ,'Instantiated record'
  FROM objects x
  WHERE class_name = 'STREAM_ITEM'
    AND TRUNC(p_daytime,'MM') BETWEEN Nvl(start_date,TRUNC(p_daytime,'MM')-1) AND Nvl(end_date,TRUNC(p_daytime,'MM')+1)
    AND DECODE(p_company_id,NULL,'1', ec_stream_item_version.company_id(object_id, p_daytime, '<=')) = NVL(p_company_id,'1')
    AND NOT EXISTS (SELECT 'x' FROM stim_mth_value WHERE object_id = x.object_id AND daytime = Trunc(p_daytime,'MM'))
    AND (p_si_object_id IS NULL OR object_id = p_si_object_id);

    -----------------------------------------------------------------------
    -- AV 10.03.2004  To avoid trigging the cascade logic 4 times, rewrote logic here to do
    --                everyting in one update, to get this right have to handle one stream item at the time
    --                this will make it less resource demanding on rollback segments, having commits at regular
    --                intervals will also allow the cascade process to run in parallell with instatiation.

    FOR StrmItm IN c_stream_items LOOP

      l_stim_mth_value.CALC_METHOD := ec_stream_item_version.calc_method(StrmItm.object_id, TRUNC(p_daytime,'MM'), '<=');

        lv2_status := null;

        lv2_set_to_zero := ec_stream_item_version.set_to_zero_method_mth(StrmItm.object_id, TRUNC(p_daytime,'MM'), '<=');


        ---------------------------------------------------------------------------
      -- Default UOMs
      ---------------------------------------------------------------------------
      l_stim_mth_value.VOLUME_UOM_CODE := ec_stream_item_version.default_uom_volume(StrmItm.Object_Id, TRUNC(p_daytime,'MM'), '<=');
      l_stim_mth_value.MASS_UOM_CODE   := ec_stream_item_version.default_uom_mass(StrmItm.Object_Id, TRUNC(p_daytime,'MM'), '<=');
      l_stim_mth_value.ENERGY_UOM_CODE := ec_stream_item_version.default_uom_energy(StrmItm.Object_Id, TRUNC(p_daytime,'MM'), '<=');
      l_stim_mth_value.EXTRA1_UOM_CODE := ec_stream_item_version.default_uom_extra1(StrmItm.Object_Id, TRUNC(p_daytime,'MM'), '<=');
      l_stim_mth_value.EXTRA2_UOM_CODE := ec_stream_item_version.default_uom_extra2(StrmItm.Object_Id, TRUNC(p_daytime,'MM'), '<=');
      l_stim_mth_value.EXTRA3_UOM_CODE := ec_stream_item_version.default_uom_extra3(StrmItm.Object_Id, TRUNC(p_daytime,'MM'), '<=');

      --'Set-To-Zero logic for setting Stream Items to zero
       IF lv2_set_to_zero = 'ACCRUAL' THEN
               ln_value := 0;
               lv2_status_flag :='ACCRUAL';
       END IF;

       IF lv2_set_to_zero = 'FINAL' THEN
               ln_value := 0;
               lv2_status_flag :='FINAL';
       END IF;

       IF lv2_set_to_zero IS NULL THEN
               ln_value := NULL;
               lv2_status_flag := NULL;
       END IF;

       IF (l_stim_mth_value.VOLUME_UOM_CODE IS NOT NULL) THEN
           l_stim_mth_value.NET_VOLUME_VALUE   := ln_value;
           l_stim_mth_value.GROSS_VOLUME_VALUE   := ln_value;
           lv2_status := lv2_status_flag;
       END IF;
       IF (l_stim_mth_value.MASS_UOM_CODE IS NOT NULL) THEN
           l_stim_mth_value.NET_MASS_VALUE   := ln_value;
           l_stim_mth_value.GROSS_MASS_VALUE   := ln_value;
           lv2_status := lv2_status_flag;
       END IF;
       IF (l_stim_mth_value.ENERGY_UOM_CODE IS NOT NULL) THEN
           l_stim_mth_value.NET_ENERGY_VALUE   := ln_value;
           l_stim_mth_value.GROSS_ENERGY_VALUE   := ln_value;
           lv2_status := lv2_status_flag;
       END IF;
       IF (l_stim_mth_value.EXTRA1_UOM_CODE IS NOT NULL) THEN
           l_stim_mth_value.NET_EXTRA1_VALUE   := ln_value;
           l_stim_mth_value.GROSS_EXTRA1_VALUE   := ln_value;
           lv2_status := lv2_status_flag;
       END IF;
       IF (l_stim_mth_value.EXTRA2_UOM_CODE IS NOT NULL) THEN
           l_stim_mth_value.NET_EXTRA2_VALUE   := ln_value;
           l_stim_mth_value.GROSS_EXTRA2_VALUE   := ln_value;
           lv2_status := lv2_status_flag;
       END IF;
       IF (l_stim_mth_value.EXTRA3_UOM_CODE IS NOT NULL) THEN
           l_stim_mth_value.NET_EXTRA3_VALUE   := ln_value;
           l_stim_mth_value.GROSS_EXTRA3_VALUE   := ln_value;
           lv2_status := lv2_status_flag;
       END IF;

       -- Insert into cascade table to make the cascade update SI set to zero
      INSERT INTO stim_cascade (object_id,period,daytime) VALUES (StrmItm.object_id, 'MTH', TRUNC(p_daytime,'MM'));

      --End of Set-To-Zero logic

      --Copy over the previous month's values for the CONSTANT type of stream items
      IF l_stim_mth_value.CALC_METHOD = 'CO' THEN

        FOR prevStrmItm IN c_prevMonth(StrmItm.object_id) LOOP


             ---------------------------------------------------------------------------
            -- Need to set constants from last entry
            --
             ---------------------------------------------------------------------------

             l_stim_mth_value.NET_MASS_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_MASS_VALUE,prevStrmItm.MASS_UOM_CODE,
                                                                       l_stim_mth_value.MASS_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));

             l_stim_mth_value.GROSS_MASS_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_MASS_VALUE,prevStrmItm.MASS_UOM_CODE,
                                                                       l_stim_mth_value.MASS_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));

             l_stim_mth_value.NET_VOLUME_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_VOLUME_VALUE,prevStrmItm.VOLUME_UOM_CODE,
                                                                       l_stim_mth_value.VOLUME_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));


             l_stim_mth_value.GROSS_VOLUME_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_VOLUME_VALUE,prevStrmItm.VOLUME_UOM_CODE,
                                                                       l_stim_mth_value.VOLUME_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));

             l_stim_mth_value.NET_ENERGY_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_ENERGY_VALUE,prevStrmItm.ENERGY_UOM_CODE,
                                                                       l_stim_mth_value.ENERGY_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));


            l_stim_mth_value.GROSS_ENERGY_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_ENERGY_VALUE,prevStrmItm.ENERGY_UOM_CODE,
                                                                       l_stim_mth_value.ENERGY_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));


            l_stim_mth_value.NET_EXTRA1_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_EXTRA1_VALUE,prevStrmItm.EXTRA1_UOM_CODE,
                                                                       l_stim_mth_value.EXTRA1_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));

            l_stim_mth_value.GROSS_EXTRA1_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_EXTRA1_VALUE,prevStrmItm.EXTRA1_UOM_CODE,
                                                                       l_stim_mth_value.EXTRA1_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));


            l_stim_mth_value.NET_EXTRA2_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_EXTRA2_VALUE,prevStrmItm.EXTRA2_UOM_CODE,
                                                                       l_stim_mth_value.EXTRA2_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));

            l_stim_mth_value.GROSS_EXTRA2_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_EXTRA2_VALUE,prevStrmItm.EXTRA2_UOM_CODE,
                                                                       l_stim_mth_value.EXTRA2_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));


            l_stim_mth_value.NET_EXTRA3_VALUE := EcDp_Unit.convertValue(prevStrmItm.NET_EXTRA3_VALUE,prevStrmItm.EXTRA3_UOM_CODE,
                                                                       l_stim_mth_value.EXTRA3_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));

            l_stim_mth_value.GROSS_EXTRA3_VALUE := EcDp_Unit.convertValue(prevStrmItm.GROSS_EXTRA3_VALUE,prevStrmItm.EXTRA3_UOM_CODE,
                                                                       l_stim_mth_value.EXTRA3_UOM_CODE,
                                                                       TRUNC(p_daytime, 'MM'));



          lv2_status             := prevStrmItm.STATUS;

                -- Force cascade update on CO stream items
                INSERT INTO stim_cascade (object_id,period,daytime) VALUES (StrmItm.object_id, 'MTH', TRUNC(p_daytime,'MM'));




        END LOOP;  -- prevStrmItm
    END IF;


       ---------------------------------------------------------------------------
       -- If a Split key, instantiate split share
       --
       ---------------------------------------------------------------------------


        IF l_stim_mth_value.CALC_METHOD = 'SK' THEN
           l_stim_mth_value.SPLIT_SHARE  := GetSplitShareMth(StrmItm.object_id,TRUNC(p_daytime,'MM'));
        END IF;


      ---------------------------------------------------------------------------
         -- set default conversion factors
         -- For each factor set UOM from and to.
         ---------------------------------------------------------------------------

    IF StrmItm.conversion_method = 'CONVERSION_FACTOR' THEN

        l_ConvFact := GetDefDensity(StrmItm.object_id, TRUNC(p_daytime,'MM'));
        l_stim_mth_value.density := l_ConvFact.factor;
        l_stim_mth_value.density_volume_uom := l_ConvFact.from_uom;
        l_stim_mth_value.density_mass_uom := l_ConvFact.to_uom;
        l_stim_mth_value.density_source_id := l_ConvFact.source_object_id;

        l_ConvFact := GetDefGCV(StrmItm.object_id, TRUNC(p_daytime,'MM'));
        l_stim_mth_value.gcv := l_ConvFact.factor;
        l_stim_mth_value.gcv_volume_uom := l_ConvFact.from_uom;
        l_stim_mth_value.gcv_energy_uom := l_ConvFact.to_uom;
        l_stim_mth_value.gcv_source_id := l_ConvFact.source_object_id;


        l_ConvFact := GetDefMCV(StrmItm.object_id, TRUNC(p_daytime,'MM'));
        l_stim_mth_value.mcv := l_ConvFact.factor;
        l_stim_mth_value.mcv_mass_uom := l_ConvFact.from_uom;
        l_stim_mth_value.mcv_energy_uom := l_ConvFact.to_uom;
        l_stim_mth_value.mcv_source_id := l_ConvFact.source_object_id;

    END IF;


        l_ConvFact := GetDefBOE(StrmItm.object_id, TRUNC(p_daytime,'MM'));
        l_stim_mth_value.boe_factor := l_ConvFact.factor;
        l_stim_mth_value.boe_from_uom_code := l_ConvFact.from_uom;
        l_stim_mth_value.boe_to_uom_code := l_ConvFact.to_uom;
        l_stim_mth_value.boe_source_id := l_ConvFact.source_object_id;



        -- Update everyting in one update

    update stim_mth_value
       set volume_uom_code    = l_stim_mth_value.volume_uom_code,
           mass_uom_code      = l_stim_mth_value.mass_uom_code,
           energy_uom_code    = l_stim_mth_value.energy_uom_code,
           extra1_uom_code    = l_stim_mth_value.extra1_uom_code,
           extra2_uom_code    = l_stim_mth_value.extra2_uom_code,
           extra3_uom_code    = l_stim_mth_value.extra3_uom_code,
           net_mass_value     = l_stim_mth_value.net_mass_value,
           gross_mass_value   = l_stim_mth_value.gross_mass_value,
           net_volume_value   = l_stim_mth_value.net_volume_value,
           gross_volume_value = l_stim_mth_value.gross_volume_value,
           net_energy_value   = l_stim_mth_value.net_energy_value,
           gross_energy_value = l_stim_mth_value.gross_energy_value,
           net_extra1_value   = l_stim_mth_value.net_extra1_value,
           gross_extra1_value = l_stim_mth_value.gross_extra1_value,
           net_extra2_value   = l_stim_mth_value.net_extra2_value,
           gross_extra2_value = l_stim_mth_value.gross_extra2_value,
           net_extra3_value   = l_stim_mth_value.net_extra3_value,
           gross_extra3_value = l_stim_mth_value.gross_extra3_value,
           gcv                = l_stim_mth_value.gcv,
           gcv_energy_uom     = l_stim_mth_value.gcv_energy_uom,
           gcv_volume_uom     = l_stim_mth_value.gcv_volume_uom,
           density            = l_stim_mth_value.density,
           density_mass_uom   = l_stim_mth_value.density_mass_uom,
           density_volume_uom = l_stim_mth_value.density_volume_uom,
           mcv                = l_stim_mth_value.mcv,
           mcv_energy_uom     = l_stim_mth_value.mcv_energy_uom,
           mcv_mass_uom       = l_stim_mth_value.mcv_mass_uom,
           density_source_id  = l_stim_mth_value.density_source_id,
           gcv_source_id      = l_stim_mth_value.gcv_source_id,
           mcv_source_id      = l_stim_mth_value.mcv_source_id,
           boe_factor         = l_stim_mth_value.boe_factor,
           boe_from_uom_code  = l_stim_mth_value.boe_from_uom_code,
           boe_to_uom_code    = l_stim_mth_value.boe_to_uom_code,
           boe_source_id      = l_stim_mth_value.boe_source_id,
           split_share        = l_stim_mth_value.split_share,
           status             = lv2_status,
           last_updated_by    = 'INSTANTIATE'
     where object_id = strmitm.object_id
       and daytime = trunc(p_daytime, 'mm')
       and last_updated_by = 'INSTANTIATE';

        l_stim_mth_value := NULL; -- reset for next iteration

  END LOOP;

END InstantiateMth;


---------------------

PROCEDURE InstantiateNextMth(p_company_id VARCHAR2 DEFAULT NULL) IS
BEGIN
   -- This routine will do instatiation of monthly numbers for the next month based on sysdate
   InstantiateMth(TRUNC(LAST_DAY(Ecdp_Timestamp.getCurrentSysdate)+1,'MM'),p_company_id);
END InstantiateNextMth;

PROCEDURE InstantiatePeriodDay(p_start_date DATE, p_end_date DATE) IS

ln_count NUMBER;

BEGIN
-- instantiate all days and months in period
   FOR ln_count IN 0..(Trunc(p_end_date) - Trunc(p_start_date)) LOOP

       -- days
       InstantiateDay(Trunc(p_start_date) + ln_count);

   END LOOP;
END InstantiatePeriodDay;

PROCEDURE InstantiatePeriodMth(p_start_date DATE, p_end_date DATE) IS

ln_count NUMBER;

BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*

-- instantiate all days and months in period
   FOR ln_count IN 0..Months_Between(Trunc(p_end_date,'MM'),Trunc(p_start_date,'MM')) LOOP

           InstantiateMth(p_system_id, Add_Months(Trunc(p_start_date,'MM'), ln_count));

   END LOOP;
*/
END InstantiatePeriodMth;

FUNCTION GetSubGroupValue(
   pr_stim_mth_value   stim_mth_value%ROWTYPE,
   p_uom_group   VARCHAR2,
   p_uom_subgroup VARCHAR2
   )

RETURN NUMBER

IS

lv2_uom_subgroup VARCHAR2(32);
lv2_target_uom VARCHAR2(32);

BEGIN

     lv2_target_uom := EcDp_Unit.GetUOMSubGroupTarget(p_uom_subgroup);

     IF p_uom_group = 'V' THEN

        lv2_uom_subgroup := EcDp_Unit.GetUOMSubGroup(pr_stim_mth_value.volume_uom_code);

        IF lv2_uom_subgroup = p_uom_subgroup THEN

           RETURN EcDp_Revn_Unit.convertValue(pr_stim_mth_value.net_volume_value, pr_stim_mth_value.volume_uom_code, lv2_target_uom, pr_stim_mth_value.object_id, pr_stim_mth_value.daytime);

        END IF;

     ELSIF p_uom_group = 'M' THEN

        lv2_uom_subgroup := EcDp_Unit.GetUOMSubGroup(pr_stim_mth_value.mass_uom_code);

        IF lv2_uom_subgroup = p_uom_subgroup THEN

           RETURN EcDp_Revn_Unit.convertValue(pr_stim_mth_value.net_mass_value, pr_stim_mth_value.mass_uom_code, lv2_target_uom, pr_stim_mth_value.object_id, pr_stim_mth_value.daytime);

         END IF;

     ELSIF p_uom_group = 'E' THEN

        lv2_uom_subgroup := EcDp_Unit.GetUOMSubGroup(pr_stim_mth_value.energy_uom_code);

        IF lv2_uom_subgroup = p_uom_subgroup THEN

           RETURN EcDp_Revn_Unit.convertValue(pr_stim_mth_value.net_energy_value, pr_stim_mth_value.energy_uom_code, lv2_target_uom, pr_stim_mth_value.object_id, pr_stim_mth_value.daytime);

        END IF;

     END IF;

     -- NOTE that if found, we have already returned from this function
     -- check if any of the extras within same subgroup

     lv2_uom_subgroup := EcDp_Unit.GetUOMSubGroup(pr_stim_mth_value.extra1_uom_code);

     IF lv2_uom_subgroup = p_uom_subgroup THEN

        RETURN EcDp_Revn_Unit.convertValue(pr_stim_mth_value.net_extra1_value, pr_stim_mth_value.extra1_uom_code, lv2_target_uom, pr_stim_mth_value.object_id, pr_stim_mth_value.daytime);

     END IF;

     lv2_uom_subgroup := EcDp_Unit.GetUOMSubGroup(pr_stim_mth_value.extra2_uom_code);

     IF lv2_uom_subgroup = p_uom_subgroup THEN

        RETURN EcDp_Revn_Unit.convertValue(pr_stim_mth_value.net_extra2_value, pr_stim_mth_value.extra2_uom_code, lv2_target_uom, pr_stim_mth_value.object_id, pr_stim_mth_value.daytime);

     END IF;

     lv2_uom_subgroup := EcDp_Unit.GetUOMSubGroup(pr_stim_mth_value.extra3_uom_code);

     IF lv2_uom_subgroup = p_uom_subgroup THEN

        RETURN EcDp_Revn_Unit.convertValue(pr_stim_mth_value.net_extra3_value, pr_stim_mth_value.extra3_uom_code, lv2_target_uom, pr_stim_mth_value.object_id, pr_stim_mth_value.daytime);

     END IF;


     -- NOTE that if found, we have already returned from this function
     -- convert from UOM Group

     IF p_uom_group = 'V' THEN

           RETURN EcDp_Revn_Unit.convertValue(pr_stim_mth_value.net_volume_value, pr_stim_mth_value.volume_uom_code, lv2_target_uom, pr_stim_mth_value.object_id, pr_stim_mth_value.daytime);

     ELSIF p_uom_group = 'M' THEN

           RETURN EcDp_Revn_Unit.convertValue(pr_stim_mth_value.net_mass_value, pr_stim_mth_value.mass_uom_code, lv2_target_uom, pr_stim_mth_value.object_id, pr_stim_mth_value.daytime);

     ELSIF p_uom_group = 'E' THEN

           RETURN EcDp_Revn_Unit.convertValue(pr_stim_mth_value.net_energy_value, pr_stim_mth_value.energy_uom_code, lv2_target_uom, pr_stim_mth_value.object_id, pr_stim_mth_value.daytime);

     ELSE

           RETURN NULL;

     END IF;


 RETURN NULL;

END;

FUNCTION GetBOEValue(pr_stim_mth_value stim_mth_value%ROWTYPE)

RETURN NUMBER

IS

lv2_boe_from_unit VARCHAR2(16);
lv2_boe_to_unit VARCHAR2(16);
ln_boe_factor NUMBER;
lv2_uomgroup ctrl_unit.uom_group%type;
ln_result NUMBER;
ln_unit_value NUMBER;
lv2_unit_uom ctrl_unit.unit%type;

BEGIN

     ln_boe_factor := pr_stim_mth_value.boe_factor;
     lv2_boe_from_unit := pr_stim_mth_value.boe_from_uom_code;

    IF pr_stim_mth_value.energy_uom_code IN ('BOE','KBOE','MBOE') THEN

           ln_result := ecdp_unit.convertvalue(pr_stim_mth_value.net_energy_value,pr_stim_mth_value.energy_uom_code,'BOE',pr_stim_mth_value.daytime);

    ELSIF pr_stim_mth_value.extra1_uom_code IN ('BOE','KBOE','MBOE') THEN

          ln_result := ecdp_unit.convertvalue(pr_stim_mth_value.net_extra1_value,pr_stim_mth_value.extra1_uom_code,'BOE',pr_stim_mth_value.daytime);

    ELSIF pr_stim_mth_value.extra2_uom_code IN ('BOE','KBOE','MBOE') THEN

          ln_result := ecdp_unit.convertvalue(pr_stim_mth_value.net_extra2_value,pr_stim_mth_value.extra2_uom_code,'BOE',pr_stim_mth_value.daytime);

   ELSIF  pr_stim_mth_value.extra3_uom_code IN ('BOE','KBOE','MBOE') THEN

          ln_result := ecdp_unit.convertvalue(pr_stim_mth_value.net_extra3_value,pr_stim_mth_value.extra3_uom_code,'BOE',pr_stim_mth_value.daytime);



    ELSE

          lv2_uomgroup := ec_ctrl_unit.uom_group(lv2_boe_from_unit);

          IF lv2_uomgroup = 'V' THEN

             IF pr_stim_mth_value.net_volume_value IS NOT NULL THEN
                ln_unit_value := pr_stim_mth_value.net_volume_value;
                lv2_unit_uom := pr_stim_mth_value.volume_uom_code;

              ELSIF ec_ctrl_unit.uom_group(pr_stim_mth_value.extra1_uom_code) = 'V' AND pr_stim_mth_value.net_extra1_value IS NOT NULL THEN
                         ln_unit_value := pr_stim_mth_value.net_extra1_value;
                         lv2_unit_uom := pr_stim_mth_value.extra1_uom_code;

              ELSIF ec_ctrl_unit.uom_group(pr_stim_mth_value.extra2_uom_code) = 'V' AND pr_stim_mth_value.net_extra2_value IS NOT NULL THEN
                     ln_unit_value := pr_stim_mth_value.net_extra2_value;
                     lv2_unit_uom := pr_stim_mth_value.extra2_uom_code;

               ELSIF ec_ctrl_unit.uom_group(pr_stim_mth_value.extra3_uom_code) = 'V' AND pr_stim_mth_value.net_extra3_value IS NOT NULL THEN
                     ln_unit_value := pr_stim_mth_value.net_extra3_value;
                     lv2_unit_uom := pr_stim_mth_value.extra3_uom_code;
              END IF;


          ELSIF lv2_uomgroup = 'M' THEN


                IF pr_stim_mth_value.net_mass_value IS NOT NULL THEN
                     ln_unit_value := pr_stim_mth_value.net_mass_value;
                     lv2_unit_uom := pr_stim_mth_value.mass_uom_code;
                 ELSIF ec_ctrl_unit.uom_group(pr_stim_mth_value.extra1_uom_code) = 'M' AND pr_stim_mth_value.net_extra1_value IS NOT NULL THEN
                         ln_unit_value := pr_stim_mth_value.net_extra1_value;
                         lv2_unit_uom := pr_stim_mth_value.extra1_uom_code;

                  ELSIF ec_ctrl_unit.uom_group(pr_stim_mth_value.extra2_uom_code) = 'M' AND pr_stim_mth_value.net_extra2_value IS NOT NULL THEN
                        ln_unit_value := pr_stim_mth_value.net_extra2_value;
                        lv2_unit_uom := pr_stim_mth_value.extra2_uom_code;
                   ELSIF ec_ctrl_unit.uom_group(pr_stim_mth_value.extra3_uom_code) = 'M' AND pr_stim_mth_value.net_extra3_value IS NOT NULL THEN
                         ln_unit_value := pr_stim_mth_value.net_extra3_value;
                         lv2_unit_uom := pr_stim_mth_value.extra3_uom_code;
                 END IF;



          ELSIF lv2_uomgroup = 'E' THEN


                IF pr_stim_mth_value.net_energy_value IS NOT NULL THEN
                     ln_unit_value := pr_stim_mth_value.net_energy_value;
                     lv2_unit_uom := pr_stim_mth_value.energy_uom_code;

                 ELSIF ec_ctrl_unit.uom_group(pr_stim_mth_value.extra1_uom_code) = 'E' AND pr_stim_mth_value.net_extra1_value IS NOT NULL THEN
                         ln_unit_value := pr_stim_mth_value.net_extra1_value;
                         lv2_unit_uom := pr_stim_mth_value.extra1_uom_code;

                  ELSIF ec_ctrl_unit.uom_group(pr_stim_mth_value.extra2_uom_code) = 'E' AND pr_stim_mth_value.net_extra2_value IS NOT NULL THEN
                     ln_unit_value := pr_stim_mth_value.net_extra2_value;
                     lv2_unit_uom := pr_stim_mth_value.extra2_uom_code;

                   ELSIF ec_ctrl_unit.uom_group(pr_stim_mth_value.extra3_uom_code) = 'E' AND pr_stim_mth_value.net_extra3_value IS NOT NULL THEN
                     ln_unit_value := pr_stim_mth_value.net_extra3_value;
                     lv2_unit_uom := pr_stim_mth_value.extra3_uom_code;
                 END IF;


          END IF;

              ln_result := ecdp_revn_unit.boe_convert(ln_unit_value,
                                                      lv2_unit_uom,
                                                     'BOE',
                                                      pr_stim_mth_value.daytime,
                                                      pr_stim_mth_value.object_id,
                                                      lv2_boe_from_unit,
                                                      ln_boe_factor);
    END IF;

    return ln_result;

END;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetBOEStimValue
-- Description    : Finds a BOE number based on available units / unit groups on the record
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
FUNCTION GetBOEStimValue(p_object_id         VARCHAR2,
                         p_daytime           DATE,
                         p_net_volume_value  NUMBER,
                         p_volume_uom_code   VARCHAR2,
                         p_net_mass_value    NUMBER,
                         p_mass_uom_code     VARCHAR2,
                         p_net_energy_value  NUMBER,
                         p_energy_uom_code   VARCHAR2,
                         p_net_extra1_value  NUMBER,
                         p_extra1_uom_code   VARCHAR2,
                         p_net_extra2_value  NUMBER,
                         p_extra2_uom_code   VARCHAR2,
                         p_net_extra3_value  NUMBER,
                         p_extra3_uom_code   VARCHAR2,
                         p_boe_from_uom_code VARCHAR2,
                         p_boe_to_uom_code   VARCHAR2,
                         p_boe_factor        NUMBER)

 RETURN NUMBER

IS

lv2_uomgroup ctrl_unit.uom_group%type;
ln_result NUMBER;
ln_unit_value NUMBER;
lv2_unit_uom ctrl_unit.unit%type;

BEGIN

          lv2_uomgroup := ec_ctrl_unit.uom_group(p_boe_from_uom_code);

          IF lv2_uomgroup = 'V' THEN

             IF p_net_volume_value IS NOT NULL AND ec_ctrl_unit.uom_subgroup(p_volume_uom_code) NOT IN ('BE') THEN
                ln_unit_value := p_net_volume_value;
                lv2_unit_uom := p_volume_uom_code;

              ELSIF ec_ctrl_unit.uom_group(p_extra1_uom_code) = 'V'
                     AND p_net_extra1_value IS NOT NULL
                     AND ec_ctrl_unit.uom_subgroup(p_extra1_uom_code) NOT IN ('BE') THEN

                         ln_unit_value := p_net_extra1_value;
                         lv2_unit_uom := p_extra1_uom_code;

              ELSIF ec_ctrl_unit.uom_group(p_extra2_uom_code) = 'V'
                     AND p_net_extra2_value IS NOT NULL
                     AND ec_ctrl_unit.uom_subgroup(p_extra2_uom_code) NOT IN ('BE') THEN
                     ln_unit_value := p_net_extra2_value;
                     lv2_unit_uom := p_extra2_uom_code;

               ELSIF ec_ctrl_unit.uom_group(p_extra3_uom_code) = 'V'
                     AND p_net_extra3_value IS NOT NULL
                     AND ec_ctrl_unit.uom_subgroup(p_extra3_uom_code) NOT IN ('BE') THEN
                     ln_unit_value := p_net_extra3_value;
                     lv2_unit_uom := p_extra3_uom_code;
              END IF;


          ELSIF lv2_uomgroup = 'M' THEN


                IF p_net_mass_value IS NOT NULL
                   AND ec_ctrl_unit.uom_subgroup(p_mass_uom_code) NOT IN ('BE') THEN
                     ln_unit_value := p_net_mass_value;
                     lv2_unit_uom := p_mass_uom_code;

                 ELSIF ec_ctrl_unit.uom_group(p_extra1_uom_code) = 'M'
                       AND p_net_extra1_value IS NOT NULL
                       AND ec_ctrl_unit.uom_subgroup(p_extra1_uom_code) NOT IN ('BE') THEN
                         ln_unit_value := p_net_extra1_value;
                         lv2_unit_uom := p_extra1_uom_code;

                  ELSIF ec_ctrl_unit.uom_group(p_extra2_uom_code) = 'M'
                        AND p_net_extra2_value IS NOT NULL
                        AND ec_ctrl_unit.uom_subgroup(p_extra2_uom_code) NOT IN ('BE') THEN
                        ln_unit_value := p_net_extra2_value;
                        lv2_unit_uom := p_extra2_uom_code;

                   ELSIF ec_ctrl_unit.uom_group(p_extra3_uom_code) = 'M'
                         AND p_net_extra3_value IS NOT NULL
                         AND ec_ctrl_unit.uom_subgroup(p_extra3_uom_code) NOT IN ('BE') THEN
                         ln_unit_value := p_net_extra3_value;
                         lv2_unit_uom := p_extra3_uom_code;
                 END IF;



          ELSIF lv2_uomgroup = 'E' THEN


                IF p_net_energy_value IS NOT NULL
                   AND ec_ctrl_unit.uom_subgroup(p_energy_uom_code) NOT IN ('BE') THEN
                     ln_unit_value := p_net_energy_value;
                     lv2_unit_uom := p_energy_uom_code;

                 ELSIF ec_ctrl_unit.uom_group(p_extra1_uom_code) = 'E'
                       AND p_net_extra1_value IS NOT NULL
                       AND ec_ctrl_unit.uom_subgroup(p_extra1_uom_code) NOT IN ('BE') THEN
                         ln_unit_value := p_net_extra1_value;
                         lv2_unit_uom := p_extra1_uom_code;

                  ELSIF ec_ctrl_unit.uom_group(p_extra2_uom_code) = 'E'
                        AND p_net_extra2_value IS NOT NULL
                        AND ec_ctrl_unit.uom_subgroup(p_extra2_uom_code) NOT IN ('BE') THEN
                     ln_unit_value := p_net_extra2_value;
                     lv2_unit_uom := p_extra2_uom_code;

                   ELSIF ec_ctrl_unit.uom_group(p_extra3_uom_code) = 'E'
                         AND p_net_extra3_value IS NOT NULL
                         AND ec_ctrl_unit.uom_subgroup(p_extra3_uom_code) NOT IN ('BE') THEN
                     ln_unit_value := p_net_extra3_value;
                     lv2_unit_uom := p_extra3_uom_code;
                 END IF;


          END IF;

              ln_result := ecdp_revn_unit.boe_convert(ln_unit_value,
                                                      lv2_unit_uom,
                                                      p_boe_to_uom_code,
                                                      p_daytime,
                                                      p_object_id,
                                                      p_boe_from_uom_code,
                                                      p_boe_factor);
    return ln_result;

END;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetBOEUnitValue
-- Description    : Finds a BOE number based on available units / unit groups on the record
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
-----------------------------------------------------------------------------------------------------
FUNCTION GetBOEUnitValue(p_object_id         VARCHAR2,
                         p_daytime           DATE,
                         p_net_value         NUMBER,
                         p_uom_code          VARCHAR2,
                         p_boe_from_uom_code VARCHAR2,
                         p_boe_to_uom_code   VARCHAR2,
                         p_boe_factor        NUMBER)

 RETURN NUMBER

IS

lv2_uomgroup_boe ctrl_unit.uom_group%type;
lv2_uomgroup ctrl_unit.uom_group%type;
ln_result NUMBER;

BEGIN

    lv2_uomgroup_boe := ec_ctrl_unit.uom_group(p_boe_from_uom_code);
    lv2_uomgroup := ec_ctrl_unit.uom_group(p_uom_code);

          IF lv2_uomgroup_boe <> lv2_uomgroup THEN
             RETURN NULL;
             END IF;


              ln_result := ecdp_revn_unit.boe_convert(p_net_value,
                                                      p_uom_code,
                                                      p_boe_to_uom_code,
                                                      p_daytime,
                                                      p_object_id,
                                                      p_boe_from_uom_code,
                                                      p_boe_factor);
    return ln_result;

END;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getBOEInvertUnitValue                                                              --
-- Description    : Inverts the BOE value and converts back to the unit passed as argument
--                  if this unit is within the same UOM as the BOE from-unit. Returns null otherwise
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
-- Using tables   :
-- Using functions:
-- Configuration                                                                                   --
-- required       :                                                                                --
-- Behaviour      :                                                                                --
-----------------------------------------------------------------------------------------------------
FUNCTION getBOEInvertUnitValue(p_object_id         VARCHAR2,
                               p_daytime           DATE,
                               p_net_value         NUMBER,
                               p_uom               VARCHAR2,
                               p_boe_from_uom_code VARCHAR2,
                               p_boe_to_uom_code   VARCHAR2,
                               p_boe_factor        NUMBER)

 RETURN NUMBER

IS

lv2_uomgroup ctrl_unit.uom_group%type;
ln_result NUMBER;
ln_boe_unit_value NUMBER;
lv2_unit_uom ctrl_unit.unit%type;

BEGIN

          lv2_uomgroup := ec_ctrl_unit.uom_group(p_boe_from_uom_code);


            IF lv2_uomgroup = ec_ctrl_unit.uom_group(p_uom) THEN
                  ln_boe_unit_value := ecdp_revn_unit.boeinvert(p_net_value,
                                                                p_boe_to_uom_code,
                                                                p_daytime,
                                                                p_object_id,
                                                                p_boe_from_uom_code,
                                                                p_boe_factor);

             ln_result := ecdp_unit.convertvalue(ln_boe_unit_value,p_boe_from_uom_code,p_uom,p_daytime);

            END IF;

    return ln_result;

END getBOEInvertUnitValue;

-- -------------------------------------------------------------------
-- function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------
FUNCTION GetPerBookedCrudeSaleVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_booked.math_net_volume_bi(c_si.to_object_id,p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.SALE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerBookedCrudeSaleVolBlCur IN c_crude LOOP

         ln_return_val := PerBookedCrudeSaleVolBlCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;

*/
END GetPerBookedCrudeSaleVolBi;

-- -------------------------------------------------------------------
-- function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerBookedCrudeSaleVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_booked.math_net_volume_be(c_si.to_object_id,p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.SALE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerBookedCrudeSaleVolBeCur IN c_crude LOOP

         ln_return_val := PerBookedCrudeSaleVolBeCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;
*/
END GetPerBookedCrudeSaleVolBe;

-- -------------------------------------------------------------------
-- function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerBookedGasSaleVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_gas IS
  SELECT  sum(ec_stim_mth_booked.math_net_volume_sf(c_si.to_object_id,p_from_day,p_to_day)) sum_gas
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.SALE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.GAS())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PeriodBookedGasSaleVolSfCur IN c_gas LOOP

         ln_return_val := PeriodBookedGasSaleVolSfCur.sum_gas;

     END LOOP;

     RETURN ln_return_val;

*/

END GetPerBookedGasSaleVolSf;

-- -------------------------------------------------------------------
-- Function :    GetPerBookedCrudePurchVolBi
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerBookedCrudePurchVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_booked.math_net_volume_bi(c_si.to_object_id, p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.PURCHASE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;

*/

BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerBookedCrudePurchVolBlCur IN c_crude LOOP

         ln_return_val := PerBookedCrudePurchVolBlCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;

*/
END GetPerBookedCrudePurchVolBi;

-- -------------------------------------------------------------------
-- Function :    GetPerBookedCrudePurchVolBe
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerBookedCrudePurchVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_booked.math_net_volume_be(c_si.to_object_id, p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.PURCHASE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;

*/

BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerBookedCrudePurchVolBeCur IN c_crude LOOP

         ln_return_val := PerBookedCrudePurchVolBeCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;

*/
END GetPerBookedCrudePurchVolBe;

-- -------------------------------------------------------------------
-- Function :    GetPerBookedGasPurchVolSf
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerBookedGasPurchVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

IS
/*
CURSOR c_gas IS
  SELECT sum(ec_stim_mth_booked.math_net_volume_sf(c_si.to_object_id,p_from_day,p_to_day)) sum_gas
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.PURCHASE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.GAS())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerBookedGasPurchVolSfCur IN c_gas LOOP

         ln_return_val := PerBookedGasPurchVolSfCur.sum_gas;

     END LOOP;

     RETURN ln_return_val;

*/
END GetPerBookedGasPurchVolSf;

-- -------------------------------------------------------------------
-- Function :    GetPerBookedCrudeVolBi
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerBookedCrudeVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_booked.math_net_volume_bi(c_si.to_object_id,p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation sic_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream_item_category
  and    sic_si.role_name = 'STREAM_ITEM_CATEGORY'
  and    sic_si.from_object_id = p_stream_item_category_obj_id
  and    sic_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- company.stream_item -> stream_item_category.stream_item
  and    c_si.to_object_id = sic_si.to_object_id
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerBookedCrudeVolBlCur IN c_crude LOOP

         ln_return_val := PerBookedCrudeVolBlCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;
*/

END GetPerBookedCrudeVolBi;

-- -------------------------------------------------------------------
-- Function :    GetPerBookedCrudeVolBe
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerBookedCrudeVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_booked.math_net_volume_be(c_si.to_object_id,p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation sic_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream_item_category
  and    sic_si.role_name = 'STREAM_ITEM_CATEGORY'
  and    sic_si.from_object_id = p_stream_item_category_obj_id
  and    sic_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- company.stream_item -> stream_item_category.stream_item
  and    c_si.to_object_id = sic_si.to_object_id
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerBookedCrudeVolBeCur IN c_crude LOOP

         ln_return_val := PerBookedCrudeVolBeCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;

*/
END GetPerBookedCrudeVolBe;

-- -------------------------------------------------------------------
-- Function :    GetPerBookedGasVolSf
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerBookedGasVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

IS
/*
CURSOR c_gas IS
  SELECT sum(ec_stim_mth_booked.math_net_volume_sf(c_si.to_object_id,p_from_day,p_to_day)) sum_gas
  FROM   objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation sic_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream_item_category
  and    sic_si.role_name = 'STREAM_ITEM_CATEGORY'
  and    sic_si.from_object_id = p_stream_item_category_obj_id
  and    sic_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- company.stream_item -> stream_item_category.stream_item
  and    c_si.to_object_id = sic_si.to_object_id
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.GAS())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerBookedGasVolSfCur IN c_gas LOOP

         ln_return_val := PerBookedGasVolSfCur.sum_gas;

     END LOOP;

     RETURN ln_return_val;

*/
END GetPerBookedGasVolSf;

-- start for reported versjon 04.02.2003

-- -------------------------------------------------------------------
-- Function :    GetPerReportedCrudeSaleVolBi
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerReportedCrudeSaleVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_reported.math_net_volume_bi(c_si.to_object_id,p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.SALE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerReportedCrudeSaleVolBlCur IN c_crude LOOP

         ln_return_val := PerReportedCrudeSaleVolBlCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;
*/

END GetPerReportedCrudeSaleVolBi;

-- -------------------------------------------------------------------
-- Function :    GetPerReportedCrudeSaleVolBe
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerReportedCrudeSaleVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_reported.math_net_volume_be(c_si.to_object_id,p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.SALE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerReportedCrudeSaleVolBeCur IN c_crude LOOP

         ln_return_val := PerReportedCrudeSaleVolBeCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;

*/
END GetPerReportedCrudeSaleVolBe;

-- -------------------------------------------------------------------
-- Function :    GetPerReportedGasSaleVolSf
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerReportedGasSaleVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_gas IS
  SELECT sum(ec_stim_mth_reported.math_net_volume_sf(c_si.to_object_id,p_from_day,p_to_day)) sum_gas
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.SALE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.GAS())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PeriodReportedGasSaleVolSfCur IN c_gas LOOP

         ln_return_val := PeriodReportedGasSaleVolSfCur.sum_gas;

     END LOOP;

     RETURN ln_return_val;
*/

END GetPerReportedGasSaleVolSf;

-- -------------------------------------------------------------------
-- Function :    GetPerReportedCrudePurchVolBi
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerReportedCrudePurchVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_reported.math_net_volume_bi(c_si.to_object_id, p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.PURCHASE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;

*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerReportedCrudePurchVolBlCur IN c_crude LOOP

         ln_return_val := PerReportedCrudePurchVolBlCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;
*/

END GetPerReportedCrudePurchVolBi;

-- -------------------------------------------------------------------
-- Function :    GetPerReportedCrudePurchVolBe
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerReportedCrudePurchVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_reported.math_net_volume_be(c_si.to_object_id, p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.PURCHASE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;

*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerReportedCrudePurchVolBeCur IN c_crude LOOP

         ln_return_val := PerReportedCrudePurchVolBeCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;
*/

END GetPerReportedCrudePurchVolBe;

-- -------------------------------------------------------------------
-- Function :    GetPerReportedGasPurchVolSf
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerReportedGasPurchVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

IS
/*
CURSOR c_gas IS
  SELECT sum(ec_stim_mth_reported.math_net_volume_sf(c_si.to_object_id,p_from_day,p_to_day)) sum_gas
  FROM   objects_attribute a_s_scc
         ,objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- attribute: stream.stream_category_code
  and    a_s_scc.object_id = s_si.from_object_id
  and    a_s_scc.attribute_type = 'STREAM_CATEGORY_CODE'
  and    a_s_scc.attribute_text = Ecdp_System_Constants.PURCHASE  --p_stream_category -- end exists STREAM_CATEGORY_CODE attribute
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.GAS())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerReportedGasPurchVolSfCur IN c_gas LOOP

         ln_return_val := PerReportedGasPurchVolSfCur.sum_gas;

     END LOOP;

     RETURN ln_return_val;
*/

END GetPerReportedGasPurchVolSf;

-- -------------------------------------------------------------------
-- Function :    GetPerReportedCrudeVolBi
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerReportedCrudeVolBi(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_reported.math_net_volume_bi(c_si.to_object_id,p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation sic_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream_item_category
  and    sic_si.role_name = 'STREAM_ITEM_CATEGORY'
  and    sic_si.from_object_id = p_stream_item_category_obj_id
  and    sic_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- company.stream_item -> stream_item_category.stream_item
  and    c_si.to_object_id = sic_si.to_object_id
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerReportedCrudeVolBlCur IN c_crude LOOP

         ln_return_val := PerReportedCrudeVolBlCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;
*/

END GetPerReportedCrudeVolBi;

-- -------------------------------------------------------------------
-- Function :    GetPerReportedCrudeVolBe
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerReportedCrudeVolBe(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_crude IS
  SELECT sum(ec_stim_mth_reported.math_net_volume_be(c_si.to_object_id,p_from_day,p_to_day)) sum_crude
  FROM   objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation sic_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream_item_category
  and    sic_si.role_name = 'STREAM_ITEM_CATEGORY'
  and    sic_si.from_object_id = p_stream_item_category_obj_id
  and    sic_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- company.stream_item -> stream_item_category.stream_item
  and    c_si.to_object_id = sic_si.to_object_id
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.NGL())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerReportedCrudeVolBeCur IN c_crude LOOP

         ln_return_val := PerReportedCrudeVolBeCur.sum_crude;

     END LOOP;

     RETURN ln_return_val;
*/

END GetPerReportedCrudeVolBe;

-- -------------------------------------------------------------------
-- Function :    GetPerReportedGasVolSf
--
-- Description : Function used in report v_re_vo_sp_dl_earn_inp_uk_boo
-- -------------------------------------------------------------------

FUNCTION GetPerReportedGasVolSf(
   p_company_object_id VARCHAR2,
   p_field_object_id VARCHAR2,
   p_product_object_id VARCHAR2,
   p_stream_item_category_obj_id VARCHAR2,
   p_from_day DATE,
   p_to_day DATE
   )

RETURN NUMBER

--<EC-DOC>

IS
/*
CURSOR c_gas IS
  SELECT sum(ec_stim_mth_reported.math_net_volume_sf(c_si.to_object_id,p_from_day,p_to_day)) sum_gas
  FROM   objects_attribute a_p_pgc
         ,objects_relation c_si
         ,objects_relation f_si
         ,objects_relation s_si
         ,objects_relation sic_si
         ,objects_relation p_s
  WHERE
  -- company
         c_si.role_name = 'COMPANY'
  and    c_si.from_object_id = p_company_object_id
  and    c_si.to_class_name = 'STREAM_ITEM'
  -- field
  and    f_si.role_name = 'FIELD'
  and    f_si.from_object_id = p_field_object_id
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream
  and    s_si.role_name = 'STREAM'
  and    s_si.From_Class_Name = 'STREAM'
  and    f_si.to_class_name = 'STREAM_ITEM'
  -- stream_item_category
  and    sic_si.role_name = 'STREAM_ITEM_CATEGORY'
  and    sic_si.from_object_id = p_stream_item_category_obj_id
  and    sic_si.to_class_name = 'STREAM_ITEM'
  -- product -> stream
  and    p_s.to_object_id = s_si.from_object_id
  and    p_s.role_name = 'PRODUCT'
  and    p_s.from_object_id = p_product_object_id
  -- company.stream_item -> field.stream_item
  and    c_si.to_object_id = f_si.to_object_id
  -- company.stream_item -> stream.stream_item
  and    c_si.to_object_id = s_si.to_object_id
  -- company.stream_item -> stream_item_category.stream_item
  and    c_si.to_object_id = sic_si.to_object_id
  -- attribute: product.product_group_code
  and    a_p_pgc.object_id = p_s.from_object_id
  and    a_p_pgc.attribute_type = 'PRODUCT_GROUP_CODE'
  and    a_p_pgc.attribute_text in (Ecdp_System_Constants.Crude(),Ecdp_System_Constants.GAS())
  ;

  ln_return_val NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
  RETURN NULL;
/*
     FOR PerReportedGasVolSfCur IN c_gas LOOP

         ln_return_val := PerReportedGasVolSfCur.sum_gas;

     END LOOP;

     RETURN ln_return_val;
*/

END GetPerReportedGasVolSf;


-- slutt for reported versjon 04.02.2003


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : SumDayPeriodVol                                                                --
-- Description    : Calculate sum stim_day_value (to a specified uom) for a period.                                     --
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_DAY_VALUE                                                                --
--                                                                                                 --
-- Using functions:  EcDp_UOM.unit_convert                                                         --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------

FUNCTION SumDayPeriodVol(
   p_object_id VARCHAR2,
   p_from_daytime DATE,
   p_to_daytime DATE,
   p_to_uom_code VARCHAR2
   )

RETURN NUMBER

--<EC-DOC>

IS

CURSOR c_sdv IS
SELECT sum(EcDp_Unit.convertValue(s.net_volume_value, s.volume_uom_code, p_to_uom_code)) sum_period
FROM stim_day_value s
WHERE object_id = p_object_id
  AND daytime between p_from_daytime and p_to_daytime;

ln_return_val NUMBER;

BEGIN

     FOR DayPeriodCur IN c_sdv LOOP

         ln_return_val := DayPeriodCur.sum_period;

     END LOOP;

     RETURN ln_return_val;

END SumDayPeriodVol;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : SumPrevMthAsIsVol                                                                --
-- Description    : Calculate total value for previous month for a specified date.                                         --
--                  - if exists use montly value (stim_mth_actual) for the month previous specified
--                    in the daytime parameter. If not exists use sum dayly values (stim_day_value)
--                    for previous month
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :  STIM_DAY_VALUE                                                                --
--                                                                                                 --
-- Using functions:  EcDp_Stream_Item.SumDayPeriodVol                                                         --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION SumPrevMthAsIsVol(
   p_object_id VARCHAR2,
   p_daytime DATE,
   p_to_uom_code VARCHAR2
   )

RETURN NUMBER

--<EC-DOC>

IS

   ln_mth_val NUMBER;
   lv2_uom_subgroup VARCHAR2(32);

BEGIN

      lv2_uom_subgroup := EcDp_Unit.GetUOMSubGroup(p_to_uom_code);

      -- BBLS60
      IF lv2_uom_subgroup = 'BI' THEN

         -- if exists, get monthly values from previous month (stim_mth_actual)
         ln_mth_val := EcDp_Revn_Unit.convertValue(ec_stim_mth_actual.math_net_volume_bi(p_object_id, ADD_MONTHS(Trunc(p_daytime,'MM'),-1), Last_Day(ADD_MONTHS(Trunc(p_daytime,'MM'),-1)) ),
                                             EcDp_Unit.GetUOMSubGroupTarget(lv2_uom_subgroup),
                                             p_to_uom_code,
                                             p_object_id,
                                             p_daytime);

         -- else get total dayly volumes from previous month (stim_day_value)
         IF ln_mth_val IS NULL THEN

            ln_mth_val := Nvl(ecdp_stream_item.sumdayperiodvol(p_object_id, ADD_MONTHS(Trunc(p_daytime,'MM'),-1), Last_Day(ADD_MONTHS(Trunc(p_daytime,'MM'),-1) ), p_to_uom_code),0);

         END IF;

      -- MSCF
      ELSIF lv2_uom_subgroup = 'SF' THEN

         -- if exists, get monthly values from previous month (stim_mth_actual)
         ln_mth_val := EcDp_Revn_Unit.convertValue( ec_stim_mth_actual.math_net_volume_sf(p_object_id, ADD_MONTHS(Trunc(p_daytime,'MM'),-1), Last_Day(ADD_MONTHS(Trunc(p_daytime,'MM'),-1)) ),
                                              EcDp_Unit.GetUOMSubGroupTarget(lv2_uom_subgroup),
                                              p_to_uom_code,
                                              p_object_id,
                                              p_daytime);

         -- else get total dayly volumes from previous month (stim_day_value)
         IF ln_mth_val IS NULL THEN

            ln_mth_val := Nvl(ecdp_stream_item.sumdayperiodvol(p_object_id, ADD_MONTHS(Trunc(p_daytime,'MM'),-1), Last_Day(ADD_MONTHS(Trunc(p_daytime,'MM'),-1) ), p_to_uom_code),0);

         END IF;

      -- MNM3
      ELSIF lv2_uom_subgroup = 'NM' THEN

         -- if exists, get monthly values from previous month (stim_mth_actual)
         ln_mth_val := EcDp_Revn_Unit.convertValue( ec_stim_mth_actual.math_net_volume_nm(p_object_id, ADD_MONTHS(Trunc(p_daytime,'MM'),-1), Last_Day(ADD_MONTHS(Trunc(p_daytime,'MM'),-1)) ),
                                              EcDp_Unit.GetUOMSubGroupTarget(lv2_uom_subgroup),
                                              p_to_uom_code,
                                              p_object_id,
                                              p_daytime);

         -- else get total dayly volumes from previous month (stim_day_value)
         IF ln_mth_val IS NULL THEN

            ln_mth_val := Nvl(ecdp_stream_item.sumdayperiodvol(p_object_id, ADD_MONTHS(Trunc(p_daytime,'MM'),-1), Last_Day(ADD_MONTHS(Trunc(p_daytime,'MM'),-1) ), p_to_uom_code),0);

         END IF;

      -- MCM
      ELSIF lv2_uom_subgroup = 'SM' THEN

         -- if exists, get monthly values from previous month (stim_mth_actual)
         ln_mth_val := EcDp_Revn_Unit.convertValue( ec_stim_mth_actual.math_net_volume_sm(p_object_id, ADD_MONTHS(Trunc(p_daytime,'MM'),-1), Last_Day(ADD_MONTHS(Trunc(p_daytime,'MM'),-1)) ),
                                              EcDp_Unit.GetUOMSubGroupTarget(lv2_uom_subgroup),
                                              p_to_uom_code,
                                              p_object_id,
                                              p_daytime);

         -- else get total dayly volumes from previous month (stim_day_value)
         IF ln_mth_val IS NULL THEN

            ln_mth_val := Nvl(ecdp_stream_item.sumdayperiodvol(p_object_id, ADD_MONTHS(Trunc(p_daytime,'MM'),-1), Last_Day(ADD_MONTHS(Trunc(p_daytime,'MM'),-1) ), p_to_uom_code),0);

         END IF;

      END IF;

   RETURN ln_mth_val;

END SumPrevMthAsIsVol;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : SumYTDAsIsVol                                                                --
-- Description    : Calculate year to date as is volume.                                         --
--                  - dayly values for the month specified in daytime parameter (stim_day_value)
--                  - if exists use montly value (stim_mth_actual) for the month previous specified
--                    in the daytime parameter. If not exists use sum dayly values (stim_day_value)
--                    for previous month
--                  - for the rest previous months use figures from stim_mth_actual
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                                                --
--                                                                                                 --
-- Using functions:  EcDp_Stream_Item.SumDayPeriodVol                                              --
--                   EcDp_Stream_Item.SumPrevMthAsIsVol                                            --
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION SumYTDAsIsVol(
   p_object_id VARCHAR2,
   p_daytime DATE,
   p_to_uom_code VARCHAR2
   )

RETURN NUMBER

--<EC-DOC>

IS

   ln_day_val NUMBER;
   ln_mth_val NUMBER;
   ln_rest_val NUMBER;
   lv2_uom_subgroup VARCHAR2(32);

BEGIN

-- dayly figures for the month in specified daytime in parameter (stim_day_value)
   ln_day_val := ecdp_stream_item.sumdayperiodvol(p_object_id, TRUNC(p_daytime,'MM'), p_daytime, p_to_uom_code);

-- Get monthly value from previous month if daytime is not a date in January
   IF ADD_MONTHS(Trunc(p_daytime,'MM'),-1) > Trunc(p_daytime,'YYYY') THEN

      -- if exists, get monthly values from previous month (stim_mth_actual)
      ln_mth_val := ecdp_stream_item.sumPrevMthAsIsVol(p_object_id, p_daytime, p_to_uom_code);

      -- else get total dayly volumes from previous month (stim_day_value)
      IF ln_mth_val IS NULL THEN

         ln_mth_val := Nvl(ecdp_stream_item.sumdayperiodvol(p_object_id, ADD_MONTHS(Trunc(p_daytime,'MM'),-1), Last_Day(ADD_MONTHS(Trunc(p_daytime,'MM'),-1) ), p_to_uom_code),0);

      END IF;

   ELSE  -- If daytime in January, the previous month value := 0

       ln_mth_val := 0;

   END IF;

-- Get sum monthly values (stim_day_actual) if daytime is from March or later

   IF ADD_MONTHS(Trunc(p_daytime,'MM'),-2) > Trunc(p_daytime,'YYYY') THEN

      lv2_uom_subgroup := EcDp_Unit.GetUOMSubGroup(p_to_uom_code);

      -- BBLS60
      IF lv2_uom_subgroup = 'BL' THEN

         ln_rest_val := EcDp_Revn_Unit.convertValue(ec_stim_mth_actual.math_net_volume_bi(p_object_id, Trunc(p_daytime,'YYYY'), ADD_MONTHS(Trunc(p_daytime,'MM'),-2) ),
                                              EcDp_Unit.GetUOMSubGroupTarget(lv2_uom_subgroup),
                                              p_to_uom_code,
                                              p_object_id,
                                              p_daytime);
      -- MSCF
      ELSIF lv2_uom_subgroup = 'SF' THEN

         ln_rest_val := EcDp_Revn_Unit.convertValue(ec_stim_mth_actual.math_net_volume_sf(p_object_id, Trunc(p_daytime,'YYYY'), ADD_MONTHS(Trunc(p_daytime,'MM'),-2) ),
                                              EcDp_Unit.GetUOMSubGroupTarget(lv2_uom_subgroup),
                                              p_to_uom_code,
                                              p_object_id,
                                              p_daytime);

      -- MNM3
      ELSIF lv2_uom_subgroup = 'NM' THEN

         ln_rest_val := EcDp_Revn_Unit.convertValue(ec_stim_mth_actual.math_net_volume_sf(p_object_id, Trunc(p_daytime,'YYYY'), ADD_MONTHS(Trunc(p_daytime,'MM'),-2) ),
                                              EcDp_Unit.GetUOMSubGroupTarget(lv2_uom_subgroup),
                                              p_to_uom_code,
                                              p_object_id,
                                              p_daytime);

      -- MCM
      ELSIF lv2_uom_subgroup = 'SM' THEN

         ln_rest_val := EcDp_Revn_Unit.convertValue(ec_stim_mth_actual.math_net_volume_sm(p_object_id, Trunc(p_daytime,'YYYY'), ADD_MONTHS(Trunc(p_daytime,'MM'),-2) ),
                                              EcDp_Unit.GetUOMSubGroupTarget(lv2_uom_subgroup),
                                              p_to_uom_code,
                                              p_object_id,
                                              p_daytime);

      END IF;

   ELSE  -- If daytime in January or February, the rest of month values := 0

      ln_rest_val := 0;

   END IF;

   RETURN ln_day_val + nvl(ln_mth_val, 0) + nvl(ln_rest_val, 0);
--   RETURN ln_day_val + ln_mth_val + ln_rest_val;

END SumYTDAsIsVol;

PROCEDURE ImportSIValueMth(
   p_object_id             VARCHAR2,
   p_daytime             DATE,
   ptab_uom_set          EcDp_Unit.t_uomtable,
   p_status              VARCHAR2,
   p_user                VARCHAR2,
   p_upd_flag            VARCHAR2 DEFAULT 'ADD_INCR', -- use REPLACE to set new values, ADD_INCR to add to existing
   p_reverse_factor      NUMBER DEFAULT 1
)

IS
/*
CURSOR c_siv IS
SELECT *
FROM stim_mth_value
WHERE object_id = p_object_id
  AND daytime = Trunc(p_daytime,'MM');

no_valid_master_uom EXCEPTION;
not_equal_uom_group EXCEPTION;
no_entry_found EXCEPTION;
conversion_not_possible EXCEPTION;

ln_rec_count NUMBER;
lv2_master_uom_code VARCHAR2(32) := EcDp_Objects.GetObjAttrText(p_object_id, p_daytime, 'MASTER_UOM_GROUP');
ln_qty NUMBER;

ltab_uom_set EcDp_UOM.t_UOMTable := ptab_uom_set;
lrec_siv t_siv_net;

lv2_upd_flag VARCHAR2(32) := p_upd_flag;


ln_log_qty NUMBER :=  ltab_uom_set(1).qty;
lv2_log_uom VARCHAR2(200) := ltab_uom_set(1).uom;
lv2_cursor_uom VARCHAR2(200);
lv2_calc_method VARCHAR2(32);
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
   IF lv2_master_uom_code NOT IN ('V','M','E') OR lv2_master_uom_code IS NULL THEN RAISE no_valid_master_uom; END IF;

   IF lv2_master_uom_code <> GetUOMGroup(ltab_uom_set(1).uom) THEN RAISE not_equal_uom_group; END IF;

   ln_rec_count := 0;

   FOR SIVCur IN c_siv LOOP

     ln_rec_count := ln_rec_count + 1;
     lv2_cursor_uom := SIVCur.volume_uom_code;
     ln_qty := EcDp_UOM.GetUOMSetQty(ltab_uom_set, SIVCur.volume_uom_code, Ecdp_Timestamp.getCurrentSysdate, p_object_id);

     IF (ln_qty is null) THEN RAISE conversion_not_possible; END IF;

     IF (p_reverse_factor = -1) THEN
         IF (lv2_master_uom_code = 'M' AND ln_qty = 0) OR
            (lv2_master_uom_code = 'V' AND ln_qty = 0) OR
            (lv2_master_uom_code = 'E' AND ln_qty = 0) THEN
             lv2_upd_flag := 'ORIGINAL';
             lv2_calc_method := EcDp_Objects.GetObjAttrText(p_object_id, p_daytime, 'CALC_METHOD');
         END IF;
     END IF;

     IF (lv2_master_uom_code = 'V') THEN

        UPDATE stim_mth_value
        SET net_volume_value = ln_qty
            ,status = decode(status, 'FINAL', 'FINAL', Nvl(p_status, status) ) -- change if not FINAL (hierarchy is NULL - ACCRUAL - FINAL
            ,calc_method = decode(lv2_upd_flag,'ADD_INCR','SP', 'REPLACE','SP','ORIGINAL',lv2_calc_method, calc_method)
            ,contract_object_id = decode(lv2_upd_flag,'ORIGINAL',NULL, contract_object_id)
            ,line_item_id = decode(lv2_upd_flag,'ORIGINAL',NULL, line_item_id)
            ,last_updated_by = p_user
        WHERE object_id = p_object_id
        AND daytime = Trunc(p_daytime,'MM');

     ELSIF (lv2_master_uom_code = 'M') THEN

        UPDATE stim_mth_value
        SET net_mass_value = ln_qty
            ,status = decode(status, 'FINAL', 'FINAL', Nvl(p_status, status) ) -- change if not FINAL (hierarchy is NULL - ACCRUAL - FINAL
            ,calc_method = decode(lv2_upd_flag,'ADD_INCR','SP', 'REPLACE','SP','ORIGINAL',lv2_calc_method, calc_method)
            ,contract_object_id = decode(lv2_upd_flag,'ORIGINAL',NULL, contract_object_id)
            ,line_item_id = decode(lv2_upd_flag,'ORIGINAL',NULL, line_item_id)
            ,last_updated_by = p_user
        WHERE object_id = p_object_id
        AND daytime = Trunc(p_daytime,'MM');

     ELSIF (lv2_master_uom_code = 'E') THEN

        UPDATE stim_mth_value
        SET net_mass_value = ln_qty
            ,status = decode(status, 'FINAL', 'FINAL', Nvl(p_status, status) ) -- change if not FINAL (hierarchy is NULL - ACCRUAL - FINAL
            ,calc_method = decode(lv2_upd_flag,'ADD_INCR','SP', 'REPLACE','SP','ORIGINAL',lv2_calc_method, calc_method)
            ,contract_object_id = decode(lv2_upd_flag,'ORIGINAL',NULL, contract_object_id)
            ,line_item_id = decode(lv2_upd_flag,'ORIGINAL',NULL, line_item_id)
            ,last_updated_by = p_user
        WHERE object_id = p_object_id
        AND daytime = Trunc(p_daytime,'MM');

     END IF;

   END LOOP;


   IF(ln_rec_count = 0) THEN
      raise no_entry_found;
   END IF;


EXCEPTION

     WHEN no_valid_master_uom THEN

         RAISE_APPLICATION_ERROR(-20000,'No valid UOM master for stream item: '|| Nvl( EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'CODE'), ' ') || '    ' || Nvl( EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'NAME'), ' ')  ) ;

     WHEN not_equal_uom_group THEN

         RAISE_APPLICATION_ERROR(-20000,'Not corresponding UOM groups. UOM group from file: ' || GetUOMGroup(ltab_uom_set(1).uom) || ' - UOM for Stream Item: ' || lv2_master_uom_code);

     WHEN no_entry_found THEN

         RAISE_APPLICATION_ERROR(-20000,'No entry found in stim_mth_value for this stream item (' || ecdp_objects.GetObjAttrText(p_object_id, Ecdp_Timestamp.getCurrentSysdate, 'CODE') || ') on this date (' || p_daytime || ')');

     WHEN conversion_not_possible THEN

         RAISE_APPLICATION_ERROR(-20000,'Could not convert between units ' || lv2_log_uom || ' and ' || lv2_cursor_uom);
*/
END ImportSIValueMth;

PROCEDURE UpdAddToSIValueMth(
   p_object_id             VARCHAR2,
   p_daytime               DATE,
   ptab_uom_set            EcDp_Unit.t_uomtable,
   p_status                VARCHAR2,
   p_user                  VARCHAR2,
   p_upd_flag              VARCHAR2 DEFAULT 'ADD_INCR', -- use REPLACE to set new values, ADD_INCR to add to existing
   p_reverse_factor        NUMBER DEFAULT 1,
   p_do_delete             BOOLEAN DEFAULT TRUE,
   p_contract_id           VARCHAR2 DEFAULT NULL,
   p_alloc_no              NUMBER DEFAULT NULL,
   p_vendor_id             VARCHAR2 DEFAULT NULL,
   p_delivery_point_id     VARCHAR2 DEFAULT NULL,
   p_price_concept_code    VARCHAR2 DEFAULT NULL,
   p_cargo_name            VARCHAR2 DEFAULT NULL,
   p_parcel_name           VARCHAR2 DEFAULT NULL,
   p_qty_type              VARCHAR2 DEFAULT NULL,
   p_is_cascade_scheduled  VARCHAR2 DEFAULT 'N'
)

IS

CURSOR c_siv IS
SELECT nvl(smv.calc_method,ec_stream_item_version.calc_method(smv.object_id,smv.daytime,'<=')) calc_method,
       smv.volume_uom_code,
       smv.net_volume_value,
       smv.mass_uom_code,
       smv.net_mass_value,
       smv.energy_uom_code,
       smv.net_energy_value,
       smv.extra1_uom_code,
       smv.net_extra1_value,
       smv.extra2_uom_code,
       smv.net_extra2_value,
       smv.extra3_uom_code,
       smv.net_extra3_value
  FROM stim_mth_value smv
 WHERE object_id = p_object_id
   AND daytime = Trunc(p_daytime, 'MM');

not_master_uom      EXCEPTION;
no_valid_master_uom EXCEPTION;

lv2_master_uom_code VARCHAR2(32) := ec_stream_item_version.master_uom_group(p_object_id, p_daytime, '<=');
lv2_calc_method     VARCHAR2(32);
lv2_upd_flag        VARCHAR2(32) := p_upd_flag;
lv2_transaction_key VARCHAR2(32) := NULL;

ln_qty              NUMBER;
ln_prev_qty         NUMBER;
ln_delta            NUMBER;

ib_update           BOOLEAN := FALSE;

ltab_uom_set EcDp_Unit.t_UOMTable := ptab_uom_set;
ltab_prev_uom_set EcDp_Unit.t_UOMTable := EcDp_Unit.t_uomtable();
lrec_siv t_siv_net;

BEGIN

   IF lv2_master_uom_code NOT IN ('V','M','E') OR lv2_master_uom_code IS NULL THEN RAISE no_valid_master_uom; END IF;

   FOR SIVCur IN c_siv LOOP

        IF lv2_upd_flag = 'ADD_INCR' AND SIVCur.calc_method <> 'SP' THEN

           lv2_upd_flag := 'REPLACE'; -- in this case, we need to reset before applying increments

        END IF;



        ----------------------------------------------------------------------
        -- Volume
        IF SIVCur.volume_uom_code IS NOT NULL THEN

           ln_qty := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, SivCur.volume_uom_code, p_daytime, p_object_id, p_do_delete);

           -- raise error if we do not have a valid master
           IF lv2_master_uom_code = 'V' AND ln_qty IS NULL THEN

              RAISE not_master_uom;

           END IF;

           -- do we have volume ?
           IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_volume_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;
                   lrec_siv.net_volume_value := Nvl(SIVCur.net_volume_value,0) + ln_qty;

               END IF;
            END IF;
        END IF;


        --------------------------
        -- Mass
        IF SIVCur.mass_uom_code IS NOT NULL THEN

          ln_qty := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, SivCur.mass_uom_code, p_daytime, p_object_id, p_do_delete);

           -- raise error if we do not have a valid master
           IF lv2_master_uom_code = 'M' AND ln_qty IS NULL THEN

              RAISE not_master_uom;

           END IF;

          -- do we have mass ?
           IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_mass_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_mass_value := Nvl(SIVCur.net_mass_value,0) + ln_qty;

               END IF;
            END IF;
       END IF;


       --------------------------
       -- energy
       IF SIVCur.energy_uom_code IS NOT NULL THEN

          ln_qty := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, SivCur.energy_uom_code, p_daytime, p_object_id, p_do_delete);

           -- raise error if we do not have a valid master
           IF lv2_master_uom_code = 'E' AND ln_qty IS NULL THEN

              RAISE not_master_uom;

           END IF;

          -- do we have energy ?
          IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_energy_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_energy_value := Nvl(SIVCur.net_energy_value,0) + ln_qty;

               END IF;
           END IF;
       END IF;


       --------------------------
       -- extra1
       IF SIVCur.extra1_uom_code IS NOT NULL THEN

          ln_qty := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, SivCur.extra1_uom_code, p_daytime, p_object_id, p_do_delete);

          -- do we have any match  ?
          IF ln_qty IS NOT NULL THEN


               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_extra1_value := ln_qty;


               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_extra1_value := Nvl(SIVCur.net_extra1_value,0) + ln_qty;

               END IF;
           END IF;
       END IF;


       --------------------------
       -- extra2
       IF SIVCur.extra2_uom_code IS NOT NULL THEN

          ln_qty := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, SivCur.extra2_uom_code, p_daytime, p_object_id, p_do_delete);

          -- do we have any match  ?
          IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_extra2_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_extra2_value := Nvl(SIVCur.net_extra2_value,0) + ln_qty;

               END IF;
           END IF;
       END IF;


       --------------------------
       --  extra3
       IF SIVCur.extra3_uom_code IS NOT NULL THEN

          ln_qty := EcDp_Revn_Unit.GetUOMSetQty(ltab_uom_set, SivCur.extra3_uom_code, p_daytime, p_object_id, p_do_delete);

          -- do we have any match  ?
          IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_extra3_value := ln_qty;


               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_extra3_value := Nvl(SIVCur.net_extra3_value,0) + ln_qty;

               END IF;
           END IF;
       END IF;


       --- now update
       IF ib_update THEN

           IF (p_reverse_factor = -1) THEN
               IF (lv2_master_uom_code = 'M' AND lrec_siv.net_mass_value = 0) OR
                  (lv2_master_uom_code = 'V' AND lrec_siv.net_volume_value = 0) OR
                  (lv2_master_uom_code = 'E' AND lrec_siv.net_energy_value = 0) THEN
                   lv2_upd_flag := 'ORIGINAL';
                   lv2_calc_method := ec_stream_item_version.calc_method(p_object_id, p_daytime, '<=');
               END IF;
           END IF;

           UPDATE stim_mth_value
              SET net_volume_value = lrec_siv.net_volume_value
                 ,net_mass_value = lrec_siv.net_mass_value
                 ,net_energy_value = lrec_siv.net_energy_value
                 ,net_extra1_value = lrec_siv.net_extra1_value
                 ,net_extra2_value = lrec_siv.net_extra2_value
                 ,net_extra3_value = lrec_siv.net_extra3_value
                 ,status = decode(status, 'FINAL', 'FINAL', Nvl(p_status, status)) -- change if not FINAL (hierarchy is NULL - ACCRUAL - FINAL
                 ,calc_method = decode(lv2_upd_flag,'ADD_INCR','SP', 'REPLACE','SP','DELTA','SP','ORIGINAL',lv2_calc_method, calc_method)
                 ,transaction_key = decode(lv2_upd_flag,'ORIGINAL',NULL, transaction_key)
                 ,last_updated_by = p_user
            WHERE object_id = p_object_id
              AND daytime = Trunc(p_daytime,'MM');

            -- Cascading must be run after FT-VO update
            IF p_is_cascade_scheduled = 'Y' THEN
               INSERT INTO stim_cascade_asynch (object_id,period,daytime,bulk_cascade_ind)
               VALUES (p_object_id,'MTH',Trunc(p_daytime,'MM'),'Y');
            ELSE
               INSERT INTO stim_cascade (object_id,period,daytime)
               VALUES (p_object_id,'MTH',Trunc(p_daytime,'MM'));
            END IF;

       END IF;

   END LOOP;

EXCEPTION

     WHEN not_master_uom THEN

        Raise_Application_Error(-20000,'Missing quantity for the master UOM for stream item: '|| Nvl( ec_stream_item.object_code(p_object_id), ' ') || '    ' || Nvl( ec_stream_item_version.name(p_object_id,p_daytime,'<='), ' ')  ) ;

     WHEN no_valid_master_uom THEN

         RAISE_APPLICATION_ERROR(-20000,'No valid UOM master for stream item: '|| Nvl( ec_stream_item.object_code(p_object_id), ' ') || '    ' || Nvl( ec_stream_item_version.name(p_object_id,p_daytime,'<='), ' ')  ) ;

END UpdAddToSIValueMth;


PROCEDURE ImportSIValueDay(
   p_object_id             VARCHAR2,
   p_daytime             DATE,
   ptab_uom_set          EcDp_Unit.t_uomtable,
   p_status              VARCHAR2,
   p_user                VARCHAR2,
   p_upd_flag            VARCHAR2 DEFAULT 'ADD_INCR' -- use REPLACE to set new values, ADD_INCR to add to existing
)

IS
/*
CURSOR c_siv IS
SELECT *
FROM stim_day_value
WHERE object_id = p_object_id
  AND daytime = p_daytime;

no_valid_master_uom EXCEPTION;
not_equal_uom_group EXCEPTION;
no_entry_found EXCEPTION;
conversion_not_possible EXCEPTION;

ln_rec_count NUMBER;
lv2_master_uom_code VARCHAR2(32) := EcDp_Objects.GetObjAttrText(p_object_id, p_daytime, 'MASTER_UOM_GROUP');
ln_qty NUMBER;

ltab_uom_set EcDp_UOM.t_UOMTable := ptab_uom_set;
lrec_siv t_siv_net;

lv2_upd_flag VARCHAR2(32) := p_upd_flag;


ln_log_qty NUMBER :=  ltab_uom_set(1).qty;
lv2_log_uom VARCHAR2(200) := ltab_uom_set(1).uom;
lv2_cursor_uom VARCHAR2(200);
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
   IF lv2_master_uom_code NOT IN ('V','M','E') OR lv2_master_uom_code IS NULL THEN RAISE no_valid_master_uom; END IF;

   IF lv2_master_uom_code <> GetUOMGroup(ltab_uom_set(1).uom) THEN RAISE not_equal_uom_group; END IF;

   ln_rec_count := 0;

   FOR SIVCur IN c_siv LOOP

     ln_rec_count := ln_rec_count + 1;
     lv2_cursor_uom := SIVCur.volume_uom_code;
     ln_qty := EcDp_UOM.GetUOMSetQty(ltab_uom_set, SIVCur.volume_uom_code, Ecdp_Timestamp.getCurrentSysdate, p_object_id);

     IF (ln_qty is null) THEN RAISE conversion_not_possible; END IF;

     IF (lv2_master_uom_code = 'V') THEN

        UPDATE stim_day_value
        SET net_volume_value = ln_qty
            ,status = decode(status, 'FINAL', status, Nvl(p_status, status) ) -- change if not FINAL (hierarchy is NULL - ACCRUAL - FINAL
            ,calc_method = decode(lv2_upd_flag,'ADD_INCR','SP',calc_method)
            ,last_updated_by = p_user
        WHERE object_id = p_object_id
        AND daytime = p_daytime;

     ELSIF (lv2_master_uom_code = 'M') THEN

        UPDATE stim_day_value
        SET net_mass_value = ln_qty
            ,status = decode(status, 'FINAL', status, Nvl(p_status, status) ) -- change if not FINAL (hierarchy is NULL - ACCRUAL - FINAL
            ,calc_method = decode(lv2_upd_flag,'ADD_INCR','SP',calc_method)
            ,last_updated_by = p_user
        WHERE object_id = p_object_id
        AND daytime = p_daytime;

     ELSIF (lv2_master_uom_code = 'E') THEN

        UPDATE stim_day_value
        SET net_mass_value = ln_qty
            ,status = decode(status, 'FINAL', status, Nvl(p_status, status) ) -- change if not FINAL (hierarchy is NULL - ACCRUAL - FINAL
            ,calc_method = decode(lv2_upd_flag,'ADD_INCR','SP',calc_method)
            ,last_updated_by = p_user
        WHERE object_id = p_object_id
        AND daytime = p_daytime;

     END IF;

   END LOOP;


   IF(ln_rec_count = 0) THEN
      raise no_entry_found;
   END IF;


EXCEPTION

     WHEN no_valid_master_uom THEN

         RAISE_APPLICATION_ERROR(-20000,'No valid UOM master for stream item: '|| Nvl( EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'CODE'), ' ') || '    ' || Nvl( EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'NAME'), ' ')  ) ;

     WHEN not_equal_uom_group THEN

         RAISE_APPLICATION_ERROR(-20000,'Not corresponding UOM groups. UOM group from file: ' || GetUOMGroup(ltab_uom_set(1).uom) || ' - UOM for Stream Item: ' || lv2_master_uom_code);

     WHEN no_entry_found THEN

         RAISE_APPLICATION_ERROR(-20000,'No entry found in stim_day_value for this stream item (' || ecdp_objects.GetObjAttrText(p_object_id, Ecdp_Timestamp.getCurrentSysdate, 'CODE') || ') on this date (' || p_daytime || ')');

     WHEN conversion_not_possible THEN

         RAISE_APPLICATION_ERROR(-20000,'Could not convert between units ' || lv2_log_uom || ' and ' || lv2_cursor_uom);
*/
END ImportSIValueDay;

FUNCTION GetUOMGroup(
  p_uom VARCHAR2)
RETURN VARCHAR2
IS

lv2_found_group VARCHAR2(10);

BEGIN

  lv2_found_group := '';

  SELECT
     uom_group
  INTO
     lv2_found_group
  FROM
     ctrl_unit cu
  WHERE
     cu.unit = p_uom;


   return lv2_found_group;

END GetUOMGroup;

PROCEDURE UpdAddToSIValueDay(
   p_object_id             VARCHAR2,
   p_daytime             DATE,
   ptab_uom_set          EcDp_Unit.t_uomtable,
   p_status              VARCHAR2,
   p_user                VARCHAR2,
   p_upd_flag            VARCHAR2 DEFAULT 'ADD_INCR' -- use REPLACE to set new values, ADD_INCR to add to existing
)

IS
/*

CURSOR c_siv IS
SELECT *
FROM stim_day_value
WHERE object_id = p_object_id
  AND daytime = p_daytime;

not_master_uom EXCEPTION;
no_valid_master_uom EXCEPTION;

lv2_master_uom_code VARCHAR2(32) := EcDp_Objects.GetObjAttrText(p_object_id, p_daytime, 'MASTER_UOM_GROUP');
ln_qty NUMBER;

ib_update BOOLEAN := FALSE;

ltab_uom_set EcDp_UOM.t_UOMTable := ptab_uom_set;
lrec_siv t_siv_net;

lv2_upd_flag VARCHAR2(32) := p_upd_flag;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');
/*
   IF lv2_master_uom_code NOT IN ('V','M','E') OR lv2_master_uom_code IS NULL THEN RAISE no_valid_master_uom; END IF;

   FOR SIVCur IN c_siv LOOP

        IF lv2_upd_flag = 'ADD_INCR' AND SIVCur.calc_method <> 'SP' THEN

           lv2_upd_flag := 'REPLACE'; -- in this case, we need to reset before applying increments

        END IF;

        ----------------------------------------------------------------------
        -- Volume
        IF SIVCur.volume_uom_code IS NOT NULL THEN

           ln_qty := EcDp_UOM.GetUOMSetQty(ltab_uom_set, SivCur.volume_uom_code, p_daytime, p_object_id);

           -- raise error if we do not have a valid master
           IF lv2_master_uom_code = 'V' AND ln_qty IS NULL THEN

              RAISE not_master_uom;

           END IF;

           -- do we have volume ?
           IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_volume_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_volume_value := Nvl(SIVCur.net_volume_value,0) + ln_qty;

                END IF;

            END IF;

        END IF;

        --------------------------
        -- Mass
        IF SIVCur.mass_uom_code IS NOT NULL THEN

          ln_qty := EcDp_UOM.GetUOMSetQty(ltab_uom_set, SivCur.mass_uom_code, p_daytime, p_object_id);

           -- raise error if we do not have a valid master
           IF lv2_master_uom_code = 'M' AND ln_qty IS NULL THEN

              RAISE not_master_uom;

           END IF;

          -- do we have mass ?
           IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_mass_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_mass_value := Nvl(SIVCur.net_mass_value,0) + ln_qty;

               END IF;

            END IF;

       END IF;


       --------------------------
       -- energy
       IF SIVCur.energy_uom_code IS NOT NULL THEN

          ln_qty := EcDp_UOM.GetUOMSetQty(ltab_uom_set, SivCur.energy_uom_code, p_daytime, p_object_id);

           -- raise error if we do not have a valid master
           IF lv2_master_uom_code = 'E' AND ln_qty IS NULL THEN

              RAISE not_master_uom;

           END IF;

          -- do we have energy ?
          IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_energy_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_energy_value := Nvl(SIVCur.net_energy_value,0) + ln_qty;

               END IF;

           END IF;

       END IF;


       --------------------------
       -- extra1
       IF SIVCur.extra1_uom_code IS NOT NULL THEN

          ln_qty := EcDp_UOM.GetUOMSetQty(ltab_uom_set, SivCur.extra1_uom_code, p_daytime, p_object_id);

          -- do we have any match  ?
          IF ln_qty IS NOT NULL THEN


               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_extra1_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_extra1_value := Nvl(SIVCur.net_extra1_value,0) + ln_qty;

                END IF;

           END IF;

       END IF;


       --------------------------
       -- extra2
       IF SIVCur.extra2_uom_code IS NOT NULL THEN

          ln_qty := EcDp_UOM.GetUOMSetQty(ltab_uom_set, SivCur.extra2_uom_code, p_daytime, p_object_id);

          -- do we have any match  ?
          IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_extra2_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_extra2_value := Nvl(SIVCur.net_extra2_value,0) + ln_qty;

               END IF;

           END IF;

       END IF;


       --------------------------
       --  extra3
       IF SIVCur.extra3_uom_code IS NOT NULL THEN

          ln_qty := EcDp_UOM.GetUOMSetQty(ltab_uom_set, SivCur.extra3_uom_code, p_daytime, p_object_id);

          -- do we have any match  ?
          IF ln_qty IS NOT NULL THEN

               IF lv2_upd_flag = 'REPLACE' THEN

                  ib_update := TRUE;
                  lrec_siv.net_extra3_value := ln_qty;

               ELSIF lv2_upd_flag = 'ADD_INCR' THEN

                   ib_update := TRUE;

                   lrec_siv.net_extra3_value := Nvl(SIVCur.net_extra3_value,0) + ln_qty;

               END IF;

           END IF;

       END IF;


       --- now update
       IF ib_update THEN

           UPDATE stim_day_value
              SET net_volume_value = lrec_siv.net_volume_value
                 ,net_mass_value = lrec_siv.net_mass_value
                 ,net_energy_value = lrec_siv.net_energy_value
                 ,net_extra1_value = lrec_siv.net_extra1_value
                 ,net_extra2_value = lrec_siv.net_extra2_value
                 ,net_extra3_value = lrec_siv.net_extra3_value
                 ,status = decode(status, 'FINAL', status, Nvl(p_status, status) ) -- change if not FINAL (hierarchy is NULL - ACCRUAL - FINAL
                 ,calc_method = decode(lv2_upd_flag,'ADD_INCR','SP',calc_method)
                 ,last_updated_by = p_user
            WHERE object_id = p_object_id
              AND daytime = p_daytime;

           -- Cascading must be run after FT-VO update
               INSERT INTO stim_cascade (object_id,period,daytime)
               VALUES (p_object_id,'DAY',p_daytime);
       END IF;

   END LOOP;

EXCEPTION

     WHEN not_master_uom THEN

        Raise_Application_Error(-20000,'Missing quantity for the master UOM for stream item: '|| Nvl( EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'CODE'), ' ') || '    ' || Nvl( EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'NAME'), ' ')  ) ;

     WHEN no_valid_master_uom THEN

         RAISE_APPLICATION_ERROR(-20000,'No valid UOM master for stream item: '|| Nvl( EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'CODE'), ' ') || '    ' || Nvl( EcDp_Objects.GetObjAttrText(p_object_id,p_daytime,'NAME'), ' ')  ) ;
*/

END UpdAddToSIValueDay;

PROCEDURE GenMthAsBookedStaticData(
   p_daytime             DATE,
   p_last_run_time       DATE
)

IS

CURSOR c_siv (pc_last_closed_period DATE) IS
SELECT *
FROM stim_mth_value
WHERE last_updated_date >= p_last_run_time
  AND daytime = p_daytime;

lr_net_sub_uom t_net_sub_uom;
lr_prev_booked stim_mth_booked%ROWTYPE;
lr_prev_value stim_mth_value%ROWTYPE;
lr_this_value stim_mth_value%ROWTYPE;

ld_last_closed_period DATE; -- NOTYET GetLastClosedDate(p_system_id,'B');

BEGIN

        -- create empty records
        INSERT INTO stim_mth_booked
        (object_id,
         daytime,
         status,
         period_ref_item,
         calc_method,
         comments,
         created_by,
         created_date
        )
        SELECT
         object_id,
         daytime,
         status,
         period_ref_item,
         calc_method,
         comments,
         'SYSTEM',
         Ecdp_Timestamp.getCurrentSysdate
        FROM stim_mth_value x
         WHERE created_date > p_last_run_time
          AND daytime = p_daytime
          AND NOT EXISTS (SELECT 'x' FROM stim_mth_booked
                          WHERE object_id = x.object_id
                            AND daytime = x.daytime) ;

        FOR StrmItmCur IN c_siv(ld_last_closed_period) LOOP

         lr_prev_booked := ec_stim_mth_booked.row_by_pk(StrmItmCur.object_id, Add_Months(StrmItmCur.daytime,-1), '=');
         lr_prev_value := ec_stim_mth_value.row_by_pk(StrmItmCur.object_id, Add_Months(StrmItmCur.daytime,-1), '=');
         lr_this_value := StrmItmCur;


         lr_net_sub_uom.net_energy_jo :=
              GetSubGroupValue(lr_this_value, 'E', 'JO')
            + NVL(GetSubGroupValue(lr_prev_value, 'E', 'JO'),0)
            -  NVL(lr_prev_booked.net_energy_jo,0);



         lr_net_sub_uom.net_energy_th :=
              GetSubGroupValue(lr_this_value, 'E', 'TH')
            + NVL(GetSubGroupValue(lr_prev_value, 'E', 'TH'),0)
            -  NVL(lr_prev_booked.net_energy_th,0);

         lr_net_sub_uom.net_energy_wh :=
              GetSubGroupValue(lr_this_value, 'E', 'WH')
            + NVL(GetSubGroupValue(lr_prev_value, 'E', 'WH'),0)
            -  NVL(lr_prev_booked.net_energy_wh,0);

         lr_net_sub_uom.net_energy_be :=
              GetSubGroupValue(lr_this_value, 'E', 'BE')
            + NVL(GetSubGroupValue(lr_prev_value, 'E', 'BE'),0)
            -  NVL(lr_prev_booked.net_energy_be,0);

         lr_net_sub_uom.net_mass_ma :=
              GetSubGroupValue(lr_this_value, 'M', 'MA')
            + NVL(GetSubGroupValue(lr_prev_value, 'M', 'MA'),0)
            -  NVL(lr_prev_booked.net_mass_ma,0);

         lr_net_sub_uom.net_mass_mv :=
              GetSubGroupValue(lr_this_value, 'M', 'MV')
            + NVL(GetSubGroupValue(lr_prev_value, 'M', 'MV'),0)
            -  NVL(lr_prev_booked.net_mass_mv,0);

         lr_net_sub_uom.net_mass_ua :=
              GetSubGroupValue(lr_this_value, 'M', 'UA')
            + NVL(GetSubGroupValue(lr_prev_value, 'M', 'UA'),0)
            -  NVL(lr_prev_booked.net_mass_ua,0);

         lr_net_sub_uom.net_mass_uv :=
              GetSubGroupValue(lr_this_value, 'M', 'UV')
            + NVL(GetSubGroupValue(lr_prev_value, 'M', 'UV'),0)
            -  NVL(lr_prev_booked.net_mass_uv,0);

         lr_net_sub_uom.net_volume_bi :=
              GetSubGroupValue(lr_this_value, 'V', 'BI')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'BI'),0)
            -  NVL(lr_prev_booked.net_volume_bi,0);

        lr_net_sub_uom.net_volume_bm :=
              GetSubGroupValue(lr_this_value, 'V', 'BM')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'BM'),0)
            -  NVL(lr_prev_booked.net_volume_bm,0);

         lr_net_sub_uom.net_volume_sf :=
              GetSubGroupValue(lr_this_value, 'V', 'SF')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'SF'),0)
            -  NVL(lr_prev_booked.net_volume_sf,0);

         lr_net_sub_uom.net_volume_nm :=
              GetSubGroupValue(lr_this_value, 'V', 'NM')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'NM'),0)
            -  NVL(lr_prev_booked.net_volume_nm,0);

         lr_net_sub_uom.net_volume_sm :=
              GetSubGroupValue(lr_this_value, 'V', 'SM')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'SM'),0)
            -  NVL(lr_prev_booked.net_volume_sm,0);

         -- now update table
         UPDATE stim_mth_booked
           SET NET_ENERGY_JO         = lr_net_sub_uom.NET_ENERGY_JO
              ,NET_ENERGY_TH         = lr_net_sub_uom.NET_ENERGY_TH
              ,NET_ENERGY_WH         = lr_net_sub_uom.NET_ENERGY_WH
              ,NET_ENERGY_BE         = lr_net_sub_uom.NET_ENERGY_BE
              ,NET_MASS_MA           = lr_net_sub_uom.NET_MASS_MA
              ,NET_MASS_MV           = lr_net_sub_uom.NET_MASS_MV
              ,NET_MASS_UA           = lr_net_sub_uom.NET_MASS_UA
              ,NET_MASS_UV           = lr_net_sub_uom.NET_MASS_UV
              ,NET_VOLUME_BI         = lr_net_sub_uom.NET_VOLUME_BI
              ,NET_VOLUME_BM         = lr_net_sub_uom.NET_VOLUME_BM
              ,NET_VOLUME_SF         = lr_net_sub_uom.NET_VOLUME_SF
              ,NET_VOLUME_NM         = lr_net_sub_uom.NET_VOLUME_NM
              ,NET_VOLUME_SM         = lr_net_sub_uom.NET_VOLUME_SM
              ,last_updated_by = 'SYSTEM'
         WHERE object_id = StrmItmCur.object_id
           AND daytime = StrmItmCur.daytime;

     END LOOP;

END GenMthAsBookedStaticData;

PROCEDURE GenMthAsReportedStaticData(
   p_daytime             DATE,
   p_last_run_time       DATE
)

IS

CURSOR c_siv  IS
SELECT *
FROM stim_mth_value
WHERE last_updated_date >= p_last_run_time
  AND daytime = p_daytime;

lr_net_sub_uom t_net_sub_uom;
lr_prev_reported stim_mth_reported%ROWTYPE;
lr_prev_value stim_mth_value%ROWTYPE;
lr_this_value stim_mth_value%ROWTYPE;

BEGIN

        -- create empty records
        INSERT INTO stim_mth_reported
        (object_id,
         daytime,
         status,
         period_ref_item,
         calc_method,
         comments,
         created_by,
         created_date
        )
        SELECT
         object_id,
         daytime,
         status,
         period_ref_item,
         calc_method,
         comments,
         'SYSTEM',
         Ecdp_Timestamp.getCurrentSysdate
        FROM stim_mth_value x
        WHERE created_date > p_last_run_time
         AND daytime = p_daytime
         AND NOT EXISTS (SELECT 'x' FROM stim_mth_reported
                  WHERE object_id = x.object_id
                    AND daytime = x.daytime) ;

        FOR StrmItmCur IN c_siv LOOP

         lr_prev_reported := ec_stim_mth_reported.row_by_pk(StrmItmCur.object_id, Add_Months(StrmItmCur.daytime,-1),'=');
         lr_prev_value := ec_stim_mth_value.row_by_pk(StrmItmCur.object_id, Add_Months(StrmItmCur.daytime,-1), '=');
         lr_this_value := StrmItmCur;

         lr_net_sub_uom.net_energy_jo :=
              GetSubGroupValue(lr_this_value, 'E', 'JO')
            + NVL(GetSubGroupValue(lr_prev_value, 'E', 'JO'),0)
            -  NVL(lr_prev_reported.net_energy_jo,0);


         lr_net_sub_uom.net_energy_th :=
              GetSubGroupValue(lr_this_value, 'E', 'TH')
            + NVL(GetSubGroupValue(lr_prev_value, 'E', 'TH'),0)
            -  NVL(lr_prev_reported.net_energy_th,0);

         lr_net_sub_uom.net_energy_wh :=
              GetSubGroupValue(lr_this_value, 'E', 'WH')
            + NVL(GetSubGroupValue(lr_prev_value, 'E', 'WH'),0)
            -  NVL(lr_prev_reported.net_energy_wh,0);

         lr_net_sub_uom.net_energy_be :=
              GetSubGroupValue(lr_this_value, 'E', 'BE')
            + NVL(GetSubGroupValue(lr_prev_value, 'E', 'BE'),0)
            -  NVL(lr_prev_reported.net_energy_be,0);


         lr_net_sub_uom.net_mass_ma :=
              GetSubGroupValue(lr_this_value, 'M', 'MA')
            + NVL(GetSubGroupValue(lr_prev_value, 'M', 'MA'),0)
            -  NVL(lr_prev_reported.net_mass_ma,0);

         lr_net_sub_uom.net_mass_mv :=
              GetSubGroupValue(lr_this_value, 'M', 'MV')
            + NVL(GetSubGroupValue(lr_prev_value, 'M', 'MV'),0)
            -  NVL(lr_prev_reported.net_mass_mv,0);

         lr_net_sub_uom.net_mass_ua :=
              GetSubGroupValue(lr_this_value, 'M', 'UA')
            + NVL(GetSubGroupValue(lr_prev_value, 'M', 'UA'),0)
            -  NVL(lr_prev_reported.net_mass_ua,0);

         lr_net_sub_uom.net_mass_uv :=
              GetSubGroupValue(lr_this_value, 'M', 'UV')
            + NVL(GetSubGroupValue(lr_prev_value, 'M', 'UV'),0)
            -  NVL(lr_prev_reported.net_mass_uv,0);

         lr_net_sub_uom.net_volume_bi :=
              GetSubGroupValue(lr_this_value, 'V', 'BI')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'BI'),0)
            -  NVL(lr_prev_reported.net_volume_bi,0);

         lr_net_sub_uom.net_volume_bm :=
              GetSubGroupValue(lr_this_value, 'V', 'BM')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'BM'),0)
            -  NVL(lr_prev_reported.net_volume_bm,0);

         lr_net_sub_uom.net_volume_sf :=
              GetSubGroupValue(lr_this_value, 'V', 'SF')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'SF'),0)
            -  NVL(lr_prev_reported.net_volume_sf,0);

         lr_net_sub_uom.net_volume_nm :=
              GetSubGroupValue(lr_this_value, 'V', 'NM')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'NM'),0)
            -  NVL(lr_prev_reported.net_volume_nm,0);

         lr_net_sub_uom.net_volume_sm :=
              GetSubGroupValue(lr_this_value, 'V', 'SM')
            + NVL(GetSubGroupValue(lr_prev_value, 'V', 'SM'),0)
            -  NVL(lr_prev_reported.net_volume_sm,0);

         -- now update table
         UPDATE stim_mth_reported
           SET NET_ENERGY_JO         = lr_net_sub_uom.NET_ENERGY_JO
              ,NET_ENERGY_TH         = lr_net_sub_uom.NET_ENERGY_TH
              ,NET_ENERGY_WH         = lr_net_sub_uom.NET_ENERGY_WH
              ,NET_ENERGY_BE         = lr_net_sub_uom.NET_ENERGY_BE
              ,NET_MASS_MA           = lr_net_sub_uom.NET_MASS_MA
              ,NET_MASS_MV           = lr_net_sub_uom.NET_MASS_MV
              ,NET_MASS_UA           = lr_net_sub_uom.NET_MASS_UA
              ,NET_MASS_UV           = lr_net_sub_uom.NET_MASS_UV
              ,NET_VOLUME_BI         = lr_net_sub_uom.NET_VOLUME_BI
              ,NET_VOLUME_BM         = lr_net_sub_uom.NET_VOLUME_BM
              ,NET_VOLUME_SF         = lr_net_sub_uom.NET_VOLUME_SF
              ,NET_VOLUME_NM         = lr_net_sub_uom.NET_VOLUME_NM
              ,NET_VOLUME_SM         = lr_net_sub_uom.NET_VOLUME_SM
              ,last_updated_by = 'SYSTEM'
         WHERE object_id = StrmItmCur.object_id
           AND daytime = StrmItmCur.daytime;

     END LOOP;

END GenMthAsReportedStaticData;


PROCEDURE GenMthAsIsStaticData(
   p_daytime             DATE,
   p_last_run_time       DATE
)

IS

CURSOR c_siv IS
SELECT *
FROM stim_mth_value
WHERE last_updated_date >= p_last_run_time
  AND daytime = p_daytime;

lr_net_sub_uom t_net_sub_uom;
lr_this_value stim_mth_value%ROWTYPE;

BEGIN

        -- create empty records
        INSERT INTO stim_mth_actual
        (object_id,
         daytime,
         status,
         period_ref_item,
         calc_method,
         comments,
         created_by,
         created_date
        )
        SELECT
         object_id,
         daytime,
         status,
         period_ref_item,
         calc_method,
         comments,
         'SYSTEM',
         Ecdp_Timestamp.getCurrentSysdate
        FROM stim_mth_value x
        WHERE created_date > p_last_run_time
         AND daytime = p_daytime
         AND NOT EXISTS (SELECT 'x' FROM stim_mth_actual
                  WHERE object_id = x.object_id
                    AND daytime = x.daytime) ;



        FOR StrmItmCur IN c_siv LOOP

         lr_this_value := StrmItmCur;

         lr_net_sub_uom.net_energy_jo :=
              GetSubGroupValue(lr_this_value, 'E', 'JO');

         lr_net_sub_uom.net_energy_th :=
              GetSubGroupValue(lr_this_value, 'E', 'TH');

         lr_net_sub_uom.net_energy_wh :=
              GetSubGroupValue(lr_this_value, 'E', 'WH');

         lr_net_sub_uom.net_energy_be :=
              GetSubGroupValue(lr_this_value, 'E', 'BE');


         lr_net_sub_uom.net_mass_ma :=
              GetSubGroupValue(lr_this_value, 'M', 'MA');

         lr_net_sub_uom.net_mass_mv :=
              GetSubGroupValue(lr_this_value, 'M', 'MV');

         lr_net_sub_uom.net_mass_ua :=
              GetSubGroupValue(lr_this_value, 'M', 'UA');

         lr_net_sub_uom.net_mass_uv :=
              GetSubGroupValue(lr_this_value, 'M', 'UV');

         lr_net_sub_uom.net_volume_bi :=
              GetSubGroupValue(lr_this_value, 'V', 'BI');

         lr_net_sub_uom.net_volume_bm :=
              GetSubGroupValue(lr_this_value, 'V', 'BM');


         lr_net_sub_uom.net_volume_sf :=
              GetSubGroupValue(lr_this_value, 'V', 'SF');

         lr_net_sub_uom.net_volume_nm :=
              GetSubGroupValue(lr_this_value, 'V', 'NM');

         lr_net_sub_uom.net_volume_sm :=
              GetSubGroupValue(lr_this_value, 'V', 'SM');

         -- now update table
         UPDATE stim_mth_actual
           SET NET_ENERGY_JO         = lr_net_sub_uom.NET_ENERGY_JO
              ,NET_ENERGY_TH         = lr_net_sub_uom.NET_ENERGY_TH
              ,NET_ENERGY_WH         = lr_net_sub_uom.NET_ENERGY_WH
              ,NET_ENERGY_BE         = lr_net_sub_uom.NET_ENERGY_BE
              ,NET_MASS_MA           = lr_net_sub_uom.NET_MASS_MA
              ,NET_MASS_MV           = lr_net_sub_uom.NET_MASS_MV
              ,NET_MASS_UA           = lr_net_sub_uom.NET_MASS_UA
              ,NET_MASS_UV           = lr_net_sub_uom.NET_MASS_UV
              ,NET_VOLUME_BI         = lr_net_sub_uom.NET_VOLUME_BI
              ,NET_VOLUME_BM         = lr_net_sub_uom.NET_VOLUME_BM
              ,NET_VOLUME_SF         = lr_net_sub_uom.NET_VOLUME_SF
              ,NET_VOLUME_NM         = lr_net_sub_uom.NET_VOLUME_NM
              ,NET_VOLUME_SM         = lr_net_sub_uom.NET_VOLUME_SM
              ,last_updated_by = 'SYSTEM'
              ,last_updated_date = StrmItmCur.last_updated_date
         WHERE object_id = StrmItmCur.object_id
           AND daytime = StrmItmCur.daytime;

     END LOOP;

END GenMthAsIsStaticData;
/*
PROCEDURE GenMthStaticData

IS

CURSOR c_last_run IS
SELECT daytime, closed_book_date, closed_report_date
FROM  system_mth_status x
WHERE EXISTS (SELECT 'x'
              FROM stim_mth_value
              WHERE daytime = x.daytime
                AND last_updated_date > x.gen_static_date);

ld_run_time DATE := Ecdp_Timestamp.getCurrentSysdate; -- set this as last run

BEGIN

   FOR LastRunCur IN c_last_run LOOP

       -- generate any as is changes for period
       GenMthAsIsStaticData(p_system_id, LastRunCur.daytime, LastRunCur.gen_static_date);

       -- generate any as booked - if not closed for period
       IF LastRunCur.closed_book_date IS NULL THEN

          GenMthAsBookedStaticData(p_system_id, LastRunCur.daytime, LastRunCur.gen_static_date);

       END IF;

       -- generate any as reported - if not closed for period
       IF LastRunCur.closed_report_date IS NULL THEN

          GenMthAsReportedStaticData(p_system_id, LastRunCur.daytime, LastRunCur.gen_static_date);

       END IF;

       UPDATE system_mth_status
          SET gen_static_date = ld_run_time,
          last_updated_by = 'SYSTEM'
        WHERE object_id = p_system_id
          AND daytime = LastRunCur.daytime;
   END LOOP;

   -- perform transaction management within procedure in this case (job to run from scheduler)
   -- COMMIT WORK;

END GenMthStaticData;
*/

PROCEDURE UpdateSplitKeyMth(
   p_object_id       VARCHAR2, -- Split_Key_Id
   p_daytime          DATE

)
IS
/*
CURSOR c_splitkeyitems IS
SELECT to_object_id id
FROM objects_relation
WHERE from_object_id = p_object_id
  AND role_name = 'SPLIT_KEY'
  AND to_class_name = 'STREAM_ITEM'
  AND p_daytime <= Nvl(end_date,p_daytime+1)
  AND p_daytime >= Nvl(start_date,p_daytime-1);
*/

BEGIN

  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');

/*
  FOR SplitKeyItems IN c_splitkeyitems LOOP

        UPDATE stim_mth_value
           SET SPLIT_SHARE = GetSplitShareMth(object_id,daytime)
                ,last_updated_by = 'INSTANTIATE'
        WHERE object_id = SplitKeyItems.id
          AND daytime >= Trunc(p_daytime,'MM')
          AND calc_method = 'SK'
          AND last_updated_by = 'INSTANTIATE';

     END LOOP;
*/
END UpdateSplitKeyMth;

PROCEDURE UpdateSplitKeyDay(
   p_object_id        VARCHAR2,
   p_daytime          DATE
)

IS
/*
CURSOR c_splitkeyitems IS
SELECT to_object_id id, end_date
FROM objects_relation
WHERE from_object_id = p_object_id
  AND role_name = 'SPLIT_KEY'
  AND to_class_name = 'STREAM_ITEM'
  AND p_daytime <= Nvl(end_date,p_daytime+1)
  AND p_daytime >= Nvl(start_date,p_daytime-1);
*/

BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');

/*
  FOR SplitKeyItems IN c_splitkeyitems LOOP
        UPDATE stim_day_value
           SET SPLIT_SHARE = GetSplitShareDay(object_id,daytime)
                ,last_updated_by = 'INSTANTIATE'
        WHERE object_id = SplitKeyItems.id
          and daytime >= p_daytime
          AND calc_method = 'SK'
          AND last_updated_by = 'INSTANTIATE';

  END LOOP;
*/
END UpdateSplitKeyDay;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure       :
-- Description    :
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
-- Using tables   :
-- Using functions:
-- Configuration                                                                                   --
-- required       :                                                                                --
-- Behaviour      :                                                                                --
-----------------------------------------------------------------------------------------------------
PROCEDURE UpdateSplitKey(p_object_id             VARCHAR2,
                         p_business_function_url VARCHAR2,
                         p_daytime               DATE,
                         p_user_id               VARCHAR2,
                         p_stim_pending_no       NUMBER DEFAULT NULL,
                         p_stream_item_id        VARCHAR2 DEFAULT NULL)
--</EC-DOC>
IS


ld_daytime DATE;
lv2_business_function business_function.name%TYPE;
ln_stim_day_pend_no NUMBER;
ln_stim_mth_pend_no NUMBER;
ln_stim_fcst_mth_pend_no NUMBER;
lv2_description VARCHAR2(2000);
lv2_sysprop_runmode VARCHAR2(32);
lv2_period VARCHAR2(32);

CURSOR c_stream_items(cp_split_key_id VARCHAR2, cp_object_id VARCHAR2, cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_enddate DATE) IS
-- Start before/on - end inside/outside
 SELECT siv.object_id id,
        siv.daytime daytime,
        least(nvl(cp_enddate, date '9999-01-01'),
              nvl(siv.end_date, date '9999-01-01')) enddate
   FROM stream_item si, stream_item_version siv
  WHERE si.object_id = siv.object_id
    AND cp_object_id IN
        (siv.split_company_id, siv.split_field_id, siv.split_product_id, siv.split_item_other_id)
    AND siv.split_key_id = cp_split_key_id
    AND cp_daytime <= siv.daytime
    AND nvl(cp_enddate, siv.daytime + 1) > siv.daytime
    AND si.object_id = nvl(cp_stream_item_id, si.object_id)
 UNION
 -- Start inside - end inside/outside
 SELECT siv.object_id id,
        greatest(siv.daytime, cp_daytime) daytime,
        least(nvl(cp_enddate, date '9999-01-01'),
              nvl(siv.end_date, date '9999-01-01')) enddate
   FROM stream_item si, stream_item_version siv
  WHERE si.object_id = siv.object_id
    AND cp_object_id IN
        (siv.split_company_id, siv.split_field_id, siv.split_product_id, siv.split_item_other_id)
    AND siv.split_key_id = cp_split_key_id
    AND cp_daytime >= siv.daytime
    AND nvl(cp_enddate, siv.daytime + 1) > siv.daytime
    AND si.object_id = nvl(cp_stream_item_id, si.object_id);




CURSOR c_splitkeyitems(cp_split_id VARCHAR2, cp_daytime DATE) IS
SELECT split_member_id id,
       (select min(daytime)
          from split_key_setup
         where daytime > sks.daytime
           and object_id = sks.object_id
           and split_member_id = sks.split_member_id) enddate
  FROM split_key_setup sks
 WHERE object_id = cp_split_id
   AND sks.daytime = decode(p_stream_item_id, -- If stream item id is provided, the daytime of the share is not applicable
                            null, -- i.e. we want to run for all share versions for the given stream item
                            (select max(daytime)
                               from split_key_setup
                              where object_id = sks.object_id
                                and split_member_id = sks.split_member_id
                                and daytime <= cp_daytime),
                            sks.daytime);



CURSOR c_stim_mth_value (cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_enddate DATE, cp_period VARCHAR2) IS
SELECT object_id, daytime
  FROM stim_mth_value
 WHERE object_id = cp_stream_item_id
   AND daytime >= cp_daytime
   AND daytime < nvl(cp_enddate, daytime + 1)
   AND NVL(calc_method,
           ec_stream_item_version.calc_method(object_id, daytime, '<=')) = 'SK'
   AND nvl(cp_period, 'MONTHLY') = 'MONTHLY';

CURSOR c_stim_day_value (cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_enddate DATE, cp_period VARCHAR2) IS
SELECT object_id, daytime
  FROM stim_day_value
 WHERE object_id = cp_stream_item_id
   AND daytime >= cp_daytime
   AND daytime < nvl(cp_enddate, daytime + 1)
   AND NVL(calc_method,
           ec_stream_item_version.calc_method(object_id, daytime, '<=')) = 'SK'
   AND nvl(cp_period, 'DAILY') = 'DAILY';


-- See if changed SK is in use in forecast
CURSOR c_fcst(cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_end_date DATE, cp_period VARCHAR2) IS
SELECT DISTINCT sfmv.forecast_id, sfmv.daytime
  FROM stim_fcst_mth_value sfmv
 WHERE sfmv.object_id = cp_stream_item_id
   AND NVL(sfmv.calc_method,
           ecdp_revn_forecast.getStreamItemAttribute(sfmv.forecast_id,
                                                     sfmv.object_id,
                                                     sfmv.daytime,
                                                     'CALC_METHOD')) = 'SK'
   AND sfmv.daytime >= cp_daytime
   AND sfmv.daytime < NVL(cp_end_date, sfmv.daytime + 1)
   AND nvl(cp_period, 'MONTHLY') = 'MONTHLY'
   AND sfmv.forecast_id NOT IN
       (SELECT fms.object_id
          FROM fcst_mth_status fms
         WHERE fms.record_status IN ('V','A'));


CURSOR c_bf IS
SELECT bf.name
  FROM business_function bf
 where bf.url = p_business_function_url;

CURSOR c_exists IS
SELECT sp.stim_pending_no
  FROM stim_pending sp
 WHERE sp.stim_pending_no = p_stim_pending_no;




lv2_class_name VARCHAR2(200);
lv2_object_id VARCHAR2(32);
lv2_parent_stream_item_id VARCHAR2(32);
ln_old_share NUMBER;
ln_new_share NUMBER;

BEGIN

lv2_sysprop_runmode := nvl(ec_ctrl_system_attribute.attribute_text(p_daytime,'CASCADE_SK_SHARE_CHANGE','<='),'NA');



/* Avoiding all the loops if nothing is supposed to be done here */
IF lv2_sysprop_runmode = 'NONE' THEN
   RETURN;
END IF;



  IF instr(p_business_function_url,'MONTHLY') > 0 THEN
     lv2_period := 'MONTHLY';
  ELSIF instr(p_business_function_url,'DAILY') > 0 THEN
        lv2_period := 'DAILY';
  END IF;

FOR c_e IN c_exists LOOP
    ln_stim_day_pend_no := c_e.stim_pending_no;
    ln_stim_mth_pend_no := c_e.stim_pending_no;
    ln_stim_fcst_mth_pend_no := c_e.stim_pending_no;
END LOOP;


-- Preparing business function name
FOR cbf IN c_bf LOOP
    lv2_business_function := cbf.name;
END LOOP;

IF lv2_business_function IS NULL THEN
   lv2_business_function := 'N/A';
END IF;


  FOR SplitKeyItems IN c_splitkeyitems(p_object_id,p_daytime) LOOP


      FOR StreamItems IN c_stream_items(p_object_id, SplitKeyItems.id,p_stream_item_id,p_daytime, SplitKeyItems.enddate) LOOP

          -- Monthly update
          -- If the new split share is applied in the middle of the month, then this month is not applicable for split share update.
          IF (StreamItems.daytime > Trunc(StreamItems.daytime, 'MM')) THEN
              ld_daytime := add_months(Trunc(StreamItems.daytime, 'MM'),1);
          ELSE
              ld_daytime := StreamItems.daytime;
          END IF;



          FOR stimMthRec IN c_stim_mth_value(StreamItems.id,ld_daytime,StreamItems.enddate,lv2_period) LOOP

              IF lv2_sysprop_runmode <> 'NONE' THEN

                IF ln_stim_mth_pend_no IS NULL THEN

                   lv2_description := 'Split key change: '||EcDp_ClassMeta_Cnfg.getLabel(ecdp_objects.GetObjClassName(SplitKeyItems.id)) ||' split key ' || ec_split_key_version.name(p_object_id,stimMthRec.daytime,'<=');

                    INSERT INTO stim_pending
                      (stim_pending_no, period, bf_reference, description, created_by)
                    VALUES
                      (p_stim_pending_no,'MTH', lv2_business_function, lv2_description, p_user_id)
                    RETURNING stim_pending_no INTO ln_stim_mth_pend_no;

                END IF;

                -- Writing the source stream item
                     lv2_parent_stream_item_id := NULL;

                      SELECT fo.stream_item_id
                        INTO lv2_parent_stream_item_id
                        FROM stream_item_formula fo
                       WHERE fo.object_id = stimMthRec.object_id
                         AND fo.daytime =
                             (SELECT MAX(daytime)
                                FROM stream_item_version siv
                               WHERE siv.object_id = fo.object_id
                                 AND siv.daytime <= stimMthRec.daytime
                                 AND nvl(siv.end_date, stimMthRec.daytime + 1) > stimMthRec.daytime);

                  BEGIN

                      INSERT INTO stim_pending_item
                        (object_id,
                         daytime,
                         stim_pending_no,
                         period,
                         status_code,
                         created_by)
                      VALUES
                        (lv2_parent_stream_item_id,--stimMthRec.object_id,
                         stimMthRec.daytime,
                         ln_stim_mth_pend_no,
                         'MTH',
                         'READY',
                         p_user_id);

                         EXCEPTION
                      --Do nothing when recored exists
                      WHEN DUP_VAL_ON_INDEX THEN
                           NULL;

               END;
                 END IF;
          END LOOP;


          -- Daily update
          FOR stimDayRec IN c_stim_day_value(StreamItems.id,p_daytime,SplitKeyItems.enddate,lv2_period) LOOP

               IF lv2_sysprop_runmode <> 'NONE' THEN
                   IF ln_stim_day_pend_no IS NULL THEN

                     lv2_description := 'Split key change: '||EcDp_ClassMeta_Cnfg.getLabel(ecdp_objects.GetObjClassName(SplitKeyItems.id)) ||' split key ' || ec_split_key_version.name(p_object_id,stimDayRec.daytime,'<=');

                      INSERT INTO stim_pending
                        (stim_pending_no,period, bf_reference, description, created_by)
                      VALUES
                        (p_stim_pending_no,'DAY', lv2_business_function, lv2_description, p_user_id)
                      RETURNING stim_pending_no INTO ln_stim_day_pend_no;

                  END IF;

                       -- Writing the source stream item
                       lv2_parent_stream_item_id := NULL;

                      SELECT sif.stream_item_id
                        INTO lv2_parent_stream_item_id
                        FROM stream_item_formula sif
                       WHERE sif.object_id = stimDayRec.object_id
                         AND sif.daytime =
                             (select MAX(daytime)
                                from stream_item_version siv
                               WHERE siv.object_id = sif.object_id
                                 AND siv.daytime <= stimDayRec.daytime
                                 AND nvl(siv.end_date,
                                         stimDayRec.daytime + 1) >
                                     stimDayRec.daytime);

                       BEGIN

                                INSERT INTO stim_pending_item
                                  (object_id,
                                   daytime,
                                   stim_pending_no,
                                   period,
                                   status_code,
                                   created_by)
                                VALUES
                                  (lv2_parent_stream_item_id,
                                   stimDayRec.daytime,
                                   ln_stim_day_pend_no,
                                   'DAY',
                                   'READY',
                                   p_user_id);

                                   EXCEPTION
                              --Do nothing when recored exists
                              WHEN DUP_VAL_ON_INDEX THEN
                                   NULL;

                        END;


                 END IF;


          END LOOP;


          -- Forecast update
          FOR rsFcst IN c_fcst(StreamItems.id,p_daytime,SplitKeyItems.enddate,lv2_period) LOOP

            IF lv2_sysprop_runmode <> 'NONE' THEN
               IF ln_stim_fcst_mth_pend_no IS NULL THEN

                 lv2_description := 'Split key change: '||EcDp_ClassMeta_Cnfg.getLabel(ecdp_objects.GetObjClassName(SplitKeyItems.id)) ||' split key ' || ec_split_key_version.name(p_object_id,rsFcst.daytime,'<=');


                  INSERT INTO stim_pending
                    (stim_pending_no,period, bf_reference, description, created_by)
                  VALUES
                    (p_stim_pending_no,'FCST_MTH', lv2_business_function, lv2_description, p_user_id)
                  RETURNING stim_pending_no INTO ln_stim_fcst_mth_pend_no;

              END IF;
                       -- Writing the source stream item
                       lv2_parent_stream_item_id := ecdp_revn_forecast.getstreamitemattribute(rsFcst.Forecast_Id,StreamItems.id,rsFcst.daytime,'STREAM_ITEM_FORMULA');
                       lv2_parent_stream_item_id := ec_stream_item.object_id_by_uk(lv2_parent_stream_item_id);

                   BEGIN

                      INSERT INTO stim_pending_item
                        (object_id,
                         daytime,
                         stim_pending_no,
                         period,
                         forecast_id,
                         status_code,
                         created_by)
                      VALUES
                        (lv2_parent_stream_item_id,
                         rsFcst.daytime,
                         ln_stim_fcst_mth_pend_no,
                         'FCST_MTH',
                         rsFcst.Forecast_Id,
                         'READY',
                         p_user_id);


                         EXCEPTION
                        --Do nothing when recored exists
                        WHEN DUP_VAL_ON_INDEX THEN
                             NULL;

                  END;

           END IF;

          END LOOP;

      END LOOP;
  END LOOP;
END UpdateSplitKey;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : UpdateConversionFactor
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE UpdateConversionFactor(p_object_id             VARCHAR2,
                                 p_business_function_url VARCHAR2,
                                 p_daytime               VARCHAR2,
                                 p_end_date              VARCHAR2,
                                 p_user                  VARCHAR2,
                                 p_stim_pending_no       NUMBER DEFAULT NULL)

IS

ltab_object_ids EcDp_STIM_Util.t_elem := EcDp_STIM_Util.t_elem();
ltab_start_date EcDp_STIM_Util.t_elem := EcDp_STIM_Util.t_elem();
ltab_end_date EcDp_STIM_Util.t_elem := EcDp_STIM_Util.t_elem();

lv2_class VARCHAR2(200);
lv2_object_id VARCHAR2(32);

ld_daytime DATE := NULL;
ld_end_date DATE := NULL;
lv2_business_function business_function.name%TYPE;
ln_stim_day_pend_no NUMBER;
ln_stim_mth_pend_no NUMBER;
ln_stim_fcst_mth_pend_no NUMBER;
lv2_description VARCHAR2(2000);
lv2_sysprop_runmode VARCHAR2(32);

-- Loop through all valid versions
CURSOR c_factors(cp_object_id VARCHAR2, cd_daytime DATE, cd_end_date DATE) IS
SELECT pnv.daytime,
       pnv.end_date,
       pn.product_id
  FROM product_node_version pnv, product_node pn
 WHERE pnv.object_id = cp_object_id
   AND pn.object_id = pnv.object_id
   AND pnv.daytime >= cd_daytime
   AND pnv.daytime <  nvl(cd_end_date,pnv.daytime+1)
   AND nvl(pnv.end_date,pnv.daytime) <= nvl(cd_end_date,nvl(pnv.end_date,pnv.daytime)+1)
   AND pn.conversion_type = 'DENSITY_GCV_MCV'
UNION
SELECT pfv.daytime,
       pfv.end_date,
       pf.product_id -- Field Level
   FROM product_field_version pfv, product_field pf
 WHERE pfv.object_id = cp_object_id
   AND pfv.object_id = pf.object_id
   AND pfv.daytime >= cd_daytime
   AND pfv.daytime <  nvl(cd_end_date,pfv.daytime+1)
   AND nvl(pfv.end_date,pfv.daytime) <= nvl(cd_end_date,nvl(pfv.end_date,pfv.daytime)+1)
   AND pf.conversion_type = 'DENSITY_GCV_MCV'
UNION
SELECT pcv.daytime,
       pcv.end_date,
       pc.product_id -- Country Level
    FROM product_country_version pcv, product_country pc
 WHERE pcv.object_id = cp_object_id
   AND pcv.object_id = pc.object_id
   AND pcv.daytime >= cd_daytime
   AND pcv.daytime <  nvl(cd_end_date,pcv.daytime+1)
   AND nvl(pcv.end_date,pcv.daytime) <= nvl(cd_end_date,nvl(pcv.end_date,pcv.daytime)+1)
   AND pc.conversion_type = 'DENSITY_GCV_MCV';

CURSOR c_sdv(cp_product_id VARCHAR2, cp_cf_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS
  SELECT *
    FROM stim_day_value
   WHERE nvl(calc_method, 'NA') <> 'SP' -- Using NA because Calc method on object will never be OW/SP
   AND ec_stream_item_version.product_id(object_id, cp_daytime, '<=') = cp_product_id
     AND (density_source_id = cp_cf_id OR gcv_source_id = cp_cf_id OR
          mcv_source_id = cp_cf_id)
     AND daytime >= cp_daytime
     AND daytime < nvl(cp_end_date, daytime + 1);

CURSOR c_smv(cp_product_id VARCHAR2, cp_cf_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS
  SELECT *
    FROM stim_mth_value
   WHERE nvl(calc_method, 'NA') <> 'SP' -- Using NA because Calc method on object will never be OW/SP
   AND ec_stream_item_version.product_id(object_id, cp_daytime, '<=') = cp_product_id
     AND (density_source_id = cp_cf_id OR gcv_source_id = cp_cf_id OR
          mcv_source_id = cp_cf_id)
     AND daytime >= cp_daytime
     AND daytime < nvl(cp_end_date, daytime + 1);

-- See if changed CF is in use in forecast
CURSOR c_fcst(cp_product_id VARCHAR2, cp_cf_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS
SELECT sfmv.object_id, sfmv.forecast_id, sfmv.daytime
  FROM stim_fcst_mth_value sfmv
 WHERE ec_stream_item_version.product_id(sfmv.object_id, sfmv.daytime, '<=') =
       cp_product_id
   AND (sfmv.density_source_id = cp_cf_id OR sfmv.gcv_source_id = cp_cf_id OR
        sfmv.mcv_source_id = cp_cf_id)
   AND sfmv.daytime >= cp_daytime
   AND sfmv.daytime < NVL(cp_end_date, sfmv.daytime + 1)
   AND sfmv.forecast_id NOT IN
       (SELECT fms.object_id
          FROM fcst_mth_status fms
         WHERE fms.record_status IN ('V', 'A'));


CURSOR c_bf IS
SELECT bf.name
  FROM business_function bf
 WHERE bf.url = p_business_function_url;

BEGIN

  -- Preparing business function name
  FOR cbf IN c_bf LOOP
      lv2_business_function := cbf.name;
  END LOOP;

  IF lv2_business_function IS NULL THEN
     lv2_business_function := 'N/A';
  END IF;


   IF (INSTR(p_object_id, ';') = 0) THEN -- Normal operation not a list
       IF (p_daytime IS NULL OR UPPER(p_daytime) = 'NULL') THEN
          ld_daytime := NULL;
       ELSE
          ld_daytime := to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');
       END IF;

       IF (p_end_date IS NULL OR UPPER(p_end_date) = 'NULL') THEN
          ld_end_date := NULL;
       ELSE
        BEGIN
              ld_end_date := to_date(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS');
        EXCEPTION
            WHEN OTHERS THEN
              ld_end_date := NULL;
        END;

       END IF;

       IF (UPPER(p_object_id) = 'NULL') THEN
          lv2_object_id := NULL;
       ELSE
          lv2_object_id := p_object_id;
       END IF;

       lv2_class := EcDp_Objects.GetObjClassName(p_object_id);

       IF (lv2_class IS NULL) THEN
             RETURN;
       END IF;
    END IF;

    ltab_object_ids := EcDp_STIM_Util.splitString(p_object_id, ';');
    ltab_start_date := EcDp_STIM_Util.splitString(p_daytime, ';');
    ltab_end_date := EcDp_STIM_Util.splitString(p_end_date, ';');

    <<inputlist>>
    FOR i IN 1..ltab_object_ids.count LOOP

        ld_daytime := to_date(ltab_start_date(i), 'YYYY-MM-DD"T"HH24:MI:SS');

        -- Getting system attribute for how to handle conversion factor changes
        lv2_sysprop_runmode := nvl(ec_ctrl_system_attribute.attribute_text(ld_daytime,'CASCADE_CONV_FACT_CHANGE','<='),'AUTO');

        EXIT inputlist WHEN lv2_sysprop_runmode = 'NONE';

        BEGIN
            ld_end_date := to_date(ltab_end_date(i), 'YYYY-MM-DD"T"HH24:MI:SS');
        EXCEPTION
            WHEN OTHERS THEN
                ld_end_date := NULL;
        END;

        FOR CurFactors IN c_factors( ltab_object_ids(i), ld_daytime, ld_end_date ) LOOP

             -- Insert Cascade basis for conversion factor adjustment on daily values
             FOR rsD IN c_sdv(CurFactors.Product_Id, ltab_object_ids(i), CurFactors.daytime, CurFactors.end_date) LOOP

             IF lv2_sysprop_runmode <> 'NONE' THEN
                 IF ln_stim_day_pend_no IS NULL THEN

                    lv2_description := 'Conversion factor change: ' ||
                                       EcDp_ClassMeta_Cnfg.getLabel(ecdp_objects.GetObjClassName(ltab_object_ids(i))) ||
                                       ' '||
                                       ecdp_objects.GetObjName(ltab_object_ids(i),CurFactors.daytime) ||
                                       ' / Product ' ||
                                       ec_product_version.name(CurFactors.Product_Id,CurFactors.daytime,'<=');


                      INSERT INTO stim_pending
                        (stim_pending_no,period, bf_reference, description, created_by)
                      VALUES
                        (p_stim_pending_no,'DAY', lv2_business_function, lv2_description, p_user)
                      RETURNING stim_pending_no INTO ln_stim_day_pend_no;
                END IF;

                INSERT INTO stim_pending_item
                  (object_id,
                   daytime,
                   stim_pending_no,
                   period,
                   status_code,
                   created_by)
                VALUES
                  (rsD.Object_Id,
                   rsD.Daytime,
                   ln_stim_day_pend_no,
                   'DAY',
                   'READY',
                   p_user);
             END IF;

             END LOOP;



             -- Insert Cascade basis for conversion factor adjustment on monthly values

             FOR rsM IN c_smv(CurFactors.Product_Id, ltab_object_ids(i), CurFactors.daytime, CurFactors.end_date) LOOP

                IF lv2_sysprop_runmode <> 'NONE' THEN
                     IF ln_stim_mth_pend_no IS NULL THEN

                        lv2_description := 'Conversion factor change: ' ||
                                      EcDp_ClassMeta_Cnfg.getLabel(ecdp_objects.GetObjClassName(ltab_object_ids(i))) ||
                                      ' '||
                                      ecdp_objects.GetObjName(ltab_object_ids(i),CurFactors.daytime) ||
                                      ' / Product ' ||
                                      ec_product_version.name(CurFactors.Product_Id,CurFactors.daytime,'<=');

                        INSERT INTO stim_pending
                          (stim_pending_no,period, bf_reference, description, created_by)
                        VALUES
                          (p_stim_pending_no,'MTH', lv2_business_function, lv2_description, p_user)
                        RETURNING stim_pending_no INTO ln_stim_mth_pend_no;
                  END IF;

                    INSERT INTO stim_pending_item
                      (object_id,
                       daytime,
                       stim_pending_no,
                       period,
                       status_code,
                       created_by)
                    VALUES
                      (rsM.Object_Id,
                       rsM.Daytime,
                       ln_stim_mth_pend_no,
                       'MTH',
                       'READY',
                       p_user);

                 END IF;
             END LOOP;


             -- Insert Cascade basis for conversion factor adjustment on monthly values
             FOR rsF IN c_fcst(CurFactors.Product_Id, ltab_object_ids(i), CurFactors.daytime, CurFactors.end_date) LOOP


                  IF lv2_sysprop_runmode <> 'NONE' THEN
                   IF ln_stim_fcst_mth_pend_no IS NULL THEN

                      lv2_description := 'Conversion factor change: ' ||
                                         EcDp_ClassMeta_Cnfg.getLabel(ecdp_objects.GetObjClassName(ltab_object_ids(i))) ||
                                         ' '||
                                         ecdp_objects.GetObjName(ltab_object_ids(i),CurFactors.daytime) ||
                                         ' / Product ' ||
                                         ec_product_version.name(CurFactors.Product_Id,CurFactors.daytime,'<=');


                        INSERT INTO stim_pending
                          (stim_pending_no,period, bf_reference, description, created_by)
                        VALUES
                          (p_stim_pending_no,
                           'FCST_MTH',
                           lv2_business_function,
                           lv2_description,
                           p_user)
                        RETURNING stim_pending_no INTO ln_stim_fcst_mth_pend_no;

                  END IF;

                    INSERT INTO stim_pending_item
                      (object_id,
                       daytime,
                       stim_pending_no,
                       period,
                       forecast_id,
                       status_code,
                       created_by)
                    VALUES
                      (rsF.Object_Id,
                       rsF.Daytime,
                       ln_stim_fcst_mth_pend_no,
                       'FCST_MTH',
                       rsF.Forecast_Id,
                       'READY',
                       p_user);

                  END IF;
             END LOOP;

        END LOOP; -- CurFactors
    END LOOP; -- ltab_object_ids


END UpdateConversionFactor;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : UpdateBOEConversionFactor
-- Description    :
-- Preconditions  :
-- Postconditions :
-- Using tables   :
-- Using functions:
-- Configuration
-- required       :
-- Behaviour      :
---------------------------------------------------------------------------------------------------
PROCEDURE UpdateBOEConversionFactor(p_object_id             VARCHAR2,
                                    p_business_function_url VARCHAR2,
                                    p_daytime               VARCHAR2,
                                    p_end_date              VARCHAR2,
                                    p_user                  VARCHAR2,
                                    p_stim_pending_no       NUMBER DEFAULT NULL)

IS


lv2_class VARCHAR2(200);
lv2_object_id VARCHAR2(32);

ld_daytime DATE := NULL;
ld_end_date DATE := NULL;

l_stim_day_value stim_day_value%ROWTYPE;

lv2_business_function business_function.name%TYPE;
ln_stim_day_pend_no NUMBER;
ln_stim_mth_pend_no NUMBER;
ln_stim_fcst_mth_pend_no NUMBER;
lv2_description VARCHAR2(2000);
lv2_sysprop_runmode VARCHAR2(32);

-- Loop through all versions since we can not determine which version is updated from the application
CURSOR c_factors(cp_object_id VARCHAR2, cd_daytime DATE, cd_end_date DATE) IS
SELECT pnv.daytime,
       pnv.end_date,
       pn.product_id,
       pnv.boe_factor,
       pnv.boe_from_uom,
       pnv.boe_to_uom
  FROM product_node_version pnv, product_node pn
 WHERE pnv.object_id = cp_object_id
   AND pn.object_id = pnv.object_id
   AND pnv.daytime >= cd_daytime
   AND pnv.daytime <  nvl(cd_end_date,pnv.daytime+1)
   AND nvl(pnv.end_date,pnv.daytime) <= nvl(cd_end_date,nvl(pnv.end_date,pnv.daytime)+1)
   AND pn.conversion_type = 'BOE'
UNION
SELECT pfv.daytime,
       pfv.end_date,
       pf.product_id,
       pfv.boe_factor,
       pfv.boe_from_uom,
       pfv.boe_to_uom
  FROM product_field_version pfv, product_field pf
 WHERE pfv.object_id = cp_object_id
   AND pfv.object_id = pf.object_id
   AND pfv.daytime >= cd_daytime
   AND pfv.daytime <  nvl(cd_end_date,pfv.daytime+1)
   AND nvl(pfv.end_date,pfv.daytime) <= nvl(cd_end_date,nvl(pfv.end_date,pfv.daytime)+1)
   AND pf.conversion_type = 'BOE'
UNION
SELECT pcv.daytime,
       pcv.end_date,
       pc.product_id,
       pcv.boe_factor,
       pcv.boe_from_uom,
       pcv.boe_to_uom
  FROM product_country_version pcv, product_country pc
 WHERE pcv.object_id = cp_object_id
   AND pcv.object_id = pc.object_id
   AND pcv.daytime >= cd_daytime
   AND pcv.daytime <  nvl(cd_end_date,pcv.daytime+1)
   AND nvl(pcv.end_date,pcv.daytime) <= nvl(cd_end_date,nvl(pcv.end_date,pcv.daytime)+1)
   AND pc.conversion_type = 'BOE';

CURSOR c_sdv(cp_product_id VARCHAR2, cp_cf_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS
  SELECT *
    FROM stim_day_value
   WHERE nvl(calc_method, 'NA') <> 'SP' -- Using NA because Calc method on object will never be OW/SP
     AND ec_stream_item_version.product_id(object_id, cp_daytime, '<=') =
         cp_product_id
     AND boe_source_id = cp_cf_id
     AND daytime >= cp_daytime
     AND daytime < nvl(cp_end_date, daytime + 1);

CURSOR c_smv(cp_product_id VARCHAR2, cp_cf_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS
  SELECT *
    FROM stim_mth_value
   WHERE nvl(calc_method, 'NA') <> 'SP' -- Using NA because Calc method on object will never be OW/SP
     AND ec_stream_item_version.product_id(object_id, cp_daytime, '<=') =
         cp_product_id
     AND boe_source_id = cp_cf_id
     AND daytime >= cp_daytime
     AND daytime < nvl(cp_end_date, daytime + 1);

-- See if changed CF is in use in forecast
CURSOR c_fcst(cp_product_id VARCHAR2, cp_cf_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS
SELECT sfmv.object_id, sfmv.forecast_id, sfmv.daytime
  FROM stim_fcst_mth_value sfmv
 WHERE ec_stream_item_version.product_id(sfmv.object_id, sfmv.daytime, '<=') =
       cp_product_id
   AND sfmv.boe_source_id = cp_cf_id
   AND sfmv.daytime >= cp_daytime
   AND sfmv.daytime < NVL(cp_end_date, sfmv.daytime + 1)
   AND sfmv.forecast_id NOT IN
       (SELECT fms.object_id
          FROM fcst_mth_status fms
         WHERE fms.record_status IN ('V', 'A'));


CURSOR c_bf IS
SELECT bf.name
  FROM business_function bf
 WHERE bf.url = p_business_function_url;

BEGIN



  -- Preparing business function name
  FOR cbf IN c_bf LOOP
      lv2_business_function := cbf.name;
  END LOOP;

  IF lv2_business_function IS NULL THEN
     lv2_business_function := 'N/A';
  END IF;

       IF (p_daytime IS NULL OR UPPER(p_daytime) = 'NULL') THEN
          ld_daytime := NULL;
       ELSE
          ld_daytime := to_date(p_daytime, 'YYYY-MM-DD"T"HH24:MI:SS');
       END IF;
       IF (p_end_date IS NULL OR UPPER(p_end_date) = 'NULL') THEN
          ld_end_date := NULL;
       ELSE
        BEGIN
              ld_end_date := to_date(p_end_date, 'YYYY-MM-DD"T"HH24:MI:SS');
        EXCEPTION
            WHEN OTHERS THEN
              ld_end_date := NULL;
        END;
       END IF;

       IF (UPPER(p_object_id) = 'NULL') THEN
          lv2_object_id := NULL;
       ELSE
          lv2_object_id := p_object_id;
       END IF;
       lv2_class := EcDp_Objects.GetObjClassName(p_object_id);

       IF (lv2_class IS NULL) THEN
             RETURN;
       END IF;

        -- Getting system attribute for how to handle BOE conversion factor changes
        lv2_sysprop_runmode := nvl(ec_ctrl_system_attribute.attribute_text(ld_daytime,'CASCADE_BOE_FACT_CHANGE','<='),'AUTO');

/* Avoiding all the loops if nothing is supposed to be done here */
IF lv2_sysprop_runmode = 'NONE' THEN
   RETURN;
END IF;

        FOR CurFactors IN c_factors( lv2_object_id, ld_daytime, ld_end_date ) LOOP


             -- Insert Cascade basis for BOE conversion factor adjustment on daily values
             FOR rsD IN c_sdv(CurFactors.Product_Id, lv2_object_id, CurFactors.daytime, CurFactors.end_date) LOOP

             IF lv2_sysprop_runmode <> 'NONE' THEN
                 IF ln_stim_day_pend_no IS NULL THEN

                    lv2_description := 'BOE Conversion factor change: ' ||
                                       EcDp_ClassMeta_Cnfg.getLabel(ecdp_objects.GetObjClassName(lv2_object_id)) ||
                                       ' '||
                                       ecdp_objects.GetObjName(lv2_object_id,CurFactors.daytime) ||
                                       ' / Product ' ||
                                       ec_product_version.name(CurFactors.Product_Id,CurFactors.daytime,'<=');


                      INSERT INTO stim_pending
                        (stim_pending_no,period, bf_reference, description, created_by)
                      VALUES
                        (p_stim_pending_no,'DAY', lv2_business_function, lv2_description, p_user)
                      RETURNING stim_pending_no INTO ln_stim_day_pend_no;
                END IF;

                INSERT INTO stim_pending_item
                  (object_id,
                   daytime,
                   stim_pending_no,
                   period,
                   status_code,
                   created_by)
                VALUES
                  (rsD.Object_Id,
                   rsD.Daytime,
                   ln_stim_day_pend_no,
                   'DAY',
                   'READY',
                   p_user);
             END IF;

             END LOOP;


             -- Insert Cascade basis for BOE conversion factor adjustment on monthly values



             FOR rsM IN c_smv(CurFactors.Product_Id, lv2_object_id, CurFactors.daytime, CurFactors.end_date) LOOP

                IF lv2_sysprop_runmode <> 'NONE' THEN
                     IF ln_stim_mth_pend_no IS NULL THEN

                        lv2_description := 'BOE Conversion factor change: ' ||
                                      EcDp_ClassMeta_Cnfg.getLabel(ecdp_objects.GetObjClassName(lv2_object_id)) ||
                                      ' '||
                                      ecdp_objects.GetObjName(lv2_object_id,CurFactors.daytime) ||
                                      ' / Product ' ||
                                      ec_product_version.name(CurFactors.Product_Id,CurFactors.daytime,'<=');

                        INSERT INTO stim_pending
                          (stim_pending_no,period, bf_reference, description, created_by)
                        VALUES
                          (p_stim_pending_no,'MTH', lv2_business_function, lv2_description, p_user)
                        RETURNING stim_pending_no INTO ln_stim_mth_pend_no;
                  END IF;

                    INSERT INTO stim_pending_item
                      (object_id,
                       daytime,
                       stim_pending_no,
                       period,
                       status_code,
                       created_by)
                    VALUES
                      (rsM.Object_Id,
                       rsM.Daytime,
                       ln_stim_mth_pend_no,
                       'MTH',
                       'READY',
                       p_user);

                 END IF;
             END LOOP;


             -- Insert Cascade basis for BOE conversion factor adjustment on monthly values
             FOR rsF IN c_fcst(CurFactors.Product_Id, lv2_object_id, CurFactors.daytime, CurFactors.end_date) LOOP


                  IF lv2_sysprop_runmode <> 'NONE' THEN
                   IF ln_stim_fcst_mth_pend_no IS NULL THEN

                      lv2_description := 'Conversion factor change: ' ||
                                         EcDp_ClassMeta_Cnfg.getLabel(ecdp_objects.GetObjClassName(lv2_object_id)) ||
                                         ' '||
                                         ecdp_objects.GetObjName(lv2_object_id,CurFactors.daytime) ||
                                         ' / Product ' ||
                                         ec_product_version.name(CurFactors.Product_Id,CurFactors.daytime,'<=');


                        INSERT INTO stim_pending
                          (stim_pending_no,
                           period,
                           bf_reference,
                           description,
                           created_by)
                        VALUES
                          (p_stim_pending_no,
                           'FCST_MTH',
                           lv2_business_function,
                           lv2_description,
                           p_user)
                        RETURNING stim_pending_no INTO ln_stim_fcst_mth_pend_no;

                  END IF;

                    INSERT INTO stim_pending_item
                      (object_id,
                       daytime,
                       stim_pending_no,
                       period,
                       forecast_id,
                       status_code,
                       created_by)
                    VALUES
                      (rsF.Object_Id,
                       rsF.Daytime,
                       ln_stim_fcst_mth_pend_no,
                       'FCST_MTH',
                       rsF.Forecast_Id,
                       'READY',
                       p_user);

                  END IF;
             END LOOP;

        END LOOP;

END UpdateBOEConversionFactor;


PROCEDURE UpdateSTIMConversionFactor(
   p_object_id VARCHAR2, -- Stream_Item object_id
   p_daytime DATE, -- The daytime to run the update for
   p_type VARCHAR2, -- Either DAY or MTH
   p_user VARCHAR2,
   p_forecast_id VARCHAR2 DEFAULT NULL
) IS

l_stim_day_value stim_day_value%ROWTYPE;
l_ConvFact t_conversion;

BEGIN

   l_ConvFact := GetDefDensity(p_object_id, p_daytime);
   l_stim_day_value.density := l_ConvFact.factor;
   l_stim_day_value.density_volume_uom := l_ConvFact.from_uom;
   l_stim_day_value.density_mass_uom := l_ConvFact.to_uom;
   l_stim_day_value.density_source_id := l_ConvFact.source_object_id;

   l_ConvFact := GetDefGCV(p_object_id, p_daytime);
   l_stim_day_value.gcv := l_ConvFact.factor;
   l_stim_day_value.gcv_volume_uom := l_ConvFact.from_uom;
   l_stim_day_value.gcv_energy_uom := l_ConvFact.to_uom;
   l_stim_day_value.gcv_source_id := l_ConvFact.source_object_id;

   l_ConvFact := GetDefMCV(p_object_id, p_daytime);
   l_stim_day_value.mcv := l_ConvFact.factor;
   l_stim_day_value.mcv_mass_uom := l_ConvFact.from_uom;
   l_stim_day_value.mcv_energy_uom := l_ConvFact.to_uom;
   l_stim_day_value.mcv_source_id := l_ConvFact.source_object_id;

   l_ConvFact := GetDefBOE(p_object_id, p_daytime);
   l_stim_day_value.boe_factor := l_ConvFact.factor;
   l_stim_day_value.boe_from_uom_code := l_ConvFact.from_uom;
   l_stim_day_value.boe_to_uom_code := l_ConvFact.to_uom;
   l_stim_day_value.boe_source_id := l_ConvFact.source_object_id;



   IF (p_type = 'DAY') THEN
      -- Ensure source ids are not reset if values have been manually input (ECPD-13789):
      IF ec_stim_day_value.mcv(p_object_id, p_daytime) IS NOT NULL AND nvl(ec_stim_day_value.mcv_source_id(p_object_id, p_daytime) , 'X') = 'X'
        AND l_stim_day_value.mcv is null  THEN
        l_stim_day_value.mcv_source_id  := NULL;
      END IF;

      IF ec_stim_day_value.gcv(p_object_id, p_daytime) IS NOT NULL AND nvl(ec_stim_day_value.gcv_source_id(p_object_id, p_daytime), 'X') = 'X'
        AND l_stim_day_value.gcv is null  THEN
        l_stim_day_value.gcv_source_id  := NULL;
      END IF;

      IF ec_stim_day_value.density(p_object_id, p_daytime) IS NOT NULL AND nvl(ec_stim_day_value.density_source_id(p_object_id, p_daytime) , 'X') = 'X'
        AND l_stim_day_value.density is null THEN
        l_stim_day_value.density_source_id  := NULL;
      END IF;

      IF ec_stim_day_value.boe_factor(p_object_id, p_daytime) IS NOT NULL AND nvl(ec_stim_day_value.boe_source_id(p_object_id, p_daytime), 'X') = 'X'
        AND l_stim_day_value.boe_factor is null  THEN
        l_stim_day_value.boe_source_id := NULL;
      END IF;

      -- Update the daily numbers with the new conversion factors
      UPDATE stim_day_value
         SET density            = nvl2(l_stim_day_value.density_source_id, l_stim_day_value.density, density),
             density_volume_uom = nvl2(l_stim_day_value.density_source_id, l_stim_day_value.density_volume_uom, density_volume_uom),
             density_mass_uom   = nvl2(l_stim_day_value.density_source_id, l_stim_day_value.density_mass_uom, density_mass_uom),
             gcv                = nvl2(l_stim_day_value.gcv_source_id, l_stim_day_value.gcv, gcv),
             gcv_volume_uom     = nvl2(l_stim_day_value.gcv_source_id, l_stim_day_value.gcv_volume_uom, gcv_volume_uom),
             gcv_energy_uom     = nvl2(l_stim_day_value.gcv_source_id, l_stim_day_value.gcv_energy_uom, gcv_energy_uom),
             mcv                = nvl2(l_stim_day_value.mcv_source_id, l_stim_day_value.mcv, mcv),
             mcv_mass_uom       = nvl2(l_stim_day_value.mcv_source_id, l_stim_day_value.mcv_mass_uom, mcv_mass_uom),
             mcv_energy_uom     = nvl2(l_stim_day_value.mcv_source_id, l_stim_day_value.mcv_energy_uom, mcv_energy_uom),
             boe_factor         = nvl2(l_stim_day_value.boe_source_id, l_stim_day_value.boe_factor, boe_factor),
             boe_from_uom_code  = nvl2(l_stim_day_value.boe_source_id, l_stim_day_value.boe_from_uom_code, boe_from_uom_code),
             boe_to_uom_code    = nvl2(l_stim_day_value.boe_source_id, l_stim_day_value.boe_to_uom_code, boe_to_uom_code),
             last_updated_by    = p_user
       WHERE object_id = p_object_id
         AND daytime = p_daytime;
      -- To Force the a journal record
      UPDATE stim_day_value
         SET density_source_id = l_stim_day_value.density_source_id,
             gcv_source_id     = l_stim_day_value.gcv_source_id,
             mcv_source_id     = l_stim_day_value.mcv_source_id,
             boe_source_id     = l_stim_day_value.boe_source_id,
             last_updated_by   = 'SYSTEM'
       WHERE object_id = p_object_id
         AND daytime = p_daytime;
   ELSIF (p_type = 'MTH') THEN
      -- Ensure source ids are not reset if values have been manually input (ECPD-13789):
      IF ec_stim_mth_value.mcv(p_object_id, p_daytime) IS NOT NULL
          AND nvl(ec_stim_mth_value.mcv_source_id(p_object_id, p_daytime) , 'X') = 'X'
          AND l_stim_day_value.mcv is null
      THEN
        l_stim_day_value.mcv_source_id  := NULL;
      END IF;

      IF ec_stim_mth_value.gcv(p_object_id, p_daytime) IS NOT NULL AND nvl(ec_stim_mth_value.gcv_source_id(p_object_id, p_daytime) , 'X') = 'X'
        AND l_stim_day_value.gcv is null THEN
        l_stim_day_value.gcv_source_id  := NULL;
      END IF;

      IF ec_stim_mth_value.density(p_object_id, p_daytime) IS NOT NULL AND nvl(ec_stim_mth_value.density_source_id(p_object_id, p_daytime) , 'X') = 'X'
        AND l_stim_day_value.density is null THEN
        l_stim_day_value.density_source_id  := NULL;
      END IF;

      IF ec_stim_mth_value.boe_factor(p_object_id, p_daytime) IS NOT NULL AND nvl(ec_stim_mth_value.boe_source_id(p_object_id, p_daytime) , 'X') = 'X'
         AND l_stim_day_value.boe_factor is null THEN
        l_stim_day_value.boe_source_id := NULL;
      END IF;

      -- Update the monthly numbers with the new conversion factors
      UPDATE stim_mth_value
         SET density            = nvl2(l_stim_day_value.density_source_id, l_stim_day_value.density, density),
             density_volume_uom = nvl2(l_stim_day_value.density_source_id, l_stim_day_value.density_volume_uom, density_volume_uom),
             density_mass_uom   = nvl2(l_stim_day_value.density_source_id, l_stim_day_value.density_mass_uom, density_mass_uom),
             gcv                = nvl2(l_stim_day_value.gcv_source_id, l_stim_day_value.gcv, gcv),
             gcv_volume_uom     = nvl2(l_stim_day_value.gcv_source_id, l_stim_day_value.gcv_volume_uom, gcv_volume_uom),
             gcv_energy_uom     = nvl2(l_stim_day_value.gcv_source_id, l_stim_day_value.gcv_energy_uom, gcv_energy_uom),
             mcv                = nvl2(l_stim_day_value.mcv_source_id, l_stim_day_value.mcv, mcv),
             mcv_mass_uom       = nvl2(l_stim_day_value.mcv_source_id, l_stim_day_value.mcv_mass_uom, mcv_mass_uom),
             mcv_energy_uom     = nvl2(l_stim_day_value.mcv_source_id, l_stim_day_value.mcv_energy_uom, mcv_energy_uom),
             boe_factor         = nvl2(l_stim_day_value.boe_source_id, l_stim_day_value.boe_factor, boe_factor),
             boe_from_uom_code  = nvl2(l_stim_day_value.boe_source_id, l_stim_day_value.boe_from_uom_code, boe_from_uom_code),
             boe_to_uom_code    = nvl2(l_stim_day_value.boe_source_id, l_stim_day_value.boe_to_uom_code, boe_to_uom_code),
             last_updated_by    = p_user
       WHERE object_id = p_object_id
         AND daytime = p_daytime;
      -- To Force the a journal record
      UPDATE stim_mth_value
         SET density_source_id = l_stim_day_value.density_source_id,
             gcv_source_id     = l_stim_day_value.gcv_source_id,
             mcv_source_id     = l_stim_day_value.mcv_source_id,
             boe_source_id     = l_stim_day_value.boe_source_id,
             last_updated_by   = 'SYSTEM'
       WHERE object_id = p_object_id
         AND daytime = p_daytime;
   ELSIF (p_type = 'FCST_MTH') THEN
      -- Ensure source ids are not reset if values have been manually input (ECPD-13789):
      IF ec_stim_fcst_mth_value.mcv(p_object_id, p_forecast_id, p_daytime) IS NOT NULL AND nvl(ec_stim_fcst_mth_value.mcv_source_id(p_object_id, p_forecast_id, p_daytime) , 'X') = 'X'
        AND l_stim_day_value.mcv is null THEN
        l_stim_day_value.mcv_source_id  := NULL;
      END IF;

      IF ec_stim_fcst_mth_value.gcv(p_object_id, p_forecast_id, p_daytime) IS NOT NULL AND nvl(ec_stim_fcst_mth_value.gcv_source_id(p_object_id, p_forecast_id, p_daytime) , 'X') = 'X'
        AND l_stim_day_value.gcv is null THEN
        l_stim_day_value.gcv_source_id  := NULL;
      END IF;

      IF ec_stim_fcst_mth_value.density(p_object_id, p_forecast_id, p_daytime) IS NOT NULL AND nvl(ec_stim_fcst_mth_value.density_source_id(p_object_id, p_forecast_id, p_daytime) , 'X') = 'X'
       AND l_stim_day_value.density is null  THEN
        l_stim_day_value.density_source_id  := NULL;
      END IF;

      IF ec_stim_fcst_mth_value.boe_factor(p_object_id, p_forecast_id, p_daytime) IS NOT NULL AND nvl(ec_stim_fcst_mth_value.boe_source_id(p_object_id, p_forecast_id, p_daytime) , 'X') = 'X'
        AND l_stim_day_value.boe_factor is null  THEN
        l_stim_day_value.boe_source_id := NULL;
      END IF;

      -- Update the monthly numbers with the new conversion factors
      UPDATE stim_fcst_mth_value
         SET density            = nvl2(l_stim_day_value.density_source_id, l_stim_day_value.density, density),
             density_volume_uom = nvl2(l_stim_day_value.density_source_id, l_stim_day_value.density_volume_uom, density_volume_uom),
             density_mass_uom   = nvl2(l_stim_day_value.density_source_id, l_stim_day_value.density_mass_uom, density_mass_uom),
             gcv                = nvl2(l_stim_day_value.gcv_source_id, l_stim_day_value.gcv, gcv),
             gcv_volume_uom     = nvl2(l_stim_day_value.gcv_source_id, l_stim_day_value.gcv_volume_uom, gcv_volume_uom),
             gcv_energy_uom     = nvl2(l_stim_day_value.gcv_source_id, l_stim_day_value.gcv_energy_uom, gcv_energy_uom),
             mcv                = nvl2(l_stim_day_value.mcv_source_id, l_stim_day_value.mcv, mcv),
             mcv_mass_uom       = nvl2(l_stim_day_value.mcv_source_id, l_stim_day_value.mcv_mass_uom, mcv_mass_uom),
             mcv_energy_uom     = nvl2(l_stim_day_value.mcv_source_id, l_stim_day_value.mcv_energy_uom, mcv_energy_uom),
             boe_factor         = nvl2(l_stim_day_value.boe_source_id, l_stim_day_value.boe_factor, boe_factor),
             boe_from_uom_code  = nvl2(l_stim_day_value.boe_source_id, l_stim_day_value.boe_from_uom_code, boe_from_uom_code),
             boe_to_uom_code    = nvl2(l_stim_day_value.boe_source_id, l_stim_day_value.boe_to_uom_code, boe_to_uom_code),
             last_updated_by    = p_user
       WHERE object_id = p_object_id
         AND daytime = p_daytime
         AND forecast_id = p_forecast_id;
      -- To Force the a journal record
      UPDATE stim_fcst_mth_value
         SET density_source_id = l_stim_day_value.density_source_id,
             gcv_source_id     = l_stim_day_value.gcv_source_id,
             mcv_source_id     = l_stim_day_value.mcv_source_id,
             boe_source_id     = l_stim_day_value.boe_source_id,
             last_updated_by   = 'SYSTEM'
       WHERE object_id = p_object_id
         AND daytime = p_daytime
         AND forecast_id = p_forecast_id;
   END IF;

END UpdateSTIMConversionFactor;

PROCEDURE UpdateListStrmConversionFactor(
   p_object_id VARCHAR2, -- List object_id or Stream object_id
   p_daytime DATE, -- The daytime to run the update for
   p_type VARCHAR2, -- Either DAY or MTH
   p_user VARCHAR2
) IS

l_stim_day_value stim_day_value%ROWTYPE;
l_ConvFact t_conversion;
lv2_class_name VARCHAR2(200);

-- Find Stream_Items based on Stream_Id
CURSOR c_stream IS
SELECT si.object_id stream_item_id FROM stream_item si WHERE
    si.stream_id = p_object_id
    AND (p_daytime >= Nvl(start_date,p_daytime-1) AND p_daytime < Nvl(end_date, p_daytime+1))
;

-- Find Stream_Items based on Stream_Item_Collection
CURSOR c_list IS
SELECT stream_item_id FROM stim_collection_setup scs
WHERE scs.object_id  = p_object_id
    AND p_daytime >= scs.daytime
;

BEGIN

   lv2_class_name := EcDp_Objects.GetObjClassName(p_object_id);
   IF (lv2_class_name = 'STREAM') THEN
      FOR StreamItems IN c_stream LOOP
         UpdateSTIMConversionFactor(StreamItems.stream_item_id, p_daytime, p_type, p_user);
         -- Insert into stim_cascade to mark SIs to run cascade for
         INSERT INTO stim_cascade (object_id,period,daytime) VALUES (StreamItems.stream_item_id, p_type, p_daytime);
      END LOOP;
   ELSIF (lv2_class_name = 'STREAM_ITEM_COLLECTION') THEN
      FOR StreamCollItems IN c_list LOOP
         UpdateSTIMConversionFactor(StreamCollItems.stream_item_id, p_daytime, p_type, p_user);
         -- Insert into stim_cascade to mark SIs to run cascade for
         INSERT INTO stim_cascade (object_id,period,daytime) VALUES (StreamCollItems.stream_item_id, p_type, p_daytime);
      END LOOP;
   ELSE
      Raise_Application_Error(-20000,'Unknown class to run this conversion on, please contact technical personell');
   END IF;

END UpdateListStrmConversionFactor;

FUNCTION GetProductFromSI(
   p_object_id VARCHAR2,
   p_daytime DATE
   ) RETURN VARCHAR2
IS

lv2_stream_id Objects.Object_Id%TYPE;
lv2_product_id Objects.Object_Id%TYPE;

BEGIN

   -- get the stram where the stream item is connect to

   -- get the product the stram represents
lv2_product_id := ec_stream_item_version.product_id(p_object_id, p_daytime, '<=');

   return lv2_product_id;

END GetProductFromSI;

FUNCTION GetConvValue (
   p_object_id VARCHAR2,  -- STREAM_ITEM object_id
   p_daytime DATE, -- Date to process for
   p_type VARCHAR2, -- DAY or MTH
   p_group VARCHAR2, -- M V or E
   p_to_uom VARCHAR2
) RETURN NUMBER
IS

   ln_value NUMBER;
   ln_return_value NUMBER;
   lv2_uom VARCHAR2(32);

BEGIN

     IF (p_type = 'DAY') THEN
        IF (p_group = 'M') THEN
           lv2_uom := ec_stim_day_value.mass_uom_code(p_object_id, p_daytime);
           ln_value := ec_stim_day_value.net_mass_value(p_object_id,p_daytime);
        ELSIF (p_group = 'V') THEN
           lv2_uom := ec_stim_day_value.volume_uom_code(p_object_id, p_daytime);
           ln_value := ec_stim_day_value.net_volume_value(p_object_id,p_daytime);
        ELSIF (p_group = 'E') THEN
           lv2_uom := ec_stim_day_value.energy_uom_code(p_object_id, p_daytime);
           ln_value := ec_stim_day_value.net_energy_value(p_object_id,p_daytime);
        END IF;
        ln_return_value := EcDp_Revn_Unit.convertValue(ln_value, lv2_uom, p_to_uom, p_object_id, p_daytime);
     ELSIf (p_type = 'MTH') THEN
        IF (p_group = 'M') THEN
           lv2_uom := ec_stim_mth_value.mass_uom_code(p_object_id, p_daytime);
           ln_value := ec_stim_mth_value.net_mass_value(p_object_id,p_daytime);
        ELSIF (p_group = 'V') THEN
           lv2_uom := ec_stim_mth_value.volume_uom_code(p_object_id, p_daytime);
           ln_value := ec_stim_mth_value.net_volume_value(p_object_id,p_daytime);
        ELSIF (p_group = 'E') THEN
           lv2_uom := ec_stim_mth_value.energy_uom_code(p_object_id, p_daytime);
           ln_value := ec_stim_mth_value.net_energy_value(p_object_id,p_daytime);
        END IF;
        ln_return_value := EcDp_Revn_Unit.convertValue(ln_value, lv2_uom, p_to_uom, p_object_id, p_daytime);
     END IF;

     RETURN ln_return_value;

END GetConvValue;


PROCEDURE Validate_Stream_Item -- validate a stream item prior to committing save
(  p_object_id VARCHAR2,
   p_daytime  DATE
)

IS

generic_error EXCEPTION;

lv2_attr_name VARCHAR2(2000);
lv2_id objects.object_id%TYPE;
lb_found BOOLEAN := FALSE;
lv2_calc_method VARCHAR2(32);
lv2_split_type VARCHAR2(32);
lv2_formula VARCHAR2(2000);
lv2_si_separated VARCHAR2(2000);
ln_si_count NUMBER;
ln_count NUMBER;
lv2_si_code stream_item.object_code%type;
lv2_si_id stream_item.object_id%type;
ln_this     INT;
ln_last     INT;

BEGIN

      lv2_calc_method := ec_stream_item_version.calc_method(p_object_id, p_daytime, '<=');
      lv2_formula := ec_stream_item_version.stream_item_formula(p_object_id, p_daytime, '<=');

     -- additional checks for certain types of stream items
     IF lv2_calc_method IN ( 'IP', 'CO' ) THEN

        -- following relations must not exists
        IF lv2_formula IS NOT NULL OR lv2_formula <> '' THEN

           lv2_attr_name := 'Stream items with calc method '|| lv2_calc_method ||' must have a blank Formula';

           RAISE  generic_error;

        END IF;

     ELSIF lv2_calc_method IN ( 'SK' , 'FO' ) THEN

     IF lv2_formula IS NULL OR lv2_formula = '' THEN
           lv2_attr_name := 'Stream items with calc method '|| lv2_calc_method ||' cannot have a blank Formula';
          RAISE generic_error;

       END IF;

      -- Additions
      IF INSTR(lv2_formula, '+') > 0 OR
        INSTR(lv2_formula, '-') > 0 OR
        INSTR(lv2_formula, '/') > 0 OR
        INSTR(lv2_formula, '*') > 0 THEN

        lv2_si_separated := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lv2_formula,'+',';'),'-',';'),'/',';'),'*',';'),'(',''),')',''),' ','') || ';';


        -- How many stream items are in the formula?
        ln_si_count := LENGTH(REPLACE(lv2_si_separated, ';', ';' || ' ')) - LENGTH(lv2_si_separated);

        ln_count := 1;
        ln_last := 0;

        WHILE ln_count <= ln_si_count LOOP

              ln_this := instr(lv2_si_separated, ';', 1, ln_count);

              -- Get the Stream Item code
              lv2_si_code := trim(substr(lv2_si_separated, ln_last + 1, ln_this - ln_last -1));

              -- Verify a valid Stream Item
              lv2_si_id := ec_stream_item.object_id_by_uk(lv2_si_code);

              IF lv2_si_id IS NULL THEN

                 lv2_attr_name :=  'Code found in formula ' || lv2_si_code || ' does not represent a valid stream item';
                 RAISE generic_error;

              END IF;

              -- Go to next SI
              ln_count := ln_count + 1;
              ln_last := ln_this;

        END LOOP;

        ELSE

        -- Assuming only one stream item in formula. If not a valid SI Code an exception is thrown
        lv2_si_id := ec_stream_item.object_id_by_uk(lv2_formula);

        IF lv2_si_id IS NULL THEN

           lv2_attr_name :=  'Code found in formula ' || lv2_formula || ' does not represent a valid stream item';
                 RAISE generic_error;


        END IF;


        END IF;

      -- End additions

     END IF;


EXCEPTION


   WHEN generic_error THEN

        Raise_Application_Error(-20000,lv2_attr_name || '. Stream item: ' || Nvl(ec_stream_item.object_code(p_object_id),' ') || ' - ' || Nvl(ec_stream_item_version.name(p_object_id,p_daytime,'<='),' ') );

END Validate_Stream_Item;





PROCEDURE DelStreamItem(
   p_object_id VARCHAR2,
   p_daytime   DATE DEFAULT NULL,
   p_user      VARCHAR2 DEFAULT NULL
)

IS
/*
CURSOR c_si_del_rel IS
SELECT *
FROM classes_relation
WHERE to_class = 'STREAM_ITEM'
AND role_name IN (
'COMPANY',
'FIELD',
'NODE',
'SPLIT_COMPANY',
'SPLIT_FIELD',
'SPLIT_ITEM_OTHER',
'SPLIT_KEY',
'SPLIT_PRODUCT',
'STREAM',
'STREAM_ITEM_CATEGORY'
); -- For time being need to list them

in_use_exception EXCEPTION;
ln_si_splits NUMBER;
ln_remaining_rels NUMBER;
ln_instantiated NUMBER;
ln_period_value NUMBER;
*/
BEGIN
  Raise_Application_Error(-20000,'TO BE IMPLEMENTED');

/*
     -- check if si is instantiated (daily)
     ln_instantiated := Ec_Stim_Day_Value.count_rows(p_object_id, to_date('01.01.1000','DD.MM.YYYY'), to_date('01.01.9999','DD.MM.YYYY'));

     -- raise exception if so
     IF ln_instantiated > 0 THEN
        RAISE in_use_exception;
     END IF;

     -- check if si is instantiated (monthly)
     ln_instantiated := Ec_Stim_Mth_Value.count_rows(p_object_id, to_date('01.01.1000','DD.MM.YYYY'), to_date('01.01.9999','DD.MM.YYYY'));

     -- raise exception if so
     IF ln_instantiated > 0 THEN
        RAISE in_use_exception;
     END IF;

     -- check if si in use in stim_period_gen_value
     SELECT count(*)
     INTO ln_period_value
     FROM stim_period_gen_value
     WHERE object_id = p_object_id;

     -- raise exception if so
     IF ln_period_value > 0 THEN
        RAISE in_use_exception;
     END IF;

     -- check if si in use in normal si split
     SELECT count(*)
     INTO ln_si_splits
     FROM objects_rel_attribute x
     WHERE exists (SELECT 'x' FROM OBJECTS_RELATION
                  WHERE object_id = x.object_id
                  AND to_object_id = p_object_id
                  AND role_name = 'SPLIT_KEY');

     -- raise exception if so
     IF ln_si_splits > 0 THEN
        RAISE in_use_exception;
     END IF;

     -- delete relations
     FOR DelRelCur IN c_si_del_rel LOOP

         DELETE FROM OBJECTS_RELATION
         WHERE to_object_id = p_object_id
         AND role_name = DelRelCur.role_name;

     END LOOP;

     -- delete formula relation from this si
     DELETE FROM OBJECTS_RELATION
     WHERE from_object_id = p_object_id
     AND role_name = 'FORMULA_ITEM';

     -- check if there are remaining relations
     SELECT count(*)
     INTO ln_remaining_rels
     FROM objects_relation
     WHERE from_object_id = p_object_id
     OR to_object_id = p_object_id;

     -- raise execption if so
     IF ln_remaining_rels > 0 THEN
        RAISE in_use_exception;
     END IF;

     -- delete from objects_attribute
     DELETE FROM objects_attribute
     WHERE object_id = p_object_id;

     -- delete from objects
     DELETE FROM objects
     WHERE object_id = p_object_id;


EXCEPTION

   WHEN in_use_exception THEN

        Raise_Application_Error(-20000, 'Stream item: ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,nvl(p_daytime,Ecdp_Timestamp.getCurrentSysdate),'CODE'),' ') || ' - ' || Nvl(EcDp_Objects.GetObjAttrText(p_object_id,nvl(p_daytime,Ecdp_Timestamp.getCurrentSysdate),'NAME'),' ') || ' is in use and cannot be deleted.');

*/
END DelStreamItem;

PROCEDURE CleanUpStreamItem(
    p_object_id VARCHAR2,
    p_clean_up_cm VARCHAR2, -- CALC_METHOD
    p_clean_up_sk VARCHAR2, -- SPLIT_KEY
    p_daytime DATE,
    p_user VARCHAR2
)

IS

BEGIN

    IF p_clean_up_cm = 'Y' THEN
        DELETE FROM stream_item_formula t WHERE t.stream_item_id = p_object_id;
    END IF;

    IF p_clean_up_sk = 'Y' THEN
        UPDATE stream_item_version t SET
            t.split_company_id = NULL
            ,t.split_field_id = NULL
            ,t.split_product_id = NULL
            ,t.split_item_other_id = NULL
        WHERE t.object_id = p_object_id
        AND t.daytime = p_daytime;
    END IF;

END CleanUpStreamItem;


Function crossGroupUnitConvert(
  p_si_object_id varchar2 ,
  p_daytime date,
  p_from_group varchar2,
  p_from_uom varchar2,
  p_to_group varchar2,
  p_to_uom varchar2,
  p_value number)

RETURN NUMBER

IS

cursor c_stim_mth_value IS
select *
from stim_mth_value
where object_id = p_si_object_id
and   daytime = p_daytime;

lr_stim_mth_value stim_mth_value%ROWTYPE;
ln_result         NUMBER;

BEGIN

  -- First check if differen groups

  IF  p_from_group <> p_to_group  THEN

     FOR curSI IN c_stim_mth_value LOOP   -- There should only be one

        lr_stim_mth_value :=  curSI;

     END LOOP;


     IF p_from_group = 'V'  THEN

        IF p_to_group = 'M' AND lr_stim_mth_value.DENSITY IS NOT NULL THEN

          ln_result :=  EcDp_Revn_Unit.convertValue( EcDp_Revn_Unit.convertValue(p_value, p_from_uom,
                                             lr_stim_mth_value.DENSITY_VOLUME_UOM, p_si_object_id, p_daytime) * lr_stim_mth_value.DENSITY
                                            ,lr_stim_mth_value.DENSITY_MASS_UOM
                                            ,p_to_uom, p_si_object_id, p_daytime);

      ELSIF p_to_group = 'E' AND lr_stim_mth_value.GCV IS NOT NULL THEN

        ln_result := EcDp_Revn_Unit.convertValue( EcDp_Revn_Unit.convertValue(p_value,p_from_uom,
                                            lr_stim_mth_value.GCV_VOLUME_UOM, p_si_object_id, p_daytime) * lr_stim_mth_value.GCV
                                           , lr_stim_mth_value.GCV_ENERGY_UOM
                                           ,p_to_uom, p_si_object_id, p_daytime);

        END IF;


     ELSIF p_from_group = 'M' THEN

        IF p_to_group = 'V' AND lr_stim_mth_value.DENSITY IS NOT NULL THEN

            ln_result := EcDp_Revn_Unit.convertValue( EcDp_Revn_Unit.convertValue(p_value,p_from_uom,
                                                          lr_stim_mth_value.DENSITY_MASS_UOM, p_si_object_id, p_daytime) / lr_stim_mth_value.DENSITY
                                                          , lr_stim_mth_value.DENSITY_VOLUME_UOM
                                                          ,p_to_uom, p_si_object_id, p_daytime);

      ELSIF p_to_group = 'E' AND lr_stim_mth_value.GCV IS NOT NULL THEN

        ln_result := EcDp_Revn_Unit.convertValue( EcDp_Revn_Unit.convertValue(p_value,p_from_uom,
                                                           lr_stim_mth_value.MCV_MASS_UOM, p_si_object_id, p_daytime) * lr_stim_mth_value.MCV
                                                           , lr_stim_mth_value.MCV_ENERGY_UOM
                                                           , p_to_uom, p_si_object_id, p_daytime);


        END IF;


     ELSIF p_from_group = 'E'  THEN


        IF p_to_group = 'V' AND lr_stim_mth_value.GCV IS NOT NULL THEN



        ln_result :=  EcDp_Revn_Unit.convertValue( EcDp_Revn_Unit.convertValue(p_value,p_from_uom,
                                                          lr_stim_mth_value.GCV_ENERGY_UOM, p_si_object_id, p_daytime) / lr_stim_mth_value.GCV
                                                          , lr_stim_mth_value.GCV_VOLUME_UOM
                                                          , p_to_uom, p_si_object_id, p_daytime);


      ELSIF p_to_group = 'M' AND lr_stim_mth_value.GCV IS NOT NULL THEN

           ln_result :=  EcDp_Revn_Unit.convertValue( EcDp_Revn_Unit.convertValue(p_value,p_from_uom,
                                                         lr_stim_mth_value.MCV_ENERGY_UOM, p_si_object_id, p_daytime) / lr_stim_mth_value.MCV
                                                         , lr_stim_mth_value.MCV_MASS_UOM,
                                                         p_to_uom, p_si_object_id, p_daytime);


        END IF;


     END IF;

  ELSE

     ln_result := EcDp_Unit.convertValue(p_value,p_from_uom,p_to_uom, p_daytime);

  END IF;


  RETURN ln_result;

END  crossGroupUnitConvert;


PROCEDURE SetSIParentFieldIndicator(
   p_si_object_id  VARCHAR2,
   p_daytime       DATE,
   p_user          VARCHAR2
   )

IS

lv2_parent_field_ind VARCHAR2(1);

BEGIN

  lv2_parent_field_ind := GetParentChildFieldIndicator(p_si_object_id,NULL,p_daytime);

       UPDATE stream_item_version t
       SET t.parent_field_type = lv2_parent_field_ind
       WHERE object_id = p_si_object_id
       AND   daytime = p_daytime;

END;


PROCEDURE checkExistedStim(
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_product_context IN VARCHAR2)
IS
ln_numrows NUMBER;

BEGIN
   -- Check if the record already exists
   SELECT Count(*) INTO ln_numrows
    FROM fcst_member
    WHERE object_id = p_object_id
    AND product_id = p_product_id
    AND member_type = 'FIELD_PRODUCT'
    and product_context = p_product_context
    AND adj_stream_item_id is not null;

    IF (ln_numrows >= 1) THEN
      RAISE_APPLICATION_ERROR(-20000,'Cannot insert more than 1 Adjustment Stream Item');
    END IF;
END;



PROCEDURE checkRedundantStim(
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_stream_item_id  IN VARCHAR2,
   p_product_context IN VARCHAR2)
IS

CURSOR c_no_rows_stim IS
  SELECT Count(*) no_rows
  FROM fcst_member
  WHERE object_id = p_object_id
  AND product_id = p_product_id
  AND member_type = 'FIELD_PRODUCT'
  and product_context =  p_product_context
  AND stream_item_id = p_stream_item_id;
ln_numrows NUMBER;

BEGIN
   -- Check if the stream item is redundant
  FOR myCur IN c_no_rows_stim LOOP
    ln_numrows := myCur.no_rows;
  END LOOP;

    IF (ln_numrows > 0) THEN
      RAISE_APPLICATION_ERROR(-20000,'Redundant Stream Item is selected');
    END IF;
END;




PROCEDURE checkIsInStim(
   p_flag       IN VARCHAR2,
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_stream_item_id  IN VARCHAR2,
   p_product_context IN VARCHAR2)
IS

CURSOR c_no_rows_adj_stim IS
  SELECT Count(*) no_rows
  FROM fcst_product_setup
  WHERE object_id = p_object_id
  AND product_id = p_product_id
  AND product_collection_type = 'QUANTITY'
  AND product_context = p_product_context
  AND cpy_adj_stream_item_id = p_stream_item_id;

ln_numrows NUMBER;

BEGIN
   -- Check if the stream item is already a Adjust stream item
   IF p_flag = 'NORMAL' THEN
   FOR myCur IN c_no_rows_adj_stim LOOP
     ln_numrows := myCur.no_rows;
   END LOOP;

     IF (ln_numrows > 0) THEN
      RAISE_APPLICATION_ERROR(-20000,'Stream item is already a Adjustment stream item');
     END IF;
   END IF;
END;


PROCEDURE checkForecastCaseStim(
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_stream_item_id  IN VARCHAR2,
   p_product_context IN VARCHAR2)
IS
BEGIN
  checkRedundantStim(p_object_id, p_product_id, p_stream_item_id, p_product_context);
  checkIsInStim('NORMAL',p_object_id, p_product_id, p_stream_item_id, p_product_context);
  IF (ecdp_revn_forecast.chkStreamItem(p_object_id, p_product_id, p_stream_item_id,p_product_context) > 0) THEN
    RAISE_APPLICATION_ERROR(-20000,'Unique Stream item required per Field per Company per Product');
  END IF;
END;

PROCEDURE checkForecastCaseAdjStim(
   p_object_id       IN VARCHAR2,
   p_product_id      IN VARCHAR2,
   p_stream_item_id  IN VARCHAR2,
   p_product_context IN VARCHAR2)
IS
BEGIN
  checkIsInStim('ADJUSTMENT',p_object_id, p_product_id, p_stream_item_id, p_product_context);
  checkExistedStim(p_object_id, p_product_id, p_product_context);
  IF (ecdp_revn_forecast.chkStreamItem(p_object_id, p_product_id, p_stream_item_id,p_product_context) > 0) THEN
    RAISE_APPLICATION_ERROR(-20000,'Unique Stream item required per Field per Company per Product');
  END IF;
END;

PROCEDURE run_status_process(p_process_id VARCHAR2,
                      p_from_daytime DATE,
                      p_to_daytime DATE DEFAULT NULL,
                      p_field_group_id VARCHAR2,
                      p_user_id VARCHAR2 DEFAULT NULL)
IS

CURSOR c_fields IS
SELECT *
FROM field_group_setup fgs
WHERE fgs.field_group_id = p_field_group_id
AND fgs.daytime = (SELECT max(daytime) FROM field_group_setup
WHERE field_group_id = fgs.field_group_id
AND daytime <= p_from_daytime)
;

CURSOR c_stream_items(cp_field_id VARCHAR2) IS
SELECT si.*
FROM stream_item si, stream_item_version siv
WHERE
   si.object_id = siv.object_id
   AND si.start_date <= p_from_daytime
   AND si.end_date >= NVL(p_to_daytime, si.end_date - 1)
   AND siv.daytime = (SELECT max(daytime) FROM stream_item_version
                      WHERE object_id = siv.object_id AND daytime <= p_from_daytime)
   AND siv.field_id = cp_field_id
;

lv2_day_mth VARCHAR2(32);
lv2_type VARCHAR2(32);

BEGIN

    IF (INSTR(p_process_id,'APPRV_') > 0) THEN
        lv2_type := 'A';
    ELSIF (INSTR(p_process_id,'VER_') > 0) THEN
        lv2_type := 'V';
    END IF;

    IF (INSTR(p_process_id,'_DAY') > 0) THEN
        lv2_day_mth := 'DAY';
    ELSIF (INSTR(p_process_id,'_MTH') > 0) THEN
        lv2_day_mth := 'MTH';
    END IF;

    FOR Fields IN c_fields LOOP
        FOR StreamItems IN c_stream_items(Fields.Object_Id) LOOP
            IF (lv2_day_mth = 'DAY') THEN
                UPDATE stim_day_value SET record_status = lv2_type
                WHERE object_id = StreamItems.Object_Id
                AND daytime = p_from_daytime;
            ELSIF (lv2_day_mth = 'MTH') THEN
                UPDATE stim_mth_value SET record_status = lv2_type
                WHERE object_id = StreamItems.Object_Id
                AND daytime = p_from_daytime;
            END IF;
        END LOOP; -- Stream Items
    END LOOP; -- Fields
/*
   RAISE_APPLICATION_ERROR(-20000,'DEBUG: FG:' || p_field_group_id);
    -- Run the Standard Status Process
    pck_status.run_process(p_process_id, p_from_daytime, p_to_daytime, p_user_id);
*/
END run_status_process;

FUNCTION GetNode(
  p_where VARCHAR2, -- FROM_NODE, TO_NODE or AT_NODE
  p_object_id VARCHAR2,
  p_daytime DATE,
  p_attribute VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2
IS
lv2_node_id VARCHAR2(32) := NULL;
lv2_attribute VARCHAR2(240) := NULL;
BEGIN

    IF (p_where = 'FROM_NODE') THEN
        lv2_node_id := ec_strm_version.from_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    ELSIF (p_where = 'TO_NODE') THEN
        lv2_node_id := ec_strm_version.to_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
    ELSE -- AT_NODE default
        IF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'TO_NODE') THEN
            lv2_node_id := ec_strm_version.to_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
        ELSIF (ec_stream_item_version.value_point(p_object_id, p_daytime, '<=') = 'FROM_NODE') THEN
            lv2_node_id := ec_strm_version.from_node_id(ec_stream_item.stream_id(p_object_id), p_daytime, '<=');
        END IF;
    END IF;

    IF (p_attribute = 'CODE') THEN
       lv2_attribute := ec_node.object_code(lv2_node_id);
    ELSIF (p_attribute = 'NAME') THEN
       lv2_attribute := ec_node_version.name(lv2_node_id, p_daytime, '<=');
    ELSE -- Use OBJECT_ID
       lv2_attribute := lv2_node_id;
    END IF;

    RETURN lv2_attribute;

END GetNode;

PROCEDURE checkUniqueQtyFcstCase(
   p_object_id       VARCHAR2,
   p_product_id      VARCHAR2,
   p_product_context VARCHAR2,
   p_sort_order      NUMBER)
IS
  ln_numrows NUMBER;
BEGIN
   -- Check if the record already exists
   SELECT Count(*) INTO ln_numrows
   FROM fcst_product_setup
   WHERE object_id = p_object_id
   and (product_id || product_context) <> (nvl(p_product_id, 'NULL') || nvl(p_product_context, 'NULL'))
   AND product_collection_type = 'QUANTITY'
   AND sort_order = p_sort_order;

   IF (ln_numrows >= 1) THEN
     RAISE_APPLICATION_ERROR(-20602,'Sort order must be unique');
   END IF;
END;

FUNCTION GetStimDeltaValue(
  p_new_value NUMBER,
  p_old_value NUMBER,
  p_delta_value NUMBER,
  p_sum_prior_delta_value NUMBER
  )
RETURN NUMBER
IS
 ln_delta_value NUMBER;
BEGIN

     -- calculate the diff between new and old value
     IF NVL(p_new_value,'999999999') = NVL(p_old_value,'999999999') THEN
        ln_delta_value := p_delta_value;
     ELSE
        ln_delta_value := NVL(p_new_value,0) - NVL(p_sum_prior_delta_value,0);
     END IF;

    RETURN ln_delta_value;

END GetStimDeltaValue;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Procedure       : updateStreamItem                                                               --
-- Description    : The procedure does not really update the stream item formula how ever it is runned on save from different business functions
--                  that have in common that changes to the SI Formula might influence multiple records on the quantities numbers.
--                                                                                                 --
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
--                                                                                                 --
-- Using tables   :                                                                         --
--                                                                                                 --
-- Using functions:
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
PROCEDURE updateStreamItem(p_object_id             VARCHAR2,
                           p_start_date            DATE,
                           p_business_function_url VARCHAR2,
                           p_user                  VARCHAR2,
                           p_end_date              DATE DEFAULT NULL,
                           p_stim_pending_no       NUMBER DEFAULT NULL)
IS

ln_days NUMBER;
ln_months NUMBER;
ld_last_day DATE;
ld_first_day DATE;
ld_last_month DATE;
ld_first_month DATE;
ld_start_mth DATE;
ld_start_day DATE;
lv2_validFormula VARCHAR2(1) := 'Y';
lv2_business_function business_function.name%TYPE;
ln_stim_day_pend_no NUMBER;
ln_stim_mth_pend_no NUMBER;
ln_stim_fcst_mth_pend_no NUMBER;
lv2_description VARCHAR2(2000);
lv2_sysprop_runmode VARCHAR2(32);

-- Make sure that the FO-stream item still has a formula, both in si_version and stream_item_formula tables.
-- When changing calc_method from FO to fex. IP, the stream_item_formula records will not be deleted (TODO).
CURSOR c_validFormula(cp_object_id VARCHAR2, cp_start_date DATE, cp_end_date DATE) IS
SELECT 1
  FROM stream_item si, stream_item_version siv
 WHERE si.object_id = siv.object_id
   AND siv.object_id = cp_object_id
   AND siv.daytime =
       (SELECT max(siv_sub.daytime)
          FROM stream_item_version siv_sub
         WHERE siv_sub.object_id = siv.object_id
           AND siv_sub.daytime >= cp_start_date
           AND siv_sub.daytime < nvl(cp_end_date, siv_sub.daytime + 1))
   AND siv.calc_method = 'FO'
   AND (siv.stream_item_formula IS NULL OR EXISTS
        (SELECT 1
           FROM stream_item_formula sif
          WHERE sif.object_id = siv.object_id
            AND sif.daytime = siv.daytime
            AND ec_stream_item.object_code(sif.stream_item_id) IS NULL));

-- See if changed si is in use in forecast
CURSOR c_fcst(cp_stream_item_id VARCHAR2, cp_daytime DATE, cp_end_date DATE) IS
SELECT DISTINCT sfmv.forecast_id,
                sfmv.daytime,
                nvl(sfmv.calc_method,'NA') calc_method -- Using NA because Calc method on object will never be OW/SP
  FROM stim_fcst_mth_value sfmv
 WHERE sfmv.object_id = cp_stream_item_id
   AND sfmv.daytime >= cp_daytime
   AND sfmv.daytime < NVL(cp_end_date, sfmv.daytime + 1)
   AND sfmv.forecast_id NOT IN
       (SELECT fms.object_id
          FROM fcst_mth_status fms
         WHERE fms.record_status IN ('V','A'));



CURSOR c_bf IS
SELECT bf.name
  FROM business_function bf
 where bf.url = p_business_function_url;


BEGIN

lv2_sysprop_runmode := nvl(ec_ctrl_system_attribute.attribute_text(p_start_date,'CASCADE_SI_CHANGE','<='),'NA');


-- Preparing business function name
FOR cbf IN c_bf LOOP
    lv2_business_function := cbf.name;
END LOOP;

IF lv2_business_function IS NULL THEN
   lv2_business_function := 'N/A';
END IF;


  lv2_description := 'Stream item change: '||ec_stream_item.object_code(p_object_id)||' '||ec_stream_item_version.name(p_object_id,p_start_date,'<=');

  FOR c_valid IN c_validFormula(p_object_id, p_start_date, p_end_date) LOOP
     lv2_validFormula := 'N';
  END LOOP;

  IF trunc(p_start_date,'MM') < p_start_date THEN
     ld_start_mth := add_months(trunc(p_start_date,'MM'),1);
  ELSE
     ld_start_mth := p_start_date;
  END IF;

  ld_start_day := p_start_date;

  -- No need to populate records in stim_cascade_asynch table that are outdated wrg, stim-tables.
  select min(smv_min.daytime)
    into ld_first_month
    from stim_mth_value smv_min
   where smv_min.object_id = p_object_id
     and smv_min.daytime >= ld_start_mth;

  IF ld_first_month IS NOT NULL THEN
     ld_start_mth := ld_first_month;
  END IF;

  select min(sdv_min.daytime)
    into ld_first_day
    from stim_day_value sdv_min
   where sdv_min.object_id = p_object_id
     and sdv_min.daytime >= ld_start_day;

  IF ld_first_day IS NOT NULL THEN
     ld_start_day := ld_first_day;
  END IF;

  -- Handling daily/monthly dates
      select max(sdv.daytime)
       into ld_last_day
       from stim_day_value sdv
      where sdv.object_id = p_object_id
        and sdv.daytime >= ld_start_day
        and sdv.daytime < nvl(p_end_date,sdv.daytime+1);

      select max(smv.daytime)
        into ld_last_month
        from stim_mth_value smv
       where smv.object_id = p_object_id
         and smv.daytime >= ld_start_mth
         and smv.daytime < nvl(trunc(p_end_date,'MM'),smv.daytime+1);


  IF ld_last_day IS NULL THEN
     ln_days := 0;
  ELSE
     ln_days := ld_last_day - ld_start_day;
  END IF;

  IF ld_last_month IS NULL THEN
     ln_months := 0;
  ELSE
     ln_months := months_between(ld_last_month,ld_start_mth);
  END IF;


     -- Loop through every day and populate stim_pending tables
     FOR ln_counter IN 0..ln_days LOOP

         IF (nvl(ec_stim_day_value.calc_method(p_object_id,ld_start_day+ln_counter),'NA') <> 'SP' AND lv2_validFormula = 'Y') THEN

         IF lv2_sysprop_runmode <> 'NONE' THEN

            IF ln_stim_day_pend_no IS NULL THEN
                INSERT INTO stim_pending
                  (stim_pending_no,period, bf_reference, description, created_by)
                VALUES
                  (p_stim_pending_no,'DAY', lv2_business_function, lv2_description, p_user)
                RETURNING stim_pending_no INTO ln_stim_day_pend_no;
            END IF;

              INSERT INTO stim_pending_item
                (object_id,
                 daytime,
                 stim_pending_no,
                 period,
                 status_code,
                 created_by)
              VALUES
                (p_object_id,
                 ld_start_day + ln_counter,
                 ln_stim_day_pend_no,
                 'DAY',
                 'READY',
                 p_user);

         END IF;


         END IF;
     END LOOP;

     -- Loop through every month and populate stim_cascade
     FOR ln_counter IN 0..ln_months LOOP
         IF (nvl(ec_stim_mth_value.calc_method(p_object_id,add_months(ld_start_mth,ln_counter)),'NA') <> 'SP' AND lv2_validFormula = 'Y') THEN

           IF lv2_sysprop_runmode <> 'NONE' THEN

           IF ln_stim_mth_pend_no IS NULL THEN
                  INSERT INTO stim_pending
                    (stim_pending_no,period, bf_reference, description, created_by)
                  VALUES
                    (p_stim_pending_no,'MTH', lv2_business_function, lv2_description, p_user)
                  RETURNING stim_pending_no INTO ln_stim_mth_pend_no;
              END IF;

                INSERT INTO stim_pending_item
                  (object_id,
                   daytime,
                   stim_pending_no,
                   period,
                   status_code,
                   created_by)
                VALUES
                  (p_object_id,
                   add_months(ld_start_mth, ln_counter),
                   ln_stim_mth_pend_no,
                   'MTH',
                   'READY',
                   p_user);

            END IF;
         END IF;
     END LOOP;

    -- Loop through cursor and populate stim_cascade for forecast
    FOR rsFcst IN c_fcst(p_object_id, p_start_date, p_end_date) LOOP

         IF lv2_sysprop_runmode <> 'NONE' THEN

            IF ln_stim_fcst_mth_pend_no IS NULL THEN
                  INSERT INTO stim_pending
                    (stim_pending_no,
                     period,
                     bf_reference,
                     description,
                     created_by)
                  VALUES
                    (p_stim_pending_no,
                     'FCST_MTH',
                     lv2_business_function,
                     lv2_description,
                     p_user)
                  RETURNING stim_pending_no INTO ln_stim_fcst_mth_pend_no;
              END IF;

                INSERT INTO stim_pending_item
                  (object_id,
                   daytime,
                   stim_pending_no,
                   period,
                   forecast_id,
                   status_code,
                   created_by)
                VALUES
                  (p_object_id,
                   rsFcst.daytime,
                   ln_stim_fcst_mth_pend_no,
                   'FCST_MTH',
                   rsFcst.forecast_id,
                   'READY',
                   p_user);

            END IF;

    END LOOP;

END updateStreamItem;


FUNCTION GenStreamItemCopy(
   p_object_id VARCHAR2, -- to copy from
   p_code      VARCHAR2)
RETURN VARCHAR2 -- new stream item object_id
--</EC-DOC>
IS

lv2_object_id stream_item.object_id%TYPE;
lrec_stream_item stream_item%ROWTYPE;
lrec_stream_item_version stream_item_version%ROWTYPE;
lrec_stream_item_formula stream_item_formula%ROWTYPE;
-- ** 4-eyes approval stuff ** --
lv2_4e_recid VARCHAR2(32);
-- ** END 4-eyes approval stuff ** --

CURSOR c_siv(cp_object_id VARCHAR2) IS
select daytime from stream_item_version siv
where siv.object_id = cp_object_id
order by daytime ASC;

CURSOR c_sif(cp_object_id VARCHAR2, cp_daytime DATE) IS
select stream_item_id from stream_item_formula sif
where sif.object_id = cp_object_id
and sif.daytime = cp_daytime
order by daytime ASC;

BEGIN

     lrec_stream_item := ec_stream_item.row_by_object_id(p_object_id);

     -- Creating and preparing the contract and contract attributes
     lrec_stream_item.object_id := NULL;
     lrec_stream_item.object_code := Ecdp_Object_Copy.GetCopyObjectCode('STREAM_ITEM',p_code || '_COPY');
     lrec_stream_item.description := 'Copy of ' || lrec_stream_item.description;
     lrec_stream_item.record_status := NULL;
     lrec_stream_item.created_by := Nvl(EcDp_Context.getAppUser,User);
     lrec_stream_item.created_date := NULL;
     lrec_stream_item.last_updated_by :=NULL;
     lrec_stream_item.last_updated_date :=NULL;
     lrec_stream_item.rev_no :=NULL;
     lrec_stream_item.rev_text :=NULL;
     lrec_stream_item.approval_state :=NULL;
     lrec_stream_item.approval_by :=NULL;
     lrec_stream_item.approval_date :=NULL;
     lrec_stream_item_version.rec_id :=NULL;

     INSERT INTO stream_item VALUES lrec_stream_item
     RETURNING object_id INTO lv2_object_id;

     -- Loop through every day and populate stream item version
     FOR cur IN c_siv(p_object_id) LOOP

       lrec_stream_item_version := ec_stream_item_version.row_by_pk(p_object_id, cur.daytime,'<=');
       lrec_stream_item_version.record_status := NULL;
       lrec_stream_item_version.created_by := Nvl(EcDp_Context.getAppUser,User);
       lrec_stream_item_version.created_date := NULL;
       lrec_stream_item_version.last_updated_by :=NULL;
       lrec_stream_item_version.last_updated_date :=NULL;
       lrec_stream_item_version.rev_no :=NULL;
       lrec_stream_item_version.rev_text :=NULL;
       lrec_stream_item_version.approval_state :=NULL;
       lrec_stream_item_version.approval_by :=NULL;
       lrec_stream_item_version.approval_date :=NULL;
       lrec_stream_item_version.rec_id := NULL;

       lrec_stream_item_version.object_id := lv2_object_id;
       INSERT INTO stream_item_version VALUES lrec_stream_item_version;

        -- ** 4-eyes approval logic ** --
        IF NVL(EcDp_ClassMeta_Cnfg.getApprovalInd('STREAM_ITEM'),'N') = 'Y' THEN

          -- Generate rec_id for the latest version record
          lv2_4e_recid := SYS_GUID();

          -- Set approval info on latest version record.
          UPDATE stream_item_version
          SET last_updated_by = Nvl(EcDp_Context.getAppUser,User),
              last_updated_date = Ecdp_Timestamp.getCurrentSysdate,
              approval_state = 'N',
              rec_id = lv2_4e_recid,
              rev_no = (nvl(rev_no,0) + 1)
          WHERE object_id = lv2_object_id
          AND daytime = cur.daytime;

          -- Register version record for approval
          Ecdp_Approval.registerTaskDetail(lv2_4e_recid,
                                            'STREAM_ITEM',
                                            Nvl(EcDp_Context.getAppUser,User));
        END IF;
        -- ** END 4-eyes approval ** --

        IF lrec_stream_item_version.stream_item_formula IS NOT NULL THEN
        --copying stream item formula
         FOR cur2 IN c_sif(p_object_id,cur.daytime) LOOP
             lrec_stream_item_formula := ec_stream_item_formula.row_by_pk(p_object_id, cur2.stream_item_id, cur.daytime,'<=');
             lrec_stream_item_formula.object_id := lv2_object_id;
             lrec_stream_item_formula.record_status := NULL;
             lrec_stream_item_formula.created_by := Nvl(EcDp_Context.getAppUser,User);
             lrec_stream_item_formula.created_date := NULL;
             lrec_stream_item_formula.last_updated_by :=NULL;
             lrec_stream_item_formula.last_updated_date :=NULL;
             lrec_stream_item_formula.rev_no :=NULL;
             lrec_stream_item_formula.rev_text :=NULL;
             lrec_stream_item_formula.approval_state :=NULL;
             lrec_stream_item_formula.approval_by :=NULL;
             lrec_stream_item_formula.approval_date :=NULL;
             lrec_stream_item_formula.rec_id := SYS_GUID();

             INSERT INTO stream_item_formula VALUES lrec_stream_item_formula;
         END LOOP;

        END IF;

     END LOOP;

      IF (NVL(EcDp_ClassMeta_Cnfg.getAccessControlInd('STREAM_ITEM'),'N') = 'Y') THEN
             EcDp_Acl.RefreshObject(lv2_object_id, 'STREAM_ITEM', 'INSERTING');
      END IF;

     RETURN ec_stream_item.object_code(lv2_object_id);

END GenStreamItemCopy;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : IsIntergroupConversionValid
-- Description    : Validate the inter-group conversion factor configuration
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
--
---------------------------------------------------------------------------------------------------
PROCEDURE IsIntergroupConversionValid(p_density            NUMBER,
                                     p_density_mass_uom   VARCHAR2,
                                     p_density_volume_uom VARCHAR2,
                                     p_gcv                NUMBER,
                                     p_gcv_energy_uom     VARCHAR2,
                                     p_gcv_volume_uom     VARCHAR2,
                                     p_mcv                NUMBER,
                                     p_mcv_energy_uom     VARCHAR2,
                                     p_mcv_mass_uom       VARCHAR2)


--</EC-DOC>
IS

uncomplete_conversion EXCEPTION;
lv2_type VARCHAR2(32);

BEGIN

  IF p_density IS NOT NULL OR p_density_mass_uom IS NOT NULL OR p_density_volume_uom IS NOT NULL THEN
     IF p_density IS NULL OR p_density_mass_uom IS NULL OR p_density_volume_uom IS NULL THEN
        lv2_type := 'Density';
        Raise uncomplete_conversion;
     END IF;
  END IF;

  IF p_gcv IS NOT NULL OR p_gcv_energy_uom IS NOT NULL OR p_gcv_volume_uom IS NOT NULL THEN
     IF p_gcv IS NULL OR p_gcv_energy_uom IS NULL OR p_gcv_volume_uom IS NULL THEN
        lv2_type := 'GCV';
        Raise uncomplete_conversion;
     END IF;
  END IF;

  IF p_mcv IS NOT NULL OR p_mcv_energy_uom IS NOT NULL OR p_mcv_mass_uom IS NOT NULL THEN
     IF p_mcv IS NULL OR p_mcv_energy_uom IS NULL OR p_mcv_mass_uom IS NULL THEN
        lv2_type := 'MCV';
        Raise uncomplete_conversion;
     END IF;
  END IF;





EXCEPTION

         WHEN uncomplete_conversion THEN

              Raise_Application_Error(-20000,'Incomplete '||lv2_type|| ' configuration');


END IsIntergroupConversionValid;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : InsertUpdateIUCVersion
-- Description    :
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
--
---------------------------------------------------------------------------------------------------
PROCEDURE InsertUpdateIUCVersion(p_class_name VARCHAR2,
                           p_object_id  VARCHAR2,
                           p_daytime    DATE,
                           p_user       VARCHAR2)


--</EC-DOC>
IS
BEGIN

  IF p_class_name = 'PRODUCT_FIELD' OR p_class_name = 'PRODUCT_FIELD_BOE' THEN
      InsertUpdateIUCFieldVersion(p_object_id,p_daytime,p_user);
      ELSIF p_class_name = 'PRODUCT_COUNTRY' OR p_class_name = 'PRODUCT_COUNTRY_BOE' THEN
       InsertUpdateIUCCountryVersion(p_object_id,p_daytime,p_user);
        ELSIF p_class_name = 'PRODUCT_NODE' OR p_class_name = 'PRODUCT_NODE_BOE' THEN
         InsertUpdateIUCNodeVersion(p_object_id,p_daytime,p_user);
  END IF;


END InsertUpdateIUCVersion;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : InsertUpdateIUCFieldVersion
-- Description    :
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
--
---------------------------------------------------------------------------------------------------
PROCEDURE InsertUpdateIUCFieldVersion(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)


--</EC-DOC>
IS

CURSOR c_version IS
SELECT daytime, end_date
  FROM product_field_version pf
 WHERE pf.object_id = p_object_id
   AND pf.daytime = (SELECT MAX(v.daytime)
                       FROM product_field_version v
                      WHERE v.object_id = pf.object_id);

version_exists EXCEPTION;

BEGIN


FOR val IN c_version LOOP

   -- Existing version
   IF val.daytime >= p_daytime OR NVL(val.end_date,p_daytime-1) > p_daytime THEN
     RAISE version_exists;
     END IF;


   IF val.end_date IS NULL THEN

      UPDATE product_field_version v
         SET v.end_date = p_daytime, v.last_updated_by = p_user
       WHERE v.object_id = p_object_id
         AND v.daytime = val.daytime;

     END IF;


    END LOOP;

     EXCEPTION

         WHEN version_exists THEN
              Raise_Application_Error(-20000,'Daytime is already present');


END InsertUpdateIUCFieldVersion;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : InsertUpdateIUCCountryVersion
-- Description    :
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
--
---------------------------------------------------------------------------------------------------
PROCEDURE InsertUpdateIUCCountryVersion(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)


--</EC-DOC>
IS

CURSOR c_version IS
SELECT daytime, end_date
  FROM product_country_version pc
 WHERE pc.object_id = p_object_id
   AND pc.daytime = (SELECT MAX(v.daytime)
                       FROM product_country_version v
                      WHERE v.object_id = pc.object_id);

version_exists EXCEPTION;

BEGIN


FOR val IN c_version LOOP

   -- Existing version
   IF val.daytime >= p_daytime OR NVL(val.end_date,p_daytime-1) > p_daytime THEN
     RAISE version_exists;
     END IF;


   IF val.end_date IS NULL THEN

      UPDATE product_country_version v
         SET v.end_date = p_daytime, v.last_updated_by = p_user
       WHERE v.object_id = p_object_id
         AND v.daytime = val.daytime;

     END IF;


    END LOOP;

     EXCEPTION

         WHEN version_exists THEN
              Raise_Application_Error(-20000,'Daytime is already present');


END InsertUpdateIUCCountryVersion;



--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : InsertUpdateIUCNodeVersion
-- Description    :
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
--
---------------------------------------------------------------------------------------------------
PROCEDURE InsertUpdateIUCNodeVersion(p_object_id VARCHAR2, p_daytime DATE, p_user VARCHAR2)


--</EC-DOC>
IS

CURSOR c_version IS
SELECT daytime, end_date
  FROM product_node_version pn
 WHERE pn.object_id = p_object_id
   AND pn.daytime = (SELECT MAX(v.daytime)
                       FROM product_node_version v
                      WHERE v.object_id = pn.object_id);

version_exists EXCEPTION;

BEGIN


FOR val IN c_version LOOP

   -- Existing version
   IF val.daytime >= p_daytime OR NVL(val.end_date,p_daytime-1) > p_daytime THEN
     RAISE version_exists;
     END IF;


   IF val.end_date IS NULL THEN

      UPDATE product_node_version v
         SET v.end_date = p_daytime, v.last_updated_by = p_user
       WHERE v.object_id = p_object_id
         AND v.daytime = val.daytime;

     END IF;


    END LOOP;

     EXCEPTION

         WHEN version_exists THEN
              Raise_Application_Error(-20000,'Daytime is already present');


END InsertUpdateIUCNodeVersion;

PROCEDURE deleteExistingSIFormula (
          p_stream_item_id VARCHAR2,
          p_daytime DATE)
IS
BEGIN

  DELETE FROM stream_item_formula
   WHERE object_id = p_stream_item_id
     AND (daytime = p_daytime OR
         daytime NOT IN
         (SELECT daytime
             FROM stream_item_version
            WHERE object_id = p_stream_item_id));

END deleteExistingSIFormula;


PROCEDURE deleteExistingSIFCSTFormula(p_forecast_id    VARCHAR2,
                                      p_stream_item_id VARCHAR2,
                                      p_daytime        DATE)
IS
BEGIN

  DELETE FROM stim_fcst_formula
   WHERE object_id = p_stream_item_id
     AND forecast_id = nvl(p_forecast_id, 'GENERAL_FCST_FORMULA')
     AND (daytime = p_daytime OR
         daytime NOT IN
         (SELECT daytime
             FROM stim_fcst_setup
            WHERE object_id = p_stream_item_id
              AND nvl(forecast_id, 'NA') = nvl(p_forecast_id, 'NA')));

END deleteExistingSIFCSTFormula;



PROCEDURE insertSIFormula (
          p_stream_item_id VARCHAR2,
          p_formula_si_id  VARCHAR2,
          p_daytime        DATE,
          p_user           VARCHAR2)
IS

CURSOR cChk (cp_stream_item_id VARCHAR2, cp_formula_si_id VARCHAR2, cp_daytime DATE  ) IS
       SELECT * FROM stream_item_formula fo
       WHERE fo.object_id = cp_stream_item_id
       AND fo.stream_item_id = cp_formula_si_id
       AND fo.daytime = cp_daytime;

lb_exists BOOLEAN := FALSE;

BEGIN

  FOR rsChk IN cChk(p_stream_item_id, p_formula_si_id, p_daytime) LOOP
      lb_exists := TRUE;
  END LOOP;

  BEGIN

    IF NOT lb_exists THEN
      INSERT INTO stream_item_formula (object_id, stream_item_id, daytime, created_by)
      VALUES (p_stream_item_id, p_formula_si_id, p_daytime, p_user);
    END IF;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
         NULL;
  END;

END insertSIFormula;



PROCEDURE populateSIFormula(
   p_calc_method VARCHAR2, -- SK or FO
   p_daytime     DATE,
   p_user        VARCHAR2,
   p_stream_item_id VARCHAR2 DEFAULT NULL -- If you want to do this on only one SI
   )

IS

CURSOR c_SI IS
  SELECT si.object_id, siv.daytime, siv.stream_item_formula
    FROM stream_item si, stream_item_version siv
   WHERE si.object_id = siv.object_id
     AND siv.daytime = (SELECT MAX(daytime)
                          FROM stream_item_version
                         WHERE object_id = si.object_id
                           AND daytime <= p_daytime)
     AND siv.stream_item_formula IS NOT NULL
     AND siv.calc_method = p_calc_method
     AND si.object_id = nvl(p_stream_item_id, si.object_id);

lv2_si_code VARCHAR2(32);
lv2_si_id   VARCHAR2(32);
lv2_formula stream_item_version.stream_item_formula%TYPE;
ln_si_count NUMBER;
ln_count    INT;
ln_this     INT;
ln_last     INT;

BEGIN

  FOR rsSI IN c_SI LOOP

     lv2_formula := rsSI.Stream_Item_Formula;

     IF INSTR(lv2_formula, '+') > 0 OR
        INSTR(lv2_formula, '-') > 0 OR
        INSTR(lv2_formula, '/') > 0 OR
        INSTR(lv2_formula, '*') > 0 THEN

        deleteExistingSIFormula(rsSI.Object_Id, rsSI.Daytime);

        -- Replace operators with semicolons and remove space and paranthesis
        lv2_formula := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lv2_formula,'+',';'),'-',';'),'/',';'),'*',';'),'(',''),')',''),' ','') || ';';

        -- How many stream items are in the formula?
        ln_si_count := LENGTH(REPLACE(lv2_formula, ';', ';' || ' ')) - LENGTH(lv2_formula);

        ln_count := 1;
        ln_last := 0;

        WHILE ln_count <= ln_si_count LOOP

              ln_this := instr(lv2_formula, ';', 1, ln_count);

              -- Get the Stream Item code
              lv2_si_code := trim(substr(lv2_formula, ln_last + 1, ln_this - ln_last -1));

              -- Verify a valid Stream Item
              lv2_si_id := ec_stream_item.object_id_by_uk(lv2_si_code);

              IF lv2_si_id IS NOT NULL THEN

                 insertSIFormula(rsSI.Object_Id, lv2_si_id, rsSI.Daytime, p_user);

              ELSE
                -- Unidentified part of formula
                NULL;
                /*IF lv2_si_code IS NOT NULL THEN
                   Raise_Application_Error(-20000,'Failed to identify formula');
                END IF;*/

              END IF;

              -- Go to next SI
              ln_count := ln_count + 1;
              ln_last := ln_this;

        END LOOP;


     ELSE
        -- Assuming only one stream item in formula. If not a valid SI Code, nothing is inserted.
        lv2_si_id := ec_stream_item.object_id_by_uk(lv2_formula);

        IF lv2_si_id IS NOT NULL THEN

           deleteExistingSIFormula(rsSI.Object_Id, rsSI.Daytime);

           insertSIFormula(rsSI.Object_Id, lv2_si_id, rsSI.Daytime, p_user);

           ELSE
                -- Unidentified part of formula
                   --Raise_Application_Error(-20000,'Failed to identify formula');
                   NULL;


        END IF;

     END IF;


  END LOOP;

  -- Cleanup if changing from formula CM to non-formula CM
  IF  p_calc_method NOT IN ('SK','FO') THEN
      DELETE stream_item_formula s
       WHERE s.object_id = p_stream_item_id
         AND s.daytime = p_daytime;
     END IF;

END populateSIFormula;



PROCEDURE populateFcstSIFormula(p_object_id      VARCHAR2,
                                p_forecast_id         VARCHAR2,
                                p_daytime             DATE,
                                p_user                VARCHAR2)

IS

lv2_formula stream_item_version.stream_item_formula%type;
lv2_calc_method stream_item_version.calc_method%type;
lv2_si_code VARCHAR2(32);
lv2_si_id   VARCHAR2(32);
ln_si_count NUMBER;
ln_count    INT;
ln_this     INT;
ln_last     INT;

BEGIN


lv2_formula := ecdp_revn_forecast.Getstreamitemattribute(nvl(p_forecast_id,'GENERAL_FCST_FORMULA'),p_object_id,p_daytime,'STREAM_ITEM_FORMULA');
lv2_calc_method := ecdp_revn_forecast.Getstreamitemattribute(nvl(p_forecast_id,'GENERAL_FCST_FORMULA'),p_object_id,p_daytime,'CALC_METHOD');

     IF INSTR(lv2_formula, '+') > 0 OR
        INSTR(lv2_formula, '-') > 0 OR
        INSTR(lv2_formula, '/') > 0 OR
        INSTR(lv2_formula, '*') > 0 THEN

        deleteExistingSIFCSTFormula(p_forecast_id,p_object_id, p_daytime);

        -- Replace operators with semicolons and remove space and paranthesis
        lv2_formula := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lv2_formula,'+',';'),'-',';'),'/',';'),'*',';'),'(',''),')',''),' ','') || ';';

        -- How many stream items are in the formula?
        ln_si_count := LENGTH(REPLACE(lv2_formula, ';', ';' || ' ')) - LENGTH(lv2_formula);

        ln_count := 1;
        ln_last := 0;

        WHILE ln_count <= ln_si_count LOOP

              ln_this := instr(lv2_formula, ';', 1, ln_count);

              -- Get the Stream Item code
              lv2_si_code := trim(substr(lv2_formula, ln_last + 1, ln_this - ln_last -1));

              -- Verify a valid Stream Item
              lv2_si_id := ec_stream_item.object_id_by_uk(lv2_si_code);

              IF lv2_si_id IS NOT NULL THEN
                 updateStimFcstFormula(p_object_id,lv2_si_id,p_forecast_id,p_daytime,p_user);

               ELSE
                -- Unidentified part of formula
                NULL;
                /*IF lv2_si_code IS NOT NULL THEN
                   Raise_Application_Error(-20000,'Failed to identify formula');
                END IF;  */


              END IF;

              -- Go to next SI
              ln_count := ln_count + 1;
              ln_last := ln_this;

        END LOOP;


     ELSE
        -- Assuming only one stream item in formula. If not a valid SI Code, nothing is inserted.
        lv2_si_id := ec_stream_item.object_id_by_uk(lv2_formula);

        IF lv2_si_id IS NOT NULL THEN

           deleteExistingSIFCSTFormula(p_forecast_id,p_object_id, p_daytime);
           updateStimFcstFormula(p_object_id,lv2_si_id,p_forecast_id,p_daytime,p_user);


           ELSE
                -- Unidentified part of formula
                NULL;
                /*Raise_Application_Error(-20000,'Failed to identify formula');*/

        END IF;

     END IF;


     -- Cleanup if changing from formula CM to non-formula CM
  IF  lv2_calc_method NOT IN ('SK','FO') THEN
     DELETE stim_fcst_formula s
      WHERE s.object_id = p_object_id
        AND forecast_id = nvl(p_forecast_id,'GENERAL_FCST_FORMULA')
        AND s.daytime = p_daytime;
     END IF;


END populateFcstSIFormula;





PROCEDURE updateStimFcstFormula(p_object_id      VARCHAR2,
                                p_stream_item_id VARCHAR2,
                                p_forecast_id    VARCHAR2,
                                p_daytime          DATE,
                                p_user           VARCHAR2)


IS
BEGIN

INSERT INTO stim_fcst_formula
  (object_id, stream_item_id, forecast_id, daytime, last_updated_by)
VALUES
  (p_object_id,
   p_stream_item_id,
   nvl(p_forecast_id, 'GENERAL_FCST_FORMULA'),
   p_daytime,
   p_user);


END updateStimFcstFormula;

PROCEDURE updAccrualToFinal(p_object_id     VARCHAR2,
                           p_daytime        DATE,
                           p_type           VARCHAR2,
                           p_user           VARCHAR2)
IS

CURSOR c_day_list (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT object_id, daytime
FROM stim_day_value smv
WHERE smv.status = 'ACCRUAL'
AND smv.daytime BETWEEN cp_daytime AND cp_daytime + 1
AND smv.daytime <> cp_daytime + 1
AND smv.object_id in (select stream_item_id from stim_collection_setup where object_id = cp_object_id)
AND nvl(smv.calc_method,ec_stream_item_version.calc_method(smv.object_id,smv.daytime,'<=')) in ('IP','DE','OW','SP');

CURSOR c_day_node (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT object_id, daytime
FROM stim_day_value smv
WHERE smv.status = 'ACCRUAL'
AND smv.daytime BETWEEN cp_daytime AND cp_daytime + 1
AND smv.daytime <> cp_daytime + 1
AND smv.object_id in (select object_id from stream_item where stream_id = cp_object_id)
AND nvl(smv.calc_method,ec_stream_item_version.calc_method(smv.object_id,smv.daytime,'<=')) in ('IP','DE','OW','SP');

CURSOR c_mth_list (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT object_id, daytime
FROM stim_mth_value smv
WHERE smv.status = 'ACCRUAL'
AND smv.daytime BETWEEN cp_daytime AND last_day(cp_daytime)
AND smv.daytime <> last_day(cp_daytime)
AND smv.object_id in (select stream_item_id from stim_collection_setup where object_id = cp_object_id)
AND nvl(smv.calc_method,ec_stream_item_version.calc_method(smv.object_id,smv.daytime,'<=')) in ('IP','DE','OW','SP');

CURSOR c_mth_node (cp_object_id VARCHAR2, cp_daytime DATE) IS
SELECT object_id, daytime
FROM stim_mth_value smv
WHERE smv.status = 'ACCRUAL'
AND smv.daytime BETWEEN cp_daytime AND last_day(cp_daytime)
AND smv.daytime <> last_day(cp_daytime)
AND smv.object_id in (select object_id from stream_item where stream_id = cp_object_id)
AND nvl(smv.calc_method,ec_stream_item_version.calc_method(smv.object_id,smv.daytime,'<=')) in ('IP','DE','OW','SP');


BEGIN

   IF p_type = 'DAILY_LIST_INPUT' THEN

      FOR r_si IN c_day_list(p_object_id, p_daytime) LOOP

          UPDATE stim_day_value SET status = 'FINAL', last_updated_by = p_user
          WHERE object_id = r_si.object_id AND daytime = r_si.daytime;

          INSERT INTO stim_cascade (object_id,period,daytime) VALUES (r_si.object_id, 'DAY', r_si.daytime);

      END LOOP;

   ELSIF p_type = 'DAILY_NODE_INPUT' THEN

      FOR r_si IN c_day_node(p_object_id, p_daytime) LOOP

          UPDATE stim_day_value SET status = 'FINAL', last_updated_by = p_user
          WHERE object_id = r_si.object_id AND daytime = r_si.daytime;

          INSERT INTO stim_cascade (object_id,period,daytime) VALUES (r_si.object_id, 'DAY', r_si.daytime);

      END LOOP;

   ELSIF p_type = 'MONTHLY_LIST_INPUT' THEN

      FOR r_si IN c_mth_list(p_object_id, p_daytime) LOOP

          UPDATE stim_mth_value SET status = 'FINAL', last_updated_by = p_user
          WHERE object_id = r_si.object_id AND daytime = r_si.daytime;

          INSERT INTO stim_cascade (object_id,period,daytime) VALUES (r_si.object_id, 'MTH', r_si.daytime);

      END LOOP;

   ELSIF  p_type = 'MONTHLY_NODE_INPUT' THEN

       FOR r_si IN c_mth_node(p_object_id, p_daytime) LOOP

          UPDATE stim_mth_value SET status = 'FINAL', last_updated_by = p_user
          WHERE object_id = r_si.object_id AND daytime = r_si.daytime;

          INSERT INTO stim_cascade (object_id,period,daytime) VALUES (r_si.object_id, 'MTH', r_si.daytime);

      END LOOP;

   ELSE

      null;

   END IF;

END updAccrualToFinal;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetConversionFactorValue                                                                --
-- Description
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION GetConversionFactorValue(p_object_id VARCHAR2,
                                  p_daytime   DATE,
                                  p_type      VARCHAR2)

 RETURN NUMBER

  --<EC-DOC>

 IS

BEGIN

  FOR cv IN gc_factors(p_object_id, p_daytime) LOOP

    IF p_type = 'DENSITY' THEN
      RETURN cv.density;
    ELSIF p_type = 'GCV' THEN
      RETURN cv.gcv;
    ELSIF p_type = 'MCV' THEN
      RETURN cv.mcv;
    ELSIF p_type = 'BOE' THEN
      RETURN cv.boe_factor;
    END IF;

  END LOOP;

  RETURN NULL;

END GetConversionFactorValue;


--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : GetConversionFactorUom                                                                --
-- Description
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION GetConversionFactorUom(p_object_id VARCHAR2,
                                p_daytime   DATE,
                                p_type      VARCHAR2,
                                p_subtype   VARCHAR2) RETURN VARCHAR2
--<EC-DOC>
 IS

BEGIN

  FOR cv IN gc_factors(p_object_id, p_daytime) LOOP

    IF p_type = 'DENSITY' THEN
      IF p_subtype = 'VOLUME' THEN

        RETURN cv.density_volume_uom;

      ELSIF p_subtype = 'MASS' THEN

        RETURN cv.density_mass_uom;

      END IF;

    ELSIF p_type = 'GCV' THEN

      IF p_subtype = 'VOLUME' THEN

        RETURN cv.gcv_volume_uom;

      ELSIF p_subtype = 'ENERGY' THEN

        RETURN cv.gcv_energy_uom;

      END IF;
    ELSIF p_type = 'MCV' THEN

      IF p_subtype = 'MASS' THEN

        RETURN cv.mcv_mass_uom;

      ELSIF p_subtype = 'ENERGY' THEN

        RETURN cv.mcv_energy_uom;

      END IF;

    ELSE

      IF p_subtype = 'FROM' THEN

        RETURN cv.boe_from_uom;

      ELSIF p_subtype = 'TO' THEN

        RETURN cv.boe_to_uom;

      END IF;

    END IF;

  END LOOP;

  RETURN NULL;

END GetConversionFactorUom;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getConversionFactorValue                                                       --
-- Description    Used from CascadeBusinessAction
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getConversionFactorValue(p_stream_item_id VARCHAR2, p_source_id VARCHAR2, p_daytime DATE, p_source_type VARCHAR2, p_value NUMBER)
  RETURN NUMBER
--<EC-DOC>
IS

l_ConvFact t_conversion;


BEGIN
   -- Ensure source ids are not reset if values have been manually input
   IF nvl(p_source_id,'XX') = 'XX' and p_value IS NOT NULL THEN
     RETURN p_value;
   END IF;

   IF p_source_type = 'DENSITY' THEN
     l_ConvFact := GetDefDensity(p_stream_item_id, p_daytime);
     return l_ConvFact.factor;

   END IF;

   IF p_source_type = 'GCV' THEN
     l_ConvFact := GetDefGCV(p_stream_item_id, p_daytime);
     return l_ConvFact.factor;
   END IF;

   IF p_source_type = 'MCV' THEN
     l_ConvFact := GetDefMCV(p_stream_item_id, p_daytime);
     return l_ConvFact.factor;
   END IF;

   IF p_source_type = 'BOE' THEN
     l_ConvFact := GetDefBOE(p_stream_item_id, p_daytime);
     return l_ConvFact.factor;
   END IF;

   RETURN NULL;

END getConversionFactorValue;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getConversionFactorUOM                                                         --
-- Description    Used from CascadeBusinessAction
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getConversionFactorUOM(p_stream_item_id VARCHAR2,
                                p_source_id      VARCHAR2,
                                p_daytime        DATE,
                                p_source_type    VARCHAR2,
                                p_value          NUMBER,
                                p_uom_type       VARCHAR) RETURN VARCHAR2
--<EC-DOC>
IS

l_ConvFact t_conversion;

BEGIN

   IF p_source_type = 'DENSITY' THEN
     l_ConvFact := GetDefDensity(p_stream_item_id, p_daytime);

     IF p_uom_type = 'FROM_UOM' THEN
       RETURN l_ConvFact.from_uom;
     ELSIF p_uom_type = 'TO_UOM' THEN
       RETURN l_ConvFact.to_uom;
     END IF;

   END IF;

   IF p_source_type = 'GCV' THEN
     l_ConvFact := GetDefGCV(p_stream_item_id, p_daytime);

     IF p_uom_type = 'FROM_UOM' THEN
       RETURN l_ConvFact.from_uom;
     ELSIF p_uom_type = 'TO_UOM' THEN
       RETURN l_ConvFact.to_uom;
     END IF;

   END IF;

   IF p_source_type = 'MCV' THEN
     l_ConvFact := GetDefMCV(p_stream_item_id, p_daytime);

     IF p_uom_type = 'FROM_UOM' THEN
       RETURN l_ConvFact.from_uom;
     ELSIF p_uom_type = 'TO_UOM' THEN
       RETURN l_ConvFact.to_uom;
     END IF;

   END IF;

   IF p_source_type = 'BOE' THEN
     l_ConvFact := GetDefBOE(p_stream_item_id, p_daytime);

     IF p_uom_type = 'FROM_UOM' THEN
       RETURN l_ConvFact.from_uom;
     ELSIF p_uom_type = 'TO_UOM' THEN
       RETURN l_ConvFact.to_uom;
     END IF;

   END IF;

   RETURN NULL;

END getConversionFactorUOM;

--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getConversionFactorSourceId                                                    --
-- Description    :
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getConversionFactorSourceId(p_stream_item_id VARCHAR2, p_source_id VARCHAR2, p_daytime DATE, p_source_type VARCHAR2, p_value NUMBER)
  RETURN VARCHAR2
--<EC-DOC>
IS

l_ConvFact t_conversion;
ln_factor_value NUMBER;

BEGIN
   -- Ensure source ids are not reset if values have been manually input
   IF nvl(p_source_id,'XX') = 'XX' and p_value IS NOT NULL THEN
     RETURN NULL;
   END IF;

   IF p_source_type = 'DENSITY' THEN
     l_ConvFact := GetDefDensity(p_stream_item_id, p_daytime);
     RETURN l_ConvFact.source_object_id;
   END IF;

   IF p_source_type = 'GCV' THEN
     l_ConvFact := GetDefGCV(p_stream_item_id, p_daytime);
     RETURN l_ConvFact.source_object_id;
   END IF;

   IF p_source_type = 'MCV' THEN
     l_ConvFact := GetDefMCV(p_stream_item_id, p_daytime);
     RETURN l_ConvFact.source_object_id;
   END IF;

   IF p_source_type = 'BOE' THEN
     l_ConvFact := GetDefBOE(p_stream_item_id, p_daytime);
     RETURN l_ConvFact.source_object_id;
   END IF;

   RETURN NULL;

END getConversionFactorSourceId;



--<EC-DOC>
-----------------------------------------------------------------------------------------------------
-- Function       : getNodeId                                                    --
-- Description    :
-- Preconditions  :                                                                                --
-- Postconditions :                                                                                --
-- Using tables   :
--                                                                                                 --
-- Using functions:
--                                                                                                 --
-- Configuration                                                                                   --
-- required       :                                                                                --
--                                                                                                 --
-- Behaviour      :                                                                                --
--                                                                                                 --
-----------------------------------------------------------------------------------------------------
FUNCTION getNodeId(p_object_id VARCHAR2, p_daytime DATE) RETURN VARCHAR2

 IS

  lv2_value_point  VARCHAR2(32);
  lv2_stream_id    stream.object_id%TYPE;
  lv2_to_node_id   node.object_id%TYPE;
  lv2_from_node_id node.object_id%TYPE;

BEGIN

  lv2_stream_id    := ec_stream_item.stream_id(p_object_id);
  lv2_value_point  := ec_stream_item_version.value_point(p_object_id, p_daytime, '<=');
  lv2_from_node_id := ec_strm_version.from_node_id(lv2_stream_id, p_daytime, '<=');
  lv2_to_node_id   := ec_strm_version.to_node_id(lv2_stream_id, p_daytime, '<=');

IF lv2_value_point = 'TO_NODE' THEN
   RETURN lv2_to_node_id;
ELSIF
lv2_value_point = 'FROM_NODE' THEN
 RETURN lv2_from_node_id;
ELSE
  RETURN NULL;

END IF;

END getNodeId;

FUNCTION ApplyRounding(p_value NUMBER, p_rounding NUMBER)
  RETURN NUMBER IS
BEGIN
  IF(p_rounding IS NULL) THEN
    RETURN p_value;
  ELSE
    RETURN ROUND(p_value, p_rounding);
  END IF;

END ApplyRounding;
-----------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- Function       : GetSplitShareMthPC
-- Description    : Get PC split share from respective stream item.
-- Using tables   : SPLIT_KEY_SETUP,STIM_MTH_VALUE
-- Behaviour      : Called to get PC split share when FULL configured using stream item having Dist Source Split Type as SOURCE_SPLIT contract is interfaced at Transaction level.
-------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
FUNCTION GetSplitShareMthPC(p_split_key VARCHAR2
                        ,p_source_member_id VARCHAR2
                        ,p_processing_period DATE
                        ) RETURN NUMBER

IS
lv_sum_share NUMBER;
lv_share NUMBER;

BEGIN

SELECT SUM(NVL(smv.net_mass_value,0)) INTO lv_sum_share
FROM SPLIT_KEY_SETUP sks,STIM_MTH_VALUE smv
WHERE sks.OBJECT_ID=p_split_key
AND sks.source_member_id=smv.object_id
AND smv.daytime =(SELECT max(daytime)
                  FROM STIM_MTH_VALUE
                  WHERE object_id = sks.source_member_id
                  AND daytime <= p_processing_period);

IF(lv_sum_share<>0) THEN
lv_share:=NVL(ec_stim_mth_value.net_mass_value(p_source_member_id,p_processing_period,'<='),0)/lv_sum_share;
RETURN lv_share;
ELSE
RETURN NULL;
END IF;

END GetSplitShareMthPC;

END EcDp_Stream_Item;