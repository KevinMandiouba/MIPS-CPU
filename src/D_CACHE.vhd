library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity D_CACHE is
port(   clk         : in std_logic;
        reset       : in std_logic;
        data_write  : in std_logic;
        addr         : in std_logic_vector(31 downto 0); 
        d_in        : in std_logic_vector(31 downto 0);
        d_out       : out std_logic_vector(31 downto 0)
    );
end D_CACHE;

architecture behavior of D_CACHE is

    signal address: std_logic_vector(4 downto 0);

    type location_array is array (31 downto 0) 
                of std_logic_vector(31 downto 0);

        signal locations: location_array :=(others => (others => '0'));
begin

    address <= addr(4 downto 0);
    d_out <= locations(to_integer(unsigned(address)));

    process(clk, reset)
    begin
        if reset = '1' then
            locations <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if data_write = '1' then
                locations(to_integer(unsigned(address))) <= d_in;
            end if;
        end if;
    end process;
end behavior;