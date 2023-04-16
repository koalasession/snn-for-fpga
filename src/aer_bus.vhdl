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
        DT : IN STD_LOGIC;
        Spikes : IN STD_LOGIC_VECTOR(neuron_num DOWNTO 0);
        EN_Neuron : OUT STD_LOGIC;
        NB : OUT STD_LOGIC;
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
        IF (rising_edge(clk)) THEN -- should only happen for inj cycle
            IF (FIFO_En = '1') THEN -- if neurons are allowed to fire
                IF (FIFO_ptr > 0) THEN -- if memory has something stored -- for double cycle this is not important
                    FIFO_out <= memory(0); -- first in memory is next to be processed
                    FOR I IN 0 TO 6 LOOP
                        memory(I) <= memory(I + 1); -- shift everything in memory to one down
                    END LOOP;
                    IF (FIFO_in > 0) THEN -- if there is any neuron firing
                        memory(to_integer(FIFO_ptr)) <= FIFO_in; -- store it in next in memory
                    ELSE
                        FIFO_ptr <= FIFO_ptr - 1; -- otherwise decrease index for next loop
                    END IF;
                ELSE
                    --recorded
                    FIFO_out <= FIFO_in; -- if memory is empty process the output directly -- what is going to be processed for double clock thing
                END IF;
            ELSE
                IF (FIFO_ptr /= "110" AND FIFO_in > 0) THEN -- if neurons activation is off and there are neurons firing the memory is not full
                    FIFO_ptr <= FIFO_ptr + 1; -- next index in memory to store
                    memory(to_integer(FIFO_ptr)) <= FIFO_in; -- store the spikes
                END IF;
            END IF;
        END IF;
    END PROCESS;
    -- Demux of spikes
    ENC_in <= FIFO_out WHEN FIFO_En = '1' ELSE -- if neurons are allowed to fire which is always the case at clk INJ
        ENC_spikes WHEN FIFO_En = '0' ELSE -- in case the spikes processing is not finished which should always activates when broadcasting addresses keep processing 
        (OTHERS => '0');
    -- Encoder -- each cycle output an address
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN -- process all the input spikes for output
            FOR I IN ENC_in'RANGE LOOP
                IF (ENC_in(I) = '1') THEN
                    ENC_out <= STD_LOGIC_VECTOR(to_signed(I, neuron_adr + 1));
                    ENC_Spikes <= ENC_in;
                    ENC_Spikes(I) <= '0';
                    EXIT;
                ELSE
                    ENC_out <= (OTHERS => '1'); -- if no spikes broadcast -1
                END IF;
            END LOOP;
        END IF;
    END PROCESS;

    AER <= ENC_out; -- output address
    FIFO_En <= '1' WHEN ENC_Spikes = 0 ELSE
        '0'; -- enable neurons spiking after all spikes are processed
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
    --suggestion activate EN neurons only for receiving and not for firing
    -- if address has something other than ff or if spikes is 0 and clkinj is 1
    NB <= '1' WHEN signed(ENC_out) /= to_signed(-1, ENC_out'length) ELSE
        '1' WHEN (spikes = 0 AND DT = '1') ELSE
        '0';
END Behavioral;