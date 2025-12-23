library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity NEXT_ADDRESS is
port(   rt, rs          : in std_logic_vector(31 downto 0);
        -- two register inputs
        pc              : in std_logic_vector(31 downto 0);
        target_address  : in std_logic_vector(25 downto 0);
        branch_type     : in std_logic_vector(1 downto 0);
        pc_sel          : in std_logic_vector(1 downto 0);
        next_pc         : out std_logic_vector(31 downto 0));
end NEXT_ADDRESS;

architecture behavior of NEXT_ADDRESS is

    signal offset       :  std_logic_vector(15 downto 0);
    signal sign_extend  :  signed(31 downto 0);
    signal jump_address :  std_logic_vector(31 downto 0);
    signal no_jump      :  std_logic_vector(31 downto 0);
    signal branching    :  signed(31 downto 0);
    signal reg_comp     :  std_logic;
    signal slt          :  std_logic;
begin

    -- Sign extend
    offset <= target_address(15 downto 0);
    sign_extend <= resize(signed(offset), 32);

    -- COMP rs, rt (BEQ = 1, BNE = 0)
    reg_comp <= '1' when (rs = rt) else '0';

    -- SLT (if rs < 0, slt = 1)
    slt <= '1' when (signed(rs) < 0) else '0';

    -- No Unconditioanl Jump
    process(branch_type, reg_comp, slt, sign_extend)
    begin 
        case branch_type is
            when "00" => -- No Branch
                branching <= to_signed(1, 32);

            when "01" => -- BEQ
                if (reg_comp = '0') then branching <= to_signed(1, 32);
                else branching <= sign_extend + to_signed(1, 32);
                end if;

            when "10" => -- BNE
                if (reg_comp = '1') then branching <= to_signed(1, 32);
                else branching <= sign_extend + to_signed(1, 32);
                end if;

            when others => -- BLTZ
                if (slt = '0') then branching <= to_signed(1, 32);
                else branching <= sign_extend + to_signed(1, 32);
                end if;
        end case;
    end process;

    no_jump <= std_logic_vector(signed(pc) + branching);

    -- Jump to target address
    jump_address <= (5 downto 0 => '0') & target_address;

    -- PC_sel functionality
    with pc_sel select
    next_pc <=  no_jump         when "00",
                jump_address    when "01",
                rs              when "10",
                (others => '0') when others;
end behavior;