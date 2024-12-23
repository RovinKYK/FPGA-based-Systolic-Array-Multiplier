# Matrix Multiplication Accelerator (Design-02)

A VHDL implementation of a matrix multiplication accelerator using a systolic array architecture with UART interface. This design represents the complete version, building upon the concepts explored in design-01.

## Features

- 3x3 matrix multiplication using systolic array architecture
- UART communication interface (115200 baud rate)
- Buffered data handling
- 8-bit precision for input values
- Fully pipelined design for efficient processing
- Automated test bench included

## Hardware Requirements

- FPGA board with minimum 100MHz clock
- UART interface capability
- Pins as specified in constraints.xdc

## Project Structure

- `DPU.vhd`: Data Processing Unit implementation
- `Systolic_Array.vhd`: Main systolic array architecture
- `UART_controller.vhd`: Top-level UART control
- `UART_buffer.vhd`: Data buffering between UART and processor
- `UART.vhd`, `UART_rx.vhd`, `UART_tx.vhd`: UART communication modules
- `TB_Systolic_Array.vhd`: Test bench for verification
- `constraints.xdc`: Pin constraints for FPGA implementation

## Usage

1. Configure UART settings (115200 baud rate, 8-bit data)
2. Send two 3x3 matrices sequentially through UART
3. System automatically processes the multiplication
4. Results are transmitted back through UART

## Implementation Notes

- Clock frequency: 100MHz
- Input format: Row-major order
- Output: 16-bit precision results
