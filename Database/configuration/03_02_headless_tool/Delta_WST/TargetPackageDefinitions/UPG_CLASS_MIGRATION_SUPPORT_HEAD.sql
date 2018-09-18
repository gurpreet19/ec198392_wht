CREATE OR REPLACE PACKAGE upg_Class_Migration_Support IS
/**************************************************************
** Package:    upg_Class_Migration_Support
**
** $Revision: 1.39 $
**
** Filename:   upg_Class_Migration_Support_head.sql
**
** Part of :   EC Kernel
**
** Purpose: Utility functions used during copy from CLASS_xxx to CLASS_xxx_CNFG tables
**          especially for normalizing presentation properties and verify copy against
**          old table structure
**
** General Logic:
**
** Document References:
**
**
** Created:     25.11.2016  Arild Vervik, EC
**
**
**************************************************************/
Procedure CopyClassToNewStructure;
--PROCEDURE ClassMigrationStatistic;
Procedure RemoveIdenticalProperties(p_high_owner_cntx number,
                                    p_low_owner_cntx number,
                                    p_property_table_name varchar2 default null,
                                    p_property_type varchar2 default null,
                                    p_property_code varchar2 default null);

Procedure DeleteUpdPropreties(p_option number);
-- This procedure can be run with 2 different options
--2) Remove the once that is equal to the value from 11.1SP3
--3) Remove the once that is equal to 11.1SP3 and EC 11.2 (Default)

Procedure DeletePrevECPropreties;

END;