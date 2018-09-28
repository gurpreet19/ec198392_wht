/* Formatted on 11/20/2013 12:33:54 PM (QP5 v5.226.12202.30050) */
CREATE OR REPLACE FORCE VIEW cv_base_business_defer
(
   field,
   surf_subsurf,
   event_system_text,
   event_category_text,
   event_reason_text,
   proact_react,
   v_year,
   v_month,
   oil_prod_loss_event_bbls_mtd,
   gas_prod_loss_event_mscf_mtd
)
AS
     SELECT ec_well_version.geo_field_code (object_id, d.daytime, '<='),
            ec_prosty_codes.alt_code (reason_code_1, 'DEFER_SYS_GRP'),
            ec_prosty_codes.code_text (reason_code_1, 'DEFER_SYS_GRP'),
            ec_prosty_codes.code_text (reason_code_2, 'DEFER_CAUSE_GRP'),
            ec_prosty_codes.code_text (reason_code_3, 'DEFER_CAUSE_CAT'),
            ec_prosty_codes.alt_code (reason_code_2, 'DEFER_CAUSE_GRP'),
            TO_CHAR (s.daytime, 'YYYY'),
            RTRIM (TO_CHAR (s.daytime, 'MONTH')),
            SUM (ue_ct_well_deferment.calclossbyday (event_no,
                                                         d.daytime,
                                                         s.daytime,
                                                         'OIL',
                                                         'P')),
            SUM (ue_ct_well_deferment.calclossbyday (event_no,
                                                         d.daytime,
                                                         s.daytime,
                                                         'GAS',
                                                         'P'))
       FROM DEFERMENT_EVENT d, system_days s
      --
      --Get Parent events
      --
      WHERE     s.daytime >= TRUNC (d.daytime - 1)
            AND (s.daytime <= TRUNC (d.end_date) OR d.end_date IS NULL)
            AND event_type = 'DOWN'
            AND deferment_type != 'GROUP_CHILD'
   GROUP BY ec_well_version.geo_field_code (object_id, d.daytime, '<='),
            TO_CHAR (s.daytime, 'YYYY'),
            RTRIM (TO_CHAR (s.daytime, 'MONTH')),
            ec_prosty_codes.alt_code (reason_code_1, 'DEFER_SYS_GRP'),
            ec_prosty_codes.alt_code (reason_code_2, 'DEFER_CAUSE_GRP'),
            ec_prosty_codes.code_text (reason_code_1, 'DEFER_SYS_GRP'),
            ec_prosty_codes.code_text (reason_code_2, 'DEFER_CAUSE_GRP'),
            ec_prosty_codes.code_text (reason_code_3, 'DEFER_CAUSE_CAT')
   UNION ALL
     --
     --Get Child events
     --
     SELECT ec_well_version.geo_field_code (object_id, d.daytime, '<='),
            ec_prosty_codes.alt_code (reason_code_1, 'DEFER_SYS_GRP'),
            ec_prosty_codes.code_text (reason_code_1, 'DEFER_SYS_GRP'),
            ec_prosty_codes.code_text (reason_code_2, 'DEFER_CAUSE_GRP'),
            ec_prosty_codes.code_text (reason_code_3, 'DEFER_CAUSE_CAT'),
            ec_prosty_codes.alt_code (reason_code_2, 'DEFER_CAUSE_GRP'),
            TO_CHAR (s.daytime, 'YYYY'),
            RTRIM (TO_CHAR (s.daytime, 'MONTH')),
            SUM (ue_ct_well_deferment.calclossbyday (event_no,
                                                         d.daytime,
                                                         s.daytime,
                                                         'OIL',
                                                         'P')),
            SUM (ue_ct_well_deferment.calclossbyday (event_no,
                                                         d.daytime,
                                                         s.daytime,
                                                         'GAS',
                                                         'P'))
       FROM DEFERMENT_EVENT d, system_days s
      WHERE     s.daytime >= TRUNC (d.daytime - 1)
            AND (s.daytime <= TRUNC (d.end_date) OR d.end_date IS NULL)
            AND event_type = 'DOWN'
            AND deferment_type = 'GROUP_CHILD'
            AND ecdp_well.iswellproducer (object_id, s.daytime) = 'Y'
   GROUP BY ec_well_version.geo_field_code (object_id, d.daytime, '<='),
            TO_CHAR (s.daytime, 'YYYY'),
            RTRIM (TO_CHAR (s.daytime, 'MONTH')),
            ec_prosty_codes.alt_code (reason_code_1, 'DEFER_SYS_GRP'),
            ec_prosty_codes.alt_code (reason_code_2, 'DEFER_CAUSE_GRP'),
            ec_prosty_codes.code_text (reason_code_1, 'DEFER_SYS_GRP'),
            ec_prosty_codes.code_text (reason_code_2, 'DEFER_CAUSE_GRP'),
            ec_prosty_codes.code_text (reason_code_3, 'DEFER_CAUSE_CAT');
