LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; -- For incrementing A easily

ENTITY ControlUnitTestBench IS
END ControlUnitTestBench;

ARCHITECTURE Behavioral OF ControlUnitTestBench IS
    SIGNAL GREENLIGHT : STD_LOGIC := '0'; -- only 1 when everything works

    SIGNAL CU_CLK : STD_LOGIC := '0';
    SIGNAL CU_RESET : STD_LOGIC := '0';
    SIGNAL CU_CMP : STD_LOGIC := '0';
    SIGNAL CU_OP : STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
    SIGNAL CU_AM : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL CU_ZFLAG : STD_LOGIC := '0';

    SIGNAL CU_AddressSelect : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL CU_DATASELECT : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL CU_ALUSELECT : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL CU_ALUSELECT2 : STD_LOGIC := '0';
    SIGNAL CU_REGSELECT : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL CU_PCSELECT : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL CU_DPCRSELECT : STD_LOGIC := '0';

    SIGNAL CU_PCSTORE : STD_LOGIC := '0';
    SIGNAL CU_IMSTORE : STD_LOGIC := '0';
    SIGNAL CU_IRLOAD : STD_LOGIC := '0';
    SIGNAL CU_REGSTORE : STD_LOGIC := '0';
    SIGNAL CU_ALUOP : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    SIGNAL CU_DMLOAD : STD_LOGIC := '0';
    SIGNAL CU_DMSTORE : STD_LOGIC := '0';

    SIGNAL CU_DPCRSTORE : STD_LOGIC := '0';
    SIGNAL CU_ZCLEAR : STD_LOGIC := '0';
    SIGNAL CU_ERCLEAR : STD_LOGIC := '0';
    SIGNAL CU_EOTCLEAR : STD_LOGIC := '0';
    SIGNAL CU_EOTSET : STD_LOGIC := '0';
    SIGNAL CU_SVOPSET : STD_LOGIC := '0';
    SIGNAL CU_SOPSET : STD_LOGIC := '0';

    COMPONENT ControlUnit IS
        PORT (
            -- INPUTS
            CLK : IN STD_LOGIC;
            Reset : IN STD_LOGIC;
            CMP0 : IN STD_LOGIC;
            OP_Code : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
            AM : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            Z_Flag : IN STD_LOGIC;

            -- OUTPUTS DATA FLOW
            Address_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            Data_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALU_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALU_Select_2 : OUT STD_LOGIC;
            Reg_Select : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            PC_Select : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            DPCR_Select : OUT STD_LOGIC;

            -- OUTPUTS MIAN CONTROL
            PC_Store : OUT STD_LOGIC;
            IM_Store : OUT STD_LOGIC;
            IR_Load : OUT STD_LOGIC;
            Reg_Store : OUT STD_LOGIC;
            ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            DM_LOAD : OUT STD_LOGIC;
            DM_STORE : OUT STD_LOGIC;

             -- OUTPUTS IO / REG CONTROL
            DPCR_Store : OUT STD_LOGIC;
            Z_Clear : OUT STD_LOGIC;
            ER_Clear : OUT STD_LOGIC;
            EOT_Clear : OUT STD_LOGIC;
            EOT_Set : OUT STD_LOGIC;
            SVOP_Set : OUT STD_LOGIC;
            SOP_Set : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Non-critical variables
    TYPE commandArray IS ARRAY (0 TO 30) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL commands : commandArray := ("01001000", "11001000", "01001100", "11001100", "01111000", "11111000", "01000100", "01000011", "01000000", "11000000", "10000000", "01000010", "11000010", "10000010", "01011000", "11011000", "01011100", "11101000", "01101001", "01010100", "00010000", "00111100", "00111110", "00111111", "11110110", "11111011", "11110111", "11111010", "00110100", "01011110", "10101010");
    SIGNAL indexPtr : INTEGER := 0; -- for the commands array
    TYPE sArray IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL bonus : sArray := ("00", "01", "10", "11");
    SIGNAL bIndexPtr : INTEGER := 3;
    SIGNAL SAFETY : INTEGER := 2;
    SIGNAL LOOKUP_VECTOR : STD_LOGIC_VECTOR(28 DOWNTO 0) := "00000000000000000000000000000"; -- this is the lookup vector for the control unit
    CONSTANT const_addressSelect : INTEGER := 28;
    CONSTANT const_dataSelect : INTEGER := 26;
    CONSTANT const_ALUSelect : INTEGER := 24;
    CONSTANT const_ALUSelect2 : INTEGER := 22;
    CONSTANT const_regSelect : INTEGER := 21;
    CONSTANT const_PCSelect : INTEGER := 18;
    CONSTANT const_DPCRSelect : INTEGER := 16;
    CONSTANT const_PCStore : INTEGER := 15;
    CONSTANT const_IMStore : INTEGER := 14;
    CONSTANT const_IRLoad : INTEGER := 13;
    CONSTANT const_regStore : INTEGER := 12;
    CONSTANT const_ALUOP : INTEGER := 11;
    CONSTANT const_DMLOAD : INTEGER := 8;
    CONSTANT const_DMSTORE : INTEGER := 7;
    CONSTANT const_DPCRStore : INTEGER := 6;
    CONSTANT const_ZClear : INTEGER := 5;
    CONSTANT const_ERClear : INTEGER := 4;
    CONSTANT const_EOTClear : INTEGER := 3;
    CONSTANT const_EOTSet : INTEGER := 2;
    CONSTANT const_SVOPSet : INTEGER := 1;
    CONSTANT const_SOPSet : INTEGER := 0;

    --
    SIGNAL TESTING : STD_LOGIC_VECTOR(28 DOWNTO 0) := "00000000000000000000000000000"; -- this is the lookup vector for the control unit
    SIGNAL CURRENT_STATE : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; -- this is the current state of the control unit
    SIGNAL COMPARING0 : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    SIGNAL COMPARINGZ : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    SIGNAL COMPARINGZCLEAR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    SIGNAL COMPARINGERCLEAR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    SIGNAL COMPARINGEOTCLEAR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
    SIGNAL COMPARINGEOTSET : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";

    PROCEDURE checkVector(
        SIGNAL TESTING : IN STD_LOGIC_VECTOR(28 DOWNTO 0);
        SIGNAL CURRENT_STATE : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        SIGNAL COMPARING0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        SIGNAL COMPARINGZ : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        SIGNAL COMPARINGZCLEAR : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        SIGNAL COMPARINGERCLEAR : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        SIGNAL COMPARINGEOTCLEAR : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        SIGNAL COMPARINGEOTSET : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        SIGNAL GREEN_LIGHT : OUT STD_LOGIC) IS

    BEGIN
        CASE current_state(7 DOWNTO 0) IS
            WHEN "01001000" =>
                IF
                    (TESTING(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) = "0") AND
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "100") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_ALUOP DOWNTO (const_DMLOAD + 1)) = "10")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11001000" =>
                IF
                    (TESTING(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) = "1") AND
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "100") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_ALUOP DOWNTO (const_DMLOAD + 1)) = "10")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01001100" =>
                IF
                    (TESTING(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) = "0") AND
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "100") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_ALUOP DOWNTO (const_DMLOAD + 1)) = "11")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11001100" =>
                IF
                    (TESTING(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) = "1") AND
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "100") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_ALUOP DOWNTO (const_DMLOAD + 1)) = "11")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01111000" =>
                IF
                    (TESTING(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) = "0") AND
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "100") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_ALUOP DOWNTO (const_DMLOAD + 1)) = "00")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11111000" =>
                IF
                    (TESTING(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) = "1") AND
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "100") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_ALUOP DOWNTO (const_DMLOAD + 1)) = "00")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01000100" =>
                IF
                    (TESTING(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) = "0") AND
                    (TESTING(const_ALUSelect2 DOWNTO (const_regSelect + 1)) = "1") AND
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "100") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_ALUOP DOWNTO (const_DMLOAD + 1)) = "01")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01000011" =>
                IF
                    (TESTING(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) = "0") AND
                    (TESTING(const_ALUSelect2 DOWNTO (const_regSelect + 1)) = "1") AND
                    (TESTING(const_ALUOP DOWNTO (const_DMLOAD + 1)) = "01")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01000000" =>
                IF
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "100") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11000000" =>
                IF
                    (TESTING(const_addressSelect DOWNTO (const_dataSelect + 1)) = "10") AND
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "11") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_DMLOAD DOWNTO (const_DMSTORE + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "10000000" =>
                IF
                    (TESTING(const_addressSelect DOWNTO (const_dataSelect + 1)) = "0") AND
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "11") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_DMLOAD DOWNTO (const_DMSTORE + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01000010" =>
                IF
                    (TESTING(const_addressSelect DOWNTO (const_dataSelect + 1)) = "1") AND
                    (TESTING(const_dataSelect DOWNTO (const_ALUSelect + 1)) = "0") AND
                    (TESTING(const_DMSTORE DOWNTO (const_DPCRStore + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11000010" =>
                IF
                    (TESTING(const_addressSelect DOWNTO (const_dataSelect + 1)) = "1") AND
                    (TESTING(const_dataSelect DOWNTO (const_ALUSelect + 1)) = "1") AND
                    (TESTING(const_DMSTORE DOWNTO (const_DPCRStore + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "10000010" =>
                IF
                    (TESTING(const_addressSelect DOWNTO (const_dataSelect + 1)) = "0") AND
                    (TESTING(const_dataSelect DOWNTO (const_ALUSelect + 1)) = "1") AND
                    (TESTING(const_DMSTORE DOWNTO (const_DPCRStore + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01011000" =>
                IF
                    (TESTING(const_PCSelect DOWNTO (const_DPCRSelect + 1)) = "01")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11011000" =>
                IF
                    (TESTING(const_PCSelect DOWNTO (const_DPCRSelect + 1)) = "10")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01011100" =>
                IF
                    (TESTING(const_PCSelect DOWNTO (const_DPCRSelect + 1)) = "01") AND
                    (TESTING(const_PCStore DOWNTO (const_IMStore + 1)) = COMPARING0)
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11101000" =>
                IF
                    (TESTING(const_DPCRSelect DOWNTO (const_PCStore + 1)) = "0") AND
                    (TESTING(const_DMSTORE DOWNTO (const_DPCRStore + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01101001" =>
                IF
                    (TESTING(const_DPCRSelect DOWNTO (const_PCStore + 1)) = "1") AND
                    (TESTING(const_DMSTORE DOWNTO (const_DPCRStore + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01010100" =>
                IF
                    (TESTING(const_PCSelect DOWNTO (const_DPCRSelect + 1)) = "01") AND
                    (TESTING(const_PCStore DOWNTO (const_IMStore + 1)) = COMPARINGZ)
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "00010000" =>
                -- IF 
                --     THEN
                GREEN_LIGHT <= 'X';
                -- END IF;
            WHEN "00111100" =>
                -- IF
                --     THEN
                GREEN_LIGHT <= 'X';
                -- END IF;
            WHEN "00111110" =>
                -- IF
                --     THEN
                GREEN_LIGHT <= 'X';
                -- END IF;
            WHEN "00111111" =>
                -- IF
                --     THEN
                GREEN_LIGHT <= 'X';
                -- END IF;
            WHEN "11110110" =>
                IF
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "001") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11111011" =>
                IF
                    (TESTING(const_SVOPSet DOWNTO (const_SOPSet + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11110111" =>
                IF
                    (TESTING(const_regSelect DOWNTO (const_PCSelect + 1)) = "010") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "11111010" =>
                IF
                    (TESTING(const_SOPSet DOWNTO 0) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "00110100" =>
                IF 0 = 0
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "01011110" =>
                IF
                    (TESTING(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) = "0") AND
                    (TESTING(const_ALUSelect2 DOWNTO (const_regSelect + 1)) = "1") AND
                    (TESTING(const_regStore DOWNTO (const_ALUOP + 1)) = "1") AND
                    (TESTING(const_ALUOP DOWNTO (const_DMLOAD + 1)) = "101")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN "10101010" =>
                IF
                    (TESTING(const_addressSelect DOWNTO (const_dataSelect + 1)) = "0") AND
                    (TESTING(const_dataSelect DOWNTO (const_ALUSelect + 1)) = "10") AND
                    (TESTING(const_DMSTORE DOWNTO (const_DPCRStore + 1)) = "1")
                    THEN
                    GREEN_LIGHT <= '1';
                END IF;
            WHEN OTHERS =>
                GREEN_LIGHT <= '0'; -- this is the default case, if nothing matches, then it is an error
        END CASE;

    END PROCEDURE checkVector;

BEGIN

    DUT : ControlUnit
    PORT MAP(
        -- INPUTS
        CLK => CU_CLK,
        Reset => CU_RESET,
        CMP0 => CU_CMP,
        OP_Code => CU_OP,
        AM => CU_AM,
        Z_Flag => CU_ZFLAG,

        -- OUTPUTS DATA FLOW
        Address_Select => CU_AddressSelect,
        Data_Select => CU_DATASELECT,
        ALU_Select => CU_ALUSELECT,
        ALU_Select_2 => CU_ALUSELECT2,
        Reg_Select => CU_REGSELECT,
        PC_Select => CU_PCSELECT,
        DPCR_Select => CU_DPCRSELECT,

        -- OUTPUTS MIAN CONTROL
        PC_Store => CU_PCSTORE,
        IM_Store => CU_IMSTORE,
        IR_Load => CU_IRLOAD,
        Reg_Store => CU_REGSTORE,
        ALU_OP => CU_ALUOP,
        DM_LOAD => CU_DMLOAD,
        DM_STORE => CU_DMSTORE,

        -- OUTPUTS IO / REG CONTROL
        DPCR_Store => CU_DPCRSTORE,
        Z_Clear => CU_ZCLEAR,
        ER_Clear => CU_ERCLEAR,
        EOT_Clear => CU_EOTCLEAR,
        EOT_Set => CU_EOTSET,
        SVOP_Set => CU_SVOPSET,
        SOP_Set => CU_SOPSET
    );

    CU_CLK <= NOT CU_CLK AFTER 10 ns; -- 50 MHz clock
    -- Stimulus process
    whatDoesThisNameDo : PROCESS
    BEGIN
        CU_CMP <= bonus(bIndexPtr)(1);
        CU_ZFLAG <= bonus(bIndexPtr)(0);

        CU_AM <= commands(indexPtr)(7 DOWNTO 6); -- because AM comes first
        CU_OP <= commands(indexPtr)(5 DOWNTO 0);

        -- indexPtr <= (indexPtr + 1) mod 31; -- this should loop through the array

        bIndexPtr <= (bIndexPtr + 1) MOD 4;
        IF bIndexPtr = 0 AND SAFETY = 0 THEN
            indexPtr <= (indexPtr + 1) MOD 31;
        END IF;

        IF SAFETY > 0 THEN
            SAFETY <= SAFETY - 1;
        END IF;

        -- for testing purposes
        LOOKUP_VECTOR(const_addressSelect DOWNTO (const_dataSelect + 1)) <= CU_AddressSelect;
        LOOKUP_VECTOR(const_dataSelect DOWNTO (const_ALUSelect + 1)) <= CU_DataSelect;
        LOOKUP_VECTOR(const_ALUSelect DOWNTO (const_ALUSelect2 + 1)) <= CU_ALUSELECT;
        LOOKUP_VECTOR(const_ALUSelect2 DOWNTO (const_regSelect + 1)) <= (OTHERS => CU_ALUSELECT2);
        LOOKUP_VECTOR(const_regSelect DOWNTO (const_PCSelect + 1)) <= CU_REGSELECT;
        LOOKUP_VECTOR(const_PCSelect DOWNTO (const_DPCRSelect + 1)) <= CU_PCSELECT;
        LOOKUP_VECTOR(const_DPCRSelect DOWNTO (const_PCStore + 1)) <= (OTHERS => CU_DPCRSELECT);
        LOOKUP_VECTOR(const_PCStore DOWNTO (const_IMStore + 1)) <= (OTHERS => CU_PCSTORE);
        LOOKUP_VECTOR(const_IMStore DOWNTO (const_IRLoad + 1)) <= (OTHERS => CU_IMSTORE);
        LOOKUP_VECTOR(const_IRLoad DOWNTO (const_regStore + 1)) <= (OTHERS => CU_IRLOAD);
        LOOKUP_VECTOR(const_regStore DOWNTO (const_ALUOP + 1)) <= (OTHERS => CU_REGSTORE);
        LOOKUP_VECTOR(const_ALUOP DOWNTO (const_DMLOAD + 1)) <= CU_ALUOP;
        LOOKUP_VECTOR(const_DMLOAD DOWNTO (const_DMSTORE + 1)) <= (OTHERS => CU_DMLOAD);
        LOOKUP_VECTOR(const_DMSTORE DOWNTO (const_DPCRStore + 1)) <= (OTHERS => CU_DMSTORE);
        LOOKUP_VECTOR(const_DPCRStore DOWNTO (const_ZClear + 1)) <= (OTHERS => CU_DPCRSTORE);
        LOOKUP_VECTOR(const_ZClear DOWNTO (const_ERClear + 1)) <= (OTHERS => CU_ZCLEAR);
        LOOKUP_VECTOR(const_ERClear DOWNTO (const_EOTClear + 1)) <= (OTHERS => CU_ERCLEAR);
        LOOKUP_VECTOR(const_EOTClear DOWNTO (const_EOTSet + 1)) <= (OTHERS => CU_EOTCLEAR);
        LOOKUP_VECTOR(const_EOTSet DOWNTO (const_SVOPSet + 1)) <= (OTHERS => CU_EOTSET);
        LOOKUP_VECTOR(const_SVOPSet DOWNTO (const_SOPSet + 1)) <= (OTHERS => CU_SVOPSET);
        LOOKUP_VECTOR(const_SOPSet DOWNTO 0) <= (OTHERS => CU_SOPSET);
        CURRENT_STATE <= commands(indexPtr)(7 DOWNTO 0); -- this is the current state of the control unit
        COMPARING0 <= (OTHERS => CU_CMP);
        COMPARINGZ <= (OTHERS => CU_ZFLAG);
        COMPARINGZCLEAR <= (OTHERS => CU_ZCLEAR);
        COMPARINGERCLEAR <= (OTHERS => CU_ERCLEAR);
        COMPARINGEOTCLEAR <= (OTHERS => CU_EOTCLEAR);
        COMPARINGEOTSET <= (OTHERS => CU_EOTSET);
        checkVector(LOOKUP_VECTOR, CURRENT_STATE, COMPARING0, COMPARINGZ, COMPARINGZCLEAR, COMPARINGERCLEAR, COMPARINGEOTCLEAR, COMPARINGEOTSET, GREENLIGHT);

        WAIT FOR 10 ns; -- Wait for the clock to toggle
    END PROCESS;

END Behavioral;