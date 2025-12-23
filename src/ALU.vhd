library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity ALU is
Port(x, y: in std_logic_vector(31 downto 0);
    
    --two input operands
    add_sub: in std_logic;
    -- 0 = add, 1 = sub
    
    logic_func: in std_logic_vector(1 downto 0);   
    -- 00 = AND, 01 = OR, 10 = XOR, 11 = NOR)

    func: in std_logic_vector(1 downto 0);
    -- 00 = LUI, 01 = SETLESS, 10 = ARITH, 11 = LOGIC

    output: out std_logic_vector(31 downto 0);
    
    overflow: out std_logic;

    zero: out std_logic);

end ALU;

architecture behavior of ALU is

    signal a, b     : signed(31 downto 0);
    signal sum_diff : signed(31 downto 0);

    --Overflow
    signal add_o : std_logic;
    Signal sub_o : std_logic;

    -- Results
    signal arith_r  : std_logic_vector(31 downto 0);
    signal logic_r  : std_logic_vector(31 downto 0);
    signal slt_r    : std_logic_vector(31 downto 0);
    signal slt_diff : signed(31 downto 0);
    signal lui_r    : std_logic_vector(31 downto 0);
    
    constant ZERO32 : signed(31 downto 0) := (others => '0');

begin
    a <= signed(x);
    b <= signed(y);

    --Arithmetic
    with add_sub select 
        sum_diff <= a + b when '0',
                    a - b when others;

    arith_r <= std_logic_vector(sum_diff);

    slt_diff <= a - b;
    slt_r    <= (31 downto 1 => '0') & slt_diff(31);

    -- Logic Function
    with logic_func select
    logic_r <=  (x and y)   when "00",
                (x or y)    when "01",
                (x xor y)   when "10",
                not(x or y) when others;

    -- LUI
    lui_r <= y;
    
    -- Output
    with func select
    output <=   lui_r   when "00",
                slt_r   when "01",
                arith_r when "10",
                logic_r when others;

    -- Flags

        -- Overflow
        add_o   <= '1' when (x(31) = y(31)) and (sum_diff(31) /= x(31)) else '0';
        sub_o   <= '1' when (x(31) /= y(31)) and (sum_diff(31) /= x(31)) else '0';
        overflow <= add_o when add_sub = '0' else sub_o;
    
        -- zero
        zero <= '1' when sum_diff = to_signed(0, 32) else '0';

end behavior;