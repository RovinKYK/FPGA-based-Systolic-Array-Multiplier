library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Systolic_Array is
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
end Systolic_Array;

architecture Behavioral of Systolic_Array is
    component DPU_8bit is
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            a_in     : in  std_logic_vector(7 downto 0);
            b_in     : in  std_logic_vector(7 downto 0);
            acc_out  : out std_logic_vector(15 downto 0);
            a_out    : out std_logic_vector(7 downto 0);
            b_out    : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Types for matrix handling
    type matrix_3by3_8bit is array (1 to 3, 1 to 3) of std_logic_vector(7 downto 0);
    type matrix_4by4_8bit is array (1 to 4, 1 to 4) of std_logic_vector(7 downto 0);
    type matrix_3by3_16bit is array (1 to 3, 1 to 3) of std_logic_vector(15 downto 0);

    -- Control signals
    type state_type is (IDLE, LOADING, PROCESSING, RESET_DPUs, COMPLETE);
    signal current_state : state_type := IDLE;
    
    -- Internal reset signal for DPUs
    signal dpu_reset : std_logic := '0';
    signal combined_reset : std_logic := '0';
    
    -- Matrix signals
    signal A_matrix, B_matrix : matrix_3by3_8bit := (others => (others => (others => '0')));
    signal a_inter, b_inter : matrix_4by4_8bit := (others => (others => (others => '0')));
    signal acc_out_signals : matrix_3by3_16bit := (others => (others => (others => '0')));
    
    signal counter : integer range 0 to 10 := 0;
    signal result_buffer : std_logic_vector(8*BUFFER_SIZE-1 downto 0) := (others => '0');

begin

    combined_reset <= dpu_reset or reset;
    
    -- Systolic array generation with internal reset
    gen_rows: for i in 1 to 3 generate
        gen_columns: for j in 1 to 3 generate
            DPU_inst: DPU_8bit
                port map (
                    clk     => clk,
                    rst     => combined_reset,  -- Combined reset
                    a_in    => a_inter(i, j),
                    b_in    => b_inter(i, j),
                    a_out   => a_inter(i, j+1),
                    b_out   => b_inter(i+1, j),
                    acc_out => acc_out_signals(i, j)
                );
        end generate;
    end generate;

    -- Main control process
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= IDLE;
                counter <= 0;
                proc_done <= '0';
                dpu_reset <= '1';
                result_buffer <= (others => '0');
                
            else
                case current_state is
                    when IDLE =>
                        proc_done <= '0';
                        dpu_reset <= '0';
                        if proc_start = '1' then
                            -- Load matrices from input buffer
                            for i in 1 to 3 loop
                                for j in 1 to 3 loop
                                    -- First matrix (first 9 bytes)
                                    A_matrix(i,j) <= data_in(8*((i-1)*3 + j)-1 downto 8*((i-1)*3 + j - 1));
                                    -- Second matrix (next 9 bytes)
                                    B_matrix(i,j) <= data_in(8*((i-1)*3 + j + 9)-1 downto 8*((i-1)*3 + j + 8));
                                end loop;
                            end loop;
                            current_state <= LOADING;
                            counter <= 0;
                        end if;

                    when LOADING =>
                        case counter is
                            when 0 =>  -- Initial values
                                a_inter(1,1) <= A_matrix(1,1);
                                b_inter(1,1) <= B_matrix(1,1);
                                counter <= counter + 1;
                                
                            when 1 =>  -- Second wave
                                a_inter(1,1) <= A_matrix(1,2);
                                a_inter(2,1) <= A_matrix(2,1);
                                b_inter(1,1) <= B_matrix(2,1);
                                b_inter(1,2) <= B_matrix(1,2);
                                counter <= counter + 1;
                                
                            when 2 =>  -- Third wave
                                a_inter(1,1) <= A_matrix(1,3);
                                a_inter(2,1) <= A_matrix(2,2);
                                a_inter(3,1) <= A_matrix(3,1);
                                b_inter(1,1) <= B_matrix(3,1);
                                b_inter(1,2) <= B_matrix(2,2);
                                b_inter(1,3) <= B_matrix(1,3);
                                counter <= counter + 1;
                                
                            when 3 =>  -- Fourth wave
                                a_inter(2,1) <= A_matrix(2,3);
                                a_inter(3,1) <= A_matrix(3,2);
                                b_inter(1,2) <= B_matrix(3,2);
                                b_inter(1,3) <= B_matrix(2,3);
                                a_inter(1,1) <= (others => '0');
                                b_inter(1,1) <= (others => '0');
                                counter <= counter + 1;
                                
                            when 4 =>  -- Fifth wave
                                a_inter(3,1) <= A_matrix(3,3);
                                b_inter(1,3) <= B_matrix(3,3);
                                a_inter(2,1) <= (others => '0');
                                b_inter(1,2) <= (others => '0');
                                counter <= counter + 1;
                                
                            when 5 =>  -- Cleanup wave
                                a_inter(3,1) <= (others => '0');
                                b_inter(1,3) <= (others => '0');
                                counter <= counter + 1;
                                
                            when 6 to 9 =>  -- Additional cycles for propagation
                                counter <= counter + 1;
                                
                            when 10 =>  -- Complete
                                current_state <= RESET_DPUs;
                                -- Pack results into output buffer
                                for i in 1 to 3 loop
                                    for j in 1 to 3 loop
                                        result_buffer(16*((i-1)*3 + j)-1 downto 16*((i-1)*3 + j - 1)) <= 
                                            acc_out_signals(i,j);
                                    end loop;
                                end loop;
                        end case;

                    when RESET_DPUs =>
                        dpu_reset <= '1';  -- Assert reset for DPUs
                        current_state <= COMPLETE;
                        
                    when COMPLETE =>
                        dpu_reset <= '0';  -- De-assert reset
                        data_out <= result_buffer;
                        proc_done <= '1';
                        if proc_start = '0' then
                            current_state <= IDLE;
                        end if;
                        
                    when others =>
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end Behavioral;