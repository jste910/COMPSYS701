-- Not Morteza

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

USE work.recop_types.ALL;
USE work.opcodes.ALL;
USE work.various_constants.ALL;

ENTITY ArithmaticLogicUnit IS

    PORT (
        clk : IN bit_1;
        z_flag : OUT bit_1;
        -- ALU operation selection
        alu_operation : IN bit_3;
        -- operand selection
        alu_op1_sel : IN bit_2;
        alu_op2_sel : IN bit_1;
        alu_carry : IN bit_1; --WARNING: carry in currently is not used
        alu_result : OUT bit_16 := X"0000";
        -- operands
        rx : IN bit_16;
        rz : IN bit_16;
        ir_operand : IN bit_16;
        -- flag control signal
        clr_z_flag : IN bit_1;
        reset : IN bit_1;
        ALU_SELECT : IN bit_2
    );

END ENTITY ArithmaticLogicUnit;
ARCHITECTURE behavior OF ArithmaticLogicUnit IS

    COMPONENT alu
        PORT (
            clk : IN bit_1;
            z_flag : OUT bit_1;
            -- ALU operation selection
            alu_operation : IN bit_3;
            -- operand selection
            alu_op1_sel : IN bit_2;
            alu_op2_sel : IN bit_1;
            alu_carry : IN bit_1; --WARNING: carry in currently is not used
            alu_result : OUT bit_16 := X"0000";
            -- operands
            rx : IN bit_16;
            rz : IN bit_16;
            ir_operand : IN bit_16;
            -- flag control signal
            clr_z_flag : IN bit_1;
            reset : IN bit_1
        );
    END COMPONENT;

BEGIN

    Al : alu
    PORT MAP(
        clk => clk,
        z_flag => z_flag,
        -- ALU operation selection
        alu_operation => alu_operation,
        -- operand selection
        alu_op1_sel => alu_op1_sel,
        alu_op2_sel => alu_op2_sel,
        alu_carry => alu_carry, --WARNING: carry in currently is not used
        alu_result => alu_result,
        -- operands
        rx => rx,
        rz => rz,
        ir_operand => ir_operand,
        -- flag control signal
        clr_z_flag => CLR_Z_FLAG,
        reset => reset
    );

    PROCESS (clk, reset)
    BEGIN
        CASE ALU_SELECT IS
            WHEN "00" => -- ALU operation selection
                alu_result <= "0000000000000000"; -- ADD operation
            WHEN "01" => -- operand selection
                alu_result <= "0000000000000000"; -- ADD operation
            WHEN "10" => -- operand selection
                alu_result <= "0000000000000000"; -- ADD operation
            WHEN OTHERS =>
                alu_result <= "0000000000000000"; -- ADD operation
        END CASE;
    END PROCESS;
END behavior;