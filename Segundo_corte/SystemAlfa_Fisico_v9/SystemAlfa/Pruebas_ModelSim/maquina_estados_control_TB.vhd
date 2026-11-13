library ieee;
use ieee.std_logic_1164.all;

entity maquina_estados_control_TB is
end entity maquina_estados_control_TB;

architecture prueba
of maquina_estados_control_TB is

    component maquina_estados_control is
        port (
            reloj,
            reinicio :
                in std_logic;

            marcha,
            nueva_pieza,
            pieza_valida :
                in std_logic;

            registrar_evento,
            contar_pieza :
                out std_logic;

            alarma_estado,
            ocupado :
                out std_logic;

            estado_codigo :
                out std_logic_vector(2 downto 0)
        );
    end component;

    signal RELOJ_TB :
        std_logic := '0';

    signal REINICIO_TB :
        std_logic := '1';

    signal MARCHA_TB :
        std_logic := '0';

    signal NUEVA_PIEZA_TB :
        std_logic := '0';

    signal PIEZA_VALIDA_TB :
        std_logic := '0';

    signal REGISTRAR_EVENTO_TB :
        std_logic;

    signal CONTAR_PIEZA_TB :
        std_logic;

    signal ALARMA_ESTADO_TB :
        std_logic;

    signal OCUPADO_TB :
        std_logic;

    signal ESTADO_CODIGO_TB :
        std_logic_vector(2 downto 0);

    signal FIN_TB :
        boolean := false;

begin

    RELOJ_TB <=
        not RELOJ_TB after 10 ns
        when not FIN_TB
        else '0';

    DUT1 : maquina_estados_control
        port map (
            reloj =>
                RELOJ_TB,

            reinicio =>
                REINICIO_TB,

            marcha =>
                MARCHA_TB,

            nueva_pieza =>
                NUEVA_PIEZA_TB,

            pieza_valida =>
                PIEZA_VALIDA_TB,

            registrar_evento =>
                REGISTRAR_EVENTO_TB,

            contar_pieza =>
                CONTAR_PIEZA_TB,

            alarma_estado =>
                ALARMA_ESTADO_TB,

            ocupado =>
                OCUPADO_TB,

            estado_codigo =>
                ESTADO_CODIGO_TB
        );

    STIMULUS : process

        procedure esperar_estado(
            codigo :
                std_logic_vector(2 downto 0)
        ) is
        begin

            wait until rising_edge(RELOJ_TB);

            wait for 1 ns;

            assert
                ESTADO_CODIGO_TB = codigo

                report
                    "Estado inesperado"

                severity failure;

        end procedure;

    begin

        --------------------------------------------------------
        -- RESET
        --------------------------------------------------------

        wait for 25 ns;

        REINICIO_TB <= '0';

        wait for 5 ns;

        assert
            ESTADO_CODIGO_TB = "000"

            report
                "No inicia en ESPERA"

            severity failure;

        --------------------------------------------------------
        -- CAMINO VALIDO
        --------------------------------------------------------

        MARCHA_TB <= '1';

        PIEZA_VALIDA_TB <= '1';

        NUEVA_PIEZA_TB <= '1';

        esperar_estado("001"); -- DETECCION

        NUEVA_PIEZA_TB <= '0';

        esperar_estado("010"); -- LECTURA

        esperar_estado("011"); -- CLASIFICACION

        esperar_estado("100"); -- REGISTRO

        assert
            REGISTRAR_EVENTO_TB = '1'
            and
            CONTAR_PIEZA_TB = '1'

            report
                "No registra pieza valida"

            severity failure;

        esperar_estado("000"); -- ESPERA

        --------------------------------------------------------
        -- CAMINO INVALIDO
        --------------------------------------------------------

        PIEZA_VALIDA_TB <= '0';

        NUEVA_PIEZA_TB <= '1';

        esperar_estado("001");

        NUEVA_PIEZA_TB <= '0';

        esperar_estado("010");

        esperar_estado("011");

        assert
            REGISTRAR_EVENTO_TB = '1'
            and
            CONTAR_PIEZA_TB = '0'
            and
            ALARMA_ESTADO_TB = '1'

            report
                "Rechazo incorrecto"

            severity failure;

        esperar_estado("101");

        assert
            ALARMA_ESTADO_TB = '1'

            report
                "Alarma no retenida"

            severity failure;

        --------------------------------------------------------
        -- RESET DESDE ERROR
        --------------------------------------------------------

        REINICIO_TB <= '1';

        wait for 2 ns;

        assert
            ESTADO_CODIGO_TB = "000"

            report
                "Reset no vuelve a ESPERA"

            severity failure;

        report
            "OK: maquina_estados_control_TB"
            severity note;

        FIN_TB <= true;

        wait;

    end process STIMULUS;

end architecture prueba;