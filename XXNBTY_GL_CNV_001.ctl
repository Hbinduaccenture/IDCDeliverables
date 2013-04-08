-------------------------------------------------------------------------------
-- Control File        : XXNBTY_GL_CNV_001
-- Author’s name       : Anirban Das (NBTY ERP Implementation)
-- Date written        : 20-DEC-2012
-- RICEFW Object id    : NBTY-FIN-C-001
-- Description         : This is a Control File used for GL Journal Conversion.
-- Program Style       : Subordinate
-- Maintenance History :
-- Date           Issue#   Name          Remarks
-------------------------------------------------------------------------------
-- 20-DEC-2012             Anirban Das   Initial development.
-- 22-Mar-2013             Pavan M       Removed the fillers for segments.
-------------------------------------------------------------------------------
OPTIONS (SKIP=1,errors=500000)
LOAD DATA
INFILE '$INTERFACE_HOME/incoming/data'     
APPEND INTO TABLE XXNBTY_GL_INTERFACE_STG_TB
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS 
(
COMPANY               CHAR "(:COMPANY)",	
FISCAL_YEAR           CHAR "(:FISCAL_YEAR)",
ACCT_PERIOD	          INTEGER EXTERNAL "TO_NUMBER(:ACCT_PERIOD)",
CONTROL_GROUP	      INTEGER EXTERNAL "TO_NUMBER(:CONTROL_GROUP)",
SYSTEM	              CHAR "(:SYSTEM)",
JE_TYPE	              CHAR "(:JE_TYPE)",
JE_SEQUENCE	          INTEGER EXTERNAL "TO_NUMBER(:JE_SEQUENCE)",
LINE_NBR	          INTEGER EXTERNAL "TO_NUMBER(:LINE_NBR)",
ACCT_UNIT	          CHAR "(:ACCT_UNIT)",
ACCOUNT	              CHAR "(:ACCOUNT)",
SUB_ACCOUNT	          CHAR "(:SUB_ACCOUNT)",
SOURCE_CODE	          CHAR "(:SOURCE_CODE)",
REFERENCE4	          CHAR "(:REFERENCE4)",
DESCRIPTION           CHAR "(:DESCRIPTION)",
BASE_AMOUNT           INTEGER EXTERNAL "TO_NUMBER(:BASE_AMOUNT)",
TO_COMPANY	          CHAR "(:TO_COMPANY)",
TRANSACTION_DATE	  "TRUNC(TO_DATE(:TRANSACTION_DATE,'RRRR-MM-DD HH24:MI:SS'))",
CURRENCY_CODE	      CHAR "TRIM(:CURRENCY_CODE)",
ORIG_COMPANY	      CHAR "(:ORIG_COMPANY)",
ORIG_PROGRAM	      CHAR "(:ORIG_PROGRAM)",
CURRENCY_CODE2	      CHAR "(:CURRENCY_CODE2)",
LAWSON	              CHAR "(:LAWSON)",
LEDGER	              CHAR "(:LEDGER)",
SEGMENT1		      CHAR "(:SEGMENT1)",
SEGMENT2		      CHAR "(:SEGMENT2)",
SEGMENT3		      CHAR "(:SEGMENT3)",
SEGMENT4		      CHAR "(:SEGMENT4)",
SEGMENT5		      CHAR "(:SEGMENT5)",
SEGMENT6		      CHAR "(:SEGMENT6)",
SEGMENT7		      CHAR "(:SEGMENT7)",
SEGMENT8		      CHAR "(:SEGMENT8)",
REFERENCE21           CHAR "(:REFERENCE21)",
JE_NAME               CHAR "TRIM(:JE_NAME)",
RECORD_ID             SEQUENCE(max,1)
)

