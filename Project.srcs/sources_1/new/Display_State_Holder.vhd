library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This component holds a state changing in every 4 ms
-- This is used to display differnt digits in three inbuild 7 segment displays on same time
entity Display_State_Holder is
    Port ( Clk_in : in STD_LOGIC;
           state : out STD_LOGIC_VECTOR(1 downto 0));
end Display_State_Holder;

architecture Behavioral of Display_State_Holder is
    signal count : integer := 0;
    signal state_counter : integer := 0;

begin
    process (Clk_in) begin
        -- Count clock pulses
        if (rising_edge(Clk_in)) then
            count <= count + 1;  
            
            -- Change state in every 4 ms         
            if ((count+1) mod 400000)=0 then  
--            if ((count+1) mod 2)=0 then -- Use for simulation
                state_counter <= (state_counter + 1) mod 3; -- Rotate in 3 states
            end if;
        end if;
    end process;
    
    -- Assign state_counter value to state output
    state <= std_logic_vector(to_unsigned(state_counter, 2));

end Behavioral;
