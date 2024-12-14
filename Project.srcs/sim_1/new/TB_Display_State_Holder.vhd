library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TB_Display_State_Holder is
end TB_Display_State_Holder;

architecture behavior of TB_Display_State_Holder is
    -- Signals to connect to the UUT
    signal Clk_in : STD_LOGIC;
    signal state : STD_LOGIC_VECTOR(1 downto 0);

begin
    -- Clock generation
    clk_gen: entity work.Clock port map (clk_out => Clk_in);

    -- Instantiate Display_State_Holder
    Display_State_Holder_inst: entity work.Display_State_Holder port map (Clk_in => Clk_in, state => state);

    -- Process to validate output
    process
    begin
        -- Sync with the clock
        wait until rising_edge(Clk_in);
        
        -- Test initial state (state 0)
        assert state = "00" report "Initial state is not correct" severity error;
        wait for 2 ms;  

        -- Test tranisition to state 1
        assert state = "01" report "State didn't transition to state 1 correctly" severity error;
        wait for 2 ms;

        -- Test transition to state 2
        assert state = "10" report "State didn't transition to state 2 correctly" severity error;
        wait for 2 ms;

        -- State returining to state 0
        assert state = "00" report "State didn't return to state 0 correctly" severity error;
        wait;
    end process;

end behavior;
