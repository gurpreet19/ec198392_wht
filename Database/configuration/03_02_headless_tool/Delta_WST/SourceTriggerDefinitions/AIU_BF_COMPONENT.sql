CREATE OR REPLACE EDITIONABLE TRIGGER "AIU_BF_COMPONENT" 
AFTER UPDATE ON BF_COMPONENT
BEGIN
   -- $Revision: 1.4 $
   -- Common
  EcDp_Business_function.updateBCList();

END;