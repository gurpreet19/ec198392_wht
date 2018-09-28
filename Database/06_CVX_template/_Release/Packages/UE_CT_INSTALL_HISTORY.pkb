CREATE OR REPLACE PACKAGE BODY UE_CT_INSTALL_HISTORY IS

  PROCEDURE entry (p_id           CT_EC_INSTALL_HISTORY.INSTALL_ID%TYPE,
                   p_release_date DATE,
                   p_phase        VARCHAR2,
                   p_issues       VARCHAR2,
                   p_descr        VARCHAR2)
  IS
  BEGIN
  
    DBMS_OUTPUT.PUT_LINE('WARNING! UE_CT_INSTALL_HISTORY.entry is deprecated! Results may vary.');
  
    INSERT INTO CT_EC_INSTALL_HISTORY (
      INSTALL_ID
     ,RELEASE_DATE
     ,DESCRIPTION
     ,PREPARED_BY )
    VALUES (
      p_id
     ,p_release_date
     ,p_issues
     ,p_descr );

  END entry;
  
  PROCEDURE entry (p_id           CT_EC_INSTALL_HISTORY.INSTALL_ID%TYPE,
                   p_release_date DATE,
                   p_description  VARCHAR2,
                   p_prepared_by  VARCHAR2)
  IS
  BEGIN
  
    INSERT INTO CT_EC_INSTALL_HISTORY (
      INSTALL_ID
     ,RELEASE_DATE
     ,DESCRIPTION
     ,PREPARED_BY )
    VALUES (
      p_id
     ,p_release_date
     ,p_description
     ,p_prepared_by );

  END entry;
  
  PROCEDURE set_feature(p_feature_id        CT_EC_INSTALLED_FEATURES.FEATURE_ID%TYPE,
                        p_feature_name      CT_EC_INSTALLED_FEATURES.FEATURE_NAME%TYPE,
                        p_context_code      CT_EC_INSTALLED_FEATURES.CONTEXT_CODE%TYPE,
                        p_major_version     CT_EC_INSTALLED_FEATURES.MAJOR_VERSION%TYPE,
                        p_minor_version     CT_EC_INSTALLED_FEATURES.MINOR_VERSION%TYPE,
                        p_description       CT_EC_INSTALLED_FEATURES.DESCRIPTION%TYPE DEFAULT NULL)
  IS
    ln_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO ln_count
    FROM CT_EC_INSTALLED_FEATURES
    WHERE feature_id = p_feature_id;
    
    IF ln_count = 0 THEN
        INSERT INTO CT_EC_INSTALLED_FEATURES (FEATURE_ID, FEATURE_NAME, CONTEXT_CODE, MAJOR_VERSION, MINOR_VERSION, DESCRIPTION)
            VALUES (p_feature_id, p_feature_name, p_context_code, p_major_version, p_minor_version, p_description);
            COMMIT;
    ELSE
        UPDATE CT_EC_INSTALLED_FEATURES
        SET feature_name = nvl(p_feature_name, feature_name),
            context_code = nvl(p_context_code, context_code),
            major_version = nvl(p_major_version, major_version),
            minor_version = nvl(p_minor_version, minor_version),
            description = nvl(p_description, description)
        WHERE feature_id = p_feature_id;
    END IF;
  END set_feature;                        
  
  PROCEDURE drop_feature(p_feature_id         CT_EC_INSTALLED_FEATURES.FEATURE_ID%TYPE)
  IS
  BEGIN
    DELETE FROM CT_EC_INSTALLED_FEATURES
    WHERE feature_id = p_feature_id;
  END drop_feature;
  
  PROCEDURE assert_feature_version        (p_feature_id        CT_EC_INSTALLED_FEATURES.FEATURE_ID%TYPE,
                                   p_major_version     CT_EC_INSTALLED_FEATURES.MAJOR_VERSION%TYPE,
                                   p_minor_version     CT_EC_INSTALLED_FEATURES.MINOR_VERSION%TYPE,
                                   p_direction         VARCHAR2 DEFAULT '>=')
  IS
    v_major_version NUMBER;
    v_minor_version NUMBER;
    v_feature_name VARCHAR2(500);
    
  BEGIN
  
    SELECT count(*) INTO v_major_version
    FROM CT_EC_INSTALLED_FEATURES
    WHERE feature_id = p_feature_id;
    
    IF v_major_version = 0 THEN
        IF p_major_version IS NULL AND p_minor_version IS NULL AND p_direction <> '=' THEN
            RETURN;
        END IF;
        RAISE_APPLICATION_ERROR(-20101, 'Assertion failed: ' || v_feature_name || ' was not installed');
    END IF;        
  
    SELECT major_version, minor_version, feature_name INTO v_major_Version, v_minor_version, v_feature_name
    FROM CT_EC_INSTALLED_FEATURES
    WHERE feature_id = p_feature_id;
    
    IF 
    (
        v_major_version = p_major_version
        AND
        (
             (p_direction = '=' AND v_minor_version = p_minor_version)
          OR (p_direction = '>=' AND v_minor_version >= p_minor_version)
          OR (p_direction = '>' AND v_minor_version > p_minor_version) 
        )
    )
    OR
    (
        (p_direction = '>' AND v_major_version > p_major_version)
     OR (p_direction = '>=' AND v_major_version >= p_major_version)
    )
    THEN
        NULL;
    ELSE
        RAISE_APPLICATION_ERROR(-20101, 'Assertion failed: ' || v_feature_name || ' was not at expected version: ' || p_major_version || '.' || p_minor_version);
    END IF;
  END assert_feature_version;

END UE_CT_INSTALL_HISTORY;
/
