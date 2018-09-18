CREATE OR REPLACE PACKAGE BODY EcDp_Matrix IS
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

	/*------------------------Private Variables ----------------------*/

	/* The number of rows in the array */
	number_of_rows INTEGER := NULL;

	/* The number of columns in the array */
	number_of_columns INTEGER := NULL;

	/* The generic table structure for a numeric table */
	TYPE number_array_type IS TABLE OF NUMBER
		INDEX BY BINARY_INTEGER;

	/* The actual table which will hold the array */
	number_array number_array_type;

	/* An empty table used to erase the array */
	empty_array number_array_type;

/*------------------------Private Modules ----------------------*/
--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : rowForCell                                                                   --
-- Description    : Returns the row in the table that stores the value for                       --
--                  the specified cell in the array.                                             --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION rowForCell (p_row INTEGER, p_col INTEGER)
RETURN INTEGER
--</EC-DOC>
IS
BEGIN
	RETURN (p_col - 1) * number_of_rows + p_row;
END;

/*------------------------Public Modules ----------------------*/
--<EC-DOC>
--------------------------------------------------------------------------------------------------
-- Procedure      : make                                                                        --
-- Description    : Create an array of the specified size, with the initial                     --
--	                 value. If the table is already in use, it will be erased                    --
--	                 and then re-made only if the conflict action is the                         --
--	                 default value above.                                                        --
--                                                                                              --
-- Preconditions  :                                                                             --
-- Postconditions :                                                                             --
--                                                                                              --
-- Using tables   :                                                                             --
--                                                                                              --
-- Using functions:                                                                             --
--                                                                                              --
--                                                                                              --
--                                                                                              --
-- Configuration                                                                                --
-- required       :                                                                             --
--                                                                                              --
-- Behaviour      :                                                                             --
--                                                                                              --
--------------------------------------------------------------------------------------------------
PROCEDURE make
           (num_rows_in        INTEGER,
            num_columns_in     INTEGER,
            initial_value_in   NUMBER := NULL,
            conflict_action_in VARCHAR2 := 'OVERWRITE')
--</EC-DOC>
IS
BEGIN
		/*
		|| If number_of_rows is NOT NULL, then the array is
		|| already in use. If the conflict action is the
		|| default or OVERWRITE, then erase the existing
		|| array.
		*/
		IF number_of_rows IS NOT NULL AND
			UPPER (conflict_action_in) = 'OVERWRITE'
		THEN
			erase;
		END IF;
		/*
		|| Only continue now if my number of rows is NULL.
		|| If it has a value, then table is in use and user
		|| did NOT want to overwrite it.
		*/
		IF number_of_rows IS NULL
		THEN
			/* Set the global variables storing size of array */
			number_of_rows := num_rows_in;
			number_of_columns := num_columns_in;
			/*
			|| A PL/SQL table's row is defined only if a value
			|| is assigned to that row, even if that is only a
			|| NULL value. So to create the array, I will simply
			|| make the needed assignments. Remember: I use a single
			|| table, but segregate distinct areas of the table for each
			|| column of data. I use the rowForCell function to
			|| "space out" the different cells of the array across
			|| the table.
			*/
			FOR col_index IN 1 .. number_of_columns
			LOOP
				FOR row_index IN 1 .. number_of_rows
				LOOP
					number_array (rowForCell (row_index, col_index))
						:= initial_value_in;
				END LOOP;
			END LOOP;
		END IF;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : cell                                                                         --
-- Description    : Retrieve the value in a cell using rowForCell.                               --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION cell (p_row INTEGER, p_col INTEGER)
RETURN NUMBER
--</EC-DOC>
IS
BEGIN
	RETURN number_array (rowForCell (p_row, p_col));
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : change                                                                       --
-- Description    : Change the value in a cell using rowForCell.                                 --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE change(p_row INTEGER, p_col INTEGER, p_value NUMBER)
--</EC-DOC>
IS
BEGIN
	number_array (rowForCell (p_row, p_col)) := p_value;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : erase                                                                        --
-- Description    : Erase a table by assigning an empty table to a non-empty                     --
--                  array. Then set the size globals for the array to NULL.                      --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE erase
--</EC-DOC>
IS
BEGIN
	number_array := empty_array;
   number_of_rows := NULL;
	number_of_columns := NULL;
END;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Procedure      : display                                                                      --
-- Description    : Let the user provide a range of columns and rows for display.                --
--                  The default values for the parameters are defined so that the                --
--                  user can call display without ANY arguments and see the full array.          --
--                  User can also ask for array-style listing, in which all values               --
--                  for a row are displayed on same line, or line-style in which each            --
--                  cell is displayed on its own line.                                           --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
PROCEDURE display
           (start_row_in INTEGER := 1,
            end_row_in   INTEGER,
            start_col_in INTEGER := 1,
            end_col_in   INTEGER,
            display_style_in VARCHAR2 := 'ARRAY')
--</EC-DOC>
IS
		/*
		|| The start and end values must be between 1 and number_of
		|| values for rows and columns.
		*/
		start_row INTEGER :=
			LEAST (GREATEST (1, start_row_in), number_of_rows);
		end_row INTEGER :=
			LEAST (GREATEST (1, end_row_in), number_of_rows);
		start_col INTEGER :=
			LEAST (GREATEST (1, start_col_in), number_of_columns);
		end_col INTEGER :=
			LEAST (GREATEST (1, end_col_in), number_of_columns);

		/* Named constants clean up the code below. */
		array_style BOOLEAN := UPPER (display_style_in) = 'ARRAY';
		line_style BOOLEAN := UPPER (display_style_in) = 'LINE';

		/* Array-style display line containing row contents. */
		row_contents VARCHAR2 (1000);

		/* --------------------- Local Module -------------------------*/

		FUNCTION cellDescription (row_in INTEGER, col_in INTEGER)
			RETURN VARCHAR2
		/*
		|| To make the body of the main display program more
		|| readable, I will create a local module which takes the row
		|| and column of a cell and returns a string description of the
		|| contents. If array style, then simply return the contents.
		|| If line style, prefix the cell value with its location.
		*/
		IS
		BEGIN
			IF array_style
			THEN
				RETURN TO_CHAR (number_array
										(rowForCell (row_in, col_in)));
			ELSIF line_style
			THEN
				RETURN 'Cell (' ||
						 TO_CHAR (row_in) || ',' ||
						 TO_CHAR (col_in) || ') contents: ' ||
						 TO_CHAR (number_array
										(rowForCell (row_in, col_in)));
			END IF;
		END;
BEGIN
		/*
		|| Build header for output if array style. Assume max size of
		|| 10 digits per cell. To really do this right, the package would
		|| keep track of the size of values in the array and AUTOMATICALLY
		|| adjust report.
		*/
		IF array_style
		THEN
			row_contents := RPAD ('Row', 10);
			FOR col_index IN start_col .. end_col
			LOOP
				row_contents :=
					row_contents ||
					RPAD ('Column ' || TO_CHAR (col_index), 10);
			END LOOP;
			DBMS_OUTPUT.PUT_LINE (row_contents);
		END IF;
		/*
		|| Now loop through all the rows of interest and display
		|| the contents in the specified format.
		*/
		FOR row_index IN start_row .. end_row
		LOOP
			IF array_style
			THEN
				/* Construct a single line of text for all columns */
				row_contents := RPAD (TO_CHAR (row_index), 10);
				FOR col_index IN start_col .. end_col
				LOOP
					row_contents :=
						row_contents ||
						RPAD (cellDescription (row_index, col_index), 10);
				END LOOP;
				DBMS_OUTPUT.PUT_LINE (row_contents);

			ELSIF line_style
			THEN
				/* Spit out a new line for each cell under examination */
				FOR col_index IN start_col .. end_col
				LOOP
					DBMS_OUTPUT.PUT_LINE
						(cellDescription (row_index, col_index));
				END LOOP;
			END IF;
		END LOOP;
END display;

--<EC-DOC>
---------------------------------------------------------------------------------------------------
-- Function       : emptyCellInMatrix                                                                  --
-- Description    : Check if the matrix contains at least one cell with NULL value               --
--                                                                                               --
-- Preconditions  :                                                                              --
-- Postconditions :                                                                              --
--                                                                                               --
-- Using tables   :                                                                              --
--                                                                                               --
-- Using functions:                                                                              --
--                                                                                               --
-- Configuration                                                                                 --
-- required       :                                                                              --
--                                                                                               --
-- Behaviour      :                                                                              --
--                                                                                               --
---------------------------------------------------------------------------------------------------
FUNCTION emptyCellInMatrix(
							p_row INTEGER,
							p_col INTEGER)
RETURN BOOLEAN
--</EC-DOC>
IS

li_error INTEGER;
li_ok    INTEGER;

lb_empty_cell BOOLEAN;

BEGIN

  lb_empty_cell := FALSE;

  FOR i IN 1..p_row -- row
  LOOP
    FOR j IN 1..p_col -- col
    LOOP
      IF EcDp_Matrix.cell(i,j) IS NULL THEN
         lb_empty_cell := TRUE;
      END IF;
    END LOOP;
  END LOOP;

  RETURN lb_empty_cell;

END emptyCellInMatrix;

END EcDp_Matrix;