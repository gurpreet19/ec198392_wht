CREATE OR REPLACE PACKAGE EcDp_change_logging IS
/****************************************************************
** Package        :  EcDp_object_logging, header part
**
** $Revision: 1.3 $
**
** Purpose        :  Provide special functions on Financials Periods
**
** Documentation  :  www.energy-components.com
**
** Created  : 11.02.2008
**
** Modification history:
**
** Version  Date     Whom  Change description:
** -------  ------   ----- --------------------------------------
*****************************************************************/

TYPE t_logging_rec IS RECORD
  (
    class_name          VARCHAR2(32),
    object_id           VARCHAR2(32),
    row_id              VARCHAR2(2000),
    attribute           VARCHAR2(32),
    old_value           VARCHAR2(2000),
    new_value           VARCHAR2(2000),
    last_updated_by     VARCHAR2(100),
    last_updated_date   DATE,
    rev_no              VARCHAR2(7),
    rev_text            VARCHAR2(240),
    rec_id              VARCHAR2(32)
);

TYPE t_logging_tab IS TABLE OF t_logging_rec;

PROCEDURE AddClassChanges(
    p_class_name          VARCHAR,
    p_object_id           VARCHAR2,
    p_row_id              VARCHAR2,
    p_attribute           VARCHAR2,
    p_old_value           VARCHAR2,
    p_new_value           VARCHAR2,
    p_last_updated_by     VARCHAR2,
    p_last_updated_date   DATE,
    p_rev_no              VARCHAR2,
    p_rev_text            VARCHAR2,
    p_rec_id              VARCHAR2
)
;


FUNCTION getlogging(
           p_classlist  VARCHAR2,
           p_from_date  DATE,
           p_to_date    DATE,
           p_user_id    VARCHAR2 DEFAULT NULL
)
RETURN t_logging_tab PIPELINED ;

p_tab  t_logging_tab;


END EcDp_change_logging;