library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity PC_REG is
port(   clk     : in std_logic;
        reset   : in std_logic;
        next_pc : in std_logic_vector(31 downto 0);
        pc      : out std_logic_vector(31 downto 0);
        pc_write: in std_logic -- stalling
    );
end PC_REG;

architecture behavior of PC_REG is
begin
   process(clk, reset)
   begin
        if reset = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            if pc_write = '1' then
                pc <= next_pc;
            else
                -- Same PC as before
                -- Stalling
            end if;
        end if;
    end process;
end behavior;