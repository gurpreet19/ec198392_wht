CREATE OR REPLACE PACKAGE EcDp_Maintain_Mappings_update IS
/***********************************************************************
** Package            :  EcDp_Maintain_Mappings_update
**
** $Revision: 1.0 $
**
** Purpose            :  Provide function to do bulk update on many mapping tags
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 04.04.2017  Semere Ghebregiorgish
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
** 1.0      04.04.2017  SVN   Initial version
***************************************************************************/

    FUNCTION DoBulkUpdate(
        p_last_transfer_string		     VARCHAR2 DEFAULT NULL,
        p_from_date_string                   VARCHAR2 DEFAULT NULL,
        p_to_date_string                     VARCHAR2 DEFAULT NULL,
        p_active                             VARCHAR2 DEFAULT NULL,
        p_tag_id                             VARCHAR2 DEFAULT NULL,
        p_source_id                          VARCHAR2 DEFAULT NULL,
        p_attribute                          VARCHAR2 DEFAULT NULL,
        p_data_class                         VARCHAR2 DEFAULT NULL,
        p_object_id                          VARCHAR2 DEFAULT NULL,
        p_template_code                      VARCHAR2 DEFAULT NULL,
        p_tag_status                         VARCHAR2 DEFAULT NULL
        )
    RETURN VARCHAR2;

END EcDp_Maintain_Mappings_update;