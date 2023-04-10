-------------------------------------------------------------------------
-- Engineer: Eduard-Guillem Merino Mallorqui
-- Create Date: 10:00:00 03/05/2017
-- Module Name: RAM_09 - Behavioral
-- Project Name: Digital System for Neural Network Emulation
-------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;
ENTITY RAM_09 IS
    GENERIC (
        number : IN INTEGER;
        width : IN INTEGER;
        neuron_adr : IN INTEGER;
        weights : IN INTEGER);
    PORT (
        clk : IN STD_LOGIC;
        we : IN STD_LOGIC;
        a : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
        dpra : IN STD_LOGIC_VECTOR(neuron_adr DOWNTO 0);
        di : IN STD_LOGIC_VECTOR(weights DOWNTO 0);
        dpo : OUT STD_LOGIC_VECTOR(weights DOWNTO 0));
END RAM_09;
ARCHITECTURE syn OF RAM_09 IS
    TYPE ram_type IS ARRAY (0 TO 63) OF STD_LOGIC_VECTOR(weights DOWNTO 0);
    SIGNAL RAM : ram_type := (
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000",
        x"00" & "000", x"00" & "000", x"00" & "000", x"00" & "000"); -- Initializes all weights to 0

BEGIN
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (we = '1') THEN
                RAM(conv_integer(a)) <= di;
            END IF;
        END IF;
    END PROCESS;
    dpo <= RAM(conv_integer(dpra));
END syn;