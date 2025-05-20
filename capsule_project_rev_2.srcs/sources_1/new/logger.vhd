-- barbarbar338
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

PACKAGE LOGGERPKG IS
    PROCEDURE LOG (
        MSG     : IN STRING; 
        LEVEL   : IN STRING := "INFO"
    );
    
    PROCEDURE CHECK_CONDITION (
        CONDITION   : IN BOOLEAN;
        MSG         : IN STRING;
        LEVEL       : IN STRING     := "ERROR";
        ASSERT_FAIL : IN BOOLEAN    := TRUE
    );
    
    PROCEDURE CHECK_SIGNAL (
        SIGNAL_NAME     : IN STRING;
        ACTUAL_VALUE    : IN STD_LOGIC_VECTOR;
        EXPECTED_VALUE  : IN STD_LOGIC_VECTOR;
        LEVEL           : IN STRING             := "ERROR";
        ASSERT_FAIL     : IN BOOLEAN            := TRUE
    );
    
    PROCEDURE CHECK_SIGNAL(
        SIGNAL_NAME     : IN STRING;
        ACTUAL_VALUE    : IN STD_LOGIC;
        EXPECTED_VALUE  : IN STD_LOGIC;
        LEVEL           : IN STRING     := "ERROR";
        ASSERT_FAIL     : IN BOOLEAN    := TRUE
    );
    
    PROCEDURE CHECK_SIGNAL(
        SIGNAL_NAME     : IN STRING;
        ACTUAL_VALUE    : IN BOOLEAN;
        EXPECTED_VALUE  : IN BOOLEAN;
        LEVEL           : IN STRING     := "ERROR";
        ASSERT_FAIL     : IN BOOLEAN    := TRUE
    );
    
    PROCEDURE CHECK_SIGNAL(
        SIGNAL_NAME     : IN STRING;
        ACTUAL_VALUE    : IN INTEGER;
        EXPECTED_VALUE  : IN INTEGER;
        LEVEL           : IN STRING     := "ERROR";
        ASSERT_FAIL     : IN BOOLEAN    := TRUE
    );
END PACKAGE;

PACKAGE BODY LOGGERPKG IS
    PROCEDURE LOG (
        MSG     : IN STRING; 
        LEVEL   : IN STRING := "INFO"
    ) IS
        VARIABLE LINE_BUF   : LINE;
        VARIABLE SIM_TIME   : TIME              := NOW;
        VARIABLE SEV        : SEVERITY_LEVEL    := NOTE;
    BEGIN
        -- Set severity level based on the input
        IF LEVEL = "ERROR" OR LEVEL = "FAIL" THEN
            SEV := FAILURE;
        ELSIF LEVEL = "WARN" THEN
            SEV := WARNING;
        ELSE
            SEV := NOTE;
        END IF;
        
        -- Construct message in line buffer
        WRITE(LINE_BUF, STRING'(">>> ["));
        WRITE(LINE_BUF, LEVEL);
        WRITE(LINE_BUF, STRING'("] @ "));
        WRITE(LINE_BUF, SIM_TIME, RIGHT, 0);
        WRITE(LINE_BUF, STRING'(" : "));
        WRITE(LINE_BUF, MSG);
        
        -- Output to console using report
        REPORT LINE_BUF.ALL SEVERITY SEV;
        
        -- Free the line buffer (to avoid memory leaks)
        DEALLOCATE(LINE_BUF);
    END PROCEDURE;
    
    PROCEDURE CHECK_CONDITION (
        CONDITION   : IN BOOLEAN;
        MSG         : IN STRING;
        LEVEL       : IN STRING     := "ERROR";
        ASSERT_FAIL : IN BOOLEAN    := TRUE
    ) IS
    BEGIN
        IF NOT CONDITION THEN
            LOG(MSG, LEVEL);
    
            IF ASSERT_FAIL THEN
                ASSERT FALSE REPORT MSG SEVERITY ERROR;
                REPORT "Stopping simulation due to error!" SEVERITY FAILURE;
            END IF;
        END IF;
    END PROCEDURE;
    
    PROCEDURE CHECK_SIGNAL(
        SIGNAL_NAME     : IN STRING;
        ACTUAL_VALUE    : IN STD_LOGIC_VECTOR;
        EXPECTED_VALUE  : IN STD_LOGIC_VECTOR;
        LEVEL           : IN STRING             := "ERROR";
        ASSERT_FAIL     : IN BOOLEAN            := TRUE
    ) IS
        VARIABLE MSG_LINE   : LINE;
        VARIABLE MSG        : STRING(1 TO 200);
    BEGIN
        IF ACTUAL_VALUE /= EXPECTED_VALUE THEN
            -- Format the message
            WRITE(MSG_LINE, STRING'("Signal "));
            WRITE(MSG_LINE, SIGNAL_NAME);
            WRITE(MSG_LINE, STRING'(" has value "));
            WRITE(MSG_LINE, ACTUAL_VALUE);
            WRITE(MSG_LINE, STRING'(", expected "));
            WRITE(MSG_LINE, EXPECTED_VALUE);
    
            -- Convert to string and deallocate
            MSG := MSG_LINE.ALL;
            DEALLOCATE(MSG_LINE);
    
            -- Log the message
            LOG(MSG, LEVEL);
    
            -- Optionally halt
            IF ASSERT_FAIL THEN
                ASSERT FALSE REPORT MSG SEVERITY ERROR;
                REPORT "Stopping simulation due to error!" SEVERITY FAILURE;
            END IF;
        END IF;
    END PROCEDURE;
    
    PROCEDURE CHECK_SIGNAL(
        SIGNAL_NAME     : IN STRING;
        ACTUAL_VALUE    : IN STD_LOGIC;
        EXPECTED_VALUE  : IN STD_LOGIC;
        LEVEL           : IN STRING     := "ERROR";
        ASSERT_FAIL     : IN BOOLEAN    := TRUE
    ) IS
        VARIABLE MSG_LINE   : LINE;
        VARIABLE MSG        : STRING(1 TO 200);
    BEGIN
        IF ACTUAL_VALUE /= EXPECTED_VALUE THEN
            WRITE(MSG_LINE, STRING'("Signal "));
            WRITE(MSG_LINE, SIGNAL_NAME);
            WRITE(MSG_LINE, STRING'(" has value '"));
            WRITE(MSG_LINE, ACTUAL_VALUE);
            WRITE(MSG_LINE, STRING'("', expected '"));
            WRITE(MSG_LINE, EXPECTED_VALUE);
            WRITE(MSG_LINE, STRING'("'"));
    
            MSG := MSG_LINE.ALL;
            DEALLOCATE(MSG_LINE);
    
            LOG(MSG, LEVEL);
    
            IF ASSERT_FAIL THEN
                ASSERT FALSE REPORT MSG SEVERITY ERROR;
                REPORT "Stopping simulation due to error!" SEVERITY FAILURE;
            END IF;
        END IF;
    END PROCEDURE;

    PROCEDURE CHECK_SIGNAL(
        SIGNAL_NAME     : IN STRING;
        ACTUAL_VALUE    : IN BOOLEAN;
        EXPECTED_VALUE  : IN BOOLEAN;
        LEVEL           : IN STRING     := "ERROR";
        ASSERT_FAIL     : IN BOOLEAN    := TRUE
    ) IS
        VARIABLE MSG_LINE   : LINE;
        VARIABLE MSG        : STRING(1 TO 200);
    BEGIN
        IF ACTUAL_VALUE /= EXPECTED_VALUE THEN
            WRITE(MSG_LINE, STRING'("Signal "));
            WRITE(MSG_LINE, SIGNAL_NAME);
            WRITE(MSG_LINE, STRING'(" has value "));
            WRITE(MSG_LINE, ACTUAL_VALUE);
            WRITE(MSG_LINE, STRING'(", expected "));
            WRITE(MSG_LINE, EXPECTED_VALUE);
    
            MSG := MSG_LINE.ALL;
            DEALLOCATE(MSG_LINE);
    
            LOG(MSG, LEVEL);
    
            IF ASSERT_FAIL THEN
                ASSERT FALSE REPORT MSG SEVERITY ERROR;
                REPORT "Stopping simulation due to error!" SEVERITY FAILURE;
            END IF;
        END IF;
    END PROCEDURE;

    PROCEDURE CHECK_SIGNAL(
        SIGNAL_NAME     : IN STRING;
        ACTUAL_VALUE    : IN INTEGER;
        EXPECTED_VALUE  : IN INTEGER;
        LEVEL           : IN STRING     := "ERROR";
        ASSERT_FAIL     : IN BOOLEAN    := TRUE
    ) IS
        VARIABLE MSG_LINE   : LINE;
        VARIABLE MSG        : STRING(1 TO 200);
    BEGIN
        IF ACTUAL_VALUE /= EXPECTED_VALUE THEN
            WRITE(MSG_LINE, STRING'("Signal "));
            WRITE(MSG_LINE, SIGNAL_NAME);
            WRITE(MSG_LINE, STRING'(" has value "));
            WRITE(MSG_LINE, ACTUAL_VALUE);
            WRITE(MSG_LINE, STRING'(", expected "));
            WRITE(MSG_LINE, EXPECTED_VALUE);
    
            MSG := MSG_LINE.ALL;
            DEALLOCATE(MSG_LINE);
    
            LOG(MSG, LEVEL);
    
            IF ASSERT_FAIL THEN
                ASSERT FALSE REPORT MSG SEVERITY ERROR;
                REPORT "Stopping simulation due to error!" SEVERITY FAILURE;
            END IF;
        END IF;
    END PROCEDURE;
    
END PACKAGE BODY;
-- barbarbar338
