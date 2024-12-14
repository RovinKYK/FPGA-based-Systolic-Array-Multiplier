library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DPU is
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        a_in     : in  std_logic_vector(2 downto 0); -- Element from matrix A
        b_in     : in  std_logic_vector(2 downto 0); -- Element from matrix B
        acc_out  : out std_logic_vector(5 downto 0); -- Accumulated result (local)
        a_out    : out std_logic_vector(2 downto 0);  -- Forwarded element of A to the next DPU
        b_out    : out std_logic_vector(2 downto 0)   -- Forwarded element of B to the next DPU
    );
end DPU;

architecture Behavioral of DPU is
    signal acc      : unsigned(5 downto 0) := (others => '0');   -- Accumulator initialized to all 0s
    signal a_reg    : std_logic_vector(2 downto 0) := (others => '0'); -- Register for A output (delayed)
    signal b_reg    : std_logic_vector(2 downto 0) := (others => '0'); -- Register for B output (delayed)
   
begin
     -- Input signals saved to pass as output in next cycle
     a_reg <= a_in;
     b_reg <= b_in;

    process (clk, rst)
    begin
        if rst = '1' then
            acc_out <= (others => '0'); 
            a_out <= (others => '0');   
            b_out <= (others => '0');  
            acc <= (others => '0');
            
        elsif rising_edge(clk) then
            -- Update the accumulator and output on clock edge
            acc <= unsigned(a_reg) * unsigned(b_reg) + acc;
            acc_out <= std_logic_vector(unsigned(a_reg) * unsigned(b_reg) + acc);
            
            -- Assign the delayed outputs
            a_out <= a_reg;  
            b_out <= b_reg;
        end if;
    end process;  
end Behavioral;
