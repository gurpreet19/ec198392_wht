CREATE OR REPLACE PACKAGE EcDp_Matrix IS
/***********************************************************************
** Package            :  EcDp_Matrix
**
** $Revision: 1.1 $
**
** Purpose            :  Provide functions to manage 2 dimensional arrays
**
**
** Documentation  :  www.energy-components.com
**
** Created  : 13.12.2001  Stig Vidar Nordgaard
**
** Modification history:
**
** Version  Date        Whom  Change description:
** -------  ------      ----- --------------------------------------
** 1.0      13.12.2001  SVN   Initial version
***************************************************************************/

   /* Return the value in a cell */
   FUNCTION cell (p_row INTEGER, p_col INTEGER)
   RETURN NUMBER;

   /* Check if matrix contains empty cells */
   FUNCTION emptyCellInMatrix (p_row INTEGER, p_col INTEGER)
   RETURN BOOLEAN;

   /* Create an array */
   PROCEDURE make
           (num_rows_in        INTEGER,
            num_columns_in     INTEGER,
            initial_value_in   NUMBER := NULL,
            conflict_action_in VARCHAR2 := 'OVERWRITE');


   /* Change the value in a cell */
   PROCEDURE CHANGE(p_row INTEGER, p_col INTEGER, p_value NUMBER);

   /* Erase the array */
   PROCEDURE erase;

   /* Display the array */
   PROCEDURE display
           (start_row_in INTEGER := 1,
            end_row_in   INTEGER,
            start_col_in INTEGER := 1,
            end_col_in   INTEGER,
            display_style_in VARCHAR2 := 'ARRAY');

END EcDp_Matrix;