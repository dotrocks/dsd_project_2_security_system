library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity led_controller is 
    generic ( 
        clocks_per_second : integer := 100_000_000; 
        blink_period_ms : integer := 500;
        simulation_mode : boolean := false
    ); 
    port ( 
        clk : in std_logic; 
        mode : in std_logic_vector(1 downto 0);
        led_out : out std_logic 
    ); 
end led_controller; 

architecture behavioral of led_controller is 
    function compute_blink_ticks (
        clk_per_sec : integer;
        period_ms : integer;
        sim_mode : boolean
    ) return integer is
    begin
        if sim_mode then
            return 10;
        else
            return (clk_per_sec / 1000) * period_ms;
        end if;
    end function;

    constant blink_toggle_ticks : integer := compute_blink_ticks(clocks_per_second, blink_period_ms, simulation_mode);
    signal blink_counter : integer range 0 to blink_toggle_ticks-1 := 0;  
    signal blink_state : std_logic := '0'; 
begin 

    process(clk)
    begin 
        if rising_edge(clk) then 
            if mode = "10" then
                if blink_counter < blink_toggle_ticks - 1 then 
                    blink_counter <= blink_counter + 1; 
                else 
                    blink_counter <= 0;
                    blink_state <= not blink_state; 
                end if; 
            else 
                blink_counter <= 0;
                blink_state <= '0'; 
            end if; 
        end if; 
    end process; 

    with mode select 
        led_out <= '0' when "00", '1' when "01", blink_state when "10", '0' when others;
end behavioral;
