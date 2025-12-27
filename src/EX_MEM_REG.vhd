library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity EX_MEM_REG is 
port(
    clk             : in  std_logic;
    reset           : in  std_logic;
    ex_alu_out       : in  std_logic_vector(31 downto 0);
    mem_alu_out      : out std_logic_vector(31 downto 0);
    ex_store_data    : in  std_logic_vector(31 downto 0);
    mem_store_data   : out std_logic_vector(31 downto 0);
    ex_dest_reg      : in  std_logic_vector(4 downto 0);
    mem_dest_reg     : out std_logic_vector(4 downto 0);
    ex_mem_write     : in  std_logic;
    mem_mem_write    : out std_logic;
    ex_reg_write     : in  std_logic;
    mem_reg_write    : out std_logic;
    ex_reg_in_src    : in  std_logic;
    mem_reg_in_src   : out std_logic
);
end EX_MEM_REG;

architecture behavior of EX_MEM_REG is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            mem_alu_out      <= (others => '0');
            mem_store_data   <= (others => '0');
            mem_dest_reg     <= (others => '0');

            mem_mem_write    <= '0';
            mem_reg_write    <= '0';
            mem_reg_in_src   <= '0';

        elsif rising_edge(clk) then
            mem_alu_out      <= ex_alu_out;
            mem_store_data   <= ex_store_data;
            mem_dest_reg     <= ex_dest_reg;

            mem_mem_write    <= ex_mem_write;
            mem_reg_write    <= ex_reg_write;
            mem_reg_in_src   <= ex_reg_in_src;
        end if;
    end process;
end behavior;
