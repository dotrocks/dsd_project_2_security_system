----------------------------------------------------------------------------------
-- Created at: 10.05.2025
-- Author: Barış DEMİRCİ <hi@338.rocks>
-- Description: Finite state machine controller for security system
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY FSM_CONTROLLER IS
    GENERIC (
        CLOCKS_PER_SECOND : INTEGER := 100_000_000
    );
    PORT (
        CLK             : IN  STD_LOGIC;
        
        -- INPUT
        RESET           : IN  STD_LOGIC;
        BTN_SETUP       : IN  STD_LOGIC;
        BTN_DOOR        : IN  STD_LOGIC;
        BTN_ARM         : IN  STD_LOGIC;
        BTN_SEND        : IN  STD_LOGIC;
        SW_PASS         : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
        
        SAVED_PASSWORD  : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
        WRONG_COUNT     : OUT INTEGER RANGE 0 TO 3;
        
        STATE           : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        CURRENT_SECONDS : OUT INTEGER RANGE 0 TO 30
    );
END FSM_CONTROLLER;

ARCHITECTURE BEHAVIORAL OF FSM_CONTROLLER IS
    TYPE STATE_TYPE IS (IDLE, SETUP_PASSWORD, ARMED, DOOR_OPEN, BREACH);
    SIGNAL CURRENT_STATE, NEXT_STATE    : STATE_TYPE                    := IDLE;
    
    SIGNAL CURRENT_PASSWORD             : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL CURRENT_WRONG_COUNT          : INTEGER RANGE 0 TO 3          := 0;
    
    SIGNAL COUNTDOWN_COUNTER            : UNSIGNED(31 DOWNTO 0)         := (OTHERS => '0');
    SIGNAL SECOND_TICK                  : STD_LOGIC                     := '0';
    SIGNAL SEC_COUNT                    : INTEGER RANGE 0 TO 30         := 30;
    SIGNAL COUNTDOWN_DONE               : STD_LOGIC                     := '0';
    
    SIGNAL WRONG_COUNT_NEXT             : INTEGER RANGE 0 TO 3          := 0;
    SIGNAL UPDATE_WRONG_COUNT           : STD_LOGIC                     := '0';
    SIGNAL LOAD_PASSWORD                : STD_LOGIC                     := '0';
BEGIN
    -- Countdown logic
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF CURRENT_STATE = DOOR_OPEN THEN
                IF COUNTDOWN_COUNTER < TO_UNSIGNED(CLOCKS_PER_SECOND - 1, 32) THEN
                    COUNTDOWN_COUNTER   <= COUNTDOWN_COUNTER + 1;
                    SECOND_TICK         <= '0';
                ELSE
                    COUNTDOWN_COUNTER   <= (OTHERS => '0');
                    SECOND_TICK         <= '1';
    
                    IF SEC_COUNT > 0 THEN
                        SEC_COUNT <= SEC_COUNT - 1;
                    END IF;
                END IF;
    
                IF SEC_COUNT = 0 THEN
                    COUNTDOWN_DONE <= '1';
                ELSE
                    COUNTDOWN_DONE <= '0';
                END IF;
            ELSE
                COUNTDOWN_COUNTER   <= (OTHERS => '0');
                SEC_COUNT           <= 30;
                COUNTDOWN_DONE      <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- FSM logic
    PROCESS(CLK, RESET)
    BEGIN
        IF RESET = '1' THEN
            CURRENT_STATE       <= IDLE;
            CURRENT_WRONG_COUNT <= 0;
            
            -- Uncomment this if you also want to reset the password 
            -- CURRENT_PASSWORD <= (OTHERS => '0');
        ELSIF RISING_EDGE(CLK) THEN
            CURRENT_STATE <= NEXT_STATE;
    
            -- Update internal data at clock edge
            IF UPDATE_WRONG_COUNT = '1' THEN
                CURRENT_WRONG_COUNT <= WRONG_COUNT_NEXT;
                WRONG_COUNT         <= WRONG_COUNT_NEXT;
            END IF;
    
            IF LOAD_PASSWORD = '1' THEN
                CURRENT_PASSWORD <= SW_PASS;
            END IF;
        END IF;
    END PROCESS;
    
    PROCESS(CURRENT_STATE, BTN_SETUP, BTN_ARM, BTN_DOOR, BTN_SEND, SW_PASS, CURRENT_PASSWORD, COUNTDOWN_DONE, CURRENT_WRONG_COUNT)
    BEGIN
        -- Default assignments
        NEXT_STATE         <= CURRENT_STATE;
        WRONG_COUNT_NEXT   <= CURRENT_WRONG_COUNT;
        LOAD_PASSWORD      <= '0';
        UPDATE_WRONG_COUNT <= '0';
        SAVED_PASSWORD     <= (OTHERS => '0');
    
        CASE CURRENT_STATE IS
            WHEN IDLE =>
                IF BTN_SETUP = '1' THEN
                    NEXT_STATE <= SETUP_PASSWORD;
                ELSIF BTN_ARM = '1' THEN
                    NEXT_STATE <= ARMED;
                END IF;
                STATE               <= "000";
                WRONG_COUNT_NEXT    <= 0;
                UPDATE_WRONG_COUNT  <= '1';
    
            WHEN SETUP_PASSWORD =>
                STATE               <= "001";
                SAVED_PASSWORD      <= SW_PASS;
                LOAD_PASSWORD       <= '1';
                WRONG_COUNT_NEXT    <= 0;
                UPDATE_WRONG_COUNT  <= '1';
                IF BTN_SETUP = '1' THEN
                    NEXT_STATE <= IDLE;
                END IF;
    
            WHEN ARMED =>
                STATE               <= "010";
                WRONG_COUNT_NEXT    <= 0;
                UPDATE_WRONG_COUNT  <= '1';
                IF BTN_DOOR = '1' THEN
                    NEXT_STATE <= DOOR_OPEN;
                END IF;
    
            WHEN DOOR_OPEN =>
                STATE <= "011";
                IF BTN_SEND = '1' THEN
                    IF SW_PASS = CURRENT_PASSWORD THEN
                        NEXT_STATE          <= IDLE;
                        WRONG_COUNT_NEXT    <= 0;
                    ELSE
                        IF CURRENT_WRONG_COUNT < 2 THEN
                            WRONG_COUNT_NEXT    <= CURRENT_WRONG_COUNT + 1;
                            NEXT_STATE          <= DOOR_OPEN;
                        ELSE
                            WRONG_COUNT_NEXT    <= 3;
                            NEXT_STATE          <= BREACH;
                        END IF;
                    END IF;
                    UPDATE_WRONG_COUNT <= '1';
                ELSIF COUNTDOWN_DONE = '1' THEN
                    WRONG_COUNT_NEXT    <= 0;
                    UPDATE_WRONG_COUNT  <= '1';
                    NEXT_STATE          <= BREACH;
                END IF;
    
            WHEN BREACH =>
                STATE               <= "100";
                WRONG_COUNT_NEXT    <= 0;
                UPDATE_WRONG_COUNT  <= '1';
    
            WHEN OTHERS =>
                NEXT_STATE          <= IDLE;
                WRONG_COUNT_NEXT    <= 0;
                UPDATE_WRONG_COUNT  <= '1';
        END CASE;
    END PROCESS;
    
    CURRENT_SECONDS <= SEC_COUNT;
END BEHAVIORAL;