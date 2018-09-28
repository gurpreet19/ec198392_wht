/******************************************************************************************************
** Fixing viewhidden property
** - make unhidden when it was customized in old system
** + caused by not able to compare removed viewhidden=true which is the same as viewhidden=false
******************************************************************************************************/
merge into class_attr_property_cnfg trg
using  ( select class_name, attribute_name, property_code, 3000 owner_cntx, presentation_cntx, property_type, 'false' property_value
         from   class_attr_property_cnfg u
         where  property_code  = 'viewhidden'
         and    property_value = 'true'
         and    property_type  = 'STATIC_PRESENTATION' 
         and    owner_cntx     = 0
         and    not exists ( select 'X'
                             from   class_attr_property_cnfg c
                             where  u.class_name     = c.class_name
                             and    u.attribute_name = c.attribute_name
                             and    u.property_code  = c.property_code
                             and    c.owner_cntx     = 3000
                             and    c.property_value = 'false'
                           )
         and    exists ( select 'X'
                         from   u_class_attr_property_cnfg ootb_src
                         where  u.class_name            = ootb_src.class_name
                         and    u.attribute_name        = ootb_src.attribute_name
                         and    u.property_code         = ootb_src.property_code
                         and    ootb_src.owner_cntx     = -100
                         and    ootb_src.property_value = 'true'
                         union
                         ( select class_name||'-'||attribute_name from class_attr_property_cnfg  sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                           minus
                           select class_name||'-'||attribute_name from u_class_attribute_cnfg    sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                         )
                       )
         and    exists ( select 'X'
                         from   old_class_attr_presentation o
                         where  u.class_name     = o.class_name
                         and    u.attribute_name = o.attribute_name
                         and    not regexp_like(o.static_presentation_syntax, 'viewhidden=true', 'i')
                       )
         --EXCLUDE attributes that are DISABLED or HIDDEN, this has no impact at screen level
         and    not exists ( select 'X'
                             from   old_class_attr_presentation o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    regexp_like(o.static_presentation_syntax, 'viewhidden=true', 'i')
                             union
                             select 'X'
                             from   old_class_attribute o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    nvl(o.disabled_ind,'N') = 'Y'
                           )
       ) src
on     (     src.class_name     = trg.class_name
         and src.attribute_name = trg.attribute_name
         and src.property_code  = trg.property_code
         and src.owner_cntx     = trg.owner_cntx
       )
when matched then update set
  trg.property_value  = 'false'
, trg.last_updated_by = 'upgrade_script'
when not matched then insert
  (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value, created_by, created_date) 
  values 
  (src.class_name, src.attribute_name, src.property_code, 3000, src.presentation_cntx, src.property_type, 'false', 'upgrade_script', sysdate);
  
/******************************************************************************************************
** Fixing vieweditable property
** - make editable when it was customized in old system
** + caused by not able to compare removed vieweditable=false which is the same as vieweditable=true
******************************************************************************************************/
merge into class_attr_property_cnfg trg
using  ( select class_name, attribute_name, property_code, 3000 owner_cntx, presentation_cntx, property_type, 'true' property_value
         from   class_attr_property_cnfg u
         where  property_code  = 'vieweditable'
         and    property_value = 'false'
         and    property_type  = 'STATIC_PRESENTATION' 
         and    owner_cntx     = 0
         and    not exists ( select 'X'
                             from   class_attr_property_cnfg c
                             where  u.class_name     = c.class_name
                             and    u.attribute_name = c.attribute_name
                             and    u.property_code  = c.property_code
                             and    c.owner_cntx     = 3000
                             and    c.property_value = 'true'
                           )
         and    not exists ( select 'X'
                             from   class_attribute_cnfg c
                             where  u.class_name      = c.class_name
                             and    u.attribute_name  = c.attribute_name
                             and    c.db_mapping_type = 'FUNCTION'
                           )
         and    exists ( select 'X'
                         from   u_class_attr_property_cnfg ootb_src
                         where  u.class_name            = ootb_src.class_name
                         and    u.attribute_name        = ootb_src.attribute_name
                         and    u.property_code         = ootb_src.property_code
                         and    ootb_src.owner_cntx     = -100
                         and    ootb_src.property_value = 'false'
                         union
                         ( select class_name||'-'||attribute_name from class_attr_property_cnfg  sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                           minus
                           select class_name||'-'||attribute_name from u_class_attribute_cnfg    sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                         )
                       )
         and    exists ( select 'X'
                         from   old_class_attr_presentation o
                         where  u.class_name     = o.class_name
                         and    u.attribute_name = o.attribute_name
                         and    not regexp_like(o.static_presentation_syntax, 'vieweditable=false', 'i')
                       )
         --EXCLUDE attributes that are DISABLED or HIDDEN, this has no impact at screen level
         and    not exists ( select 'X'
                             from   old_class_attr_presentation o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    regexp_like(o.static_presentation_syntax, 'viewhidden=true', 'i')
                             union
                             select 'X'
                             from   old_class_attribute o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    nvl(o.disabled_ind,'N') = 'Y'
                           )
       ) src
on     (     src.class_name     = trg.class_name
         and src.attribute_name = trg.attribute_name
         and src.property_code  = trg.property_code
         and src.owner_cntx     = trg.owner_cntx
       )
when matched then update set
  trg.property_value  = 'true'
, trg.last_updated_by = 'upgrade_script'
when not matched then insert
  (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value, created_by, created_date) 
  values 
  (src.class_name, src.attribute_name, src.property_code, 3000, src.presentation_cntx, src.property_type, 'true', 'upgrade_script', sysdate);

/******************************************************************************************************
** Fixing viewlabelhead property
** - make empty when it was customized in old system
** + caused by not able to compare removed viewlabelhead=SOMETEXT which is the same as viewlabelhead=NULL
******************************************************************************************************/
merge into class_attr_property_cnfg trg
using  ( select class_name, attribute_name, property_code, 3000 owner_cntx, presentation_cntx, property_type, '' property_value
         from   class_attr_property_cnfg u
         where  property_code  = 'viewlabelhead'
         and    property_value is not null
         and    property_type  = 'STATIC_PRESENTATION' 
         and    owner_cntx     = 0
         and    not exists ( select 'X'
                             from   class_attr_property_cnfg c
                             where  u.class_name     = c.class_name
                             and    u.attribute_name = c.attribute_name
                             and    u.property_code  = c.property_code
                             and    c.owner_cntx     = 3000
                             and    c.property_value is null
                           )
         and    exists ( select 'X'
                         from   u_class_attr_property_cnfg ootb_src
                         where  u.class_name            = ootb_src.class_name
                         and    u.attribute_name        = ootb_src.attribute_name
                         and    u.property_code         = ootb_src.property_code
                         and    ootb_src.owner_cntx     = -100
                         and    ootb_src.property_value is not null
                         union
                         ( select class_name||'-'||attribute_name from class_attr_property_cnfg  sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                           minus
                           select class_name||'-'||attribute_name from u_class_attribute_cnfg    sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                         )
                       )
         and    exists ( select 'X'
                         from   old_class_attr_presentation o
                         where  u.class_name     = o.class_name
                         and    u.attribute_name = o.attribute_name
                         and    not regexp_like(o.static_presentation_syntax, 'viewlabelhead=[^;]', 'i')
                       )
         --EXCLUDE attributes that are DISABLED or HIDDEN, this has no impact at screen level
         and    not exists ( select 'X'
                             from   old_class_attr_presentation o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    regexp_like(o.static_presentation_syntax, 'viewhidden=true', 'i')
                             union
                             select 'X'
                             from   old_class_attribute o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    nvl(o.disabled_ind,'N') = 'Y'
                           )
       ) src
on     (     src.class_name     = trg.class_name
         and src.attribute_name = trg.attribute_name
         and src.property_code  = trg.property_code
         and src.owner_cntx     = trg.owner_cntx
       )
when matched then update set
  trg.property_value  = ''
, trg.last_updated_by = 'upgrade_script'
when not matched then insert
  (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value, created_by, created_date) 
  values 
  (src.class_name, src.attribute_name, src.property_code, 3000, src.presentation_cntx, src.property_type, '', 'upgrade_script', sysdate);

/******************************************************************************************************
** Fixing viewformatmask property
** - make empty when it was customized in old system
** + caused by not able to compare removed viewformatmask=SOMEFORMAT which is the same as viewformatmask=NULL
******************************************************************************************************/
merge into class_attr_property_cnfg trg
using  ( select class_name, attribute_name, property_code, 3000 owner_cntx, presentation_cntx, property_type, '' property_value
         from   class_attr_property_cnfg u
         where  property_code  = 'viewformatmask'
         and    property_value is not null
         and    property_type  = 'STATIC_PRESENTATION' 
         and    owner_cntx     = 0
         and    not exists ( select 'X'
                             from   class_attr_property_cnfg c
                             where  u.class_name     = c.class_name
                             and    u.attribute_name = c.attribute_name
                             and    u.property_code  = c.property_code
                             and    c.owner_cntx     = 3000
                             and    c.property_value is null
                           )
         and    exists ( select 'X'
                         from   u_class_attr_property_cnfg ootb_src
                         where  u.class_name            = ootb_src.class_name
                         and    u.attribute_name        = ootb_src.attribute_name
                         and    u.property_code         = ootb_src.property_code
                         and    ootb_src.owner_cntx     = -100
                         and    ootb_src.property_value is not null
                         union
                         ( select class_name||'-'||attribute_name from class_attr_property_cnfg  sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                           minus
                           select class_name||'-'||attribute_name from u_class_attribute_cnfg    sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                         )
                       )
         and    exists ( select 'X'
                         from   old_class_attr_presentation o
                         where  u.class_name     = o.class_name
                         and    u.attribute_name = o.attribute_name
                         and    not regexp_like(o.static_presentation_syntax, 'viewformatmask=[^;]', 'i')
                       )
         --EXCLUDE attributes that are DISABLED or HIDDEN, this has no impact at screen level
         and    not exists ( select 'X'
                             from   old_class_attr_presentation o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    regexp_like(o.static_presentation_syntax, 'viewhidden=true', 'i')
                             union
                             select 'X'
                             from   old_class_attribute o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    nvl(o.disabled_ind,'N') = 'Y'
                           )
       ) src
on     (     src.class_name     = trg.class_name
         and src.attribute_name = trg.attribute_name
         and src.property_code  = trg.property_code
         and src.owner_cntx     = trg.owner_cntx
       )
when matched then update set
  trg.property_value  = ''
, trg.last_updated_by = 'upgrade_script'
when not matched then insert
  (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value, created_by, created_date) 
  values 
  (src.class_name, src.attribute_name, src.property_code, 3000, src.presentation_cntx, src.property_type, '', 'upgrade_script', sysdate);

/******************************************************************************************************
** Fixing viewcolsumfunc property
** - make empty when it was customized in old system
** + caused by not able to compare removed viewcolsumfunc=true which is the same as viewcolsumfunc=false
******************************************************************************************************/
merge into class_attr_property_cnfg trg
using  ( select class_name, attribute_name, property_code, 3000 owner_cntx, presentation_cntx, property_type, 'false' property_value
         from   class_attr_property_cnfg u
         where  property_code  = 'viewcolsumfunc'
         and    property_value = 'true'
         and    property_type  = 'STATIC_PRESENTATION' 
         and    owner_cntx     = 0
         and    not exists ( select 'X'
                             from   class_attr_property_cnfg c
                             where  u.class_name     = c.class_name
                             and    u.attribute_name = c.attribute_name
                             and    u.property_code  = c.property_code
                             and    c.owner_cntx     = 3000
                             and    c.property_value = 'false'
                           )
         and    exists ( select 'X'
                         from   u_class_attr_property_cnfg ootb_src
                         where  u.class_name            = ootb_src.class_name
                         and    u.attribute_name        = ootb_src.attribute_name
                         and    u.property_code         = ootb_src.property_code
                         and    ootb_src.owner_cntx     = -100
                         and    ootb_src.property_value = 'true'
                         union
                         ( select class_name||'-'||attribute_name from class_attr_property_cnfg  sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                           minus
                           select class_name||'-'||attribute_name from u_class_attribute_cnfg    sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                         )
                       )
         and    exists ( select 'X'
                         from   old_class_attr_presentation o
                         where  u.class_name     = o.class_name
                         and    u.attribute_name = o.attribute_name
                         and    not regexp_like(o.static_presentation_syntax, 'viewcolsumfunc=true', 'i')
                       )
         --EXCLUDE attributes that are DISABLED or HIDDEN, this has no impact at screen level
         and    not exists ( select 'X'
                             from   old_class_attr_presentation o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    regexp_like(o.static_presentation_syntax, 'viewhidden=true', 'i')
                             union
                             select 'X'
                             from   old_class_attribute o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    nvl(o.disabled_ind,'N') = 'Y'
                           )
       ) src
on     (     src.class_name     = trg.class_name
         and src.attribute_name = trg.attribute_name
         and src.property_code  = trg.property_code
         and src.owner_cntx     = trg.owner_cntx
       )
when matched then update set
  trg.property_value  = 'false'
, trg.last_updated_by = 'upgrade_script'
when not matched then insert
  (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value, created_by, created_date) 
  values 
  (src.class_name, src.attribute_name, src.property_code, 3000, src.presentation_cntx, src.property_type, 'false', 'upgrade_script', sysdate);

/******************************************************************************************************
** Fixing UOM_CODE property
** When customized in the old environment, it should be customized in the target as well
******************************************************************************************************/
merge into class_attr_property_cnfg trg
using  ( select u.class_name, u.attribute_name, u.property_code, 3000 owner_cntx, u.presentation_cntx, u.property_type, o.uom_code property_value
         from   class_attr_property_cnfg    u
         ,      old_class_attr_presentation o
         where  u.class_name          = o.class_name
         and    u.attribute_name      = o.attribute_name
         and    nvl(o.uom_code, 'X') <> u.property_value
         and    u.property_code       = 'UOM_CODE'
         and    u.property_type       = 'VIEWLAYER' 
         and    u.owner_cntx          = 0
         and    not exists ( select 'X'
                             from   class_attr_property_cnfg c
                             where  u.class_name         = c.class_name
                             and    u.attribute_name     = c.attribute_name
                             and    u.property_code      = c.property_code
							 and    nvl(o.uom_code, 'X') = nvl(c.property_value, 'X')
                             and    c.owner_cntx         = 3000
                           )
         and    exists ( select 'X'
                         from   u_class_attr_property_cnfg ootb_src
                         where  u.class_name            = ootb_src.class_name
                         and    u.attribute_name        = ootb_src.attribute_name
                         and    u.property_code         = ootb_src.property_code
                         and    ootb_src.owner_cntx     = -100
                         and    ootb_src.property_value = u.property_value
                         union
                         ( select class_name||'-'||attribute_name from class_attr_property_cnfg  sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                           minus
                           select class_name||'-'||attribute_name from u_class_attribute_cnfg    sub where sub.class_name = u.class_name and sub.attribute_name = u.attribute_name
                         )
                       )
         --EXCLUDE attributes that are DISABLED or HIDDEN, this has no impact at screen level
         and    not exists ( select 'X'
                             from   old_class_attr_presentation o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    regexp_like(o.static_presentation_syntax, 'viewhidden=true', 'i')
                             union
                             select 'X'
                             from   old_class_attribute o
                             where  u.class_name     = o.class_name
                             and    u.attribute_name = o.attribute_name
                             and    nvl(o.disabled_ind,'N') = 'Y'
                           )
       ) src
on     (     src.class_name     = trg.class_name
         and src.attribute_name = trg.attribute_name
         and src.property_code  = trg.property_code
         and src.owner_cntx     = trg.owner_cntx
       )
when matched then update set
  trg.property_value  = src.property_value
, trg.last_updated_by = 'upgrade_script'
when not matched then insert
  (    class_name,     attribute_name,     property_code,     owner_cntx,     presentation_cntx,     property_type,     property_value,       created_by, created_date) 
  values 
  (src.class_name, src.attribute_name, src.property_code, src.owner_cntx, src.presentation_cntx, src.property_type, src.property_value, 'upgrade_script', sysdate     );
  
-- Work arround for ECPD-52243
insert into class_property_cnfg (class_name, property_code, owner_cntx, presentation_cntx, property_type, property_value) values ('TRANS_INV_TMPL_SET', 'JOURNAL_RULE_DB_SYNTAX', '3000', '/EC', 'VIEWLAYER', '');

--Fix disabled ind
merge into class_attr_property_cnfg trg
using  ( select class_name, attribute_name, property_code, 3000 owner_cntx, presentation_cntx, property_type, 'N' property_value
         from   class_attr_property_cnfg u
         where  property_code  = 'DISABLED_IND'
         and    property_value = 'Y'
         and    property_type  = 'VIEWLAYER' 
         and    owner_cntx     = 0
         and    not exists ( select 'X'
                             from   class_attr_property_cnfg c
                             where  u.class_name     = c.class_name
                             and    u.attribute_name = c.attribute_name
                             and    u.property_code  = c.property_code
                             and    c.owner_cntx     = 3000
                             and    c.property_value = 'N'
                           )
         and    exists ( select 'X'
                         from   old_class_attribute o
                         where  u.class_name     = o.class_name
                         and    u.attribute_name = o.attribute_name
                         and    nvl(o.disabled_ind, 'N') = 'N'
                       )
       ) src
on     (     src.class_name     = trg.class_name
         and src.attribute_name = trg.attribute_name
         and src.property_code  = trg.property_code
         and src.owner_cntx     = trg.owner_cntx
       )
when matched then update set
  trg.property_value  = 'N'
, trg.last_updated_by = 'upgrade_script'
when not matched then insert
  (class_name, attribute_name, property_code, owner_cntx, presentation_cntx, property_type, property_value, created_by, created_date) 
  values 
  (src.class_name, src.attribute_name, src.property_code, src.owner_cntx, src.presentation_cntx, src.property_type, src.property_value, 'upgrade_script', sysdate);
