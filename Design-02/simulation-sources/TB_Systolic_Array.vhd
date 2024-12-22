library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_processor_tb is
end data_processor_tb;

architecture behavior of data_processor_tb is
    -- Component Declaration
    component data_processor
        generic (
            BUFFER_SIZE : integer := 18
        );
        port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            data_in     : in  std_logic_vector(8*BUFFER_SIZE-1 downto 0);
            data_out    : out std_logic_vector(8*BUFFER_SIZE-1 downto 0);
            proc_start  : in  std_logic;
            proc_done   : out std_logic
        );
    end component;

    -- Constants
    constant BUFFER_SIZE : integer := 18;
    constant CLK_PERIOD : time := 10 ns;

    -- Signals
    signal clk         : std_logic := '0';
    signal reset       : std_logic := '0';
    signal data_in     : std_logic_vector(8*BUFFER_SIZE-1 downto 0) := (others => '0');
    signal data_out    : std_logic_vector(8*BUFFER_SIZE-1 downto 0);
    signal proc_start  : std_logic := '0';
    signal proc_done   : std_logic;

    -- Array type for easier matrix handling
    type matrix_3x3 is array (0 to 2, 0 to 2) of integer range 0 to 255;
    
    -- Test matrices
    constant matrix_a : matrix_3x3 := (
        (1, 1, 1),
        (1, 1, 1),
        (1, 1, 1)
    );
    
    constant matrix_b : matrix_3x3 := (
        (1, 1, 1),
        (1, 1, 1),
        (1, 1, 1)
    );

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: data_processor 
    generic map (
        BUFFER_SIZE => BUFFER_SIZE
    )
    port map (
        clk => clk,
        reset => reset,
        data_in => data_in,
        data_out => data_out,
        proc_start => proc_start,
        proc_done => proc_done
    );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        reset <= '1';
        wait for CLK_PERIOD*2;
        reset <= '0';
        wait for CLK_PERIOD*2;

        -- Pack matrices into data_in signal
        -- First matrix A (9 bytes)
        for i in 0 to 2 loop
            for j in 0 to 2 loop
                data_in(8*((i*3 + j) + 1)-1 downto 8*(i*3 + j)) <= 
                    std_logic_vector(to_unsigned(matrix_a(i,j), 8));
            end loop;
        end loop;

        -- Then matrix B (next 9 bytes)
        for i in 0 to 2 loop
            for j in 0 to 2 loop
                data_in(8*((i*3 + j + 9) + 1)-1 downto 8*(i*3 + j + 9)) <= 
                    std_logic_vector(to_unsigned(matrix_b(i,j), 8));
            end loop;
        end loop;

        -- Start processing
        wait for CLK_PERIOD*2;
        proc_start <= '1';
        wait for CLK_PERIOD;
        proc_start <= '0';

        -- Wait for processing to complete
        wait until proc_done = '1';
        wait for CLK_PERIOD;

        -- Print results
        report "Matrix multiplication results:";
        for i in 0 to 2 loop
            for j in 0 to 2 loop
                report "Result(" & integer'image(i) & "," & integer'image(j) & ") = " & 
                    integer'image(to_integer(unsigned(
                        data_out(16*((i*3 + j) + 1)-1 downto 16*(i*3 + j))
                    )));
            end loop;
        end loop;

        wait for CLK_PERIOD*10;
        
        -- End simulation
        assert false report "Test completed successfully" severity note;
        wait;
    end process;
end behavior;