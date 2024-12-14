library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity TB_Multiply_Controller is
end TB_Multiply_Controller;

architecture behavior of TB_Multiply_Controller is
    -- Clock and reset signals
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    
    signal counter: std_logic_vector(4 downto 0);
    
--    signal Res11, Res12, Res13 : std_logic_vector(5 downto 0);
--    signal Res21, Res22, Res23 : std_logic_vector(5 downto 0);
--    signal Res31, Res32, Res33 : std_logic_vector(5 downto 0);  

    -- Display output signals
    signal Out_7Seg : std_logic_vector(6 downto 0);
    signal Out_Anode: std_logic_vector(3 downto 0);
    
    constant clk_period : time := 10 ns;
        
begin
    -- Clock generation
    clk_gen: entity work.Clock port map (clk_out => clk);

    -- Instantiate the Multiplier Controller
    controller_inst: entity work.Multiply_Controller
        port map (
            clk  => clk,
            rst  => rst,
            
            -- Output matri Res
--            Res11 => Res11,
--            Res12 => Res12,
--            Res13 => Res13,
--            Res21 => Res21,
--            Res22 => Res22,
--            Res23 => Res23,
--            Res31 => Res31,
--            Res32 => Res32,
--            Res33 => Res33

            Out_7Seg => Out_7Seg,
            Out_Anode => Out_Anode,
            cout => counter
        );

    -- Process to control the multiply controller
    process
    begin
        -- Reset the controller
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        
        -- Wait for the controller to complete producing outputs
        wait until rising_edge(clk);
        wait for clk_period * 29;
        
        -- Reset the controller after completion
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait;
    end process;
        
    -- Process to validate results on falling edges
    process
    begin
        -- Wait untill the multiply_controller produces results
        wait until falling_edge(clk);
        wait for clk_period * 12;

        -- Validate element 11
        assert (Out_7Seg  = "0010010") report "Display value for element 11 is incorrect!" severity error; -- 5
        assert (Out_Anode = "1011") report "Anode value for element 11 is incorrect!" severity error;
        wait for clk_period * 2;
        
        -- Validate element 12
        assert (Out_7Seg  = "0011001") report "Display value for element 12 is incorrect!" severity error; -- 4
        assert (Out_Anode = "1101") report "Anode value for element 12 is incorrect!" severity error;
        wait for clk_period * 2;
        
        -- Validate element 13
        assert (Out_7Seg  = "0000000") report "Display value for element 13 is incorrect!" severity error; -- 8
        assert (Out_Anode = "1110") report "Anode value for element 13 is incorrect!" severity error;
        wait for clk_period * 2;
        
        -- Validate element 21
        assert (Out_7Seg  = "0011001") report "Display value for element 21 is incorrect!" severity error; -- 4
        assert (Out_Anode = "1011") report "Anode value for element 21 is incorrect!" severity error;
        wait for clk_period * 2;
        
        -- Validate element 22
        assert (Out_7Seg  = "1111001") report "Display value for element 22 is incorrect!" severity error; -- 1
        assert (Out_Anode = "1101") report "Anode value for element 22 is incorrect!" severity error;
        wait for clk_period * 2;
        
        -- Validate element 23
        assert (Out_7Seg  = "0010010") report "Display value for element 23 is incorrect!" severity error; -- 5
        assert (Out_Anode = "1110") report "Anode value for element 23 is incorrect!" severity error;
        wait for clk_period * 2;
        
        -- Validate element 31
        assert (Out_7Seg  = "0011001") report "Display value for element 31 is incorrect!" severity error; -- 4
        assert (Out_Anode = "1011") report "Anode value for element 31 is incorrect!" severity error;
        wait for clk_period * 2;
        
        -- Validate element 32
        assert (Out_7Seg  = "0000000") report "Display value for element 32 is incorrect!" severity error; -- 8
        assert (Out_Anode = "1101") report "Anode value for element 32 is incorrect!" severity error;
        wait for clk_period * 2;
        
        -- Validate element 33
        assert (Out_7Seg  = "0011001") report "Display value for element 33 is incorrect!" severity error; -- 4
        assert (Out_Anode = "1110") report "Anode value for element 33 is incorrect!" severity error;
        wait for clk_period * 2;
        
        -- Test whether display is off after reset until results are produced
        assert (Out_Anode = "1111") report "Anode value after reset is incorrect!" severity error;
        wait;
    end process;
end behavior;
