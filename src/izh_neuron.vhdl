-------------------------------------------------------------------------
-- Engineer: Eduard-Guillem Merino Mallorqui
-- Create Date: 11:53:08 02/12/2017 
-- Module Name: IZH_Neuron - Behavioral 
-- Project Name: Digital System for Neural Network Emulation
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IZH_Neuron IS
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
END IZH_Neuron;

ARCHITECTURE Behavioral OF IZH_Neuron IS

    COMPONENT RAM_09
        GENERIC (
            width : IN INTEGER;
            neuron_adr : IN INTEGER;
            weights : IN INTEGER;
            number : IN INTEGER);
        PORT (
            clk : IN STD_LOGIC;
            we : IN STD_LOGIC;
            a : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
            dpra : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
            di : IN STD_LOGIC_VECTOR(weights DOWNTO 0);
            dpo : OUT STD_LOGIC_VECTOR(weights DOWNTO 0));
    END COMPONENT;

    SIGNAL c, d, thresh : signed(width DOWNTO 0);
    SIGNAL I, v_n, v_n1, u_n, u_n1 : signed(width DOWNTO 0) := (OTHERS => '0');
    SIGNAL v1, v2, v3, u1, u2, u3, u4, u5 : signed(width DOWNTO 0);
    SIGNAL Synaptic_in : STD_LOGIC_VECTOR(weights DOWNTO 0);
    SIGNAL Spike : STD_LOGIC;
    TYPE signed_array IS ARRAY (0 TO 1) OF signed(width DOWNTO 0);
    SIGNAL I_store, v_store, u_store : signed_array := (OTHERS => (OTHERS => '0'));

BEGIN

    -- RAM
    RAM : RAM_09
    GENERIC MAP(
        number => number,
        width => width,
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
        IF (CLK = '1' AND CLK'event) THEN
            IF (EN = '1') THEN
                I_store(0) <= resize(signed(Synaptic_in), I_store(0)'length);
                I <= I_store(1);
                IF I_store(0) >- 140 THEN
                    I_store(1) <= I_store(0);
                ELSE
                    I_store(1) <= to_signed(-140, I_store(0)'length);
                END IF;
            ELSE
                I_store(0) <= I_store(0) + resize(signed(Synaptic_in), I_store(0)'length);
            END IF;
        END IF;
    END PROCESS;
    -- "v" Store
    PROCESS (CLK)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            IF (EN = '1') THEN
                v_store(0) <= v_n1;
                v_store(1) <= v_store(0);
                v_n <= v_store(1);
            END IF;
        END IF;
    END PROCESS;
    -- "u" Store

    PROCESS (CLK)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            IF (EN = '1') THEN
                u_store(0) <= u_n1;
                u_store(1) <= u_store(0);
                u_n <= u_store(1);
            END IF;
        END IF;
    END PROCESS;
    -- Parameters
    c <= to_signed(-650, width + 1);
    d <= to_signed(80, width + 1);
    thresh <= to_signed(300, width + 1);
    -- "v" Pipeline
    PROCESS (CLK)
    BEGIN
        IF (CLK = '1' AND CLK'event) THEN
            IF (EN = '1') THEN
                v3 <= resize(shift_right(v_n * v_n, 8) -- v_n^2/256
                    + shift_left(v_n, 1) + shift_left(v_n, 2) -- v_n + 5*v_n
                    + to_signed(1400, width + 1) -- + 1400
                    - u_n + I, v3'length); -- - u_n + I
            END IF;
        END IF;
    END PROCESS;

    Spike <= '1' WHEN v3 > thresh ELSE
        '0';

    v_n1 <= c WHEN RST = '1' ELSE
        v3 WHEN Spike = '0' ELSE
        c WHEN Spike = '1' ELSE
        (OTHERS => '0');

    Spike_out <= Spike;
    -- "u" Pipeline
    u1 <= shift_right(v_n, 2); -- v_n/4
    u2 <= u1 - u_n; -- v_n/4 - u_n
    u3 <= shift_right(u2, 6); -- (v_n/4 - u_n)/64
    u4 <= u_n + u3; -- u_n + (v_n/4 - u_n)/64
    u5 <= u4 + d; -- u_n + (v_n/4 - u_n)/64 + d

    u_n1 <= u4 WHEN RST = '1' ELSE
        u4 WHEN Spike = '0' ELSE
        u5 WHEN Spike = '1' ELSE
        (OTHERS => '0');

END Behavioral;