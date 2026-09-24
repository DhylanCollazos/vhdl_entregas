library ieee;
use ieee.std_logic_1164.all;

entity GXOR2 is
	port
	(
		-- Input ports
		A, B	: in std_logic;
		F	: out std_logic

	);
end GXOR2;
architecture arch_GXOR2 of GXOR2 is

begin
F <= A or B;
end arch_GXOR2;
