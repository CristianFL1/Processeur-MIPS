--========================= imem.vhd ============================
-- ELE-343 Conception des syst�mes ordin�s
-- HIVER 2017, Ecole de technologie sup�rieure
-- Auteur : Chakib Tadj, Vincent Trudel-Lapierre, Yves Blaqui�re
-- =============================================================
-- Description: imem        
-- =============================================================

LIBRARY ieee;
LIBRARY std;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY imem IS -- Memoire d'instructions
  PORT (adresse : IN  std_logic_vector(7 DOWNTO 0); -- Taille a modifier
                                                     -- selon le programme 
        data : OUT std_logic_vector(31 DOWNTO 0));
END;  -- imem;

ARCHITECTURE imem_arch OF imem IS

  CONSTANT TAILLE_ROM : positive := 19;  -- taille de la rom (modifier au besoin)
  TYPE romtype IS ARRAY (0 TO TAILLE_ROM) OF std_logic_vector(31 DOWNTO 0);

  CONSTANT Rom : romtype := (
    0  => x"20030001", --main:   addi $3, $0, 1 
    1  => x"2067000b", --        addi $7, $3, 11
    2  => x"00671024", --        and  $2, $3, $7
    3  => x"ac472000", --        sw   $7, 8192($2)
    4  => x"00432820", --        add  $5, $2, $3 
    5  => x"8ca21fff", --        lw   $2, 8191($5)
	 
    6  => x"10430002", --To :    beq  $2, $3, next
    7  => x"2063000b", --        addi $3, $3, 11
    8  => x"08000006", --        j    To           --> 0800006 : ligne 9 MARS
	 
    9  => x"00a7202a", --next:   slt  $4, $5, $7
    10 => x"10820001", --        beq  $4, $2, around
    11 => x"ac851fff", --        sw   $5, 8191($4)
	 
    12 => x"00e2202a", --around: slt  $4, $7, $2
    13 => x"00622025", --        or   $4, $3, $2
    14 => x"2067ffff", --        addi $7, $3, -1  
    15 => x"00e23822", --        sub  $7, $7, $2  
    16 => x"8c621ff4", --        lw   $2, 8180($3)
    17 => x"ac871ff4", --        sw   $7, 8180($4)  
	 18 => x"00051820", --        add  $3, $0, $5    
	 19 => x"10a3ffec"  --        beq  $5, $3, main

	 );

BEGIN
  PROCESS (adresse)
  BEGIN
    data <= Rom(to_integer(unsigned((adresse))));
  END PROCESS;
END imem_arch;

