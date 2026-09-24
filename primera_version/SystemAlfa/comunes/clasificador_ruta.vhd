library ieee;
use ieee.std_logic_1164.all;

entity clasificador_ruta is
    port (
        color : in std_logic_vector(1 downto 0);
        tamano : in std_logic;

        ruta : out std_logic_vector(3 downto 0);
        aceptada : out std_logic
    );
end entity clasificador_ruta;

architecture estructural of clasificador_ruta is

    component tabla_reglas is
        port (
            color : in std_logic_vector(1 downto 0);
            tamano : in std_logic;
            ruta : out std_logic_vector(3 downto 0);
            valida : out std_logic
        );
    end component;

begin

    U_REGLAS : tabla_reglas
        port map (
            color  => color,
            tamano => tamano,
            ruta   => ruta,
            valida => aceptada
        );

end architecture estructural;