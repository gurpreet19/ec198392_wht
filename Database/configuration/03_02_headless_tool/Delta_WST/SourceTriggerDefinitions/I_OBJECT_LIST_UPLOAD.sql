CREATE OR REPLACE EDITIONABLE TRIGGER "I_OBJECT_LIST_UPLOAD" 
INSTEAD OF INSERT or UPDATE ON V_OBJECT_LIST_UPLOAD
FOR EACH ROW

DECLARE

  lrec V_OBJECT_LIST_UPLOAD%ROWTYPE;

BEGIN

lrec.LIST_CLASS      	:=  TRIM(:new.LIST_CLASS)             ;
lrec.LIST_ACTION      :=  TRIM(UPPER(:new.LIST_ACTION))    ;
lrec.OBJECT_LIST_CODE :=  TRIM(:new.OBJECT_LIST_CODE)       ;

lrec.START_DATE       :=  :new.START_DATE   ;
lrec.END_DATE         :=  :new.END_DATE ;

lrec.OBJECT_LIST_NAME :=  TRIM(:new.OBJECT_LIST_NAME ) ;
lrec.OBJ_LIST_DESC    :=  TRIM(:new.OBJ_LIST_DESC )  ;

lrec.REVISION_DATE        	:=  :new.REVISION_DATE  ;
lrec.REVISION_END_DATE      :=  :new.REVISION_END_DATE ;

lrec.OBJECT_ACTION          :=  TRIM(UPPER(:new.OBJECT_ACTION))    ;
lrec.GENERIC_OBJECT_CODE    :=  TRIM(:new.GENERIC_OBJECT_CODE)    ;
lrec.OBJECT_CODE            :=  TRIM(:new.OBJECT_CODE  )           ;

lrec.OBJECT_START_DATE      :=  :new.OBJECT_START_DATE;
lrec.OBJECT_END_DATE        :=  :new.OBJECT_END_DATE    ;

lrec.EC_CODE                :=  TRIM(:new.EC_CODE )                ;
lrec.OBJECT_NAME            :=  TRIM(:new.OBJECT_NAME )            ;
lrec.FIN_CODE               :=  TRIM(:new.FIN_CODE  )              ;
lrec.OBJ_DESCR              :=  TRIM(:new.OBJ_DESCR  )             ;


EcDp_Object_List.ObjectListUpload (lrec);


END;
