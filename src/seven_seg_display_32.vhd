library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity seven_seg_display is
Port(
    clk     : in  std_logic;                      -- Basys3 100 MHz clock
    value   : in  std_logic_vector(4 downto 0);    -- 0..31
    display : out std_logic_vector(7 downto 0);    -- segments (active-low on Basys3)
    an      : out std_logic_vector(3 downto 0)     -- anodes  (active-low on Basys3)
);
end seven_seg_display;

architecture behavior of seven_seg_display is

    signal scan_cnt  : unsigned(15 downto 0) := (others => '0');
    signal scan_sel  : std_logic := '0';  -- 0 = ones, 1 = tens

    signal val_u     : unsigned(4 downto 0);
    signal ones_u    : unsigned(3 downto 0);
    signal tens_u    : unsigned(3 downto 0);
    signal digit_u   : unsigned(3 downto 0);

begin
    val_u <= unsigned(value);

    -------------------------------------------------------------------------
    -- 1) Split 0..31 into tens and ones (no division/mod; just ranges)
    -------------------------------------------------------------------------
    process(val_u)
    begin
        tens_u <= (others => '0');
        ones_u <= (others => '0');

        if val_u < 10 then
            tens_u <= to_unsigned(0, 4);
            ones_u <= resize(val_u, 4);
        elsif val_u < 20 then
            tens_u <= to_unsigned(1, 4);
            ones_u <= resize(val_u - 10, 4);
        elsif val_u < 30 then
            tens_u <= to_unsigned(2, 4);
            ones_u <= resize(val_u - 20, 4);
        else
            tens_u <= to_unsigned(3, 4);
            ones_u <= resize(val_u - 30, 4);
        end if;
    end process;

    -------------------------------------------------------------------------
    -- 2) Simple digit scan (time-multiplex)
    --    Use scan_cnt to create a slower toggle than 100 MHz.
    -------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            scan_cnt <= scan_cnt + 1;

            -- pick a bit to control scan speed (adjust if flicker)
            scan_sel <= scan_cnt(15);
        end if;
    end process;

    -------------------------------------------------------------------------
    -- 3) Choose which digit to show and which anode to enable
    -------------------------------------------------------------------------
    process(scan_sel, ones_u, tens_u)
    begin
        -- default: all digits off
        an <= "1111";

        if scan_sel = '0' then
            -- ONES on digit 0 (rightmost)
            an      <= "1110";
            digit_u <= ones_u;
        else
            -- TENS on digit 1
            an      <= "1101";
            digit_u <= tens_u;

            -- optional: blank leading zero
            if tens_u = 0 then
                an <= "1111"; -- tens off
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------
    -- 4) 7-seg decode (same table style as yours)
    -------------------------------------------------------------------------
    process(digit_u)
    begin
        case std_logic_vector(digit_u) is
            when "0000" => display <= not "11111100"; -- 0
            when "0001" => display <= not "01100000"; -- 1
            when "0010" => display <= not "11011010"; -- 2
            when "0011" => display <= not "11110010"; -- 3
            when "0100" => display <= not "01100110"; -- 4
            when "0101" => display <= not "10110110"; -- 5
            when "0110" => display <= not "10111110"; -- 6
            when "0111" => display <= not "11100000"; -- 7
            when "1000" => display <= not "11111110"; -- 8
            when "1001" => display <= not "11110110"; -- 9
            when "1010" => display <= not "11101110"; -- A
            when "1011" => display <= not "00111110"; -- b
            when "1100" => display <= not "10011100"; -- C
            when "1101" => display <= not "01111010"; -- d
            when "1110" => display <= not "10011110"; -- E
            when "1111" => display <= not "10001110"; -- F
            when others => display <= (others => '1'); -- all off
        end case;
    end process;

end behavior;
