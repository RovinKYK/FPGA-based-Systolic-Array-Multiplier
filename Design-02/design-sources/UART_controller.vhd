library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_controller is
    generic (
        BUFFER_SIZE : integer := 18
    );
    port(
        clk              : in  std_logic;
        reset            : in  std_logic;
        rx               : in  std_logic;
        tx               : out std_logic
    );
end UART_controller;

architecture Behavioral of UART_controller is

    component UART_buffer
        generic (
            BAUD_DELAY : integer := 13020
        );
        port(
            clk           : in  std_logic;
            reset         : in  std_logic;
            rx_data       : in  std_logic_vector(7 downto 0);
            rx_valid      : in  std_logic;
            tx_data       : out std_logic_vector(7 downto 0);
            tx_start      : out std_logic;
            data_out      : out std_logic_vector(8*BUFFER_SIZE-1 downto 0);
            data_in       : in  std_logic_vector(8*BUFFER_SIZE-1 downto 0);
            proc_start    : out std_logic;
            proc_done     : in  std_logic
        );
    end component;
    
    component UART
        port(
            clk            : in  std_logic;
            reset          : in  std_logic;
            tx_start       : in  std_logic;
            data_in        : in  std_logic_vector(7 downto 0);
            data_out       : out std_logic_vector(7 downto 0);
            rx             : in  std_logic;
            tx             : out std_logic
        );
    end component;
    
    component Systolic_Array
        generic (
            BUFFER_SIZE : integer := 18
        );
        port(
            clk         : in  std_logic;
            reset       : in  std_logic;
            data_in     : in  std_logic_vector(8*BUFFER_SIZE-1 downto 0);
            data_out    : out std_logic_vector(8*BUFFER_SIZE-1 downto 0);
            proc_start  : in  std_logic;
            proc_done   : out std_logic
        );
    end component;
    
    -- Internal signals for UART interface
    signal rx_data_internal : std_logic_vector(7 downto 0);
    signal rx_valid        : std_logic;
    signal tx_data_internal : std_logic_vector(7 downto 0);
    signal tx_start_internal : std_logic;
    
    -- Internal signals for processor interface
    signal buffer_to_proc_data : std_logic_vector(8*BUFFER_SIZE-1 downto 0);
    signal proc_to_buffer_data : std_logic_vector(8*BUFFER_SIZE-1 downto 0);
    signal proc_start_signal   : std_logic;
    signal proc_done_signal    : std_logic;

begin
    -- Instantiate UART buffer
    buffer_inst: UART_buffer
    port map(
            clk           => clk,
            reset         => reset,
            rx_data       => rx_data_internal,
            rx_valid      => rx_valid,
            tx_data       => tx_data_internal,
            tx_start      => tx_start_internal,
            data_out      => buffer_to_proc_data,
            data_in       => proc_to_buffer_data,
            proc_start    => proc_start_signal,
            proc_done     => proc_done_signal
    );

    -- Instantiate UART transceiver
    UART_transceiver: UART
    port map(
            clk            => clk,
            reset          => reset,
            tx_start       => tx_start_internal,
            data_in        => tx_data_internal,
            data_out       => rx_data_internal,
            rx             => rx,
            tx             => tx
    );
    
    -- Instantiate data processor
    systolic_array_inst: Systolic_Array
    generic map (
            BUFFER_SIZE    => BUFFER_SIZE
    )
    port map(
            clk           => clk,
            reset         => reset,
            data_in       => buffer_to_proc_data,
            data_out      => proc_to_buffer_data,
            proc_start    => proc_start_signal,
            proc_done     => proc_done_signal
    );
    
    -- Generate rx_valid pulse when new data is received
    process(clk)
        variable last_rx_data : std_logic_vector(7 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if reset = '1' then
                rx_valid <= '0';
                last_rx_data := (others => '0');
            else
                if rx_data_internal /= last_rx_data then
                    rx_valid <= '1';
                    last_rx_data := rx_data_internal;
                else
                    rx_valid <= '0';
                end if;
            end if;
        end if;
    end process;

end Behavioral;