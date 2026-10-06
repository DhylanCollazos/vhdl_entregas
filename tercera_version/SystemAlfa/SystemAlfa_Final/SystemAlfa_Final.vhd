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
        RELOJ, REINICIO_BAJO, PRESENCIA, CAMBIO_VELOCIDAD :
            in std_logic;

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
            out std_logic_vector(6 downto 0)
    );
end entity SystemAlfa_Final;

architecture estructural of SystemAlfa_Final is

    component reinicio_seguro is
        port (
            reloj, reinicio_bajo : in std_logic;
            reinicio_salida : out std_logic
        );
    end component;

    component captura_pieza is
        generic (
            CICLOS_FILTRO : positive := 500000
        );
        port (
            reloj, reinicio, presencia_baja : in std_logic;
            color_selector : in std_logic_vector(1 downto 0);
            tamano_selector : in std_logic;
            nueva_pieza, presencia_activa : out std_logic;
            color : out std_logic_vector(1 downto 0);
            tamano : out std_logic
        );
    end component;

    component tabla_reglas is
        port (
            color : in std_logic_vector(1 downto 0);
            tamano : in std_logic;
            ruta : out std_logic_vector(3 downto 0);
            valida : out std_logic
        );
    end component;

    component selector_velocidad is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO : positive := 500000
        );
        port (
            reloj, reinicio, boton_bajo : in std_logic;
            nivel_salida : out std_logic_vector(1 downto 0);
            pulso_linea : out std_logic;
            segmentos : out std_logic_vector(6 downto 0)
        );
    end component;

    component control_linea is
        port (
            reloj, reinicio, marcha, bloqueo, pulso_linea_entrada :
                in std_logic;

            pulso_motor, led_linea, en_marcha : out std_logic
        );
    end component;

    component supervisor_error is
        generic (
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            reloj, reinicio, marcha, presencia_activa : in std_logic;
            nueva_pieza, pieza_valida : in std_logic;
            alarma : out std_logic
        );
    end component;

    component conteo_categorias is
        port (
            reloj, reinicio, registrar : in std_logic;
            categoria : in std_logic_vector(3 downto 0);
            seleccion : in std_logic_vector(2 downto 0);
            por_color : in std_logic;

            total, cantidad_seleccionada :
                out std_logic_vector(9 downto 0);

            limite : out std_logic
        );
    end component;

    component historial_sesion is
        port (
            reloj, reinicio, guardar : in std_logic;
            consulta, siguiente, ir_ultimo : in std_logic;
            tiempo_entrada : in std_logic_vector(7 downto 0);
            color_entrada : in std_logic_vector(1 downto 0);
            tamano_entrada : in std_logic;

            identificador_salida : out std_logic_vector(9 downto 0);
            tiempo_salida : out std_logic_vector(7 downto 0);
            color_salida : out std_logic_vector(1 downto 0);

            tamano_salida, registro_valido, limite : out std_logic
        );
    end component;

    component divisor_frecuencia is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000
        );
        port (
            reloj, reinicio : in std_logic;
            nivel : in std_logic_vector(1 downto 0);
            pulso_linea : out std_logic
        );
    end component;

    component contador_segundos is
        port (
            reloj, reinicio, pulso_segundo : in std_logic;
            segundos : out std_logic_vector(7 downto 0)
        );
    end component;

    component sincronizador is
        generic (
            ANCHO_BITS : positive := 1
        );
        port (
            reloj, reinicio : in std_logic;
            entrada : in std_logic_vector(ANCHO_BITS-1 downto 0);
            salida : out std_logic_vector(ANCHO_BITS-1 downto 0)
        );
    end component;

    component filtro_boton is
        generic (
            CICLOS_ESTABLES : positive := 500000
        );
        port (
            reloj, reinicio, boton_entrada : in std_logic;
            pulso_salida, estado_salida : out std_logic
        );
    end component;

    component conversor_binario_decimal is
        port (
            numero_binario : in std_logic_vector(9 downto 0);
            centenas : out std_logic_vector(3 downto 0);
            decenas : out std_logic_vector(3 downto 0);
            unidades : out std_logic_vector(3 downto 0)
        );
    end component;

    component decodificador_7segmentos is
        port (
            numero : in std_logic_vector(3 downto 0);
            segmentos : out std_logic_vector(6 downto 0)
        );
    end component;

    -- Captura y clasificacion.
    signal reinicio_alto, nueva, presente : std_logic;
    signal tamano_actual, pieza_valida : std_logic;
    signal color_actual : std_logic_vector(1 downto 0);
    signal categoria_actual : std_logic_vector(3 downto 0);

    -- Transporte y conteo.
    signal pulso_linea, marcha_real, error, bloqueo : std_logic;
    signal registrar_evento, limite_total, limite_historial : std_logic;
    signal total, cantidad_consultada : std_logic_vector(9 downto 0);

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

    U_REINICIO : reinicio_seguro
        port map (
            reloj => RELOJ,
            reinicio_bajo => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_CAPTURA : captura_pieza
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

    U_REGLAS : tabla_reglas
        port map (
            color => color_actual,
            tamano => tamano_actual,
            ruta => categoria_actual,
            valida => pieza_valida
        );

    U_VELOCIDAD : selector_velocidad
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ,
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            boton_bajo => CAMBIO_VELOCIDAD,
            nivel_salida => open,
            pulso_linea => pulso_linea,
            segmentos => visor_velocidad
        );

    U_ERRORES : supervisor_error
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
            alarma => error
        );

    bloqueo <= error or limite_total or limite_historial;

    U_LINEA : control_linea
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            marcha => LINEA_MARCHA,
            bloqueo => bloqueo,
            pulso_linea_entrada => pulso_linea,
            pulso_motor => open,
            led_linea => LINEA_ACTIVA,
            en_marcha => marcha_real
        );

    -- Con la linea detenida no se registra ni se cuenta.
    registrar_evento <= nueva and marcha_real;

    U_CONTEOS : conteo_categorias
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            registrar => registrar_evento,
            categoria => categoria_actual,
            seleccion => std_logic_vector(seleccion),
            por_color => modo(3),
            total => total,
            cantidad_seleccionada => cantidad_consultada,
            limite => limite_total
        );

    -- Conserva los atributos del ultimo evento procesado.
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

    U_SEGUNDO : divisor_frecuencia
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            nivel => "01",
            pulso_linea => pulso_segundo
        );

    U_TIEMPO : contador_segundos
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
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

    U_MODO : sincronizador
        generic map (
            ANCHO_BITS => 4
        )
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            entrada => modo_entrada,
            salida => modo
        );

    consulta_registros <= modo(0) and not modo(2);
    consulta_cantidades <= modo(0) and modo(2);

    U_SIGUIENTE : filtro_boton
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

    U_ULTIMO : filtro_boton
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

    U_HISTORIAL : historial_sesion
        port map (
            reloj => RELOJ,
            reinicio => reinicio_alto,
            guardar => registrar_evento,
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

    -- Selecciona los atributos que se mostraran en los LEDs.
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

                -- En totales por color no se muestra un tamano.
                color_vista <= std_logic_vector(seleccion(1 downto 0));

            else

                case std_logic_vector(seleccion) is

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

    U_REGLA_VISTA : tabla_reglas
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

    ALARMA <= error;
    LED_LIMITE <= limite_total or limite_historial;

    -- La consulta puede ser cantidad, identificador o tiempo.
    numero_consulta <=
        cantidad_consultada when consulta_cantidades = '1'
        else id_guardado when modo(1) = '0'
        else "00" & tiempo_guardado;

    U_DECIMAL_TOTAL : conversor_binario_decimal
        port map (
            numero_binario => total,
            centenas => total_c,
            decenas => total_d,
            unidades => total_u
        );

    U_DECIMAL_CONSULTA : conversor_binario_decimal
        port map (
            numero_binario => numero_consulta,
            centenas => consulta_c,
            decenas => consulta_d,
            unidades => consulta_u
        );

    U_TOTAL_C : decodificador_7segmentos
        port map (
            numero => total_c,
            segmentos => visor_total_c
        );

    U_TOTAL_D : decodificador_7segmentos
        port map (
            numero => total_d,
            segmentos => visor_total_d
        );

    U_TOTAL_U : decodificador_7segmentos
        port map (
            numero => total_u,
            segmentos => visor_total_u
        );

    U_CONSULTA_C : decodificador_7segmentos
        port map (
            numero => consulta_c,
            segmentos => visor_consulta_c
        );

    U_CONSULTA_D : decodificador_7segmentos
        port map (
            numero => consulta_d,
            segmentos => visor_consulta_d
        );

    U_CONSULTA_U : decodificador_7segmentos
        port map (
            numero => consulta_u,
            segmentos => visor_consulta_u
        );

    digito_seleccion <= '0' & std_logic_vector(seleccion);

    U_SELECCION : decodificador_7segmentos
        port map (
            numero => digito_seleccion,
            segmentos => visor_seleccion
        );

    -- Seleccion final de los cuatro displays.
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

            -- Modo normal: total decimal y velocidad.
            VISOR_0 <= visor_total_u;
            VISOR_1 <= visor_velocidad;
            VISOR_2 <= visor_total_d;
            VISOR_3 <= visor_total_c;

        elsif modo(2) = '1' then

            -- Cantidades: categoria/color y cantidad decimal.
            VISOR_0 <= visor_consulta_u;
            VISOR_1 <= visor_consulta_d;
            VISOR_2 <= visor_consulta_c;
            VISOR_3 <= visor_seleccion;

        elsif registro_valido = '1' then

            -- Registro individual: identificador o tiempo decimal.
            VISOR_0 <= visor_consulta_u;
            VISOR_1 <= visor_consulta_d;
            VISOR_2 <= visor_consulta_c;

        end if;

    end process;

end architecture estructural;