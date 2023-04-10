-------------------------------------------------------------------------
-- Engineer: Eduard-Guillem Merino Mallorqui
-- Create Date: 10:59:16 02/26/2017 
-- Module Name: AER Bus - Behavioral
-- Project Name: Digital System for Neural Network Emulation
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
ENTITY AER_Bus IS
    GENERIC (
        neuron_adr : IN INTEGER;
        neuron_num : IN INTEGER);
    PORT (
        CLK : IN STD_LOGIC;
        Spikes : IN STD_LOGIC_VECTOR(neuron_num DOWNTO 0);
        EN_Neuron : OUT STD_LOGIC;
        AER : OUT STD_LOGIC_VECTOR(neuron_adr DOWNTO 0));
END AER_Bus;
ARCHITECTURE Behavioral OF AER_Bus IS
    TYPE memory_type IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR(neuron_num DOWNTO 0);
    SIGNAL memory : memory_type := (OTHERS => (OTHERS => '0'));
    SIGNAL FIFO_En : STD_LOGIC := '1';
    SIGNAL FIFO_in, FIFO_out : STD_LOGIC_VECTOR(neuron_num DOWNTO 0);
    SIGNAL FIFO_ptr : unsigned(2 DOWNTO 0) := "000";
    SIGNAL ENC_in, ENC_Spikes : STD_LOGIC_VECTOR(neuron_num DOWNTO 0) := (OTHERS => '0');
    SIGNAL ENC_out : STD_LOGIC_VECTOR(neuron_adr DOWNTO 0) := (OTHERS => '0');
BEGIN
    -- FIFO
    FIFO_in <= Spikes;
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (FIFO_En = '1') THEN
                IF (FIFO_ptr > 0) THEN
                    FIFO_out <= memory(0);
                    FOR I IN 0 TO 6 LOOP
                        memory(I) <= memory(I + 1);
                    END LOOP;
                    IF (FIFO_in > 0) THEN
                        memory(to_integer(FIFO_ptr)) <= FIFO_in;
                    ELSE
                        FIFO_ptr <= FIFO_ptr - 1;
                    END IF;
                ELSE
                    FIFO_out <= FIFO_in;
                END IF;
            ELSE
                IF (FIFO_ptr /= "110" AND FIFO_in > 0) THEN
                    FIFO_ptr <= FIFO_ptr + 1;
                    memory(to_integer(FIFO_ptr)) <= FIFO_in;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    -- Demux of spikes
    ENC_in <= FIFO_out WHEN FIFO_En = '1' ELSE
        ENC_spikes WHEN FIFO_En = '0' ELSE
        (OTHERS => '0');
    -- Encoder
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            FOR I IN ENC_in'RANGE LOOP
                IF (ENC_in(I) = '1') THEN
                    ENC_out <= STD_LOGIC_VECTOR(to_signed(I, neuron_adr + 1));
                    ENC_Spikes <= ENC_in;
                    ENC_Spikes(I) <= '0';
                    EXIT;
                ELSE
                    ENC_out <= (OTHERS => '1');
                END IF;
            END LOOP;
        END IF;
    END PROCESS;

    AER <= ENC_out;
    FIFO_En <= '1' WHEN ENC_Spikes="00000" ELSE '0';
    -- Neuron's Enable
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF FIFO_En = '1' THEN
                EN_Neuron <= '1';
            ELSE
                EN_Neuron <= '0';
            END IF;
        END IF;
    END PROCESS;
END Behavioral;