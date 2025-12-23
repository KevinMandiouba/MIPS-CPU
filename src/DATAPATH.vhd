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
    signal next_pc_sig      : std_logic_vector(31 downto 0);

    signal rs, rt, rd       : std_logic_vector(4 downto 0);
    signal rs_out, rt_out   : std_logic_vector(31 downto 0);
    signal instr_sig        : std_logic_vector(31 downto 0);
    signal ta               : std_logic_vector(25 downto 0);
    signal imm_sig          : std_logic_vector(15 downto 0);
    signal sign_ext_sig     : std_logic_vector(31 downto 0);
    signal alu_out          : std_logic_vector(31 downto 0);
    signal data_out         : std_logic_vector(31 downto 0);
    signal alu_y            : std_logic_vector(31 downto 0);
    signal reg_din          : std_logic_vector(31 downto 0);
    signal reg_write_addr   : std_logic_vector(4 downto 0);
begin

    -- For control unit debugging
    rs_path <= rs_out;
    rt_path <= rt_out;
    pc_path <= pc_sig;

    ta <= instr_sig(25 downto 0);
    rs <= instr_sig(25 downto 21);
    rt <= instr_sig(20 downto 16);
    rd <= instr_sig(15 downto 11);
    imm_sig <= instr_sig(15 downto 0);

    instruction <= instr_sig;
 
    alu_y <= rt_out when alu_src = '0' else sign_ext_sig;
 
    reg_din <= data_out when reg_in_src = '0' else alu_out;

    reg_write_addr <= rt when reg_dst = '0' else rd;

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
        rt              => rt_out,
        rs              => rs_out,
        pc              => pc_sig,
        target_address  => ta,
        branch_type     => branch_type,
        pc_sel          => pc_sel,
        next_pc         => next_pc_sig
    );

    -- I-Cache
    U_I_CACHE: entity work.I_CACHE
     port map(
        pc   => pc_sig,
        instr => instr_sig
    );

    -- Sign extend
    U_SIGN_EXTEND: entity work.SIGN_EXTEND
     port map(
        imm             => imm_sig,
        func            => func,
        sign_ext_out    => sign_ext_sig
    );

    -- Arithmethic Logic Unit
    U_ALU: entity work.ALU
     port map(
        x => rs_out,
        y => alu_y,
        add_sub => add_sub,
        logic_func => logic_func,
        func => func,
        output => alu_out,
        overflow => alu_overflow,
        zero => alu_zero
    );

    -- D-Cache(32x32 locations)
    U_D_CACHE : entity work.D_CACHE
    port map(
        clk        => clk,
        reset      => reset,
        data_write => data_write,
        addr       => alu_out,
        d_in       => rt_out,
        d_out      => data_out
    );

    -- Register File (32x32 registers)
    U_REGFILE: entity work.REGFILE
     port map(
        din             => reg_din,
        reset           => reset,
        clk             => clk,
        write           =>reg_write,
        read_a          => rs,
        read_b          => rt,
        write_address   => reg_write_addr,
        out_a           => rs_out,
        out_b           => rt_out
    );
end behavior;