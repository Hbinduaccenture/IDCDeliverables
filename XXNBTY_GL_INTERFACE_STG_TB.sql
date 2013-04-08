---------------------------------------------------------------------------
/*
Table Name          : XXNBTY_GL_INTERFACE_STG_TB
Author’s name       : Anirban Das (NBTY ERP Implementation)
Date written        : 20-DEC-2012
RICEFW Object id    : NBTY-FIN-C-002
Description         : This is a staging table used for GL Journal Conversion.
Program Style       : Subordinate
Maintenance History :
Date           Issue#   Name          Remarks
-----------    ------   -----------   --------------------------------------
20-DEC-2012             Anirban Das   Initial development.
*/
----------------------------------------------------------------------------

  CREATE TABLE BOLINF.XXNBTY_GL_INTERFACE_STG_TB 
   ( STATUS               VARCHAR2(30)
   , COMPANY              VARCHAR2(30)
   , FISCAL_YEAR          VARCHAR2(30)
   , ACCT_PERIOD          VARCHAR2(30)
   , CONTROL_GROUP        VARCHAR2(30)
   , SYSTEM               VARCHAR2(30)
   , JE_TYPE              VARCHAR2(30)
   , JE_SEQUENCE          NUMBER
   , LINE_NBR 			  NUMBER 
   , ACCT_UNIT            VARCHAR2(30) 
   , ACCOUNT              VARCHAR2(30) 
   , SUB_ACCOUNT          VARCHAR2(30) 
   , SOURCE_CODE          VARCHAR2(30) 
   , REFERENCE4           VARCHAR2(30) 
   , DESCRIPTION          VARCHAR2(30) 
   , BASE_AMOUNT          NUMBER 
   , TO_COMPANY           VARCHAR2(30) 
   , TRANSACTION_DATE     DATE 
   , CURRENCY_CODE        VARCHAR2(30) 
   , ORIG_COMPANY         VARCHAR2(150) 
   , ORIG_PROGRAM         VARCHAR2(30) 
   , CURRENCY_CODE2       VARCHAR2(30) 
   , LAWSON               VARCHAR2(30) 
   , LEDGER               VARCHAR2(30) 
   , SEGMENT1             VARCHAR2(30) 
   , SEGMENT2             VARCHAR2(30) 
   , SEGMENT3             VARCHAR2(30) 
   , SEGMENT4             VARCHAR2(30) 
   , SEGMENT5             VARCHAR2(30) 
   , SEGMENT6             VARCHAR2(30) 
   , SEGMENT7             VARCHAR2(30) 
   , SEGMENT8             VARCHAR2(30) 
   , REFERENCE21          VARCHAR2(300) 
   , JE_NAME              VARCHAR2(150) 
   , LEDGER_ID            NUMBER 
   , CHART_OF_ACCOUNTS_ID NUMBER 
   , PERIOD_NAME          VARCHAR2(15) 
   , CODE_COMBINATION_ID  NUMBER 
   , RECORD_ID            NUMBER 
   , ERROR_MESSAGE        VARCHAR2(2000) 
   , CREATION_DATE        DATE 
   , CREATED_BY           NUMBER 
   , LAST_UPDATE_DATE     DATE 
   , LAST_UPDATED_BY      NUMBER 
   , REQUEST_ID           NUMBER 
   , FILENAME             VARCHAR2(200));


GRANT ALL ON BOLINF.XXNBTY_GL_INTERFACE_STG_TB TO APPS;

SHOW ERRORS;
EXIT;



