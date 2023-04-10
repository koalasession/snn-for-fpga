-------------------------------------------------------------------------
-- Engineer: Eduard-Guillem Merino Mallorqui
-- Create Date: 14:27:19 02/17/2017
-- Module Name: IZH_Neuron - Testbench
-- Project Name: Digital System for Neural Network Emulation
-------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY IZH_Testbench IS
    GENERIC (
        number : INTEGER := 0;
        weight_width : INTEGER := 12;
        neuron_adr : INTEGER := 5;
        weights : INTEGER := 10);
END IZH_Testbench;
ARCHITECTURE behavior OF IZH_Testbench IS
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT IZH_Neuron
        GENERIC (
            number : IN INTEGER;
            weight_width : IN INTEGER;
            neuron_adr : IN INTEGER;
            weights : IN INTEGER);
        PORT (
            CLK : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            EN : IN STD_LOGIC;
            WE : IN STD_LOGIC;
            Addr : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
            Weight : IN STD_LOGIC_VECTOR(weights DOWNTO 0);
            AER_Bus : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
            Spike_out : OUT STD_LOGIC);
    END COMPONENT;
    --Inputs
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL EN : STD_LOGIC := '0';
    SIGNAL WE : STD_LOGIC := '0';
    SIGNAL Addr : STD_LOGIC_VECTOR(neuron_adr DOWNTO 0) := (OTHERS => '0');
    SIGNAL Weight : STD_LOGIC_VECTOR(weights DOWNTO 0) := (OTHERS => '0');
    SIGNAL AER_Bus : STD_LOGIC_VECTOR(neuron_adr DOWNTO 0) := (OTHERS => '0');
    --Outputs
    SIGNAL Spike_out : STD_LOGIC;
    -- Clock period definitions
    CONSTANT CLK_period : TIME := 10 ns;
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : IZH_Neuron
    GENERIC MAP(
        number => number,
        weight_width => weight_width,
        neuron_adr => neuron_adr,
        weights => weights)
    PORT MAP(
        CLK => CLK,
        RST => RST,
        EN => EN,
        WE => WE,
        Addr => Addr,
        Weight => Weight,
        AER_Bus => AER_Bus,
        Spike_out => Spike_out
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
        EN <= '1';
        RST <= '1';
        AER_Bus <= (OTHERS => '1');
        WAIT FOR CLK_period * 5;
        RST <= '0';
        WAIT FOR 50 ns;
        WE <= '1';
        Weight <= STD_LOGIC_VECTOR(to_signed(120, Weight'length));
        Addr <= STD_LOGIC_VECTOR(to_signed(1, Addr'length));
        WAIT FOR 50 ns;
        WE <= '0';
        WAIT FOR 50 ns;
        AER_Bus <= STD_LOGIC_VECTOR(to_signed(1, AER_Bus'length));
        WAIT;
    END PROCESS;
END;