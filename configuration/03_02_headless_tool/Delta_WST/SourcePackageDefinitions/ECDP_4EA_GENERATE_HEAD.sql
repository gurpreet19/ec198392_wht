CREATE OR REPLACE PACKAGE ecdp_4ea_generate IS
/******************************************************************************
** Package        :  ec4ea_genvalidation, body part
**
** $Revision: 1.2 $
**
** Purpose        :  Generate 4 eyes approval packages for all ec classes
**
** Documentation  :  www.energy-components.com
**
** Created        :  23.12.2007
**
** Modification history:
**
** Date        Whom  Change description:
** ------      ----- ------------------------------------------------------------------------------
** 23.12.2007  AV    Initial version
********************************************************************/



PROCEDURE BuildEC4EA_PackageHeader(
				p_class_name				VARCHAR2,
				p_target						VARCHAR2 DEFAULT 'CREATE');

PROCEDURE BuildEC4EA_AllPackageHeader(
				p_class_name				VARCHAR2 DEFAULT NULL,
				p_target						VARCHAR2 DEFAULT 'CREATE');


PROCEDURE BuildEC4EA_PackageBody(
				p_class_name				VARCHAR2,
				p_target						VARCHAR2 DEFAULT 'CREATE');

PROCEDURE BuildEC4EA_AllPackageBodies(
				p_class_name				VARCHAR2 DEFAULT NULL,
				p_target						VARCHAR2 DEFAULT 'CREATE');


PROCEDURE BuildEC4EA_Package(
				p_class_name				VARCHAR2 DEFAULT NULL,
				p_target						VARCHAR2 DEFAULT 'CREATE');



END ecdp_4ea_generate;