CREATE OR REPLACE PACKAGE EcDp_Stream_ORF_Value IS
/******************************************************************************************
** Package        :  EcDp_Stream_ORF_Value, header part
**
** $Revision: 1.2 $
**
** Purpose        :  This package is responsible for data access to strm_orf_component
**
** Documentation  :  www.energy-components.com
**
** Created        :  25.04.2006  Jerome Chong
**
** Modification history:
**
** Date        Whom    Change description:
** ----------  ------  ----------------------------------------------------------------
** 25.04.2006  Jerome  Initial Version
** 28.09.2007  rajarsar ECPD#6052: Updated copyToNewDaytime.
** 05.01.2016  abdulmaw ECPD-32161: Updated copyToNewDaytime to exclude created and last updated info copied to new set
******************************************************************************************/

PROCEDURE copyToNewDaytime (
   p_object_id    stream.object_id%TYPE,
   p_daytime      DATE,
   p_orf_type     VARCHAR2,
   p_user_id      VARCHAR2      DEFAULT NULL);

END EcDp_Stream_ORF_Value;