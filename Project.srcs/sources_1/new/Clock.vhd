library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Clock is
    Port (
        clk_out : out std_logic  -- Generated clock signal
    );
end Clock;

architecture Behavioral of Clock is
    signal clk_signal : std_logic := '0';
    constant period : time := 10 ns;  -- Define the clock period (adjust as needed)
begin
    -- Clock generation process
    process
    begin
        clk_signal <= not clk_signal;  -- Toggle clock signal
        clk_out <= clk_signal;
        wait for period / 2;  -- Wait for half the clock period
    end process;
end Behavioral;
