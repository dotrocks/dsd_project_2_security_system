LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY TB_TOP_LEVEL IS
END ENTITY;

ARCHITECTURE BEHAVIORAL OF TB_TOP_LEVEL IS
    -- Signals
    SIGNAL CLK              : STD_LOGIC                     := '0';
    SIGNAL BTN_SETUP        : STD_LOGIC                     := '0';
    SIGNAL BTN_ARM          : STD_LOGIC                     := '0';
    SIGNAL BTN_RESET        : STD_LOGIC                     := '0';
    SIGNAL BTN_DOOR         : STD_LOGIC                     := '0';
    SIGNAL BTN_SEND         : STD_LOGIC                     := '0';
    SIGNAL SW_PASS          : STD_LOGIC_VECTOR(9 DOWNTO 0)  := (OTHERS => '0');

    SIGNAL STATUS_LED       : STD_LOGIC;
    SIGNAL LD1              : STD_LOGIC;
    SIGNAL LD2              : STD_LOGIC;
    SIGNAL ANODES           : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL SEGMENTS         : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL FSM_STATE_OUT    : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- Clock period
    CONSTANT CLK_PERIOD     : TIME                          := 10 ns;

BEGIN
    -- Instantiate DUT
    DUT: ENTITY WORK.TOP_LEVEL
        GENERIC MAP (
            CLOCKS_PER_SECOND   => 100_000_000,
            BLINK_PERIOD_MS     => 100,
            MAX_SECONDS         => 5
        )
        PORT MAP (
            CLK100MHZ       => CLK,
            BTN_SETUP       => BTN_SETUP,
            BTN_ARM         => BTN_ARM,
            BTN_RESET       => BTN_RESET,
            BTN_DOOR        => BTN_DOOR,
            BTN_SEND        => BTN_SEND,
            SW_PASS         => SW_PASS,
            STATUS_LED      => STATUS_LED,
            LD1             => LD1,
            LD2             => LD2,
            ANODES          => ANODES,
            SEGMENTS        => SEGMENTS,
            FSM_STATE_OUT   => FSM_STATE_OUT
        );

    -- Clock generation
    CLK_PROCESS : PROCESS
    BEGIN
        WHILE TRUE LOOP
            CLK <= '0';
            WAIT FOR CLK_PERIOD / 2;
            CLK <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
    END PROCESS;

    -- Stimulus process
    STIM_PROC : PROCESS
    BEGIN
        -- Wait for global reset
        REPORT "Starting simulation..." SEVERITY NOTE;
        WAIT FOR 100 NS;

        -------------------------------------------------------------------
        -- Reset
        -------------------------------------------------------------------
        REPORT "Resetting system: Expect transition to IDLE" SEVERITY NOTE;
        BTN_RESET <= '1';
        WAIT FOR 20 NS;
        BTN_RESET <= '0';
        WAIT FOR 100 NS;

        -- Assert FSM is in IDLE (FSM_STATE = "000")
        ASSERT FSM_STATE_OUT = "000"
            REPORT "FSM did not transition to IDLE after reset!" SEVERITY ERROR;

        -------------------------------------------------------------------
        -- Password Setup (FSM_STATE = "001")
        -------------------------------------------------------------------
        REPORT "Entering Password Setup Mode: Expect FSM_STATE = 001" SEVERITY NOTE;
        SW_PASS <= "0000001111"; -- Example password: 15
        BTN_SETUP <= '1';
        WAIT FOR 20 NS;
        BTN_SETUP <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Password Setup (FSM_STATE = "001")
        ASSERT FSM_STATE_OUT = "001"
            REPORT "FSM did not enter Password Setup state!" SEVERITY ERROR;

        -------------------------------------------------------------------
        -- Password Setup to Idle (FSM_STATE = "000")
        -------------------------------------------------------------------
        REPORT "Entering Idle state from Password Setup Mode: Expect FSM_STATE = 000" SEVERITY NOTE;
        SW_PASS <= "0000000000"; -- reset SW input
        BTN_SETUP <= '1';
        WAIT FOR 20 NS;
        BTN_SETUP <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Idle (FSM_STATE = "000")
        ASSERT FSM_STATE_OUT = "000"
            REPORT "FSM did not enter Idle state!" SEVERITY ERROR;











        REPORT "Simulation finished." SEVERITY NOTE;
        WAIT;

    END PROCESS;
END BEHAVIORAL;
