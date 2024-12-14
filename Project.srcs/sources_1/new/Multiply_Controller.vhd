library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Multiply_Controller is
    Port (
        clk  : in std_logic;
        rst  : in std_logic;
          
--         Parallel outputs for the result (each element is 16-bit)
--        Res11  : out std_logic_vector(5 downto 0);
--        Res12  : out std_logic_vector(5 downto 0);
--        Res13  : out std_logic_vector(5 downto 0);
--        Res21  : out std_logic_vector(5 downto 0);
--        Res22  : out std_logic_vector(5 downto 0);
--        Res23  : out std_logic_vector(5 downto 0);
--        Res31  : out std_logic_vector(5 downto 0);
--        Res32  : out std_logic_vector(5 downto 0);
--        Res33  : out std_logic_vector(5 downto 0)
        
        S_7Seg : out STD_LOGIC_VECTOR (6 downto 0);
        S_anode : out STD_LOGIC_VECTOR (3 downto 0)
    );
    
end Multiply_Controller;

architecture Behavioral of Multiply_Controller is
    type rom_type is array (1 to 18) of std_logic_vector(2 downto 0);
    signal Res11  : std_logic_vector(5 downto 0);
    signal Res12  : std_logic_vector(5 downto 0);
    signal Res13  : std_logic_vector(5 downto 0);
    signal Res21  : std_logic_vector(5 downto 0);
    signal Res22  : std_logic_vector(5 downto 0);
    signal Res23  : std_logic_vector(5 downto 0);
    signal Res31  : std_logic_vector(5 downto 0);
    signal Res32  : std_logic_vector(5 downto 0);
    signal Res33  : std_logic_vector(5 downto 0);
    
    signal lut_in : STD_LOGIC_VECTOR (5 downto 0);
    signal counter : integer := 0;
    signal counter_state : std_logic_vector(1 downto 0);
    
    signal inputMatrix_ROM : rom_type := (
    --Matrix A
    "011", "001", "001", -- Row 1: 3 1 1
    "010", "000", "001", -- Row 2: 2 0 1
    "000", "010", "010",  -- Row 3: 0 2 2
    
    --Matrix B
    "001", "000","010", -- Row 1: 1 0 2
    "000", "011", "001", -- Row 2: 0 3 1
    "010", "001", "001"  -- Row 3: 2 1 1
    
--    --Matrix A
--     X"01", X"02", X"03",       
--     X"02", X"04", X"02",      
--     X"01", X"03", X"01",
      
--     --Matrix B        
--     X"02", X"04", X"01",     
--     X"03", X"01", X"02",            
--     X"04", X"02", X"03"
     );
    
    begin        
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
            
    Counter0: entity work.Counter 
                PORT MAP ( Clk_in => clk,
                       state => counter_state);
 
    LUT_16_7 : entity work.LUT_16_7      
           PORT MAP ( address => lut_in,
                      data => S_7Seg );
                      
     process(clk, rst)
        begin
            if rst = '1' then
                counter <= 0;
        elsif rising_edge(clk) then
            if counter >= 600000000 then
                if counter_state = "00" then
                    S_anode <= "1011";
                    lut_in <= Res31;
                elsif counter_state = "01" then
                    S_anode <= "1101";
                    lut_in <= Res32;
                elsif counter_state = "10" then
                    S_anode <= "1110";
                    lut_in <= Res33;
                end if;
            elsif counter >= 400000000 then
                if counter_state = "00" then
                    S_anode <= "1011";
                    lut_in <= Res21;
                elsif counter_state = "01" then
                    S_anode <= "1101";
                    lut_in <= Res22;
                elsif counter_state = "10" then
                    S_anode <= "1110";
                    lut_in <= Res23;
                end if;
            elsif counter >= 200000000 then
                if counter_state = "00" then
                    S_anode <= "1011";
                    lut_in <= Res11;
                elsif counter_state = "01" then
                    S_anode <= "1101";
                    lut_in <= Res12;
                elsif counter_state = "10" then
                    S_anode <= "1110";
                    lut_in <= Res13;
                end if;
            end if;
            
            counter <= counter + 1;        
        end if;
    end process;
end Behavioral;
