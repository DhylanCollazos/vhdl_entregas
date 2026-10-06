library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF2_Inspeccion_TB is
end entity RF2_Inspeccion_TB;

architecture RF2_Inspeccion_TB_arch of RF2_Inspeccion_TB is

    component RF2_Inspeccion is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO :
                in std_logic;

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO, LED_PIEZA :
                out std_logic
        );
    end component;

    signal RELOJ_TB         : std_logic := '0';
    signal REINICIO_BAJO_TB : std_logic := '0';
    signal PRESENCIA_TB     : std_logic := '0';

    signal SELECTOR_COLOR_TB :
        std_logic_vector(1 downto 0) := "00";

    signal SELECTOR_TAMANO_TB :
        std_logic := '0';

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB :
        std_logic;

    signal LED_PIEZA_TB :
        std_logic;

    signal FIN_TB :
        boolean := false;

begin

    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF2_Inspeccion
        generic map (
            CICLOS_FILTRO => 3
        )
        port map (
            RELOJ           => RELOJ_TB,
            REINICIO_BAJO   => REINICIO_BAJO_TB,
            PRESENCIA       => PRESENCIA_TB,
            SELECTOR_COLOR  => SELECTOR_COLOR_TB,
            SELECTOR_TAMANO => SELECTOR_TAMANO_TB,
            LED_COLOR       => LED_COLOR_TB,
            LED_TAMANO      => LED_TAMANO_TB,
            LED_PIEZA       => LED_PIEZA_TB
        );

    STIMULUS : process

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(RELOJ_TB);
                wait for 1 ns;
            end loop;
        end procedure;

    begin

        -- Liberar reinicio.
        esperar(4);
        REINICIO_BAJO_TB <= '1';
        esperar(16);

        assert LED_PIEZA_TB = '0'
            report "RF2 detecto una pieza inexistente"
            severity failure;

        -- Sensor libre.
        PRESENCIA_TB <= '1';
        esperar(10);

        -- Probar las 8 combinaciones posibles.
        for i in 0 to 7 loop

            SELECTOR_COLOR_TB <=
                std_logic_vector(to_unsigned(i / 2, 2));

            if i mod 2 = 0 then
                SELECTOR_TAMANO_TB <= '0';
            else
                SELECTOR_TAMANO_TB <= '1';
            end if;

            esperar(8);

            -- Pulsar presencia.
            PRESENCIA_TB <= '0';
            esperar(10);

            assert
                LED_COLOR_TB = SELECTOR_COLOR_TB and
                LED_TAMANO_TB = SELECTOR_TAMANO_TB

                report "RF2 no guardo los atributos"
                severity failure;

            assert LED_PIEZA_TB = '1'
                report "RF2 no indico pieza"
                severity failure;

            -- Liberar presencia.
            PRESENCIA_TB <= '1';
            esperar(10);

        end loop;

        -- Los atributos no deben cambiar solos.
        SELECTOR_COLOR_TB <= "01";
        SELECTOR_TAMANO_TB <= '0';
        esperar(10);

        assert
            LED_COLOR_TB = "11" and
            LED_TAMANO_TB = '1'

            report "Los atributos cambiaron sin nueva captura"
            severity failure;

        -- Reiniciar.
        REINICIO_BAJO_TB <= '0';
        esperar(4);

        assert
            LED_PIEZA_TB = '0' and
            LED_COLOR_TB = "00" and
            LED_TAMANO_TB = '0'

            report "RF2 no se reinicio"
            severity failure;

        report "OK: RF2_Inspeccion_TB"
            severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF2_Inspeccion_TB_arch;