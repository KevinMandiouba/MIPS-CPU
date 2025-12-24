library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity DATAPATH is
port(
    clk         : in std_logic;
    reset       : in std_logic;
    pc_sel      : in std_logic_vector(1 downto 0);
    branch_type : in std_logic_vector(1 downto 0);
    alu_src     : in std_logic;
    reg_dst     : in std_logic;
    reg_write   : in std_logic;
    reg_in_src  : in std_logic;
    data_write  : in std_logic;
    add_sub     : in std_logic;
    logic_func  : in std_logic_vector(1 downto 0);
    func        : in std_logic_vector(1 downto 0);
    instruction : out std_logic_vector(31 downto 0);
    alu_zero    : out std_logic;
    alu_overflow: out std_logic;
    rs_path     : out std_logic_vector(31 downto 0);
    rt_path     : out std_logic_vector(31 downto 0);
    pc_path     : out std_logic_vector(31 downto 0)
);
end DATAPATH;

architecture behavior of DATAPATH is
    signal pc_sig           : std_logic_vector(31 downto 0);
    signal pc_IF_ID         : std_logic_vector(31 downto 0);
    signal pc_ID_EX         : std_logic_vector(31 downto 0);
    --signal pc_EX_MEM        : std_logic_vector(31 downto 0);



    signal next_pc_sig      : std_logic_vector(31 downto 0);

    signal rs, rt, rd               : std_logic_vector(4 downto 0);
    signal ex_rs, ex_rt, ex_rd      : std_logic_vector(4 downto 0);

    signal id_out_a, id_out_b   : std_logic_vector(31 downto 0);
    signal ex_out_a, ex_out_b   : std_logic_vector(31 downto 0);

    signal mem_alu_out     : std_logic_vector(31 downto 0);
    signal mem_store_data  : std_logic_vector(31 downto 0);
    signal mem_dest_reg    : std_logic_vector(4 downto 0);

    signal mem_mem_write   : std_logic;
    signal mem_reg_write   : std_logic;
    signal mem_reg_in_src  : std_logic;

    signal ex_alu_src     : std_logic;
    signal ex_reg_dst     : std_logic;
    signal ex_reg_write   : std_logic;
    signal ex_reg_in_src  : std_logic;
    signal ex_data_write  : std_logic;

    signal ex_dest_reg     : std_logic_vector(4 downto 0);

    signal instr_cache      : std_logic_vector(31 downto 0);
    signal instr_IF_ID      : std_logic_vector(31 downto 0);

    signal wb_data_out    : std_logic_vector(31 downto 0);
    signal wb_alu_out     : std_logic_vector(31 downto 0);
    signal wb_dest_reg    : std_logic_vector(4 downto 0);
    signal wb_reg_write   : std_logic;
    signal wb_reg_in_src  : std_logic;

    signal ta               : std_logic_vector(25 downto 0);
    signal imm_sig          : std_logic_vector(15 downto 0);
    signal id_sign_extend     : std_logic_vector(31 downto 0);
    signal ex_sign_extend     : std_logic_vector(31 downto 0);
    signal alu_out          : std_logic_vector(31 downto 0);
    signal data_out         : std_logic_vector(31 downto 0);
    signal alu_y            : std_logic_vector(31 downto 0);
    signal reg_din          : std_logic_vector(31 downto 0);
    signal reg_write_addr   : std_logic_vector(4 downto 0);
begin

    -- For control unit debugging
    rs_path <= id_out_a;
    rt_path <= id_out_b;
    pc_path <= pc_IF_ID;

    ta <= instr_IF_ID(25 downto 0);
    rs <= instr_IF_ID(25 downto 21);
    rt <= instr_IF_ID(20 downto 16);
    rd <= instr_IF_ID(15 downto 11);
    imm_sig <= instr_IF_ID(15 downto 0);

    instruction <= instr_IF_ID;
 
    alu_y <= ex_out_b when ex_alu_src = '0' else ex_sign_extend;     

    reg_din        <= wb_data_out when wb_reg_in_src = '0' else wb_alu_out;

    reg_write_addr <= wb_dest_reg;

    ex_dest_reg <= ex_rt when ex_reg_dst = '0' else ex_rd;


    -- Program Counter (PC)
    U_PC_REG: entity work.PC_REG
     port map(
        clk     => clk,
        reset   => reset,
        next_pc => next_pc_sig,
        pc      => pc_sig
    );

    -- Next Address Unit
    U_NEXT_ADDRESS: entity work.NEXT_ADDRESS
     port map(
        rt              => id_out_b,
        rs              => id_out_a,
        pc              => pc_IF_ID,
        target_address  => ta,
        branch_type     => branch_type,
        pc_sel          => pc_sel,
        next_pc         => next_pc_sig
    );

    -- I-Cache
    U_I_CACHE: entity work.I_CACHE
     port map(
        pc   => pc_sig,
        instr => instr_cache
    );

    -- IF/ID Register
    U_IF_ID_REG: entity work.IF_ID_REG
     port map(
        clk         => clk,
        reset       => reset,
        pc          => pc_sig,
        instr_in    => instr_cache,
        instr_out   => instr_IF_ID,
        pc_plus_1   => pc_IF_ID
     );

    -- Sign extend
    U_SIGN_EXTEND: entity work.SIGN_EXTEND
     port map(
        imm             => imm_sig,
        func            => func,
        sign_ext_out    => id_sign_extend
    );

    -- ID/EX Register
    U_ID_EX_REG: entity work.ID_EX_REG
     port map(
        clk             => clk,
        reset           => reset,
        id_pc_plus_1    => pc_IF_ID,
        ex_pc_plus_1    => pc_ID_EX,
        id_rs           => rs,
        id_rt           => rt,
        id_rd           => rd,
        ex_rs           => ex_rs,
        ex_rt           => ex_rt,
        ex_rd           => ex_rd,
        id_out_a        => id_out_a,
        id_out_b        => id_out_b,
        ex_out_a        => ex_out_a,
        ex_out_b        => ex_out_b,
        id_sign_extend  => id_sign_extend,
        ex_sign_extend  => ex_sign_extend,
        id_alu_src      => alu_src,
        id_reg_dst      => reg_dst,
        id_reg_write    => reg_write,
        id_reg_in_src   => reg_in_src,
        id_data_write   => data_write,
        ex_alu_src      => ex_alu_src,
        ex_reg_dst      => ex_reg_dst,
        ex_reg_write    => ex_reg_write,
        ex_reg_in_src   => ex_reg_in_src,
        ex_data_write   => ex_data_write

     );

    -- Arithmethic Logic Unit
    U_ALU: entity work.ALU
     port map(
        x => ex_out_a,
        y => alu_y,
        add_sub => add_sub,
        logic_func => logic_func,
        func => func,
        output => alu_out,
        overflow => alu_overflow,
        zero => alu_zero
    );

    -- EX_MEM Register
     U_EX_MEM_REG: entity work.EX_MEM_REG
     port map(
        clk             => clk,
        reset           => reset,
        ex_alu_out      => alu_out,
        mem_alu_out     => mem_alu_out,
        ex_store_data   => ex_out_b,
        mem_store_data  => mem_store_data,
        ex_dest_reg     => ex_dest_reg,
        mem_dest_reg    => mem_dest_reg,
        ex_mem_write    => ex_data_write,
        mem_mem_write   => mem_mem_write,
        ex_reg_write    => ex_reg_write,
        mem_reg_write   => mem_reg_write,
        ex_reg_in_src   => ex_reg_in_src,
        mem_reg_in_src  => mem_reg_in_src
    );

    -- D-Cache(32x32 locations)
    U_D_CACHE : entity work.D_CACHE
    port map(
        clk         => clk,
        reset       => reset,
        data_write  => mem_mem_write,
        addr        => mem_alu_out,
        d_in        => mem_store_data,
        d_out       => data_out
    );

    U_MEM_WB_REG: entity work.MEM_WB_REG
     port map(
        clk            => clk,
        reset          => reset,

        mem_data_out   => data_out,
        mem_alu_out    => mem_alu_out,
        mem_dest_reg   => mem_dest_reg,

        mem_reg_write  => mem_reg_write,
        mem_reg_in_src => mem_reg_in_src,

        wb_data_out    => wb_data_out,
        wb_alu_out     => wb_alu_out,
        wb_dest_reg    => wb_dest_reg,

        wb_reg_write   => wb_reg_write,
        wb_reg_in_src  => wb_reg_in_src
    );


    -- Register File (32x32 registers)
    U_REGFILE: entity work.REGFILE
     port map(
        din             => reg_din,
        reset           => reset,
        clk             => clk,
        write           => wb_reg_write,
        read_a          => rs,
        read_b          => rt,
        write_address   => reg_write_addr,
        out_a           => id_out_a,
        out_b           => id_out_b
    );
end behavior;