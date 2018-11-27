CREATE OR REPLACE PACKAGE BODY EcDp_PackageDoc IS
/****************************************************************
** Package        :  EcDp_PackageDoc, body part
**
** $Revision: 1.3 $
**
** Purpose        :  Used for documenting view source
**
** Documentation  :  www.energy-components.com
**
** Created  : 25.01.2001  Arild vervik
**
** Modification history:
**
** Date       Whom  Change description:
** --------   ----- --------------------------------------
** 20031112   DN    Renamed t_temptekst.
** 20031118   DN    Replaced sysdate with new function.
*****************************************************************/

ln_line NUMBER:= 0;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : insertDocTempText                                                            --
-- Description    : Insert lines of package documentation into t_temptext                       --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postcondition  :                                                                              --
-- Using Tables   : t_temptext                                                                  --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
--<FUNC>
FUNCTION insertDocTempText(ln_line NUMBER ,lv2_text VARCHAR2) RETURN NUMBER IS
--</FUNC>
--</EC-DOC>
BEGIN

  INSERT INTO t_temptext (
      ID
     ,LINE_NUMBER
     ,TEXT
  )
  VALUES (
  'ECDOC_PACK'
  ,ln_line
  ,lv2_text
  );

COMMIT;

RETURN ln_line + 1;


END insertDocTempText;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- function       : ExtractPacageDocumentation                                                   --
-- Description    : Copy all lines of package documentation from package body to t_temptext     --
--                                                                                               --
-- Preconditions  : Documentation  between --<EC-DOC>  --</EC-DOC> brackets                      --
-- Postcondition  : Documentation copied to t_temptext with id 'ECDOC_PACK'                     --
-- Using Tables   : t_temptext                                                                  --
--                                                                                               --
-- Using functions: insertDocTempText                                                            --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
--<FUNC>
PROCEDURE ExtractPacageDocumentation(p_packagename VARCHAR2 DEFAULT NULL)
--</FUNC>
--</EC-DOC>

IS
  ln_inside_brackets       NUMBER;
  ln_verify_inside         NUMBER;
  lv2_line                 VARCHAR2(4000);
  ln_line                  NUMBER;
  ln_temp                  NUMBER;
  ln_count		   NUMBER;
  lv2_temp		   VARCHAR2(2000);
  headtemp1		   VARCHAR2(2000);
  headtemp2		   VARCHAR2(2000);

  CURSOR c_package_name IS
  SELECT object_name
  FROM user_objects
  WHERE OBJECT_TYPE = 'PACKAGE BODY'
  AND UPPER(object_name) = UPPER(Nvl(p_packagename,object_name));

  CURSOR c_package(cp_packagename VARCHAR2) IS
  SELECT name, text
  FROM user_source
  WHERE TYPE = 'PACKAGE BODY'
  AND name = cp_packagename;



BEGIN

   ln_inside_brackets := 0;
   ln_verify_inside := 0;
   ln_line := 0;


   DELETE FROM t_temptext WHERE id = 'ECDOC_PACK';


          ln_line:= insertDocTempText(ln_line, '<HTML>');
          ln_line:= insertDocTempText(ln_line, '<BODY>');

--------------------------------------------------------------------------
--Table of context
		        ln_line:= insertDocTempText(ln_line, '<HR>Generated:   ' || TO_CHAR(EcDp_Date_Time.getCurrentSysdate, 'dd.mm.yyyy hh24:mi:ss') || '<BR>');
		        ln_line:= insertDocTempText(ln_line, '<H2>Table of context</H2><HR><BR>');

    ln_count := 0;

   FOR curPackage_name IN c_package_name LOOP

    FOR curPackage IN c_package(curPackage_name.object_name) LOOP


     IF curPackage.text LIKE '--<EC-DOC>%' THEN

        -- Probably start but because of known mistakes we also try to handle '--<EC-DOC>%' as stop
        -- of brackets

        IF ln_inside_brackets = 0 THEN

          ln_inside_brackets := 1;
          ln_verify_inside := 1;

        ELSIF ln_inside_brackets = 1 THEN -- We have to assume that this is end of documentation

          ln_inside_brackets := 0;

        END IF;

      ELSIF  curPackage.text LIKE '--</EC-DOC>%' THEN

         ln_inside_brackets := 0;


      ELSE

         IF ln_verify_inside = 1 THEN -- Check the next line to ensure that we really are inside a comment
                                      -- Assumming that next line also will be a comment starting with --

            IF NOT curPackage.text LIKE '--%' THEN

              ln_inside_brackets := 0;

            ELSE

              headtemp1:=curPackage.name;
              headtemp2:=curPackage.text;

            END IF;

            ln_verify_inside := 0 ;


         ELSIF ln_inside_brackets = 1 THEN

		 IF  UPPER(curPackage.text) LIKE '-- FUNCTION%' THEN

		     	 lv2_temp:= curPackage.text;

			 lv2_temp:= REPLACE(lv2_temp, ' ');
			 lv2_temp:= REPLACE(lv2_temp, '--');
		 	 lv2_temp:= SUBSTR(lv2_temp,10);

		         lv2_temp:= CONCAT('.',lv2_temp);
		         lv2_temp:= CONCAT(curPackage_name.object_name,lv2_temp);

		        ln_line:= insertDocTempText(ln_line, '<H5><A HREF="#' || ln_count || '">');
		        ln_line:= insertDocTempText(ln_line, lv2_temp);
		        ln_line:= insertDocTempText(ln_line, '</A></H5>');



		  ELSIF  UPPER(curPackage.text) LIKE '-- PROCEDURE%' THEN

		     	 lv2_temp:= curPackage.text;

			 lv2_temp:= REPLACE(lv2_temp, ' ');
			 lv2_temp:= REPLACE(lv2_temp, '--');
		 	 lv2_temp:= SUBSTR(lv2_temp,11);

		         lv2_temp:= CONCAT('.',lv2_temp);
		         lv2_temp:= CONCAT(curPackage_name.object_name,lv2_temp);

		        ln_line:= insertDocTempText(ln_line, '<H5><A HREF="#' || ln_count || '">');
		        ln_line:= insertDocTempText(ln_line, lv2_temp);
		        ln_line:= insertDocTempText(ln_line, '</A></H5>');


		   END IF;


         END IF;


      END IF;

	ln_count:= ln_count + 1;

      END LOOP;

	  ln_inside_brackets := 0;
	  ln_verify_inside := 0;

    END LOOP;

		        ln_line:= insertDocTempText(ln_line, '<HR>');

--------------------------------------------------------------------------
--BODY

    ln_count:= 0;

   FOR curPackage_name IN c_package_name LOOP

    FOR curPackage IN c_package(curPackage_name.object_name) LOOP


     IF curPackage.text LIKE '--<EC-DOC>%' THEN

        -- Probably start but because of known mistakes we also try to handle '--<EC-DOC>%' as stop
        -- of brackets

        IF ln_inside_brackets = 0 THEN

          ln_inside_brackets := 1;
          ln_verify_inside := 1;

        ELSIF ln_inside_brackets = 1 THEN -- We have to assume that this is end of documentation

          ln_inside_brackets := 0;

          ln_line:= insertDocTempText(ln_line, '<BR>');
          ln_line:= insertDocTempText(ln_line, '<HR>');


        END IF;

      ELSIF  curPackage.text LIKE '--</EC-DOC>%' THEN

         ln_inside_brackets := 0;

         ln_line:= insertDocTempText(ln_line, '<BR>');
         ln_line:= insertDocTempText(ln_line, '<HR>');



      ELSE

         IF ln_verify_inside = 1 THEN -- Check the next line to ensure that we really are inside a comment
                                      -- Assumming that next line also will be a comment starting with --

            IF NOT curPackage.text LIKE '--%' THEN

              ln_inside_brackets := 0;

            ELSE

              headtemp1:=curPackage.name;
              headtemp2:=curPackage.text;

            END IF;

            ln_verify_inside := 0 ;


         ELSIF ln_inside_brackets = 1 THEN

		 IF  UPPER(curPackage.text) LIKE '-- FUNCTION%' THEN

		     	 lv2_temp:= curPackage.text;

			 lv2_temp:= REPLACE(lv2_temp, ' ');
			 lv2_temp:= REPLACE(lv2_temp, '--');
		 	 lv2_temp:= SUBSTR(lv2_temp,10);

		         lv2_temp:= CONCAT('.',lv2_temp);
		         lv2_temp:= CONCAT(curPackage_name.object_name,lv2_temp);

		        ln_line:= insertDocTempText(ln_line, '<H3><A NAME="' || ln_count || '"></A>');
		        ln_line:= insertDocTempText(ln_line, lv2_temp);
		        ln_line:= insertDocTempText(ln_line, '</H3>');

		        ln_line:= insertDocTempText(ln_line, headtemp2);
		        ln_line:= insertDocTempText(ln_line, '<BR>');



		         ln_line:= insertDocTempText(ln_line, curPackage.text);
			 ln_line:= insertDocTempText(ln_line, '<BR>');


		  ELSIF  UPPER(curPackage.text) LIKE '-- PROCEDURE%' THEN

		     	 lv2_temp:= curPackage.text;

			 lv2_temp:= REPLACE(lv2_temp, ' ');
			 lv2_temp:= REPLACE(lv2_temp, '--');
		 	 lv2_temp:= SUBSTR(lv2_temp,11);

		         lv2_temp:= CONCAT('.',lv2_temp);
		         lv2_temp:= CONCAT(curPackage_name.object_name,lv2_temp);

		        ln_line:= insertDocTempText(ln_line, '<H3><A NAME="' || ln_count || '"></A>');
		        ln_line:= insertDocTempText(ln_line, lv2_temp);
		        ln_line:= insertDocTempText(ln_line, '</H3>');

		        ln_line:= insertDocTempText(ln_line, headtemp2);
		        ln_line:= insertDocTempText(ln_line, '<BR>');


		         ln_line:= insertDocTempText(ln_line, curPackage.text);
			 ln_line:= insertDocTempText(ln_line, '<BR>');

		   ELSE

			ln_line:= insertDocTempText(ln_line, curPackage.text);
			ln_line:= insertDocTempText(ln_line, '<BR>');

		   END IF;


         END IF;


      END IF;

	ln_count:= ln_count + 1;

      END LOOP;

	  ln_inside_brackets := 0;
	  ln_verify_inside := 0;

    END LOOP;

          ln_line:= insertDocTempText(ln_line, '</HTML>');
          ln_line:= insertDocTempText(ln_line, '</BODY>');



  END ExtractPacageDocumentation;

END EcDp_PackageDoc;
--</PACKAGES>