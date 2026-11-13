library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoria_ram_historial_TB is
end entity memoria_ram_historial_TB;

architecture prueba
of memoria_ram_historial_TB is

    component memoria_ram_historial is
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
    end component;

    signal RELOJ_TB :
        std_logic := '0';

    signal HABILITAR_ESCRITURA_TB :
        std_logic := '0';

    signal DIRECCION_ESCRITURA_TB :
        std_logic_vector(2 downto 0) :=
        "000";

    signal DIRECCION_LECTURA_TB :
        std_logic_vector(2 downto 0) :=
        "000";

    signal DATO_ENTRADA_TB :
        std_logic_vector(20 downto 0) :=
        (others => '0');

    signal DATO_SALIDA_TB :
        std_logic_vector(20 downto 0);

    signal FIN_TB :
        boolean := false;

begin

    RELOJ_TB <=
        not RELOJ_TB after 10 ns
        when not FIN_TB
        else '0';

    DUT1 : memoria_ram_historial
        port map (
            reloj =>
                RELOJ_TB,

            habilitar_escritura =>
                HABILITAR_ESCRITURA_TB,

            direccion_escritura =>
                DIRECCION_ESCRITURA_TB,

            direccion_lectura =>
                DIRECCION_LECTURA_TB,

            dato_entrada =>
                DATO_ENTRADA_TB,

            dato_salida =>
                DATO_SALIDA_TB
        );

    STIMULUS : process

        procedure escribir(
            direccion : natural;
            dato      : natural
        ) is
        begin

            DIRECCION_ESCRITURA_TB <=
                std_logic_vector(
                    to_unsigned(direccion, 3)
                );

            DATO_ENTRADA_TB <=
                std_logic_vector(
                    to_unsigned(dato, 21)
                );

            HABILITAR_ESCRITURA_TB <= '1';

            wait until rising_edge(RELOJ_TB);

            wait for 1 ns;

            HABILITAR_ESCRITURA_TB <= '0';

        end procedure;

        procedure comprobar(
            direccion : natural;
            dato      : natural
        ) is
        begin

            DIRECCION_LECTURA_TB <=
                std_logic_vector(
                    to_unsigned(direccion, 3)
                );

            wait for 2 ns;

            assert
                DATO_SALIDA_TB =
                std_logic_vector(
                    to_unsigned(dato, 21)
                )

                report
                    "Lectura incorrecta de RAM"

                severity failure;

        end procedure;

    begin

        -- Escribir las ocho posiciones.
        for i in 0 to 7 loop

            escribir(
                i,
                100 + i
            );

        end loop;

        -- Leerlas.
        for i in 0 to 7 loop

            comprobar(
                i,
                100 + i
            );

        end loop;

        -- Sobrescribir posicion 3.
        escribir(
            3,
            777
        );

        comprobar(
            3,
            777
        );

        -- Las otras deben seguir iguales.
        comprobar(
            2,
            102
        );

        comprobar(
            4,
            104
        );

        report
            "OK: memoria_ram_historial_TB"
            severity note;

        FIN_TB <= true;

        wait;

    end process STIMULUS;

end architecture prueba;