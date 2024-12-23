library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DPU_8bit is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        a_in     : in  std_logic_vector(7 downto 0);
        b_in     : in  std_logic_vector(7 downto 0);
        acc_out  : out std_logic_vector(15 downto 0);
        a_out    : out std_logic_vector(7 downto 0);
        b_out    : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of DPU_8bit is
    signal acc : unsigned(15 downto 0) := (others => '0');
    signal a_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal b_reg : std_logic_vector(7 downto 0) := (others => '0');
begin
    a_reg <= a_in;
    b_reg <= b_in;

    process(clk, rst)
    begin
        if rst = '1' then
            acc_out <= (others => '0');
            a_out <= (others => '0');
            b_out <= (others => '0');
            acc <= (others => '0');
        elsif rising_edge(clk) then
            acc <= unsigned(a_reg) * unsigned(b_reg) + acc;
            acc_out <= std_logic_vector(unsigned(a_reg) * unsigned(b_reg) + acc);
            a_out <= a_reg;
            b_out <= b_reg;
        end if;
    end process;
end architecture;