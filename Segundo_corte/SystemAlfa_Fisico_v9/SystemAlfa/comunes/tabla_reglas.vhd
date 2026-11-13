library ieee;
use ieee.std_logic_1164.all;

-- Adaptador entre el resto del proyecto y la ROM.
--
-- Las reglas ya no se encuentran escritas en este archivo.
-- Se genera una direccion y se consulta rom_categorias.

entity tabla_reglas is
    port (
        color  :
            in std_logic_vector(1 downto 0);

        tamano :
            in std_logic;

        ruta :
            out std_logic_vector(3 downto 0);

        valida :
            out std_logic
    );
end entity tabla_reglas;

architecture estructural of tabla_reglas is

    ------------------------------------------------------------
    -- COMPONENTE QUE FORMA LA DIRECCION
    ------------------------------------------------------------

    component codificador_direccion is
        port (
            color :
                in std_logic_vector(1 downto 0);

            tamano :
                in std_logic;

            direccion :
                out std_logic_vector(2 downto 0)
        );
    end component;

    ------------------------------------------------------------
    -- MEMORIA ROM
    ------------------------------------------------------------

    component rom_categorias is
        port (
            direccion :
                in std_logic_vector(2 downto 0);

            dato :
                out std_logic_vector(4 downto 0)
        );
    end component;

    ------------------------------------------------------------
    -- SENALES INTERNAS
    ------------------------------------------------------------

    signal direccion_rom :
        std_logic_vector(2 downto 0);

    signal dato_rom :
        std_logic_vector(4 downto 0);

begin

    ------------------------------------------------------------
    -- GENERAR DIRECCION
    ------------------------------------------------------------

    U_DIRECCION : codificador_direccion
        port map (
            color     => color,
            tamano    => tamano,
            direccion => direccion_rom
        );

    ------------------------------------------------------------
    -- CONSULTAR ROM
    ------------------------------------------------------------

    U_ROM : rom_categorias
        port map (
            direccion => direccion_rom,
            dato      => dato_rom
        );

    ------------------------------------------------------------
    -- SALIDAS
    ------------------------------------------------------------

    valida <= dato_rom(4);

    ruta <= dato_rom(3 downto 0);

end architecture estructural;