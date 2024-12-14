library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is
    Port ( Clk_in : in STD_LOGIC;
           state : out STD_LOGIC_VECTOR(1 downto 0));
end Counter;

architecture Behavioral of Counter is

signal count : integer := 0;
signal counter_val : integer := 0;

begin

    process (Clk_in) begin
        if (rising_edge(Clk_in)) then
            count <= count + 1;           
            if (count mod 400000)=0 then     -- 4 ms
                counter_val <= (counter_val + 1) mod 3; 
                state <= std_logic_vector(to_unsigned(counter_val, 2));
            end if;
        end if;
    end process;

end Behavioral;
