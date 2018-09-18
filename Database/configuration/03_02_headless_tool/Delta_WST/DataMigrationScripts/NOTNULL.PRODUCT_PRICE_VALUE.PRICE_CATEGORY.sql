-- ECPD-21764
DECLARE 
HASENTRY NUMBER;
BEGIN
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_PRODUCT_PRICE_VALUE'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_PRODUCT_PRICE_VALUE DISABLE';
		END IF;
		
		-- contract price list	
		update product_price_value 
		set price_category = 'CONTRACT' 
		where object_id in (select p.object_id
		FROM PRODUCT_PRICE_VALUE p, PRODUCT_PRICE o
		WHERE p.object_id = o.object_id
		AND o.contract_id is not null AND p.parcel_key is null)
		and parcel_key is null;
		
		-- inventory price list
		update product_price_value 
		set price_category = 'INVENTORY' 
		where object_id in (select p.object_id
		FROM PRODUCT_PRICE_VALUE p, PRODUCT_PRICE o
		WHERE p.object_id = o.object_id
		AND o.inventory_id is not null and p.parcel_key is null)
		and parcel_key is null;
		
		-- Cargo price list
		update product_price_value 
		set price_category = 'CARGO' 
		where parcel_key is not null;
		
		-- product price list, general price value
		update product_price_value 
		set price_category = 'PRODUCT'
		where price_category is null;
	
	SELECT COUNT(*) INTO HASENTRY FROM USER_TRIGGERS 
		WHERE TRIGGER_NAME = 'IU_PRODUCT_PRICE_VALUE'; 
		IF HASENTRY > 0 THEN 
		EXECUTE IMMEDIATE 'ALTER TRIGGER IU_PRODUCT_PRICE_VALUE ENABLE';
		END IF;
EXCEPTION
   WHEN OTHERS 
     THEN

       IF HASENTRY > 0 THEN 
           EXECUTE IMMEDIATE 'ALTER TRIGGER IU_PRODUCT_PRICE_VALUE ENABLE';
       END IF;
        
        raise_application_error(-20000,
                            'ERROR: Some Other fatal error occured :- '||SQLERRM);


END;
--~^UTDELIM^~--
