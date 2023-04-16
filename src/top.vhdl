LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE STD.textio.ALL;
USE ieee.std_logic_textio.ALL;

ENTITY Top IS
    GENERIC (
        weight_width : INTEGER := 16; -- IZH_Neuron eq
        neuron_adr : INTEGER := 7; -- Up to 128
        weights : INTEGER := 10; -- 255 downto -256
        input_neuron_num : INTEGER := 1; -- Number of virtual neurons for STDP
        neuron_num : INTEGER := 76); -- Number of neurons
    PORT (
        CLK : IN STD_LOGIC;
        DT : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        FINISHED : OUT STD_LOGIC;
        pattern : OUT STD_LOGIC_VECTOR(input_neuron_num DOWNTO 0); -- injection spikes
        Spikes_out : OUT STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0)); -- all neurons of lsm
END Top;
ARCHITECTURE Behavioral OF Top IS
    COMPONENT AER_Bus
        GENERIC (
            neuron_adr : IN INTEGER;
            neuron_num : IN INTEGER);
        PORT (
            CLK : IN STD_LOGIC;
            DT : IN STD_LOGIC;
            Spikes : IN STD_LOGIC_VECTOR(neuron_num DOWNTO 0);
            EN_Neuron : OUT STD_LOGIC; -- stops activity of neurons
            NB : OUT STD_LOGIC;
            AER : OUT STD_LOGIC_VECTOR(neuron_adr DOWNTO 0)); -- address of which neuron has spiked ram reads it and returns weight of the synapse
    END COMPONENT;
    COMPONENT IZH_Neuron
        GENERIC (
            number : IN INTEGER;
            weight_width : IN INTEGER;
            neuron_adr : IN INTEGER;
            weights : IN INTEGER);
        PORT (
            CLK : IN STD_LOGIC;
            DT : IN STD_LOGIC;
            RST : IN STD_LOGIC; -- reset neurons ram
            EN : IN STD_LOGIC; -- signal of en neuron that disables and enables all
            NB : IN STD_LOGIC; -- signal of en neuron that disables and enables all
            WE : IN STD_LOGIC; -- enables weight update sent from STDP
            Addr : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0); -- address of neuron that needs to be updated
            Weight : IN STD_LOGIC_VECTOR(weights DOWNTO 0); -- weight received from stdp along with addr and we to update the weights
            AER_Bus : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);-- receives address of which neuron has spiked
            Spike_out : OUT STD_LOGIC);
    END COMPONENT;
    SIGNAL RST_Signal : STD_LOGIC;
    SIGNAL Spikes_Signal : STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Spikes : STD_LOGIC_VECTOR(neuron_num DOWNTO 0) := (OTHERS => '0');
    SIGNAL AER : STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
    SIGNAL EN_Neuron : STD_LOGIC;
    SIGNAL NB : STD_LOGIC;

    SIGNAL WE : STD_LOGIC_VECTOR(neuron_num DOWNTO 0) := (OTHERS => '0');
    TYPE addr_type IS ARRAY (0 TO neuron_num) OF STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
    SIGNAL Addr : addr_type := (OTHERS => (OTHERS => '0'));
    TYPE weight_type IS ARRAY (0 TO neuron_num) OF STD_LOGIC_VECTOR(weights DOWNTO 0);
    SIGNAL Weight : weight_type := (OTHERS => (OTHERS => '0'));

    SIGNAL pattern_signal : STD_LOGIC_VECTOR(input_neuron_num DOWNTO 0) := (OTHERS => '0');

    FILE file_RESULTS : text;

BEGIN
    -- RST Signal
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF RST = '1' THEN
                RST_Signal <= '1';
            ELSE
                RST_Signal <= '0';
            END IF;
        END IF;
    END PROCESS;
    -- input spike train
    p_read : PROCESS (CLK)
        CONSTANT NUM_COL : INTEGER := 1; -- number of column of file
        TYPE t_integer_array IS ARRAY(INTEGER RANGE <>) OF INTEGER;
        FILE test_vector : text OPEN read_mode IS "spike_train_in.txt";
        VARIABLE row : line; -- page 46
        VARIABLE v_data_read : STD_LOGIC_VECTOR(1 DOWNTO 0);
        VARIABLE v_data_row_counter : INTEGER := 0;
    BEGIN
        IF (rising_edge(CLK)) THEN
            IF (RST_SIGNAL = '0' AND EN_neuron = '1' AND DT = '1') THEN -- AER enable signal  
                IF (NOT endfile(test_vector)) THEN
                    FINISHED <= '0';
                    readline(test_vector, row);
                    read(row, v_data_read);
                    pattern_signal <= v_data_read; -- only for out
                    Spikes(0) <= v_data_read(1);
                    Spikes(1) <= v_data_read(0);
                ELSE
                    FINISHED <= '1';
                END IF;
            ELSIF DT = '0' THEN
                Spikes(0) <= '0';
                Spikes(1) <= '0';
                pattern_signal <= "00";
            END IF;
        END IF;
    END PROCESS p_read;
    pattern <= pattern_signal;
    Spikes_out <= Spikes(neuron_num DOWNTO input_neuron_num + 1);

    -- Spikes_signal(input_neuron_num TO 0) <= pattern_signal; -- which neuron is activated for learning aka input plus the pattern to recognize
    -- Input_Neurons : FOR I IN 0 TO input_neuron_num GENERATE
    --     PROCESS (CLK)
    --     BEGIN
    --         IF (rising_edge(CLK)) THEN
    --             Spikes(I) <= pattern_signal(I);
    --         END IF;
    --     END PROCESS;
    -- END GENERATE Input_Neurons;

    -- For readout! Write variable to file        
    -- PROCESS (DT)
    --     VARIABLE OLINE : line;
    -- BEGIN
    --     IF (rising_edge(DT)) THEN -- external enable signal  
    --         file_open(file_RESULTS, "spikes_train_out.txt", append_mode);
    --         write(OLINE, Spikes(neuron_num DOWNTO input_neuron_num + 1)); --- what is this variable
    --         writeline(file_RESULTS, OLINE);
    --         file_close(file_RESULTS);
    --     END IF;
    -- END PROCESS;

    AERX : AER_Bus
    GENERIC MAP(
        neuron_adr => neuron_adr,
        neuron_num => neuron_num)
    PORT MAP(
        CLK => CLK,
        DT => DT,
        Spikes => Spikes,
        EN_Neuron => EN_Neuron,
        NB => NB,
        AER => AER);
    -- IZH Neurons
    Network : FOR I IN input_neuron_num + 1 TO neuron_num GENERATE
        NX : IZH_Neuron
        GENERIC MAP(
            number => I,
            weight_width => weight_width,
            neuron_adr => neuron_adr,
            weights => weights)
        PORT MAP(
            CLK => CLK,
            DT => DT,
            RST => RST_Signal,
            EN => EN_Neuron,
            NB => NB,
            WE => WE(I),
            Addr => Addr(I),
            Weight => Weight(I),
            AER_Bus => AER,
            Spike_out => Spikes(I));
    END GENERATE Network;

END Behavioral;