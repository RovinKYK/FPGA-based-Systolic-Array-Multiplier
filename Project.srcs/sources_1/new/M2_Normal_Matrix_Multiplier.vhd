library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This module conducts normal matrix multiplication in 1 clock cycle
entity M2_Normal_Matrix_Multiplier is
    port (
        clk  : in std_logic;
        rst  : in std_logic;
        
        -- Parallel inputs for 3x3 matrix A
        A11, A12, A13, A21, A22, A23, A31, A32, A33 : in std_logic_vector(2 downto 0);
        
        -- Parallel inputs for 3x3 matrix B
        B11, B12, B13, B21, B22, B23, B31, B32, B33 : in std_logic_vector(2 downto 0);
        
        -- Parallel outputs for the result
        Res11, Res12, Res13, Res21, Res22, Res23, Res31, Res32, Res33 : out std_logic_vector(5 downto 0)
    );
end M2_Normal_Matrix_Multiplier;

architecture Behavioral of M2_Normal_Matrix_Multiplier is
    type matrix_3by3 is array(1 to 3, 1 to 3) of unsigned(5 downto 0);
    signal results : matrix_3by3 := (others => (others => (others => '0')));
begin
    process(clk)
    begin
        -- Reset result matrix with reset signal
        if rst = '1' then
            results <= (others => (others => (others => '0')));
            
        elsif rising_edge(clk) then
            -- Perform normal matrix multiplication
            results(1,1) <= unsigned(A11) * unsigned(B11) + unsigned(A12) * unsigned(B21) + unsigned(A13) * unsigned(B31);
            results(1,2) <= unsigned(A11) * unsigned(B12) + unsigned(A12) * unsigned(B22) + unsigned(A13) * unsigned(B32);
            results(1,3) <= unsigned(A11) * unsigned(B13) + unsigned(A12) * unsigned(B23) + unsigned(A13) * unsigned(B33);
    
            results(2,1) <= unsigned(A21) * unsigned(B11) + unsigned(A22) * unsigned(B21) + unsigned(A23) * unsigned(B31);
            results(2,2) <= unsigned(A21) * unsigned(B12) + unsigned(A22) * unsigned(B22) + unsigned(A23) * unsigned(B32);
            results(2,3) <= unsigned(A21) * unsigned(B13) + unsigned(A22) * unsigned(B23) + unsigned(A23) * unsigned(B33);
    
            results(3,1) <= unsigned(A31) * unsigned(B11) + unsigned(A32) * unsigned(B21) + unsigned(A33) * unsigned(B31);
            results(3,2) <= unsigned(A31) * unsigned(B12) + unsigned(A32) * unsigned(B22) + unsigned(A33) * unsigned(B32);
            results(3,3) <= unsigned(A31) * unsigned(B13) + unsigned(A32) * unsigned(B23) + unsigned(A33) * unsigned(B33);
        end if;
    end process;

    -- Map outputs
    Res11 <= std_logic_vector(results(1,1)); Res12 <= std_logic_vector(results(1,2)); Res13 <= std_logic_vector(results(1,3));
    Res21 <= std_logic_vector(results(2,1)); Res22 <= std_logic_vector(results(2,2)); Res23 <= std_logic_vector(results(2,3));
    Res31 <= std_logic_vector(results(3,1)); Res32 <= std_logic_vector(results(3,2)); Res33 <= std_logic_vector(results(3,3));
end Behavioral;
