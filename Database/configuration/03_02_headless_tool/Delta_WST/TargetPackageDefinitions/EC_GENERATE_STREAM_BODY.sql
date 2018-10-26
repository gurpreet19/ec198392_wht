CREATE OR REPLACE PACKAGE BODY ec_generate_stream IS
/**************************************************************
** Package :               ec_generate_stream, body part
**
** Revision :              $Revision: 1.4 $
**
** Purpose :               Generates code for derived streams.
**
** Documentation :         www.energy-components.no
**
** Created :               07.10.02 Dagfinn Njå
**
** Modification history:
**
** Date:    Whom: Change description:
** -------- ----- --------------------------------------------
** 07.10.02 DN    Initial revision. Split from ec_generate.
** 12.11.03 DN    Renamed t_temptekst. Removed public synonyms and grants.
***********************************************************************************************/

------------------------------------------------------------------
-- PROCEDURE:      create_dummy_head()
--
-- Purpose:
-- Preconditions:
------------------------------------------------------------------
PROCEDURE create_dummy_head(p_function_name VARCHAR2)
IS

BEGIN

	LagKodeServer.Laglogg('------------------------------------------------------------------------------------');
	LagKodeServer.Laglogg('FUNCTION math_' || p_function_name || '(' || chr(10) );
--	LagKodeServer.Laglogg('         ' || 'p_sysnam      VARCHAR2,');
--	LagKodeServer.Laglogg('         ' || 'p_stream_code VARCHAR2,');
	LagKodeServer.Laglogg('         ' || 'p_stream_id VARCHAR2,');
	LagKodeServer.Laglogg('         ' || 'p_from_day    DATE,');
	LagKodeServer.Laglogg('         ' || 'p_to_day      DATE DEFAULT NULL,');
	LagKodeServer.Laglogg('         ' || 'p_method      VARCHAR2 DEFAULT ''' || 'SUM' || ''') RETURN NUMBER;');
	LagKodeServer.Laglogg('  ');
	LagKodeServer.Laglogg('PRAGMA RESTRICT_REFERENCES (math_' || p_function_name || ', WNDS, WNPS, RNPS);');

END create_dummy_head;
-- End procedure


------------------------------------------------------------------
-- PROCEDURE:      create_dummy_body()
--
-- Purpose:
-- Preconditions:
------------------------------------------------------------------
PROCEDURE create_dummy_body(p_function_name VARCHAR2)
IS

BEGIN

	LagKodeServer.Laglogg('------------------------------------------------------------------------------------');
	LagKodeServer.Laglogg('FUNCTION math_' || p_function_name || '(' || chr(10) );
--	LagKodeServer.Laglogg('         ' || 'p_sysnam       VARCHAR2,');
--	LagKodeServer.Laglogg('         ' || 'p_stream_code  VARCHAR2,');
	LagKodeServer.Laglogg('         ' || 'p_stream_id  VARCHAR2,');
	LagKodeServer.Laglogg('         ' || 'p_from_day     DATE,');
	LagKodeServer.Laglogg('         ' || 'p_to_day       DATE DEFAULT NULL,');
	LagKodeServer.Laglogg('         ' || 'p_method       VARCHAR2 DEFAULT ''' || 'SUM' || ''') RETURN NUMBER IS');
	LagKodeServer.Laglogg(' ');

	LagKodeServer.Laglogg('BEGIN');
   LagKodeServer.Laglogg(' ');
	LagKodeServer.Laglogg(' RETURN NULL;');
	LagKodeServer.Laglogg('  ');

	LagKodeServer.Laglogg('END math_' || p_function_name || ';');
	LagKodeServer.Laglogg('  ');

END create_dummy_body;
-- End procedure


------------------------------------------------------------------
-- PROCEDURE:      generateDerivedStreams()
--
-- Purpose:        Generates the ec_derived_stream package, for streams
--                 configured in the <strm_derived> table.
--
-- Preconditions:  The table <strm_derived> should contain a valid
--                 caclulation formula in the derived_formula column:
--                 ln_return_val := <some code> ;
------------------------------------------------------------------
PROCEDURE generateDerivedStreams
IS

-- The stream_codes, derived_type and the formula
CURSOR  c_derived_streams IS
SELECT  -- STRM_DERIVED.STREAM_CODE,
	STRM_DERIVED.object_id,
        Lower(DERIVED_TYPE) derived_type,
        DERIVED_FORMULA
FROM    STRM_DERIVED,
        STREAM
WHERE   STREAM.object_id = STRM_DERIVED.object_id -- strm_derived have no stream_code anymore
;
--AND     STREAM.STREAM_TYPE IN('X','D'); Removed since this should be the case for all streams


-- The functions which should be generated
CURSOR  c_derived_type IS
SELECT  DISTINCT(Lower(DERIVED_TYPE)) function_name
FROM    STRM_DERIVED
;
--AND     STREAM_CODE IN
--        (SELECT STREAM_CODE
--        FROM    STREAM
--        WHERE   STREAM_TYPE IN ('X','D')
--         AND     SYSNAM = p_sysnam);

ln_count NUMBER;
ln_net_vol_flag NUMBER := 0;
ln_net_mass_flag NUMBER := 0;
ln_grs_vol_flag NUMBER := 0;
ln_grs_mass_flag NUMBER := 0;

BEGIN

	------------------------------------------------------------
	-- initiate and delete old information from t_temptext
	------------------------------------------------------------
	DELETE 	FROM t_temptext
	WHERE 	id='DERIVED_STREAMS';

	LagKodeServer.Lv2_id :='DERIVED_STREAMS';
	LagKodeServer.ln_nummer :=0;

	------------------------------------------------------------
	-- create package header
	------------------------------------------------------------
	LagKodeServer.Laglogg('CREATE OR REPLACE PACKAGE EC_DERIVED_STREAM IS');
	LagKodeServer.Laglogg('------------------------------------------------------------------------------------');
	LagKodeServer.Laglogg('-- Package: EC_DERIVED_STREAM  ');
	LagKodeServer.Laglogg('-- Generated by EC_GENERATE : $Revision: 1.4 $ ' || To_Char(Sysdate, 'DD.MM.YYYY HH24:MI'));
	LagKodeServer.Laglogg('------------------------------------------------------------------------------------');
	LagKodeServer.Laglogg('  ');


	------------------------------------------------------------
	-- create math-function spec' for derived streams
	------------------------------------------------------------

	FOR mycur_type IN c_derived_type LOOP

		IF (mycur_type.function_name = 'net_vol') THEN
			ln_net_vol_flag := 1;
		END IF;

		IF (mycur_type.function_name = 'net_mass') THEN
			ln_net_mass_flag := 1;
		END IF;

		IF (mycur_type.function_name = 'grs_vol') THEN
			ln_grs_vol_flag := 1;
		END IF;

		IF (mycur_type.function_name = 'grs_mass') THEN
			ln_grs_mass_flag := 1;
		END IF;

		LagKodeServer.Laglogg('------------------------------------------------------------------------------------');
		LagKodeServer.Laglogg('FUNCTION math_' || mycur_type.function_name || '(' || chr(10) );
--		LagKodeServer.Laglogg('         ' || 'p_sysnam      VARCHAR2,');
--		LagKodeServer.Laglogg('         ' || 'p_stream_code VARCHAR2,');
		LagKodeServer.Laglogg('         ' || 'p_stream_id VARCHAR2,');
		LagKodeServer.Laglogg('         ' || 'p_from_day    DATE,');
		LagKodeServer.Laglogg('         ' || 'p_to_day      DATE DEFAULT NULL,');
		LagKodeServer.Laglogg('         ' || 'p_method      VARCHAR2 DEFAULT ''' || 'SUM' || ''') RETURN NUMBER;');
		LagKodeServer.Laglogg('  ');
		LagKodeServer.Laglogg('PRAGMA RESTRICT_REFERENCES (math_' || mycur_type.function_name || ', WNDS, WNPS, RNPS);');

	END LOOP;

	IF (ln_net_vol_flag = 0) THEN
		create_dummy_head('net_vol');
	END IF;

	IF (ln_net_mass_flag = 0) THEN
		create_dummy_head('net_mass');
	END IF;

	IF (ln_grs_vol_flag = 0) THEN
		create_dummy_head('grs_vol');
	END IF;

	IF (ln_grs_mass_flag = 0) THEN
		create_dummy_head('grs_mass');
	END IF;

	LagKodeServer.Laglogg('  ');


	------------------------------------------------------------
	-- create package footer
	------------------------------------------------------------
	LagKodeServer.Laglogg('  ');
	LagKodeServer.Laglogg('END EC_DERIVED_STREAM;');
	LagKodeServer.Laglogg('/  ');

	------------------------------------------------------------
	-- create package body header
	------------------------------------------------------------
	LagKodeServer.Laglogg('  ');
	LagKodeServer.Laglogg('  ');
	LagKodeServer.Laglogg('CREATE OR REPLACE PACKAGE BODY EC_DERIVED_STREAM IS');
	LagKodeServer.Laglogg('------------------------------------------------------------------------------------');
	LagKodeServer.Laglogg('-- Package body: EC_DERIVED_STREAM ');
	LagKodeServer.Laglogg('-- generated by EC_GENERATE : $Revision: 1.4 $ ' || To_Char(Sysdate, 'DD.MM.YYYY HH24:MI'));
	LagKodeServer.Laglogg('------------------------------------------------------------------------------------');
	LagKodeServer.Laglogg('  ');
	LagKodeServer.Laglogg('  ');

	------------------------------------------------------------
	-- create generic functions for derived streams
	------------------------------------------------------------
	FOR mycur_type IN c_derived_type LOOP

		LagKodeServer.Laglogg('------------------------------------------------------------------------------------');
		LagKodeServer.Laglogg('FUNCTION math_' || mycur_type.function_name || '(' || chr(10) );
--		LagKodeServer.Laglogg('         ' || 'p_sysnam       VARCHAR2,');
--		LagKodeServer.Laglogg('         ' || 'p_stream_code  VARCHAR2,');
		LagKodeServer.Laglogg('         ' || 'p_stream_id  VARCHAR2,');
		LagKodeServer.Laglogg('         ' || 'p_from_day     DATE,');
		LagKodeServer.Laglogg('         ' || 'p_to_day       DATE DEFAULT NULL,');
		LagKodeServer.Laglogg('         ' || 'p_method       VARCHAR2 DEFAULT ''' || 'SUM' || ''') RETURN NUMBER IS');
		LagKodeServer.Laglogg(' ');

		LagKodeServer.Laglogg(' ln_return_val NUMBER := 0;');
		LagKodeServer.Laglogg(' ');
		LagKodeServer.Laglogg('BEGIN');
      LagKodeServer.Laglogg(' ');
      LagKodeServer.Laglogg(' IF p_from_day = NULL THEN');
      LagKodeServer.Laglogg('   return NULL;');
      LagKodeServer.Laglogg(' END IF;');
      LagKodeServer.Laglogg(' ');

		ln_count := 0;

		FOR mycur_streams IN c_derived_streams LOOP

			IF (mycur_streams.derived_type = mycur_type.function_name) THEN
				IF (ln_count = 0) THEN
					LagKodeServer.Laglogg(' IF p_stream_id = ''' || mycur_streams.object_id || ''' THEN');
				ELSE
					LagKodeServer.Laglogg(' ELSIF p_stream_id = ''' || mycur_streams.object_id || ''' THEN');
				END IF;

				LagKodeServer.Laglogg('    ' || mycur_streams.derived_formula);
				LagKodeServer.Laglogg(' ');
				ln_count := ln_count + 1;
			END IF;

		END LOOP;

		LagKodeServer.Laglogg(' ELSE');
		LagKodeServer.Laglogg('    ln_return_val := NULL;');
		LagKodeServer.Laglogg(' END IF;');
		LagKodeServer.Laglogg('  ');

		LagKodeServer.Laglogg(' RETURN ln_return_val;');
		LagKodeServer.Laglogg('  ');

		LagKodeServer.Laglogg('END math_' || mycur_type.function_name || ';');
		LagKodeServer.Laglogg('  ');

	END LOOP;

	IF (ln_net_vol_flag = 0) THEN
		create_dummy_body('net_vol');
	END IF;

	IF (ln_net_mass_flag = 0) THEN
		create_dummy_body('net_mass');
	END IF;

	IF (ln_grs_vol_flag = 0) THEN
		create_dummy_body('grs_vol');
	END IF;

	IF (ln_grs_mass_flag = 0) THEN
		create_dummy_body('grs_mass');
	END IF;

		------------------------------------------------------------
	-- CREATE PACKAGE FOOTER
	------------------------------------------------------------

	LagKodeServer.Laglogg('END EC_DERIVED_STREAM;');
	LagKodeServer.Laglogg('/ ');
	LagKodeServer.Laglogg(' ');

END generateDerivedStreams;
-- End procedure


END ec_generate_stream;