---------------------------------------------------------------------------
/*
Synonym Name        : XXNBTY_GL_INTERFACE_STG_TB
Author’s name       : Anirban Das (NBTY ERP Implementation)
Date written        : 20-DEC-2012
RICEFW Object id    : NBTY-FIN-C-002
Description         : This is a synonym for table 
                      NBTY_GL_INTERFACE_STG_TB.
Program Style       : Subordinate
Maintenance History :
Date           Issue#   Name          Remarks
-----------    ------   -----------   --------------------------------------
20-DEC-2012             Anirban Das   Initial development.
*/
----------------------------------------------------------------------------
CREATE SYNONYM APPS.XXNBTY_GL_INTERFACE_STG_TB FOR BOLINF.XXNBTY_GL_INTERFACE_STG_TB;

SHOW ERRORS;
EXIT;