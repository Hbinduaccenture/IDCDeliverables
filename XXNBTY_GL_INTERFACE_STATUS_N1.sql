---------------------------------------------------------------------------
/*
Index Name          : XXNBTY_GL_INTERFACE_STATUS_U1
Author’s name       : Anirban Das (NBTY ERP Implementation)
Date written        : 20-DEC-2012
RICEFW Object id    : NBTY-FIN-C-002
Description         : This is a index on NBTY_GL_INTERFACE_STG_TB 
                      staging table
Program Style       : Subordinate
Maintenance History :
Date           Issue#   Name          Remarks
-----------    ------   -----------   --------------------------------------
20-DEC-2012             Anirban Das   Initial development.
*/
----------------------------------------------------------------------------

CREATE INDEX BOLINF.XXNBTY_GL_INTERFACE_STATUS_N1 ON BOLINF.XXNBTY_GL_INTERFACE_STG_TB
(RECORD_ID,STATUS);

SHOW ERRORS;
EXIT;
