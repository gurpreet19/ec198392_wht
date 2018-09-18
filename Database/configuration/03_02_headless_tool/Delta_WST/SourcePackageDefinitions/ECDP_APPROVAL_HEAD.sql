CREATE OR REPLACE PACKAGE EcDp_Approval IS

/****************************************************************
** Package        :  EcDp_Approval, header part
**
** $Revision: 1.8 $
**
** Purpose        : Approval handling.
**
** Documentation  :  www.energy-components.com
**
** Created  : 19-Jun-2007
**
** Modification history:
**
**  Date     Whom  Change description:
**  ------   ----- --------------------------------------
** 19.06.07 HUS    Initial version of package
** 21.04.09 leeeewei Added new procedure BuildApprovalRecordViewType
*****************************************************************/

PROCEDURE Accept(
    p_rec_id      IN VARCHAR2,
    p_comments    IN VARCHAR2);

PROCEDURE Reject(
    p_rec_id      IN VARCHAR2,
    p_comments    IN VARCHAR2);

-- User by generated IU triggers to check whether call came from one of the approval functions.
FUNCTION InApprovalMode RETURN BOOLEAN;

-- User by generated IU triggers to check whether call came from Accept function.
FUNCTION IsAccepting RETURN BOOLEAN;

-- User by generated IU triggers to check whether call came from Reject function.
FUNCTION IsRejecting RETURN BOOLEAN;

PROCEDURE registerTaskDetail(
    p_rec_id       IN VARCHAR2,
    p_class_name   IN VARCHAR2,
    p_user         IN VARCHAR2,
    p_del_callback IN VARCHAR2 DEFAULT NULL);

PROCEDURE deleteTaskDetail(
    p_rec_id      IN VARCHAR2);


PROCEDURE BuildApprovalRecordView;

FUNCTION hasRowAccess(p_class_name IN VARCHAR2,
                     p_rec_id     IN VARCHAR2)
        RETURN VARCHAR2;

PROCEDURE findMissingTaskDetailEntry(p_rec_id IN VARCHAR2,
                                    p_class_name IN OUT VARCHAR2,
                                    p_created_by IN OUT VARCHAR2,
                                    p_last_updated_by IN OUT VARCHAR2);

FUNCTION ChangedClassColumns(p_class_name IN VARCHAR2,
                             p_rec_id     IN VARCHAR2)
        RETURN VARCHAR2;

PROCEDURE BuildApprovalRecordViewType(p_include_all VARCHAR2 DEFAULT 'N');

END EcDp_Approval;