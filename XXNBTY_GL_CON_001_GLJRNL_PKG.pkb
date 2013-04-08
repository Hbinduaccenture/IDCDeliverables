CREATE OR REPLACE PACKAGE BODY XXNBTY_GL_CON_001_GLJRNL_PKG
AS
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
29-JAN-2013             Dhivya        Updated as per latest Charts of 
                                      Accounts structure
12-FEB-2013             Dhivya       Change in the accounts and File changes
21-Mar-2013             Pavan        Commented the purging logic.                                      
*/
----------------------------------------------------------------------------
    g_desc1                  APPS.gl_code_combinations.segment1%TYPE;
    g_desc2                  APPS.gl_code_combinations.segment2%TYPE;
    g_desc3                  APPS.gl_code_combinations.segment3%TYPE;
    g_desc4                  APPS.gl_code_combinations.segment4%TYPE;
    g_desc5                  APPS.gl_code_combinations.segment5%TYPE;
   ----------------------------------------------------
   --Start of Changes by Dhivya on 29-JAN-2013
   ----------------------------------------------------
 -- g_desc6                  APPS.gl_code_combinations.segment6%TYPE := '000000';
 -- g_desc7                  APPS.gl_code_combinations.segment7%TYPE := '000';
 -- g_desc8                  APPS.gl_code_combinations.segment8%TYPE := '0000';
    g_desc6                  APPS.gl_code_combinations.segment6%TYPE := '000';
    g_desc7                  APPS.gl_code_combinations.segment7%TYPE := '000000';
    g_desc8                  APPS.gl_code_combinations.segment8%TYPE := '0000';
   ----------------------------------------------------
   --End of Changes by Dhivya on 29-JAN-2013
   ----------------------------------------------------
    g_request_id             NUMBER;
    g_actual_flag            VARCHAR2(1)  := 'A';
    g_user_je_category_name  VARCHAR2(30) := 'NBTY GL Conversion';
    g_user_je_source_name    VARCHAR2(30) := 'NBTY GL Conversion';
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
   PROCEDURE CHECK_JOURNAL
   IS 
            l_err_flag              VARCHAR2(1);
            l_err_message           VARCHAR2(4000);
            l_entered_dr            NUMBER;
            l_entered_cr            NUMBER;
            l_count                 NUMBER;
            l_filename              VARCHAR2(50);
        --  l_reference4            VARCHAR2(150);
        
        CURSOR c_file_name
        IS    
           SELECT FILENAME
           FROM xxnbty_gl_interface_stg_tb
           WHERE status = 'NEW' 
           GROUP BY filename;
         
      /* Added the cursor for the Amount for the Journal Names */
        CURSOR c_journal_name ( p_filename VARCHAR)
        IS    
           SELECT SUM(TRUNC(base_amount,2)) base_amount  -- Truncated to 2 decimals by Pavan on 27-Feb-13.
          --     , decode(sign(batchSUM(batch_amount) L_ENTERED_CR
                 , filename
          --     , je_name
           FROM xxnbty_gl_interface_stg_tb
           WHERE STATUS     = 'NEW'  
             AND filename   = p_filename
          -- AND je_name    = p_je_name
           GROUP BY filename;
                  
        BEGIN
            
          FOR rec_file_name IN c_file_name
            
            LOOP
                
                BEGIN
                    
                    FOR rec_journal_name IN c_journal_name (rec_file_name.filename)
                    
                    LOOP
                        l_err_flag    := 'N';
                        l_err_message := NULL;        
                              
                        -- IF (l_entered_dr + l_entered_cr) != 0   THEN
                        IF (rec_journal_name.base_amount) !=0 THEN  -- Added by Dhivya on 11-FEb-2013
                                
                            l_err_flag := 'Y';
                            l_err_message := ' ** The CR and DR amounts are not equal.**';
                                    
                                UPDATE xxnbty_gl_interface_stg_tb
                                SET status           = 'REJECTED'
                                   , error_message    = l_err_message
                                   , creation_date    = SYSDATE
                                   , last_update_date = SYSDATE
                                   , last_updated_by  = fnd_global.user_id
                                WHERE filename         = rec_file_name.filename;
                              --  AND je_name          = rec_file_name.je_name;
                                COMMIT;                                     
                                EXIT;
                        END IF;
                        
                    END LOOP;
                    
                EXCEPTION
                  WHEN OTHERS
                  THEN
                    fnd_file.put_line (fnd_file.LOG,
                                       'Other exception :'
                                       || SQLERRM
                                       || '.At Location:'
                                       || DBMS_UTILITY.format_error_backtrace
                                      );     
                END; 
                
            END LOOP;
            
            COMMIT;            
        EXCEPTION
          WHEN OTHERS
          THEN
            fnd_file.put_line (fnd_file.LOG,
                               'Other exception :'
                               || SQLERRM
                               || '.At Location:'
                               || DBMS_UTILITY.format_error_backtrace
                              );         

        END CHECK_JOURNAL;                                  
   ------------------------------------------------------------------------------
   /*
   Procedure Name      : VALIDATE_JOURNALS
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
   PROCEDURE VALIDATE_JOURNALS
   IS 
   
    -- Table type definition for the record variable to store the data retrieved.
       TYPE tab_rec IS TABLE OF xxnbty_gl_interface_stg_tb%ROWTYPE INDEX BY BINARY_INTEGER;
   
    ----------------------------------------------------------------
    -- Cursor to get the Journal Header details from staging table
    ----------------------------------------------------------------
        CURSOR c_valid_header 
        IS
           SELECT *
             FROM xxnbty_gl_interface_stg_tb
            WHERE status = 'NEW';  
        
        CURSOR c_journal_name ( p_filename VARCHAR,p_je_name VARCHAR)
        IS    
           SELECT SUM(base_amount) base_amount
            --   , decode(sign(batchSUM(batch_amount) l_entered_cr
                 , filename
                 , je_name
           FROM xxnbty_gl_interface_stg_tb
           WHERE STATUS     = 'NEW'  
             AND filename   = p_filename
             AND je_name    = p_je_name
           GROUP BY je_name;
        
               l_rec                   tab_rec;
               l_err_flag              VARCHAR2(1);
               l_err_message           VARCHAR2(4000);
               l_currency_code         fnd_currencies.currency_code%TYPE;
               l_period_status         VARCHAR2(50);
               l_period_name           VARCHAR2(20);
               l_count                 NUMBER := 0;
               e_val_err               EXCEPTION;
               l_concat_segs           APPS.gl_code_combinations_kfv.concatenated_segments%type;
               l_ccid                  NUMBER;
               l_errbuf                VARCHAR2(200);
               l_ledger_id             NUMBER;
               l_chart_of_accounts_id  NUMBER; 
               l_lookup_mng            APPS.fnd_lookup_values.meaning%TYPE;
               l_get_lookup_err        VARCHAR2(2400);
               l_ledger_name           VARCHAR2(200);
               l_ccid_err              VARCHAR2(10000);
               l_segment1              VARCHAR2(10);
           
      
    BEGIN
    
  ---------------------------------------------------------
    -- Validate Journal category name 
    ---------------------------------------------------------     
        BEGIN
            SELECT 1
            INTO l_count
            FROM gl_je_categories
            WHERE user_je_category_name = 'NBTY GL Conversion';
                  
             IF l_count = 0
             THEN  
                fnd_file.put_line (fnd_file.LOG,'Journal Category Name is not configured');
                RAISE e_val_err;       
             END IF; 
                 
        EXCEPTION
         WHEN NO_DATA_FOUND
         THEN       
               fnd_file.put_line (fnd_file.LOG,'Journal Category Name is not configured');
               RAISE e_val_err;    
         WHEN OTHERS
         THEN       
               fnd_file.put_line (fnd_file.LOG,'Exception while validating the Journal Category. '|| SQLERRM);
               RAISE e_val_err;    
        END;          
    ---------------------------------------------------------
    -- Validate Journal source name 
    ---------------------------------------------------------    
        BEGIN
            SELECT COUNT (1)
            INTO l_count
            FROM gl_je_sources
            WHERE user_je_source_name = 'NBTY GL Conversion';
                  
             IF l_count = 0
             THEN  
                fnd_file.put_line (fnd_file.LOG,'Journal Source is not configured');
                RAISE e_val_err;       
             END IF;
             
        EXCEPTION
         WHEN NO_DATA_FOUND
         THEN       
               fnd_file.put_line (fnd_file.LOG,'Journal Source is not configured');
               RAISE e_val_err;    
         WHEN OTHERS
         THEN       
               fnd_file.put_line (fnd_file.LOG,'Exception while validating the Journal Source. '|| SQLERRM);
               RAISE e_val_err;    
        END;           
    
    -----------------------------------------------
    -- Cursor loop for records
    -----------------------------------------------
        OPEN c_valid_header;
        LOOP
                         
        FETCH c_valid_header BULK COLLECT 
        INTO l_rec LIMIT 1000;
        
          IF l_rec.COUNT != 0 
          THEN
        
            FOR i IN l_rec.FIRST..l_rec.LAST
            LOOP
            
                 l_err_flag              := 'N';
                 l_err_message           := NULL;
                 l_ledger_id             := NULL;
                 l_ccid                  := NULL;
                 l_chart_of_accounts_id  := NULL;
                 l_period_name           := NULL;
                 g_desc1                 := NULL;               
                 g_desc2                 := NULL;
                 g_desc3                 := NULL;
                 g_desc4                 := NULL;
                 g_desc5                 := NULL;
                 l_ccid_err              := NULL;
                 l_segment1              := NULL;  -- Added to get the Segment1  value on 11-Feb-2013

    -----------------------------------------------
    -- Derive Ledger ID
    -----------------------------------------------
                 /*  BEGIN
                       XXNBTY_INT_UTIL_PKG.get_lookup_value( p_lookup_code  => l_rec(i).segment1 
                                                             ,p_lookup_type  => 'NBTY_LEGACY_TO_ORCL_LE_LU'
                                                            ,x_meaning      => l_lookup_mng 
                                                            ,x_description  => g_desc1 
                                                            ,x_errbuf       => l_get_lookup_err
                                                           );
                       
                       IF g_desc1 IS NULL
                       THEN
                          l_err_flag   := 'Y';
                          l_err_message:= l_err_message || ' ** Balancing Segment is not configured in NBTY_LEGACY_TO_ORCL_LE_LU ** ';                       
                       ELSE      
                          XXNBTY_INT_UTIL_PKG.get_lookup_value( p_lookup_code  => g_desc1
                                                                ,p_lookup_type  => 'NBTY_LE_TO_LEDGER_LU'
                                                               ,x_meaning      => l_lookup_mng 
                                                               ,x_description  => l_ledger_name 
                                                               ,x_errbuf       => l_get_lookup_err
                                                              );                                                   
                              IF l_ledger_name IS NOT NULL
                              THEN
                                BEGIN
                                  SELECT ledger_id
                                        , chart_of_accounts_id
                                  INTO l_ledger_id
                                      , l_chart_of_accounts_id
                                  FROM gl_ledgers
                                  WHERE name = l_ledger_name; 
                                EXCEPTION
                                  WHEN NO_DATA_FOUND 
                                  THEN
                                       l_err_flag   := 'Y';
                                       l_err_message:= l_err_message ||  ' ** Ledger Name:'|| l_ledger_name ||' is not valid ** ';       
                                  WHEN OTHERS
                                  THEN
                                       l_err_flag   := 'Y';
                                       l_err_message:= l_err_message || ' ** Exception while generating the Ledger ID :' || SQLERRM || '**' ;  
                                END;
                               ELSE
                                    l_err_flag   := 'Y';
                                    l_err_message:= l_err_message ||  ' ** Ledger Name is NULL ** ';                           
                               END IF;                                
                       END IF;       
                   EXCEPTION
                     WHEN OTHERS
                     THEN
                        l_err_flag   := 'Y';
                        l_err_message:= l_err_message ||'  ** Ledger Exception - Others : '|| SQLERRM || '**';
                   END;    */
           /* added the Coe to get Segment1 11-Feb-2013*/
                /*   SELECT SUBSTR(reference21,0,INSTR(reference21,'.')-1)
                     INTO l_segment1
                     FROM bolinf.nbty_gl_interface_stg_tb
                    WHERE record_id=l_rec(i).record_id;
                         
            XXNBTY_INT_UTIL_PKG.get_lookup_value( p_lookup_code  => l_segment1 
                                                                                ,p_lookup_type  => 'NBTY_LEGACY_TO_ORCL_LEDGER_LU'
                                                                               ,x_meaning      => l_lookup_mng 
                                                                               ,x_description  => l_ledger_name 
                                                                               ,x_errbuf       => l_get_lookup_err
                                                                            );            */                                       
                  IF l_rec(i).ledger IS NOT NULL
                  THEN
                     
                     BEGIN
                     
                        SELECT ledger_id
                              , chart_of_accounts_id
                        INTO l_ledger_id
                            , l_chart_of_accounts_id
                        FROM gl_ledgers
                        WHERE name = l_rec(i).ledger; 
                   
                   
                     EXCEPTION
                       WHEN NO_DATA_FOUND 
                       THEN
                            l_err_flag   := 'Y';
                            l_err_message:= l_err_message ||  ' ** Ledger Name:'|| l_ledger_name ||' is not valid ** ';       
                       WHEN OTHERS
                       THEN
                            l_err_flag   := 'Y';
                            l_err_message:= l_err_message || ' ** Exception while generating the Ledger ID for the ledger:'|| l_ledger_name  ||'.Msg:'|| SQLERRM || '**' ;  
                     
                     END;
                     
                  ELSE
                         l_err_flag   := 'Y';
                         l_err_message:= l_err_message ||  ' ** Ledger configuration not done for segment:'||l_rec(i).segment1||'in lookup NBTY_LEGACY_TO_ORCL_LEDGER_LU ** ';                           
                  END IF;                                
    ----------------------------------------------------
    -- Validate Currency Code
    ----------------------------------------------------
                   IF l_ledger_id IS NOT NULL THEN
                       
                       IF l_rec(i).currency_code2 IS NOT NULL THEN
                           
                           BEGIN
                               SELECT COUNT (1)
                               INTO l_count
                               FROM gl_ledgers
                               WHERE currency_code = l_rec(i).currency_code2
                                 AND ledger_id = l_ledger_id;             
                                
                                   IF l_count = 0 THEN
                                      l_err_flag := 'Y';
                                      l_err_message:= l_err_message||' '||' ** Invalid Currency code ** ';
                                   END IF;     
                           
                           EXCEPTION
                             WHEN NO_DATA_FOUND
                             THEN
                                  l_err_flag   := 'Y';
                                  l_err_message:= l_err_message||' '||' ** Currency code - No data found ** ';
                             WHEN TOO_MANY_ROWS
                             THEN
                                  l_err_flag   := 'Y';
                                  l_err_message:= l_err_message||' '||' ** Currency code - Too Many Rows ** ';
                             WHEN OTHERS
                             THEN
                                  l_err_flag   := 'Y';
                                  l_err_message:= l_err_message||' '||' Currency code - Others : '||SQLERRM|| '**';
                           END;
                       
                       ELSE
                           l_err_flag   := 'Y';
                           l_err_message:= l_err_message||' '||' ** Currency code is Null ** ';
                       END IF;
                   
                   ELSE    
                       l_err_flag   := 'Y';
                       l_err_message:= l_err_message||' '||' ** Ledger Id is null hence Currency cannot be validated ** ';
                   END IF;                       
    ---------------------------------------------------
    -- Validate Period Name
    -- Should be a Valid and Open Period
    ---------------------------------------------------
                   IF l_ledger_id IS NOT NULL THEN
                       
                       IF l_rec(i).transaction_date IS NOT NULL THEN
                             
                          BEGIN
                              
                               SELECT DECODE(gps.closing_status,'O','Y','N')
                                     , gp.period_name
                               INTO l_period_status
                                   , l_period_name
                               FROM gl_period_statuses gps
                                    , gl_ledgers gll
                                    , gl_periods gp
                               WHERE gps.set_of_books_id    = gll.ledger_id
                                 AND gps.application_id     = 101
                                 AND gp.period_name         = gps.period_name
                                 AND gps.period_type        = gll.accounted_period_type
                                 AND gp.period_set_name     = gll.period_set_name
                                 AND gll.ledger_id          = l_ledger_id
                                 AND l_rec(i).transaction_date BETWEEN gp.start_date AND gp.end_date  -- modified the accounting_date to transaction_date
                                 AND gp.adjustment_period_flag = 'N';
                                
                                  IF l_period_status != 'Y' THEN
                                          l_err_flag   := 'Y';
                                          l_err_message:= l_err_message||' ** Period Name should be in Open Period ** ';
                                  END IF;
                           
                          EXCEPTION
                            WHEN OTHERS
                            THEN
                                  l_err_flag   := 'Y';
                                  l_err_message:= l_err_message||' '||' ** Period Name - Others : '||SQLERRM|| '**';
                          END;
                       
                       ELSE
                           l_err_flag   := 'Y';
                           l_err_message:= l_err_message||' '||' ** Accounting Date is NULL hence period cannot be validated ** ';
                       END IF;
                   
                   ELSE    
                       l_err_flag   := 'Y';
                       l_err_message:= l_err_message||' '||' ** Ledger Id is null hence Period cannot be validated ** ';    
                   END IF;                       
    ----------------------------------------------------------------------
    -- Check the Journal Name
    ----------------------------------------------------------------------
                   IF  l_rec(i).je_name IS NULL THEN  -- added Je_name as given by Jeff on 12-Feb-2013
                       l_err_flag   := 'Y';
                       l_err_message:= l_err_message||' '||' ** Journal Name is Null ** ';
                   END IF; 
                  ----------------------------------------------------
                  -- Validate GL Code Combination Id
                  ----------------------------------------------------
                  /*  BEGIN  */
 
                     /* Begin of code to capture Legal Entity */
                                                          
                     /* XXNBTY_INT_UTIL_PKG.get_lookup_value( p_lookup_code  => l_rec(i).segment1 
                                                             ,p_lookup_type  => 'NBTY_LEGACY_TO_ORCL_LE_LU'
                                                               ,x_meaning      => l_lookup_mng 
                                                             ,x_description  => g_desc1 
                                                             ,x_errbuf       => l_get_lookup_err 
                                                            );  */
                     /* End of code*/                                            
                                
                     /* Begin of code to capture Reporting Segment */    
                        
                     /* XXNBTY_INT_UTIL_PKG.get_lookup_value( p_lookup_code  => l_rec(i).segment2 
                                                             ,p_lookup_type  => 'NBTY_LEGACY_TO_ORCL_RPT_LU'
                                                             ,x_meaning      => l_lookup_mng 
                                                             ,x_description  => g_desc2 
                                                             ,x_errbuf       => l_get_lookup_err 
                                                            );  */
                      /* End of code*/       
                    
                     /* Begin of code to capture Department */
                    
                     /* XXNBTY_INT_UTIL_PKG.get_lookup_value( p_lookup_code  => l_rec(i).segment3 
                                                             ,p_lookup_type  => 'NBTY_LEGACY_TO_ORCL_DEPT_LU'
                                                             ,x_meaning      => l_lookup_mng 
                                                             ,x_description  => g_desc3 
                                                             ,x_errbuf       => l_get_lookup_err 
                                                            );  */
                     /* End of code*/    
                    
                     /* Begin of code to capture Account */                               
                    
                     /* XXNBTY_INT_UTIL_PKG.get_lookup_value( p_lookup_code  => l_rec(i).segment4 
                                                             ,p_lookup_type  => 'NBTY_LEGACY_TO_ORCL_ACCT_LU'
                                                             ,x_meaning      => l_lookup_mng 
                                                             ,x_description  => g_desc4 
                                                             ,x_errbuf       => l_get_lookup_err 
                                                            );  */
                     /* End of code*/    
                    
                     /* Begin of code to capture Location */                               
 
                     /* XXNBTY_INT_UTIL_PKG.get_lookup_value( p_lookup_code  => l_rec(i).segment5 
                                                             ,p_lookup_type  => 'NBTY_LEGACY_TO_ORCL_LOC_LU'
                                                             ,x_meaning      => l_lookup_mng 
                                                             ,x_description  => g_desc5 
                                                             ,x_errbuf       => l_get_lookup_err 
                                                               );
                     /* End of code*/
                    
                     /* l_concat_segs := g_desc1||'.'||
                                     g_desc2||'.'||
                                     g_desc3||'.'||
                                     g_desc4||'.'||
                                     g_desc5||'.'||
                                     g_desc6||'.'||
                                     g_desc7||'.'||
                                     g_desc8;                                        
                  
                        l_ccid := APPS.fnd_flex_ext.get_ccid( application_short_name => 'SQLGL'
                                                             ,key_flex_code          => 'GL#'
                                                             ,structure_number       => l_chart_of_accounts_id
                                                             ,validation_date        => SYSDATE
                                                             ,concatenated_segments  => l_concat_segs);
                
  
                        IF l_ccid =0 THEN
                           l_err_flag   := 'Y';
                           l_err_message:= l_err_message||' '||' ** GL Code Combination ID does not exist ** ';
                        END IF;
                        
                   EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                         l_err_flag   := 'Y';
                         l_err_message:= l_err_message||' '||' ** GL code combination ID - No data found ** ';
                     WHEN OTHERS
                     THEN
                         l_err_flag   := 'Y';
                         l_err_message:= l_err_message||' '||' ** GL code combination ID - Others : '||SQLERRM|| '**';
                   END;   */
                   
                    /* XXNBTY_INT_UTIL_PKG.validate_derive_gl_account( p_concat_segs => l_rec(i).reference21
                                                                     , x_cc_id       => l_ccid
                                                                     , x_errbuf      => l_ccid_err);  
               
                    l_ccid := APPS.fnd_flex_ext.get_ccid( application_short_name => 'SQLGL'
                                                         ,key_flex_code          => 'GL#'
                                                         ,structure_number       => l_chart_of_accounts_id
                                                         ,validation_date        => SYSDATE
                                                         ,concatenated_segments  => l_rec(i).reference21);
 
                       IF l_ccid = 0 THEN
                          l_err_flag   := 'Y';
                          l_err_message:= l_err_message||' ** '||'Code Combination is Invalid '||' ** ';
                          l_ccid:=null;
                       END IF;*/
					   
					   
    ----------------------------------------------------------
    -- Updating the id's
    ----------------------------------------------------------
                     l_rec(i).ledger_id             := l_ledger_id;
                     l_rec(i).code_combination_id   := l_ccid;
                     l_rec(i).chart_of_accounts_id  := l_chart_of_accounts_id;
                     l_rec(i).period_name           := l_period_name;
                     l_rec(i).creation_date         := SYSDATE;
                     l_rec(i).last_update_date      := SYSDATE;
                     l_rec(i).last_updated_by       := fnd_global.user_id;
                     l_rec(i).error_message         := l_err_message;
                     
                          IF l_err_flag = 'Y'  THEN
                            l_rec(i).status := 'REJECTED';
                            
                         ELSIF l_err_flag = 'N'  THEN
                            l_rec(i).status := 'VALIDATED';
                            
                         END IF;
               
               COMMIT;
               
            END LOOP;
               
            FORALL i IN l_rec.FIRST..l_rec.LAST
                     
                   UPDATE  BOLINF.XXNBTY_GL_INTERFACE_STG_TB 
                   SET ledger_id              = l_rec(i).ledger_id            
                      , code_combination_id   = l_rec(i).code_combination_id  
                      , chart_of_accounts_id  = l_rec(i).chart_of_accounts_id 
                      , period_name           = l_rec(i).period_name          
                      , creation_date         = l_rec(i).creation_date        
                      , last_update_date      = l_rec(i).last_update_date     
                      , last_updated_by       = l_rec(i).last_updated_by      
                      , status                = l_rec(i).status 
                      , error_message         = l_rec(i).error_message                          
                   WHERE record_id             = l_rec(i).record_id;        
                       
           COMMIT;
           
          END IF;
          
        EXIT WHEN c_valid_header%NOTFOUND;
        
        END LOOP;
        
        COMMIT;
        
        CLOSE c_valid_header;
        
                   /*UPDATE  BOLINF.XXNBTY_GL_INTERFACE_STG_TB 
                      SET  ledger_id             = l_ledger_id
                          ,code_combination_id   = l_ccid
                          ,chart_of_accounts_id  = l_chart_of_accounts_id
                     --   ,reference4            = l_rec(i).reference4
                          ,last_update_date      = SYSDATE
                          ,last_updated_by       = fnd_global.user_id
                          ,period_name           = l_period_name
                    WHERE record_id              = l_rec(i).record_id;       
      
                         IF  l_err_flag = 'Y'  THEN
                  
                               UPDATE xxnbty_gl_interface_stg_tb
                                  SET status           = 'REJECTED'
                                     ,error_message    = l_err_message
                                     ,creation_date    = SYSDATE
                                     ,last_update_date = SYSDATE
                                     ,last_updated_by  = fnd_global.user_id
                                WHERE record_id        = l_rec(i).record_id;    
               
                         ELSIF  l_err_flag = 'N'  THEN
                  
                               UPDATE xxnbty_gl_interface_stg_tb
                                  SET status           = 'VALIDATED'
                                     ,error_message    = l_err_message
                                     ,creation_date    = SYSDATE
                                     ,last_update_date = SYSDATE
                                     ,last_updated_by  = fnd_global.user_id              
                                WHERE record_id        = l_rec(i).record_id;    
                       END IF;
               
               COMMIT;
               
            END LOOP;
          
          END IF;
        
        EXIT WHEN c_valid_header%NOTFOUND;
        
        END LOOP;
        
        COMMIT;
        
        CLOSE c_valid_header;*/
        
        
    EXCEPTION
      WHEN e_val_err
      THEN
           fnd_file.put_line (fnd_file.LOG,'Stopped the processing....');
      WHEN OTHERS
      THEN
           fnd_file.put_line (fnd_file.LOG,
                              'Other exception in VALIDATE_JOURNALS :'
                              || SQLERRM
                              || '.At Location:'
                              || DBMS_UTILITY.format_error_backtrace
                             );
    END VALIDATE_JOURNALS;
        
    ------------------------------------------------------------------------------
   /*
   Procedure Name      : INSERT_INTERFACE
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
   PROCEDURE INSERT_INTERFACE
   IS   
    -- Table type definition for the record variable to store the data retrieved.
       TYPE tab_rec IS TABLE OF xxnbty_gl_interface_stg_tb%ROWTYPE INDEX BY BINARY_INTEGER;
       
    ----------------------------------------------------------------
    -- Cursor to insert validated records in GL_INTERFACE table
    ----------------------------------------------------------------
        CURSOR c_valid_insert 
        IS
               SELECT *
               FROM xxnbty_gl_interface_stg_tb a
               WHERE a.status = 'VALIDATED'
                 AND NOT EXISTS (SELECT 1 
                                 FROM xxnbty_gl_interface_stg_tb b 
                                 WHERE a.filename = b.filename 
                                   AND b.status = 'REJECTED');
       
             l_user_id        NUMBER;
             l_rec            tab_rec;
             l_lookup_mng     APPS.fnd_lookup_values.meaning%TYPE;
             l_get_lookup_err VARCHAR2(2400);
             l_group_id       NUMBER;
             l_reference6     VARCHAR2(150);
        
        
            BEGIN 

                SELECT gl_interface_control_s.NEXTVAL
                  INTO l_group_id
                  FROM DUAL;            
        
                -----------------------------------------------
                -- Cursor loop for lines
                -----------------------------------------------
                OPEN c_valid_insert;
                LOOP
                       
                  FETCH c_valid_insert BULK COLLECT 
                  INTO l_rec LIMIT 1000;
                  
                  IF l_rec.COUNT != 0 THEN 
                  
                    FOR i IN l_rec.FIRST..l_rec.LAST
                    LOOP
                  
                        /* Added as Jeff on 11-Feb-2013 */
                                l_reference6 :=   LPAD(l_rec(i).company,3,'0')
                                                  ||'.'
                                                  ||l_rec(i).fiscal_year
                                                  ||'.'
                                                  ||LPAD(l_rec(i).acct_period,2,'0')
                                                  ||'.'
                                                  ||LPAD(l_rec(i).control_group,7,'0')
                                                  ||'.'
                                                  ||l_rec(i).system
                                                  ||'.'
                                                  ||l_rec(i).je_type
                                                  ||'.'
                                                  ||l_rec(i).je_sequence
                                                  ||'.'
                                                  ||LPAD(l_rec(i).line_nbr,5,'0');                         --     reference6
                        BEGIN
           
                            INSERT INTO gl_interface ( status
                                                      , ledger_id           
                                                      , accounting_date                  
                                                      , currency_code                   
                                                      , date_created
                                                      , created_by           
                                                      , actual_flag                                    
                                                      , user_je_category_name         
                                                      , user_je_source_name                                    
                                                      , entered_dr                    
                                                      , entered_cr
                                                      , transaction_date                   
                                                      , reference1
                            --                        , reference2
                                                      , reference4                    
                            --                        , reference5
                            --                        , reference6
                                                      , reference7                    
                                                      , reference10
                                                      , reference21
                                                      , reference22
                                                      , reference23
                                                      , reference24
                                                      , period_name
                                                      , je_line_num
                                                      , chart_of_accounts_id                   
                            --                        , functional_currency_code  /* AS per Jeff's discussion on 13022013*/
                                                      --, code_combination_id
													  , segment1
													  , segment2
													  , segment3
													  , segment4
													  , segment5
													  , segment6
													  , segment7
													  , segment8
                                                      , group_id
                                                     )
                                               VALUES( 'NEW'                                                                                                                                                                  --     status
                                                      , l_rec(i).ledger_id                                                                                                                                                    --     ledger_id           
                                                      , UPPER(l_rec(i).transaction_date)                                                                                                                                      --     accounting_date          
                                                      , l_rec(i).currency_code2                                                                                                                                               --     currency_code            
                                                      , l_rec(i).creation_date                                                                                                                                                --     date_created
                                                      , l_rec(i).created_by                                                                                                                                                   --     created_by           
                                                      , g_actual_flag                                                                                                                                                         --     actual_flag                
                                                      , g_user_je_category_name                                                                                                                                               --     user_je_category_name    
                                                      , g_user_je_source_name                                                                                                                                                 --     user_je_source_name        
                                                      , DECODE(SIGN(l_rec(i).base_amount), 1,ROUND(ABS(l_rec(i).base_amount),2),NULL)                                                                                         --     entered_dr               
                                                      , DECODE(SIGN(l_rec(i).base_amount), -1,ROUND(ABS(l_rec(i).base_amount),2),NULL)                                                                                        --     entered_cr
                                                      , l_rec(i).transaction_date                                                                                                                                             --     transaction_date         
                                                      , 'Lawson Period'||' '||LPAD(l_rec(i).acct_period,2,'0')||' '||'TRANSACTION'||' '||l_rec(i).fiscal_year||' '||l_rec(i).currency_code2                                   --     reference1
                            --                        , l_rec(i).reference2                                                                                                                                                   --     reference2
                                                      , 'Lawson Period'||' '||LPAD(l_rec(i).acct_period,2,'0')||' '||'TRANSACTION'||' '||l_rec(i).fiscal_year||' '||l_rec(i).currency_code2 --||' '|| l_rec(i).currency_code  --     reference4                           
                            --                        , l_rec(i).description                                                                                                                                                  --     reference5
                            --                        , l_reference6                                                                                                                                                          --     reference6
                                                      , 'N'                                                                                                                                                                   --     reference7              
                                                      , l_rec(i).description                                                                                                                                                  --     reference10
                                                      , l_rec(i).je_name                                                                                                                                                      --     reference21              
                                                      , l_rec(i).reference21                                                                                                                                                  --     reference22
                                                      , l_reference6                                                                                                                                                          --     reference23
                                                      , l_rec(i).lawson                                                                                                                                                       --     reference24
                                                      , UPPER(l_rec(i).period_name)                                                                                                                                           --     period_name
                                                      , l_rec(i).line_nbr                                                                                                                                                     --     je_line_num
                                                      , l_rec(i).chart_of_accounts_id                                                                                                                                         --     chart_of_accounts_id     
                            --                        , l_rec(i).currency_code2                                                                                                                                               --     functional_currency_code
                            --                        , l_rec(i).code_combination_id                                                                                                                                          --     code_combination_id
													  , l_rec(i).segment1
													  , l_rec(i).segment2
													  , l_rec(i).segment3
													  , l_rec(i).segment4
													  , l_rec(i).segment5
													  , l_rec(i).segment6
													  , l_rec(i).segment7
													  , l_rec(i).segment8
                                                      , l_group_id                                                                                                                                                            --     group_id
                                                     );                                   
                           
                            UPDATE xxnbty_gl_interface_stg_tb
                            SET status             = 'PROCESSED'
                               , last_update_date  = SYSDATE
                               , last_updated_by   = fnd_global.user_id
                            WHERE record_id        = l_rec(i).record_id
                              AND status           = 'VALIDATED';
                               
                        EXCEPTION
                          WHEN OTHERS
                          THEN
                               UPDATE xxnbty_gl_interface_stg_tb
                               SET status             = 'NOT PROCESSED'
                                  , error_message     = 'Error while inserting into GL INTERFACE table.'
                                  , last_update_date  = SYSDATE
                                  , last_updated_by   = fnd_global.user_id
                               WHERE record_id        = l_rec(i).record_id
                                 AND status           = 'VALIDATED';
                               
                        END;                               

                    END LOOP;
                    
                  END IF;
                  
                EXIT WHEN c_valid_insert%NOTFOUND;
        
                END LOOP;
                COMMIT;    
     
                CLOSE c_valid_insert;
                
     
            EXCEPTION
              WHEN OTHERS
              THEN
                      fnd_file.put_line (fnd_file.LOG,
                                         'Other exception in INSERT_INTERFACE :'
                                         || SQLERRM
                                         || '.At Location:'
                                         || DBMS_UTILITY.format_error_backtrace
                                        );    
            END INSERT_INTERFACE;

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
   PROCEDURE FILE_STATUS
   IS
       
        CURSOR c_processed_file
            IS 
             SELECT FILENAME,DECODE(STATUS,'PROCESSED','Processed','Not Processed') STATUS
             FROM xxnbty_gl_interface_stg_tb
             WHERE request_id = fnd_global.conc_request_id 
             GROUP BY filename,DECODE(status,'PROCESSED','Processed','Not Processed');
        
    BEGIN
        fnd_file.put_line( fnd_file.output,'File Process Status Report:');
        fnd_file.put_line( fnd_file.output,RPAD('File Name',30,' ')||'     '||'File Status');
        fnd_file.put_line( fnd_file.output,RPAD('---------',30,' ')||'     '||'-----------');
        FOR rec_processed_file IN c_processed_file
        LOOP
            fnd_file.put_line( fnd_file.output,RPAD(rec_processed_file.filename,30,' ')||'     '||rec_processed_file.status);
        END LOOP;
    EXCEPTION
       WHEN OTHERS
       THEN
          fnd_file.put_line (fnd_file.log,
                             'Other exception in FILE_STATUS :'
                             || SQLERRM
                             || '.At Location:'
                             || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                            );        
    END FILE_STATUS;           
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
   PROCEDURE ERROR_LOG
   IS
   
    -- Table type definition for the record variable to store the data retrieved.
       TYPE tab_rec IS TABLE OF xxnbty_gl_interface_stg_tb%ROWTYPE INDEX BY BINARY_INTEGER;
    ----------------------------------------------------------------
    -- Cursor to log errors records in GL_INTERFACE table
    ----------------------------------------------------------------
        CURSOR c_error_log 
            IS
             SELECT *
             FROM xxnbty_gl_interface_stg_tb
             WHERE status     = 'REJECTED'
               AND request_id = fnd_global.conc_request_id ; 
        
             l_rec      tab_rec;        
    
           BEGIN   
            -----------------------------------------------
            -- Cursor loop for error records
            -----------------------------------------------
                fnd_file.put_line( fnd_file.output,RPAD('File Name',25,' ')
                                   ||'     '
                                   ||RPAD('Je Name',25,' ')
                                   ||'   '
                                   ||RPAD('Line Number',15,' ')
                                   ||'     '
                                   ||'Error Message');
                fnd_file.put_line( fnd_file.output,RPAD('---------',25,' ')
                                   ||'     '
                                   ||RPAD('------------',50,' ')
                                   ||'   '
                                   ||RPAD('-----------',15,' ')
                                   ||'     '
                                   ||'-------------');
                            
                OPEN c_error_log;
                LOOP
                             
                    FETCH c_error_log BULK COLLECT 
                     INTO l_rec LIMIT 1000;
                     IF l_rec.count!=0
                     THEN
                        FOR i IN l_rec.FIRST..l_rec.LAST
                        LOOP
                            fnd_file.put_line( fnd_file.output,RPAD(l_rec(i).filename,25,' ')
                                               ||'     '
                                               ||RPAD(l_rec(i).je_name,50,' ')
                                               ||'   '
                                               ||RPAD(l_rec(i).line_nbr,15,' ')
                                               ||'     '
                                               ||l_rec(i).error_message);       
                        END LOOP;
                     END IF;
                    EXIT WHEN c_error_log%NOTFOUND;
                
                END LOOP;
            
           EXCEPTION
             WHEN OTHERS
             THEN
                fnd_file.put_line (fnd_file.log,
                                   'Other exception in ERROR_LOG :'
                                   || SQLERRM
                                   || '.At Location:'
                                   || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                                  );        
           END ERROR_LOG;
   
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
    PROCEDURE STANDARD_IMPORT
    IS
        l_int_id        NUMBER;
        l_source_name   VARCHAR2(200);
    
        CURSOR c_std_import
            IS
              SELECT ledger_id
                    , user_je_source_name
                    , group_id
              FROM gl_interface
              WHERE status = 'NEW'
                AND user_je_source_name = g_user_je_source_name
                AND user_je_category_name = g_user_je_category_name               
              GROUP BY ledger_id
                      , user_je_source_name
                      , group_id;
                
              BEGIN
                    FOR rec_std_import IN c_std_import
                    LOOP
                        l_int_id:=  gl_interface_control_pkg.get_unique_run_id;
            
                        SELECT je_source_name
                        INTO l_source_name
                        FROM gl_je_sources
                        WHERE user_je_source_name = rec_std_import.user_je_source_name;
                        
                        gl_interface_control_pkg.insert_row( l_int_id
                                                            ,l_source_name
                                                            ,rec_std_import.ledger_id
                                                            ,rec_std_import.group_id
                                                            ,NULL
                                                            );
                    
                        COMMIT;
                        
                        g_request_id := fnd_request.submit_request( 'SQLGL'
                                                                   ,'GLLEZL'
                                                                   ,'Journal Import'
                                                                   ,SYSDATE
                                                                   ,FALSE
                                                                   ,l_int_id
                                                                   ,fnd_profile.value('GL_access_set_id')
                                                                   ,'N'
                                                                   ,''
                                                                   ,''
                                                                   ,'N'
                                                                   ,'N'
                                                                   ,'Y'
                                                                   ,CHR(0)
                                                                    ,'', '', '', '', '', '', '', '', '', ''
                                                                    ,'', '', '', '', '', '', '', '', '', ''
                                                                    ,'', '', '', '', '', '', '', '', '', ''
                                                                    ,'', '', '', '', '', '', '', '', '', ''
                                                                    ,'', '', '', '', '', '', '', '', '', ''
                                                                    ,'', '', '', '', '', '', '', '', '', ''
                                                                    ,'', '', '', '', '', '', '', '', '', ''
                                                                    ,'', '', '', '', '', '', '', '', '', ''
                                                                    ,'', '', '', '', '', '', '', '', '', ''
                                                                    ,'');
                        
                        COMMIT;
                        
                        fnd_file.put_line (fnd_file.LOG,'l_int_id: ' || l_int_id);
                        fnd_file.put_line (fnd_file.LOG,'g_request_id: ' || g_request_id);
                        
                        IF  g_request_id = 0
                        THEN
                            fnd_file.put_line (fnd_file.LOG,'Standard Journal Import Failed'); 
                        END IF;                    
                    END LOOP;                        
                    COMMIT;
              EXCEPTION
                WHEN OTHERS
                THEN
                    fnd_file.put_line (fnd_file.log,
                                       'Other exception in STANDARD_IMPORT :'
                                        || SQLERRM
                                       || '.At Location:'
                                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                                      );        
           END STANDARD_IMPORT;   
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
    PROCEDURE STANDARD_PURGE
    IS  
        l_source_name   VARCHAR2(200);
        l_request_id    NUMBER;
        
         CURSOR c_std_purge
            IS
             SELECT ledger_id
                   , user_je_source_name
                   , group_id
             FROM gl_interface
             WHERE status IS NOT NULL
               AND request_id = g_request_id
             GROUP BY ledger_id
                     , user_je_source_name
                     , group_id;
                   
              BEGIN
                    FOR rec_std_purge IN c_std_purge
                    LOOP
                        SELECT je_source_name
                        INTO l_source_name
                        FROM gl_je_sources
                        WHERE user_je_source_name = rec_std_purge.user_je_source_name;
                        
                        l_request_id := fnd_request.submit_request( 'SQLGL'
                                                                   ,'GLLDEL'
                                                                   ,'Program - Delete Journal Import Data'
                                                                   ,SYSDATE
                                                                   ,FALSE
                                                                   ,l_source_name
                                                                   ,g_request_id
                                                                   ,rec_std_purge.ledger_id
                                                                   ,rec_std_purge.group_id
                                                                   ,fnd_profile.VALUE('GL_access_set_id')
                                                                   );
                                                                   
                    COMMIT;
                        
                        fnd_file.put_line (fnd_file.LOG,'l_request_id: ' || l_request_id);
                        
                        IF  l_request_id = 0
                        THEN
                            fnd_file.put_line (fnd_file.LOG,'Standard Purge Program Failed'); 
                        END IF;                    
                    END LOOP;                        
                    COMMIT;
              EXCEPTION
                WHEN OTHERS
                THEN
                    fnd_file.put_line (fnd_file.log,
                                       'Other exception in STANDARD_PURGE :'
                                        || SQLERRM
                                       || '.At Location:'
                                       || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
                                      );        
           END STANDARD_PURGE; 
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
    PROCEDURE MAIN ( o_errbuf OUT VARCHAR2
                    ,o_retcode OUT NUMBER)
    IS
   
        l_successful        NUMBER := 0;
        l_errors            NUMBER := 0;
        l_successful_stg    NUMBER := 0;
        l_errors_stg        NUMBER := 0;
        l_total_records     NUMBER := 0;
        l_count             NUMBER := 0;
        l_insert_count      NUMBER := 0;
        l_error_log_count   NUMBER := 0;
        l_valid_records     NUMBER := 0;
        l_import_error      NUMBER := 0;
        l_phase             VARCHAR2(200);
        l_status            VARCHAR2(200);
        l_dev_phase         VARCHAR2(200);
        l_dev_status        VARCHAR2(200);
        l_message           VARCHAR2(2000);
        l_req_status        BOOLEAN;
        
         CURSOR c_stg_count
            IS
            SELECT DECODE(status ,'VALIDATED','VALIDATED','REJECTED') status
                  , COUNT (1) cnt
            FROM xxnbty_gl_interface_stg_tb
            WHERE request_id = fnd_global.conc_request_id
            GROUP BY DECODE(status ,'VALIDATED','VALIDATED','REJECTED');
          
         CURSOR c_int_count
            IS
            SELECT DECODE(status ,'PROCESSED','PROCESSED','NOT PROCESSED') status
                  , COUNT (1) cnt
            FROM xxnbty_gl_interface_stg_tb
            WHERE request_id = fnd_global.conc_request_id
            GROUP BY DECODE(status ,'PROCESSED','PROCESSED','NOT PROCESSED');

        
        BEGIN  
            
            UPDATE xxnbty_gl_interface_stg_tb
            SET request_id = fnd_global.conc_request_id
               , created_by = fnd_global.user_id
               , status     = 'NEW'
            WHERE request_id IS NULL;
            
            SELECT COUNT (1)
            INTO l_total_records
            FROM xxnbty_gl_interface_stg_tb 
            WHERE status = 'NEW'
              AND request_id = fnd_global.conc_request_id;
         
            CHECK_JOURNAL;
            
            /*SELECT COUNT (1)
              into l_valid_records
              FROM xxnbty_gl_interface_stg_tb
             WHERE status = 'NEW'
               AND request_id = fnd_global.conc_request_id; 
            
            IF l_valid_records > 0
            THEN
               VALIDATE_JOURNALS;
            END IF;*/   
            
            VALIDATE_JOURNALS;

            FOR I IN c_stg_count 
            LOOP
                IF I.status = 'VALIDATED'
                then
                  l_successful_stg := I.cnt;
                else
                  l_errors_stg := I.cnt;
                END IF;
            END LOOP;
            
            /*SELECT COUNT (1)
              INTO l_successful_stg
              FROM xxnbty_gl_interface_stg_tb
             WHERE status = 'VALIDATED'
               AND request_id = fnd_global.conc_request_id; 
          
            SELECT COUNT (1)
              INTO l_errors_stg
              FROM xxnbty_gl_interface_stg_tb
             WHERE status = 'REJECTED'
               AND request_id = fnd_global.conc_request_id;*/
         
            /*SELECT count(1)
              INTO l_insert_count
              FROM xxnbty_gl_interface_stg_tb a
             WHERE a.status = 'VALIDATED'
               AND NOT EXISTS (SELECT 1 
                                 FROM xxnbty_gl_interface_stg_tb b 
                                WHERE a.filename = b.filename 
                                  AND b.status = 'REJECTED');
            IF l_insert_count > 0 
            THEN
            INSERT_INTERFACE;        
            END IF;*/
            
            INSERT_INTERFACE;
            
            FOR I IN c_int_count 
            LOOP
                IF I.status = 'PROCESSED'
                THEN
                  l_successful := I.cnt;
                ELSE
                  l_errors := I.cnt;
                END IF;
            END LOOP;

            /*SELECT COUNT (1)
              INTO l_successful
              FROM xxnbty_gl_interface_stg_tb
             WHERE status = 'PROCESSED'
               AND request_id = fnd_global.conc_request_id;
         
            SELECT COUNT (1)
              INTO l_errors
              FROM xxnbty_gl_interface_stg_tb
             WHERE status = 'NOT PROCESSED'
               AND request_id = fnd_global.conc_request_id;*/
           
            fnd_file.put_line (fnd_file.OUTPUT,
                               '*** SUMMARY - GL JOURNAL LINES CONVERSION *** '
                              );
            fnd_file.put_line (fnd_file.OUTPUT,
                               '------------------------------------------------------------------------------------'
                              );
          
            fnd_file.put_line (fnd_file.OUTPUT,
                               'Total Number of Records in staging table : '
                               || l_total_records
                              );
            fnd_file.put_line(fnd_file.OUTPUT,
                              'Number of Records Successfully Validated In Staging Table : '
                               || l_successful_stg
                             );
            fnd_file.put_line(fnd_file.OUTPUT,
                              'Number of Records Failed Validation In Staging Table : ' 
                               || l_errors_stg
                             );
            fnd_file.put_line(fnd_file.OUTPUT,
                              'Number of Records Successfully Inserted In Interface Table: '
                              || l_successful
                             );
            fnd_file.put_line(fnd_file.OUTPUT,
                              'Number of Records Failed Insertion In Interface Table : ' 
                              || l_errors
                             );    
            fnd_file.put_line(fnd_file.OUTPUT,
                               '                                                                                    '
                             );
            FILE_STATUS;
         
            SELECT count(1)
            INTO l_error_log_count
            FROM xxnbty_gl_interface_stg_tb 
            WHERE status = 'REJECTED';
            
            
            IF l_error_log_count > 0
            THEN
               fnd_file.put_line(fnd_file.output,'                                                                                     ');
               fnd_file.put_line(fnd_file.output,'*** SUMMARY - GL JOURNAL LINES CONVERSION CUSTOM VALIDATION ERRORS *** ');
               fnd_file.put_line(fnd_file.output,'------------------------------------------------------------------------------------');
               
               ERROR_LOG;
            END IF; 

            -- Calling the standard import program to validate the data and craete journals in base tables
            IF l_successful > 0
            THEN            
               STANDARD_IMPORT;
            END IF;
            
            -- Purging the custom staging table
            /*BEGIN
                DELETE FROM xxnbty_gl_interface_stg_tb;
                COMMIT;
            EXCEPTION
              WHEN OTHERS
              THEN
                fnd_file.put_line (fnd_file.LOG,
                                   'Other exception in purging staging table :'
                                   || SQLERRM
                                   || '.At Location:'
                                   || DBMS_UTILITY.format_error_backtrace
                                  );
            END;
            */
            -- Wait for the Standard Import to complete.
            l_req_status:=fnd_concurrent.wait_for_request( request_id => g_request_id
                                                          ,interval => 10
                                                          ,phase => l_phase 
                                                          ,status => l_status 
                                                          ,dev_phase => l_dev_phase 
                                                          ,dev_status => l_dev_status 
                                                          ,message => l_message);
            
            SELECT count(1)
            INTO l_import_error
            FROM gl_interface 
            WHERE user_je_source_name = g_user_je_source_name
              AND user_je_category_name = g_user_je_category_name;
               
            -- Calling the standard program to purge the interface table
           /* IF l_import_error > 0
            THEN
               STANDARD_PURGE;
            END IF;   
             */            
        EXCEPTION
          WHEN OTHERS
          THEN
            fnd_file.put_line (fnd_file.LOG,
                               'Other exception in MAIN :'
                               || SQLERRM
                               || '.At Location:'
                               || DBMS_UTILITY.format_error_backtrace
                              );
            o_retcode := 2;
       
       END MAIN;

END XXNBTY_GL_CON_001_GLJRNL_PKG;
/
SHOW ERRORS;
EXIT;