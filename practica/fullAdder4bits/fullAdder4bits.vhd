library ieee;
use ieee.std_logic_1164.all;

entity fullAdder4bits is
    port
    (
        A, B : in bit_vector(3 downto 0);

        Cin  : in bit;

        Sum  : out bit_vector(3 downto 0);
        Cout : out bit
    );
end fullAdder4bits;


architecture arch_fullAdder4bits of fullAdder4bits is

    component fullAdder
        port
        (
            A, B, Cin : in bit;
            Sum, Cout : out bit
        );
    end component;

    signal C1, C2, C3 : bit;

begin

    -- El Cin externo entra al primer Full Adder
    A0 : fullAdder
        port map(A(0), B(0), Cin, Sum(0), C1);

    A1 : fullAdder
        port map(A(1), B(1), C1, Sum(1), C2);

    A2 : fullAdder
        port map(A(2), B(2), C2, Sum(2), C3);

    A3 : fullAdder
        port map(A(3), B(3), C3, Sum(3), Cout);

end arch_fullAdder4bits;