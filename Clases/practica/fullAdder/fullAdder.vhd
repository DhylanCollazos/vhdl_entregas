library ieee;
use ieee.std_logic_1164.all;

entity fullAdder is
	port
	(
		-- Input ports
		A, B, Cin	: in  bit;
		Sum, Cout : out bit
	);
end fullAdder;


architecture arch_fullAdder of fullAdder is

	component halfAdder 
	port
	(
		-- Input ports
		A, B	    : in bit;
		Sum, Cout : out bit

	);
	end component;

	signal Ha1_Sum, Ha1_Cout : bit;
	signal Ha2_Cout : bit;	
	
	
begin

 u1 : halfAdder port map (A, B, Ha1_Sum, Ha1_Cout);
 u2 : halfAdder port map (Ha1_Sum, Cin, Sum, Ha2_Cout);
 
 Cout <= Ha2_Cout or Ha1_Cout;
 
 
end arch_fullAdder;
