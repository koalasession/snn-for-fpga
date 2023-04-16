LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IZH_Testbench IS
    GENERIC (
        number : INTEGER := 0;
        weight_width : INTEGER := 16;
        neuron_adr : INTEGER := 7;
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
            DT : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            EN : IN STD_LOGIC;
            NB : IN STD_LOGIC;
            WE : IN STD_LOGIC;
            Addr : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
            Weight : IN STD_LOGIC_VECTOR(weights DOWNTO 0);
            AER_Bus : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
            Spike_out : OUT STD_LOGIC);
    END COMPONENT;
    --Inputs
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL DT : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    SIGNAL EN : STD_LOGIC := '1';
    SIGNAL NB : STD_LOGIC := '0';
    SIGNAL WE : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    TYPE addr_type IS ARRAY (0 TO 1) OF STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
    SIGNAL Addr : addr_type := (OTHERS => (OTHERS => '0'));

    TYPE weight_type IS ARRAY (0 TO 1) OF STD_LOGIC_VECTOR(weights DOWNTO 0);
    SIGNAL Weight : weight_type := (OTHERS => (OTHERS => '0'));

    SIGNAL FINISHED : STD_LOGIC := '0';

    SIGNAL AER_Bus : STD_LOGIC_VECTOR(neuron_adr DOWNTO 0) := (OTHERS => '1');

    --Outputs
    SIGNAL Spikes : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    -- Clock period definitions
    CONSTANT CLK_period : TIME := 10 ns;

    CONSTANT N1 : INTEGER := 13;
    CONSTANT N2 : INTEGER := 1;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    -- uut1 : IZH_Neuron_INT
    -- GENERIC MAP(
    --     number => N1,
    --     weight_width => weight_width,
    --     neuron_adr => neuron_adr,
    --     weights => weights)
    -- PORT MAP(
    --     CLK => CLK,
    --     DT => DT,
    --     RST => RST,
    --     EN => EN,
    --     WE => WE(N1),
    --     Addr => Addr(N1),
    --     Weight => Weight(N1),
    --     AER_Bus => AER_Bus,
    --     Spike_out => Spikes(N1)
    -- );
    uut2 : IZH_Neuron
    GENERIC MAP(
        number => N1,
        weight_width => weight_width,
        neuron_adr => neuron_adr,
        weights => weights)
    PORT MAP(
        CLK => CLK,
        DT => DT,
        RST => RST,
        EN => EN,
        NB => NB,
        WE => WE(N2),
        Addr => Addr(N2),
        Weight => Weight(N2),
        AER_Bus => AER_Bus,
        Spike_out => Spikes(N2)
    );
    -- Clock process definitions
    CLK_process : PROCESS
    BEGIN
        CLK <= '0';
        WAIT FOR CLK_period/2;
        CLK <= '1';
        WAIT FOR CLK_period/2;
    END PROCESS;
    -- neuron spike
    inj_process : PROCESS
    BEGIN
        DT <= '0';
        WAIT FOR 0.005 ms - CLK_period/2; -- (2.0, 4.0, 0.005)
        DT <= '1';
        WAIT FOR CLK_period/2;
    END PROCESS;
    aer_proc : PROCESS
    BEGIN
        WAIT FOR 2.0 ms;
        aer_bus <= (OTHERS => '0');
    END PROCESS;
    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        NB <= '0';
        WAIT FOR 0.005 ms - CLK_period/2;
        NB <= '1';
        WAIT FOR CLK_period/2;
    END PROCESS;
    -- -- Stimulus process
    -- stim_proc : PROCESS
    -- BEGIN
    --     EN <= '1';
    --     WAIT FOR 0.5 ms - CLK_period/2 - (2 * CLK_period);
    --     EN <= '0';
    --     AER_Bus <= STD_LOGIC_VECTOR(to_signed(2, AER_Bus'length));
    --     WAIT FOR CLK_period;
    --     AER_Bus <= STD_LOGIC_VECTOR(to_signed(3, AER_Bus'length));
    --     WAIT FOR CLK_period;
    --     EN <= '1';
    --     WAIT FOR CLK_period/2;
    -- END PROCESS;

    -- Reset process
    rst_proc : PROCESS
    BEGIN
        RST <= '0';
        WAIT FOR CLK_period;
        RST <= '1';
        WAIT FOR CLK_period;
        RST <= '0';
        WAIT UNTIL FINISHED = '1';
    END PROCESS;

    -- stim_proc : PROCESS
    -- BEGIN
    --     -- hold reset state for 100 ns.
    --     EN <= '1';
    --     RST <= '1';
    --     AER_Bus <= (OTHERS => '1');
    --     WAIT FOR CLK_period * 5;
    --     RST <= '0';
    --     WAIT FOR 50 ns;
    --     WE <= '1';
    --     Weight <= STD_LOGIC_VECTOR(to_signed(120, Weight'length));
    --     Addr <= STD_LOGIC_VECTOR(to_signed(1, Addr'length));
    --     WAIT FOR 50 ns;
    --     WE <= '0';
    --     WAIT FOR 50 ns;
    --     AER_Bus <= STD_LOGIC_VECTOR(to_signed(1, AER_Bus'length));
    --     WAIT;
    -- END PROCESS;
END;