library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity TB_DPU1 is
end TB_DPU1;

architecture behavior of TB_DPU1 is
    -- Clock and reset signals
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    
    -- Signals for DPU ports
    signal a_in    : std_logic_vector(2 downto 0) := (others => '0');
    signal b_in    : std_logic_vector(2 downto 0) := (others => '0');
    signal acc_out : std_logic_vector(5 downto 0);
    signal a_out   : std_logic_vector(2 downto 0);
    signal b_out   : std_logic_vector(2 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;

    -- Instantiate the Clock generator
    component Clock
        Port (
            clk_out : out std_logic
        );
    end component;

    -- Instantiate the DPU
    component DPU
        Port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            a_in     : in  std_logic_vector(2 downto 0);
            b_in     : in  std_logic_vector(2 downto 0);
            acc_out  : out std_logic_vector(5 downto 0);
            a_out    : out std_logic_vector(2 downto 0);
            b_out    : out std_logic_vector(2 downto 0)
        );
    end component;

begin
    -- Clock generation
    clk_gen: Clock port map (clk_out => clk);

    -- Instantiate DPU
    dpu_inst: DPU port map (
        clk      => clk,
        rst      => rst,
        a_in     => a_in,
        b_in     => b_in,
        acc_out  => acc_out,
        a_out    => a_out,
        b_out    => b_out
    );

    -- Process for applying inputs on the rising edge of the clock
    process
    begin
        -- Apply reset
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        
        wait until rising_edge(clk);
    
        -- Apply test vector set 1
        a_in <= "001";  -- 1
        b_in <= "010";  -- 2
        wait for clk_period;
    
        -- Apply test vector set 2
        a_in <= "011";  -- 3
        b_in <= "100";  -- 4
        wait for clk_period;
        
        -- Apply test vector set 3
        a_in <= "101";  -- 5
        b_in <= "010";  -- 2
        wait for clk_period;
    
        -- Apply test vector set 4
        -- Test 0 input vectors and retained accumulator
        a_in <= "000";  -- 0
        b_in <= "000";  -- 0
        wait for clk_period * 2;
        
        -- Test reset
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait;
    end process;
    
    -- Process for validaitng outputs in falling edges
    process
    begin
        -- Sync with input setting
        wait for clk_period * 3;
        
        -- Check the output set 1
        assert (acc_out = "000010") -- 1*2 = 2
        report "Error: Accumulated output 1 is incorrect" severity error;
        assert (a_out = "001") -- A output = 1
        report "Error: A output 1 is incorrect" severity error;
        assert (b_out = "010") -- B output =2
        report "Error: B output 1 is incorrect" severity error;
        wait for clk_period;
        
        -- Check the output set 2
        assert (acc_out = "001110") -- 2 + 3*4 = 2 + 12 = 14
        report "Error: Accumulated output 2 is incorrect" severity error;
        assert (a_out = "011") -- A output = 3
        report "Error: A output 2 is incorrect" severity error;
        assert (b_out = "100") -- B output = 4
        report "Error: B output 2 is incorrect" severity error;
        wait for clk_period;
    
        -- Check the output set 3
        assert (acc_out = "011000") -- 14 + 5*2 = 14 + 10 = 24
        report "Error: Accumulated output 3 is incorrect" severity error;
        assert (a_out = "101") -- A output = 5
        report "Error: A output 3 is incorrect" severity error;
        assert (b_out = "010") -- B output = 2
        report "Error: B output 3 is incorrect" severity error;
        wait for clk_period;
        
        -- Check the output set 4
        assert (acc_out = "011000") -- 24 + 0*0 = 24 + 0 = 24
        report "Error: Accumulated output 4 is incorrect" severity error;
        assert (a_out = "000") -- A output = 0
        report "Error: A output 4 is incorrect" severity error;
        assert (b_out = "000") -- B output = 0
        report "Error: B output 4 is incorrect" severity error;
        wait for clk_period;
        
        -- Check reset
        assert (acc_out = "000000") 
        report "Error: Accumulated output after reset is incorrect" severity error;
        wait;
        
    end process;

end behavior;