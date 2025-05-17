library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_segment_mux is
    port (
        clk : in std_logic;
        digits : in std_logic_vector(15 downto 0);
        fsm_state : in std_logic_vector(2 downto 0);
        enable : in std_logic;
        anodes : out std_logic_vector(3 downto 0);
        segments : out std_logic_vector(6 downto 0)
    );
end seven_segment_mux;

architecture behavioral of seven_segment_mux is
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');
    signal digit_index : unsigned(1 downto 0);
    signal digit_val : std_logic_vector(3 downto 0);

    function encode_7seg(bcd : std_logic_vector(3 downto 0)) return std_logic_vector is
        variable seg : std_logic_vector(6 downto 0);
    begin
        case bcd is
            when "0000" => seg := "1000000";
            when "0001" => seg := "1111001";
            when "0010" => seg := "0100100";
            when "0011" => seg := "0110000";
            when "0100" => seg := "0011001";
            when "0101" => seg := "0010010";
            when "0110" => seg := "0000010";
            when "0111" => seg := "1111000";
            when "1000" => seg := "0000000";
            when "1001" => seg := "0010000";
            when others => seg := "1111111";
        end case;
        
        return seg;
    end function;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
            digit_index <= refresh_counter(19 downto 18);
        end if;
    end process;

    process(digit_index, digits, enable, fsm_state)
    begin
        if enable = '1' then
            if fsm_state = "001" or fsm_state = "011" then
                case digit_index is
                    when "00" =>
                        anodes <= "1110";
                        digit_val <= digits(3 downto 0);
                    when "01" =>
                        anodes <= "1101";
                        digit_val <= digits(7 downto 4);
                    when "10" =>
                        anodes <= "1011";
                        digit_val <= digits(11 downto 8);
                    when others =>
                        anodes <= "0111";
                        digit_val <= digits(15 downto 12);
                end case;
    
                segments <= encode_7seg(digit_val);
            elsif fsm_state = "000" then
                case digit_index is
                    when "00" =>
                        anodes <= "1110";
                        segments <= "0000110";
                    when "01" =>
                        anodes <= "1101";
                        segments <= "1000111";
                    when "10" =>
                        anodes <= "1011";
                        segments <= "0100001";
                    when others =>
                        anodes <= "0111";
                        segments <= "1111001";
                end case;
            elsif fsm_state = "010" then
                case digit_index is
                    when "00" =>
                        anodes <= "1110";
                        segments <= "1101010";
                    when "01" =>
                        anodes <= "1101";
                        segments <= "1001110";
                    when "10" =>
                        anodes <= "1011";
                        segments <= "0001000";
                    when others =>
                        anodes <= "0111";
                        segments <= "1111111";
                end case;
            elsif fsm_state = "100" then
                case digit_index is
                    when "00" =>
                        anodes <= "1110";
                        segments <= "0001001";
                    when "01" =>
                        anodes <= "1101";
                        segments <= "0001001";
                    when "10" =>
                        anodes <= "1011";
                        segments <= "0001001";
                    when others =>
                        anodes <= "0111";
                        segments <= "0001001";
                end case;
            end if;
        else
            anodes <= "1111";
            segments <= "1111111";
        end if;
    end process;
end behavioral;
