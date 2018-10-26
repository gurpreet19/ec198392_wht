CREATE OR REPLACE PACKAGE EcDp_AlertLog IS

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : deprecate
-- Description    : Insert entry in t_alert_log with type='DEPRECATED' using AUTONOMOUS TRANSACTION:
--
--                     t_alert_log.type:    'DEPRECATED'
--                     t_alert_log.origin:  <name of caller function/procedure>
--                     t_alert_log.message: p_message
--                     t_alert_log.context: <call stack w/parameters (if registered)>
--
--                  Note that t_alert_log.context will list any parameters that have been
--                  registered prior to the deprecate call. The deprecate procedure will
--                  clear the parameters after they have been logged.
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   : t_alert_log
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE deprecate(p_message IN VARCHAR2)
--</EC-DOC>
;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : clearParams
-- Description    : It should not be neccessary to call this function explicitly, since parameters
--                  are cleared by the deprecate call.
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE clearParams
--</EC-DOC>
;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : addParam
-- Description    : Register parameter name/value pair for use by deprecate function.
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE addParam(p_name IN VARCHAR2, p_value IN VARCHAR2)
--</EC-DOC>
;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : addParam
-- Description    : Register parameter name/value pair for use by deprecate function.
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE addParam(p_name IN VARCHAR2, p_value IN NUMBER)
--</EC-DOC>
;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : addParam
-- Description    : Register parameter name/value pair for use by deprecate function.
--
-- Preconditions  : None
-- Postcondition  :
-- Using Tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------
PROCEDURE addParam(p_name IN VARCHAR2, p_value IN DATE)
--</EC-DOC>
;

END EcDp_AlertLog;