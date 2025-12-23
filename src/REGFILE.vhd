library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity REGFILE is
port(   din             : in std_logic_vector(31 downto 0);
        reset           : in std_logic;
        clk             : in std_logic;
        write           : in std_logic;
        read_a          : in std_logic_vector (4 downto 0);
        read_b          : in std_logic_vector(4 downto 0);
        write_address   : in std_logic_vector(4 downto 0);
        out_a           : out std_logic_vector(31 downto 0);
        out_b           : out std_logic_vector(31 downto 0));
end REGFILE ;

architecture behavior of REGFILE is

        type register_array is array (31 downto 0) 
                of std_logic_vector(31 downto 0);

        signal registers: register_array :=(others => (others => '0'));

begin

        out_a <= registers(to_integer(unsigned(read_a)));
        out_b <= registers(to_integer(unsigned(read_b)));

        process(clk, reset)
        begin 
                if reset = '1' then
                        registers <=(others => (others => '0'));
                elsif rising_edge(clk) then
                        if write = '1' then
                                registers(to_integer(unsigned(write_address))) <= din;
                        end if;
                end if;
        end process;
end behavior;