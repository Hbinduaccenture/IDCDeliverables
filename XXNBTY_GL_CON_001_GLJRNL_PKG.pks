CREATE OR REPLACE PACKAGE XXNBTY_GL_CON_001_GLJRNL_PKG
---------------------------------------------------------------------------
/*
Package Name        : XXNBTY_GL_CON_001_GLJRNL_PKG
Author’s name       : Anirban Das (NBTY ERP Implementation)
Date written        : 20-DEC-2012
RICEFW Object id    : NBTY-FIN-C-002
Description         : This package is created for GL Journals Line Conversion
Program Style       : Subordinate
Maintenance History :
Date           Issue#   Name          Remarks
-----------    ------   -----------   --------------------------------------
20-DEC-2012             Anirban Das   Initial development.
*/
----------------------------------------------------------------------------
AS
   ------------------------------------------------------------------------------
   /*
   Procedure Name      : MAIN
   Author’s name       : Anirban Das (NBTY ERP Implementation)
   Date written        : 20-DEC-2012
   RICEFW Object id    : NBTY-FIN-C-002
   Description         : This package is created for GL Journals Line Conversion
   Program Style       : Subordinate
   Maintenance History :
   Date           Issue#   Name          Remarks
   -----------    ------   -----------   ----------------------------------------
   20-DEC-2012             Anirban Das   Initial development.
   */
   ------------------------------------------------------------------------------
   PROCEDURE MAIN ( o_errbuf  OUT VARCHAR2
                   ,o_retcode OUT NUMBER);
                   
   ------------------------------------------------------------------------------
   /*
   Procedure Name      : CHECK_JOURNAL
   Author’s name       : Anirban Das (NBTY ERP Implementation)
   Date written        : 20-DEC-2012
   RICEFW Object id    : NBTY-FIN-C-002
   Description         : This procedure is created for GL Journals Line Conversion
   Program Style       : Subordinate
   Maintenance History :
   Date           Issue#   Name          Remarks
   -----------    ------   -----------   ----------------------------------------
   20-DEC-2012             Anirban Das   Initial development.
   */
   ------------------------------------------------------------------------------               
   PROCEDURE CHECK_JOURNAL;
   
   ------------------------------------------------------------------------------
   /*
   Procedure Name      : VALIDATE_JOURNALS
   Author’s name       : Anirban Das (NBTY ERP Implementation)
   Date written        : 20-DEC-2012
   RICEFW Object id    : NBTY-FIN-C-002
   Description         : This package is created for GL Journals Line Conversion
   Program Style       : Subordinate
   Maintenance History :
   Date           Issue#   Name          Remarks
   -----------    ------   -----------   ----------------------------------------
   20-DEC-2012             Anirban Das   Initial development.
   */
   ------------------------------------------------------------------------------               
   PROCEDURE VALIDATE_JOURNALS;
  
   ------------------------------------------------------------------------------
   /*
   Procedure Name      : INSERT_INTERFACE
   Author’s name       : Anirban Das (NBTY ERP Implementation)
   Date written        : 20-DEC-2012
   RICEFW Object id    : NBTY-FIN-C-002
   Description         : This package is created for GL Journals Line Conversion
   Program Style       : Subordinate
   Maintenance History :
   Date           Issue#   Name          Remarks
   -----------    ------   -----------   ----------------------------------------
   20-DEC-2012             Anirban Das   Initial development.
   */
   ------------------------------------------------------------------------------   
   PROCEDURE INSERT_INTERFACE;
   
   ------------------------------------------------------------------------------
   /*
   Procedure Name      : FILE_STATUS
   Author’s name       : Anirban Das (NBTY ERP Implementation)
   Date written        : 20-DEC-2012
   RICEFW Object id    : NBTY-FIN-C-002
   Description         : This procedure is created for displaying the processed 
                         and unprocessed file names.
   Program Style       : Subordinate
   Maintenance History :
   Date           Issue#   Name          Remarks
   -----------    ------   -----------   ----------------------------------------
   20-DEC-2012             Anirban Das   Initial development.
   */
   ------------------------------------------------------------------------------
   PROCEDURE FILE_STATUS;
   
   ------------------------------------------------------------------------------
   /*
   Procedure Name      : ERROR_LOG
   Author’s name       : Anirban Das (NBTY ERP Implementation)
   Date written        : 20-DEC-2012
   RICEFW Object id    : NBTY-FIN-C-002
   Description         : This procedure is created for creating a report for 
                         displaying the error report.
   Program Style       : Subordinate
   Maintenance History :
   Date           Issue#   Name          Remarks
   -----------    ------   -----------   ----------------------------------------
   20-DEC-2012             Anirban Das   Initial development.
   */
   ------------------------------------------------------------------------------
   PROCEDURE ERROR_LOG;
   
   ------------------------------------------------------------------------------
   /*
   Procedure Name      : STANDARD_IMPORT
   Author’s name       : Anirban Das (NBTY ERP Implementation)
   Date written        : 20-DEC-2012
   RICEFW Object id    : NBTY-FIN-C-002
   Description         : This procedure is created for launching the standard 
                         import program.
   Program Style       : Subordinate
   Maintenance History :
   Date           Issue#   Name          Remarks
   -----------    ------   -----------   ----------------------------------------
   20-DEC-2012             Anirban Das   Initial development.
   */
   ------------------------------------------------------------------------------   
    PROCEDURE STANDARD_IMPORT;
    
    ------------------------------------------------------------------------------
   /*
   Procedure Name      : STANDARD_PURGE
   Author’s name       : Anirban Das (NBTY ERP Implementation)
   Date written        : 20-DEC-2012
   RICEFW Object id    : NBTY-FIN-C-002
   Description         : This procedure is created for purging the data from the
                         interface table.
   Program Style       : Subordinate
   Maintenance History :
   Date           Issue#   Name          Remarks
   -----------    ------   -----------   ----------------------------------------
   20-DEC-2012             Anirban Das   Initial development.
   */
   ------------------------------------------------------------------------------ 
   PROCEDURE STANDARD_PURGE;
   
END  XXNBTY_GL_CON_001_GLJRNL_PKG;
/
SHOW ERRORS;
EXIT;