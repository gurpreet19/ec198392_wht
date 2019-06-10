SET serveroutput ON
DECLARE

  CURSOR c1 IS
    SELECT 'ORA-GEN_ERROR : ' || substr(text,1,200) as txt
      FROM t_temptext
      WHERE id = 'GENCODEERROR'
      AND upper(text) like '%SYNTAX%'
      ORDER BY line_number;

BEGIN
    
	ecdp_viewlayer.BuildViewLayer();  
	 -- for one in c1 loop
      -- dbms_output.put_line(one.txt);
    -- end loop;
	
	ecdp_viewlayer.BuildReportLayer();
	 -- for one in c1 loop
      -- dbms_output.put_line(one.txt);
    -- end loop;
	
END;
/