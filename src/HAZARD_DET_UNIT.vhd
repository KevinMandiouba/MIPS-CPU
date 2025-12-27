library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity HAZARD_DET_UNIT is 
port(
    -- Next Instruction's operands
    rs          : in std_logic_vector(4 downto 0);
    rt          : in std_logic_vector(4 downto 0);

    -- Is instruction in EX lw?
    ex_rt       : in std_logic_vector(4 downto 0);
    ex_MemRead  : in std_logic;

    -- Controls for stall
    pc_write    : out std_logic;
    IF_ID_write : out std_logic;
    ID_EX_flush : out std_logic;
    id_uses_rt  : in std_logic
);
end HAZARD_DET_UNIT;

architecture behavior of HAZARD_DET_UNIT is
begin
    process(ex_MemRead, ex_rt, rs, rt, id_uses_rt)
        variable hazard : std_logic;
    begin
        if ex_MemRead = '1' and (ex_rt = rs or (id_uses_rt = '1' and ex_rt = rt)) and ex_rt /= "00000" then
            -- We have a lw hazard
            hazard := '1';
        else
            -- default
            hazard := '0';
        end if;

        -- Hazard handling
        if hazard = '1' then
            pc_write    <= '0';
            IF_ID_write <= '0';
            ID_EX_flush <= '1';
        else
            -- Defaults
            pc_write    <= '1';
            IF_ID_write <= '1';
            ID_EX_flush <= '0';
        end if;
    end process;
end behavior;
