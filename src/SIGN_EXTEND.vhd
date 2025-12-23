library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SIGN_EXTEND is
port(   imm             : in std_logic_vector(15 downto 0);
        func            : in std_logic_vector(1 downto 0);
        sign_ext_out    : out std_logic_vector(31 downto 0)
    );
end SIGN_EXTEND;

architecture behavior of SIGN_EXTEND is
begin

    process(func, imm)
    begin
        case func is
            --LUI
            when "00" =>
                sign_ext_out(31 downto 16) <= imm;
                sign_ext_out(15 downto 0) <= (others => '0');

            --SLI and ARITH
            when "01" | "10" =>
                sign_ext_out <= std_logic_vector(resize(signed(imm), 32));

            --Logical
            when "11" =>
                sign_ext_out <= std_logic_vector(resize(unsigned(imm), 32));

            when others =>
                sign_ext_out <= (others => '0');
        end case;
    end process;
end behavior;