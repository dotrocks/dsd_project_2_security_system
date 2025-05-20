-- barbarbar338
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SEVEN_SEGMENT_MUX IS
    PORT (
        CLK         : IN  STD_LOGIC;
        DIGITS      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- 4 digits, 4-bit each
        FSM_STATE   : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        ENABLE      : IN  STD_LOGIC;
        ANODES      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SEGMENTS    : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END SEVEN_SEGMENT_MUX;

ARCHITECTURE BEHAVIORAL OF SEVEN_SEGMENT_MUX IS
    SIGNAL REFRESH_COUNTER  : UNSIGNED(19 DOWNTO 0)         := (OTHERS => '0');
    SIGNAL DIGIT_INDEX      : UNSIGNED(1 DOWNTO 0);
    SIGNAL DIGIT_VAL        : STD_LOGIC_VECTOR(3 DOWNTO 0);

    FUNCTION ENCODE_7SEG(BCD : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE SEG : STD_LOGIC_VECTOR(6 DOWNTO 0);
    BEGIN
        CASE BCD IS
            WHEN "0000" => SEG := "1000000"; -- 0
            WHEN "0001" => SEG := "1111001"; -- 1
            WHEN "0010" => SEG := "0100100"; -- 2
            WHEN "0011" => SEG := "0110000"; -- 3
            WHEN "0100" => SEG := "0011001"; -- 4
            WHEN "0101" => SEG := "0010010"; -- 5
            WHEN "0110" => SEG := "0000010"; -- 6
            WHEN "0111" => SEG := "1111000"; -- 7
            WHEN "1000" => SEG := "0000000"; -- 8
            WHEN "1001" => SEG := "0010000"; -- 9
            WHEN OTHERS => SEG := "1111111"; -- BLANK
        END CASE;
        
        RETURN SEG;
    END FUNCTION;
BEGIN
    PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            REFRESH_COUNTER <= REFRESH_COUNTER + 1;
            DIGIT_INDEX     <= REFRESH_COUNTER(19 DOWNTO 18);
        END IF;
    END PROCESS;

    PROCESS(DIGIT_INDEX, DIGITS, ENABLE, FSM_STATE)
    BEGIN
        IF ENABLE = '1' THEN
            IF FSM_STATE = "001" OR FSM_STATE = "011" THEN -- Password setup or door open
                CASE DIGIT_INDEX IS
                    WHEN "00" =>
                        ANODES      <= "1110";
                        DIGIT_VAL   <= DIGITS(3 DOWNTO 0);
                    WHEN "01" =>
                        ANODES      <= "1101";
                        DIGIT_VAL   <= DIGITS(7 DOWNTO 4);
                    WHEN "10" =>
                        ANODES      <= "1011";
                        DIGIT_VAL   <= DIGITS(11 DOWNTO 8);
                    WHEN OTHERS =>
                        ANODES      <= "0111";
                        DIGIT_VAL   <= DIGITS(15 DOWNTO 12);
                END CASE;
    
                SEGMENTS <= ENCODE_7SEG(DIGIT_VAL);
            ELSIF FSM_STATE = "000" THEN -- Idle
                CASE DIGIT_INDEX IS
                    WHEN "00" =>
                        ANODES      <= "1110";
                        SEGMENTS    <= "0000110"; -- E
                    WHEN "01" =>
                        ANODES      <= "1101";
                        SEGMENTS    <= "1000111"; -- L
                    WHEN "10" =>
                        ANODES      <= "1011";
                        SEGMENTS    <= "0100001"; -- D
                    WHEN OTHERS =>
                        ANODES      <= "0111";
                        SEGMENTS    <= "1111001"; -- I
                END CASE;
            ELSIF FSM_STATE = "010" THEN -- Armed
                CASE DIGIT_INDEX IS
                    WHEN "00" =>
                        ANODES      <= "1110";
                        SEGMENTS    <= "1101010"; -- M
                    WHEN "01" =>
                        ANODES      <= "1101";
                        SEGMENTS    <= "1001110"; -- R
                    WHEN "10" =>
                        ANODES      <= "1011";
                        SEGMENTS    <= "0001000"; -- A
                    WHEN OTHERS =>
                        ANODES      <= "0111";
                        SEGMENTS    <= "1111111"; -- OFF
                END CASE;
            ELSIF FSM_STATE = "100" THEN -- Breach
                CASE DIGIT_INDEX IS
                    WHEN "00" =>
                        ANODES      <= "1110";
                        SEGMENTS    <= "0001001"; -- X
                    WHEN "01" =>
                        ANODES      <= "1101";
                        SEGMENTS    <= "0001001"; -- X
                    WHEN "10" =>
                        ANODES      <= "1011";
                        SEGMENTS    <= "0001001"; -- X
                    WHEN OTHERS =>
                        ANODES      <= "0111";
                        SEGMENTS    <= "0001001"; -- X
                END CASE;
            END IF;
        ELSE
            ANODES      <= "1111";
            SEGMENTS    <= "1111111";
        END IF;
    END PROCESS;
END BEHAVIORAL;
-- barbarbar338
