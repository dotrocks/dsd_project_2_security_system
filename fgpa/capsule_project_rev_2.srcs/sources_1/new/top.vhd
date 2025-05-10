----------------------------------------------------------------------------------
-- Created at: 10.05.2025
-- Author: Barış DEMİRCİ <hi@338.rocks>
-- Description: Top module for security system
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY TOP_LEVEL IS
    PORT (
        -- Internal 100MHz clock
        CLK100MHZ  : IN STD_LOGIC;
        
        -- INPUTS
        BTN_SETUP   : IN  STD_LOGIC; -- btnU
        BTN_ARM     : IN  STD_LOGIC; -- btnD
        BTN_RESET   : IN  STD_LOGIC; -- btnC
        BTN_DOOR    : IN  STD_LOGIC; -- btnR
        BTN_SEND    : IN  STD_LOGIC; -- btnL
        SW_PASS     : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);

        -- LED outputs
        STATUS_LED  : OUT STD_LOGIC;
        LD1         : OUT STD_LOGIC;
        LD2         : OUT STD_LOGIC;

        -- 7 segment display
        ANODES      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SEGMENTS    : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END TOP_LEVEL;

ARCHITECTURE STRUCTURAL OF TOP_LEVEL IS
    -- Internal password signal
    SIGNAL SAVED_PASSWORD           : STD_LOGIC_VECTOR(9 DOWNTO 0);
   
    -- Debounced button signals
    SIGNAL DEBOUNCED_BTN_SETUP      : STD_LOGIC;
    SIGNAL DEBOUNCED_BTN_ARM        : STD_LOGIC;
    SIGNAL DEBOUNCED_BTN_RESET      : STD_LOGIC;
    SIGNAL DEBOUNCED_BTN_DOOR       : STD_LOGIC;
    SIGNAL DEBOUNCED_BTN_SEND       : STD_LOGIC;
    
    -- LED signals
    SIGNAL STATUS_LED_MODE          : STD_LOGIC_VECTOR(1 DOWNTO 0)  := "10";
    SIGNAL LD1_MODE                 : STD_LOGIC_VECTOR(1 DOWNTO 0)  := "00";
    SIGNAL LD2_MODE                 : STD_LOGIC_VECTOR(1 DOWNTO 0)  := "00";

    -- FSM states
    SIGNAL FSM_STATE                : STD_LOGIC_VECTOR(2 DOWNTO 0);
    
    SIGNAL SECONDS_REMAIN           : INTEGER RANGE 0 TO 30;
    SIGNAL DONE                     : STD_LOGIC;
    SIGNAL START_COUNTER            : STD_LOGIC                     := '0';
    SIGNAL COUNTER_DIGITS           : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL WRONG_COUNT              : INTEGER RANGE 0 TO 3          := 0;
    SIGNAL DISPLAY_DIGITS           : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL RESET_COUNTER            : STD_LOGIC;
    SIGNAL INTERNAL_COUNTER_RESET   : STD_LOGIC;
    
    FUNCTION BIN_TO_BCD(BIN_IN : STD_LOGIC_VECTOR(9 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE I          : INTEGER;
        VARIABLE THOUSANDS  : INTEGER;
        VARIABLE HUNDREDS   : INTEGER;
        VARIABLE TENS       : INTEGER;
        VARIABLE ONES       : INTEGER;
        VARIABLE BCD        : STD_LOGIC_VECTOR(15 DOWNTO 0);
    BEGIN
        I           := TO_INTEGER(UNSIGNED(BIN_IN));
        
        THOUSANDS   := (I / 1000) MOD 10;
        HUNDREDS    := (I / 100) MOD 10;
        TENS        := (I / 10) MOD 10;
        ONES        := I MOD 10;
        
        BCD         := STD_LOGIC_VECTOR(TO_UNSIGNED(THOUSANDS, 4))
                     & STD_LOGIC_VECTOR(TO_UNSIGNED(HUNDREDS, 4)) 
                     & STD_LOGIC_VECTOR(TO_UNSIGNED(TENS, 4)) 
                     & STD_LOGIC_VECTOR(TO_UNSIGNED(ONES, 4));
        
        RETURN BCD;
    END FUNCTION;

BEGIN
    -- Debounced buttons
    DEBOUNCED_BTN_SETUP_INSTANCE: ENTITY WORK.BUTTON_DEBOUNCER
        PORT MAP (
            CLK     => CLK100MHZ,
            BTN_IN  => BTN_SETUP,
            BTN_OUT => DEBOUNCED_BTN_SETUP
        );
    DEBOUNCED_BTN_RESET_INSTANCE: ENTITY WORK.BUTTON_DEBOUNCER
        PORT MAP (
            CLK     => CLK100MHZ,
            BTN_IN  => BTN_RESET,
            BTN_OUT => DEBOUNCED_BTN_RESET
        );
    DEBOUNCED_BTN_ARM_INSTANCE: ENTITY WORK.BUTTON_DEBOUNCER
        PORT MAP (
            CLK     => CLK100MHZ,
            BTN_IN  => BTN_ARM,
            BTN_OUT => DEBOUNCED_BTN_ARM
        );
    DEBOUNCED_BTN_DOOR_INSTANCE: ENTITY WORK.BUTTON_DEBOUNCER
        PORT MAP (
            CLK     => CLK100MHZ,
            BTN_IN  => BTN_DOOR,
            BTN_OUT => DEBOUNCED_BTN_DOOR
        );
    DEBOUNCED_BTN_SEND_INSTANCE: ENTITY WORK.BUTTON_DEBOUNCER
        PORT MAP (
            CLK     => CLK100MHZ,
            BTN_IN  => BTN_SEND,
            BTN_OUT => DEBOUNCED_BTN_SEND
        );

    -- FSM controller
    FSM_INST: ENTITY WORK.FSM_CONTROLLER
        PORT MAP (
            CLK             => CLK100MHZ,
            
            RESET           => DEBOUNCED_BTN_RESET,
            BTN_SETUP       => DEBOUNCED_BTN_SETUP,
            BTN_ARM         => DEBOUNCED_BTN_ARM,
            BTN_DOOR        => DEBOUNCED_BTN_DOOR,
            BTN_SEND        => DEBOUNCED_BTN_SEND,
            
            SW_PASS         => SW_PASS,
            SAVED_PASSWORD  => SAVED_PASSWORD,
            
            WRONG_COUNT     => WRONG_COUNT,

            STATE           => FSM_STATE,
            CURRENT_SECONDS => SECONDS_REMAIN
        );

    -- Seven-segment display decoder
    SEVEN_SEG_INST: ENTITY WORK.SEVEN_SEGMENT_MUX
        PORT MAP (
            CLK         => CLK100MHZ,
            DIGITS      => DISPLAY_DIGITS,
            FSM_STATE   => FSM_STATE,
            ENABLE      => '1',
            ANODES      => ANODES,
            SEGMENTS    => SEGMENTS
        );
        
    -- LED controllers
    STATUS_LED_CONTROLLER_INST: ENTITY WORK.LED_CONTROLLER
        PORT MAP (
            CLK     => CLK100MHZ,
            MODE    => STATUS_LED_MODE,
            LED_OUT => STATUS_LED
        );
    LD1_CONTROLLER_INST: ENTITY WORK.LED_CONTROLLER
        PORT MAP (
            CLK     => CLK100MHZ,
            MODE    => LD1_MODE,
            LED_OUT => LD1
        );
    LD2_CONTROLLER_INST: ENTITY WORK.LED_CONTROLLER
        PORT MAP (
            CLK     => CLK100MHZ,
            MODE    => LD2_MODE,
            LED_OUT => LD2
        );

    -- Countdown timer
    COUNTDOWN_INST: ENTITY WORK.COUNTDOWN_TIMER
        PORT MAP (
            CLK     => CLK100MHZ,
            RESET   => INTERNAL_COUNTER_RESET,
            DIGITS  => COUNTER_DIGITS,
            DONE    => DONE,
            START   => START_COUNTER
        );

    -- Control which message will be shown on the 7 segment display and status LED according to FSM state
    PROCESS(FSM_STATE, WRONG_COUNT)
    BEGIN
        CASE FSM_STATE IS
            WHEN "000" => -- İdle state
                RESET_COUNTER   <= '1';
                START_COUNTER   <= '0';
                STATUS_LED_MODE <= "10"; -- 1Hz blink
                LD1_MODE        <= "00"; -- Off
                LD2_MODE        <= "00"; -- Off
            WHEN "001" => -- Setup password state
                RESET_COUNTER   <= '1';
                START_COUNTER   <= '0';
                STATUS_LED_MODE <= "00"; -- Off
                DISPLAY_DIGITS  <= BIN_TO_BCD(SAVED_PASSWORD);
                LD1_MODE        <= "00"; -- Off
                LD2_MODE        <= "00"; -- Off
            WHEN "010" => -- Armed state
                RESET_COUNTER   <= '0';
                START_COUNTER   <= '0';
                STATUS_LED_MODE <= "01"; -- On
                LD1_MODE        <= "00"; -- Off
                LD2_MODE        <= "00"; -- Off
            WHEN "011" => -- Door open state
                START_COUNTER   <= '1';
                DISPLAY_DIGITS  <= COUNTER_DIGITS;
                STATUS_LED_MODE <= "01"; -- On
                
                CASE WRONG_COUNT IS
                    WHEN 0 => 
                        LD1_MODE <= "00"; -- Off
                        LD2_MODE <= "00"; -- Off
                    WHEN 1 => 
                        LD1_MODE <= "01"; -- On
                        LD2_MODE <= "00"; -- Off
                    WHEN 2 => 
                        LD1_MODE <= "01"; -- On
                        LD2_MODE <= "01"; -- On
                    WHEN OTHERS => 
                        LD1_MODE <= "01"; -- On
                        LD2_MODE <= "01"; -- On
                END CASE;

            WHEN "100" => -- Breach state
                RESET_COUNTER   <= '1';
                START_COUNTER   <= '0';
                STATUS_LED_MODE <= "10"; -- 1Hz blink
                LD1_MODE        <= "10"; -- 1Hz blink
                LD2_MODE        <= "10"; -- 1Hz blink
                
            WHEN OTHERS => -- Any other state (extendable)
                RESET_COUNTER   <= '1';
                START_COUNTER   <= '0';
                STATUS_LED_MODE <= "00"; -- Off
                LD1_MODE        <= "00"; -- Off
                LD2_MODE        <= "00"; -- Off
        END CASE;
    END PROCESS;
    
    INTERNAL_COUNTER_RESET <= DEBOUNCED_BTN_RESET OR RESET_COUNTER;
END STRUCTURAL;
