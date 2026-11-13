library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ROM de clasificacion.
--
-- direccion = color(1 downto 0) & tamano
--
-- dato(4) = categoria valida
-- dato(3 downto 0) = codigo de categoria o rechazo

entity rom_categorias is
    port (
        direccion :
            in std_logic_vector(2 downto 0);

        dato :
            out std_logic_vector(4 downto 0)
    );
end entity rom_categorias;

architecture memoria of rom_categorias is

    type tipo_rom is
        array (0 to 7)
        of std_logic_vector(4 downto 0);

    constant CONTENIDO_ROM :
        tipo_rom := (

        -- Color 00: no valido
        0 => "01000", -- 000 -> rechazo pequena
        1 => "01000", -- 001 -> rechazo grande

        -- Color 01: rojo
        2 => "10001", -- 010 -> rojo pequeno -> categoria 1
        3 => "10010", -- 011 -> rojo grande  -> categoria 2

        -- Color 10: verde
        4 => "10011", -- 100 -> verde pequeno -> categoria 3
        5 => "10100", -- 101 -> verde grande  -> categoria 4

        -- Color 11: azul
        6 => "10101", -- 110 -> azul pequeno -> categoria 5
        7 => "10110"  -- 111 -> azul grande  -> categoria 6

    );

begin

    ------------------------------------------------------------
    -- LECTURA DE ROM
    ------------------------------------------------------------

    dato <=
        CONTENIDO_ROM(
            to_integer(
                unsigned(direccion)
            )
        );

end architecture memoria;