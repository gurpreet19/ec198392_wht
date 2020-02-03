CREATE OR REPLACE PACKAGE ue_replicate_cargovalues IS
/******************************************************************************
** Package        : ue_Replicate_CargoValues, head part
**
** $Revision: 1.3 $
**
** Purpose        :  Replicating tables in transport with interface Cargo Values
**
** Documentation  :  www.energy-components.com
**
** Created  		:	10.09.2007 Kari Sandvik
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
**
********************************************************************************************************************************/
    PROCEDURE updatecarrier (
        p_cargo_no         NUMBER,
        p_old_carrier_id   VARCHAR2,
        p_new_carrier_id   VARCHAR2,
        p_user             VARCHAR2 DEFAULT NULL
    );

    PROCEDURE updatebldate (
        p_parcel_no     VARCHAR2,
        p_old_bl_date   DATE,
        p_new_bl_date   DATE,
        p_user          VARCHAR2 DEFAULT NULL
    );

    PROCEDURE updatedetails (
        p_parcel_no         VARCHAR2,
        p_old_consignor     VARCHAR2,
        p_new_consignor     VARCHAR2,
        p_old_consignee     VARCHAR2,
        p_new_consignee     VARCHAR2,
        p_old_incoterm      VARCHAR2,
        p_new_incoterm      VARCHAR2,
        p_old_contract_id   VARCHAR2,
        p_new_contract_id   VARCHAR2,
        p_old_port_id       VARCHAR2,
        p_new_port_id       VARCHAR2,
        p_user              VARCHAR2 DEFAULT NULL
    );

    PROCEDURE updateunloaddate (
        p_parcel_no         NUMBER,
        p_old_unload_date   DATE,
        p_new_unload_date   DATE,
        p_user              VARCHAR2 DEFAULT NULL
    );

    PROCEDURE updatecargoname (
        p_old_cargo_name   VARCHAR2,
        p_new_cargo_name   VARCHAR2,
        p_user             VARCHAR2 DEFAULT NULL
    );

    PROCEDURE updateloadinstr (
        p_cargo_no        VARCHAR2,
        p_old_berth_id    VARCHAR2,
        p_new_berth_id    VARCHAR2,
        p_old_voyage_no   VARCHAR2,
        p_new_voyage_no   VARCHAR2,
        p_user            VARCHAR2 DEFAULT NULL
    );

    PROCEDURE insertalloc (
        p_parcel_no          NUMBER,
        p_profit_centre_id   VARCHAR2,
        p_qty                VARCHAR2,
        p_user               VARCHAR2 DEFAULT NULL
    );

    PROCEDURE updateliftingqty (
        p_parcel_no      NUMBER,
        p_old_qty        NUMBER,
        p_new_qty        NUMBER,
        p_old_date       DATE,
        p_new_date       DATE,
        p_nom_type       VARCHAR2,
        p_prod_meas_no   NUMBER DEFAULT NULL,
        p_user           VARCHAR2 DEFAULT NULL
    );

    PROCEDURE insertfromcargostatus (
        p_cargo_no       NUMBER,
        p_cargo_status   VARCHAR2,
        p_user           VARCHAR2 DEFAULT NULL
    );

    PROCEDURE updatefromcargostatus (
        p_cargo_no           NUMBER,
        p_cargo_status_old   VARCHAR2,
        p_cargo_status_new   VARCHAR2,
        p_user               VARCHAR2 DEFAULT NULL
    );

END ue_replicate_cargovalues;
/

CREATE OR REPLACE PACKAGE BODY ue_replicate_cargovalues IS
/******************************************************************************
** Package        :  ue_Replicate_CargoValues, body part
**
** $Revision: 1.8 $
**
** Purpose        :  Replicating tables in transport with interface IFAC_CargoValues
**
** Documentation  :  www.energy-components.com
**
** Created  		:	11.09.2007 Kari Sandvik
**
** Modification history:
**
** Date        	Whom  			Change description:
** ------      	----- 			-----------------------------------------------------------------------------------------------
** 10.09.2015   sharawan    ECPD-31915: Clean up - Comment out the existing logic in the updateFromCargoStatus, updateBLDate, updateDetails, updateUnloadDate
**                          ,updateCargoName, updateLoadInstr, updateCarrier procedures and add the write to temporary table (t_temptext)
** 29.11.2017   KAWF            Item 125197 - Modify insertFromCargoStatus() for Additional Online GC in Cargo.
** 08.06.2018   WVIC            Item 127927 - Modify insertFromCargoStatus() to remove duplicates caused by having different official indicators
********************************************************************************************************************************/

-- common cursor

    CURSOR c_postition (
        cp_parcel_no       NUMBER,
        cp_lifting_event   VARCHAR
    ) IS
    SELECT
        l.product_meas_no,
        l.load_value,
        i.unit,
        i.item_condition,
        m.rev_qty_mapping
    FROM
        storage_lifting            l,
        product_meas_setup         m,
        lifting_measurement_item   i
    WHERE
        l.parcel_no = cp_parcel_no
        AND l.product_meas_no = m.product_meas_no
        AND m.lifting_event = cp_lifting_event
        AND m.item_code = i.item_code
        AND m.rev_qty_mapping IS NOT NULL
    ORDER BY
        m.rev_qty_mapping,
        i.item_condition ASC;

    CURSOR c_rev_mapping (
        cp_cargo_status VARCHAR2
    ) IS
    SELECT
        m.rev_qty_code,
        m.tran_qty_code
    FROM
        cargo_status_mapping m
    WHERE
        m.cargo_status = cp_cargo_status;

    CURSOR c_mapping (
        cp_product_meas_no NUMBER
    ) IS
    SELECT
        s.rev_qty_mapping,
        i.unit,
        i.item_condition
    FROM
        product_meas_setup         s,
        lifting_measurement_item   i
    WHERE
        s.item_code = i.item_code
        AND s.product_meas_no = cp_product_meas_no;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : exist
--
-- Description    : Check if row exist in ifac table
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

    FUNCTION exist (
        p_parcel_no       VARCHAR2,
        p_qty_type        VARCHAR2,
        p_profit_centre   VARCHAR2
    ) RETURN VARCHAR2
--</EC-DOC>
     IS

        CURSOR c_row_exist (
            cp_parcel_no       VARCHAR2,
            cp_qty_type        VARCHAR2,
            cp_profit_centre   VARCHAR2
        ) IS
        SELECT
            icv.parcel_no
        FROM
            ifac_cargo_value icv
        WHERE
            icv.parcel_no = to_char(cp_parcel_no)
            AND icv.qty_type = cp_qty_type
            AND icv.profit_center_code = cp_profit_centre;

        lv_exist VARCHAR2(1) := 'N';
    BEGIN
	-- Check if row exist. if it exist from before insert into revenue, otherwise update
        FOR cur_exist IN c_row_exist(p_parcel_no, p_qty_type, p_profit_centre) LOOP lv_exist := 'Y';
        END LOOP;

        RETURN lv_exist;
    END exist;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function	      : getContractCode
--
-- Description    : Returns the contract code. If no contract code returned or not available in revenue,
--                  no insert/update to reveneue
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

    FUNCTION getcontractcode (
        p_parce_no VARCHAR2
    ) RETURN VARCHAR2
--</EC-DOC>
     IS

        CURSOR c_contract (
            cp_parcel_no VARCHAR2
        ) IS
        SELECT
            nvl(n.contract_id, av.contract_id) contract_id
        FROM
            storage_lift_nomination   n,
            lifting_account           a,
            lift_account_version      av
        WHERE
            n.parcel_no = cp_parcel_no
            AND n.lifting_account_id = a.object_id
            AND a.object_id = av.object_id
            AND a.start_date <= av.daytime
            AND ( a.end_date >= av.daytime
                  OR av.end_date IS NULL );

        lv_contract_id VARCHAR2(32);
    BEGIN
	-- Get contract
        FOR cur_contract IN c_contract(p_parce_no) LOOP lv_contract_id := cur_contract.contract_id;
        END LOOP;

	-- check if contract is available in revenue
        IF ( lv_contract_id IS NOT NULL AND ec_contract.revn_ind(lv_contract_id) = 'Y' ) THEN
            RETURN ec_contract.object_code(lv_contract_id);
        ELSE
            RETURN NULL;
        END IF;

    END getcontractcode;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertQty
--
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

    PROCEDURE insertqty (
        p_parcel_no            NUMBER,
        p_mapping              VARCHAR2,
        p_unit1                VARCHAR2,
        p_qty                  NUMBER,
        p_unit                 VARCHAR2,
        p_meas_type            VARCHAR2,
        p_qty_type             VARCHAR2,
        p_profit_centre_code   VARCHAR2,
        p_contract_code        VARCHAR2,
        p_user                 VARCHAR2 DEFAULT NULL,
        p_alloc_no             NUMBER DEFAULT 0
    )
--</EC-DOC>
     IS

        CURSOR c_values (
            cp_parcel_no VARCHAR2
        ) IS
        SELECT
            ec_carrier.object_code(c.carrier_id) carrier_code,
            ecdp_objects.getobjname(c.berth_id, n.requested_date) berth_name,
            c.voyage_no,
            c.cargo_name,
            n.incoterm,
            ec_company.object_code(n.consignee_id) consignee_code,
            ec_company.object_code(n.consignor_id) consignor_code,
            nvl(n.bl_date, n.nom_firm_date) bl_date,
            n.unload_date,
            ec_port.object_code(n.port_id) port_code,
            ec_product.object_code(ec_stor_version.product_id(n.object_id, n.nom_firm_date, '<=')) product_code,
            ecbp_storage_lift_nomination.expectedunloaddate(n.parcel_no) exp_unload_date
        FROM
            storage_lift_nomination   n,
            cargo_transport           c
        WHERE
            n.cargo_no = c.cargo_no
            AND n.parcel_no = cp_parcel_no;

        lv_carrier_code         VARCHAR2(32);
        lv_berth_name           VARCHAR2(20);
        lv_voyage_no            VARCHAR2(64);
        ln_cargo_name           VARCHAR2(100);
        lv_incoterm             VARCHAR2(32);
        lv_consignee_code       VARCHAR2(32);
        lv_consignor_code       VARCHAR2(32);
        ld_bl_date              DATE;
        ld_unload_date          DATE;
        ld_point_of_sale        DATE;
        lv_port_code            VARCHAR2(32);
        lv_product_code         VARCHAR2(32);
        lv_profit_centre_code   VARCHAR2(32);
    BEGIN
	-- get cargo and nomination values
        FOR curvalues IN c_values(p_parcel_no) LOOP
            lv_carrier_code := curvalues.carrier_code;
            lv_berth_name := curvalues.berth_name;
            lv_voyage_no := curvalues.voyage_no;
            ln_cargo_name := curvalues.cargo_name;
            lv_incoterm := curvalues.incoterm;
            lv_consignee_code := curvalues.consignee_code;
            lv_consignor_code := curvalues.consignor_code;
            ld_bl_date := curvalues.bl_date;
            ld_unload_date := curvalues.unload_date;
            lv_port_code := curvalues.port_code;
            lv_product_code := curvalues.product_code;
        END LOOP;

        IF lv_incoterm IS NOT NULL THEN
            IF ec_prosty_codes.alt_code(lv_incoterm, 'INCOTERM') = 'UNLOAD' THEN
                IF ld_unload_date IS NULL THEN
                    ld_point_of_sale := ecbp_storage_lift_nomination.expectedunloaddate(p_parcel_no);
                ELSE
                    ld_point_of_sale := ld_unload_date;
                END IF;
            END IF;

		-- if fob or point of sale is still not set

            IF ec_prosty_codes.alt_code(lv_incoterm, 'INCOTERM') = 'LOAD' OR ld_point_of_sale IS NULL THEN
                ld_point_of_sale := ld_bl_date;
            END IF;

        ELSE
            ld_point_of_sale := ld_bl_date;
        END IF;

        IF p_profit_centre_code IS NOT NULL THEN
            lv_profit_centre_code := p_profit_centre_code;
        ELSE
            lv_profit_centre_code := 'SUM';
        END IF;

        IF p_mapping = 'QTY1' THEN
            INSERT INTO ifac_cargo_value (
                contract_code,
                cargo_no,
                parcel_no,
                qty_type,
                profit_center_code,
                alloc_no,
                loading_date,
                delivery_date,
                point_of_sale_date,
                loading_port_code,
                discharge_port_code,
                consignor_code,
                consignee_code,
                carrier_code,
                voyage_no,
                product_code,
                price_concept_code,
                net_qty1,
                grs_qty1,
                uom1_code,
                status,
                created_by
            ) VALUES (
                p_contract_code,
                ln_cargo_name,
                to_char(p_parcel_no),
                p_qty_type,
                lv_profit_centre_code,
                p_alloc_no,
                ld_bl_date,
                ld_unload_date,
                ld_point_of_sale,
                lv_berth_name,
                lv_port_code,
                lv_consignor_code,
                lv_consignee_code,
                lv_carrier_code,
                lv_voyage_no,
                lv_product_code,
                lv_incoterm,
                decode(p_meas_type, 'NET', p_qty, 0),
                decode(p_meas_type, 'GRS', p_qty, NULL),
                p_unit,
                'NEW',
                p_user
            );

        ELSIF p_mapping = 'QTY2' THEN
            INSERT INTO ifac_cargo_value (
                contract_code,
                cargo_no,
                parcel_no,
                qty_type,
                profit_center_code,
                alloc_no,
                loading_date,
                delivery_date,
                point_of_sale_date,
                loading_port_code,
                discharge_port_code,
                consignor_code,
                consignee_code,
                carrier_code,
                voyage_no,
                product_code,
                price_concept_code,
                net_qty1,
                uom1_code,
                net_qty2,
                grs_qty2,
                uom2_code,
                status,
                created_by
            ) VALUES (
                p_contract_code,
                ln_cargo_name,
                to_char(p_parcel_no),
                p_qty_type,
                lv_profit_centre_code,
                p_alloc_no,
                ld_bl_date,
                ld_unload_date,
                ld_point_of_sale,
                lv_berth_name,
                lv_port_code,
                lv_consignor_code,
                lv_consignee_code,
                lv_carrier_code,
                lv_voyage_no,
                lv_product_code,
                lv_incoterm,
                0,
                p_unit1,
                decode(p_meas_type, 'NET', p_qty, NULL),
                decode(p_meas_type, 'GRS', p_qty, NULL),
                p_unit,
                'NEW',
                p_user
            );

        ELSIF p_mapping = 'QTY3' THEN
            INSERT INTO ifac_cargo_value (
                contract_code,
                cargo_no,
                parcel_no,
                qty_type,
                profit_center_code,
                alloc_no,
                loading_date,
                delivery_date,
                point_of_sale_date,
                loading_port_code,
                discharge_port_code,
                consignor_code,
                consignee_code,
                carrier_code,
                voyage_no,
                product_code,
                price_concept_code,
                net_qty1,
                uom1_code,
                net_qty3,
                grs_qty3,
                uom3_code,
                status,
                created_by
            ) VALUES (
                p_contract_code,
                ln_cargo_name,
                to_char(p_parcel_no),
                p_qty_type,
                lv_profit_centre_code,
                p_alloc_no,
                ld_bl_date,
                ld_unload_date,
                ld_point_of_sale,
                lv_berth_name,
                lv_port_code,
                lv_consignor_code,
                lv_consignee_code,
                lv_carrier_code,
                lv_voyage_no,
                lv_product_code,
                lv_incoterm,
                0,
                p_unit1,
                decode(p_meas_type, 'NET', p_qty, NULL),
                decode(p_meas_type, 'GRS', p_qty, NULL),
                p_unit,
                'NEW',
                p_user
            );

        ELSIF p_mapping = 'QTY4' THEN
            INSERT INTO ifac_cargo_value (
                contract_code,
                cargo_no,
                parcel_no,
                qty_type,
                profit_center_code,
                alloc_no,
                loading_date,
                delivery_date,
                point_of_sale_date,
                loading_port_code,
                discharge_port_code,
                consignor_code,
                consignee_code,
                carrier_code,
                voyage_no,
                product_code,
                price_concept_code,
                net_qty1,
                uom1_code,
                net_qty4,
                grs_qty4,
                uom4_code,
                status,
                created_by
            ) VALUES (
                p_contract_code,
                ln_cargo_name,
                to_char(p_parcel_no),
                p_qty_type,
                lv_profit_centre_code,
                p_alloc_no,
                ld_bl_date,
                ld_unload_date,
                ld_point_of_sale,
                lv_berth_name,
                lv_port_code,
                lv_consignor_code,
                lv_consignee_code,
                lv_carrier_code,
                lv_voyage_no,
                lv_product_code,
                lv_incoterm,
                0,
                p_unit1,
                decode(p_meas_type, 'NET', p_qty, NULL),
                decode(p_meas_type, 'GRS', p_qty, NULL),
                p_unit,
                'NEW',
                p_user
            );

        END IF;

    END insertqty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateQty
--
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

    PROCEDURE updateqty (
        p_parcel_no   NUMBER,
        p_qty_type    VARCHAR2,
        p_qty         NUMBER,
        p_unit        VARCHAR2,
        p_meas_type   VARCHAR2,
        p_mapping     VARCHAR2,
        p_user        VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS
    BEGIN
        IF p_mapping = 'QTY1' THEN
            IF p_meas_type = 'GRS' THEN
                UPDATE ifac_cargo_value
                SET
                    grs_qty1 = p_qty,
                    uom1_code = p_unit,
                    last_updated_by = p_user,
                    status = 'UPDATED'
                WHERE
                    parcel_no = to_char(p_parcel_no)
                    AND qty_type = p_qty_type;

            ELSE
                UPDATE ifac_cargo_value
                SET
                    net_qty1 = p_qty,
                    uom1_code = p_unit,
                    last_updated_by = p_user,
                    status = 'UPDATED'
                WHERE
                    parcel_no = to_char(p_parcel_no)
                    AND qty_type = p_qty_type;

            END IF;

        ELSIF p_mapping = 'QTY2' THEN
            IF p_meas_type = 'GRS' THEN
                UPDATE ifac_cargo_value
                SET
                    grs_qty2 = p_qty,
                    uom2_code = p_unit,
                    last_updated_by = p_user,
                    status = 'UPDATED'
                WHERE
                    parcel_no = to_char(p_parcel_no)
                    AND qty_type = p_qty_type;

            ELSE
                UPDATE ifac_cargo_value
                SET
                    net_qty2 = p_qty,
                    uom2_code = p_unit,
                    last_updated_by = p_user,
                    status = 'UPDATED'
                WHERE
                    parcel_no = to_char(p_parcel_no)
                    AND qty_type = p_qty_type;

            END IF;
        ELSIF p_mapping = 'QTY3' THEN
            IF p_meas_type = 'GRS' THEN
                UPDATE ifac_cargo_value
                SET
                    grs_qty3 = p_qty,
                    uom3_code = p_unit,
                    last_updated_by = p_user,
                    status = 'UPDATED'
                WHERE
                    parcel_no = to_char(p_parcel_no)
                    AND qty_type = p_qty_type;

            ELSE
                UPDATE ifac_cargo_value
                SET
                    net_qty3 = p_qty,
                    uom3_code = p_unit,
                    last_updated_by = p_user,
                    status = 'UPDATED'
                WHERE
                    parcel_no = to_char(p_parcel_no)
                    AND qty_type = p_qty_type;

            END IF;
        ELSIF p_mapping = 'QTY4' THEN
            IF p_meas_type = 'GRS' THEN
                UPDATE ifac_cargo_value
                SET
                    grs_qty4 = p_qty,
                    uom4_code = p_unit,
                    last_updated_by = p_user,
                    status = 'UPDATED'
                WHERE
                    parcel_no = to_char(p_parcel_no)
                    AND qty_type = p_qty_type;

            ELSE
                UPDATE ifac_cargo_value
                SET
                    net_qty4 = p_qty,
                    uom4_code = p_unit,
                    last_updated_by = p_user,
                    status = 'UPDATED'
                WHERE
                    parcel_no = to_char(p_parcel_no)
                    AND qty_type = p_qty_type;

            END IF;
        END IF;
    END updateqty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertLoad
--
-- Description    : Procedure that insert cargo values into revenue. It is called from storage_lifting.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lifting
--
-- Using functions: getCodes,getValues,getQtyOum
--
-- Configuration
-- required       :
--
-- Behaviour      :	It inserts two rows into cargo values interface. One row with load_value and one row with expected_unload
--
---------------------------------------------------------------------------------------------------

    PROCEDURE insertload (
        p_parcel_no         VARCHAR2,
        p_product_meas_no   VARCHAR2,
        p_user              VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS

        ln_qty             NUMBER;
        lv_unit            VARCHAR2(32);
        lv_type            VARCHAR2(32);
        lv_unit1           VARCHAR2(32);
        lv_exist           VARCHAR2(1);
        lv_incoterm        VARCHAR2(32);
        lv_mapping         VARCHAR2(32);
        lv_contract_code   VARCHAR2(32);
    BEGIN
	-- do not insert if no contract
        lv_contract_code := getcontractcode(p_parcel_no);
        IF lv_contract_code IS NULL THEN
            return;
        END IF;
        lv_exist := exist(p_parcel_no, 'LOAD', 'SUM');
        lv_incoterm := ec_storage_lift_nomination.incoterm(p_parcel_no);

	-- insert into revenue with load value
        IF lv_exist = 'N' THEN
		-- get position and qty
            FOR curpos IN c_postition(p_parcel_no, 'LOAD') LOOP
                IF curpos.rev_qty_mapping = 'QTY1' THEN
                    lv_unit1 := curpos.unit;
                END IF;
                IF ( curpos.product_meas_no = p_product_meas_no ) THEN
                    ln_qty := curpos.load_value;
                    lv_unit := curpos.unit;
                    lv_type := curpos.item_condition;
				-- Check if override of qty mapping exist in lifting account meas setup
                    IF ec_lift_acc_meas_setup.rev_qty_mapping(ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_product_meas_no
                    ) IS NOT NULL THEN
                        lv_mapping := ec_lift_acc_meas_setup.rev_qty_mapping(ec_storage_lift_nomination.lifting_account_id(p_parcel_no
                        ), p_product_meas_no);
                    ELSE
                        lv_mapping := curpos.rev_qty_mapping;
                    END IF;

                    EXIT;
                END IF;

            END LOOP;

            IF lv_unit1 IS NULL AND lv_mapping <> 'QTY1' THEN
                raise_application_error(-20427, 'Qty 1 in interface to EC Reveneu is not configured in Product Meas Setup. This is mandatory when interface is activated'
                );
            END IF;

            insertqty(p_parcel_no, lv_mapping, lv_unit1, ln_qty, lv_unit,
                      nvl(lv_type, 'NET'), 'LOAD', NULL, lv_contract_code, p_user);

		--Insert expected unload if CIF cargo

            IF ec_prosty_codes.alt_code(lv_incoterm, 'INCOTERM') = 'UNLOAD' THEN
                ln_qty := ecbp_storage_lifting.calcexpunload(p_parcel_no, p_product_meas_no);
                insertqty(p_parcel_no, lv_mapping, lv_unit1, ln_qty, lv_unit,
                          nvl(lv_type, 'NET'), 'EST_UNLOAD', NULL, lv_contract_code, p_user);

            END IF;

	-- Update if row exist

        ELSE
		-- get position and qty
            FOR curpos IN c_postition(p_parcel_no, 'LOAD') LOOP IF ( curpos.product_meas_no = p_product_meas_no ) THEN
                ln_qty := curpos.load_value;
                lv_unit := curpos.unit;
				-- Check if override of qty mapping exist in lifting account meas setup
                IF ec_lift_acc_meas_setup.rev_qty_mapping(ec_storage_lift_nomination.lifting_account_id(p_parcel_no), p_product_meas_no
                ) IS NOT NULL THEN
                    lv_mapping := ec_lift_acc_meas_setup.rev_qty_mapping(ec_storage_lift_nomination.lifting_account_id(p_parcel_no
                    ), p_product_meas_no);
                ELSE
                    lv_mapping := curpos.rev_qty_mapping;
                END IF;

                lv_type := curpos.item_condition;
                EXIT;
            END IF;
            END LOOP;

		-- update unload qty

            updateqty(p_parcel_no, 'LOAD', ln_qty, lv_unit, nvl(lv_type, 'NET'), lv_mapping, p_user);

		--update expected unload if CIF cargo

            IF ec_prosty_codes.alt_code(lv_incoterm, 'INCOTERM') = 'UNLOAD' THEN
                ln_qty := ecbp_storage_lifting.calcexpunload(p_parcel_no, p_product_meas_no);
                updateqty(p_parcel_no, 'EST_UNLOAD', ln_qty, lv_unit, nvl(lv_type, 'NET'), lv_mapping, p_user);

            END IF;

        END IF;

    END insertload;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertUnload
--
-- Description    : Procedure that insert cargo values into ifac_Cargo_values. It is called from storage_lifting_unload.
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lifting
--
-- Using functions: getCodes,getValues,getQtyOUM
--
-- Configuration
-- required       :
--
-- Behaviour      :	Get values and codes for cargo values based on parcel_no and product_meas_no,
--							insert row into ecrevenue.cargovalues
--
---------------------------------------------------------------------------------------------------

    PROCEDURE insertunload (
        p_parcel_no         VARCHAR2,
        p_product_meas_no   VARCHAR2,
        p_user              VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS

        ln_qty             NUMBER;
        lv_unit            VARCHAR2(32);
        lv_unit1           VARCHAR2(32);
        lv_exist           VARCHAR2(1);
        lv_type            VARCHAR2(32);
        lv_mapping         VARCHAR2(32);
        lv_contract_code   VARCHAR2(32);
    BEGIN
	-- do not insert if no contract
        lv_contract_code := getcontractcode(p_parcel_no);
        IF lv_contract_code IS NULL THEN
            return;
        END IF;
        lv_exist := exist(p_parcel_no, 'UNLOAD', 'SUM');

	-- get position and qty
        FOR curpos IN c_postition(p_parcel_no, 'UNLOAD') LOOP
            IF curpos.rev_qty_mapping = 'QTY1' THEN
                lv_unit1 := curpos.unit;
            END IF;
            IF ( curpos.product_meas_no = p_product_meas_no ) THEN
                ln_qty := curpos.load_value;
                lv_unit := curpos.unit;
                lv_type := curpos.item_condition;
                lv_mapping := curpos.rev_qty_mapping;
                EXIT;
            END IF;

        END LOOP;

        IF lv_unit1 IS NULL AND lv_mapping <> 'QTY1' THEN
            raise_application_error(-20427, 'Qty 1 in interface to EC Reveneu is not configured in Product Meas Setup. This is mandatory when interface is activated'
            );
        END IF;

        IF lv_exist = 'N' THEN
            insertqty(p_parcel_no, lv_mapping, lv_unit1, ln_qty, lv_unit,
                      nvl(lv_type, 'NET'), 'UNLOAD', NULL, lv_contract_code, p_user);
        ELSE
            updateqty(p_parcel_no, 'UNLOAD', ln_qty, lv_unit, nvl(lv_type, 'NET'), lv_mapping, p_user);
        END IF;

    END insertunload;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateCarrier
--
-- Description    : Update vessel_code(carrier) in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, cargo_transport
--
-- Using functions: ec_carrier.object_code
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

    PROCEDURE updatecarrier (
        p_cargo_no         NUMBER,
        p_old_carrier_id   VARCHAR2,
        p_new_carrier_id   VARCHAR2,
        p_user             VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS
        lv_code         VARCHAR2(32);
        lv_cargo_name   VARCHAR2(100);
    BEGIN
  /*-------------------------------------------------------------------------
  -- The following code can be used as a starting point for
  -- replicating Cargo data values into the IFAC_CARGO_VALUE table
  -------------------------------------------------------------------------*/
        NULL;

  /*-- Update ifac_cargo_values with new carrier
  IF Nvl(p_old_carrier_id, 'x') <>  Nvl(p_new_carrier_id, 'x') THEN
		lv_code := ec_carrier.object_code(p_new_carrier_id);
		lv_cargo_name := ec_cargo_transport.cargo_name(p_cargo_no);

		UPDATE ifac_cargo_value
	  		SET carrier_code = lv_code, last_updated_by = p_user, status = 'UPDATED'
		WHERE cargo_no = lv_cargo_name;
	END IF;
	*/
    END updatecarrier;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateBLDate
--
-- Description    : Update bl_date in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, cargo_transport
--
-- Using functions: getCodes
--
-- Configuration
-- required       :
--
-- Behaviour      : It updates bl_date, but also point_of_sale_date if incoterm = FOB
--
---------------------------------------------------------------------------------------------------

    PROCEDURE updatebldate (
        p_parcel_no     VARCHAR2,
        p_old_bl_date   DATE,
        p_new_bl_date   DATE,
        p_user          VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS
        ld_exp_unload DATE;
    BEGIN
  /*-------------------------------------------------------------------------
  -- The following code can be used as a starting point for
  -- replicating Cargo data values into the IFAC_CARGO_VALUE table
  -------------------------------------------------------------------------*/
        NULL;

	/*-- do not update if no contract
	IF getContractCode(p_parcel_no) IS NULL THEN
		RETURN;
	END IF;

  --TODO	Validate new old date. Not allowed to have different month
	IF Nvl(p_old_bl_date, SYSDATE) <>  Nvl(p_new_bl_date, SYSDATE) THEN
		UPDATE ifac_cargo_value
	  		SET loading_date = p_new_bl_date, last_updated_by = p_user, status = 'UPDATED'
		WHERE parcel_no = TO_CHAR(p_parcel_no);

		IF ec_prosty_codes.alt_code(ec_storage_lift_nomination.incoterm(p_parcel_no),'INCOTERM') = 'LOAD' THEN
			UPDATE ifac_cargo_value
		  		SET point_of_sale_date = p_new_bl_date, last_updated_by = p_user, status = 'UPDATED'
			WHERE parcel_no = TO_CHAR(p_parcel_no);

		ELSIF ec_prosty_codes.alt_code(ec_storage_lift_nomination.incoterm(p_parcel_no),'INCOTERM') = 'UNLOAD' THEN
			-- calculate expected unload date if no real unload date
			IF exist (p_parcel_no, 'UNLOAD', 'SUM') = 'N' THEN
				ld_exp_unload := ecbp_storage_lift_nomination.expectedUnloadDate(p_parcel_no);
				UPDATE ifac_cargo_value
			  		SET point_of_sale_date = ld_exp_unload, last_updated_by = p_user, status = 'UPDATED'
				WHERE parcel_no = TO_CHAR(p_parcel_no);
			END IF;
		END IF;
	END IF;
	*/
    END updatebldate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateDetails
--
-- Description    : updates details like consignor, consignee, price_concept, delivery_point, contract_code
--						  for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :  storage_lift_nomination, cargo_transport
--
-- Using functions: getCodes
--
-- Configuration
-- required       :
--
-- Behaviour      :	Update details for a cargo
--
---------------------------------------------------------------------------------------------------

    PROCEDURE updatedetails (
        p_parcel_no         VARCHAR2,
        p_old_consignor     VARCHAR2,
        p_new_consignor     VARCHAR2,
        p_old_consignee     VARCHAR2,
        p_new_consignee     VARCHAR2,
        p_old_incoterm      VARCHAR2,
        p_new_incoterm      VARCHAR2,
        p_old_contract_id   VARCHAR2,
        p_new_contract_id   VARCHAR2,
        p_old_port_id       VARCHAR2,
        p_new_port_id       VARCHAR2,
        p_user              VARCHAR2 DEFAULT NULL
    )

--</EC-DOC>
     IS
    BEGIN
  /*-------------------------------------------------------------------------
  -- The following code can be used as a starting point for
  -- replicating Cargo data values into the IFAC_CARGO_VALUE table
  -------------------------------------------------------------------------*/
        NULL;

	/*-- do not update if no contract
	IF getContractCode(p_parcel_no) IS NULL THEN
		RETURN;
	END IF;
	IF Nvl(p_old_consignor, 'x') <>  Nvl(p_new_consignor, 'x') THEN
		UPDATE ifac_cargo_value
	  		SET CONSIGNOR_CODE = ec_company.object_code(p_new_consignor), last_updated_by = p_user, status = 'UPDATED'
		WHERE parcel_no = TO_CHAR(p_parcel_no);
	END IF;

	IF Nvl(p_old_consignee, 'x') <>  Nvl(p_new_consignee, 'x') THEN
		UPDATE ifac_cargo_value
	  		SET CONSIGNEE_CODE = ec_company.object_code(p_new_consignee), last_updated_by = p_user, status = 'UPDATED'
		WHERE parcel_no = TO_CHAR(p_parcel_no);
	END IF;

	IF (Nvl(p_old_contract_id, 'x') <>  Nvl(p_new_contract_id, 'x'))THEN
		UPDATE ifac_cargo_value
	  		SET CONTRACT_CODE = ec_contract.object_code(p_new_contract_id), PRICE_CONCEPT_CODE = p_new_incoterm, last_updated_by = p_user, status = 'UPDATED'
		WHERE parcel_no = TO_CHAR(p_parcel_no);
	END IF;

	IF Nvl(p_old_port_id, 'x') <>  Nvl(p_new_port_id, 'x') THEN
		UPDATE ifac_cargo_value
	  		SET DISCHARGE_PORT_CODE = ec_port.object_code(p_new_port_id), last_updated_by = p_user, status = 'UPDATED'
		WHERE parcel_no = TO_CHAR(p_parcel_no);
	END IF;
	*/
    END updatedetails;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateUnloadDate
--
-- Description    : Update unload_date in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, cargo_transport
--
-- Using functions: getCodes
--
-- Configuration
-- required       :
--
-- Behaviour      : It updates unload_date, but also point_of_sale_date if incoterm = CIF
--
---------------------------------------------------------------------------------------------------

    PROCEDURE updateunloaddate (
        p_parcel_no         NUMBER,
        p_old_unload_date   DATE,
        p_new_unload_date   DATE,
        p_user              VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS
    BEGIN
  /*-------------------------------------------------------------------------
  -- The following code can be used as a starting point for
  -- replicating Cargo data values into the IFAC_CARGO_VALUE table
  -------------------------------------------------------------------------*/
        NULL;

	/*-- do not update if no contract
	IF getContractCode(p_parcel_no) IS NULL THEN
		RETURN;
	END IF;

	IF Nvl(p_old_unload_date, SYSDATE) <>  Nvl(p_new_unload_date, SYSDATE) THEN
		IF ec_prosty_codes.alt_code(ec_storage_lift_nomination.incoterm(p_parcel_no),'INCOTERM') = 'UNLOAD' THEN
			UPDATE ifac_cargo_value
		  		SET delivery_date = p_new_unload_date, point_of_sale_date = p_new_unload_date, last_updated_by = p_user, status = 'UPDATED'
			WHERE parcel_no = TO_CHAR(p_parcel_no) AND qty_type = 'UNLOAD';
		END IF;
	END IF;
	*/
    END updateunloaddate;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateCargoName
--
-- Description    : Update a cargoname in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : storage_lift_nomination, cargo_transport
--
-- Using functions: ec_cargo_transport.cargoname
--
-- Configuration
-- required       :
--
-- Behaviour      : It updates unload_date, but also point_of_sale_date if incoterm = CIF
--
---------------------------------------------------------------------------------------------------

    PROCEDURE updatecargoname (
        p_old_cargo_name   VARCHAR2,
        p_new_cargo_name   VARCHAR2,
        p_user             VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS
    BEGIN
  /*-------------------------------------------------------------------------
  -- The following code can be used as a starting point for
  -- replicating Cargo data values into the IFAC_CARGO_VALUE table
  -------------------------------------------------------------------------*/
        NULL;

  /*
  IF Nvl(p_old_cargo_name, 'x') <>  Nvl(p_new_cargo_name, 'x') THEN
		UPDATE ifac_cargo_value
			SET cargo_no = p_new_cargo_name, last_updated_by = p_user, status = 'UPDATED'
		WHERE cargo_no = p_old_cargo_name;
	END IF;
	*/
    END updatecargoname;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateLoadInstr
--
-- Description    : Update a vessel_code, loading_point and voyage_no in ecrevenue.cargovalues for a cargo
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   : cargo_transport
--
-- Using functions: ec_cargo_transport.cargoname,
--
-- Configuration
-- required       :
--
-- Behaviour      : update loading_point and voyage_no in cargo_values, when one or both fields have
--							been updated.
--
---------------------------------------------------------------------------------------------------

    PROCEDURE updateloadinstr (
        p_cargo_no        VARCHAR2,
        p_old_berth_id    VARCHAR2,
        p_new_berth_id    VARCHAR2,
        p_old_voyage_no   VARCHAR2,
        p_new_voyage_no   VARCHAR2,
        p_user            VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS
        lv_cargo_name VARCHAR2(32);
    BEGIN
        lv_cargo_name := ec_cargo_transport.cargo_name(p_cargo_no);

  /*
	IF Nvl(p_old_berth_id, 'x') <>  Nvl(p_new_berth_id, 'x') THEN
		UPDATE ifac_cargo_value
			SET loading_port_code = ec_berth.object_code(p_new_berth_id), last_updated_by = p_user, status = 'UPDATED'
		WHERE cargo_no = lv_cargo_name;
	END IF;

	IF Nvl(p_old_voyage_no, 'x') <>  Nvl(p_new_voyage_no, 'x') THEN
		UPDATE ifac_cargo_value
			SET voyage_no = p_new_voyage_no, last_updated_by = p_user, status = 'UPDATED'
		WHERE cargo_no = lv_cargo_name;
	END IF;
	*/
    END updateloadinstr;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : allocNo
--
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

    FUNCTION allocno (
        p_parcel_no          NUMBER,
        p_profit_centre_id   VARCHAR2,
        p_qty_type           VARCHAR2
    ) RETURN NUMBER
--</EC-DOC>
     IS

        CURSOR c_alloc_no (
            cp_parcel_no            NUMBER,
            cp_profit_centre_code   VARCHAR2,
            cp_qty_type             VARCHAR2
        ) IS
        SELECT
            MAX(alloc_no) alloc_no
        FROM
            ifac_cargo_value
        WHERE
            parcel_no = to_char(cp_parcel_no)
            AND qty_type = cp_qty_type
            AND profit_center_code = cp_profit_centre_code;

        ln_alloc_no NUMBER;
    BEGIN
        FOR curalloc IN c_alloc_no(p_parcel_no, ecdp_objects.getobjcode(p_profit_centre_id), p_qty_type) LOOP ln_alloc_no := curalloc
        .alloc_no;
        END LOOP;

        IF ln_alloc_no IS NULL THEN
            ln_alloc_no := -1;
        END IF;
        RETURN ln_alloc_no;
    END allocno;


--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertAlloc
--
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

    PROCEDURE insertalloc (
        p_parcel_no          NUMBER,
        p_profit_centre_id   VARCHAR2,
        p_qty                VARCHAR2,
        p_user               VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS

        CURSOR c_sum_parcel (
            cp_parcel_no   NUMBER,
            cp_qty_type    VARCHAR2,
            cp_alloc_no    NUMBER
        ) IS
        SELECT
            *
        FROM
            ifac_cargo_value
        WHERE
            parcel_no = to_char(cp_parcel_no)
            AND qty_type = cp_qty_type
            AND profit_center_code = 'SUM'
            AND alloc_no = cp_alloc_no;

        ln_alloc_no        NUMBER;
        lv_qty_type        VARCHAR2(32);
        lv_unit            VARCHAR2(32);
        lv_exist           VARCHAR2(1);
        lv_contract_code   VARCHAR2(32);
    BEGIN
	-- do not insert if no contract
        lv_contract_code := getcontractcode(p_parcel_no);
        IF lv_contract_code IS NULL THEN
            return;
        END IF;

	-- find qty type
        IF ec_prosty_codes.alt_code(ec_storage_lift_nomination.incoterm(p_parcel_no), 'INCOTERM') = 'UNLOAD' THEN
            lv_qty_type := 'UNLOAD';
        ELSE
            lv_qty_type := 'LOAD';
        END IF;

        lv_unit := ecbp_storage_lift_nomination.getnomunit(ec_storage_lift_nomination.object_id(p_parcel_no));
        ln_alloc_no := allocno(p_parcel_no, p_profit_centre_id, 'LOAD') + 1;

	-- insert new allocated value
        insertqty(p_parcel_no, 'QTY1', lv_unit, p_qty, lv_unit,
                  'NET', lv_qty_type, ecdp_objects.getobjcode(p_profit_centre_id), lv_contract_code, p_user,
                  ln_alloc_no);

        IF ln_alloc_no > 0 THEN
		-- duplicate sum if doesn't exist
            FOR curparcel IN c_sum_parcel(p_parcel_no, lv_qty_type, ln_alloc_no) LOOP lv_exist := 'Y';
            END LOOP;

            IF nvl(lv_exist, 'N') <> 'Y' THEN
                INSERT INTO ifac_cargo_value (
                    contract_code,
                    cargo_no,
                    parcel_no,
                    qty_type,
                    profit_center_code,
                    alloc_no,
                    loading_date,
                    delivery_date,
                    point_of_sale_date,
                    loading_port_code,
                    discharge_port_code,
                    consignor_code,
                    consignee_code,
                    carrier_code,
                    voyage_no,
                    product_code,
                    price_concept_code,
                    net_qty1,
                    grs_qty1,
                    uom1_code,
                    net_qty2,
                    grs_qty2,
                    uom2_code,
                    net_qty3,
                    grs_qty3,
                    uom3_code,
                    net_qty4,
                    grs_qty4,
                    uom4_code,
                    status,
                    created_by
                )
                    SELECT
                        contract_code,
                        cargo_no,
                        parcel_no,
                        qty_type,
                        profit_center_code,
                        ln_alloc_no,
                        loading_date,
                        delivery_date,
                        point_of_sale_date,
                        loading_port_code,
                        discharge_port_code,
                        consignor_code,
                        consignee_code,
                        carrier_code,
                        voyage_no,
                        product_code,
                        price_concept_code,
                        net_qty1,
                        grs_qty1,
                        uom1_code,
                        net_qty2,
                        grs_qty2,
                        uom2_code,
                        net_qty3,
                        grs_qty3,
                        uom3_code,
                        net_qty4,
                        grs_qty4,
                        uom4_code,
                        'NEW',
                        p_user
                    FROM
                        ifac_cargo_value
                    WHERE
                        parcel_no = to_char(p_parcel_no)
                        AND qty_type = lv_qty_type
                        AND profit_center_code = 'SUM'
                        AND alloc_no = ln_alloc_no - 1;

            END IF;

        END IF;

    END insertalloc;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : updateLiftingQty
--
-- Description    :
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

    PROCEDURE updateliftingqty (
        p_parcel_no      NUMBER,
        p_old_qty        NUMBER,
        p_new_qty        NUMBER,
        p_old_date       DATE,
        p_new_date       DATE,
        p_nom_type       VARCHAR2,
        p_prod_meas_no   NUMBER DEFAULT NULL,
        p_user           VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS

        CURSOR c_parcel_cond (
            c_parcel_no NUMBER
        ) IS
        SELECT
            grs_vol_nominated,
            ( grs_vol_nominated / (
                SELECT
                    SUM(a.grs_vol_nominated)
                FROM
                    storage_lift_nomination a
                WHERE
                    a.cargo_no = storage_lift_nomination.cargo_no
            ) ) AS ratio
        FROM
            storage_lift_nomination
        WHERE
            parcel_no = c_parcel_no
            AND object_id = ecdp_objects.getobjidfromcode('STORAGE', 'STW_COND');

        CURSOR c_parcel (
            c_parcel_no NUMBER
        ) IS
        SELECT
            grs_vol_nominated,
            ( grs_vol_nominated / (
                SELECT
                    SUM(a.grs_vol_nominated)
                FROM
                    storage_lift_nomination a
                WHERE
                    a.cargo_no = storage_lift_nomination.cargo_no
            ) ) AS ratio
        FROM
            storage_lift_nomination
        WHERE
            parcel_no = c_parcel_no
            AND object_id = ecdp_objects.getobjidfromcode('STORAGE', 'STW_LNG');

        CURSOR c_cargo (
            c_cargo_no NUMBER
        ) IS
        SELECT
            cargo_no,
            parcel_no
        FROM
            storage_lift_nomination
        WHERE
            cargo_no = c_cargo_no
            AND object_id = ecdp_objects.getobjidfromcode('STORAGE', 'STW_LNG');

        CURSOR c_cargo_cond (
            c_cargo_no NUMBER
        ) IS
        SELECT
            cargo_no,
            parcel_no
        FROM
            storage_lift_nomination
        WHERE
            cargo_no = c_cargo_no
            AND object_id = ecdp_objects.getobjidfromcode('STORAGE', 'STW_COND');

        CURSOR c_prod_meas (
            c_prod_meas_no NUMBER
        ) IS
        SELECT
            meas_item,
            object_code
        FROM
            dv_prod_meas_setup
        WHERE
            lifting_event = 'LOAD'
            AND product_meas_no = c_prod_meas_no;

        v_ratio               NUMBER;
        v_sum_of_pnc          NUMBER;
        v_grs_vol_nominated   NUMBER;
        v_meas_item           VARCHAR2(50);
        v_product             VARCHAR2(50);
    BEGIN
  --NULL;

  /*
  SAMPLE V_MEAS_ITEM
    LIFT_TOT_LNG_VOL_NET
	LIFT_TOT_COND_VOL_NET
	LIFT_LIQ_TEMP_BEFORE
	LIFT_VAP_TEMP_BEFORE
	LIFT_VAP_PRESS_BEFORE
	LIFT_LIQ_TEMP_AFTER
	LIFT_VAP_TEMP_AFTER
	LIFT_VAP_PRESS_AFTER
	PURGE_HRS
	PURGE_VOL
	COOL_HRS
	COOL_VOL
	COOL_VOL_HRS_NC
	COOL_VOL_NC
	LIFT_P_C_M3
*/
        v_meas_item := '';
        FOR c_pms IN c_prod_meas(p_prod_meas_no) LOOP
            v_meas_item := c_pms.meas_item;
            v_product := c_pms.object_code;
        END LOOP;

        IF v_meas_item = 'LIFT_TOT_LNG_VOL_NET' THEN
/*
		FOR C_LOOP IN C_PARCEL(p_parcel_no) LOOP
			v_RATIO:= C_LOOP.RATIO ;
		END LOOP;

		UPDATE STORAGE_LIFTING
		SET LOAD_VALUE= (p_new_qty * v_RATIO )
		WHERE PARCEL_NO = p_parcel_no
		AND PRODUCT_MEAS_NO =
		(SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND OBJECT_CODE = 'LNG' AND MEAS_ITEM = 'LIFT_NET_M3');
*/
		--update other commingled cargoes using Cargo No
            UPDATE storage_lifting
            SET
                load_value = ( p_new_qty )
            WHERE
                parcel_no <> ( p_parcel_no )
                AND parcel_no IN (
                    SELECT
                        parcel_no
                    FROM
                        storage_lift_nomination
                    WHERE
                        cargo_no = ec_storage_lift_nomination.cargo_no(p_parcel_no)
                )
                AND product_meas_no = p_prod_meas_no;
/*
		--update split qty for other commingled cargoes
		FOR C_LOOP IN C_CARGO(EC_STORAGE_LIFT_NOMINATION.CARGO_NO(p_parcel_no)) LOOP
			IF C_LOOP.PARCEL_NO <> p_parcel_no THEN
				FOR C_INNER_LOOP IN C_PARCEL(C_LOOP.PARCEL_NO) LOOP
					v_RATIO:= C_INNER_LOOP.RATIO ;
					UPDATE STORAGE_LIFTING
					SET LOAD_VALUE= (p_new_qty * v_RATIO )
					WHERE PARCEL_NO = C_LOOP.PARCEL_NO
					AND PRODUCT_MEAS_NO =
					(SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND OBJECT_CODE = 'LNG' AND MEAS_ITEM = 'LIFT_NET_M3');
				END LOOP;
			END IF;
		END LOOP;
*/

        END IF;

        IF v_meas_item = 'LIFT_TOT_COND_VOL_GRS' THEN
/*
		FOR C_LOOP_COND IN C_PARCEL_COND(p_parcel_no) LOOP
			v_RATIO:= C_LOOP_COND.RATIO ;
		END LOOP;

		UPDATE STORAGE_LIFTING
		SET LOAD_VALUE= (p_new_qty * v_RATIO )
		WHERE PARCEL_NO = p_parcel_no
		AND PRODUCT_MEAS_NO =
		(SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND OBJECT_CODE = 'COND' AND MEAS_ITEM = 'LIFT_COND_MET_VOL_GRS');
*/
		--update other commingled cargoes using Cargo No
            UPDATE storage_lifting
            SET
                load_value = ( p_new_qty )
            WHERE
                parcel_no <> ( p_parcel_no )
                AND parcel_no IN (
                    SELECT
                        parcel_no
                    FROM
                        storage_lift_nomination
                    WHERE
                        cargo_no = ec_storage_lift_nomination.cargo_no(p_parcel_no)
                )
                AND product_meas_no = p_prod_meas_no;
/*
		--update split qty for other commingled cargoes
		FOR C_LOOP IN C_CARGO_COND(EC_STORAGE_LIFT_NOMINATION.CARGO_NO(p_parcel_no)) LOOP
			IF C_LOOP.PARCEL_NO <> p_parcel_no THEN
				FOR C_INNER_LOOP IN C_PARCEL_COND(C_LOOP.PARCEL_NO) LOOP
					v_RATIO:= C_INNER_LOOP.RATIO ;
					UPDATE STORAGE_LIFTING
					SET LOAD_VALUE= (p_new_qty * v_RATIO )
					WHERE PARCEL_NO = C_LOOP.PARCEL_NO
					AND PRODUCT_MEAS_NO =
					(SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND OBJECT_CODE = 'COND' AND MEAS_ITEM = 'LIFT_COND_MET_VOL_GRS');
				END LOOP;
			END IF;
		END LOOP;
*/

        END IF;

        IF v_meas_item IN (
            'LIFT_LIQ_TEMP_BEFORE',
            'LIFT_VAP_TEMP_BEFORE',
            'LIFT_VAP_PRESS_BEFORE',
            'LIFT_LIQ_TEMP_AFTER',
            'LIFT_VAP_TEMP_AFTER',
            'LIFT_VAP_PRESS_AFTER',
            'PURGE_HRS',
            'PURGE_VOL',
            'COOL_HRS',
            'COOL_VOL',
            'COOL_VOL_HRS_NC',
            'COOL_VOL_NC'
        ) THEN
		--update other commingled cargoes using Cargo No
            UPDATE storage_lifting
            SET
                load_value = ( p_new_qty )
            WHERE
                parcel_no <> ( p_parcel_no )
                AND parcel_no IN (
                    SELECT
                        parcel_no
                    FROM
                        storage_lift_nomination
                    WHERE
                        cargo_no = ec_storage_lift_nomination.cargo_no(p_parcel_no)
                )
                AND product_meas_no = p_prod_meas_no;

        END IF;
/*
	IF V_MEAS_ITEM IN ('PURGE_VOL','COOL_VOL') THEN
		FOR C_LOOP IN C_PARCEL(p_parcel_no) LOOP
			v_RATIO:= C_LOOP.RATIO ;
		END LOOP;

		v_SUM_OF_PNC:=0;

		--GET THE SUM OF BOTH PURGING AND COOLING VOLUME PER VESSEL
		SELECT SUM(LOAD_VALUE) INTO v_SUM_OF_PNC
		FROM DV_STORAGE_LIFTING
		WHERE PARCEL_NO = p_parcel_no
		AND PRODUCT_MEAS_NO IN
		(SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE MEAS_ITEM IN('PURGE_VOL','COOL_VOL'));

		--APPLY THE SPLIT FACTOR TO THE PNC TO GET THE PNC PER PARCEL
		UPDATE STORAGE_LIFTING
		SET LOAD_VALUE= (v_SUM_OF_PNC * v_RATIO )
		WHERE PARCEL_NO = p_parcel_no
		AND PRODUCT_MEAS_NO =
		(SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND OBJECT_CODE = 'LNG' AND MEAS_ITEM = 'LIFT_P_C_M3');

		--update split qty for other commingled cargoes
		FOR C_LOOP IN C_CARGO(EC_STORAGE_LIFT_NOMINATION.CARGO_NO(p_parcel_no)) LOOP
			IF C_LOOP.PARCEL_NO <> p_parcel_no THEN
				FOR C_INNER_LOOP IN C_PARCEL(C_LOOP.PARCEL_NO) LOOP
					v_RATIO:= C_INNER_LOOP.RATIO ;
					UPDATE STORAGE_LIFTING
					SET LOAD_VALUE= (v_SUM_OF_PNC * v_RATIO )
					WHERE PARCEL_NO = C_LOOP.PARCEL_NO
					AND PRODUCT_MEAS_NO =
					(SELECT PRODUCT_MEAS_NO FROM DV_PROD_MEAS_SETUP WHERE LIFTING_EVENT = 'LOAD' AND OBJECT_CODE = 'LNG' AND MEAS_ITEM = 'LIFT_P_C_M3');
				END LOOP;
			END IF;
		END LOOP;

	END IF;
*/

    END updateliftingqty;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : insertFromCargoStatus
--
-- Description    : Transferes quantities on nominations  to EC Revenue
--
-- Preconditions  :
--
-- Postconditions :
--
-- Using tables   :
--
-- Using functions:
--
-- Configuration
-- required       :
--
-- Behaviour      :
--
---------------------------------------------------------------------------------------------------

    PROCEDURE insertfromcargostatus (
        p_cargo_no       NUMBER,
        p_cargo_status   VARCHAR2,
        p_user           VARCHAR2 DEFAULT NULL
    )
--</EC-DOC>
     IS

        CURSOR c_nominations (
            cp_cargo_no NUMBER
        ) IS
        SELECT
            n.parcel_no,
            n.grs_vol_requested,
            n.grs_vol_nominated,
            n.grs_vol_schedule
        FROM
            storage_lift_nomination n
        WHERE
            cargo_no = cp_cargo_no;

        CURSOR user_roles IS
        SELECT
            role_id
        FROM
            t_basis_userrole
        WHERE
            user_id = p_user;

        v_has_access         VARCHAR2(1) := 'N';
        v_product_id         VARCHAR2(32);
        CURSOR c_storage_lifting (
            cp_parcel_no       NUMBER,
            cp_lifting_event   VARCHAR2
        ) IS
        SELECT
            l.product_meas_no
        FROM
            storage_lifting      l,
            product_meas_setup   m
        WHERE
            l.parcel_no = cp_parcel_no
            AND l.product_meas_no = m.product_meas_no
            AND m.lifting_event = cp_lifting_event;

        lv_rev_qty_code      VARCHAR2(32);
        lv_tran_qty_code     VARCHAR2(32);
        ln_qty               NUMBER;
        lv_exist             VARCHAR2(1);
        lv_contract_code     VARCHAR2(32);
        ln_prod_meas_no      NUMBER;
        lv_unit              VARCHAR2(32);
        lv_item_condition    VARCHAR2(32);
        lv_rev_qty_mapping   VARCHAR2(32);
    BEGIN

	--tlxt: 99517: 07-jul-2015: Defect, to ensure the Cargo Analysis didn't gets inserted twice in both Cond and LNG
  --IF (p_cargo_status = 'M' OR p_cargo_status = 'R') THEN
        IF ( p_cargo_status = 'R' ) THEN
	-- end edit
            SELECT
                ec_stor_version.product_id((
                    SELECT
                        MAX(object_id)
                    FROM
                        dv_storage_lift_nomination
                    WHERE
                        cargo_no = p_cargo_no
                ), sysdate, '<=')
            INTO v_product_id
            FROM
                dual;

    -- Clean the cargo analysis and re-insert

            DELETE FROM cargo_analysis_item
            WHERE
                analysis_no IN (
                    SELECT
                        analysis_no
                    FROM
                        cargo_analysis
                    WHERE
                        cargo_no = p_cargo_no
                        AND sampling_method IS NULL
                )
                AND record_status = 'P';

            DELETE FROM cargo_analysis
            WHERE
                cargo_no = p_cargo_no
                AND record_status = 'P'
                AND sampling_method IS NULL;

    -- 125197: insert sample_source

            INSERT INTO dv_cargo_analysis (
                cargo_no,
                daytime,
                official_ind,
                sampling_method,
                analysis_type,
                lifting_event,
                created_by,
                product_id,
                sample_source
            )

    -- Create a distributed sample record
                SELECT
                    p_cargo_no,
                    ue_ct_leadtime.getfirstnomdatetime(p_cargo_no),
                    'N',
                    'CONT_SAMPLING',
                    'DIST_SAMPLE',
                    'LOAD',
                    p_user,
                    v_product_id,
                    NULL
                FROM
                    dual
                WHERE
                    0 = (
                        SELECT
                            COUNT(*)
                        FROM
                            dv_cargo_analysis
                        WHERE
                            cargo_no = p_cargo_no /* AND official_ind = 'N' AND sampling_method = 'CONT_SAMPLING' -- Item 127926 */
                            AND analysis_type = 'DIST_SAMPLE'
                            AND lifting_event = 'LOAD'
                            AND product_id = v_product_id
                    )
                UNION ALL

    -- Create a retained sample record
                SELECT
                    p_cargo_no,
                    ue_ct_leadtime.getfirstnomdatetime(p_cargo_no),
                    'N',
                    'CONT_SAMPLING',
                    'RET_SAMPLE',
                    'LOAD',
                    p_user,
                    v_product_id,
                    NULL
                FROM
                    dual
                WHERE
                    0 = (
                        SELECT
                            COUNT(*)
                        FROM
                            dv_cargo_analysis
                        WHERE
                            cargo_no = p_cargo_no /* AND official_ind = 'N' AND sampling_method = 'CONT_SAMPLING' -- Item 127926 */
                            AND analysis_type = 'RET_SAMPLE'
                            AND lifting_event = 'LOAD'
                            AND product_id = v_product_id
                    )
                UNION ALL

    -- Create a lab sample record - it is the official record for condensate
                SELECT
                    p_cargo_no,
                    ue_ct_leadtime.getfirstnomdatetime(p_cargo_no),
                    decode(v_product_id, ec_product.object_id_by_uk('LNG'), 'N', 'Y'),
                    'CONT_SAMPLING',
                    'WST_LAB',
                    'LOAD',
                    p_user,
                    v_product_id,
                    NULL
                FROM
                    dual
                WHERE
                    0 = (
                        SELECT
                            COUNT(*)
                        FROM
                            dv_cargo_analysis
                        WHERE
                            cargo_no = p_cargo_no /* AND official_ind = 'N' AND sampling_method = 'CONT_SAMPLING' -- Item 127926 */
                            AND analysis_type = 'WST_LAB'
                            AND lifting_event = 'LOAD'
                            AND product_id = v_product_id
                    )
                UNION ALL

    -- Create a gas chromatograph sample record - it is only for LNG and is the official record for LNG
                SELECT
                    p_cargo_no,
                    ue_ct_leadtime.getfirstnomdatetime(p_cargo_no),
                    'Y',
                    'ONLINE_GC',
                    'ONLINE_GC',
                    'LOAD',
                    p_user,
                    v_product_id,
                    'Online GC A'
                FROM
                    dual
                WHERE
                    0 = (
                        SELECT
                            COUNT(*)
                        FROM
                            dv_cargo_analysis
                        WHERE
                            cargo_no = p_cargo_no /* AND official_ind = 'Y' -- Item 127926 */
                            AND lifting_event = 'LOAD'
                            AND product_id = v_product_id
                            AND sample_source = 'Online GC A'
                    )
                    AND v_product_id = ec_product.object_id_by_uk('LNG')

    -- 125197:Start Duplicate copy of Online GC
                UNION ALL
                SELECT
                    p_cargo_no,
                    ue_ct_leadtime.getfirstnomdatetime(p_cargo_no),
                    'N',
                    'ONLINE_GC',
                    'ONLINE_GC',
                    'LOAD',
                    p_user,
                    v_product_id,
                    'Online GC B'
                FROM
                    dual
                WHERE
                    0 = (
                        SELECT
                            COUNT(*)
                        FROM
                            dv_cargo_analysis
                        WHERE
                            cargo_no = p_cargo_no /* AND official_ind = 'N' -- Item 127926 */
                            AND lifting_event = 'LOAD'
                            AND product_id = v_product_id
                            AND sample_source = 'Online GC B'
                    )
                    AND v_product_id = ec_product.object_id_by_uk('LNG');
    -- 125197:End

            ecbp_cargo_status.insertcargoanalysisitems(p_cargo_no, p_user, v_product_id, 'LOAD');
        END IF;

        IF ( ecbp_cargo_status.geteccargostatus(p_cargo_status) = 'C' ) THEN

    -- Does the user have access?
            FOR item IN user_roles LOOP IF item.role_id = 'MA.CLOSED' OR ecdp_context.getappuser IS NULL THEN
                v_has_access := 'Y';
            END IF;
            END LOOP;

	--we havent implement the Marine role

            ecdp_dynsql.writetemptext('UE_REPLICATE_CARGOVALUES', 'we havent implement the Marine role');
            v_has_access := 'Y';
            IF ecdp_context.getappuser IS NOT NULL AND v_has_access = 'N' THEN
                raise_application_error(-20856, 'You do not have sufficient permissions to change the cargo status to Closed');
            END IF;

            UPDATE cargo_transport
            SET
                record_status = 'V',
                last_updated_by = p_user
            WHERE
                cargo_no = p_cargo_no;

            UPDATE storage_lift_nomination
            SET
                record_status = 'V',
                last_updated_by = p_user
            WHERE
                cargo_no = p_cargo_no;

            UPDATE cargo_activity
            SET
                record_status = 'V',
                last_updated_by = p_user
            WHERE
                cargo_no = p_cargo_no;

            UPDATE cargo_analysis
            SET
                record_status = 'V',
                last_updated_by = p_user
            WHERE
                cargo_no = p_cargo_no;

            UPDATE cargo_analysis_item
            SET
                record_status = 'V',
                last_updated_by = p_user
            WHERE
                analysis_no IN (
                    SELECT
                        analysis_no
                    FROM
                        cargo_analysis
                    WHERE
                        cargo_no = p_cargo_no
                );

            UPDATE cargo_lifting_delay
            SET
                record_status = 'V',
                last_updated_by = p_user
            WHERE
                cargo_no = p_cargo_no;

            UPDATE carrier_inspection
            SET
                record_status = 'V',
                last_updated_by = p_user
            WHERE
                cargo_no = p_cargo_no;

            UPDATE storage_lift_nom_split
            SET
                record_status = 'V',
                last_updated_by = p_user
            WHERE
                parcel_no IN (
                    SELECT
                        parcel_no
                    FROM
                        storage_lift_nomination
                    WHERE
                        cargo_no = p_cargo_no
                );

        END IF;

        IF ( ecbp_cargo_status.geteccargostatus(p_cargo_status) = 'A' ) THEN

    -- Does the user have access?
            FOR item IN user_roles LOOP IF item.role_id = 'MA.APPROVED' THEN
                v_has_access := 'Y';
            END IF;
            END LOOP;

	--we havent implement the Marine role

            ecdp_dynsql.writetemptext('UE_REPLICATE_CARGOVALUES', 'we havent implement the Marine role');
            v_has_access := 'Y';
            IF ecdp_context.getappuser IS NOT NULL AND v_has_access = 'N' THEN
                raise_application_error(-20857, 'You do not have sufficient permissions to change the cargo status to Approved');
            END IF;

            UPDATE storage_lift_nom_split
            SET
                record_status = 'A',
                last_updated_by = p_user
            WHERE
                parcel_no IN (
                    SELECT
                        parcel_no
                    FROM
                        storage_lift_nomination
                    WHERE
                        cargo_no = p_cargo_no
                );

        END IF;

	-- check if an insert should be activated

        FOR curmapping IN c_rev_mapping(p_cargo_status) LOOP
            lv_rev_qty_code := curmapping.rev_qty_code;
            lv_tran_qty_code := curmapping.tran_qty_code;
        END LOOP;

        IF ( lv_rev_qty_code IS NOT NULL AND lv_tran_qty_code IS NOT NULL ) THEN
		--loop all nominations
            FOR curnom IN c_nominations(p_cargo_no) LOOP

			-- do nothing if no contract
                lv_contract_code := getcontractcode(curnom.parcel_no);
                IF lv_contract_code IS NULL THEN
                    return;
                END IF;
                lv_exist := exist(curnom.parcel_no, lv_rev_qty_code, 'SUM');

			-- handle cargo planning quantities special
                IF ( lv_tran_qty_code IN (
                    'REQUESTED',
                    'NOMINATED',
                    'SCHEDULED'
                ) ) THEN
                    ln_prod_meas_no := ecbp_storage_lifting.getprodmeasno(curnom.parcel_no);

				-- get unit and mapping information
                    FOR curmapping IN c_mapping(ln_prod_meas_no) LOOP
                        lv_unit := curmapping.unit;
                        lv_item_condition := curmapping.item_condition;
					-- Check if override of qty mapping exist in lifting account meas setup
                        IF ec_lift_acc_meas_setup.rev_qty_mapping(ec_storage_lift_nomination.lifting_account_id(curnom.parcel_no)
                        , ln_prod_meas_no) IS NOT NULL THEN
                            lv_rev_qty_mapping := ec_lift_acc_meas_setup.rev_qty_mapping(ec_storage_lift_nomination.lifting_account_id
                            (curnom.parcel_no), ln_prod_meas_no);
                        ELSE
                            lv_rev_qty_mapping := curmapping.rev_qty_mapping;
                        END IF;

                    END LOOP;

				--validate configuration

                    IF lv_rev_qty_mapping IS NULL THEN
                        raise_application_error(-20000, 'Revenue mapping is not configured in lifting measurement for nomination unit.'
                        );
                    ELSIF lv_rev_qty_mapping <> 'QTY1' THEN
                        raise_application_error(-20000, 'Revenue mapping for nomination unit is not pointing to QTY1.');
                    END IF;

				-- get qty

                    IF lv_tran_qty_code = 'REQUESTED' THEN
                        ln_qty := curnom.grs_vol_requested;
                    ELSIF lv_tran_qty_code = 'NOMINATED' THEN
                        ln_qty := curnom.grs_vol_nominated;
                    ELSIF lv_tran_qty_code = 'SCHEDULED' THEN
                        ln_qty := curnom.grs_vol_schedule;
                    END IF;

                    IF lv_exist = 'N' THEN
                        insertqty(curnom.parcel_no, lv_rev_qty_mapping, lv_unit, ln_qty, lv_unit,
                                  nvl(lv_item_condition, 'NET'), lv_rev_qty_code, NULL, lv_contract_code, p_user);
                    ELSE
                        updateqty(curnom.parcel_no, lv_rev_qty_code, ln_qty, lv_unit, nvl(lv_item_condition, 'NET'), lv_rev_qty_mapping
                        , p_user);
                    END IF;

                ELSE -- terminal operation quantities
                    IF lv_rev_qty_code IN (
                        'LOAD'
                    ) THEN
                        FOR curstoragelifting IN c_storage_lifting(curnom.parcel_no, lv_rev_qty_code) LOOP
                            insertload(curnom.parcel_no, curstoragelifting.product_meas_no);
                        END LOOP;

                    ELSIF lv_rev_qty_code IN (
                        'EST_UNLOAD'
                    ) THEN
					-- Only do exp unload if incoterm is CIF
                        IF ec_prosty_codes.alt_code(ec_storage_lift_nomination.incoterm(curnom.parcel_no), 'INCOTERM') = 'UNLOAD'
                        THEN
                            FOR curstoragelifting IN c_storage_lifting(curnom.parcel_no, lv_rev_qty_code) LOOP
                                insertload(curnom.parcel_no, curstoragelifting.product_meas_no);
                            END LOOP;

                        END IF;
                    ELSIF lv_rev_qty_code = 'UNLOAD' THEN
					-- Only do unload if incoterm is CIF
                        IF ec_prosty_codes.alt_code(ec_storage_lift_nomination.incoterm(curnom.parcel_no), 'INCOTERM') = 'UNLOAD'
                        THEN
                            FOR curstoragelifting IN c_storage_lifting(curnom.parcel_no, lv_rev_qty_code) LOOP
                                insertunload(curnom.parcel_no, curstoragelifting.product_meas_no);
                            END LOOP;

                        END IF;
                    END IF;
                END IF;

            END LOOP;
        END IF;

    END insertfromcargostatus;

    PROCEDURE updatefromcargostatus (
        p_cargo_no           NUMBER,
        p_cargo_status_old   VARCHAR2,
        p_cargo_status_new   VARCHAR2,
        p_user               VARCHAR2 DEFAULT NULL
    ) IS
        ln_new_sort_order     NUMBER;
        ln_old_sort_order     NUMBER;
        lv2_transaction_key   VARCHAR2(32);
        lv2_cargo_name        VARCHAR2(240);
    BEGIN
--Default EC Product value for EC Code 'TRAN_CARGO_STATUS:
--Sort Code  Code_text
--10   T     Tentative
--20 O   Official
--25 R   Ready For Harbour
--30 C   Closed
--40 A   Approved
--50 D   Cancelled
  /*-------------------------------------------------------------------------
  -- The following code can be used as a starting point for
  -- replicating Cargo data values into the IFAC_CARGO_VALUE table
  -------------------------------------------------------------------------*/
        NULL;
  /*
  ln_old_sort_order := nvl(ec_prosty_codes.sort_order(p_cargo_status_old, 'TRAN_CARGO_STATUS'),0);
  ln_new_sort_order :=ec_prosty_codes.sort_order(p_cargo_status_new, 'TRAN_CARGO_STATUS');
  lv2_cargo_name := ec_cargo_transport.cargo_name(p_cargo_no);

  if ln_new_sort_order > ln_old_sort_order then
     insertfromcargostatus(p_cargo_no, p_cargo_status_new, p_user);
  else -- Cargo status has been lowered so the IFAC record is ignored (by setting IGNORE_IND = Y)
    --see if there are IFAC records processed for this cargo:
    SELECT max(TRANSACTION_KEY) into lv2_transaction_key
       FROM ifac_cargo_value
       WHERE ALLOC_NO_MAX_IND = 'Y'
       AND CARGO_NO = lv2_cargo_name
       AND TRANS_KEY_SET_IND = 'Y'
       AND ec_cont_document.document_level_code(DOCUMENT_KEY) != 'BOOKED'
       AND TRANSACTION_KEY IS NOT NULL;

     IF lv2_transaction_key  is not null  THEN
         RAISE_APPLICATION_ERROR(-20001,'There is a document - '||ec_cont_transaction.document_key(lv2_transaction_key)||' - currently using the data from the selected cargo. The doucment must first be deleted or booked before the Cargo Status can be changed.');
     ELSE
         UPDATE ifac_cargo_value SET IGNORE_IND = 'Y',  last_updated_by = p_user, status = 'UPDATED'
         WHERE CARGO_NO = lv2_cargo_name
         AND ALLOC_NO_MAX_IND = 'Y'
         AND TRANS_KEY_SET_IND = 'N' ;
     END IF;
  end if;
  */
    END updatefromcargostatus;

END ue_replicate_cargovalues;
/
