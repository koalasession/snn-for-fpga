-------------------------------------------------------------------------
-- Engineer: Eduard-Guillem Merino Mallorqui
-- Create Date: 11:40:19 03/03/2017
-- Module Name: Top - Testbench
-- Project Name: Digital System for Neural Network Emulation
-------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY TOP_Testbench IS
    GENERIC (
        image_num : INTEGER := 9;
        width : INTEGER := 12;
        neuron_adr : INTEGER := 5; -- Up to 32 neuron_adr
        weights : INTEGER := 10; -- 255 downto -256
        input_neuron_num : INTEGER := 40; -- Number of virtual neurons +1
        training_neuron_num : INTEGER := 6; -- Number of training neurons
        neuron_num : INTEGER := 46); -- Number of neurons +1
END TOP_Testbench;
ARCHITECTURE behavior OF TOP_Testbench IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Top
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            BTN : IN STD_LOGIC;
            SEL : IN STD_LOGIC;
            Image : IN STD_LOGIC_VECTOR(image_num DOWNTO 0);
            Neuron : IN STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0);
            Spikes_out : OUT STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0));
    END COMPONENT;
    --Inputs
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL BTN : STD_LOGIC := '0';
    SIGNAL SEL : STD_LOGIC := '0';
    SIGNAL Image : STD_LOGIC_VECTOR(image_num DOWNTO 0) := (OTHERS => '0');
    SIGNAL Neuron : STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0) := (OTHERS => '0');
    --Outputs
    SIGNAL Spikes_out : STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0) := (OTHERS => '0');
    -- Clock period definitions
    CONSTANT CLK_period : TIME := 10 ns;
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : Top PORT MAP(
        CLK => CLK,
        RST => RST,
        BTN => BTN,
        SEL => SEL,
        Image => Image,
        Neuron => Neuron,
        Spikes_out => Spikes_out
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
        WAIT FOR CLK_period * 5;
        RST <= '0';
        WAIT FOR 200us;
        Image <= (0 => '1', OTHERS => '0'); -- 0
        Neuron <= (0 => '1', OTHERS => '0');
        BTN <= '1';
        WAIT FOR 10us;
        BTN <= '0';
        WAIT FOR 600us;
        Image <= (1 => '1', OTHERS => '0'); -- 1
        Neuron <= (1 => '1', OTHERS => '0');
        BTN <= '1';
        WAIT FOR 10us;
        BTN <= '0';
        WAIT FOR 600us;
        Image <= (2 => '1', OTHERS => '0'); -- 2
        Neuron <= (2 => '1', OTHERS => '0');
        BTN <= '1';
        WAIT FOR 10us;
        BTN <= '0';
        WAIT FOR 600us;
        Image <= (3 => '1', OTHERS => '0'); -- 3
        Neuron <= (3 => '1', OTHERS => '0');
        BTN <= '1';
        WAIT FOR 10us;
        BTN <= '0';
        WAIT FOR 600us;
        Image <= (4 => '1', OTHERS => '0'); -- 4
        Neuron <= (4 => '1', OTHERS => '0');
        BTN <= '1';
        WAIT FOR 10us;
        BTN <= '0';
        WAIT FOR 600us;
        Image <= (5 => '1', OTHERS => '0'); -- 5
        Neuron <= (5 => '1', OTHERS => '0');
        BTN <= '1';
        WAIT FOR 10us;
        BTN <= '0';
        WAIT FOR 600us;
        SEL <= '1';
        Neuron <= (OTHERS => '0');
        Image <= (0 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (1 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (2 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (3 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (4 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (5 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (OTHERS => '0');
        RST <= '1';
        WAIT FOR 20us;
        BTN <= '1';
        WAIT FOR 1000us;
        RST <= '0';
        BTN <= '0';
        Neuron <= (OTHERS => '0');
        Image <= (0 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (1 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (2 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (3 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (4 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (5 => '1', OTHERS => '0');
        WAIT FOR 400us;
        Image <= (OTHERS => '0');
        WAIT;
    END PROCESS;
END;