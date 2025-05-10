LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL; 
 
ENTITY LED_CONTROLLER IS 
    GENERIC ( 
        CLOCKS_PER_SECOND   : INTEGER := 100_000_000; 
        BLINK_PERIOD_MS     : INTEGER := 500 
    ); 
    PORT ( 
        CLK     : IN  STD_LOGIC; 
        MODE    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00=OFF, 01=ON, 10=BLINK 
        LED_OUT : OUT STD_LOGIC 
    ); 
END LED_CONTROLLER; 
 
ARCHITECTURE BEHAVIORAL OF LED_CONTROLLER IS 
    -- Break down the calculation into smaller steps to avoid overflow
    CONSTANT TICKS_PART_1 : INTEGER := CLOCKS_PER_SECOND / 1000;  -- Calculate frequency in kHz
    CONSTANT TICKS_PART_2 : INTEGER := TICKS_PART_1 * BLINK_PERIOD_MS;  -- Now multiply by period in ms
    CONSTANT BLINK_TOGGLE_TICKS : INTEGER := TICKS_PART_2;  -- Final result in clock cycles
    
    SIGNAL BLINK_COUNTER        : INTEGER RANGE 0 TO BLINK_TOGGLE_TICKS-1 := 0;  
    SIGNAL BLINK_STATE          : STD_LOGIC := '0'; 
BEGIN 
 
    PROCESS(CLK)
    BEGIN 
        IF RISING_EDGE(CLK) THEN 
            IF MODE = "10" THEN  -- BLINK 
                IF BLINK_COUNTER < BLINK_TOGGLE_TICKS - 1 THEN 
                    BLINK_COUNTER <= BLINK_COUNTER + 1; 
                ELSE 
                    BLINK_COUNTER <= 0;  -- Reset counter
                    BLINK_STATE <= NOT BLINK_STATE; 
                END IF; 
            ELSE 
                BLINK_COUNTER <= 0;  -- Reset counter for OFF or ON modes
                BLINK_STATE <= '0'; 
            END IF; 
        END IF; 
    END PROCESS; 
 
    -- OUTPUT LOGIC
    WITH MODE SELECT 
        LED_OUT <= '0'         WHEN "00",   -- OFF 
                   '1'         WHEN "01",   -- ON 
                   BLINK_STATE WHEN "10", 
                   '0'         WHEN OTHERS; -- DEFAULT OFF 
 
END BEHAVIORAL; 
