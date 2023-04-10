-------------------------------------------------------------------------
-- Engineer: Eduard-Guillem Merino Mallorqui
-- Create Date: 10:59:16 02/26/2017 
-- Module Name: Top - Behavioral
-- Project Name: Digital System for Neural Network Emulation
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
ENTITY Top IS
    GENERIC (
        image_num : INTEGER := 9; -- number of images
        rest_time : INTEGER := 149; -- rest time for a     neuron TO RETURN TO their DEFAULT state
        train_time : INTEGER := 200; --    train_time * rest_time
        train_spike : INTEGER := 10; -- time after the stimuli TO GENERATE a spike
        untrain_spike : INTEGER := 5; -- time before the       input stimuli TO GENERATE a spike
        pre_reg : INTEGER := 15; -- STDP Pre-Spike         REGISTER width
        post_reg : INTEGER := 5; -- STDP Post-Spike         REGISTER width
        width : INTEGER := 12; -- IZH_Neuron eq         variables width
        neuron_adr : INTEGER := 5; -- Up to 64         neuron_adr
        weights : INTEGER := 10; -- 255 downto -256
        input_neuron_num : INTEGER := 40; -- Number of virtual         AND training neurons + 1
        training_neuron_num : INTEGER := 6; -- Number of training         neurons
        neuron_num : INTEGER := 46); -- Number of neurons         + 1
    PORT (
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC;
        BTN : IN STD_LOGIC;
        SEL : IN STD_LOGIC;
        Image : IN STD_LOGIC_VECTOR(image_num DOWNTO 0);
        Neuron : IN STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0);
        Spikes_out : OUT STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0));
END Top;
ARCHITECTURE Behavioral OF Top IS
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
    COMPONENT IZH_Neuron
        GENERIC (
            number : IN INTEGER;
            width : IN INTEGER;
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

    SIGNAL RST_Signal : STD_LOGIC;
    SIGNAL Image_Signal : STD_LOGIC_VECTOR(image_num DOWNTO 0);
    SIGNAL Neuron_Signal : STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0);
    SIGNAL Spikes_Signal : STD_LOGIC_VECTOR(neuron_num - input_neuron_num - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Counter : unsigned(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL Pixels, Digit, Digit_Noise : STD_LOGIC_VECTOR(input_neuron_num - training_neuron_num DOWNTO 0);
    SIGNAL Spikes_in : STD_LOGIC_VECTOR(input_neuron_num DOWNTO 0);
    SIGNAL Spikes : STD_LOGIC_VECTOR(neuron_num DOWNTO 0) := (OTHERS => '0');
    SIGNAL AER : STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
    SIGNAL EN_Neuron : STD_LOGIC;

    TYPE TYPES IS (NP, P0, P1);
    SIGNAL STATE0, STATE1 : TYPES;

    SIGNAL BTN_Rebound : unsigned(19 DOWNTO 0);
    SIGNAL BTN_Signal : STD_LOGIC;
    SIGNAL EN_Pulse : STD_LOGIC;
    SIGNAL Pulse : unsigned(16 DOWNTO 0) := (OTHERS => '0');

    SIGNAL EN_STDP : STD_LOGIC;
    SIGNAL EN_Train : STD_LOGIC;
    SIGNAL EN_Addr : STD_LOGIC;
    SIGNAL WE : STD_LOGIC_VECTOR(neuron_num DOWNTO input_neuron_num + 1);
    SIGNAL Pre_Spikes : STD_LOGIC_VECTOR(input_neuron_num - training_neuron_num DOWNTO 0);
    TYPE addr_type IS ARRAY (input_neuron_num + 1 TO neuron_num) OF STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
    SIGNAL Addr : addr_type := (OTHERS => (OTHERS => '0'));
    TYPE weight_type IS ARRAY (input_neuron_num + 1 TO neuron_num) OF STD_LOGIC_VECTOR(weights DOWNTO 0);
    SIGNAL Weight : weight_type := (OTHERS => (OTHERS => '0'));

BEGIN
    -- RST Signal
    PROCESS (clk)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            IF RST = '1' THEN
                RST_Signal <= '1';
            ELSE
                RST_Signal <= '0';
            END IF;
        END IF;
    END PROCESS;
    -- Counter
    PROCESS (clk)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            IF (EN_Neuron = '1') THEN
                IF Counter = rest_time THEN
                    Counter <= (OTHERS => '0');
                ELSE
                    Counter <= Counter + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    -- Input neurons

    PROCESS (clk)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            Image_Signal <= Image;
            Neuron_Signal <= Neuron;
        END IF;
    END PROCESS;

    Digit <= "01110100011000110001100011000101110" WHEN
        Image_Signal(0) = '1' ELSE
        "00100011000010000100001000010001110" WHEN
        Image_Signal(1) = '1' ELSE
        "01110100010000100010001000100011111" WHEN
        Image_Signal(2) = '1' ELSE
        "01110100010000100110000011000101110" WHEN
        Image_Signal(3) = '1' ELSE
        "00010001100101010010111110001000010" WHEN
        Image_Signal(4) = '1' ELSE
        "11111100001111000001000011000101110" WHEN
        Image_Signal(5) = '1' ELSE
        "00110010001000011110100011000101110" WHEN
        Image_Signal(6) = '1' ELSE
        "11111000010001000100010000100001000" WHEN
        Image_Signal(7) = '1' ELSE
        "01110100011000101110100011000101110" WHEN
        Image_Signal(8) = '1' ELSE
        "01110100011000101111000010001001100" WHEN
        Image_Signal(9) = '1' ELSE
        (OTHERS => '0');

    Digit_Noise <= "11111100011000110001100011000111111" WHEN
        Image_Signal(0) = '1' ELSE
        "00100011000010000100001000010000100" WHEN
        Image_Signal(1) = '1' ELSE
        "01110000010000100010001000100001111" WHEN
        Image_Signal(2) = '1' ELSE
        "01110000010000100110000010000101110" WHEN
        Image_Signal(3) = '1' ELSE
        "00010100101001010010111110001000010" WHEN
        Image_Signal(4) = '1' ELSE
        "11110100001111000001000010000101110" WHEN
        Image_Signal(5) = '1' ELSE
        "00110010001000001110100001000101110" WHEN
        Image_Signal(6) = '1' ELSE
        "11111000010001000000010000100001000" WHEN
        Image_Signal(7) = '1' ELSE
        "01110100011000111111100011000101110" WHEN
        Image_Signal(8) = '1' ELSE
        "01110100011000101110000010001000100" WHEN
        Image_Signal(9) = '1' ELSE
        (OTHERS => '0');

    Pixels <= Digit_Noise WHEN SEL = '1' ELSE
        Digit;
    Spikes_in(input_neuron_num DOWNTO 0) <= Neuron_Signal & Pixels;

    Input_Neurons : FOR I IN 0 TO input_neuron_num - training_neuron_num GENERATE
        PROCESS (clk)
        BEGIN
            IF (CLK = '1' AND CLK'event) THEN
                IF Counter = rest_time THEN
                    Spikes(I) <= Spikes_in(I);
                ELSE
                    Spikes(I) <= '0';
                END IF;
            END IF;
        END PROCESS;
    END GENERATE Input_Neurons;

    -- STDP Change synaptic addr
    PROCESS (clk)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            IF Counter = rest_time - 1 THEN
                EN_Addr <= '1';
            ELSE
                EN_Addr <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- Training Neurons
    Training_Neurons : FOR I IN input_neuron_num - training_neuron_num + 1 TO input_neuron_num GENERATE
        PROCESS (clk)
        BEGIN
            IF (CLK = '1' AND CLK'event) THEN
                IF (EN_STDP = '1') THEN
                    IF (Spikes_in(I) = '1' AND Counter = train_spike) THEN
                        Spikes(I) <= '1';
                    ELSIF (Spikes_in(I) = '0' AND Counter = rest_time - untrain_spike) THEN
                        Spikes(I) <= '1';
                    ELSE
                        Spikes(I) <= '0';
                    END IF;
                ELSE
                    Spikes(I) <= '0';
                END IF;
            END IF;
        END PROCESS;
    END GENERATE Training_Neurons;

    -- Output Spikes
    PROCESS (CLK)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            Spikes_Signal <= Spikes(neuron_num DOWNTO input_neuron_num + 1);
            Spikes_out <= Spikes_Signal;
        END IF;
    END PROCESS;

    -- State Machine to detect the pushbuttons
    PROCESS (CLK)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            CASE STATE0 IS
                WHEN NP =>
                    IF BTN = '1' THEN
                        STATE0 <= P0;
                        BTN_Signal <= '0';
                    ELSE
                        STATE0 <= NP;
                        BTN_Signal <= '0';
                    END IF;
                WHEN P0 =>
                    STATE0 <= P1;
                    BTN_Signal <= '1';
                WHEN P1 =>
                    IF BTN = '1' THEN
                        STATE0 <= P1;
                        BTN_Signal <= '0';
                    ELSIF BTN_Rebound = 2000 THEN
                        STATE0 <= NP;
                        BTN_Signal <= '0';
                    END IF;
            END CASE;
        END IF;
    END PROCESS;

    PROCESS (CLK)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            IF (BTN_Signal = '1') THEN
                BTN_Rebound <= (OTHERS => '0');
            ELSE
                IF BTN_Rebound = 2000 THEN
                    BTN_Rebound <= (OTHERS => '0');
                ELSE
                    BTN_Rebound <= BTN_Rebound + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Enable signal for the STDP Module

    PROCESS (CLK)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            CASE STATE1 IS
                WHEN NP =>
                    IF BTN_Signal = '1' THEN
                        STATE1 <= P0;
                        En_Pulse <= '1';
                        EN_STDP <= '1';
                    ELSE
                        En_Pulse <= '0';
                        EN_STDP <= '0';
                    END IF;
                WHEN P0 =>
                    STATE1 <= P1;
                WHEN P1 =>
                    IF Pulse = train_time * rest_time THEN
                        STATE1 <= NP;
                    ELSE
                        En_Pulse <= '1';
                        EN_STDP <= '1';
                    END IF;
            END CASE;
        END IF;
    END PROCESS;

    PROCESS (clk)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            IF (EN_Neuron = '1') THEN
                IF (En_Pulse = '1') THEN
                    IF Pulse = train_time * rest_time THEN
                        Pulse <= (OTHERS => '0');
                    ELSE
                        Pulse <= Pulse + 1;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- AER
    AERX : AER_Bus
    GENERIC MAP(
        neuron_adr => neuron_adr,
        neuron_num => neuron_num)
    PORT MAP(
        CLK => CLK,
        Spikes => Spikes,
        EN_Neuron => EN_Neuron,
        AER => AER);

    -- IZH Neurons

    Network : FOR I IN input_neuron_num + 1 TO neuron_num GENERATE
        NX : IZH_Neuron
        GENERIC MAP(
            number => I,
            width => width,
            neuron_adr => neuron_adr,
            weights => weights)
        PORT MAP(
            CLK => CLK,
            RST => RST_Signal,
            EN => EN_Neuron,
            WE => WE(I),
            Addr => Addr(I),
            Weight => Weight(I),
            AER_Bus => AER,
            Spike_out => Spikes(I));
    END GENERATE Network;

    -- STDP

    Pre_Spikes <= Spikes(input_neuron_num - training_neuron_num DOWNTO 0);

    EN_Train <= EN_STDP AND EN_Neuron;

    Training : FOR I IN input_neuron_num + 1 TO neuron_num GENERATE
        TX : STDP
        GENERIC MAP(
            neuron_adr => neuron_adr,
            weights => weights,
            input_neuron_num => input_neuron_num,
            training_neuron_num => training_neuron_num,
            pre_reg => pre_reg,
            post_reg => post_reg)
        PORT MAP(
            CLK => CLK,
            RST => RST_Signal,
            EN => EN_Train,
            EN_Addr => EN_Addr,
            Pre_Spikes => Pre_Spikes,
            Post_Spike => Spikes(I - training_neuron_num),
            WE => WE(I),
            Addr => Addr(I),
            Weight => Weight(I));
    END GENERATE Training;
END Behavioral;