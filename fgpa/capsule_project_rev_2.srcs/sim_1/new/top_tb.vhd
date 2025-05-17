LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use work.LoggerPkg.all;

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
    SIGNAL LD3              : STD_LOGIC;
    SIGNAL ANODES           : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL SEGMENTS         : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL FSM_STATE_OUT    : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- Clock period
    CONSTANT CLK_PERIOD     : TIME                          := 10 ns;

BEGIN
    -- Instantiate DUT
    DUT: ENTITY WORK.TOP_LEVEL
        GENERIC MAP (
            SIMULATION_MODE => TRUE
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
            LD3             => LD3,
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
        LOG("Starting simulation...", "INFO");
        WAIT FOR 100 NS;

        -------------------------------------------------------------------
        -- Reset
        -------------------------------------------------------------------
        LOG("Resetting system: Expect transition to IDLE: Expect FSM_STATE = 000", "INFO");
        BTN_RESET <= '1';
        WAIT FOR 20 NS;
        BTN_RESET <= '0';
        WAIT FOR 100 NS;

        -- Assert FSM is in IDLE (FSM_STATE = "000")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "000");
        LOG("System reset successful", "INFO");

        -------------------------------------------------------------------
        -- Password Setup (FSM_STATE = "001")
        -------------------------------------------------------------------
        LOG("Entering Password Setup Mode: Expect FSM_STATE = 001", "INFO");
        SW_PASS <= "0000001111"; -- Example password: 15
        BTN_SETUP <= '1';
        WAIT FOR 20 NS;
        BTN_SETUP <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Password Setup (FSM_STATE = "001")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "001");
        LOG("Transition to Password setup mode from Idle successful", "INFO");

        -------------------------------------------------------------------
        -- Password Setup to Idle (FSM_STATE = "000")
        -------------------------------------------------------------------
        LOG("Entering Idle state from Password Setup Mode: Expect FSM_STATE = 000", "INFO");
        BTN_SETUP <= '1';
        WAIT FOR 20 NS;
        BTN_SETUP <= '0';
        WAIT FOR 500 NS;
        SW_PASS <= "0000000000"; -- reset SW input
        
        -- Assert FSM is in Idle (FSM_STATE = "000")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "000");
        LOG("Transition to Idle from Password setup successful", "INFO");


        -------------------------------------------------------------------
        -- Armed (FSM_STATE = "010")
        -------------------------------------------------------------------
        LOG("Arming the system: Expect FSM_STATE = 010", "INFO");
        BTN_ARM <= '1';
        WAIT FOR 20 NS;
        BTN_ARM <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Idle (FSM_STATE = "010")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "010");
        LOG("System arm successful", "INFO");

        -------------------------------------------------------------------
        -- Door open (FSM_STATE = "011")
        -------------------------------------------------------------------
        LOG("Entering door open mode: Expect FSM_STATE = 011", "INFO");
        BTN_DOOR <= '1';
        WAIT FOR 20 NS;
        BTN_DOOR <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Door open (FSM_STATE = "011")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "011");
        LOG("Transition to Door open successful", "INFO");

        -------------------------------------------------------------------
        -- Send correct password, transition to Idle (FSM_STATE = "000")
        -------------------------------------------------------------------
        LOG("Sending correct password: Expect FSM_STATE = 000", "INFO");
        SW_PASS <= "0000001111"; -- Example password: 15
        WAIT FOR 20 NS;
        BTN_SEND <= '1';
        WAIT FOR 20 NS;
        BTN_SEND <= '0';
        WAIT FOR 500 NS;
        SW_PASS <= "0000000000"; -- Reset password
        
        -- Assert FSM is in Idle (FSM_STATE = "000")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "000");
        LOG("Transition to Idle from Door open with correct password successful", "INFO");
        
        -------------------------------------------------------------------
        -- Standart procedure works!
        -------------------------------------------------------------------
        LOG("Standart lock-unlock procedure works as expected!", "INFO");
        LOG("Testing 3 incorrect password attempts", "INFO");
        
        -------------------------------------------------------------------
        -- Armed (FSM_STATE = "010")
        -------------------------------------------------------------------
        LOG("Arming the system: Expect FSM_STATE = 010", "INFO");
        BTN_ARM <= '1';
        WAIT FOR 20 NS;
        BTN_ARM <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Idle (FSM_STATE = "010")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "010");
        LOG("System armed", "INFO");

        -------------------------------------------------------------------
        -- Door open (FSM_STATE = "011")
        -------------------------------------------------------------------
        LOG("Entering door open mode: Expect FSM_STATE = 011", "INFO");
        BTN_DOOR <= '1';
        WAIT FOR 20 NS;
        BTN_DOOR <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Door open (FSM_STATE = "011")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "011");
        LOG("Transition to Door open successful", "INFO");

        -------------------------------------------------------------------
        -- Send incorrect password#1, stay in the same state (FSM_STATE = "011")
        -------------------------------------------------------------------
        LOG("Sending incorrect password#1: Expect FSM_STATE = 011", "INFO");
        SW_PASS <= "0000000001"; -- Example incorrect password: 1
        WAIT FOR 20 NS;
        BTN_SEND <= '1';
        WAIT FOR 20 NS;
        BTN_SEND <= '0';
        WAIT FOR 500 NS;
        SW_PASS <= "0000000000"; -- Reset password
        
        -- Assert FSM is in Door open (FSM_STATE = "011")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "011");
        
        -- Assert LD1 is indicating wrong input count (LD1 = '1')
        CHECK_SIGNAL("LD1", LD1, '1');

        LOG("Incorrect password#1 check", "INFO");
        
        -------------------------------------------------------------------
        -- Send incorrect password#2, stay in the same state (FSM_STATE = "011")
        -------------------------------------------------------------------
        LOG("Sending incorrect password#2: Expect FSM_STATE = 011", "INFO");
        SW_PASS <= "0000000011"; -- Example incorrect password: 3
        WAIT FOR 20 NS;
        BTN_SEND <= '1';
        WAIT FOR 20 NS;
        BTN_SEND <= '0';
        WAIT FOR 500 NS;
        SW_PASS <= "0000000000"; -- Reset password
        
        -- Assert FSM is in Door open (FSM_STATE = "011")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "011");
        
        -- Assert LD1 is indicating wrong input count (LD1 = '1')
        CHECK_SIGNAL("LD1", LD1, '1');
        
        -- Assert LD2 is indicating wrong input count (LD2 = '1')
        CHECK_SIGNAL("LD2", LD2, '1');

        LOG("Incorrect password#2 check", "INFO");              
            
        -------------------------------------------------------------------
        -- Send incorrect password#3, transition to Breach state (FSM_STATE = "100")
        -------------------------------------------------------------------
        LOG("Sending incorrect password#2: Expect FSM_STATE = 100", "INFO");
        SW_PASS <= "0000000111"; -- Example incorrect password: 7
        WAIT FOR 20 NS;
        BTN_SEND <= '1';
        WAIT FOR 20 NS;
        BTN_SEND <= '0';
        WAIT FOR 500 NS;
        SW_PASS <= "0000000000"; -- Reset password
        
        -- Assert FSM is in Breach (FSM_STATE = "100")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "100");
        LOG("Incorrect password#3 check, transition to Breach successful", "INFO"); 
        
        -------------------------------------------------------------------
        -- Resetting system after breach, transition to Idle state (FSM_STATE = "000")
        -------------------------------------------------------------------
        LOG("Resetting: Expect FSM_STATE = 000", "INFO");
        BTN_RESET <= '1';
        WAIT FOR 20 NS;
        BTN_RESET <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Idle (FSM_STATE = "000")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "000");
        LOG("System reset after Breach successful", "INFO");  

        -------------------------------------------------------------------
        -- Incorrect password handling procedure works!
        -------------------------------------------------------------------
        LOG("Incorrect password handling procedure works as expected!", "INFO");
        LOG("Testing 30 second timeout", "INFO");

        -------------------------------------------------------------------
        -- Resetting system, transition to Idle state (FSM_STATE = "000")
        -------------------------------------------------------------------
        LOG("Resetting: Expect FSM_STATE = 000", "INFO");
        BTN_RESET <= '1';
        WAIT FOR 20 NS;
        BTN_RESET <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Idle (FSM_STATE = "000")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "000");
        LOG("System reset successful", "INFO");  

        -------------------------------------------------------------------
        -- Armed (FSM_STATE = "010")
        -------------------------------------------------------------------
        LOG("Arming the system: Expect FSM_STATE = 010", "INFO");
        BTN_ARM <= '1';
        WAIT FOR 20 NS;
        BTN_ARM <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Idle (FSM_STATE = "010")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "010");
        LOG("System armed", "INFO");

        -------------------------------------------------------------------
        -- Door open (FSM_STATE = "011")
        -------------------------------------------------------------------
        LOG("Entering door open mode: Expect FSM_STATE = 011", "INFO");
        BTN_DOOR <= '1';
        WAIT FOR 20 NS;
        BTN_DOOR <= '0';
        WAIT FOR 500 NS;
        
        -- Assert FSM is in Door open (FSM_STATE = "011")
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "011");
        LOG("Transition to Door open successful", "INFO");

        WAIT UNTIL FSM_STATE_OUT = "100"; -- Wait until counter finishes
        CHECK_SIGNAL("FSM_STATE_OUT", FSM_STATE_OUT, "100");
        LOG("30 second timeout successful", "INFO");

        LOG("Simulation finished!", "INFO");
        WAIT;

    END PROCESS;
END BEHAVIORAL;
