library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity countdown_timer is
    generic (
        clocks_per_second : integer := 100_000_000;
        max_seconds : integer := 30;
        simulation_mode : boolean := false
    );
    port (
        clk : in std_logic;
        start : in std_logic;
        reset : in std_logic;
        done : out std_logic;
        digits : out std_logic_vector(15 downto 0)
    );
end countdown_timer;

architecture behavioral of countdown_timer is
    signal second_counter : integer := 0;
    signal current_sec : integer range 0 to max_seconds := max_seconds;
    signal counting : boolean := false;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_sec <= max_seconds;
                second_counter <= 0;
                counting <= false;
            elsif start = '1' and not counting then
                counting <= true;
                current_sec <= max_seconds;
                second_counter <= 0;
            elsif counting then
                if (simulation_mode and second_counter = 99) or ((not simulation_mode) and second_counter = clocks_per_second - 1) then
                    second_counter <= 0;
                    if current_sec > 0 then
                        current_sec <= current_sec - 1;
                    else
                        counting <= false;
                    end if;
                else
                    second_counter <= second_counter + 1;
                end if;
            end if;
        end if;
    end process;

    done <= '1' when current_sec = 0 and not counting else '0';

    process(current_sec)
        variable tens, ones : integer;
    begin
        tens := current_sec / 10;
        ones := current_sec mod 10;
        digits <= (others => '0');
        digits(3 downto 0) <= std_logic_vector(to_unsigned(ones, 4));
        digits(7 downto 4) <= std_logic_vector(to_unsigned(tens, 4));
        digits(15 downto 8) <= "00000000";
    end process;
end behavioral;
