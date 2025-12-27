library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity IF_ID_REG is 
port(   clk         : in std_logic;
        reset       : in std_logic;
        pc          : in std_logic_vector(31 downto 0);
        instr_in    : in std_logic_vector(31 downto 0);
        instr_out   : out std_logic_vector(31 downto 0);
        pc_plus_1   : out std_logic_vector(31 downto 0);

        -- Stalling
        IF_ID_write : in std_logic
);
end IF_ID_REG;

architecture behavior of IF_ID_REG is
begin
    process(clk, reset)
    begin 
        if reset = '1' then
            instr_out <= (others => '0');
            pc_plus_1 <= (others => '0');
        elsif rising_edge(clk) then
            if IF_ID_write = '1' then
                instr_out <= instr_in;
                pc_plus_1 <= std_logic_vector(unsigned(pc) + 1);
            else
                -- Same values
                -- Stalling
            end if;
        end if;
    end process;
end behavior;
