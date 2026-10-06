library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TEST BENCH DEL SISTEMA COMPLETO
-- Seis categorias, conteo por categoria y color,
-- historial decimal, reinicio, alarmas y limite.
-- SOLO PARA SIMULACION.

entity SystemAlfa_Final_TB is
end entity SystemAlfa_Final_TB;


architecture SystemAlfa_Final_TB_arch
of SystemAlfa_Final_TB is


    ------------------------------------------------------------
    -- COMPONENTE QUE SE VA A PROBAR
    ------------------------------------------------------------

    component SystemAlfa_Final is

        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000;
            CICLOS_ATASCO       : positive := 250000000
        );

        port (
            RELOJ,
            REINICIO_BAJO,
            PRESENCIA,
            CAMBIO_VELOCIDAD :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO,
            LINEA_MARCHA :
                in std_logic;

            VER_HISTORIAL,
            SIGUIENTE_HISTORIAL :
                in std_logic;

            SELECCION_HISTORIAL,
            VER_CANTIDADES :
                in std_logic;

            IR_ULTIMO,
            CONTAR_POR_COLOR :
                in std_logic;

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO,
            LINEA_ACTIVA :
                out std_logic;

            RUTA_PIEZA :
                out std_logic_vector(3 downto 0);

            ALARMA,
            LED_LIMITE :
                out std_logic;

            VISOR_0,
            VISOR_1,
            VISOR_2,
            VISOR_3 :
                out std_logic_vector(6 downto 0)
        );

    end component;


    ------------------------------------------------------------
    -- SENALES DEL TEST BENCH
    ------------------------------------------------------------

    signal RELOJ_TB :
        std_logic := '0';

    signal REINICIO_BAJO_TB :
        std_logic := '0';

    signal PRESENCIA_TB :
        std_logic := '1';

    signal CAMBIO_VELOCIDAD_TB :
        std_logic := '1';

    signal SELECTOR_COLOR_TB :
        std_logic_vector(1 downto 0) := "00";

    signal SELECTOR_TAMANO_TB :
        std_logic := '0';

    signal LINEA_MARCHA_TB :
        std_logic := '0';

    signal VER_HISTORIAL_TB :
        std_logic := '0';

    signal SIGUIENTE_HISTORIAL_TB :
        std_logic := '0';

    signal SELECCION_HISTORIAL_TB :
        std_logic := '0';

    signal VER_CANTIDADES_TB :
        std_logic := '0';

    signal IR_ULTIMO_TB :
        std_logic := '0';

    signal CONTAR_POR_COLOR_TB :
        std_logic := '0';


    ------------------------------------------------------------
    -- SALIDAS
    ------------------------------------------------------------

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB :
        std_logic;

    signal LINEA_ACTIVA_TB :
        std_logic;

    signal RUTA_PIEZA_TB :
        std_logic_vector(3 downto 0);

    signal ALARMA_TB :
        std_logic;

    signal LED_LIMITE_TB :
        std_logic;

    signal VISOR_0_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_1_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_2_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_3_TB :
        std_logic_vector(6 downto 0);


    signal FIN_TB :
        boolean := false;


    ------------------------------------------------------------
    -- TABLA PARA LEER LOS DISPLAYS
    ------------------------------------------------------------

    type tabla_segmentos is
        array (0 to 15) of std_logic_vector(6 downto 0);

    constant PATRONES : tabla_segmentos := (
        "1000000", -- 0
        "1111001", -- 1
        "0100100", -- 2
        "0110000", -- 3
        "0011001", -- 4
        "0010010", -- 5
        "0000010", -- 6
        "1111000", -- 7
        "0000000", -- 8
        "0010000", -- 9
        "0001000", -- A
        "0000011", -- b
        "1000110", -- C
        "0100001", -- d
        "0000110", -- E
        "0001110"  -- F
    );


    ------------------------------------------------------------
    -- FUNCION PARA LEER UN DISPLAY
    ------------------------------------------------------------

    function leer_hex(
        s : std_logic_vector(6 downto 0)
    ) return integer is
    begin

        for i in 0 to 15 loop

            if s = PATRONES(i) then
                return i;
            end if;

        end loop;

        return -1;

    end function;


    ------------------------------------------------------------
    -- FUNCION PARA LEER TRES DISPLAYS DECIMALES
    ------------------------------------------------------------

    function leer_decimal(
        centenas,
        decenas,
        unidades :
            std_logic_vector(6 downto 0)
    ) return integer is

        variable c, d, u : integer;

    begin

        c := leer_hex(centenas);
        d := leer_hex(decenas);
        u := leer_hex(unidades);

        if
            c < 0 or c > 9 or
            d < 0 or d > 9 or
            u < 0 or u > 9
        then
            return -1;
        end if;

        return 100*c + 10*d + u;

    end function;


begin


    ------------------------------------------------------------
    -- RELOJ
    -- 20 ns = 50 MHz
    ------------------------------------------------------------

    RELOJ_TB <=
        not RELOJ_TB after 10 ns
        when not FIN_TB
        else '0';


    ------------------------------------------------------------
    -- DUT1 = SYSTEM ALFA COMPLETO
    ------------------------------------------------------------

    DUT1 : SystemAlfa_Final

        generic map (
            -- Valores reducidos solamente para simulacion.
            FRECUENCIA_RELOJ_HZ => 1000,
            CICLOS_FILTRO       => 3,
            CICLOS_ATASCO       => 10000
        )

        port map (

            RELOJ =>
                RELOJ_TB,

            REINICIO_BAJO =>
                REINICIO_BAJO_TB,

            PRESENCIA =>
                PRESENCIA_TB,

            CAMBIO_VELOCIDAD =>
                CAMBIO_VELOCIDAD_TB,

            SELECTOR_COLOR =>
                SELECTOR_COLOR_TB,

            SELECTOR_TAMANO =>
                SELECTOR_TAMANO_TB,

            LINEA_MARCHA =>
                LINEA_MARCHA_TB,

            VER_HISTORIAL =>
                VER_HISTORIAL_TB,

            SIGUIENTE_HISTORIAL =>
                SIGUIENTE_HISTORIAL_TB,

            SELECCION_HISTORIAL =>
                SELECCION_HISTORIAL_TB,

            VER_CANTIDADES =>
                VER_CANTIDADES_TB,

            IR_ULTIMO =>
                IR_ULTIMO_TB,

            CONTAR_POR_COLOR =>
                CONTAR_POR_COLOR_TB,

            LED_COLOR =>
                LED_COLOR_TB,

            LED_TAMANO =>
                LED_TAMANO_TB,

            LINEA_ACTIVA =>
                LINEA_ACTIVA_TB,

            RUTA_PIEZA =>
                RUTA_PIEZA_TB,

            ALARMA =>
                ALARMA_TB,

            LED_LIMITE =>
                LED_LIMITE_TB,

            VISOR_0 =>
                VISOR_0_TB,

            VISOR_1 =>
                VISOR_1_TB,

            VISOR_2 =>
                VISOR_2_TB,

            VISOR_3 =>
                VISOR_3_TB
        );


    ------------------------------------------------------------
    -- GENERACION DE ESTIMULOS
    ------------------------------------------------------------

    STIMULUS : process


        --------------------------------------------------------
        -- ESPERAR CICLOS DE RELOJ
        --------------------------------------------------------

        procedure esperar(
            n : positive := 1
        ) is

        begin

            for i in 1 to n loop

                wait until rising_edge(RELOJ_TB);

                -- Se espera un poco para que las senales
                -- terminen de actualizarse.
                wait for 1 ns;

            end loop;

        end procedure;


        --------------------------------------------------------
        -- PULSO PARA SWITCHES DE MENU
        --------------------------------------------------------

        procedure pulsar_alto(
            signal mando : out std_logic
        ) is

        begin

            mando <= '1';
            esperar(10);

            mando <= '0';
            esperar(10);

        end procedure;


        --------------------------------------------------------
        -- INGRESAR UNA CATEGORIA
        --------------------------------------------------------

        procedure ingresar(
            categoria : positive
        ) is

        begin

            -- Categorias:
            -- 1 rojo pequeno
            -- 2 rojo grande
            -- 3 verde pequeno
            -- 4 verde grande
            -- 5 azul pequeno
            -- 6 azul grande

            SELECTOR_COLOR_TB <=
                std_logic_vector(
                    to_unsigned(
                        (categoria + 1) / 2,
                        2
                    )
                );

            if categoria mod 2 = 0 then

                SELECTOR_TAMANO_TB <= '1';

            else

                SELECTOR_TAMANO_TB <= '0';

            end if;


            -- Esperar que los atributos se estabilicen.
            esperar(8);


            -- BUTTON0 presionado.
            PRESENCIA_TB <= '0';

            esperar(10);


            -- BUTTON0 liberado.
            PRESENCIA_TB <= '1';

            esperar(10);

        end procedure;


        --------------------------------------------------------
        -- COMPROBAR TOTAL NORMAL
        --------------------------------------------------------

        procedure comprobar_total(
            n : natural
        ) is

        begin

            assert
                leer_decimal(
                    VISOR_3_TB,
                    VISOR_2_TB,
                    VISOR_0_TB
                ) = n

                report
                    "Total incorrecto. Esperado: "
                    & integer'image(n)

                severity failure;

        end procedure;


        --------------------------------------------------------
        -- COMPROBAR VALOR DE CONSULTA
        --------------------------------------------------------

        procedure comprobar_consulta(
            n : natural
        ) is

        begin

            assert
                leer_decimal(
                    VISOR_2_TB,
                    VISOR_1_TB,
                    VISOR_0_TB
                ) = n

                report
                    "Consulta incorrecta. Esperado: "
                    & integer'image(n)

                severity failure;

        end procedure;


        --------------------------------------------------------
        -- REINICIAR EL SISTEMA
        --------------------------------------------------------

        procedure reiniciar is

        begin

            LINEA_MARCHA_TB <= '0';
            PRESENCIA_TB <= '1';

            CAMBIO_VELOCIDAD_TB <= '1';

            VER_HISTORIAL_TB <= '0';
            VER_CANTIDADES_TB <= '0';
            CONTAR_POR_COLOR_TB <= '0';

            SELECCION_HISTORIAL_TB <= '0';
            SIGUIENTE_HISTORIAL_TB <= '0';
            IR_ULTIMO_TB <= '0';


            REINICIO_BAJO_TB <= '0';

            esperar(5);


            REINICIO_BAJO_TB <= '1';

            esperar(12);


            -- Rearmar la linea.
            LINEA_MARCHA_TB <= '1';

            esperar(8);

        end procedure;


    begin


        --------------------------------------------------------
        -- PRUEBA 1
        -- ESTADO INICIAL
        --------------------------------------------------------

        reiniciar;

        comprobar_total(0);

        assert RUTA_PIEZA_TB = "0000"
            report "Aparece una pieza ficticia tras reinicio"
            severity failure;


        --------------------------------------------------------
        -- PRUEBA 2
        -- INGRESAR CANTIDADES DE LAS SEIS CATEGORIAS
        --------------------------------------------------------

        -- Categoria 1: 1 pieza
        ingresar(1);

        -- Categoria 2: 2 piezas
        ingresar(2);
        ingresar(2);

        -- Categoria 3: 3 piezas
        for i in 1 to 3 loop
            ingresar(3);
        end loop;

        -- Categoria 4: 4 piezas
        for i in 1 to 4 loop
            ingresar(4);
        end loop;

        -- Categoria 5: 5 piezas
        for i in 1 to 5 loop
            ingresar(5);
        end loop;

        -- Categoria 6: 6 piezas
        for i in 1 to 6 loop
            ingresar(6);
        end loop;


        comprobar_total(21);


        assert ALARMA_TB = '0'
            report "Una categoria valida genero alarma"
            severity failure;


        --------------------------------------------------------
        -- PRUEBA 3
        -- CANTIDAD POR CATEGORIA
        --------------------------------------------------------

        VER_HISTORIAL_TB <= '1';
        VER_CANTIDADES_TB <= '1';
        CONTAR_POR_COLOR_TB <= '0';

        esperar(8);


        for i in 1 to 6 loop

            assert leer_hex(VISOR_3_TB) = i
                report "Selector de categoria incorrecto"
                severity failure;

            comprobar_consulta(i);

            assert
                RUTA_PIEZA_TB =
                    std_logic_vector(to_unsigned(i, 4))

                report "Codigo de categoria incorrecto"
                severity failure;


            pulsar_alto(SIGUIENTE_HISTORIAL_TB);

        end loop;


        --------------------------------------------------------
        -- PRUEBA 4
        -- CANTIDADES POR COLOR
        --------------------------------------------------------

        CONTAR_POR_COLOR_TB <= '1';

        esperar(8);


        -- Rojo = 1 + 2 = 3
        comprobar_consulta(3);

        pulsar_alto(SIGUIENTE_HISTORIAL_TB);


        -- Verde = 3 + 4 = 7
        comprobar_consulta(7);

        pulsar_alto(SIGUIENTE_HISTORIAL_TB);


        -- Azul = 5 + 6 = 11
        comprobar_consulta(11);


        --------------------------------------------------------
        -- PRUEBA 5
        -- HISTORIAL INDIVIDUAL
        --------------------------------------------------------

        VER_CANTIDADES_TB <= '0';
        CONTAR_POR_COLOR_TB <= '0';

        esperar(8);


        -- El ultimo evento debe ser el numero 21.
        comprobar_consulta(21);


        -- Avanzar debe volver al mas antiguo disponible.
        pulsar_alto(SIGUIENTE_HISTORIAL_TB);

        comprobar_consulta(14);


        -- Volver al ultimo.
        pulsar_alto(IR_ULTIMO_TB);

        comprobar_consulta(21);


        --------------------------------------------------------
        -- PRUEBA 6
        -- TIEMPO EN DECIMAL
        --------------------------------------------------------

        SELECCION_HISTORIAL_TB <= '1';

        esperar(8);


        assert
            leer_decimal(
                VISOR_2_TB,
                VISOR_1_TB,
                VISOR_0_TB
            ) >= 0

            report "Tiempo no mostrado en decimal"
            severity failure;


        SELECCION_HISTORIAL_TB <= '0';


        --------------------------------------------------------
        -- PRUEBA 7
        -- LINEA DETENIDA NO CUENTA
        --------------------------------------------------------

        VER_HISTORIAL_TB <= '0';

        LINEA_MARCHA_TB <= '0';

        esperar(8);


        ingresar(1);

        comprobar_total(21);


        --------------------------------------------------------
        -- PRUEBA 8
        -- CAMBIO DE VELOCIDAD NO CUENTA PIEZAS
        --------------------------------------------------------

        LINEA_MARCHA_TB <= '1';

        esperar(8);


        CAMBIO_VELOCIDAD_TB <= '0';

        esperar(10);


        CAMBIO_VELOCIDAD_TB <= '1';

        esperar(10);


        comprobar_total(21);


        --------------------------------------------------------
        -- PRUEBA 9
        -- PIEZA INVALIDA
        --------------------------------------------------------

        SELECTOR_COLOR_TB <= "00";
        SELECTOR_TAMANO_TB <= '0';

        esperar(8);


        PRESENCIA_TB <= '0';

        esperar(10);


        PRESENCIA_TB <= '1';

        esperar(10);


        comprobar_total(21);


        assert
            ALARMA_TB = '1'

            report "No se activo la alarma de rechazo"
            severity failure;


        assert
            LINEA_ACTIVA_TB = '0'

            report "La linea no se detuvo con alarma"
            severity failure;


        --------------------------------------------------------
        -- FIN DE LA PRUEBA
        --------------------------------------------------------

        report "OK: SystemAlfa_Final_TB"
            severity note;


        FIN_TB <= true;

        wait;


    end process STIMULUS;


end architecture SystemAlfa_Final_TB_arch;