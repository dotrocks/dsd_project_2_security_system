library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    generic (
        clocks_per_second : integer := 100_000_000;
        blink_period_ms : integer := 500;
        max_seconds : integer := 30;
        simulation_mode : boolean := false
    );
    port (
        clk_in : in std_logic;
        btn_setup : in std_logic;
        btn_arm : in std_logic;
        btn_reset : in std_logic;
        btn_door : in std_logic;
        btn_send : in std_logic;
        sw_pass : in std_logic_vector(9 downto 0);
        status_led : out std_logic;
        ld1 : out std_logic;
        ld2 : out std_logic;
        ld3 : out std_logic;
        anodes : out std_logic_vector(3 downto 0);
        segments : out std_logic_vector(6 downto 0);
        fsm_state_out : out std_logic_vector(2 downto 0)
    );
end top_level;

architecture structural of top_level is
    signal saved_password : std_logic_vector(9 downto 0);
    signal debounced_btn_setup : std_logic;
    signal debounced_btn_arm : std_logic;
    signal debounced_btn_reset : std_logic;
    signal debounced_btn_door : std_logic;
    signal debounced_btn_send : std_logic;
    signal status_led_mode : std_logic_vector(1 downto 0) := "10";
    signal ld1_mode : std_logic_vector(1 downto 0) := "00";
    signal ld2_mode : std_logic_vector(1 downto 0) := "00";
    signal ld3_mode : std_logic_vector(1 downto 0) := "00";
    signal fsm_state : std_logic_vector(2 downto 0);
    signal seconds_remain : integer range 0 to 30;
    signal done : std_logic;
    signal start_counter : std_logic := '0';
    signal counter_digits : std_logic_vector(15 downto 0);
    signal wrong_count : integer range 0 to 3 := 0;
    signal display_digits : std_logic_vector(15 downto 0);
    signal reset_counter : std_logic;
    signal internal_counter_reset : std_logic;
    function bin_to_bcd(bin_in : std_logic_vector(9 downto 0)) return std_logic_vector is
        variable i : integer;
        variable thousands : integer;
        variable hundreds : integer;
        variable tens : integer;
        variable ones : integer;
        variable bcd : std_logic_vector(15 downto 0);
    begin
        i := to_integer(unsigned(bin_in));
        thousands := (i / 1000) mod 10;
        hundreds := (i / 100) mod 10;
        tens := (i / 10) mod 10;
        ones := i mod 10;
        bcd := std_logic_vector(to_unsigned(thousands, 4))
        & std_logic_vector(to_unsigned(hundreds, 4)) 
        & std_logic_vector(to_unsigned(tens, 4)) 
        & std_logic_vector(to_unsigned(ones, 4));
        return bcd;
    end function;
begin
    debounced_btn_setup_instance: entity work.button_debouncer
        port map (
            clk => clk_in,
            btn_in => btn_setup,
            btn_out => debounced_btn_setup
        );
    debounced_btn_reset_instance: entity work.button_debouncer
        port map (
            clk => clk_in,
            btn_in => btn_reset,
            btn_out => debounced_btn_reset
        );
    debounced_btn_arm_instance: entity work.button_debouncer
        port map (
            clk => clk_in,
            btn_in => btn_arm,
            btn_out => debounced_btn_arm
        );
    debounced_btn_door_instance: entity work.button_debouncer
        port map (
            clk => clk_in,
            btn_in => btn_door,
            btn_out => debounced_btn_door
        );
    debounced_btn_send_instance: entity work.button_debouncer
        port map (
            clk => clk_in,
            btn_in => btn_send,
            btn_out => debounced_btn_send
        );

    fsm_inst: entity work.fsm_controller
        generic map (
            clocks_per_second => clocks_per_second,
            simulation_mode => simulation_mode
        )
        port map (
            clk => clk_in,
            reset => debounced_btn_reset,
            btn_setup => debounced_btn_setup,
            btn_arm => debounced_btn_arm,
            btn_door => debounced_btn_door,
            btn_send => debounced_btn_send,
            sw_pass => sw_pass,
            saved_password => saved_password,
            wrong_count => wrong_count,
            state => fsm_state,
            current_seconds => seconds_remain
        );

    seven_seg_inst: entity work.seven_segment_mux
        port map (
            clk => clk_in,
            digits => display_digits,
            fsm_state => fsm_state,
            enable => '1',
            anodes => anodes,
            segments => segments
        );

    status_led_controller_inst: entity work.led_controller
        generic map ( 
            clocks_per_second => clocks_per_second,
            blink_period_ms => blink_period_ms,
            simulation_mode => simulation_mode
        )
        port map (
            clk => clk_in,
            mode => status_led_mode,
            led_out => status_led
        );

    ld1_controller_inst: entity work.led_controller
        generic map ( 
            clocks_per_second => clocks_per_second,
            blink_period_ms => blink_period_ms,
            simulation_mode => simulation_mode
        )
        port map (
            clk => clk_in,
            mode => ld1_mode,
            led_out => ld1
        );
    ld2_controller_inst: entity work.led_controller
        generic map ( 
            clocks_per_second => clocks_per_second,
            blink_period_ms => blink_period_ms,
            simulation_mode => simulation_mode
        )
        port map (
            clk => clk_in,
            mode => ld2_mode,
            led_out => ld2
        );
    ld3_controller_inst: entity work.led_controller
        generic map ( 
            clocks_per_second => clocks_per_second,
            blink_period_ms => blink_period_ms,
            simulation_mode => simulation_mode
        )
        port map (
            clk => clk_in,
            mode => ld3_mode,
            led_out => ld3
        );

    countdown_inst: entity work.countdown_timer
        generic map (
            clocks_per_second => clocks_per_second,
            max_seconds => max_seconds,
            simulation_mode => simulation_mode
        )
        port map (
            clk => clk_in,
            reset => internal_counter_reset,
            digits => counter_digits,
            done => done,
            start => start_counter
        );

    process(fsm_state, wrong_count)
    begin
        case fsm_state is
            when "000" =>
                reset_counter <= '1';
                start_counter <= '0';
                status_led_mode <= "10";
                ld1_mode <= "00";
                ld2_mode <= "00";
                ld3_mode <= "00";
            when "001" =>
                reset_counter <= '1';
                start_counter <= '0';
                display_digits <= bin_to_bcd(saved_password);
                status_led_mode <= "00";
                ld1_mode <= "00";
                ld2_mode <= "00";
                ld3_mode <= "00";
            when "010" =>
                reset_counter <= '0';
                start_counter <= '0';
                status_led_mode <= "01";
                ld1_mode <= "00";
                ld2_mode <= "00";
                ld3_mode <= "00";
            when "011" =>
                start_counter <= '1';
                display_digits <= bin_to_bcd(sw_pass);
                status_led_mode <= "01";
            
            case wrong_count is
                when 0 => 
                    ld1_mode <= "00";
                    ld2_mode <= "00";
                    ld3_mode <= "00";
                when 1 => 
                    ld1_mode <= "01";
                    ld2_mode <= "00";
                    ld3_mode <= "00";
                when 2 => 
                    ld1_mode <= "01";
                    ld2_mode <= "01";
                    ld3_mode <= "00";
                when others => 
                    ld1_mode <= "01";
                    ld2_mode <= "01";
                    ld3_mode <= "01";
            end case;

            when "100" =>
                reset_counter <= '1';
                start_counter <= '0';
                status_led_mode <= "01"; 
                ld1_mode <= "10";
                ld2_mode <= "10";
                ld3_mode <= "10";
                
            when others =>
                reset_counter <= '1';
                start_counter <= '0';
                status_led_mode <= "00"; 
                ld1_mode <= "00";
                ld2_mode <= "00";
                ld3_mode <= "00";
        end case;
    end process;
    
    internal_counter_reset <= debounced_btn_reset or reset_counter;
    fsm_state_out <= fsm_state;
end structural;
