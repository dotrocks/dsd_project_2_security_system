LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL; 
 
ENTITY LED_CONTROLLER IS 
    GENERIC ( 
        CLOCKS_PER_SECOND   : INTEGER := 100_000_000; 
        BLINK_PERIOD_MS     : INTEGER := 500;
        SIMULATION_MODE     : BOOLEAN := FALSE
    ); 
    PORT ( 
        CLK     : IN  STD_LOGIC; 
        MODE    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00=OFF, 01=ON, 10=BLINK 
        LED_OUT : OUT STD_LOGIC 
    ); 
END LED_CONTROLLER; 
 
ARCHITECTURE BEHAVIORAL OF LED_CONTROLLER IS 
    -- Use a constant function to compute blink ticks with simulation support
    FUNCTION compute_blink_ticks (
        clk_per_sec : INTEGER;
        period_ms   : INTEGER;
        sim_mode    : BOOLEAN
    ) RETURN INTEGER IS
    BEGIN
        IF sim_mode THEN
            RETURN 10;  -- small number for quick blink in simulation
        ELSE
            RETURN (clk_per_sec / 1000) * period_ms;
        END IF;
    END FUNCTION;

    CONSTANT BLINK_TOGGLE_TICKS : INTEGER := compute_blink_ticks(CLOCKS_PER_SECOND, BLINK_PERIOD_MS, SIMULATION_MODE);
    
    SIGNAL BLINK_COUNTER : INTEGER RANGE 0 TO BLINK_TOGGLE_TICKS-1 := 0;  
    SIGNAL BLINK_STATE   : STD_LOGIC := '0'; 
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
