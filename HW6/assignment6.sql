-- DB Assignment 6
-- Sarah Groark
-- December 4, 2024 


use indexing;

SHOW SESSION VARIABLES LIKE '%timeout%';       
SET GLOBAL mysqlx_connect_timeout = 600;
SET GLOBAL mysqlx_read_timeout = 600;


DELIMITER $$
CREATE PROCEDURE generate_accounts()
BEGIN
	DECLARE i INT DEFAULT 1; 
    DECLARE branch_name VARCHAR(50);
    DECLARE account_type VARCHAR(50);
    
    -- loop to generate 50,000 records 
    WHILE i <= 150000 DO
		-- randomy select branch name 
		SET branch_name = ELT(FLOOR(1 + (RAND() * 6)), 'Brighton', 'Downtown', 'Mianus', 'Perryridge', 'Redwood', 'RoundHill');
    
		-- Randomly select an account type
		SET account_type = ELT(FLOOR(1 + (RAND() * 2)), 'Savings', 'Checking');
        
        INSERT INTO accounts(account_num, branch_name, balance, account_type)
        VALUES (
			LPAD(i,5,'0'),
            branch_name, 
            ROUND((RAND()*100000),2),
            account_type
		);
        
        SET i = i + 1;
	END WHILE;
END $$ 

DELIMITER ;

-- Execute these lines for each of the 6 experiments 
DELETE FROM accounts;
select count(*) from accounts;

CALL generate_accounts();

-- CREATE INDEXES 
CREATE INDEX idx_branch_name ON accounts (branch_name);
CREATE INDEX idx_branch_account_type ON accounts (branch_name, account_type);

CREATE INDEX idx_balance_account_type on accounts(balance, account_type);
CREATE INDEX idx_balance_branch_name on accounts(balance, branch_name);
CREATE INDEX idx_balance_branch_account_type on accounts(balance, branch_name, account_type);

DROP INDEX idx_branch_name ON accounts; 
DROP INDEX idx_branch_account_type ON accounts; 
DROP INDEX idx_balance_account_type ON accounts; 
DROP INDEX idx_balance_branch_name ON accounts; 
DROP INDEX idx_balance_branch_account_type on accounts;



-- stored procedure for execution 

DELIMITER $$

CREATE PROCEDURE avg_execution_time(IN query_str text)
BEGIN
	DECLARE start_time, end_time DATETIME(6);
    DECLARE total_time BIGINT DEFAULT 0;
    DECLARE avg_time DOUBLE;
    DECLARE i INT DEFAULT 1;
    DECLARE stmt TEXT;
    
    

    SET @stmt = query_str;
    
    PREPARE dynamic_stmt FROM @stmt;
    
	SELECT 'Prepared statement successfully: ', stmt;

    
    
    WHILE i <= 10 DO
		SET start_time = NOW(6);
        
        EXECUTE dynamic_stmt;
        
        SET end_time = NOW(6);
        
        SET total_time = total_time + TIMESTAMPDIFF(MICROSECOND, start_time, end_time);
        
        SET i = i + 1;
	END WHILE; 
    
    SET avg_time = total_time/10.0;
    
    DEALLOCATE PREPARE dynamic_stmt;
    
    SELECT avg_time AS average_execution_time_microseconds;
    
END $$ 
DELIMITER ; 

DROP PROCEDURE IF EXISTS avg_execution_time;

-- point query 1
CALL avg_execution_time('SELECT count(*) FROM accounts WHERE account_type = "Savings" AND branch_name = "Downtown"');

-- point query 2
CALL avg_execution_time('SELECT count(*) FROM accounts WHERE branch_name = "Mianus"');

-- point query 3
CALL avg_execution_6time('SELECT count(*) FROM accounts WHERE branch_name = "RoundHill" OR branch_name = "Redwood" AND account_type = "Checking"');



-- range query 1 
CALL avg_execution_time('SELECT count(*) FROM accounts WHERE branch_name = "Downtown" AND balance BETWEEN 250 AND 1000');

-- range query 2
CALL avg_execution_time('select count(*) from accounts WHERE account_type = "Checking" AND balance BETWEEN 500000 AND 1000000');

-- range query 3
CALL avg_exe5cution_time('select count(*) from accounts where account_type = "Savings" AND branch_name = "Perryridge" AND balance between 0 and 60000');



-- all queries
SELECT count(*) FROM accounts WHERE account_type = "Savings" AND branch_name = "Downtown";
SELECT count(*) FROM accounts WHERE branch_name = "Mianus";
SELECT count(*) FROM accounts WHERE branch_name = "RoundHill" OR branch_name = "Redwood" AND account_type = "Checking";
SELECT count(*) FROM accounts WHERE branch_name = "Downtown" AND balance BETWEEN 250 AND 1000;
select count(*) from accounts WHERE account_type = "Checking" AND balance BETWEEN 500000 AND 1000000; 
select count(*) from accounts where account_type = "Savings" AND branch_name = "Perryridge" AND balance between 0 and 60000;