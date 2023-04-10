-------------------------------------------------------------------------
-- Engineer: Eduard-Guillem Merino Mallorqui
-- Create Date: 14:15:20 05/05/2017
-- Module Name: STDP - Testbench 
-- Project Name: Digital System for Neural Network Emulation
-------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY STDP_Testbench IS
    GENERIC (
        neuron_adr : INTEGER := 4;
        weights : INTEGER := 10;
        input_neuron_num : INTEGER := 2;
        training_neuron_num : INTEGER := 0;
        pre_reg : INTEGER := 15;
        post_reg : INTEGER := 5);
END STDP_Testbench;
ARCHITECTURE behavior OF STDP_Testbench IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT STDP
        GENERIC (
            neuron_adr : IN INTEGER;
            weights : IN INTEGER;
            input_neuron_num : IN INTEGER;
            training_neuron_num : IN INTEGER;
            pre_reg : IN INTEGER;
            post_reg : IN INTEGER);
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            EN : IN STD_LOGIC;
            EN_Addr : IN STD_LOGIC;
            Pre_Spikes : IN STD_LOGIC_VECTOR(input_neuron_num - training_neuron_num DOWNTO 0);
            Post_Spike : IN STD_LOGIC;
            WE : OUT STD_LOGIC;
            Addr : OUT STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
            Weight : OUT STD_LOGIC_VECTOR (weights DOWNTO 0));
    END COMPONENT;
    --Inputs
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL EN : STD_LOGIC := '0';
    SIGNAL EN_Addr : STD_LOGIC := '0';
    SIGNAL Pre_Spikes : STD_LOGIC_VECTOR(input_neuron_num - training_neuron_num DOWNTO 0) := (OTHERS => '0');
    SIGNAL Post_Spike : STD_LOGIC := '0';
    --Outputs
    SIGNAL WE : STD_LOGIC := '0';
    SIGNAL Addr : STD_LOGIC_VECTOR(neuron_adr DOWNTO 0) := (OTHERS => '0');
    SIGNAL Weight : STD_LOGIC_VECTOR(weights DOWNTO 0) := (OTHERS => '0');
    -- Clock period definitions
    CONSTANT CLK_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : STDP
    GENERIC MAP(
        neuron_adr => neuron_adr,
        weights => weights,
        input_neuron_num => input_neuron_num,
        training_neuron_num => training_neuron_num,
        pre_reg => pre_reg,
        post_reg => post_reg)
    PORT MAP(
        CLK => CLK,
        RST => RST,
        EN => EN,
        EN_Addr => EN_Addr,
        Pre_Spikes => Pre_Spikes,
        Post_Spike => Post_Spike,
        WE => WE,
        Addr => Addr,
        Weight => Weight
    );

    -- Clock process definitions
    CLK_process : PROCESS
    BEGIN
        CLK <= '0';
        WAIT FOR CLK_period/2;
        CLK <= '1';
        WAIT FOR CLK_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- hold reset state for 100 ns.
        RST <= '1';
        WAIT FOR 10 ns;
        RST <= '0';
        EN <= '1';
        WAIT FOR CLK_period;
        Pre_Spikes <= "101";
        WAIT FOR CLK_period;
        Pre_Spikes <= "000";
        WAIT FOR CLK_period * 9;
        Post_Spike <= '1';
        WAIT FOR CLK_period;
        Post_Spike <= '0';

        WAIT FOR 70 ns;
        EN_Addr <= '1';
        WAIT FOR CLK_period;
        EN_Addr <= '0';
        Pre_Spikes <= "101";
        WAIT FOR CLK_period;
        Pre_Spikes <= "000";
        WAIT FOR CLK_period * 11;
        Post_Spike <= '1';
        WAIT FOR CLK_period;
        Post_Spike <= '0';

        WAIT FOR 70 ns;
        EN_Addr <= '1';
        WAIT FOR CLK_period;
        EN_Addr <= '0';
        Pre_Spikes <= "101";
        WAIT FOR CLK_period;
        Pre_Spikes <= "000";
        WAIT FOR CLK_period * 11;
        Post_Spike <= '1';
        WAIT FOR CLK_period;
        Post_Spike <= '0';

        WAIT;
    END PROCESS;

END;