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
    signal estable : std_logic := '0';

    signal cuenta :
        integer range 0 to CICLOS_ESTABLES-1 := 0;

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            etapa_sincronizada_1 <= '0';
            etapa_sincronizada_2 <= '0';
            estable <= '0';
            cuenta <= 0;
            pulso_salida <= '0';

        elsif rising_edge(reloj) then
            etapa_sincronizada_1 <= boton_entrada;
            etapa_sincronizada_2 <= etapa_sincronizada_1;

            pulso_salida <= '0';

            if etapa_sincronizada_2 = estable then
                cuenta <= 0;

            elsif cuenta = CICLOS_ESTABLES-1 then
                estable <= etapa_sincronizada_2;
                cuenta <= 0;

                if etapa_sincronizada_2 = '1' then
                    pulso_salida <= '1';
                end if;

            else
                cuenta <= cuenta + 1;
            end if;
        end if;
    end process;

    estado_salida <= estable;

end architecture comportamiento;