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
    signal pc_sig               : std_logic_vector(31 downto 0);
    signal pc_IF_ID             : std_logic_vector(31 downto 0);
    signal pc_ID_EX             : std_logic_vector(31 downto 0);

    signal next_pc_sig          : std_logic_vector(31 downto 0);

    signal rs, rt, rd           : std_logic_vector(4 downto 0);
    signal ex_rs, ex_rt, ex_rd  : std_logic_vector(4 downto 0);

    signal id_out_a, id_out_b   : std_logic_vector(31 downto 0);
    signal ex_out_a, ex_out_b   : std_logic_vector(31 downto 0);

    signal mem_alu_out          : std_logic_vector(31 downto 0);
    signal mem_store_data       : std_logic_vector(31 downto 0);
    signal mem_dest_reg         : std_logic_vector(4 downto 0);

    signal mem_mem_write        : std_logic;
    signal mem_reg_write        : std_logic;
    signal mem_reg_in_src       : std_logic;

    signal ex_alu_src           : std_logic;
    signal ex_reg_dst           : std_logic;
    signal ex_reg_write         : std_logic;
    signal ex_reg_in_src        : std_logic;
    signal ex_data_write        : std_logic;

    signal ex_dest_reg          : std_logic_vector(4 downto 0);

    signal instr_cache          : std_logic_vector(31 downto 0);
    signal instr_IF_ID          : std_logic_vector(31 downto 0);

    signal wb_data_out          : std_logic_vector(31 downto 0);
    signal wb_alu_out           : std_logic_vector(31 downto 0);
    signal wb_dest_reg          : std_logic_vector(4 downto 0);
    signal wb_reg_write         : std_logic;
    signal wb_reg_in_src        : std_logic;

    signal ta                   : std_logic_vector(25 downto 0);
    signal imm_sig              : std_logic_vector(15 downto 0);
    signal id_sign_extend       : std_logic_vector(31 downto 0);
    signal ex_sign_extend       : std_logic_vector(31 downto 0);
    signal alu_out              : std_logic_vector(31 downto 0);
    signal data_out             : std_logic_vector(31 downto 0);
    signal alu_y                : std_logic_vector(31 downto 0);
    signal reg_din              : std_logic_vector(31 downto 0);
    signal reg_write_addr       : std_logic_vector(4 downto 0);

    signal ForwardA, ForwardB   : std_logic_vector(1 downto 0);
    signal for_alu_x, for_alu_y : std_logic_vector(31 downto 0);
    signal mem_forward_val      : std_logic_vector(31 downto 0);

    signal id_MemRead           : std_logic;
    signal ex_MemRead           : std_logic;
    signal IF_ID_write          : std_logic;
    signal ID_EX_flush          : std_logic;
    signal pc_write             : std_logic;
    signal id_uses_rt           : std_logic;
    signal id_opcode            : std_logic_vector(5 downto 0);

    signal id_pc_redirect      : std_logic;
    signal id_redirect_target  : std_logic_vector(31 downto 0);

    signal if_pc_plus_1         : std_logic_vector(31 downto 0);
    signal if_next_pc           : std_logic_vector(31 downto 0);

    signal id_flush_if_id       : std_logic;

    signal pc_write_final       : std_logic;
    signal ex_add_sub           : std_logic;
    signal ex_logic_func        : std_logic_vector(1 downto 0);
    signal ex_func              : std_logic_vector(1 downto 0);

    signal id_rs_val            : std_logic_vector(31 downto 0);
    signal id_rt_val            : std_logic_vector(31 downto 0);
    signal id_pc_redirect_valid : std_logic;

begin

    -- For control unit debugging
    rs_path <= id_rs_val;
    rt_path <= id_rt_val;
    pc_path <= pc_sig;

    ta <= instr_IF_ID(25 downto 0);
    rs <= instr_IF_ID(25 downto 21);
    rt <= instr_IF_ID(20 downto 16);
    rd <= instr_IF_ID(15 downto 11);
    imm_sig <= instr_IF_ID(15 downto 0);
    id_opcode <= instr_IF_ID(31 downto 26);

    instruction <= instr_IF_ID;
 
    alu_y <= for_alu_y when ex_alu_src = '0' else ex_sign_extend;     

    reg_din <= wb_data_out when wb_reg_in_src = '0' else wb_alu_out;

    reg_write_addr <= wb_dest_reg;

    ex_dest_reg <= ex_rt when ex_reg_dst = '0' else ex_rd;

    -- Stalling
    id_MemRead <= (not reg_in_src) and reg_write;

    id_uses_rt <= '1' when (id_opcode = "000000") or    -- R-type
                        (id_opcode = "101011") or       -- sw
                        (id_opcode = "000100") or       -- beq
                        (id_opcode = "000101")          -- bne
                else '0';

    -- Forwarding
    mem_forward_val <= data_out when mem_reg_in_src='0' else mem_alu_out;

    with ForwardA select -- Rs
    for_alu_x <=
        reg_din         when "01",      -- Forward from wb
        mem_forward_val when "10",      -- Forward from mem
        ex_out_a        when others;    -- No forwarding     
        
    with ForwardB select -- Rt
    for_alu_y <=
        reg_din         when "01",      -- Forward from wb
        mem_forward_val when "10",      -- Forward from mem
        ex_out_b        when others;    -- No forwarding 

    -- Control Hazard
    -- if stage
    if_pc_plus_1 <= std_logic_vector(unsigned(pc_sig) + 1);

    if_next_pc <= id_redirect_target when id_pc_redirect_valid = '1'
                else if_pc_plus_1;

    next_pc_sig <= if_next_pc;

    -- id stage
    id_pc_redirect_valid <= id_pc_redirect and IF_ID_write; -- or `and pc_write`

    id_flush_if_id <= id_pc_redirect_valid;
    pc_write_final <= pc_write;  -- no OR here

    -- Forward to ID stage for branch/JR compare
    id_rs_val <= alu_out when (ex_reg_write = '1' and ex_reg_in_src = '1' and ex_dest_reg /= "00000" and ex_dest_reg = rs) else
                mem_forward_val when (mem_reg_write = '1' and mem_dest_reg /= "00000" and mem_dest_reg = rs) else
                reg_din         when (wb_reg_write  = '1' and wb_dest_reg  /= "00000" and wb_dest_reg  = rs) else
                id_out_a;

    id_rt_val <= alu_out when (ex_reg_write = '1' and ex_reg_in_src = '1' and ex_dest_reg /= "00000" and ex_dest_reg = rt) else
                mem_forward_val when (mem_reg_write = '1' and mem_dest_reg /= "00000" and mem_dest_reg = rt) else
                reg_din         when (wb_reg_write  = '1' and wb_dest_reg  /= "00000" and wb_dest_reg  = rt) else
                id_out_b;

    -- Program Counter (PC)
    U_PC_REG: entity work.PC_REG
     port map(
        clk     => clk,
        reset   => reset,
        next_pc => next_pc_sig,
        pc      => pc_sig,
        pc_write=> pc_write_final
    );

    -- Next Address Unit
    U_NEXT_ADDRESS: entity work.NEXT_ADDRESS
     port map(
        rt              => id_rt_val,
        rs              => id_rs_val,
        pc              => pc_IF_ID,
        target_address  => ta,
        branch_type     => branch_type,
        pc_sel          => pc_sel,
        next_pc         => open,
        pc_redirect     => id_pc_redirect,
        redirect_target => id_redirect_target

    );

    -- I-Cache
    U_I_CACHE: entity work.I_CACHE
     port map(
        pc      => pc_sig,
        instr   => instr_cache
    );

    -- IF/ID Register
    U_IF_ID_REG: entity work.IF_ID_REG
     port map(
        clk         => clk,
        reset       => reset,
        pc          => pc_sig,
        instr_in    => instr_cache,
        instr_out   => instr_IF_ID,
        pc_plus_1   => pc_IF_ID,
        IF_ID_write => IF_ID_write,
        flush => id_flush_if_id 
     );

    -- Hazard Detection Unit
    U_HAZARD_DET_UNIT: entity work.HAZARD_DET_UNIT
     port map(
        rs          => rs,
        rt          => rt,
        ex_rt       => ex_rt,
        ex_MemRead  => ex_MemRead,
        pc_write    => pc_write,
        IF_ID_write => IF_ID_write,
        ID_EX_flush => ID_EX_flush,
        id_uses_rt  => id_uses_rt
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
        ex_data_write   => ex_data_write,
        id_MemRead      => id_MemRead,
        ex_MemRead      => ex_MemRead,
        ID_EX_flush     => ID_EX_flush,
        id_add_sub      => add_sub, 
        id_logic_func   => logic_func, 
        id_func         => func,
        ex_add_sub      => ex_add_sub, 
        ex_logic_func   => ex_logic_func, 
        ex_func         => ex_func
     );

    -- Arithmethic Logic Unit
    U_ALU: entity work.ALU
     port map(
        x           => for_alu_x,
        y           => alu_y,
        add_sub     => ex_add_sub,
        logic_func  => ex_logic_func,
        func        => ex_func,
        output      => alu_out,
        overflow    => alu_overflow,
        zero        => alu_zero
    );

    -- Forwarding Unit
    U_FORWARDING_UNIT: entity work.FORWARDING_UNIT
     port map(
        -- Rs and Rt in next instruction
        ex_rs           => ex_rs,
        ex_rt           => ex_rt,

        -- Rd from current instruction
        mem_dest_reg    => mem_dest_reg,
        wb_dest_reg     => wb_dest_reg,

        -- RegWrite status
        mem_reg_write   => mem_reg_write,
        wb_reg_write    => wb_reg_write,

        -- Forwarding
        ForwardA        => ForwardA,
        ForwardB        => ForwardB
    );

    -- EX_MEM Register
     U_EX_MEM_REG: entity work.EX_MEM_REG
     port map(
        clk             => clk,
        reset           => reset,
        ex_alu_out      => alu_out,
        mem_alu_out     => mem_alu_out,
        ex_store_data   => for_alu_y,
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