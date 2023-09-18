LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY datapath IS
	PORT(
		
		-- Ports entrees
		Clk         : IN std_logic;
		Reset       : IN std_logic;
		
		MemToReg   : IN std_logic;
		MemWrite   : IN std_logic;
		MemRead    : IN std_logic;
		Branch     : IN std_logic;
		AluSrc     : IN std_logic;
		RegDst     : IN std_logic;
		RegWrite   : IN std_logic;
		Jump       : IN std_logic;
		AluControl : IN std_logic_vector(3 downto 0);
		
		Instruction : IN std_logic_vector(31 downto 0);
		ReadData    : IN std_logic_vector(31 downto 0);
		
		-- Ports sorties
		MemReadOut  : OUT std_logic;
		MemWriteOut : OUT std_logic;
		PC          : OUT std_logic_vector(31 downto 0);
		AluResult   : OUT std_logic_vector(31 downto 0);
		WriteData   : OUT std_logic_vector(31 downto 0)
		
	);
END; -- DATAPATH

ARCHITECTURE structure_interne OF datapath IS	

	-- Signaux internes pour le Registre
	SIGNAL WriteReg1     : std_logic_vector(4 DOWNTO 0);
	SIGNAL Result        : std_logic_vector(31 DOWNTO 0);
	SIGNAL ReadData1     : std_logic_vector(31 DOWNTO 0);
	SIGNAL ReadData2     : std_logic_vector(31 DOWNTO 0);	
	
	-- Signaux internes pour l'ALU
	SIGNAL sortie_mux_alusrc : std_logic_vector(31 DOWNTO 0);
	SIGNAL sortie_result     : std_logic_vector(31 DOWNTO 0);
	SIGNAL sortie_zero       : std_logic;
	
	-- Signaux interne pour le PC
	SIGNAL PCNext    : std_logic_vector(31 downto 0);
	SIGNAL PC_int    : std_logic_vector(31 downto 0) := (OTHERS => '0');
	SIGNAL PCNextBr  : std_logic_vector(31 downto 0);
	SIGNAL PCJump    : std_logic_vector(31 downto 0);
	SIGNAL PCPlus4   : std_logic_vector(31 downto 0);
	SIGNAL PCBranch  : std_logic_vector(31 downto 0);
	SIGNAL SignImm   : std_logic_vector(31 downto 0);
	SIGNAL SignImmSh : std_logic_vector(31 downto 0);
	
BEGIN

	-- Instanciations --
	
	-- Instance du registre de Regfile
		registre : ENTITY work.regfile(RegFile_arch)
					  PORT MAP (
					  
						Clk => Clk,
						we  => RegWrite,
						
						ra1 => Instruction(25 downto 21),
						ra2 => Instruction(20 downto 16),
						wa  => WriteReg1,
						wd  => Result,
						
						rd1 => ReadData1,
						rd2 => ReadData2
						
				 );
		
		-- Instance du ALU du projet 1
		ALU : ENTITY work.ual(rtl)
						PORT MAP (
							
							ualControl => AluControl,
							
							srcA		  => ReadData1,
							srcB       => sortie_mux_alusrc,
						
							result     => sortie_result,
							zero 		  => sortie_zero
						
						);
						
	-- -------------- --
	
	-- LOGIQUE PC
	
	Bascule_PC : PROCESS(Clk, Reset)
	BEGIN
		
		IF (Reset = '1') THEN
		
			PC_int <= (OTHERS => '0');
		
		ELSIF (rising_edge(Clk)) THEN
		
			PC_int <= PCNext;
		
		END IF;
	
	END PROCESS Bascule_PC;
	
	PCPlus4  <= std_logic_vector(unsigned(PC_int) + 4);
	
	-- Calcul le PC Jump
	PCJump   <= PCPlus4(31 downto 28) & std_logic_vector(shift_left(unsigned(Instruction(25 downto 0)), 2)) & "00";
	
	-- Calcul le PC Branch
	SignImm   <= std_logic_vector(resize(signed(Instruction(15 downto 0)), SignImm'length));
	SignImmSh <= std_logic_vector(shift_left(signed(SignImm), 2));
	PCBranch  <= std_logic_vector(unsigned(PCPlus4) + unsigned(SignImmSh));

	-- mux PCSrc
	--PCNextBr <= PCBranch WHEN Branch = '1' AND sortie_zero = '1' ELSE PCPlus4;
	
	-- mux Jump
	PCNext   <= PCBranch        WHEN Branch = '1' ELSE
					PCJump          WHEN Jump = '1'   ELSE
					PCPlus4;
	
	
	
	-- LOGIQUE REGISTRE --
	WriteReg1 <= Instruction(20 downto 16) WHEN RegDst = '0' ELSE
					 Instruction(15 downto 11);
					 
	Result    <= ReadData WHEN MemtoReg = '1' ELSE
					 sortie_result;
					 
	-- LOGIQUE UAL      --
	sortie_mux_alusrc <= ReadData2 WHEN AluSrc = '0' ELSE
								SignImm;
	
	-- Sorties DataPath --
	MemReadOut  <= MemRead;
	MemWriteOut <= MemWrite;
	PC          <= PC_int;
	AluResult   <= sortie_result;
	WriteData   <= ReadData2;
	
	

END structure_interne;









