library ieee;
use ieee.std_logic_1164.all;

entity button_debouncer is
    port (
        clk : in std_logic;
        btn_in : in std_logic;
        btn_out : out std_logic
    );
end button_debouncer;

architecture behavioral of button_debouncer is
    signal button_sync : std_logic := '1';
    signal button_prev : std_logic := '1';
    signal impulse_internal : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            button_prev <= button_sync;
            button_sync <= btn_in;
            impulse_internal <= '0';

            if button_prev = '0' and button_sync = '1' then
                impulse_internal <= '1';
            end if;
        end if;
    end process;

    btn_out <= impulse_internal;
end behavioral;
