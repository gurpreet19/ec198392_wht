CREATE OR REPLACE PACKAGE EcDp_XLS_Reports IS
/****************************************************************
** Package        :  EcDp_XLS_Reports, header part
**
** $Revision: 1.2 $
**
** Purpose        :  Support functions for Excel based calculations.
**
** Documentation  :  www.energy-components.com
**
** Created  : 17.02.2009  Bent Ivar Helland
**
** Modification history:
**
** Date        Who  Change description:
** ----------  ---- --------------------------------------
** 2009-02-17  BIH  Initial version
*****************************************************************/


FUNCTION getObjectTypeLabel (
   p_object_id                      VARCHAR2,
   p_object_type_code               VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getObjectTypeLabel, WNDS, WNPS, RNPS);

--

FUNCTION getSetDescription(
   p_rept_context_id   VARCHAR2,
   p_set_name          VARCHAR2,
   p_object_type_code  VARCHAR2,
   p_set_type          VARCHAR2,
   p_set_op_name       VARCHAR2,
   p_order_dir         VARCHAR2,
   p_order_by          VARCHAR2,
   p_desc_override     VARCHAR2,
   p_operator          VARCHAR2,
   p_element_time_scope_code VARCHAR2,
   p_set_time_scope_code     VARCHAR2
)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(getSetDescription, WNDS, WNPS, RNPS);

--

END EcDp_XLS_Reports;