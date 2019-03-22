CREATE OR REPLACE PACKAGE BODY EcDp_Object_List IS

    CURSOR object_list_setup_share(
         cp_object_id                      object_list.object_id%TYPE
        ,cp_daytime                        object_list_setup.daytime%TYPE
        )
    IS
        SELECT generic_object_code, split_share
          FROM object_list_setup
         WHERE object_id = cp_object_id
           AND daytime <= cp_daytime
           AND nvl(end_date, cp_daytime+1) > cp_daytime
           AND daytime = (
                 SELECT MAX(sols.daytime)
                   FROM object_list_setup sols
                  WHERE sols.generic_object_code = object_list_setup.generic_object_code
                    AND sols.object_id = object_list_setup.object_id
                    AND sols.DAYTIME <= cp_daytime
                    AND NVL(sols.END_DATE, cp_daytime + 1 ) > cp_daytime
                    );
    ----+----------------------------------+-------------------------------
    -----------------------------------------------------------------------
    -- Gets a value indicating whether a given code exists in a object list.
    --
    -- p_code:                 The code to search for.
    -- p_code_class_name:      The class name of the code. If null is given,
    --     all code in the list setup are searched, instead of code from
    --     the given class.
    -- p_code_ec_type:         When searching a object list consists of EC Code
    --     Objects, and p_check_linked_ec_code is 'Y', this parameter
    --     indicates what EC Code Type to search for.
    -- p_check_linked_ec_code: When searching a object list consists of EC
    --     Code Objects, this inidicates whether to compare the given code
    --     with EC Code Object code or the EC Code it links to.
    -- p_object_list_code:     The object list to search in.
    -- p_daytime:              The object list version.
    ----+----------------------------------+-------------------------------
    FUNCTION IsInObjectList(
         p_code                            objects.code%TYPE
        ,p_code_class_name                 objects.class_name%TYPE
        ,p_code_ec_type                    prosty_codes.code_type%TYPE
        ,p_check_linked_ec_code            ecdp_revn_common.T_BOOLEAN_STR
        ,p_object_list_code                object_list.object_code%TYPE
        ,p_daytime                         object_list_version.daytime%TYPE
        )
    RETURN ecdp_revn_common.T_BOOLEAN_STR
    IS
        CURSOR object_list_item(
             cp_code                       objects.code%TYPE
            ,cp_class_name                 objects.class_name%TYPE
            ,cp_ec_code_type               prosty_codes.code_type%TYPE
            ,cp_check_linked_ec_code       ecdp_revn_common.T_BOOLEAN_STR
            ,cp_object_list_code           object_list.object_code%TYPE
            ,cp_daytime                    object_list_version.daytime%TYPE
            )
        IS
            SELECT setup.generic_object_code
            FROM object_list_setup setup, object_list list
            WHERE setup.object_id = list.object_id
                AND list.object_code = cp_object_list_code
                AND setup.daytime <= cp_daytime
                AND NVL(setup.end_date, cp_daytime + 1) > cp_daytime
                AND (cp_class_name IS NULL OR setup.generic_class_name = cp_class_name)
                AND (setup.generic_class_name = 'EC_CODE_OBJECT' OR setup.generic_object_code = cp_code)
                AND (setup.generic_class_name <> 'EC_CODE_OBJECT'
                    OR (cp_check_linked_ec_code = ecdp_revn_common.gv2_true
                        AND EXISTS(
                            SELECT *
                            FROM ec_code_object ec_code_obj, ec_code_object_version ec_code_obj_ver
                            WHERE ec_code_obj.object_id = ec_code_obj_ver.object_id
                                AND ec_code_obj_ver.ec_code = cp_code
                                AND NVL(cp_ec_code_type, ec_code_obj_ver.ec_code_type) = ec_code_obj_ver.ec_code_type
                                AND ec_code_obj_ver.daytime <= setup.daytime
                                AND (setup.end_date IS NULL OR setup.end_date < NVL(ec_code_obj_ver.end_date, setup.end_date + 1))
                        )
                    )
                    OR (cp_check_linked_ec_code = ecdp_revn_common.gv2_false
                        AND setup.generic_object_code = cp_code
                    )
                );
    BEGIN
        FOR lci_list_item IN object_list_item(
                                     p_code
                                    ,p_code_class_name
                                    ,p_code_ec_type
                                    ,p_check_linked_ec_code
                                    ,p_object_list_code
                                    ,p_daytime
                                    )
        LOOP
            RETURN ecdp_revn_common.gv2_true;
        END LOOP;

        RETURN ecdp_revn_common.gv2_false;

    END IsInObjectList;


    FUNCTION ContainsSplitShares(
         p_object_id                        object_list.object_id%TYPE
        ,p_daytime                          object_list_setup.daytime%TYPE
        )
    RETURN ecdp_revn_common.T_BOOLEAN_STR
    IS
    BEGIN
        FOR obs_share IN object_list_setup_share(p_object_id, p_daytime) LOOP
            IF obs_share.split_share IS NOT NULL AND obs_share.split_share > 0 THEN
                RETURN ecdp_revn_common.gv2_true;
            END IF;
        END LOOP;
        RETURN ecdp_revn_common.gv2_false;
    END ContainsSplitShares;

    FUNCTION ShareIsHundred(
         p_object_id                       object_list.object_id%TYPE
        ,p_daytime                         object_list_setup.daytime%TYPE
        )
    RETURN ecdp_revn_common.T_BOOLEAN_STR
    IS
        ln_share_total                     NUMBER := 0;
    BEGIN
        FOR obs_share IN object_list_setup_share(p_object_id, p_daytime) LOOP
            ln_share_total := ln_share_total + nvl(obs_share.split_share, 0);
        END LOOP;

        IF ln_share_total = 100 THEN
            RETURN ecdp_revn_common.gv2_true;
        END IF;
        RETURN ecdp_revn_common.gv2_false;

    END ShareIsHundred;
    ----+----------------------------------+-------------------------------
    -----------------------------------------------------------------------
    -- If split shares are entered,
    -- it checks that the split for an object list is 100.
    --
    -- p_object_id:             Object_id of the object list
    -- p_daytime:               Daytime for object list setup
    ----+----------------------------------+-------------------------------
    FUNCTION VerifySplitShare(
         p_object_id                        object_list.object_id%TYPE
        ,p_daytime                          object_list_setup.daytime%TYPE
        )
    RETURN ecdp_revn_common.T_BOOLEAN_STR
    IS
    BEGIN

        IF ContainsSplitShares(p_object_id, p_daytime) = ecdp_revn_common.gv2_true THEN
            IF ShareIsHundred(p_object_id, p_daytime) = ecdp_revn_common.gv2_true THEN
                RETURN ecdp_revn_common.gv2_true;
            END IF;
        END IF;

        RETURN ecdp_revn_common.gv2_false;
    END VerifySplitShare;
-------------------------------------------------------------------------------------------------------------------------------
-- Procedure    : CheckInsertDuplicate
-- Description  : Check object added in object list is not duplicate for valid period.
-- Using tables : Object_LIST_SETUP.
-- Behaviour    : Called when New object is added in object_list.
-------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE CheckInsertDuplicate(
                                p_object_id                        object_list.object_id%TYPE
                               ,p_generic_object_code              object_list_setup.generic_object_code%TYPE
                               ,p_daytime                          object_list_setup.daytime%TYPE
                               ,p_end_date                         object_list_setup.daytime%TYPE
                               ,p_relational_obj_code              object_list_setup.relational_obj_code%TYPE
                               ,p_rec_id                           object_list_setup.rec_id%TYPE
                               )

    IS
       lv_count                   NUMBER;
    BEGIN

     SELECT COUNT(ols.generic_object_code) INTO lv_count
     FROM object_list ol,object_list_setup ols
     WHERE ol.object_id=p_object_id
     AND ols.object_id=ol.object_id
     AND ols.generic_object_code=p_generic_object_code
     AND ols.rec_id IS NOT NULL
     AND ols.rec_id <> nvl(p_rec_id,ols.rec_id)

     AND NVL(ols.relational_obj_code,'xx')=NVL(p_relational_obj_code,'xx')

     AND (
           (
            --Checking if new daytime is inside another row
            ols.daytime <= p_daytime
            AND NVL(ols.end_date,p_daytime+1) > p_daytime
           ) OR (
            --Checking if new end_date is inside another row
            ols.daytime < nvl(p_end_date,ols.daytime)
            AND NVL(ols.end_date,nvl(p_end_date,ols.daytime)) >= nvl(p_end_date,NVL(ols.end_date,nvl(p_end_date,ols.daytime))+1)
           ) OR (
            --Checking if both new daytime and new end_date are covered by another row
            ols.daytime >= p_daytime
            AND NVL(ols.end_date,nvl(p_end_date,ols.daytime)) < nvl(p_end_date,NVL(ols.end_date,nvl(p_end_date,ols.daytime))+1)
           )
         );

     IF(lv_count > 0 ) THEN
        RAISE_APPLICATION_ERROR(-20000, 'Duplicate entries: Object code and relation code in the same period.');
     END IF;

END CheckInsertDuplicate;

PROCEDURE COPY_GROUP (p_object_id VARCHAR2 , p_group NUMBER) is

BEGIN
ecdp_dynsql.WriteTempText('COPY_GROUP','p_object_id:'||p_object_id||'    p_group:'||p_group);

      INSERT
      INTO COST_MAPPING_SRC_SETUP
          (
           OBJECT_ID,
           DAYTIME,
           SRC_TYPE,
           SRC_CODE,
           OPERATOR,
           SPLIT_KEY_SOURCE,
           GROUP_NO,
           OBJECT_TYPE )
       SELECT
            OBJECT_ID,
            DAYTIME,
            SRC_TYPE,
            SRC_CODE,
            OPERATOR,
            SPLIT_KEY_SOURCE,
            (SELECT MAX(GROUP_NO)
             FROM
                   COST_MAPPING_SRC_SETUP
            WHERE  OBJECT_ID = p_object_id
            )+1 Next_GROUP_NO,
            OBJECT_TYPE
          FROM
            COST_MAPPING_SRC_SETUP
          WHERE OBJECT_ID = p_object_id
                AND group_no = p_group
      ;


EXCEPTION
  WHEN OTHERS THEN
       NULL ;

end COPY_GROUP;


PROCEDURE insObject (
         p_object_code                     VARCHAR2
        ,p_object_class                    VARCHAR2
        ,p_daytime                         DATE
        ,p_end_date                        DATE DEFAULT NULL
        ,p_object_name                     VARCHAR2 DEFAULT NULL
		,p_desc                            VARCHAR2 DEFAULT NULL
		,p_gl_code                         VARCHAR2 DEFAULT NULL
        ) IS
    lv_object_name                         VARCHAR2(240);
BEGIN

    IF ecdp_objects.GetObjIDFromCode(p_object_class,p_object_code) is null THEN
        lv_object_name := NVL(p_object_name, p_object_code);

        CASE p_object_class
            WHEN 'FIN_WBS' THEN
                insert into ov_fin_wbs (code,name,daytime,object_end_date, DESCRIPTION, WBS, FIN_EXTERNAL_REF, created_by ) values (p_object_code,lv_object_name,p_daytime,p_end_date, p_desc, NVL(p_gl_code, p_object_code) , p_object_code, ecdp_context.getAppUser  );
            WHEN 'FIN_COST_CENTER' THEN
                insert into ov_fin_cost_center (code,name,daytime,object_end_date,DESCRIPTION, COST_CENTER, FIN_EXTERNAL_REF, created_by ) values (p_object_code,lv_object_name,p_daytime,p_end_date, p_desc,  NVL(p_gl_code, p_object_code) , p_object_code, ecdp_context.getAppUser  );
            WHEN 'FIN_REVENUE_ORDER' THEN
                insert into ov_fin_revenue_order (code,name,daytime,object_end_date,DESCRIPTION, REVENUE_ORDER, FIN_EXTERNAL_REF, created_by) values (p_object_code,lv_object_name,p_daytime,p_end_date, p_desc,  NVL(p_gl_code, p_object_code) , p_object_code, ecdp_context.getAppUser );
            WHEN 'FIN_ACCOUNT' THEN
                insert into ov_fin_account (code,name,daytime, fin_cost_objecT_type,gl_account,object_end_date,DESCRIPTION, created_by) values (p_object_code,lv_object_name,p_daytime,NVL(ec_ctrl_system_attribute.attribute_text(p_daytime,'DEFAULT_COST_OBJ_TYPE','<='),'N'),NVL(p_gl_code,p_object_code),p_end_date, p_desc, ecdp_context.getAppUser ) ;
            ELSE
                RAISE_APPLICATION_ERROR(-20001, 'Inserting objects is not supported for class ' || p_object_class);
        END CASE;
    END IF;
END;


PROCEDURE ObjectListUpload ( p_obj_list_rec IN V_OBJECT_LIST_UPLOAD%ROWTYPE  ) IS

v_object_id       VARCHAR2(40) := '';
val_to_udp        VARCHAR(20) := '';
v_UPD_START_DATE  VARCHAR(40) :='' ;
v_exist_flag      VARCHAR(1) :='';


BEGIN

	   IF
				 ( p_obj_list_rec.list_class <> 'FIN_WBS' AND
				   p_obj_list_rec.list_class <> 'FIN_ACCOUNT' AND
					 p_obj_list_rec.list_class <> 'FIN_COST_CENTER' AND
					 p_obj_list_rec.list_class <> 'FIN_REVENUE_ORDER')
		    THEN

     		 	 RAISE_APPLICATION_ERROR(-20001, 'Error :Supplied class '''|| p_obj_list_rec.list_class|| ''' not supported' );

		 END IF;

     IF p_obj_list_rec.List_action =  'INSERT' OR p_obj_list_rec.List_action =  'UPDATE' THEN

        SELECT  NVL(B.object_id,'INSERT' ) object_id , NVL(B.ANY_VAL_TO_UPD , 'INSERT') ANY_VAL_TO_UPD , NVL(B.UPD_START_DATE , 'N') UPD_START_DATE
        INTO v_object_id, val_to_udp, v_UPD_START_DATE
        FROM
        (SELECT '1' object_id , '2' ANY_VAL_TO_UPD ,'3' UPD_START_DATE, '1' col FROM dual )A
        LEFT OUTER JOIN
        (SELECT ol.object_id,
               CASE
                 WHEN (
                        olv.name != p_obj_list_rec.object_list_name OR
                        NVL(ol.description, '~')  != NVL(p_obj_list_rec.obj_list_desc , '~~')  OR
                        (
                         ol.end_date IS NOT NULL AND
                         p_obj_list_rec.end_date IS NOT NULL AND
                         ol.end_date != p_obj_list_rec.end_date
                        ) OR
                        (
                         ol.end_date IS NULL AND
                         p_obj_list_rec.end_date IS NOT NULL
                        ) OR
                        (
                         olv.end_date IS NOT NULL AND
                         p_obj_list_rec.revision_end_date IS NOT NULL AND
                         olv.end_date != p_obj_list_rec.revision_end_date
                        ) OR
                        (
                         olv.end_date IS NULL AND
                         p_obj_list_rec.revision_end_date IS NOT NULL
                        )
                      )
                 THEN 'Y'
               ELSE 'N'
               END ANY_VAL_TO_UPD,
			         CASE
				           WHEN(
                        ol.start_date IS NOT NULL AND
                        p_obj_list_rec.start_date IS NOT NULL AND
                        ol.start_date != p_obj_list_rec.start_date
                       )
                     THEN 'Y'
				             ELSE 'N'
			         END UPD_START_DATE,
              '1' col
              FROM
                  object_list_version olv,
                  object_list ol
              where
                  ol.object_id = olv.object_id
                  AND olv.daytime = (SELECT MAX(start_Date) FROM object_list_version olv_2 WHERE olv_2.object_id = ol.object_id )
                  AND olv.class_name = p_obj_list_rec.list_class
                  AND ol.object_code =p_obj_list_rec.object_list_code
              ) B
              ON A.col = B.col;

              IF v_UPD_START_DATE = 'Y' THEN

				-- Check validity of start date update from DV_COST_MAPPING_SRC_SETUP and Object_list_setup

			           	SELECT  NVL(B.Exist_flag,'N' ) Exist_flag
				          INTO v_exist_flag
				          FROM
                  (
				            (SELECT '1' Exist_flag , '1' col FROM dual )A
					          LEFT OUTER JOIN
				            (SELECT DISTINCT 'Y' Exist_flag, '1' col
            		     FROM OV_object_list ol
            		     WHERE
             		     CODE = p_obj_list_rec.object_list_code
                     AND
                     (
                      ( EXISTS
                        (
                          SELECT 1 FROM DV_COST_MAPPING_SRC_SETUP
                          WHERE SRC_TYPE = p_obj_list_rec.list_class
                          AND SRC_CODE =  p_obj_list_rec.object_list_code
                          AND DAYTIME < p_obj_list_rec.start_date
                        )
                      )
                      OR
                      (EXISTS
                       (
                         SELECT 1 FROM Object_list_setup
                         WHERE GENERIC_CLASS_NAME = p_obj_list_rec.list_class
                         AND object_id = ol.object_id
                         AND DAYTIME < p_obj_list_rec.start_date
                       )
                       )
                     )
										) B
			              ON A.col =b.col
			              );

		                IF v_exist_flag = 'Y' THEN

                        RAISE_APPLICATION_ERROR(-20001, 'Error : Object list Start date conflicts with Journal mapping setup  or Object list setup' );

		                END IF;
              END IF;


  	 IF val_to_udp = 'Y' THEN

			   UPDATE OV_object_list
			   SET  DESCRIPTION = p_obj_list_rec.obj_list_desc,
				      OBJECT_end_date = p_obj_list_rec.end_date,
				      NAME = p_obj_list_rec.object_list_name
			   WHERE
				      CODE = p_obj_list_rec.object_list_code ;

		 END IF;

		 IF v_UPD_START_DATE = 'Y' THEN

         UPDATE OV_object_list
         SET  object_start_date = p_obj_list_rec.start_date
         WHERE
              CODE = p_obj_list_rec.object_list_code ;
		 END IF;


		IF v_object_id = 'INSERT' THEN

			   INSERT INTO OV_object_list
			    (CODE, NAME, OBJECT_START_DATE, OBJECT_END_DATE, DAYTIME, END_DATE, DESCRIPTION, GENERIC_CLASS_NAME)
			   VALUES
				(p_obj_list_rec.object_list_code, p_obj_list_rec.object_list_name,p_obj_list_rec.start_date, p_obj_list_rec.end_date,
				 p_obj_list_rec.start_date, p_obj_list_rec.end_date, p_obj_list_rec.obj_list_desc, p_obj_list_rec.list_class
				) ;

	  END IF;

   END IF ;

	 v_exist_flag := '';


	 SELECT  NVL(B.Exist_flag,'N' ) Exist_flag
   INTO v_exist_flag
   FROM
   (
		(SELECT 	'1' Exist_flag, '1' col FROM dual)A
		LEFT OUTER JOIN
		(SELECT DISTINCT 'Y' Exist_flag, '1' col
		FROM OV_FIN_WBS O
		WHERE CODE = p_obj_list_rec.ec_code
		AND EXISTS
		(
		  SELECT * FROM object_list_setup
		  WHERE generic_class_NAME = p_obj_list_rec.list_class
		  AND generic_object_code =  p_obj_list_rec.ec_code
		  AND DAYTIME < p_obj_list_rec.object_start_date
		)
		) B
		ON
		A.col= B.col
	 );

					IF v_exist_flag = 'Y' THEN

            RAISE_APPLICATION_ERROR(-20001, 'Error : Object Start date conflicts with Object list setup configuration' );

					END IF;

					IF p_obj_list_rec.start_date > p_obj_list_rec.revision_date THEN

            RAISE_APPLICATION_ERROR(-20001, 'Error : Object List Start date cannot be greater than List Revision Start Date' );

					END IF;

					IF p_obj_list_rec.object_start_date > p_obj_list_rec.revision_date THEN

            RAISE_APPLICATION_ERROR(-20001, 'Error : Object Start date cannot be greater than List Revision Start Date' );

					END IF;

					 IF p_obj_list_rec.object_action = 'INSERT' THEN

  				  insObject (
						           p_obj_list_rec.ec_code,
						           p_obj_list_rec.list_class,
					             p_obj_list_rec.object_start_date ,
										   p_obj_list_rec.object_end_date,
										   p_obj_list_rec.object_name,
										   p_obj_list_rec.Obj_Descr,
										   NVL(p_obj_list_rec.fin_code,p_obj_list_rec.ec_code)
										  );

						 -- Insert into object_list_setup - The object is now part of the list
            IF EcDp_Object_List.IsInObjectList (p_obj_list_rec.ec_code, p_obj_list_rec.list_class, '', 'FALSE', p_obj_list_rec.object_list_code, p_obj_list_rec.object_start_date ) = 'N' THEN

              INSERT INTO object_list_setup (Object_Id, Generic_Class_Name, generic_object_code, daytime)
              VALUES ( ecdp_objects.GetObjIDFromCode(p_class_name => 'OBJECT_LIST' ,p_code => p_obj_list_rec.object_list_code) ,
                       p_obj_list_rec.list_class,p_obj_list_rec.ec_code,p_obj_list_rec.revision_date );

            END IF;


					 ELSIF p_obj_list_rec.object_action = 'UPDATE' THEN

					      CASE p_obj_list_rec.list_class
                WHEN 'FIN_WBS'   THEN

									   UPDATE OV_FIN_WBS
										 SET
										  NAME = p_obj_list_rec.object_name,
											OBJECT_START_DATE=p_obj_list_rec.object_start_date ,
										  OBJECT_END_DATE = p_obj_list_rec.object_end_date,
											DESCRIPTION = p_obj_list_rec.Obj_Descr,
											WBS = NVL(p_obj_list_rec.fin_code,p_obj_list_rec.ec_code)
											WHERE CODE = p_obj_list_rec.ec_code ;

                WHEN 'FIN_ACCOUNT'     THEN

                     UPDATE OV_FIN_ACCOUNT
                     SET
                      NAME = p_obj_list_rec.object_name,
                      OBJECT_START_DATE=p_obj_list_rec.object_start_date ,
                      OBJECT_END_DATE = p_obj_list_rec.object_end_date,
                      DESCRIPTION = p_obj_list_rec.Obj_Descr,
                      GL_ACCOUNT = NVL(p_obj_list_rec.fin_code,p_obj_list_rec.ec_code)
                      WHERE CODE = p_obj_list_rec.ec_code ;

					 	    WHEN 'FIN_COST_CENTER' THEN

								     UPDATE OV_FIN_COST_CENTER
                     SET
										  NAME = p_obj_list_rec.object_name,
                      OBJECT_START_DATE=p_obj_list_rec.object_start_date ,
                      OBJECT_END_DATE = p_obj_list_rec.object_end_date,
                      DESCRIPTION = p_obj_list_rec.Obj_Descr,
                      COST_CENTER = NVL(p_obj_list_rec.fin_code,p_obj_list_rec.ec_code)
                      WHERE CODE = p_obj_list_rec.ec_code ;

                WHEN 'FIN_REVENUE_ORDER'   THEN

									   UPDATE OV_FIN_REVENUE_ORDER
                     SET
										  NAME = p_obj_list_rec.object_name,
                      OBJECT_START_DATE=p_obj_list_rec.object_start_date ,
                      OBJECT_END_DATE = p_obj_list_rec.object_end_date,
                      DESCRIPTION = p_obj_list_rec.Obj_Descr,
                      REVENUE_ORDER = NVL(p_obj_list_rec.fin_code,p_obj_list_rec.ec_code)
                      WHERE CODE = p_obj_list_rec.ec_code ;

							END CASE;

					 END IF;

EXCEPTION
     WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Error : '|| SUBSTR(SQLERRM,1, 200) );

END ;


END EcDp_Object_List;