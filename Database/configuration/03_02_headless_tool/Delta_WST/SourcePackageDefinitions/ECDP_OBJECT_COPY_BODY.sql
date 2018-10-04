CREATE OR REPLACE PACKAGE BODY Ecdp_Object_Copy IS

/********************************************************************************************************************************
** Package        :  Ecdp_Object_Copy, body part
**
** $Revision:
**
** Purpose        :  Provide copy function
**
** Documentation  :  www.energy-components.com
**
** Created  : 25.01.2010  Lau
**
** Modification history:
**
** Date         Whom  Change description:
** ----------   ----- --------------------------------------
** 12.02.2014   muhammah  ECPD-17241: Added function GetCopyObjectName
** 13.02.2014   sharawan  ECPD-17241: Added function genNewCntrObjCode. Modify substr for trimming OBJECT_CODE
**                                    to cater for only 32 char.
** 19.02.2014   sharawan  ECPD-17241: Added function genNewCntrObjName (generate Name for Copy Contract features)
** 10.10.2014	muhammah  ECPD-28780: Updated function genNewCntrObjCode when the new object_code >=31
**********************************************************************************************************************************/

FUNCTION GetCopyObjectCode
         (p_class_name VARCHAR2,
         p_object_copy_code VARCHAR2,
         p_class_type VARCHAR2 DEFAULT 'OBJECT')
RETURN VARCHAR2
--</EC-DOC>
IS

   ln_code_counter NUMBER := 2;
   ln_count_rec NUMBER;
   lv2_new_object_code VARCHAR2(32) := NULL;
   lv2_object_code VARCHAR2(32) := NULL;
   lv2_class_prefix VARCHAR2(3);

BEGIN


    IF p_class_type = 'OBJECT' THEN
      lv2_class_prefix := 'OV_';
    ELSIF p_class_type = 'TABLE' THEN
      lv2_class_prefix := 'TV_';
    ELSIF p_class_type = 'DATA' THEN
      lv2_class_prefix := 'DV_';
    END IF;

   -- First check if default value is in use
    IF length(p_object_copy_code) <= 32 THEN
        lv2_object_code := p_object_copy_code;
    ELSE
        lv2_new_object_code := substr(p_object_copy_code,1,31 - (length('_COPY'))) || '_COPY';
        lv2_object_code := lv2_new_object_code;
    END IF;

    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || lv2_class_prefix || p_class_name || ' WHERE CODE='|| ''''|| lv2_object_code ||'''' INTO ln_count_rec;

   IF ln_count_rec > 0 THEN
      -- Loop until a new code is found
    WHILE ln_code_counter < 100 LOOP
         IF length(p_object_copy_code || ln_code_counter) <= 32 THEN
            lv2_object_code := p_object_copy_code;
         ELSE
            lv2_new_object_code := substr(p_object_copy_code,1,31 - (length('_COPY'|| ln_code_counter))) || '_COPY';
            lv2_object_code := lv2_new_object_code;
         END IF;

         EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || lv2_class_prefix || p_class_name || ' WHERE CODE='|| ''''|| lv2_object_code ||'''' || '||' || ln_code_counter INTO ln_count_rec;

         IF ln_count_rec = 0 THEN
            IF length(p_object_copy_code || ln_code_counter) <= 32 THEN
               RETURN p_object_copy_code || ln_code_counter;
            ELSE
               lv2_new_object_code := substr(p_object_copy_code,1,31 - (length('_COPY'|| ln_code_counter))) || '_COPY';
               RETURN lv2_new_object_code || ln_code_counter;
            END IF;
          END IF;
         ln_code_counter := ln_code_counter + 1;
      END LOOP;
   ELSE
      -- Object Code is not in use
      IF length(p_object_copy_code) <= 32 THEN
         RETURN p_object_copy_code;
      ELSE
         lv2_new_object_code := substr(p_object_copy_code,1,31 - (length('_COPY'))) || '_COPY';
         RETURN lv2_new_object_code;
      END IF;
   END IF;

END GetCopyObjectCode;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  GetCopyObjectName
-- Description    :  return copy name of the copied object
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------

FUNCTION GetCopyObjectName
         (p_class_name VARCHAR2,
         p_object_copy_name VARCHAR2,
         p_class_type VARCHAR2 DEFAULT 'OBJECT')
RETURN VARCHAR2
--</EC-DOC>
IS

   ln_code_counter NUMBER := 2;
   ln_count_rec NUMBER;
   lv2_new_object_name VARCHAR2(240) := NULL;
   lv2_object_name VARCHAR2(240) := NULL;
   lv2_class_prefix VARCHAR2(3);

BEGIN


    IF p_class_type = 'OBJECT' THEN
      lv2_class_prefix := 'OV_';
    ELSIF p_class_type = 'TABLE' THEN
      lv2_class_prefix := 'TV_';
    ELSIF p_class_type = 'DATA' THEN
      lv2_class_prefix := 'DV_';
    END IF;

   -- First check if default value is in use
    IF length(p_object_copy_name) <= 240 THEN
        lv2_object_name := p_object_copy_name;
    ELSE
        lv2_new_object_name := substr(p_object_copy_name,1,240 - (length('_COPY'))) || '_COPY';
        lv2_object_name := lv2_new_object_name;
    END IF;

    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || lv2_class_prefix || p_class_name || ' WHERE NAME='|| ''''|| lv2_object_name ||'''' INTO ln_count_rec;

   IF ln_count_rec > 0 THEN
      -- Loop until a new name is found
    WHILE ln_code_counter < 100 LOOP
         IF length(p_object_copy_name || ln_code_counter) <= 240 THEN
            lv2_object_name := p_object_copy_name;
         ELSE
            lv2_new_object_name := substr(p_object_copy_name,1,240 - (length('_COPY'|| ln_code_counter))) || '_COPY';
            lv2_object_name := lv2_new_object_name;
         END IF;

         EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || lv2_class_prefix || p_class_name || ' WHERE NAME='|| ''''|| lv2_object_name ||'''' || '||' || ln_code_counter INTO ln_count_rec;

         IF ln_count_rec = 0 THEN
            IF length(p_object_copy_name || ln_code_counter) <= 240 THEN
               RETURN p_object_copy_name || ln_code_counter;
            ELSE
               lv2_new_object_name := substr(p_object_copy_name,1,240 - (length('_COPY'|| ln_code_counter))) || '_COPY';
               RETURN lv2_new_object_name || ln_code_counter;
            END IF;
          END IF;
         ln_code_counter := ln_code_counter + 1;
      END LOOP;
   ELSE
      -- Object Name is not in use
      IF length(p_object_copy_name) <= 240 THEN
         RETURN p_object_copy_name;
      ELSE
         lv2_new_object_name := substr(p_object_copy_name,1,240 - (length('_COPY'))) || '_COPY';
         RETURN lv2_new_object_name;
      END IF;
   END IF;

END GetCopyObjectName;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  genNewCntrObjCode
-- Description    :  Generate new Contract related Objects Object Code based on the new Contract code (copy contract) and old contract
--                   code.
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------

FUNCTION genNewCntrObjCode (p_old_contract_code VARCHAR2, p_new_contract_code VARCHAR2, p_old_object_code VARCHAR2, p_class_name VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS
   lv2_gen_code VARCHAR2(50);
   lv2_new_code VARCHAR2(32);

BEGIN
   IF (INSTR(p_old_object_code, p_old_contract_code) > 0) AND p_new_contract_code IS NOT NULL THEN
      -- Replace Code with New Contract Code if The Code is Related to COntract COde
      lv2_gen_code := REPLACE(p_old_object_code, p_old_contract_code, p_new_contract_code);

      IF length(lv2_gen_code) >= 31 THEN
         --if the length after replaced wiht new contract it exceeds 31 char
         --use old object_code, trim and append with copy
         lv2_gen_code := substr(p_old_object_code,1,20);
         lv2_gen_code :=lv2_gen_code || '_COPY';
         --checking for duplicate
         lv2_new_code := GetCopyObjectCode(p_class_name, lv2_gen_code, ec_class_cnfg.class_type(p_class_name));
      ELSE
          lv2_new_code := lv2_gen_code;
      END IF;

   ELSE
     --if new contract not related at all
      lv2_gen_code := p_old_object_code || '_COPY';
      -- Trim if it exceeds 32 char and Append COPY2 if it is duplicate
      lv2_new_code := GetCopyObjectCode(p_class_name, lv2_gen_code, ec_class_cnfg.class_type(p_class_name));
   END IF;

  RETURN lv2_new_code;

END genNewCntrObjCode;

--<EC-DOC>
-------------------------------------------------------------------------------------------------
-- Function      :  genNewCntrObjName
-- Description    :  Generate new Contract related Objects Object Name based on the new Contract Name (copy contract) and old contract
--                   Name.
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
-------------------------------------------------------------------------------------------------

FUNCTION genNewCntrObjName (p_old_contract_name VARCHAR2, p_new_contract_name VARCHAR2, p_old_object_name VARCHAR2, p_class_name VARCHAR2)
RETURN VARCHAR2
--</EC-DOC>

IS
   lv2_gen_name VARCHAR2(240);
   lv2_new_name VARCHAR2(240);
BEGIN
   IF (INSTR(p_old_object_name, p_old_contract_name) > 0) AND p_new_contract_name IS NOT NULL THEN
      -- Replace Code with New Contract Code if The Code is Related to COntract COde
      lv2_gen_name := REPLACE(p_old_object_name, p_old_contract_name, p_new_contract_name);
      -- Trim if it exceeds 240 char
      lv2_new_name := substr(lv2_gen_name,1,239);
   ELSE
      lv2_gen_name := p_old_object_name || ' Copy';
      -- Trim if it exceeds 240 char and Append Copy2 if it is duplicate
      lv2_new_name := GetCopyObjectName(p_class_name, lv2_gen_name, ec_class_cnfg.class_type(p_class_name));
   END IF;

  RETURN lv2_new_name;

END genNewCntrObjName;

END Ecdp_Object_Copy;