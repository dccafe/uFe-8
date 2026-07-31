import sys
import re

# Tabela de Opcodes
OPCODES = {
    'ADD': 0b000,
    'AND': 0b001,
    'XOR': 0b010,
    'OR':  0b011,
    'LD':  0b100,
    'ST':  0b101,
    'MOV': 0b110,
}

# Saltos do tipo 111 1 11 xx
JUMPS = {
    'JC':  0b00,
    'JZ':  0b01,
    'JNZ': 0b10,
    'JMP': 0b11,
}

REGISTERS = {
    'R0': 0,
    'R1': 1,
    'R2': 2,
    'R3': 3,
}

def parse_val(val_str, labels, current_pc, line_num):
    """
    Converte números (dec, hex, bin), labels ou o símbolo '$' (PC atual)
    suportando pequenos deslocamentos como '$+2' ou '$-1'.
    """
    val_str = val_str.strip()

    # Substitui o símbolo '$' pelo valor do PC atual
    if '$' in val_str:
        val_str = val_str.replace('$', str(current_pc))
        # Resolve expressões simples de adição/subtração se houver (ex: 4+2 ou 4-1)
        try:
            val_str = str(eval(val_str, {"__builtins__": None}, {}))
        except Exception:
            raise SyntaxError(f"Linha {line_num}: Expressão inválida com '$' -> '{val_str}'")

    # Tenta resolver por Label
    if val_str in labels:
        return labels[val_str]

    # Tenta resolver literais numéricos
    try:
        if val_str.startswith(("0x", "0X")):
            val = int(val_str, 16)
        elif val_str.startswith(("0b", "0B")):
            val = int(val_str, 2)
        else:
            val = int(val_str)
        return val & 0xFF
    except ValueError:
        raise SyntaxError(f"Linha {line_num}: Valor ou label inválido '{val_str}'")


def assemble(source_code):
    raw_lines = source_code.split('\n')
    
    # -------------------------------------------------------------
    # PASSO 1: Validação de Sintaxe, Labels e Mapeamento de PC
    # -------------------------------------------------------------
    labels = {}
    cleaned_lines = []
    current_pc = 0

    for idx, raw_line in enumerate(raw_lines, start=1):
        # Remove comentários (; ou //) mantendo recuo original
        line_no_comments = re.sub(r'(;|//).*$', '', raw_line).rstrip()
        
        if not line_no_comments.strip():
            continue

        has_leading_space = line_no_comments[0] in (' ', '\t')
        line_str = line_no_comments.strip()

        # CASO 1: A linha NÃO começa com espaço/TAB (Regra de Label)
        if not has_leading_space:
            if ':' not in line_str:
                raise SyntaxError(
                    f"Erro na linha {idx}: Instruções devem ser alinhadas com Espaço ou TAB.\n"
                    f"  -> '{raw_line.strip()}'"
                )
            
            parts = line_str.split(':', 1)
            label_name = parts[0].strip()

            if not label_name or ' ' in label_name or '\t' in label_name:
                raise SyntaxError(f"Erro na linha {idx}: Nome de rótulo inválido '{label_name}'")

            labels[label_name] = current_pc
            remainder = parts[1]

            if remainder:
                if not remainder.startswith((' ', '\t')):
                    raise SyntaxError(
                        f"Erro na linha {idx}: Exigido espaço ou TAB após o rótulo '{label_name}:'."
                    )
                line_instruction = remainder.strip()
            else:
                line_instruction = ""

        # CASO 2: A linha COMEÇA com espaço/TAB
        else:
            if ':' in line_str:
                label_candidate = line_str.split(':')[0]
                raise SyntaxError(
                    f"Erro na linha {idx}: O rótulo '{label_candidate}' deve iniciar no 1º caractere da linha (coluna 0)."
                )
            line_instruction = line_str

        if not line_instruction:
            continue

        # Calcula o tamanho da instrução
        tokens = re.split(r'[\s,]+', line_instruction)
        mnemonic = tokens[0].upper()

        has_immediate = False
        if mnemonic in JUMPS:
            has_immediate = True
        else:
            for token in tokens[1:]:
                if token.startswith('#') or (
                    mnemonic == 'LD' and token.startswith('@') and not any(r in token.upper() for r in REGISTERS)
                ):
                    has_immediate = True
                    break

        cleaned_lines.append((idx, current_pc, line_instruction, has_immediate))
        current_pc += 2 if has_immediate else 1

    # -------------------------------------------------------------
    # PASSO 2: Geração do Código de Máquina
    # -------------------------------------------------------------
    machine_code = []

    for line_num, pc, line, _ in cleaned_lines:
        tokens = [t for t in re.split(r'[\s,]+', line) if t]
        mnemonic = tokens[0].upper()

        # --- Saltos (JC, JZ, JNZ, JMP) ---
        if mnemonic in JUMPS:
            if len(tokens) < 2:
                raise SyntaxError(f"Linha {line_num}: Instrução '{mnemonic}' exige um endereço/label/$.")
            
            cond = JUMPS[mnemonic]
            b1 = (0b111 << 5) | (1 << 4) | (0b11 << 2) | cond
            addr = parse_val(tokens[1], labels, pc, line_num)
            
            machine_code.append(b1)
            machine_code.append(addr)
            continue

        # --- Operações Gerais (ADD, AND, XOR, OR, LD, ST, MOV) ---
        if mnemonic not in OPCODES:
            raise SyntaxError(f"Linha {line_num}: Instrução desconhecida '{mnemonic}'")

        if len(tokens) < 3:
            raise SyntaxError(f"Linha {line_num}: Instrução '{mnemonic}' exige 2 operandos.")

        opcode = OPCODES[mnemonic]
        src_token = tokens[1]
        dst_token = tokens[2]

        cte = 0
        src_reg = 0
        dst_reg = 0
        imm_val = None

        # Fonte (src)
        if src_token.startswith('#'):
            cte = 1
            imm_val = parse_val(src_token[1:], labels, pc, line_num)
            src_reg = 0
        elif mnemonic == 'LD' and src_token.startswith('@'):
            inner = src_token[1:].strip().upper()
            if inner in REGISTERS:
                src_reg = REGISTERS[inner]
            else:
                cte = 1
                imm_val = parse_val(inner, labels, pc, line_num)
                src_reg = 0
        else:
            clean_src = src_token.upper()
            if clean_src in REGISTERS:
                src_reg = REGISTERS[clean_src]
            else:
                raise SyntaxError(f"Linha {line_num}: Operando de origem inválido '{src_token}'")

        # Destino (dst)
        if dst_token.startswith('@'):
            clean_dst = dst_token[1:].upper()
            if clean_dst in REGISTERS:
                dst_reg = REGISTERS[clean_dst]
            else:
                raise SyntaxError(f"Linha {line_num}: Destino indireto inválido '{dst_token}'")
        else:
            clean_dst = dst_token.upper()
            if clean_dst in REGISTERS:
                dst_reg = REGISTERS[clean_dst]
            else:
                raise SyntaxError(f"Linha {line_num}: Registrador de destino inválido '{dst_token}'")

        if mnemonic == 'LD':
            cte = 1

        b1 = (opcode << 5) | (cte << 4) | (src_reg << 2) | dst_reg
        machine_code.append(b1)

        if cte == 1:
            if imm_val is None:
                imm_val = 0
            machine_code.append(imm_val & 0xFF)

    return machine_code


# -------------------------------------------------------------
# Exemplo de Teste
# -------------------------------------------------------------
if __name__ == "__main__":
    
    codigo_valido = """
mult: 
    MOV #4, R2
    MOV #3, R3

    MOV #0, R0
    MOV #0, R1

mult_loop:
    ADD R2, R0
    JC  mult_c
    JMP mult_dec

mult_c:
    ADD #1, R1

mult_dec:
    ADD #-1, R3
    JNZ mult_loop

    JMP $
"""

    print("--- Teste com Código Válido ---")
    try:
        bytes_out = assemble(codigo_valido)
        for i, b in enumerate(bytes_out):
            print(f"PC={i:02d}: {b:08b} | 0x{b:02X}")
    except SyntaxError as e:
        print(e)

