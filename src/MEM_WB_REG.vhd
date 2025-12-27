library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MEM_WB_REG is
port(
    clk             : in  std_logic;
    reset           : in  std_logic;
    mem_data_out    : in  std_logic_vector(31 downto 0);
    mem_alu_out     : in  std_logic_vector(31 downto 0);
    mem_dest_reg    : in  std_logic_vector(4 downto 0);
    mem_reg_write   : in  std_logic;
    mem_reg_in_src  : in  std_logic;
    wb_data_out     : out std_logic_vector(31 downto 0);
    wb_alu_out      : out std_logic_vector(31 downto 0);
    wb_dest_reg     : out std_logic_vector(4 downto 0);
    wb_reg_write    : out std_logic;
    wb_reg_in_src   : out std_logic
);
end MEM_WB_REG;

architecture behavior of MEM_WB_REG is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            wb_data_out    <= (others => '0');
            wb_alu_out     <= (others => '0');
            wb_dest_reg    <= (others => '0');

            wb_reg_write   <= '0';
            wb_reg_in_src  <= '0';

        elsif rising_edge(clk) then
            wb_data_out    <= mem_data_out;
            wb_alu_out     <= mem_alu_out;
            wb_dest_reg    <= mem_dest_reg;

            wb_reg_write   <= mem_reg_write;
            wb_reg_in_src  <= mem_reg_in_src;
        end if;
    end process;
end behavior;
