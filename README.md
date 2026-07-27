# uFe-8
8-bit CPU for didatic purpuses.

# Requirements
Workflow is based on Synopsys tools: VCS, Verdi and FusionCompiler

# About
This CPU is inspired on the MSP430 instruction set. It is a simplified version with only 4 arithmetic/logic instructions, absolute branches, and data manipulation instructions such as MOV, ST, LD. The instruction set is described in the docs folder.

## Architecture
The CPU holds 4 registers R0 to R3. 


## Instruction SET
An instruction is 8 bit wide, and comprised of 3-bit opcode, 1-bit to encode an immediate (constant) in the instruction stack (ROM), 2-bits to encode both source and destination operands. 

OP + CTE + SRC + DST
3  +  1  +  2  +  2

// Arithmetic and Logic Operations
000 c ss dd | ADD   Rs/#i, Rd
001 c ss dd | AND   Rs/#i, Rd
010 c ss dd | XOR   Rs/#i, Rd
011 c ss dd |  OR   Rs/#i, Rd

// Memory Access (Load, Store)
100 0 ss dd | LD   @Rs, Rd 
101 c ss dd | ST    Rs/#i, @Rd

// Data manipulation
110 0 ss dd | MOV   Rs, Rd
110 1 00 dd | MOV   #i, Rd 

// Jumps (actually branches. These are absolute, not relative)
111 1 11 00 | JC    addr
111 1 11 01 | JZ    addr
111 1 11 10 | JNZ   addr
111 1 11 11 | JMP   addr

# Simulator
There is a logisim version of the CPU 
