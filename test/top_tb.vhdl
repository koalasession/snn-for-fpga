LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.env.finish;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY TOP_Testbench IS
    GENERIC (
        weight_width : INTEGER := 12;
        neuron_adr : INTEGER := 7; -- Up to 32 neuron_adr
        weights : INTEGER := 10; -- 255 downto -256
        input_neuron_num : INTEGER := 1; -- Number of virtual neurons
        neuron_num : INTEGER := 76); -- Number of neurons +1
END TOP_Testbench;

ARCHITECTURE behavior OF TOP_Testbench IS

    -- UUT
    COMPONENT Top
        PORT (
            CLK : IN STD_LOGIC;
            DT : IN STD_LOGIC;
            RST : IN STD_LOGIC;
            FINISHED : OUT STD_LOGIC;
            pattern : OUT STD_LOGIC_VECTOR(input_neuron_num DOWNTO 0);
            Spikes_out : OUT STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0));
    END COMPONENT;

    --Inputs
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL DT : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
    --Outputs
    SIGNAL FINISHED : STD_LOGIC;
    SIGNAL pattern : STD_LOGIC_VECTOR(input_neuron_num DOWNTO 0);
    SIGNAL Spikes_out : STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0);

    -- Clock period definitions
    -- CONSTANT CLK_period : TIME := 1000 ns;
    CONSTANT CLK_period : TIME := 0.01 ns;
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : Top PORT MAP(
        CLK => CLK,
        DT => DT,
        RST => RST,
        pattern => pattern,
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
    -- neuron spike
    inj_process : PROCESS
    BEGIN
        DT <= '0';
        WAIT FOR 1 ns - CLK_period/2; -- simulation time = 1200000 ms , neuron frequency =  0.5 . ms
        -- 500000 ns neuron frequency
        -- 1200000000000 ns simulation
        -- run for 2400000.0 ns for a 1 ns frequency
        -- clock frequency should be frequency / 100 = 0.01 ns
        DT <= '1';
        WAIT FOR CLK_period/2;
    END PROCESS;
    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- hold reset state for 100 ns.
        RST <= '1';
        WAIT FOR CLK_period;
        RST <= '0';
        WAIT FOR CLK_period;
        RST <= '1';
        WAIT FOR CLK_period;
        RST <= '0';
        WAIT UNTIL FINISHED = '1';

    END PROCESS;
    --FOR readout! Write VARIABLE TO FILE
    -- PROCESS (CLK)
    --     VARIABLE OLINE : line;
    -- BEGIN
    --     IF (falling_edge(CLK)) THEN -- external enable signal  
    --         file_open(file_RESULTS, "spikes_train_out.txt", append_mode);
    --         write(OLINE, SPIKES_OUT); --- what is this variable
    --         writeline(file_RESULTS, OLINE);
    --         file_close(file_RESULTS);
    --     END IF;
    -- END PROCESS;
END;