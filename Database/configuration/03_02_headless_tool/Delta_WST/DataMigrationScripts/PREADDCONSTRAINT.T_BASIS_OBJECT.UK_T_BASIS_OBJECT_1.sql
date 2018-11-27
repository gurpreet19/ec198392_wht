BEGIN
  DELETE from T_BASIS_ACCESS x where object_id in (select object_id from T_BASIS_OBJECT X WHERE X.OBJECT_NAME='/com.ec.frmw.co.screens/manage_object/CLASS_NAME/FIN_REVENUE_ORDER' AND X.OBJECT_DESCR='Maintain Revenue Order' AND X.APP_ID=1 AND ROWNUM < 2);
  DELETE from T_BASIS_OBJECT X WHERE X.OBJECT_NAME='/com.ec.frmw.co.screens/manage_object/CLASS_NAME/FIN_REVENUE_ORDER' AND X.OBJECT_DESCR='Maintain Revenue Order' AND X.APP_ID=1 AND ROWNUM < 2;
 
EXCEPTION
   WHEN OTHERS 
     THEN        
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
BEGIN
  DELETE from T_BASIS_ACCESS x where object_id in (select object_id from T_BASIS_OBJECT X WHERE X.OBJECT_NAME='/com.ec.frmw.co.screens/manage_object/CLASS_NAME/FIN_COST_CENTER' AND X.OBJECT_DESCR='Maintain Cost Center' AND X.APP_ID=1 AND ROWNUM < 2);
  DELETE from T_BASIS_OBJECT X WHERE X.OBJECT_NAME='/com.ec.frmw.co.screens/manage_object/CLASS_NAME/FIN_COST_CENTER' AND X.OBJECT_DESCR='Maintain Cost Center' AND X.APP_ID=1 AND ROWNUM < 2;
 
EXCEPTION
   WHEN OTHERS 
     THEN        
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
BEGIN
  DELETE from T_BASIS_ACCESS x where object_id in (select object_id from T_BASIS_OBJECT X WHERE X.OBJECT_NAME='/com.ec.frmw.co.screens/manage_object/CLASS_NAME/FIN_WBS' AND X.OBJECT_DESCR='Maintain WBS' AND X.APP_ID=1 AND ROWNUM < 2);
  DELETE from T_BASIS_OBJECT X WHERE X.OBJECT_NAME='/com.ec.frmw.co.screens/manage_object/CLASS_NAME/FIN_WBS' AND X.OBJECT_DESCR='Maintain WBS' AND X.APP_ID=1 AND ROWNUM < 2;
 
EXCEPTION
   WHEN OTHERS 
     THEN        
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--
BEGIN
  DELETE from T_BASIS_ACCESS x where object_id in (select object_id from T_BASIS_OBJECT X WHERE X.OBJECT_NAME='/com.ec.frmw.co.screens/manage_table/CLASS_NAME/PRICE_CONCEPT' AND X.OBJECT_DESCR='Maintain Price Concept' AND X.APP_ID=1 AND ROWNUM < 2);
  DELETE from T_BASIS_OBJECT X WHERE X.OBJECT_NAME='/com.ec.frmw.co.screens/manage_table/CLASS_NAME/PRICE_CONCEPT' AND X.OBJECT_DESCR='Maintain Price Concept' AND X.APP_ID=1 AND ROWNUM < 2;
 
EXCEPTION
   WHEN OTHERS 
     THEN        
        raise_application_error(-20000,'ERROR: Some Other fatal error occured :- '||SQLERRM);
END;
--~^UTDELIM^~--