-------------------------------------------------------------------------
-- Engineer: Eduard-Guillem Merino Mallorqui
-- Create Date: 12:14:40 01/04/2017 
-- Module Name: STDP - Behavioral 
-- Project Name: Digital System for Neural Network Emulation
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_misc.ALL;

ENTITY STDP IS
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
END STDP;
ARCHITECTURE Behavioral OF STDP IS
    SIGNAL pre_shift_reg : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL post_shift_reg : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Pre_Spike, pre_gate, post_gate, decr_sel, incr_sel, decr, incr : STD_LOGIC := '0';
    SIGNAL Syn_Addr : unsigned(neuron_adr DOWNTO 0) := (OTHERS => '0');
    TYPE memory_weight IS ARRAY (0 TO input_neuron_num) OF signed(weights DOWNTO 0);
    SIGNAL Syn_Weight : memory_weight := (OTHERS => (OTHERS => '1'));

BEGIN
    -- Synaptic Addr counter and Pre-Spike selector
    PROCESS (CLK)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (EN = '1') THEN
                IF EN_Addr = '1' THEN
                    IF Syn_Addr = input_neuron_num - training_neuron_num THEN
                        Syn_Addr <= (OTHERS => '0');
                    ELSE
                        Syn_Addr <= Syn_Addr + 1;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    Pre_Spike <= Pre_Spikes(to_integer(Syn_Addr));
    Addr <= STD_LOGIC_VECTOR(Syn_Addr);
    -- Pre-Spike Shift Register
    PROCESS (CLK)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (RST = '1') THEN
                pre_shift_reg <= (OTHERS => '0');
            ELSIF (EN = '1') THEN
                pre_shift_reg(pre_reg) <= Pre_Spike;
                FOR I IN pre_reg - 1 DOWNTO 0 LOOP
                    pre_shift_reg(I) <= pre_shift_reg(I + 1); -- shift register
                END LOOP;
            END IF;
        END IF;
    END PROCESS;
    -- Pre-Spike OR Gates
    pre_gate <= or_reduce(pre_shift_reg);
    -- Post-Spike Shift Register
    PROCESS (CLK)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (RST = '1') THEN
                post_shift_reg <= (OTHERS => '0');
            ELSIF (EN = '1') THEN
                post_shift_reg(post_reg) <= Post_Spike;
                FOR I IN post_reg - 1 DOWNTO 0 LOOP
                    post_shift_reg(I) <= post_shift_reg(I + 1);
                END LOOP;
            END IF;
        END IF;
    END PROCESS;
    -- Post_Spike OR Gate
    post_gate <= or_reduce(post_shift_reg);
    -- I/D Sel
    PROCESS (CLK)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (RST = '1') THEN
                incr_sel <= '0';
                decr_sel <= '0';
            ELSIF (EN = '1') THEN
                IF (Pre_Spike = '1') THEN
                    incr_sel <= '0';
                    decr_sel <= '1';
                END IF;
                IF (Post_Spike = '1') THEN
                    decr_sel <= '0';
                    incr_sel <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;
    -- Decr and Incr Gates
    decr <= pre_gate AND (decr_sel AND post_gate);
    incr <= pre_gate AND (incr_sel AND post_gate);
    -- Synpatic Weight Counter

    PROCESS (CLK)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (RST = '1') THEN
                -- Syn_Weight(to_integer(Syn_Addr))<=(others=>'0');
                -- WE <= '1';
            ELSIF (EN = '1') THEN
                IF (decr = '1') THEN
                    IF Syn_Weight(to_integer(Syn_Addr)) >- 140 THEN
                        Syn_Weight(to_integer(Syn_Addr)) <= Syn_Weight(to_integer(Syn_Addr)) - to_signed(1, weights + 1); -- SHOULD BE MINUS
                        WE <= '1';
                    END IF;
                ELSIF (incr = '1') THEN
                    IF Syn_Weight(to_integer(Syn_Addr)) < 300 THEN
                        Syn_Weight(to_integer(Syn_Addr)) <= Syn_Weight(to_integer(Syn_Addr)) + to_signed(1, weights + 1);
                        WE <= '1';
                    END IF;
                ELSE
                    WE <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;
    Weight <= STD_LOGIC_VECTOR(Syn_Weight(to_integer(Syn_Addr)));
END Behavioral;