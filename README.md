# Matrix Multiplication Using Systolic Array on FPGA

This project explores the implementation of matrix multiplication using a systolic array architecture on an FPGA. It provides two designs that demonstrate different approaches to achieve efficient and scalable matrix multiplication.

## Designs

- [**Design-01**: Initial Prototype Implementation](./Design-01)  
  This prototype focuses on implementing 3x3 matrix multiplication using both systolic array and standard methods. It includes a display controller for results visualization and test benches for verification.

- [**Design-02**: Complete Accelerator with UART Interface](./Design-02)  
  This enhanced design builds upon the prototype and incorporates a UART interface for communication, buffered data handling, and 8-bit precision inputs. It is fully pipelined for high efficiency and includes automated test benches.

## Project Report

The project report provides an in-depth discussion of the implementation details, architectural considerations, and results. [**Link to Project Report (PDF)**](https://drive.google.com/file/d/1yXFW3y4D8ff6LSvk0fo420ny9tUrlQnj/view?usp=sharing)

## Repository Highlights

- VHDL source code for systolic array-based matrix multiplication
- Comprehensive test benches for all major components
- Modular and reusable design
- FPGA-specific constraints and configuration files

---

For details on individual designs, refer to the README files inside their respective folders.
