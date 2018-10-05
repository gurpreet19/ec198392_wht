BEGIN

INSERT INTO account_list ( ACCOUNT_CODE, ACCOUNT_NAME, PRODUCT_ID, PRICE_CONCEPT_CODE, SORT_ORDER, DESCRIPTION, CREATED_BY, CREATED_DATE)
select account_code,
       name,
       product_id,
       price_concept_code,
       sort_order,
       description,
       created_by,
	   SYSDATE
  from (select rownum xx, a.*
          from (select ACCOUNT_CODE,
                       NAME,
                       PRODUCT_ID,
                       PRICE_CONCEPT_CODE,
                       sort_order,
                       DESCRIPTION,
                       created_by
                  from contract_account
                 order by account_code) a) c1
 where not exists (select 1
          from (select rownum xx, b.*
                  from (select ACCOUNT_CODE,
                               NAME,
                               PRODUCT_ID,
                               PRICE_CONCEPT_CODE,
                               sort_order,
                               DESCRIPTION,
                               created_by
                          from contract_account
                         order by account_code) b) c2
         where c2.account_code = c1.account_code
           and c1.xx = c2.xx - 1);
		   
END;
--~^UTDELIM^~--	