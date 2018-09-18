CREATE OR REPLACE PACKAGE ecdb_buildutils AS

PROCEDURE CreateMissingGrants(p_role_name IN VARCHAR2, p_role_type IN VARCHAR2);

END;