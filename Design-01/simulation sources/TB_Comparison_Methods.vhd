library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity TB_Comparison_Methods is
end TB_Comparison_Methods;

architecture behavior of TB_Comparison_Methods is
    -- Clock and reset signals
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    
    -- Signals for Multiplier ports
    signal A11, A12, A13 : std_logic_vector(2 downto 0) := (others => '0');
    signal A21, A22, A23 : std_logic_vector(2 downto 0) := (others => '0');
    signal A31, A32, A33 : std_logic_vector(2 downto 0) := (others => '0');
    
    signal B11, B12, B13 : std_logic_vector(2 downto 0) := (others => '0');
    signal B21, B22, B23 : std_logic_vector(2 downto 0) := (others => '0');
    signal B31, B32, B33 : std_logic_vector(2 downto 0) := (others => '0');
    
    signal Res11, Res12, Res13 : std_logic_vector(5 downto 0);
    signal Res21, Res22, Res23 : std_logic_vector(5 downto 0);
    signal Res31, Res32, Res33 : std_logic_vector(5 downto 0);
   
    -- Clock period
    constant clk_period : time := 10 ns;

begin
    -- Clock generation
    clk_gen: entity work.Clock port map (clk_out => clk);

    -- Instantiate the Multiplier
--      multiplier_inst: entity work.M1_Systolic_Array_Multiplier -- Testing Method 1: Systolic Array Multiplier
    multiplier_inst: entity work.M2_Normal_Matrix_Multiplier -- Testing Method 2: Normal Matrix Multiplier
        port map (
            clk  => clk,
            rst  => rst,
            
            -- Input matrix A
            A11  => A11,
            A12  => A12,
            A13  => A13,
            A21  => A21,
            A22  => A22,
            A23  => A23,
            A31  => A31,
            A32  => A32,
            A33  => A33,
            
            -- Input matrix B
            B11  => B11,
            B12  => B12,
            B13  => B13,
            B21  => B21,
            B22  => B22,
            B23  => B23,
            B31  => B31,
            B32  => B32,
            B33  => B33,
            
            -- Output matrix Res
            Res11 => Res11,
            Res12 => Res12,
            Res13 => Res13,
            Res21 => Res21,
            Res22 => Res22,
            Res23 => Res23,
            Res31 => Res31,
            Res32 => Res32,
            Res33 => Res33
        );

    -- Process for applying inputs on the rising edge
    process
    begin
        -- Reset component
        rst <= '1';
        wait for clk_period;
        rst <= '0';  
        
        wait until rising_edge(clk);
        
        -- Apply test matrices set 1
        A11 <= "001"; A12 <= "010"; A13 <= "011"; -- 1 2 3
        A21 <= "010"; A22 <= "100"; A23 <= "010"; -- 2 4 2
        A31 <= "001"; A32 <= "011"; A33 <= "001"; -- 1 3 1

        B11 <= "010"; B12 <= "100"; B13 <= "001"; -- 2 4 1
        B21 <= "011"; B22 <= "001"; B23 <= "010"; -- 3 1 2
        B31 <= "100"; B32 <= "010"; B33 <= "011"; -- 4 2 3
        
        -- Wait enough time for the computations
        wait for clk_period * 2;
        
        -- Apply null matrices and test reset
        A11<= (others => '0'); A12<= (others => '0'); A13 <= (others => '0');
        A21<= (others => '0'); A22<= (others => '0'); A23 <= (others => '0');
        A31<= (others => '0'); A32<= (others => '0'); A33 <= (others => '0');
        
        B11<= (others => '0');B12<= (others => '0');B13 <= (others => '0');
        B21<= (others => '0');B22<= (others => '0');B23 <= (others => '0');
        B31<= (others => '0');B32<= (others => '0');B33 <= (others => '0');
        
        rst <= '1';
        wait for clk_period;
        rst <= '0'; 
        wait;
    end process;
    
    -- Process for validaitng outputs on falling edges
    process
    begin
        -- Sync with input setting
        wait for clk_period * 2;
        
        -- Wait until computations are complete
        wait for clk_period;

        -- Check the matrix multiplication result set 1
        assert (Res11 = "010100") report "Res11 for test matrix set 1 is incorrect!" severity error;
        assert (Res12 = "001100") report "Res12 for test matrix set 1 is incorrect!" severity error;
        assert (Res13 = "001110") report "Res13 for test matrix set 1 is incorrect!" severity error;
        assert (Res21 = "011000") report "Res21 for test matrix set 1 is incorrect!" severity error;
        assert (Res22 = "010000") report "Res22 for test matrix set 1 is incorrect!" severity error;
        assert (Res23 = "010000") report "Res23 for test matrix set 1 is incorrect!" severity error;
        assert (Res31 = "001111") report "Res31 for test matrix set 1 is incorrect!" severity error;
        assert (Res32 = "001001") report "Res32 for test matrix set 1 is incorrect!" severity error;
        assert (Res33 = "001010") report "Res33 for test matrix set 1 is incorrect!" severity error;
        wait for clk_period;
        
        -- Check results after reset
        assert (Res11 = "000000") report "Res11 after reset is incorrect!" severity error;
        assert (Res12 = "000000") report "Res11 after reset is incorrect!" severity error;
        assert (Res13 = "000000") report "Res11 after reset is incorrect!" severity error;
        assert (Res21 = "000000") report "Res11 after reset is incorrect!" severity error;
        assert (Res22 = "000000") report "Res11 after reset is incorrect!" severity error;
        assert (Res23 = "000000") report "Res11 after reset is incorrect!" severity error;
        assert (Res31 = "000000") report "Res11 after reset is incorrect!" severity error;
        assert (Res32 = "000000") report "Res11 after reset is incorrect!" severity error;
        assert (Res33 = "000000") report "Res11 after reset is incorrect!" severity error;
        wait;
    end process;
end behavior;
