CREATE OR REPLACE EDITIONABLE TRIGGER "D_CONT_DOCUMENT" 
BEFORE DELETE ON CONT_DOCUMENT
FOR EACH ROW

DECLARE

locked_record EXCEPTION;

TYPE t_status_list IS TABLE OF VARCHAR2(32);

ltab_status_list t_status_list := t_status_list('OPEN', 'VALID1', 'VALID2', 'TRANSFER', 'BOOKED');

BEGIN

         IF :New.DOCUMENT_LEVEL_CODE <> ltab_status_list(1) THEN

            RAISE locked_record;

         END IF;

EXCEPTION

	   WHEN locked_record THEN

		 	  RAISE_APPLICATION_ERROR(-20000,'Cannot change a document unless OPEN for: ' || Nvl(Ec_Contract.object_code(:New.object_id) , ' ') || '    ' || Nvl( Ec_Contract_Version.name(:New.object_id,:New.Daytime,'<='), ' ')  || '  ' || Nvl(:New.document_key,' ') ) ;

END;
