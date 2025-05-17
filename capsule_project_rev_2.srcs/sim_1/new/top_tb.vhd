library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top_level is
end entity;

architecture behavioral of tb_top_level is
    -- signals
    signal clk : std_logic := '0';
    signal btn_setup : std_logic := '0';
    signal btn_arm : std_logic := '0';
    signal btn_reset : std_logic := '0';
    signal btn_door : std_logic := '0';
    signal btn_send : std_logic := '0';
    signal sw_pass : std_logic_vector(9 downto 0) := (others => '0');
    signal status_led : std_logic;
    signal ld1 : std_logic;
    signal ld2 : std_logic;
    signal ld3 : std_logic;
    signal anodes : std_logic_vector(3 downto 0);
    signal segments : std_logic_vector(6 downto 0);
    signal fsm_state_out : std_logic_vector(2 downto 0);
    constant clk_period : time := 10 ns;
begin
    dut: entity work.top_level
        generic map (
            simulation_mode => true
        )
        port map (
            clk_in => clk,
            btn_setup => btn_setup,
            btn_arm => btn_arm,
            btn_reset => btn_reset,
            btn_door => btn_door,
            btn_send => btn_send,
            sw_pass => sw_pass,
            status_led => status_led,
            ld1 => ld1,
            ld2 => ld2,
            ld3 => ld3,
            anodes => anodes,
            segments => segments,
            fsm_state_out => fsm_state_out
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    stim_proc : process
    begin
        wait for 100 ns;

        btn_reset <= '1';
        wait for 20 ns;
        btn_reset <= '0';
        wait for 100 ns;
        assert fsm_state_out = "000" report "Initial state check failed" severity failure;

        sw_pass <= "0000001111";
        btn_setup <= '1';
        wait for 20 ns;
        btn_setup <= '0';
        wait for 500 ns;
        assert fsm_state_out = "001" report "Password setup state check failed" severity failure;

        btn_setup <= '1';
        wait for 20 ns;
        btn_setup <= '0';
        wait for 500 ns;
        sw_pass <= "0000000000";
        assert fsm_state_out = "000" report "Back to idle state check failed" severity failure;

        btn_arm <= '1';
        wait for 20 ns;
        btn_arm <= '0';
        wait for 500 ns;
        assert fsm_state_out = "010" report "System arm state check failed" severity failure;

        btn_door <= '1';
        wait for 20 ns;
        btn_door <= '0';
        wait for 500 ns;
        assert fsm_state_out = "011" report "Door open state check failed" severity failure;

        sw_pass <= "0000001111";
        wait for 20 ns;
        btn_send <= '1';
        wait for 20 ns;
        btn_send <= '0';
        wait for 500 ns;
        sw_pass <= "0000000000";
        assert fsm_state_out = "000" report "Back to idle state check failed" severity failure;

        btn_arm <= '1';
        wait for 20 ns;
        btn_arm <= '0';
        wait for 500 ns;
        assert fsm_state_out = "010" report "System arm state check failed" severity failure;

        btn_door <= '1';
        wait for 20 ns;
        btn_door <= '0';
        wait for 500 ns;
        assert fsm_state_out = "011" report "Door open state check failed" severity failure;

        sw_pass <= "0000000001";
        wait for 20 ns;
        btn_send <= '1';
        wait for 20 ns;
        btn_send <= '0';
        wait for 500 ns;
        sw_pass <= "0000000000";
        
        -- assert fsm is in door open (fsm_state = "011")
        assert fsm_state_out = "011" report "Door open state check failed" severity failure;
        assert ld1 = '1' report "Wrong input count check failed" severity failure;
        assert ld2 = '0' report "Wrong input count check failed" severity failure;
        assert ld3 = '0' report "Wrong input count check failed" severity failure;

        sw_pass <= "0000000011";
        wait for 20 ns;
        btn_send <= '1';
        wait for 20 ns;
        btn_send <= '0';
        wait for 500 ns;
        sw_pass <= "0000000000";
        
        assert fsm_state_out = "011" report "Door open state check failed" severity failure;
        assert ld1 = '1' report "Wrong input count check failed" severity failure;
        assert ld2 = '1' report "Wrong input count check failed" severity failure;
        assert ld3 = '0' report "Wrong input count check failed" severity failure;

        sw_pass <= "0000000111";
        wait for 20 ns;
        btn_send <= '1';
        wait for 20 ns;
        btn_send <= '0';
        wait for 500 ns;
        sw_pass <= "0000000000";
        assert fsm_state_out = "100" report "Breach state check failed" severity failure;

        btn_reset <= '1';
        wait for 20 ns;
        btn_reset <= '0';
        wait for 500 ns;
        assert fsm_state_out = "000" report "System reset check failed" severity failure;

        btn_reset <= '1';
        wait for 20 ns;
        btn_reset <= '0';
        wait for 500 ns;
        assert fsm_state_out = "000" report "System reset check failed" severity failure;

        btn_arm <= '1';
        wait for 20 ns;
        btn_arm <= '0';
        wait for 500 ns;
        assert fsm_state_out = "010" report "System arm state check failed" severity failure;

        btn_door <= '1';
        wait for 20 ns;
        btn_door <= '0';
        wait for 500 ns;
        assert fsm_state_out = "011" report "Door open state check failed" severity failure;

        wait;

    end process;
end behavioral;
