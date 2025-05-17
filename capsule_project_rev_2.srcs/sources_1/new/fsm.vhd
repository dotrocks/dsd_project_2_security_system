library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm_controller is
    generic (
        clocks_per_second : integer := 100_000_000;
        simulation_mode : boolean := false
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        btn_setup : in std_logic;
        btn_door : in std_logic;
        btn_arm : in std_logic;
        btn_send : in std_logic;
        sw_pass : in std_logic_vector(9 downto 0);
        saved_password : out std_logic_vector(9 downto 0);
        wrong_count : out integer range 0 to 3;
        state : out std_logic_vector(2 downto 0);
        current_seconds : out integer range 0 to 30
    );
end fsm_controller;

architecture behavioral of fsm_controller is
    type state_type is (idle, setup_password, armed, door_open, breach);
    signal current_state, next_state : state_type := idle;
    signal current_password : std_logic_vector(9 downto 0);
    signal current_wrong_count : integer range 0 to 3 := 0;
    signal countdown_counter : unsigned(31 downto 0) := (others => '0');
    signal second_tick : std_logic := '0';
    signal sec_count : integer range 0 to 30 := 30;
    signal countdown_done : std_logic := '0';
    signal wrong_count_next : integer range 0 to 3 := 0;
    signal update_wrong_count : std_logic := '0';
    signal load_password : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if current_state = door_open then
                if ((not simulation_mode) and countdown_counter < to_unsigned(clocks_per_second - 1, 32)) or (simulation_mode and countdown_counter < to_unsigned(99, 32)) then
                    countdown_counter <= countdown_counter + 1;
                    second_tick <= '0';
                else
                    countdown_counter <= (others => '0');
                    second_tick <= '1';
                    if sec_count > 0 then
                        sec_count <= sec_count - 1;
                    end if;
                end if;
    
                if sec_count = 0 then
                    countdown_done <= '1';
                else
                    countdown_done <= '0';
                end if;
            else
                countdown_counter <= (others => '0');
                sec_count <= 30;
                countdown_done <= '0';
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= idle;
            current_wrong_count <= 0;
            current_password <= (others => '0');
        elsif rising_edge(clk) then
            current_state <= next_state;
            if update_wrong_count = '1' then
                current_wrong_count <= wrong_count_next;
                wrong_count <= wrong_count_next;
            end if;
    
            if load_password = '1' then
                if sw_pass > "1111100111" then
                    current_password <= "1111100111";
                else
                    current_password <= sw_pass;
                end if;
            end if;
        end if;
    end process;
    
    process(current_state, btn_setup, btn_arm, btn_door, btn_send, sw_pass, current_password, countdown_done, current_wrong_count)
    begin
        next_state <= current_state;
        wrong_count_next <= current_wrong_count;
        load_password <= '0';
        update_wrong_count <= '0';
        saved_password <= (others => '0');
    
        case current_state is
            when idle =>
                if btn_setup = '1' then
                    next_state <= setup_password;
                elsif btn_arm = '1' then
                    next_state <= armed;
                end if;
                state <= "000";
                wrong_count_next <= 0;
                update_wrong_count <= '1';
    
            when setup_password =>
                state <= "001";
                saved_password <= sw_pass;
                load_password <= '1';
                wrong_count_next <= 0;
                update_wrong_count <= '1';
                if btn_setup = '1' then
                    next_state <= idle;
                end if;
    
            when armed =>
                state <= "010";
                wrong_count_next <= 0;
                update_wrong_count <= '1';
                if btn_door = '1' then
                    next_state <= door_open;
                end if;
    
            when door_open =>
                state <= "011";
                if btn_send = '1' then
                    if sw_pass = current_password then
                        next_state <= idle;
                        wrong_count_next <= 0;
                    else
                        if current_wrong_count < 2 then
                            wrong_count_next <= current_wrong_count + 1;
                            next_state <= door_open;
                        else
                            wrong_count_next <= 3;
                            next_state <= breach;
                        end if;
                    end if;
                    update_wrong_count <= '1';
                elsif countdown_done = '1' then
                    wrong_count_next <= 0;
                    update_wrong_count <= '1';
                    next_state <= breach;
                end if;
    
            when breach =>
                state <= "100";
                wrong_count_next <= 0;
                update_wrong_count <= '1';
    
            when others =>
                next_state <= idle;
                wrong_count_next <= 0;
                update_wrong_count <= '1';
        end case;
    end process;
    
    current_seconds <= sec_count;
end behavioral;
