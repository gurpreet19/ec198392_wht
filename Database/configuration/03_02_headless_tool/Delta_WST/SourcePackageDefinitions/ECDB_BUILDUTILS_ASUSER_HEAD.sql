CREATE OR REPLACE PACKAGE ecdb_buildutils_asuser AUTHID CURRENT_USER AS

PROCEDURE SyncPrivateSynonyms;

END;