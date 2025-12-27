library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity I_CACHE is
    port(
        pc    : in  std_logic_vector(31 downto 0);
        instr : out std_logic_vector(31 downto 0)
    );
end I_CACHE;

architecture behavior of I_CACHE is
    signal address : std_logic_vector(4 downto 0);
begin
    -- Your PC increments by +1, so pc(4 downto 0) is a word index
    address <= pc(4 downto 0);

    process(address)
    begin
        case address is

            ------------------------------------------------------------------
            -- 0: addi r2, r0, 0        (base address for lw)
            ------------------------------------------------------------------
            when "00000" =>
                instr <= "00100000000000100000000000000000";
                -- addi r2, r0, 0

            ------------------------------------------------------------------
            -- 1: addi r4, r0, 1        (some value to add)
            ------------------------------------------------------------------
            when "00001" =>
                instr <= "00100000000001000000000000000001";
                -- addi r4, r0, 1

            ------------------------------------------------------------------
            -- 2: lw r1, 0(r2)          (load-use producer)
            ------------------------------------------------------------------
            when "00010" =>
                instr <= "10001100010000010000000000000000";
                -- lw r1, 0(r2)

            ------------------------------------------------------------------
            -- 3: add r3, r1, r4        (immediate consumer -> MUST stall 1 cycle)
            ------------------------------------------------------------------
            when "00011" =>
                instr <= "00000000001001000001100000100000";
                -- add r3, r1, r4

            ------------------------------------------------------------------
            -- Default: NOP
            ------------------------------------------------------------------
            when others =>
                instr <= (others => '0');
                -- nop

        end case;
    end process;
end behavior;
