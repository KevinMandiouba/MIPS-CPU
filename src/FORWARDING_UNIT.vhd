library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FORWARDING_UNIT is 
port(
    -- Rs and Rt in next instruction
    ex_rs, ex_rt                    : in std_logic_vector(4 downto 0);

    -- Rd from current instruction
    mem_dest_reg, wb_dest_reg       : in std_logic_vector(4 downto 0);

    -- RegWrite status
    mem_reg_write, wb_reg_write     : in std_logic;

    -- Forwarding
    ForwardA, ForwardB              : out std_logic_vector(1 downto 0)
);
end FORWARDING_UNIT;

architecture behavior of FORWARDING_UNIT is
begin
    process(ex_rs, ex_rt, mem_dest_reg, wb_dest_reg, mem_reg_write, wb_reg_write)
    begin

        -- Forward A (Rs forwarded)
        if mem_reg_write = '1' and mem_dest_reg = ex_rs and mem_dest_reg /= "00000" then
            ForwardA <= "10";
        elsif wb_reg_write = '1' and wb_dest_reg = ex_rs and wb_dest_reg /= "00000" then
            ForwardA <= "01";
        else
            ForwardA <= "00";
        end if;

        -- Forward B (Rt forwarded)
        if mem_reg_write = '1' and mem_dest_reg = ex_rt and mem_dest_reg /= "00000" then
            ForwardB <= "10";
        elsif wb_reg_write = '1' and wb_dest_reg = ex_rt and wb_dest_reg /= "00000" then
            ForwardB <= "01";
        else
            ForwardB <= "00";
        end if;
    end process;
end behavior;
