LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY TOP IS
	PORT(
	
		-- ports d'entrée TOP
		Clk		  : IN std_logic;
		Reset		  : IN std_logic;
		
		-- ports de sortie TOP
		PC          : OUT std_logic_vector(31 downto 0);
		WriteData   : OUT std_logic_vector(31 downto 0);
		AluResult   : OUT std_logic_vector(31 downto 0)
		
	);
END; -- TOP

ARCHITECTURE structure_interne OF TOP IS	

	-- IMEM
	SIGNAL data_int        : std_logic_vector(31 DOWNTO 0);
	
	-- MIPS
	SIGNAL MemReadOut_int  : std_logic;
	SIGNAL MemWriteOut_int : std_logic;
	SIGNAL PC_int          : std_logic_vector(31 DOWNTO 0);
	SIGNAL DataAddress   : std_logic_vector(31 DOWNTO 0);
	SIGNAL WriteData_int   : std_logic_vector(31 DOWNTO 0);
	
	-- DMEM
	SIGNAL readData_int    : std_logic_vector(31 DOWNTO 0);
	
BEGIN

	-- Instanciations --
	
	-- Instance du imem
	imem : ENTITY work.imem(imem_arch)
					PORT MAP (
						
						-- Port d'entrée
						adresse => PC_int(9 downto 2),
						
						-- Port de sortie
						data => data_int
	
					);
	
	-- Instance du MIPS
	MIPS : ENTITY work.MIPS(structure_interne)
					PORT MAP (
						
						-- ports d'entrées
						
						Clk		   => Clk,
						Reset		   => Reset,
						
						Instruction => data_int,
						readData    => readData_int,
						
						-- ports de sorties
						
						MemReadOut  => MemReadOut_int,
						MemWriteOut => MemWriteOut_int,
						PC          => PC_int,
						AluResult   => DataAddress,
						WriteData   => WriteData_int
						
					);
					
	-- Instance du dmem
	dmem : ENTITY work.dmem(dmem_arch)
					PORT MAP (
						
						-- ports d'entrées
						
						clk		 => Clk,
						
						MemWrite  => MemWriteOut_int,
						MemRead   => MemReadOut_int,
						adresse   => DataAddress,
						WriteData => WriteData_int,
						
						-- ports de sortie
						ReadData  => readData_int
	
					);
					
	-- -------------- --		
	PC        <= PC_int;
	WriteData <= WriteData_int;
	AluResult <= DataAddress;
	
END structure_interne;