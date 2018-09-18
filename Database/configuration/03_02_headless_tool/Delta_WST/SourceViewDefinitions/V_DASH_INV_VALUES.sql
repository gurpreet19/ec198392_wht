CREATE OR REPLACE FORCE EDITIONABLE VIEW "V_DASH_INV_VALUES" ("DAYTIME", "OBJECT_ID", "UOM_CODE", "PROD_ID", "INV_OPENING_QTY", "INV_MOVEMENT_QTY", "INV_CLOSING_QTY", "INV_CLOSING_VALUE", "DAYTIME_CHAR", "UOM_LABEL", "GROUP_CURRENCY_CODE", "INV_CODE", "INV_NAME", "INV_AREA_ID", "INV_AREA_CODE", "INV_AREA_NAME", "CO_ID", "CO_NAME", "INV_CAT_CODE", "INV_CAT_NAME", "BOOK_CAT_CODE", "BOOK_CAT_NAME", "PROD_CODE", "PROD_NAME", "DASH_HEADER_QTY", "DASH_HEADER_QTY_IA", "DASH_HEADER_VAL", "DASH_HEADER_VAL_IA", "RECORD_STATUS", "CREATED_BY", "CREATED_DATE", "LAST_UPDATED_BY", "LAST_UPDATED_DATE", "REV_NO", "REV_TEXT", "APPROVAL_STATE", "APPROVAL_DATE", "APPROVAL_BY", "REC_ID") AS 
  SELECT
       --group expressions:
       x.daytime,
       x.object_id,
       ec_inventory_version.uom1_code(v.object_id,v.daytime,'<=') as UOM_CODE,
       ec_inventory_version.product_id(v.object_id,v.daytime,'<=') as PROD_ID,
       --Values:
       sum(nvl(x.opening_ul_position_qty1,0)) + sum(nvl(x.opening_ol_position_qty1,0)) + sum(nvl(x.opening_ps_position_qty1,0)) as INV_OPENING_QTY,
       sum(nvl(x.ytd_ul_mov_qty1,0)) + sum(nvl(x.ytd_ol_mov_qty1,0)) + sum(nvl(x.ytd_ps_movement_qty1,0)) as INV_MOVEMENT_QTY,
       sum(nvl(x.closing_ul_position_qty1,0)) + sum(nvl(x.closing_ol_position_qty1,0)) + sum(nvl(x.closing_ps_position_qty1,0)) as INV_CLOSING_QTY,
       sum(nvl(x.ul_group_value,0)) + sum(nvl(x.ol_group_value,0)) + sum(nvl(x.ps_group_value,0)) as INV_CLOSING_VALUE,
       --Daytime formatted:
       to_char(trunc(max(x.daytime), 'MM'), 'Mon YYYY') as DAYTIME_CHAR,
       --Unit Label
       ec_ctrl_unit.label(ec_inventory_version.uom1_code(v.object_id,v.daytime,'<=')) as UOM_LABEL,
       --Group Currency Code:
       max(ec_ctrl_system_attribute.attribute_text(v.daytime ,'GROUP_CURRENCY_CODE','<=')) as GROUP_CURRENCY_CODE,
       --Inventory Code and Name:
       max(ec_inventory.object_code(x.object_id)) as INV_CODE,
       max(ec_inventory_version.name(v.object_id,v.daytime,'<=')) as INV_NAME,
       --Inventory Area:
       max(ec_inventory_version.inventory_area_id(v.object_id,v.daytime,'<=')) as INV_AREA_ID,
       max(ec_inventory_area.object_code(ec_inventory_version.inventory_area_id(v.object_id,v.daytime,'<='))) as INV_AREA_CODE,
       max(ec_inventory_area_version.name(ec_inventory_version.inventory_area_id(v.object_id,v.daytime,'<='),v.daytime,'<=')) as INV_AREA_NAME,
       --Inventory Company:
       max(ec_inventory_version.company_id(v.object_id,v.daytime,'<=')) as CO_ID,
       max(ec_company_version.name(ec_inventory_version.company_id(v.object_id,v.daytime,'<='),v.daytime,'<=')) as CO_NAME,
       --Inventory Category:
       max(ec_inventory_version.inventory_category(v.object_id,v.daytime,'<=')) as INV_CAT_CODE,
       max(ec_prosty_codes.code_text(ec_inventory_version.inventory_category(v.object_id,v.daytime,'<='), 'INVENTORY_CATEGORY')) as INV_CAT_NAME,
       --Inventory Book Category:
       max(ec_inventory_version.book_category(v.object_id,v.daytime,'<=')) as BOOK_CAT_CODE,
       max(ec_prosty_codes.code_text(ec_inventory_version.book_category(v.object_id,v.daytime,'<='), 'BOOK_CATEGORY')) as BOOK_CAT_NAME,
       --Inventory Product:
       max(ec_product.object_code(ec_inventory_version.product_id(v.object_id,v.daytime,'<='))) as PROD_CODE,
       max(ec_product_version.name(ec_inventory_version.product_id(v.object_id,v.daytime,'<='), v.daytime,'<=')) as PROD_NAME,
       'Inventory Closing Quantity in '
                  ||ec_ctrl_unit.label(ec_inventory_version.uom1_code(v.object_id,v.daytime,'<='))
                  ||' for '
                  ||max(ec_product_version.name(ec_inventory_version.product_id(v.object_id,v.daytime,'<='), v.daytime,'<='))
                  ||' for '''
                  ||max(ec_company_version.name(ec_inventory_version.company_id(v.object_id,v.daytime,'<='),v.daytime,'<='))
                  ||''''
                  as DASH_HEADER_QTY,
       'Inventory Closing Quantity in '
                  ||ec_ctrl_unit.label(ec_inventory_version.uom1_code(v.object_id,v.daytime,'<='))
                  ||' for '
                  ||max(ec_product_version.name(ec_inventory_version.product_id(v.object_id,v.daytime,'<='), v.daytime,'<='))
                  ||' for '''
                  ||max(ec_inventory_area_version.name(ec_inventory_version.inventory_area_id(v.object_id,v.daytime,'<='),v.daytime,'<='))
                  ||''''
                  ||'/'''
                  ||max(ec_company_version.name(ec_inventory_version.company_id(v.object_id,v.daytime,'<='),v.daytime,'<='))
                  ||''''
                  as DASH_HEADER_QTY_IA,
       'Inventory Closing Value in '
                  ||max(ec_ctrl_system_attribute.attribute_text(v.daytime ,'GROUP_CURRENCY_CODE','<='))
                  ||' for '
                  ||max(ec_product_version.name(ec_inventory_version.product_id(v.object_id,v.daytime,'<='), v.daytime,'<='))
                  ||' for '''
                  ||max(ec_company_version.name(ec_inventory_version.company_id(v.object_id,v.daytime,'<='),v.daytime,'<='))
                  ||''''
                  as DASH_HEADER_VAL,
       'Inventory Closing Value in '
                  ||max(ec_ctrl_system_attribute.attribute_text(v.daytime ,'GROUP_CURRENCY_CODE','<='))
                  ||' for '
                  ||max(ec_product_version.name(ec_inventory_version.product_id(v.object_id,v.daytime,'<='), v.daytime,'<='))
                  ||' for '''
                  ||max(ec_inventory_area_version.name(ec_inventory_version.inventory_area_id(v.object_id,v.daytime,'<='),v.daytime,'<='))
                  ||''''
                  ||'/'''
                  ||max(ec_company_version.name(ec_inventory_version.company_id(v.object_id,v.daytime,'<='),v.daytime,'<='))
                  ||''''
                  as DASH_HEADER_VAL_IA,
         max(v.RECORD_STATUS) as RECORD_STATUS,
         max(v.CREATED_BY) as CREATED_BY,
         max(v.CREATED_DATE) as CREATED_DATE,
         max(v.LAST_UPDATED_BY) as LAST_UPDATED_BY,
         max(v.LAST_UPDATED_DATE) as LAST_UPDATED_DATE,
         max(v.REV_NO) as REV_NO,
         max(v.REV_TEXT) as REV_TEXT,
         max(v.approval_state) as APPROVAL_STATE,
         max(v.approval_date) as APPROVAL_DATE,
         max(v.approval_by) as APPROVAL_BY,
         max(v.rec_id) as REC_ID
 FROM inv_dist_valuation x, inv_valuation v
 where x.object_id = v.object_id
 and x.daytime = v.daytime
 group by x.daytime,
          x.object_id,
          ec_inventory_version.product_id(v.object_id,v.daytime,'<='),
          ec_inventory_version.uom1_code(v.object_id,v.daytime,'<=')
 order by daytime, inv_code