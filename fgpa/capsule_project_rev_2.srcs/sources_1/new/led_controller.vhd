----------------------------------------------------------------------------------
-- Created at: 10.05.2025
-- Author: Barış DEMİRCİ <hi@338.rocks>
-- Description: LED status controller: 00=OFF, 01=ON, 10=BLINK@1Hz
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY LED_CONTROLLER IS
    PORT (
        CLK     : IN  STD_LOGIC;
        MODE    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00=OFF, 01=ON, 10=BLINK
        LED_OUT : OUT STD_LOGIC
    );
END LED_CONTROLLER;

ARCHITECTURE BEHAVIORAL OF LED_CONTROLLER IS
    SIGNAL BLINK_COUNTER    : UNSIGNED(26 DOWNTO 0) := (OTHERS => '0'); -- for ~0.5s toggle (2^27 ~ 134M)
    SIGNAL BLINK_STATE      : STD_LOGIC             := '0';
BEGIN
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF MODE = "10" THEN  -- Blink
                BLINK_COUNTER <= BLINK_COUNTER + 1;
                IF BLINK_COUNTER = 49999999 THEN -- 0.5s @ 100MHz
                    BLINK_COUNTER   <= (OTHERS => '0');
                    BLINK_STATE     <= NOT BLINK_STATE;
                END IF;
            ELSE
                BLINK_COUNTER <= (OTHERS => '0');
                BLINK_STATE <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Output logic
    WITH MODE SELECT
        LED_OUT <= '0'          WHEN "00",      -- OFF
                   '1'          WHEN "01",      -- ON
                   BLINK_STATE  WHEN "10",
                   '0'          WHEN OTHERS;    -- default OFF
END BEHAVIORAL;
