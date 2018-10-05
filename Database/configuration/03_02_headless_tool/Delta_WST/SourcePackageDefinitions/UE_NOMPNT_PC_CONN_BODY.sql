CREATE OR REPLACE PACKAGE BODY ue_Nompnt_Pc_Conn IS
    /****************************************************************
    ** Package        :  ue_Nompnt_Pc_Conn; body part
    **
    ** $Revision: 1.2 $
    **
    ** Purpose        :
    **
    ** Documentation  :  www.energy-components.com
    **
    ** Created        :  19.04.2011 Kari Sandvik
    **
    ** Modification history:
    **
    ** Date        Whom  Change description:
    ** ----------  ----- -------------------------------------------

    **************************************************************************************************/

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Procedure      : moveProfitCentre
    -- Description    :
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : nompnt_pc_company
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE moveProfitCentre(p_daytime          DATE,
                               p_profit_centre_id VARCHAR2,
                               p_nompnt_id        VARCHAR2,
                               p_company_id       VARCHAR2,
                               p_new_nompnt_id    VARCHAR2)
    --</EC-DOC>
     IS

    BEGIN
        -- insert new record
        INSERT INTO nompnt_pc_company
            (object_id, profit_centre_id, company_id, daytime, created_by)
        VALUES
            (p_new_nompnt_id, p_profit_centre_id, p_company_id, p_daytime, ecdp_context.getAppUser);

        -- update existing records with end date
        UPDATE nompnt_pc_company
           SET end_date = p_daytime, last_updated_by = ecdp_context.getAppUser
         WHERE object_id = p_nompnt_id
           AND profit_centre_id = p_profit_centre_id
           AND company_id = p_company_id
           AND end_date is null;

    END moveProfitCentre;

    --<EC-DOC>
    ---------------------------------------------------------------------------------------------------
    -- Procedure      : connectProfitCentre
    -- Description    :
    --
    -- Preconditions  :
    -- Postconditions :
    --
    -- Using tables   : nompnt_pc_company
    --
    -- Using functions:
    --
    -- Configuration
    -- required       :
    --
    -- Behaviour      :
    --
    ---------------------------------------------------------------------------------------------------
    PROCEDURE connectProfitCentre(p_daytime          DATE,
                                  p_profit_centre_id VARCHAR2,
                                  p_nompnt_id        VARCHAR2,
                                  p_company_id       VARCHAR2,
								  p_priority_split    NUMBER)
    --</EC-DOC>
     IS

    BEGIN
        -- insert new record
        INSERT INTO nompnt_pc_company
            (object_id, profit_centre_id, company_id, daytime, priority_pct, created_by)
        VALUES
            (p_nompnt_id, p_profit_centre_id, p_company_id, p_daytime, p_priority_split, ecdp_context.getAppUser);
    END connectProfitCentre;

END ue_Nompnt_Pc_Conn;