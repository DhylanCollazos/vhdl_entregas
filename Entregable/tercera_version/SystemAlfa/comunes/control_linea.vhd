library ieee;
use ieee.std_logic_1164.all;

entity control_linea is
    port (
        reloj, reinicio, marcha, bloqueo, pulso_linea_entrada :
            in std_logic;

        pulso_motor, led_linea, en_marcha :
            out std_logic
    );
end entity control_linea;

architecture comportamiento of control_linea is

    -- Evitan interpretar el estado inicial como una parada observada.
    signal etapa1, etapa2 : std_logic := '1';

    signal preparada : std_logic := '0';
    signal estado_led : std_logic := '0';
    signal habilitada : std_logic;

begin

    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            etapa1 <= '1';
            etapa2 <= '1';
            preparada <= '0';
            estado_led <= '0';

        elsif rising_edge(reloj) then

            etapa1 <= marcha;
            etapa2 <= etapa1;

            -- Primero debe observarse el switch de marcha en cero.
            if etapa2 = '0' then
                preparada <= '1';
            end if;

            if habilitada = '0' then
                estado_led <= '0';

            elsif pulso_linea_entrada = '1' then
                estado_led <= not estado_led;
            end if;

        end if;
    end process;

    habilitada <=
        etapa2 and preparada and not bloqueo and not reinicio;

    pulso_motor <= pulso_linea_entrada and habilitada;
    led_linea <= estado_led and habilitada;
    en_marcha <= habilitada;

end architecture comportamiento;