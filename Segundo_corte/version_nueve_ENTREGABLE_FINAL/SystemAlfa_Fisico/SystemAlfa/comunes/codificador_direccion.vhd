library ieee;
use ieee.std_logic_1164.all;
use work.paquete_funciones.all;

-- Componente independiente que contiene la funcion solicitada.
-- Convierte color + tamano en una direccion de tres bits para la ROM.

entity codificador_direccion is
    port (
        color     : in  std_logic_vector(1 downto 0);
        tamano    : in  std_logic;
        direccion : out std_logic_vector(2 downto 0)
    );
end entity codificador_direccion;

architecture comportamiento of codificador_direccion is

begin

    direccion <=
        formar_direccion(
            color,
            tamano
        );

end architecture comportamiento;