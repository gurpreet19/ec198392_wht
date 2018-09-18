CREATE OR REPLACE PACKAGE ec_generate_stream IS
/**************************************************************
** Package :               ec_generate_stream, header part
**
** Revision :              $Revision: 1.2 $
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
** 20040804 kaurrnar removed sysnam
***********************************************************************************************/
PROCEDURE create_dummy_head(p_function_name VARCHAR2);

PROCEDURE create_dummy_body(p_function_name VARCHAR2);

PROCEDURE generateDerivedStreams;

END ec_generate_stream;