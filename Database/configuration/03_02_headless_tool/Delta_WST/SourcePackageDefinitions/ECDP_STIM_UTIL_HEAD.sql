CREATE OR REPLACE PACKAGE EcDp_STIM_Util IS
/****************************************************************
** Package        :  EcDp_synchronize_reports
**
** $Revision: 1.6 $
**
** Purpose        :  Infrastructure setup is replicated to report tables
**                   for performance, these report tables need to be updated when the
**                   infrastructure changes, this package takes care of that
**
** Documentation  :  www.energy-components.com
**
** Created  : 08.01.2004  Arild Vervik
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
** See header section of package body
*****************************************************************/

PROCEDURE FullUpdate(
 p_scope   varchar2  default NULL,
 p_production_period DATE default NULL
)
;

TYPE t_elem IS TABLE OF VARCHAR2(240);

FUNCTION splitString(
  p_text VARCHAR2,
  p_delimiter VARCHAR2
  ) RETURN t_elem;

PROCEDURE SetPendingCalcStatus(
          p_pending_no NUMBER,
          p_period     VARCHAR2,
          p_pos        VARCHAR2 DEFAULT 'STARTING'
);

END EcDp_STIM_Util;