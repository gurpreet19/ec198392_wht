CREATE OR REPLACE PACKAGE BODY EC_INSTALL_CONSTANTS IS

BLOCKED_APP_SPACE_CNTXTS VARCHAR2(1000) := NULL;

PROCEDURE blockAppSpaceCntxs(p_app_space_cntxs IN VARCHAR2)
IS
BEGIN
	BLOCKED_APP_SPACE_CNTXTS := NULL;
	IF p_app_space_cntxs IS NOT NULL THEN
		BLOCKED_APP_SPACE_CNTXTS := REPLACE(p_app_space_cntxs,' ','');
	END IF;
END blockAppSpaceCntxs;

FUNCTION getBlockedAppSpaceCntxs RETURN VARCHAR2
IS
BEGIN
	RETURN BLOCKED_APP_SPACE_CNTXTS;
END getBlockedAppSpaceCntxs;

FUNCTION isBlockedAppSpaceCntx(p_app_space_cntxs IN VARCHAR2) 
RETURN INTEGER
IS 
BEGIN 
	IF BLOCKED_APP_SPACE_CNTXTS IS NOT NULL AND p_app_space_cntxs IS NOT NULL THEN
		IF instr(','||BLOCKED_APP_SPACE_CNTXTS||',', ','||p_app_space_cntxs||',') > 0 THEN
			RETURN 1;
		END IF;
	END IF;
	RETURN 0;
END isBlockedAppSpaceCntx;
  
END ec_install_constants;
/