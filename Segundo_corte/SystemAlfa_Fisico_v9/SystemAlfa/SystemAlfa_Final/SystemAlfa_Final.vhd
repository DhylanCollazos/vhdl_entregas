library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SystemAlfa_Final is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO : positive := 500000;
        CICLOS_ATASCO : positive := 250000000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA, CAMBIO_VELOCIDAD : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);
        SELECTOR_TAMANO, LINEA_MARCHA : in std_logic;
        VER_HISTORIAL, SIGUIENTE_HISTORIAL : in std_logic;
        SELECCION_HISTORIAL, VER_CANTIDADES : in std_logic;
        IR_ULTIMO, CONTAR_POR_COLOR : in std_logic;
        LED_COLOR : out std_logic_vector(1 downto 0);
        LED_TAMANO, LINEA_ACTIVA : out std_logic;
        RUTA_PIEZA : out std_logic_vector(3 downto 0);
        ALARMA, LED_LIMITE : out std_logic;
        VISOR_0, VISOR_1, VISOR_2, VISOR_3 :
            out std_logic_vector(6 downto 0);
        MARCHA_FISICA, EVENTO_VALIDO : out std_logic;
        NIVEL_FISICO : out std_logic_vector(1 downto 0);
        CATEGORIA_FISICA : out std_logic_vector(3 downto 0)
    );
end entity SystemAlfa_Final;

architecture estructural of SystemAlfa_Final is

    -- Captura y clasificacion.
    signal reinicio_alto, reinicio_operacion, nueva, presente : std_logic;

    -- Solo se activa al configurar la FPGA.
    -- BUTTON(1) nunca borra la sesion.
    signal arranque_sesion : std_logic_vector(3 downto 0) := "1111";
    signal reinicio_sesion : std_logic;
    signal marcha_filtrada : std_logic;
    signal guardar_sesion, contar_sesion : std_logic;

    signal tamano_actual, pieza_valida : std_logic;
    signal color_actual : std_logic_vector(1 downto 0);
    signal categoria_actual : std_logic_vector(3 downto 0);

    -- Transporte y conteo.
    signal pulso_linea, marcha_real, bloqueo : std_logic;
    signal registrar_evento, limite_total, limite_historial : std_logic;
    signal total, cantidad_consultada : std_logic_vector(9 downto 0);

    -- Maquina de estados.
    signal contar_pieza_fsm : std_logic;
    signal alarma_fsm : std_logic;
    signal ocupado_fsm : std_logic;
    signal estado_fsm : std_logic_vector(2 downto 0);
    signal error_supervisor : std_logic;
    signal error_total : std_logic;

    -- Tiempo e historial.
    signal pulso_segundo : std_logic;
    signal segundos, tiempo_guardado : std_logic_vector(7 downto 0);
    signal id_guardado : std_logic_vector(9 downto 0);
    signal color_guardado : std_logic_vector(1 downto 0);
    signal tamano_guardado, registro_valido : std_logic;

    -- Ultimo evento procesado.
    signal ultimo_color : std_logic_vector(1 downto 0);
    signal ultimo_tamano, hay_pieza : std_logic;

    -- Menu.
    signal modo_entrada, modo : std_logic_vector(3 downto 0);
    signal consulta_registros, consulta_cantidades : std_logic;
    signal siguiente, ultimo : std_logic;
    signal seleccion : unsigned(2 downto 0) := "001";
    signal cantidades_antes, por_color_antes : std_logic;

    -- Datos visibles.
    signal color_vista : std_logic_vector(1 downto 0);
    signal tamano_vista, hay_dato_visible : std_logic;
    signal categoria_vista : std_logic_vector(3 downto 0);

    -- Conversion decimal.
    signal numero_consulta : std_logic_vector(9 downto 0);
    signal total_c, total_d, total_u : std_logic_vector(3 downto 0);
    signal consulta_c, consulta_d, consulta_u :
        std_logic_vector(3 downto 0);

    signal visor_total_c, visor_total_d, visor_total_u :
        std_logic_vector(6 downto 0);

    signal visor_consulta_c, visor_consulta_d, visor_consulta_u :
        std_logic_vector(6 downto 0);

    signal visor_velocidad, visor_seleccion :
        std_logic_vector(6 downto 0);

    signal digito_seleccion : std_logic_vector(3 downto 0);

begin
    -- Ordenes de operacion, independientes del menu de consultas.
    MARCHA_FISICA <= marcha_real;
    EVENTO_VALIDO <= contar_sesion;
    CATEGORIA_FISICA <= categoria_actual;

    U_REINICIO : entity work.reinicio_seguro
        port map (
            reloj => RELOJ,
            reinicio_bajo => REINICIO_BAJO,
            reinicio_salida => reinicio_operacion
        );

    -- Reinicio de sesion solamente al configurar la FPGA.
    process(RELOJ)
    begin
        if rising_edge(RELOJ) then
            arranque_sesion <= arranque_sesion(2 downto 0) & '0';
        end if;
    end process;

    reinicio_sesion <= arranque_sesion(3);
    reinicio_alto <= reinicio_operacion or reinicio_sesion;

    -- Al soltar reset, se vuelve a leer el nivel actual de SW3.
    U_MARCHA_FILTRADA : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            boton_entrada => LINEA_MARCHA,
            pulso_salida => open,
            estado_salida => marcha_filtrada
        );

    -- La FSM avisa tambien de los rechazos para encender su indicacion.
    -- La RAM solo guarda piezas validas: un rechazo NO consume ID.
    guardar_sesion <=
        registrar_evento and pieza_valida and not reinicio_alto;

    contar_sesion <=
        contar_pieza_fsm and not reinicio_alto;

    U_CAPTURA : entity work.captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            presencia_baja => PRESENCIA,
            color_selector => SELECTOR_COLOR,
            tamano_selector => SELECTOR_TAMANO,
            nueva_pieza => nueva,
            presencia_activa => presente,
            color => color_actual,
            tamano => tamano_actual
        );

    U_REGLAS : entity work.tabla_reglas
        port map (
            color => color_actual,
            tamano => tamano_actual,
            ruta => categoria_actual,
            valida => pieza_valida
        );

    U_VELOCIDAD : entity work.selector_velocidad
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ,
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            boton_bajo => CAMBIO_VELOCIDAD,
            nivel_salida => NIVEL_FISICO,
            pulso_linea => pulso_linea,
            segmentos => visor_velocidad
        );

    U_ERRORES : entity work.supervisor_error
        generic map (
            CICLOS_ATASCO => CICLOS_ATASCO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            marcha => marcha_real,
            presencia_activa => presente,
            nueva_pieza => nueva,
            pieza_valida => pieza_valida,
            alarma => error_supervisor
        );

    U_FSM : entity work.maquina_estados_control
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            marcha => marcha_real,
            nueva_pieza => nueva,
            pieza_valida => pieza_valida,
            registrar_evento => registrar_evento,
            contar_pieza => contar_pieza_fsm,
            alarma_estado => alarma_fsm,
            ocupado => ocupado_fsm,
            estado_codigo => estado_fsm
        );

    error_total <= error_supervisor or alarma_fsm;
    bloqueo <= error_total or limite_total or limite_historial;

    U_LINEA : entity work.control_linea
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            marcha => marcha_filtrada,
            bloqueo => bloqueo,
            pulso_linea_entrada => pulso_linea,
            pulso_motor => open,
            led_linea => LINEA_ACTIVA,
            en_marcha => marcha_real
        );

    -- Estos contadores no se borran con BUTTON1.
    U_CONTEOS : entity work.conteo_categorias
        port map (
            reloj => RELOJ,
            reinicio => reinicio_sesion,
            registrar => contar_sesion,
            categoria => categoria_actual,
            seleccion => std_logic_vector(seleccion),
            por_color => modo(3),
            total => total,
            cantidad_seleccionada => cantidad_consultada,
            limite => limite_total
        );

    -- Indicacion operativa: permite mostrar tambien el rechazo,
    -- aunque ese rechazo no se escriba en el historial.
    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            ultimo_color <= "00";
            ultimo_tamano <= '0';
            hay_pieza <= '0';

        elsif rising_edge(RELOJ) then
            if registrar_evento = '1' then
                ultimo_color <= color_actual;
                ultimo_tamano <= tamano_actual;
                hay_pieza <= '1';
            end if;
        end if;
    end process;

    U_SEGUNDO : entity work.divisor_frecuencia
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_sesion,
            nivel => "01",
            pulso_linea => pulso_segundo
        );

    U_TIEMPO : entity work.contador_segundos
        port map (
            reloj => RELOJ,
            reinicio => reinicio_sesion,
            pulso_segundo => pulso_segundo,
            segundos => segundos
        );

    -- modo(0): menu activo.
    -- modo(1): identificador o tiempo.
    -- modo(2): registros o cantidades.
    -- modo(3): categorias o colores.
    modo_entrada <=
        CONTAR_POR_COLOR &
        VER_CANTIDADES &
        SELECCION_HISTORIAL &
        VER_HISTORIAL;

    G_MODO : for i in 0 to 3 generate
        U_FILTRO_MODO : entity work.filtro_boton
            generic map (
                CICLOS_ESTABLES => CICLOS_FILTRO
            )
            port map (
                reloj => RELOJ,
                reinicio => reinicio_alto,
                boton_entrada => modo_entrada(i),
                pulso_salida => open,
                estado_salida => modo(i)
            );
    end generate G_MODO;

    consulta_registros <= modo(0) and not modo(2);
    consulta_cantidades <= modo(0) and modo(2);

    U_SIGUIENTE : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            boton_entrada => SIGUIENTE_HISTORIAL,
            pulso_salida => siguiente,
            estado_salida => open
        );

    U_ULTIMO : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            boton_entrada => IR_ULTIMO,
            pulso_salida => ultimo,
            estado_salida => open
        );

    -- SW5 selecciona categorias 1..6 o colores 1..3.
    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            seleccion <= "001";
            cantidades_antes <= '0';
            por_color_antes <= '0';

        elsif rising_edge(RELOJ) then
            cantidades_antes <= consulta_cantidades;
            por_color_antes <= modo(3);

            if (consulta_cantidades = '1' and cantidades_antes = '0')
               or modo(3) /= por_color_antes then
                seleccion <= "001";

            elsif consulta_cantidades = '1' and siguiente = '1' then
                if (modo(3) = '1' and seleccion >= 3)
                   or seleccion >= 6 then
                    seleccion <= "001";
                else
                    seleccion <= seleccion + 1;
                end if;
            end if;
        end if;
    end process;

    U_HISTORIAL : entity work.historial_sesion
        port map (
            reloj => RELOJ,
            reinicio => reinicio_sesion,
            guardar => guardar_sesion,
            consulta => consulta_registros,
            siguiente => siguiente,
            ir_ultimo => ultimo,
            tiempo_entrada => segundos,
            color_entrada => color_actual,
            tamano_entrada => tamano_actual,
            identificador_salida => id_guardado,
            tiempo_salida => tiempo_guardado,
            color_salida => color_guardado,
            tamano_salida => tamano_guardado,
            registro_valido => registro_valido,
            limite => limite_historial
        );

    -- Selecciona los atributos visibles en los LEDs.
    process(
        modo, seleccion, ultimo_color, ultimo_tamano, hay_pieza,
        color_guardado, tamano_guardado, registro_valido
    )
    begin
        color_vista <= "00";
        tamano_vista <= '0';
        hay_dato_visible <= '0';

        if modo(0) = '0' then
            color_vista <= ultimo_color;
            tamano_vista <= ultimo_tamano;
            hay_dato_visible <= hay_pieza;

        elsif modo(2) = '0' then
            if registro_valido = '1' then
                color_vista <= color_guardado;
                tamano_vista <= tamano_guardado;
                hay_dato_visible <= '1';
            end if;

        else
            hay_dato_visible <= '1';

            if modo(3) = '1' then
                -- Al consultar por color no se indica un tamano.
                color_vista <= std_logic_vector(seleccion(1 downto 0));

            else
                case seleccion is
                    when "001" =>
                        color_vista <= "01";
                        tamano_vista <= '0';

                    when "010" =>
                        color_vista <= "01";
                        tamano_vista <= '1';

                    when "011" =>
                        color_vista <= "10";
                        tamano_vista <= '0';

                    when "100" =>
                        color_vista <= "10";
                        tamano_vista <= '1';

                    when "101" =>
                        color_vista <= "11";
                        tamano_vista <= '0';

                    when "110" =>
                        color_vista <= "11";
                        tamano_vista <= '1';

                    when others =>
                        hay_dato_visible <= '0';
                end case;
            end if;
        end if;
    end process;

    U_REGLA_VISTA : entity work.tabla_reglas
        port map (
            color => color_vista,
            tamano => tamano_vista,
            ruta => categoria_vista,
            valida => open
        );

    LED_COLOR <= color_vista;
    LED_TAMANO <= tamano_vista;

    RUTA_PIEZA <= categoria_vista
        when hay_dato_visible = '1' and
             not (consulta_cantidades = '1' and modo(3) = '1')
        else "0000";

    ALARMA <= error_total;
    LED_LIMITE <= limite_total or limite_historial;

    numero_consulta <=
        cantidad_consultada when consulta_cantidades = '1'
        else id_guardado when modo(1) = '0'
        else "00" & tiempo_guardado;

    U_DECIMAL_TOTAL : entity work.conversor_decimal_reloj
        port map (
            reloj => RELOJ,
            numero_binario => total,
            centenas => total_c,
            decenas => total_d,
            unidades => total_u
        );

    U_DECIMAL_CONSULTA : entity work.conversor_decimal_reloj
        port map (
            reloj => RELOJ,
            numero_binario => numero_consulta,
            centenas => consulta_c,
            decenas => consulta_d,
            unidades => consulta_u
        );

    U_TOTAL_C : entity work.decodificador_7segmentos
        port map (
            numero => total_c,
            segmentos => visor_total_c
        );

    U_TOTAL_D : entity work.decodificador_7segmentos
        port map (
            numero => total_d,
            segmentos => visor_total_d
        );

    U_TOTAL_U : entity work.decodificador_7segmentos
        port map (
            numero => total_u,
            segmentos => visor_total_u
        );

    U_CONSULTA_C : entity work.decodificador_7segmentos
        port map (
            numero => consulta_c,
            segmentos => visor_consulta_c
        );

    U_CONSULTA_D : entity work.decodificador_7segmentos
        port map (
            numero => consulta_d,
            segmentos => visor_consulta_d
        );

    U_CONSULTA_U : entity work.decodificador_7segmentos
        port map (
            numero => consulta_u,
            segmentos => visor_consulta_u
        );

    digito_seleccion <= '0' & std_logic_vector(seleccion);

    U_SELECCION : entity work.decodificador_7segmentos
        port map (
            numero => digito_seleccion,
            segmentos => visor_seleccion
        );

    process(
        modo, registro_valido,
        visor_total_u, visor_total_d, visor_total_c,
        visor_velocidad,
        visor_consulta_u, visor_consulta_d, visor_consulta_c,
        visor_seleccion
    )
    begin
        VISOR_0 <= "1111111";
        VISOR_1 <= "1111111";
        VISOR_2 <= "1111111";
        VISOR_3 <= "1111111";

        if modo(0) = '0' then
            -- HEX3: velocidad. HEX2..HEX0: total decimal.
            VISOR_0 <= visor_total_u;
            VISOR_1 <= visor_total_d;
            VISOR_2 <= visor_total_c;
            VISOR_3 <= visor_velocidad;

        elsif modo(2) = '1' then
            -- HEX3: seleccion. HEX2..HEX0: cantidad.
            VISOR_0 <= visor_consulta_u;
            VISOR_1 <= visor_consulta_d;
            VISOR_2 <= visor_consulta_c;
            VISOR_3 <= visor_seleccion;

        elsif registro_valido = '1' then
            -- Historial: ID o tiempo. HEX3 apagado.
            VISOR_0 <= visor_consulta_u;
            VISOR_1 <= visor_consulta_d;
            VISOR_2 <= visor_consulta_c;
        end if;
    end process;

end architecture estructural;
