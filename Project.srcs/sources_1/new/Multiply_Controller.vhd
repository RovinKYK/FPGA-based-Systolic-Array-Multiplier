library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Multiply_Controller is
    Port (
        clk  : in std_logic;
        rst  : in std_logic;
       
--         Parallel outputs for the result 
--        Res11  : out std_logic_vector(5 downto 0);
--        Res12  : out std_logic_vector(5 downto 0);
--        Res13  : out std_logic_vector(5 downto 0);
--        Res21  : out std_logic_vector(5 downto 0);
--        Res22  : out std_logic_vector(5 downto 0);
--        Res23  : out std_logic_vector(5 downto 0);
--        Res31  : out std_logic_vector(5 downto 0);
--        Res32  : out std_logic_vector(5 downto 0);
--        Res33  : out std_logic_vector(5 downto 0)
        
        -- Outputs for the 7 segment display
        Out_7Seg : out STD_LOGIC_VECTOR (6 downto 0);
        Out_anode : out STD_LOGIC_VECTOR (3 downto 0) := "1111"
        
        -- Outputs to check counter value for testing purpose
        -- Uncomment when running TB_Multiply_Controller
--        cout: out std_logic_vector(4 downto 0)
    );
    
end Multiply_Controller;

architecture Behavioral of Multiply_Controller is
    -- Signals to store parallel outputs of multiplier
    signal Res11  : std_logic_vector(5 downto 0);
    signal Res12  : std_logic_vector(5 downto 0);
    signal Res13  : std_logic_vector(5 downto 0);
    signal Res21  : std_logic_vector(5 downto 0);
    signal Res22  : std_logic_vector(5 downto 0);
    signal Res23  : std_logic_vector(5 downto 0);
    signal Res31  : std_logic_vector(5 downto 0);
    signal Res32  : std_logic_vector(5 downto 0);
    signal Res33  : std_logic_vector(5 downto 0);
    
    -- Signals for other components
    signal lut_in : STD_LOGIC_VECTOR (5 downto 0);
    signal display_state : std_logic_vector(1 downto 0);
    
    -- Counter to track display time of different rows of output
    signal counter : integer := 0;
    
    -- ROM storing input matrix values
    type rom_type is array (1 to 18) of std_logic_vector(2 downto 0);
    signal inputMatrix_ROM : rom_type := (
        --Matrix A
        "011", "001", "001", -- Row 1: 3 1 1
        "010", "000", "001", -- Row 2: 2 0 1
        "000", "010", "010",  -- Row 3: 0 2 2
        
        --Matrix B
        "001", "000","010", -- Row 1: 1 0 2
        "000", "011", "001", -- Row 2: 0 3 1
        "010", "001", "001"  -- Row 3: 2 1 1
    
--        --Matrix A
--        "001", "010", "011", -- Row 1: 1 2 3
--        "010", "100", "010", -- Row 2: 2 4 2
--        "001", "011", "001", -- Row 3: 1 3 1
    
--        --Matrix B
--        "010", "100", "001", -- Row 1: 2 4 1
--        "011", "001", "010", -- Row 2: 3 1 2
--        "100", "010", "011"  -- Row 3: 4 2 3
     );
    
begin  
    -- Instantiate multiplier      
    multiplier_inst: entity work.Systolic_Array_Multiplier
            port map (
                clk  => clk,
                rst  => rst,
                
                -- Input matrix A
                A11  => inputMatrix_ROM(1),
                A12  => inputMatrix_ROM(2),
                A13  => inputMatrix_ROM(3),
                A21  => inputMatrix_ROM(4),
                A22  => inputMatrix_ROM(5),
                A23  => inputMatrix_ROM(6),
                A31  => inputMatrix_ROM(7),
                A32  => inputMatrix_ROM(8),
                A33  => inputMatrix_ROM(9),
                
                -- Input matrix B
                B11  => inputMatrix_ROM(10),
                B12  => inputMatrix_ROM(11),
                B13  => inputMatrix_ROM(12),
                B21  => inputMatrix_ROM(13),
                B22  => inputMatrix_ROM(14),
                B23  => inputMatrix_ROM(15),
                B31  => inputMatrix_ROM(16),
                B32  => inputMatrix_ROM(17),
                B33  => inputMatrix_ROM(18),
                
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
    
    -- Instantiate other components       
    Display_State_Holder: entity work.Display_State_Holder 
                PORT MAP ( Clk_in => clk,
                       state => display_state);
 
    LUT_16_7 : entity work.LUT_16_7      
           PORT MAP ( address => lut_in,
                      data => Out_7Seg );
                      
     -- Uncomment when running TB_Multiply_Controller
--     cout <= std_logic_vector(to_unsigned(counter,cout'length));
    
    -- Process to display result in 7 segment display                  
    process(clk, rst)
        begin
            -- Reset counter with reset signal
            if rst = '1' then
                counter <= 0;
                -- Off the displays on reset
                Out_Anode <= "1111";
                
            elsif rising_edge(clk) then
                -- display 3rd row
                if counter >= 600000000 then
--                if counter >= 23 then -- Use for simulation
                    if display_state = "00" then
                        Out_anode <= "1011";
                        lut_in <= Res31;
                    elsif display_state = "01" then
                        Out_anode <= "1101";
                        lut_in <= Res32;
                    elsif display_state = "10" then
                        Out_anode <= "1110";
                        lut_in <= Res33;
                    end if;
                    
                -- display 2nd row
                  elsif counter >= 400000000 then
--                  elsif counter >= 17 then -- Use for simulation
                    if display_state = "00" then
                        Out_anode <= "1011";
                        lut_in <= Res21;
                    elsif display_state = "01" then
                        Out_anode <= "1101";
                        lut_in <= Res22;
                    elsif display_state = "10" then
                        Out_anode <= "1110";
                        lut_in <= Res23;
                    end if;
                    
                -- display 1st row
                elsif counter >= 200000000 then
--                elsif counter >= 11 then -- Use for simulation
                    if display_state = "00" then
                        Out_anode <= "1011";
                        lut_in <= Res11;
                    elsif display_state = "01" then
                        Out_anode <= "1101";
                        lut_in <= Res12;
                    elsif display_state = "10" then
                        Out_anode <= "1110";
                        lut_in <= Res13;
                    end if;
                end if;
            
            -- Increment counter
            counter <= counter + 1;        
        end if;
    end process;
end Behavioral;
