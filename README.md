# uFe8
8-bit CPU for didatic purposes.

# Requirements
Workflow is based on Synopsys tools: VCS, Verdi and FusionCompiler

# About
This CPU is inspired on the MSP430 instruction set. It is a simplified version with only 4 arithmetic/logic instructions, absolute branches, and data manipulation instructions such as MOV, ST, LD. The instruction set is described in the docs folder.

## Architecture
The CPU holds 4 registers R0 to R3. 


## Instruction SET
An instruction is 8 bit wide, and comprised of 3-bit opcode, 1-bit to encode an immediate (constant) in the instruction stack (ROM), 2-bits to encode both source and destination operands. 

Instruction fields
| opcode (3 bits) | cte (1 bit) | src (2 bits) | dst (2 bits) |
|        ---      |     ---     |      ---     |      ---     |

If `cte = 1`, then the instruction composed of 2 bytes. The first byte
is the instruction, the second is the constant


| Instruction | Syntax | Description | 
|     ---     |   ---  |     ---     |
| `000 c ss dd` | `ADD   Rs/#i,  Rd` | Rd += Rs | 
| `001 c ss dd` | `AND   Rs/#i,  Rd` | Rd &= Rs |
| `010 c ss dd` | `XOR   Rs/#i,  Rd` | Rd ^= Rs |
| `011 c ss dd` | ` OR   Rs/#i,  Rd` | Rd |= Rs | 
| `100 0 ss dd` | `LD   @Rs/@i,  Rd` | Rd = data from bus addr Rs or i  | 
| `101 c ss dd` | `ST    Rs/#i, @Rd` | Source is written to bus addr Rd |
| `110 c ss dd` | `MOV   Rs/#i,  Rd` | Rd = Rs | 
| `111 1 11 00` | `JC    addr`       | PC = addr, if C = 1 |
| `111 1 11 01` | `JZ    addr`       | PC = addr, if Z = 1 |
| `111 1 11 10` | `JNZ   addr`       | PC = addr, if Z = 0 |
| `111 1 11 11` | `JMP   addr`       | PC = addr, always   |

# Simulator
There is a logisim version of the CPU 
