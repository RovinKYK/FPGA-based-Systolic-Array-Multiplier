library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This module conducts systolic array multiplication in 1 clock cycle
entity M1_Systolic_Array_Multiplier is
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
end M1_Systolic_Array_Multiplier;

architecture Behavioral of M1_Systolic_Array_Multiplier is
  -- DPU states to save A,B matrix values passing and partial multiplication results
  type DPU_state is record
    A : unsigned(2 downto 0);
    B : unsigned(2 downto 0);
    Res : unsigned(5 downto 0);
  end record;

  type DPU_array is array(1 to 3, 1 to 3) of DPU_state;

begin
  process(clk)
  -- Instantiate matrix of DPUs
  variable DPUs : DPU_array := (others => (others => (others => (others => '0'))));
  begin
      -- Clear all states of DPUs with reset
      if rst = '1' then
        DPUs := (others => (others => (others => (others => '0'))));

        elsif rising_edge(clk) then
            -- Provide input matrix values to outermost DPUs in required order
            for counter in 1 to 7 loop
                if counter = 1 then
                    DPUs(1,1).A := unsigned(A11);
                    DPUs(1,1).B := unsigned(B11);
                elsif counter = 2 then
                    DPUs(1,1).A := unsigned(A12);
                    DPUs(2,1).A := unsigned(A21);
                    DPUs(1,1).B := unsigned(B21);
                    DPUs(1,2).B := unsigned(B12);
                elsif counter = 3 then
                    DPUs(1,1).A := unsigned(A13);
                    DPUs(2,1).A := unsigned(A22);
                    DPUs(3,1).A := unsigned(A31);
                    DPUs(1,1).B := unsigned(B31);
                    DPUs(1,2).B := unsigned(B22);
                    DPUs(1,3).B := unsigned(B13);
                elsif counter = 4 then
                    DPUs(2,1).A := unsigned(A23);
                    DPUs(3,1).A := unsigned(A32);
                    DPUs(1,2).B := unsigned(B32);
                    DPUs(1,3).B := unsigned(B23);
                    DPUs(1,1).A := (others => '0');
                    DPUs(1,1).B := (others => '0');
                elsif counter = 5 then
                    DPUs(3,1).A := unsigned(A33);
                    DPUs(1,3).B := unsigned(B33);
                    DPUs(2,1).A := (others => '0');
                    DPUs(1,2).B := (others => '0');      
                elsif counter = 6 then
                    DPUs(3,1).A := (others => '0');
                    DPUs(1,3).B := (others => '0');
                end if;
                
                -- Conduct computations of DPUs
                for i in 3 downto 1 loop
                  for j in 3 downto 1 loop
                    -- Compute partial products
                    DPUs(i,j).Res := DPUs(i,j).Res + DPUs(i,j).A * DPUs(i,j).B;
                    
                    -- Shift data through DPU array
                    if i > 1 then DPUs(i,j).B := DPUs(i-1,j).B; end if;
                    if j > 1 then DPUs(i,j).A := DPUs(i,j-1).A; end if;
                  end loop;
                end loop;
            end loop;
            
      end if;
      
     -- Map the outputs
     Res11 <= std_logic_vector(DPUs(1,1).Res);
     Res12 <= std_logic_vector(DPUs(1,2).Res);
     Res13 <= std_logic_vector(DPUs(1,3).Res);
     Res21 <= std_logic_vector(DPUs(2,1).Res);
     Res22 <= std_logic_vector(DPUs(2,2).Res);
     Res23 <= std_logic_vector(DPUs(2,3).Res);
     Res31 <= std_logic_vector(DPUs(3,1).Res);
     Res32 <= std_logic_vector(DPUs(3,2).Res);
     Res33 <= std_logic_vector(DPUs(3,3).Res);
  end process;

end Behavioral;