# Matrix Multiplication Implementation (Design-01)

This is the initial prototype design for implementing matrix multiplication on a Basys3 FPGA board. The design focuses on multiplying two 3x3 matrices using two different approaches:

1. A systolic array implementation
2. A standard matrix multiplication implementation

## Features

- Implements 3x3 matrix multiplication
- Supports 3-bit input values
- Displays results on the Basys3's 7-segment display
- Includes both systolic array and standard multiplication methods
- Contains comprehensive test benches for verification

## Components

- Clock Generator
- Display State Controller
- LUT for 7-segment Display
- Matrix Multiplication Controllers (Systolic and Standard)
- Data Processing Units (DPUs)

## Hardware Requirements

- Basys3 FPGA Board
- Xilinx Vivado for synthesis and implementation

## Testing

The design includes test benches for all major components:
- Individual DPU testing
- Complete matrix multiplication verification
- Display controller validation
- Comparison between multiplication methods
