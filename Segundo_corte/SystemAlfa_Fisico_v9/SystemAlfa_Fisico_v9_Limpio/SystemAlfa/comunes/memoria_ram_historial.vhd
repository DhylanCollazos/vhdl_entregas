library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- RAM de ocho posiciones por 21 bits.
--
-- Cada palabra contiene:
--
-- 8 bits  -> tiempo
-- 10 bits -> identificador
-- 2 bits  -> color
-- 1 bit   -> tamano
--
-- Total = 21 bits

entity memoria_ram_historial is
    port (
        reloj :
            in std_logic;

        habilitar_escritura :
            in std_logic;

        direccion_escritura :
            in std_logic_vector(2 downto 0);

        direccion_lectura :
            in std_logic_vector(2 downto 0);

        dato_entrada :
            in std_logic_vector(20 downto 0);

        dato_salida :
            out std_logic_vector(20 downto 0)
    );
end entity memoria_ram_historial;

architecture memoria of memoria_ram_historial is

    ------------------------------------------------------------
    -- DEFINICION DE LA RAM
    ------------------------------------------------------------

    type tipo_ram is
        array (0 to 7)
        of std_logic_vector(20 downto 0);

    signal RAM :
        tipo_ram := (
            others => (
                others => '0'
            )
        );

begin

    ------------------------------------------------------------
    -- ESCRITURA SINCRONA
    ------------------------------------------------------------

    process(reloj)
    begin

        if rising_edge(reloj) then

            if habilitar_escritura = '1' then

                RAM(
                    to_integer(
                        unsigned(direccion_escritura)
                    )
                ) <= dato_entrada;

            end if;

        end if;

    end process;

    ------------------------------------------------------------
    -- LECTURA
    ------------------------------------------------------------

    dato_salida <=
        RAM(
            to_integer(
                unsigned(direccion_lectura)
            )
        );

end architecture memoria;