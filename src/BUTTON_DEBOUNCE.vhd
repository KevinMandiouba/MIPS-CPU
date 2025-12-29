-- Based on Samuel McDonald's video
-- VHDL Button Debounce (https://www.youtube.com/watch?v=eRawZX_R7Bg)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BUTTON_DEBOUNCE is
  generic (
    pulse       : boolean   := true;
    active_low  : boolean   := false;   -- Basys3's buttons are active high
    delay       : integer   := 100_000  -- for 100 MHz clk
  );
  port (
    clk         : in std_logic;
    reset       : in std_logic;
    input       : in std_logic;
    debounce    : out std_logic
  );
end BUTTON_DEBOUNCE;

architecture behavior of BUTTON_DEBOUNCE is
    -- Accept all 1's or all 0's
    signal sample       : std_logic_vector(9 downto 0) := "0001111000"; 
    signal sample_pulse : std_logic := '0';
begin

    Clock_Divider: process(clk)
        variable count: integer := 0;
    begin
        if rising_edge(clk) then
            if reset = '0' then 
                count := 0;
                sample_pulse <= '0';
            else
                if (count < delay) then
                    count := count + 1;
                    sample_pulse <= '0'; 
                else
                    count := 0;
                    sample_pulse <= '1';
                end if;
            end if;
        end if;
    end process;

    Sampling : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                sample <= (others => input);
            else
                if sample_pulse = '1' then
                    sample(9 downto 1) <= sample(8 downto 0); -- Left shift
                    sample(0) <= input;
                end if;
            end if;
        end if;
    end process;

    Button_Debouncing : process(clk)
        variable flag: std_logic := '0';
    begin
        if rising_edge(clk) then
            if reset = '0' then
                debounce <= '0';
            else
                if active_low then
                    if pulse then
                        -- Active Low Pulse Out
                        if sample = "0000000000" then
                            if flag = '0' then
                                debounce <= '1';
                                flag := '1';
                            else 
                                debounce <= '0';
                            end if;
                        else
                            debounce <= '0';
                            flag := '0';
                        end if;
                    else
                        -- Active Low Constant Out
                        if sample = "0000000000" then
                            debounce <= '1';
                        elsif sample = "1111111111" then
                            debounce <= '0';
                        end if;
                    end if;
                else
                    if pulse then 
                        -- Active High Pulse Out
                        if sample = "1111111111" then
                            if flag = '0' then
                                debounce <= '1';
                                flag := '1';
                            else
                                debounce <= '0';
                            end if;
                        else 
                            debounce <= '0';
                            flag := '0';
                        end if;
                    else
                        -- Active High Constant Out
                        if sample = "1111111111" then
                            debounce <= '1';
                        elsif sample = "0000000000" then
                            debounce <= '0';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end behavior;
