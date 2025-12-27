library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ID_EX_REG is 
port(
    clk             : in  std_logic;
    reset           : in  std_logic;
    id_pc_plus_1    : in  std_logic_vector(31 downto 0);
    ex_pc_plus_1    : out std_logic_vector(31 downto 0);
    id_rs, id_rt, id_rd : in  std_logic_vector(4 downto 0);
    ex_rs, ex_rt, ex_rd : out std_logic_vector(4 downto 0);
    id_out_a, id_out_b  : in  std_logic_vector(31 downto 0);
    ex_out_a, ex_out_b  : out std_logic_vector(31 downto 0);
    id_sign_extend      : in  std_logic_vector(31 downto 0);
    ex_sign_extend      : out std_logic_vector(31 downto 0);
    id_alu_src      : in  std_logic;
    id_reg_dst      : in  std_logic;
    id_reg_write    : in  std_logic;
    id_reg_in_src   : in  std_logic;
    id_data_write   : in  std_logic;
    ex_alu_src      : out std_logic;
    ex_reg_dst      : out std_logic;
    ex_reg_write    : out std_logic;
    ex_reg_in_src   : out std_logic;
    ex_data_write   : out std_logic;
    id_MemRead      : in std_logic;
    ex_MemRead      : out std_logic;
    ID_EX_flush     : in std_logic
);
end ID_EX_REG;

architecture behavior of ID_EX_REG is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            ex_pc_plus_1    <= (others => '0');
            ex_rs           <= (others => '0');
            ex_rt           <= (others => '0');
            ex_rd           <= (others => '0');
            ex_out_a        <= (others => '0');
            ex_out_b        <= (others => '0');
            ex_sign_extend  <= (others => '0');

            ex_alu_src      <= '0';
            ex_reg_dst      <= '0';
            ex_reg_write    <= '0';
            ex_reg_in_src   <= '0';
            ex_data_write   <= '0';
            ex_MemRead      <= '0';

        elsif rising_edge(clk) then
            ex_pc_plus_1    <= id_pc_plus_1;
            ex_rs           <= id_rs;
            ex_rt           <= id_rt;
            ex_rd           <= id_rd;
            ex_out_a        <= id_out_a;
            ex_out_b        <= id_out_b;
            ex_sign_extend  <= id_sign_extend;

            --Controls
            if ID_EX_flush = '1' then
                ex_reg_write    <= '0';
                ex_data_write   <= '0';
                ex_alu_src      <= '0';
                ex_reg_dst      <= '0';
                ex_reg_in_src   <= '0';
                ex_MemRead      <= '0';
    
            else
                ex_alu_src      <= id_alu_src;
                ex_reg_dst      <= id_reg_dst;
                ex_reg_write    <= id_reg_write;
                ex_reg_in_src   <= id_reg_in_src;
                ex_data_write   <= id_data_write;
                ex_MemRead      <= id_MemRead;
            end if;
        end if;
    end process;
end behavior;
