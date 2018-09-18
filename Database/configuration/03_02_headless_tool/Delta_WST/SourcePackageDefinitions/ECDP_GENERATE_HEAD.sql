CREATE OR REPLACE PACKAGE EcDp_Generate IS
/**
* Generate table triggers and EC packages (replaces the <var>ec_generate</var> package).
 * <br/><br/>
 * This package defines a number of bitmask functions and a single generate procedure.
 * The bitmasks are used as inputs to the generate procedure to indicate which object
 * types to generate. Bitmasks can be added together to trigger generation of multiple
 * object types. See examples below.
 * <br/><br/>
 * NOTE: Bit mask functions cannot be included/added multiple times in a bit mask expression.
 * @headcom
 */

/**
 * Bitmask to generate EC packages
 */
FUNCTION  PACKAGES       RETURN INTEGER;

/**
 * Bitmask to generate PInC triggers
 */
FUNCTION  AP_TRIGGERS    RETURN INTEGER;

/**
 * Bitmask to generate IUR triggers
 */
FUNCTION  IUR_TRIGGERS   RETURN INTEGER;

/**
 * Bitmask to generate JN triggers
 */
FUNCTION  JN_TRIGGERS    RETURN INTEGER;

/**
 * Bitmask to generate IU triggers
 */
FUNCTION  IU_TRIGGERS    RETURN INTEGER;

/**
 * Bitmask to generate AUT triggers
 */
FUNCTION  AUT_TRIGGERS   RETURN INTEGER;

/**
 * Bitmask to generate AIUDT triggers
 */
FUNCTION  AIUDT_TRIGGERS RETURN INTEGER;

/**
 * Bitmask to generate basic table triggers.
 * <br/><br/>
 * NOTE: <var>BASIC_TRIGGERS</var> is the same as <var>AUT_TRIGGERS + AIUDT_TRIGGERS + IU_TRIGGERS</var>.
 */
FUNCTION  BASIC_TRIGGERS RETURN INTEGER;

/**
 * Bitmask to generate all table triggers
 * <br/><br/>
 * NOTE: <var>ALL_TRIGGERS</var> is the same as <var>AP_TRIGGERS + AUT_TRIGGERS + AIUDT_TRIGGERS + IUR_TRIGGERS + IU_TRIGGERS + JN_TRIGGERS</var>.
 */
FUNCTION  ALL_TRIGGERS   RETURN INTEGER;

/**
 * Generate EC table triggers and/or packages for a given table (or all tables if <var>p_table_name</var> is <var>null</var>).
 * Triggers and packages can be generated individually or together as indicated by <var>p_target_mask</var>.
 * <br/><br/>
 * <u>Examples:</u>
 *
 * <pre class="sql">
 * SQL> -- Generate EC packages for all tables.
 * SQL> execute EcDp_Generate.generate(NULL, EcDp_Generate.PACKAGES);
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- Generate EC package for the BERTH table.
 * SQL> execute EcDp_Generate.generate('BERTH', EcDp_Generate.PACKAGES);
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- Generate all triggers for BERTH table.
 * SQL> execute EcDp_Generate.generate('BERTH', EcDp_Generate.ALL_TRIGGERS);
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- Generate IU, AUT and AIUDT triggers for all tables.
 * SQL> execute EcDp_Generate.generate(NULL, EcDp_Generate.IU + EcDp_Generate.AUT + EcDp_Generate.AIUDT);
 * </pre>
 *
 * <pre class="sql">
 * SQL> -- Generate EC package and all triggers except JN for BERTH table.
 * SQL> execute EcDp_Generate.generate('BERTH', EcDp_Generate.PACKAGES + EcDp_Generate.ALL_TRIGGERS - EcDp_Generate.JN_TRIGGERS);
 * </pre>
 *
 * @param p_table_name Name of table, or <var>null</var> for all tables
 * @param p_target_mask Indicates what to generate
 * @param p_missing_ind
 */
 PROCEDURE generate(
          p_table_name IN VARCHAR2,
          p_target_mask IN INTEGER,
          p_missing_ind IN VARCHAR2 DEFAULT NULL)
;

END EcDp_Generate;