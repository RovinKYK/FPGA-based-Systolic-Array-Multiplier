library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Systolic_Array_Multiplier is
    Port (
        clk  : in std_logic;
        rst  : in std_logic;
        
        -- Parallel inputs for 3x3 matrix A (each element is 3-bit)
        A11  : in std_logic_vector(2 downto 0);
        A12  : in std_logic_vector(2 downto 0);
        A13  : in std_logic_vector(2 downto 0);
        A21  : in std_logic_vector(2 downto 0);
        A22  : in std_logic_vector(2 downto 0);
        A23  : in std_logic_vector(2 downto 0);
        A31  : in std_logic_vector(2 downto 0);
        A32  : in std_logic_vector(2 downto 0);
        A33  : in std_logic_vector(2 downto 0);

        -- Parallel inputs for 3x3 matrix B (each element is 3-bit)
        B11  : in std_logic_vector(2 downto 0);
        B12  : in std_logic_vector(2 downto 0);
        B13  : in std_logic_vector(2 downto 0);
        B21  : in std_logic_vector(2 downto 0);
        B22  : in std_logic_vector(2 downto 0);
        B23  : in std_logic_vector(2 downto 0);
        B31  : in std_logic_vector(2 downto 0);
        B32  : in std_logic_vector(2 downto 0);
        B33  : in std_logic_vector(2 downto 0);

        -- Parallel outputs for the result (each element is 6-bit)
        Res11  : out std_logic_vector(5 downto 0);
        Res12  : out std_logic_vector(5 downto 0);
        Res13  : out std_logic_vector(5 downto 0);
        Res21  : out std_logic_vector(5 downto 0);
        Res22  : out std_logic_vector(5 downto 0);
        Res23  : out std_logic_vector(5 downto 0);
        Res31  : out std_logic_vector(5 downto 0);
        Res32  : out std_logic_vector(5 downto 0);
        Res33  : out std_logic_vector(5 downto 0)
        
        -- Outputs to check A matrix values passed among DPUs for testing purpose
        -- Uncomment when running TB_Systolic_Array_Multiplier
--        aIn11  : out std_logic_vector(2 downto 0);
--        aIn12  : out std_logic_vector(2 downto 0);
--        aIn13  : out std_logic_vector(2 downto 0);
--        aIn21  : out std_logic_vector(2 downto 0);
--        aIn22  : out std_logic_vector(2 downto 0);
--        aIn23  : out std_logic_vector(2 downto 0);
--        aIn31  : out std_logic_vector(2 downto 0);
--        aIn32  : out std_logic_vector(2 downto 0);
--        aIn33  : out std_logic_vector(2 downto 0);
        
        -- Outputs to check B matrix values passed among DPUs for testing purpose
        -- Uncomment when running TB_Systolic_Array_Multiplier
--        bIn11  : out std_logic_vector(2 downto 0);
--        bIn12  : out std_logic_vector(2 downto 0);
--        bIn13  : out std_logic_vector(2 downto 0);
--        bIn21  : out std_logic_vector(2 downto 0);
--        bIn22  : out std_logic_vector(2 downto 0);
--        bIn23  : out std_logic_vector(2 downto 0);
--        bIn31  : out std_logic_vector(2 downto 0);
--        bIn32  : out std_logic_vector(2 downto 0);
--        bIn33  : out std_logic_vector(2 downto 0);
        
        -- Outputs to check counter value for testing purpose
        -- Uncomment when running TB_Systolic_Array_Multiplier
--        cout: out std_logic_vector(3 downto 0)
    );
end Systolic_Array_Multiplier;

architecture Behavioral of Systolic_Array_Multiplier is
    type matrix_3by3_3bit is array (1 to 3, 1 to 3) of std_logic_vector(2 downto 0); 
    type matrix_4by4_3bit is array (1 to 4, 1 to 4) of std_logic_vector(2 downto 0); 
    type matrix_3by3_6bit is array (1 to 3, 1 to 3) of std_logic_vector(5 downto 0); 

    signal A_matrix, B_matrix : matrix_3by3_3bit; -- Matrix to save input matrices
    signal a_inter, b_inter : matrix_4by4_3bit := (others => (others => (others => '0'))); -- Matrix to share and pass input matrix elements among DPUs
    signal acc_out_signals : matrix_3by3_6bit; -- Matrix to save DPU outptus
    signal counter : integer := 0; -- Counter to track the clock cycle
    
begin
    -- Assign parallel inputs to A_matrix
    A_matrix(1,1) <= A11;
    A_matrix(1,2) <= A12;
    A_matrix(1,3) <= A13;
    A_matrix(2,1) <= A21;
    A_matrix(2,2) <= A22;
    A_matrix(2,3) <= A23;
    A_matrix(3,1) <= A31;
    A_matrix(3,2) <= A32;
    A_matrix(3,3) <= A33;

    -- Assign parallel inputs to B_matrix
    B_matrix(1,1) <= B11;
    B_matrix(1,2) <= B12;
    B_matrix(1,3) <= B13;
    B_matrix(2,1) <= B21;
    B_matrix(2,2) <= B22;
    B_matrix(2,3) <= B23;
    B_matrix(3,1) <= B31;
    B_matrix(3,2) <= B32;
    B_matrix(3,3) <= B33;
    
    -- Assign accumulated results to parallel outputs
    Res11 <= acc_out_signals(1,1);
    Res12 <= acc_out_signals(1,2);
    Res13 <= acc_out_signals(1,3);
    Res21 <= acc_out_signals(2,1);
    Res22 <= acc_out_signals(2,2);
    Res23 <= acc_out_signals(2,3);
    Res31 <= acc_out_signals(3,1);
    Res32 <= acc_out_signals(3,2);
    Res33 <= acc_out_signals(3,3);
    
    -- Assign shared matrix with A matrix values to parallel outptus for testing purpose
    -- Uncomment when running TB_Systolic_Array_Multiplier
--    aIn11 <= a_inter(1,1);
--    aIn12 <= a_inter(1,2);
--    aIn13 <= a_inter(1,3);
--    aIn21 <= a_inter(2,1);
--    aIn22 <= a_inter(2,2);
--    aIn23 <= a_inter(2,3);
--    aIn31 <= a_inter(3,1);
--    aIn32 <= a_inter(3,2);
--    aIn33 <= a_inter(3,3);
    
    -- Assign shared matrix with B matrix values to parallel outptus for testing purpose
    -- Uncomment when running TB_Systolic_Array_Multiplier
--    bIn11 <= b_inter(1,1);
--    bIn12 <= b_inter(1,2);
--    bIn13 <= b_inter(1,3);
--    bIn21 <= b_inter(2,1);
--    bIn22 <= b_inter(2,2);
--    bIn23 <= b_inter(2,3);
--    bIn31 <= b_inter(3,1);
--    bIn32 <= b_inter(3,2);
--    bIn33 <= b_inter(3,3);
    
    -- Assign counter value to output for testing purpose
    -- Uncomment when running TB_Systolic_Array_Multiplier
--    cout <= std_logic_vector(to_unsigned(counter,cout'length));

    -- Connect DPUs for the systolic array
    gen_rows: for i in 1 to 3 generate
        gen_columns: for j in 1 to 3 generate
            DPU_inst: entity work.DPU
                port map (
                    clk     => clk,
                    rst     => rst,
                    a_in    => a_inter(i, j),
                    b_in    => b_inter(i, j),
                    a_out   => a_inter(i, j+1),
                    b_out   => b_inter(i+1, j),
                    acc_out => acc_out_signals(i, j)
                );
        end generate;
    end generate;

--   process(clk, rst)
--   begin
--          -- Resert counter with reset signal. DPUs will reset internal accumulators
--          if rst = '1' then
--              counter <= 0;

--          -- Handle asssigning input matrix values to outermost DPUs with counter         
--          elsif rising_edge(clk) then
----                  counter <= counter + 1;
--                  if counter > 0 then
--                      if counter <= 3 then
--                          for i in counter downto 1 loop
--                              a_inter(i,1) <= A_matrix(i,counter-i+1);
--                              b_inter(1,i) <= B_matrix(counter-i+1,i);
--                          end loop;
                          
--                      else
--                          if counter <= 5 then
--                              for i in counter-3+1 to 3 loop
--                                  a_inter(i,1) <= A_matrix(i,counter-i+1);
--                                  b_inter(1,i) <= B_matrix(counter-i+1,i);
--                              end loop;
--                          end if;
                          
--                          a_inter(counter-3,1) <= (others => '0');
--                          b_inter(1,counter-3) <= (others => '0');
--                      end if;
--                  end if;

--              -- Increment counter
--              counter <= counter + 1;
--          end if;
--     end process;

    process(clk, rst)
    begin
        -- Resert counter with reset signal. DPUs will reset internal accumulators
        if rst = '1' then
                counter <= 0;
        
        -- Handle asssigning input matrix values to outermost DPUs with counter
        elsif rising_edge(clk) then
                if counter = 1 then
                    a_inter(1,1) <= A_matrix(1,1);
                    b_inter(1,1) <= B_matrix(1,1);
                elsif counter = 2 then
                    a_inter(1,1) <= A_matrix(1,2);
                    a_inter(2,1) <= A_matrix(2,1);
                    b_inter(1,1) <= B_matrix(2,1);
                    b_inter(1,2) <= B_matrix(1,2);
                elsif counter = 3 then
                    a_inter(1,1) <= A_matrix(1,3);
                    a_inter(2,1) <= A_matrix(2,2);
                    a_inter(3,1) <= A_matrix(3,1);
                    b_inter(1,1) <= B_matrix(3,1);
                    b_inter(1,2) <= B_matrix(2,2);
                    b_inter(1,3) <= B_matrix(1,3);
                elsif counter = 4 then
                    a_inter(2,1) <= A_matrix(2,3);
                    a_inter(3,1) <= A_matrix(3,2);
                    b_inter(1,2) <= B_matrix(3,2);
                    b_inter(1,3) <= B_matrix(2,3);
                    a_inter(1,1) <= (others => '0');
                    b_inter(1,1) <= (others => '0');
                elsif counter = 5 then
                    a_inter(3,1) <= A_matrix(3,3);
                    b_inter(1,3) <= B_matrix(3,3);
                    a_inter(2,1) <= (others => '0');
                    b_inter(1,2) <= (others => '0');      
                elsif counter = 6 then
                    a_inter(3,1) <= (others => '0');
                    b_inter(1,3) <= (others => '0');
                end if;
                
            -- Increment counter
            counter <= counter + 1;
        end if;
    end process;

end Behavioral;
