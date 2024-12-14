library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity TB_Multiply_Controller is
end TB_Multiply_Controller;

architecture behavior of TB_Multiply_Controller is
    -- Clock and reset signals
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    
--    signal Res11, Res12, Res13 : std_logic_vector(5 downto 0);
--    signal Res21, Res22, Res23 : std_logic_vector(5 downto 0);
--    signal Res31, Res32, Res33 : std_logic_vector(5 downto 0);  

    signal S_7Seg : STD_LOGIC_VECTOR (6 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;
        
begin
    -- Clock generation
    clk_gen: entity work.Clock port map (clk_out => clk);

    -- Instantiate the Systolic Array Multiplier
    controller_inst: entity work.Multiply_Controller
        port map (
            clk  => clk,
            rst  => rst,
            
            -- Output matrix Res
--            Res11 => Res11,
--            Res12 => Res12,
--            Res13 => Res13,
--            Res21 => Res21,
--            Res22 => Res22,
--            Res23 => Res23,
--            Res31 => Res31,
--            Res32 => Res32,
--            Res33 => Res33

            S_7Seg => S_7Seg
        );

    -- Test process
    process
    begin
        -- Initialize signals
        rst <= '1';
        wait for clk_period;
        rst <= '0';  -- De-assert reset
        
        wait until rising_edge(clk);
        -- Wait enough time for the systolic array to compute
        wait for clk_period * 9;

        -- Check the result (you should calculate the expected result manually)
        -- Example of expected result, update based on actual matrix multiplication
--        assert (Res11 = X"0014") report "Res11 is incorrect!" severity error;
--        assert (Res12 = X"000c") report "Res12 is incorrect!" severity error;
--        assert (Res13 = X"000e") report "Res13 is incorrect!" severity error;
--        assert (Res21 = X"0018") report "Res21 is incorrect!" severity error;
--        assert (Res22 = X"0010") report "Res22 is incorrect!" severity error;
--        assert (Res23 = X"0010") report "Res23 is incorrect!" severity error;
--        assert (Res31 = X"000f") report "Res31 is incorrect!" severity error;
--        assert (Res32 = X"0009") report "Res32 is incorrect!" severity error;
--        assert (Res33 = X"000a") report "Res33 is incorrect!" severity error;
 
        wait;
    end process;
end behavior;
