CREATE OR REPLACE TYPE SND_TOOLTIP_CELL AS OBJECT (
  rowindex           INTEGER,
  colindex           INTEGER,
  text               VARCHAR2(100),
  font               VARCHAR2(100),
  color              VARCHAR2(30),
  alignment          VARCHAR2(30),
  columnSpan         INTEGER,
  rowSpan            INTEGER,
  margin             INTEGER
);