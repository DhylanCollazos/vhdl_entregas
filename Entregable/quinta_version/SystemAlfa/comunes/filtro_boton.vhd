library ieee;
use ieee.std_logic_1164.all;

entity filtro_boton is
    generic (
        CICLOS_ESTABLES : positive := 500000
    );
    port (
        reloj, reinicio, boton_entrada : in std_logic;
        pulso_salida, estado_salida : out std_logic
    );
end entity filtro_boton;

architecture comportamiento of filtro_boton is

    signal etapa_sincronizada_1 : std_logic := '0';
    signal etapa_sincronizada_2 : std_logic := '0';

    signal sincronizacion_valida : std_logic_vector(1 downto 0)
        := "00";

    signal candidato, estable, inicializado : std_logic := '0';

    signal cuenta :
        integer range 0 to CICLOS_ESTABLES-1 := 0;

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            etapa_sincronizada_1 <= '0';
            etapa_sincronizada_2 <= '0';
            sincronizacion_valida <= "00";

            candidato <= '0';
            inicializado <= '0';
            estable <= '0';
            cuenta <= 0;
            pulso_salida <= '0';

        elsif rising_edge(reloj) then

            -- Sincronizacion de la entrada con el reloj.
            etapa_sincronizada_1 <= boton_entrada;
            etapa_sincronizada_2 <= etapa_sincronizada_1;

            sincronizacion_valida <=
                sincronizacion_valida(0) & '1';

            -- El pulso dura solamente un ciclo de reloj.
            pulso_salida <= '0';

            -- No usar los ceros artificiales del sincronizador
            -- inmediatamente despues del reinicio.
            if sincronizacion_valida(1) = '1' then

                if etapa_sincronizada_2 /= candidato then
                    candidato <= etapa_sincronizada_2;
                    cuenta <= 0;

                elsif cuenta < CICLOS_ESTABLES-1 then
                    cuenta <= cuenta + 1;

                else
                    if inicializado = '0' then
                        -- El primer nivel estable establece la
                        -- referencia, sin generar una pulsacion.
                        estable <= candidato;
                        inicializado <= '1';

                    elsif candidato /= estable then
                        estable <= candidato;

                        -- Generar pulso solo al pasar de 0 a 1.
                        if candidato = '1' then
                            pulso_salida <= '1';
                        end if;

                    end if;
                end if;
            end if;
        end if;
    end process;

    estado_salida <= estable;

end architecture comportamiento;