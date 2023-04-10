-------------------------------------------------------------------------
-- Engineer: Eduard-Guillem Merino Mallorqui
-- Create Date: 11:40:19 03/03/2017
-- Module Name: AER_Bus - Testbench 
-- Project Name: Digital System for Neural Network Emulation
-------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY AER_Testbench IS
    GENERIC (
        neuron_adr : INTEGER := 4; -- Up to 32 neuron_adr
        neuron_num : INTEGER := 4); -- Number of neurons +1
END AER_Testbench;
ARCHITECTURE behavior OF AER_Testbench IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT AER_Bus
        GENERIC (
            neuron_adr : IN INTEGER;
            neuron_num : IN INTEGER);
        PORT (
            CLK : IN STD_LOGIC;
            Spikes : IN STD_LOGIC_VECTOR(neuron_num DOWNTO 0);
            EN_Neuron : OUT STD_LOGIC;
            AER : OUT STD_LOGIC_VECTOR(neuron_adr DOWNTO 0));
    END COMPONENT;
    --Inputs
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL Spikes : STD_LOGIC_VECTOR(neuron_num DOWNTO 0) := (OTHERS => '0');
    --Outputs
    SIGNAL EN_Neuron : STD_LOGIC := '0';
    SIGNAL AER : STD_LOGIC_VECTOR(neuron_adr DOWNTO 0) := (OTHERS => '0');
    -- Clock period definitions
    CONSTANT CLK_period : TIME := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut : AER_Bus
    GENERIC MAP(
        neuron_adr => neuron_adr,
        neuron_num => neuron_num)
    PORT MAP(
        CLK => CLK,
        Spikes => Spikes,
        EN_Neuron => EN_Neuron,
        AER => AER
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
        Spikes <= "00000";
        WAIT FOR 10 ns;
        Spikes <= "00001";
        WAIT FOR CLK_period;
        Spikes <= "00000";
        WAIT FOR 20 ns;
        Spikes <= "11011";
        WAIT FOR CLK_period;
        Spikes <= "00000";
        WAIT FOR CLK_period;
        Spikes <= "00110";
        WAIT FOR CLK_period;
        Spikes <= "00000";
        WAIT;
    END PROCESS;

END;