LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY ieee_proposed;
USE ieee_proposed.fixed_pkg.ALL;
-- USE ieee.fixed_pkg.ALL; -- ieee_proposed for compatibility version 

ENTITY IZH_Neuron IS
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
END IZH_Neuron;
ARCHITECTURE Behavioral OF IZH_Neuron IS
    COMPONENT RAM_0
        GENERIC (
            number : IN INTEGER;
            weight_width : IN INTEGER;
            neuron_adr : IN INTEGER;
            weights : IN INTEGER);
        PORT (
            clk : IN STD_LOGIC;
            we : IN STD_LOGIC;
            a : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
            dpra : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
            di : IN STD_LOGIC_VECTOR(weights DOWNTO 0);
            dpo : OUT STD_LOGIC_VECTOR(weights DOWNTO 0));
    END COMPONENT;
    SIGNAL I : signed(weight_width DOWNTO 0) := (OTHERS => '0');

    SIGNAL v_n : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(-65, weight_width, -weight_width);
    SIGNAL u_n : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(0, weight_width, -weight_width);

    SIGNAL thresh : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(30, weight_width, -weight_width);
    SIGNAL c : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(-65, weight_width, -weight_width);

    CONSTANT v_coeff_2 : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(0.04, weight_width, -weight_width);
    CONSTANT v_coeff_1 : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(5, weight_width, -weight_width);
    CONSTANT v_const : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(140, weight_width, -weight_width);
    CONSTANT a : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(0.02, weight_width, -weight_width);
    CONSTANT b : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(0.2, weight_width, -weight_width);
    CONSTANT d : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(8, weight_width, -weight_width);

    SIGNAL v_temp : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(-65, weight_width, -weight_width);
    SIGNAL u_temp : sfixed(weight_width DOWNTO -weight_width) := to_sfixed(0, weight_width, -weight_width);

    SIGNAL Synaptic_in : STD_LOGIC_VECTOR(weights DOWNTO 0) := (OTHERS => '0');
    SIGNAL Spike : STD_LOGIC := '0';
    TYPE signed_array IS ARRAY (0 TO 0) OF signed(weight_width DOWNTO 0);
    SIGNAL I_store : signed_array := (OTHERS => (OTHERS => '0'));
BEGIN
    -- RAM
    RAM : RAM_0
    GENERIC MAP(
        number => number,
        weight_width => weight_width,
        neuron_adr => neuron_adr,
        weights => weights)
    PORT MAP(
        clk => CLK,
        we => WE,
        a => Addr,
        dpra => AER_Bus,
        di => Weight,
        dpo => Synaptic_in);
    -- Input align
    PROCESS (CLK)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (NB = '1') THEN
                IF (EN = '1') THEN
                    I <= resize(signed(Synaptic_in), I'length);
                ELSE
                    I <= I + resize(signed(Synaptic_in), I'length); -- accumulate all firing neurons
                END IF;
            END IF;
        END IF;
    END PROCESS;
    PROCESS (NB)
    BEGIN
        IF falling_edge(NB) THEN
            IF (EN = '1') THEN
                v_temp <= resize(
                    (((((v_coeff_2 * v_n)
                    + v_coeff_1) * v_n)
                    + v_const - u_n) * 0.5) + to_sfixed(I, weight_width, -weight_width) + v_n, v_n);
                u_temp <= resize(((a * ((b * v_n) - u_n)) * 0.5) + u_n, u_n);
            END IF;
        END IF;
    END PROCESS;

    Spike <= '1' WHEN v_temp > thresh ELSE
        '0';

    v_n <= c WHEN RST = '1' ELSE
        v_temp WHEN Spike = '0' ELSE
        c WHEN Spike = '1' ELSE
        (OTHERS => '0');

    u_n <= u_temp WHEN RST = '1' ELSE
        u_temp WHEN Spike = '0' ELSE
        resize(u_temp + d, u_temp)
        WHEN Spike = '1' ELSE
        (OTHERS => '0');

    PROCESS (DT)
    BEGIN
        IF (rising_edge(DT)) THEN
            Spike_out <= Spike;
        END IF;
    END PROCESS;
END Behavioral;