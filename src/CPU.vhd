library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_signed.all; 

entity CPU is 
port( 
    reset : in std_logic; 
    clk : in std_logic; 
    rs_out, rt_out : out std_logic_vector(3 downto 0); 
    --output ports from register file 
    pc_out : out std_logic_vector(3 downto 0); --pc reg 
    overflow, zero : out std_logic 
); 
end CPU;

architecture behavior of CPU is
    signal opcode           : std_logic_vector(5 downto 0);
    signal funct             : std_logic_vector(5 downto 0);

    signal pc_sig           : std_logic_vector(31 downto 0);
    signal rs_sig, rt_sig   : std_logic_vector(31 downto 0);
    signal pc_sel           : std_logic_vector(1 downto 0);
    signal branch_type      : std_logic_vector(1 downto 0);
    signal alu_src          : std_logic;
    signal reg_dst          : std_logic;
    signal reg_write        : std_logic;
    signal reg_in_src       : std_logic;
    signal data_write       : std_logic;
    signal add_sub          : std_logic;
    signal logic_func       : std_logic_vector(1 downto 0);
    signal func             : std_logic_vector(1 downto 0);
    signal instruction      : std_logic_vector(31 downto 0);
begin

    rs_out  <= rs_sig(3 downto 0);
    rt_out  <= rt_sig(3 downto 0);
    pc_out  <= pc_sig(3 downto 0);

    opcode  <= instruction(31 downto 26);
    funct   <= instruction(5 downto 0); 

    -- Control Unit
    process(opcode, funct)
    begin
        reg_write   <= '0';
        reg_dst     <= '0';
        reg_in_src  <= '0';
        alu_src     <= '0';
        add_sub     <= '0';
        data_write  <= '0';
        logic_func  <= "00";
        func        <= "00";
        branch_type <= "00";
        pc_sel      <= "00";

        -- What is commented out is don't care
        case opcode is

            -- R-type instructions
            when "000000" =>
                case funct is

                    -- ADD
                    when "100000" =>
                    reg_write   <= '1';
                    reg_dst     <= '1';
                    reg_in_src  <= '1';
                    alu_src     <= '0';
                    add_sub     <= '0';
                    data_write  <= '0';
                    -- logic_func  <= "00";
                    func        <= "10";
                    branch_type <= "00";
                    pc_sel      <= "00";

                    -- SUB
                    when "100010" =>
                    reg_write   <= '1';
                    reg_dst     <= '1';
                    reg_in_src  <= '1';
                    alu_src     <= '0';
                    add_sub     <= '1';
                    data_write  <= '0';
                    -- logic_func  <= "00";
                    func        <= "10";
                    branch_type <= "00";
                    pc_sel      <= "00";

                    -- SLT
                    when "101010" =>
                    reg_write   <= '1';
                    reg_dst     <= '1';
                    reg_in_src  <= '1';
                    alu_src     <= '0';
                    -- add_sub     <= '1';
                    data_write  <= '0';
                    -- logic_func  <= "00";
                    func        <= "01";
                    branch_type <= "00";
                    pc_sel      <= "00";

                    -- AND
                    when "100100" =>
                    reg_write   <= '1';
                    reg_dst     <= '1';
                    reg_in_src  <= '1';
                    alu_src     <= '0';
                    -- add_sub     <= '1';
                    data_write  <= '0';
                    logic_func  <= "00";
                    func        <= "11";
                    branch_type <= "00";
                    pc_sel      <= "00";

                    -- OR
                    when "100101" =>
                    reg_write   <= '1';
                    reg_dst     <= '1';
                    reg_in_src  <= '1';
                    alu_src     <= '0';
                    -- add_sub     <= '1';
                    data_write  <= '0';
                    logic_func  <= "01";
                    func        <= "11";
                    branch_type <= "00";
                    pc_sel      <= "00";

                    -- XOR
                    when "100110" =>
                    reg_write   <= '1';
                    reg_dst     <= '1';
                    reg_in_src  <= '1';
                    alu_src     <= '0';
                    -- add_sub     <= '1';
                    data_write  <= '0';
                    logic_func  <= "10";
                    func        <= "11";
                    branch_type <= "00";
                    pc_sel      <= "00";

                    -- NOR
                    when "100111" =>
                    reg_write   <= '1';
                    reg_dst     <= '1';
                    reg_in_src  <= '1';
                    alu_src     <= '0';
                    -- add_sub     <= '1';
                    data_write  <= '0';
                    logic_func  <= "11";
                    func        <= "11";
                    branch_type <= "00";
                    pc_sel      <= "00";

                    -- Jump rs
                    when "001000" =>
                    reg_write   <= '0';
                    -- reg_dst     <= '1';
                    -- reg_in_src  <= '1';
                    -- alu_src     <= '0';
                    -- add_sub     <= '1';
                    data_write  <= '0';
                    -- logic_func  <= "10";
                    -- func        <= "11";
                    -- branch_type <= "00";
                    pc_sel      <= "10";

                    when others =>
                    null;
                end case;
            
            -- I-type instructions
            when "001000" => -- ADDI
                reg_write   <= '1';
                reg_dst     <= '0';
                reg_in_src  <= '1';
                alu_src     <= '1';
                add_sub     <= '0';
                data_write  <= '0';
                logic_func  <= "00";
                func        <= "10";
                branch_type <= "00";
                pc_sel      <= "00";

            when "001010" => -- SLTI
                reg_write   <= '1';
                reg_dst     <= '0';
                reg_in_src  <= '1';
                alu_src     <= '1';
                -- add_sub     <= '0';
                data_write  <= '0';
                -- logic_func  <= "00";
                func        <= "01";
                branch_type <= "00";
                pc_sel      <= "00";

            when "001100" => -- ANDI
                reg_write   <= '1';
                reg_dst     <= '0';
                reg_in_src  <= '1';
                alu_src     <= '1';
                -- add_sub     <= '0';
                data_write  <= '0';
                logic_func  <= "00";
                func        <= "11";
                branch_type <= "00";
                pc_sel      <= "00";

            when "001101" => -- ORI
                reg_write   <= '1';
                reg_dst     <= '0';
                reg_in_src  <= '1';
                alu_src     <= '1';
                -- add_sub     <= '0';
                data_write  <= '0';
                logic_func  <= "01";
                func        <= "11";
                branch_type <= "00";
                pc_sel      <= "00";

            when "001110" => -- XORI
                reg_write   <= '1';
                reg_dst     <= '0';
                reg_in_src  <= '1';
                alu_src     <= '1';
                -- add_sub     <= '0';
                data_write  <= '0';
                logic_func  <= "10";
                func        <= "11";
                branch_type <= "00";
                pc_sel      <= "00";

            when "001111" => -- LUI
                reg_write   <= '1';
                reg_dst     <= '0';
                reg_in_src  <= '1';
                alu_src     <= '1';
                -- add_sub     <= '0';
                data_write  <= '0';
                -- logic_func  <= "00";
                func        <= "00";
                branch_type <= "00";
                pc_sel      <= "00";

            when "100011" => -- Load (lw)
                reg_write   <= '1';
                reg_dst     <= '0';
                reg_in_src  <= '0';
                alu_src     <= '1';
                add_sub     <= '0';
                data_write  <= '0';
                -- logic_func  <= "00";
                func        <= "10";
                branch_type <= "00";
                pc_sel      <= "00";

            when "101011" => -- Store (sw)
                reg_write   <= '0';
                -- reg_dst     <= '0';
                -- reg_in_src  <= '1';
                alu_src     <= '1';
                add_sub     <= '0';
                data_write  <= '1';
                -- logic_func  <= "00";
                func        <= "10";
                branch_type <= "00";
                pc_sel      <= "00";

            -- J-type instructions
            when "000010" => -- Jump target address (J)
                reg_write   <= '0';
                -- reg_dst     <= '0';
                -- reg_in_src  <= '0';
                -- alu_src     <= '1';
                -- add_sub     <= '0';
                data_write  <= '0';
                -- logic_func  <= "00";
                -- func        <= "10";
                -- branch_type <= "00";
                pc_sel      <= "01";

            when "000001" => -- BLTZ
                reg_write   <= '0';
                -- reg_dst     <= '0';
                -- reg_in_src  <= '0';
                -- alu_src     <= '1';
                -- add_sub     <= '0';
                data_write  <= '0';
                -- logic_func  <= "00";
                -- func        <= "10";
                branch_type <= "11";
                pc_sel      <= "00";

            when "000100" => -- BEQ
                reg_write   <= '0';
                -- reg_dst     <= '0';
                -- reg_in_src  <= '0';
                -- alu_src     <= '1';
                -- add_sub     <= '0';
                data_write  <= '0';
                -- logic_func  <= "00";
                -- func        <= "10";
                branch_type <= "01";
                pc_sel      <= "00";

            when "000101" => -- BNE
                reg_write   <= '0';
                -- reg_dst     <= '0';
                -- reg_in_src  <= '0';
                -- alu_src     <= '1';
                -- add_sub     <= '0';
                data_write  <= '0';
                -- logic_func  <= "00";
                -- func        <= "10";
                branch_type <= "10";
                pc_sel      <= "00";
            when others =>
            null;
        end case;
    end process;

    -- Datapath
    U_DATAPATH : entity work.DATAPATH
    port map(
        clk         => clk,
        reset       => reset,
        pc_sel      => pc_sel,
        branch_type => branch_type,
        alu_src     => alu_src,
        reg_dst     => reg_dst,
        reg_write   => reg_write,
        reg_in_src  => reg_in_src,
        data_write  => data_write,
        add_sub     => add_sub,
        logic_func  => logic_func,
        func        => func,
        instruction => instruction,
        alu_zero    => zero,
        alu_overflow=> overflow,
        rs_path     => rs_sig,
        rt_path     => rt_sig,
        pc_path     => pc_sig
    );

end behavior;