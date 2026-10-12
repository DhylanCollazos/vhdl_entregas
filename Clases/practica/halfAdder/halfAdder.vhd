library ieee;
use ieee.std_logic_1164.all;

entity halfAdder is
	port
	(
		-- Input ports
		A, B	    : in bit;
		Sum, Cout : out bit

	);
end halfAdder;

architecture arch_halfAdder of halfAdder is

begin
Sum <= A xor B;
Cout <= A and B;

end arch_halfAdder;
