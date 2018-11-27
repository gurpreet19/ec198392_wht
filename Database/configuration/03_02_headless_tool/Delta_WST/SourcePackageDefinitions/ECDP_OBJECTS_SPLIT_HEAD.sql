CREATE OR REPLACE PACKAGE EcDp_Objects_Split IS

/****************************************************************
** Package        :  EcDp_Objects_Split, body part
**
** $Revision: 1.8 $
**
** Purpose        :  Provide basic functions on objects
**
** Documentation  :  www.energy-components.com
**
** Created  : 19.01.2004  Sven Harald Nilsen
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
**  28.09.2006 zakiiari   TI#2610: Add SetSplitEndDate procedure
**  09.05.2007 rajarsar   ECPD-5231: Add SetInsertSplitEndDate procedure
**  12.11.2007 ismaiime   ECPD-6222: Add new parameter p_allow_zero to procedure ValidateValues
**  02.02.2011 musthram   ECPD-16901: Equity Share - Support for fluid types
**  18.03.2011 rajarsar   ECPD-16901: Updated createNewShare to support different phases
**  03.02.2012 musthram   ECPD-19862: Updated SetSplitEndDate to set split end date only for selected phase
****************************************************************/

TYPE t_number_list IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

PROCEDURE CreateNewShare(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2,
        p_phase              VARCHAR2 DEFAULT NULL);


PROCEDURE ValidateShare(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2,
        p_phase               VARCHAR2 DEFAULT NULL
        );


PROCEDURE ValidateColumn(
                p_column_name   VARCHAR2,
                p_table_name    VARCHAR2,
                p_object_id     VARCHAR2,
                p_daytime       DATE,
                p_phase         VARCHAR2 DEFAULT NULL,
                p_class_name    VARCHAR2 DEFAULT NULL
                );

PROCEDURE ValidateValues( p_value_list    t_number_list,
                          p_count         NUMBER,
                          p_column_name   VARCHAR2,
                          p_allow_zero	  VARCHAR2 DEFAULT 'N');

PROCEDURE SetSplitEndDate(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2,
		p_phase               VARCHAR2 DEFAULT NULL
        );

PROCEDURE SetInsertSplitEndDate(
        p_owner_object_id     VARCHAR2,
        p_daytime             DATE,
        p_class_name          VARCHAR2
        );


END EcDp_Objects_Split;