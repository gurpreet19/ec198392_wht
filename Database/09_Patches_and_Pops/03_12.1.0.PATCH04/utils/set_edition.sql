variable lv2_oracle_edition VARCHAR2(10)

DECLARE
  lv2_version VARCHAR2(50);
  lv2_edition VARCHAR2(50);
  lv2_short_edition VARCHAR2(50);
BEGIN
	select version into lv2_version from v$instance;
	IF lv2_version like '11%' THEN
		:lv2_oracle_edition := 'EE';
	ELSIF lv2_version like '12%' THEN
		BEGIN
		EXECUTE IMMEDIATE 'select edition from v$instance' into lv2_edition;
		-- for 'CORE SE' and 'SE'
		IF lv2_edition like '%SE' THEN
			lv2_short_edition:='SE';
		-- for 'CORE EE' and 'EE'
		ELSIF lv2_edition like '%EE' THEN
			lv2_short_edition:='EE';
		-- personal and XE not supported
		ELSE
			raise_application_error(-20050, 'Oracle edition not supported :'||lv2_edition );
		END IF;
		SELECT lv2_short_edition into :lv2_oracle_edition from dual;
		END;
	ELSE
		raise_application_error(-20051, 'Oracle version not supported' );
	END IF;
END;
/

column edition new_value oracle_edition
select :lv2_oracle_edition edition from dual;