LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY COUNTDOWN_TIMER IS
    GENERIC (
        CLOCKS_PER_SECOND   : INTEGER := 100_000_000;
        MAX_SECONDS         : INTEGER := 30;
        SIMULATION_MODE     : BOOLEAN := FALSE
    );
    PORT (
        CLK     : IN  STD_LOGIC;
        START   : IN  STD_LOGIC;
        RESET   : IN  STD_LOGIC;
        DONE    : OUT STD_LOGIC;
        DIGITS  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END COUNTDOWN_TIMER;

ARCHITECTURE BEHAVIORAL OF COUNTDOWN_TIMER IS
    SIGNAL SECOND_COUNTER   : INTEGER                           := 0;
    SIGNAL CURRENT_SEC      : INTEGER RANGE 0 TO MAX_SECONDS    := MAX_SECONDS;
    SIGNAL COUNTING         : BOOLEAN                           := FALSE;
BEGIN
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF RESET = '1' THEN
                CURRENT_SEC     <= MAX_SECONDS;
                SECOND_COUNTER  <= 0;
                COUNTING        <= FALSE;
            ELSIF START = '1' AND NOT COUNTING THEN
                COUNTING        <= TRUE;
                CURRENT_SEC     <= MAX_SECONDS;
                SECOND_COUNTER  <= 0;
            ELSIF COUNTING THEN
                IF ((NOT SIMULATION_MODE) AND SECOND_COUNTER = CLOCKS_PER_SECOND - 1)
                    OR (SIMULATION_MODE AND SECOND_COUNTER = 99) THEN
                    SECOND_COUNTER <= 0;
                    IF CURRENT_SEC > 0 THEN
                        CURRENT_SEC <= CURRENT_SEC - 1;
                    ELSE
                        COUNTING <= FALSE;
                    END IF;
                ELSE
                    SECOND_COUNTER <= SECOND_COUNTER + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    DONE <= '1' WHEN CURRENT_SEC = 0 AND NOT COUNTING ELSE '0';

    -- BCD digit output for display
    PROCESS(CURRENT_SEC)
        VARIABLE TENS, ONES : INTEGER;
    BEGIN
        TENS := CURRENT_SEC / 10;
        ONES := CURRENT_SEC MOD 10;
        DIGITS              <= (others => '0');
        DIGITS(3 downto 0)  <= STD_LOGIC_VECTOR(TO_UNSIGNED(ONES, 4));
        DIGITS(7 downto 4)  <= STD_LOGIC_VECTOR(TO_UNSIGNED(TENS, 4));
        DIGITS(15 downto 8) <= "00000000"; -- Blank leading digits
    END PROCESS;
END BEHAVIORAL;
