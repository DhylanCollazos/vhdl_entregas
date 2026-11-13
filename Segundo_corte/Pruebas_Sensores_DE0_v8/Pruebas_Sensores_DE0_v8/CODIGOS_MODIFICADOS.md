# Solo los seis archivos VHDL modificados

Contenido completo para copiar en la carpeta nueva. No reemplazar todavia los lectores del TOP integrado antiguo; ver LEEME.md.

## Hardware_Sensores/entrada_presencia_v183.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;

-- Adaptador del sensor infrarrojo V183 implementado como FSM Moore.
--
-- Estados:
--   INICIALIZAR          : espera que el sensor quede libre despues del reset.
--   SIN_PIEZA            : espera una nueva deteccion.
--   CONFIRMAR_PRESENCIA  : filtra la aparicion de una pieza.
--   GENERAR_PULSO        : genera un pulso de un ciclo por pieza.
--   CON_PIEZA            : mantiene presencia_activa mientras la pieza esta presente.
--   CONFIRMAR_RETIRO     : filtra la retirada de la pieza.
--
-- La salida presencia_activa usa logica positiva:
--   1 = hay pieza
--   0 = no hay pieza
entity entrada_presencia_v183 is
    generic (
        CICLOS_ESTABLES : positive := 250000;
        ACTIVO_BAJO     : boolean  := true
    );
    port (
        reloj            : in  std_logic;
        reinicio         : in  std_logic;
        sensor_entrada   : in  std_logic;
        presencia_activa : out std_logic;
        pulso_pieza      : out std_logic
    );
end entity entrada_presencia_v183;

architecture fsm_tres_procesos of entrada_presencia_v183 is

    type tipo_estado is (
        INICIALIZAR,
        SIN_PIEZA,
        CONFIRMAR_PRESENCIA,
        GENERAR_PULSO,
        CON_PIEZA,
        CONFIRMAR_RETIRO
    );

    signal estado_actual    : tipo_estado := INICIALIZAR;
    signal estado_siguiente : tipo_estado := INICIALIZAR;

    signal sensor_normalizado : std_logic;
    signal etapa_1            : std_logic := '0';
    signal etapa_2            : std_logic := '0';
    signal sincronizacion_valida : std_logic_vector(1 downto 0) := "00";

    signal cuenta_estabilidad : integer range 0 to CICLOS_ESTABLES-1 := 0;

begin

    sensor_normalizado <= not sensor_entrada
        when ACTIVO_BAJO
        else sensor_entrada;

    ------------------------------------------------------------------------
    -- PROCESO 1: registro de estado, sincronizacion y contador de filtro
    ------------------------------------------------------------------------
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            estado_actual      <= INICIALIZAR;
            etapa_1            <= '0';
            etapa_2            <= '0';
            sincronizacion_valida <= "00";
            cuenta_estabilidad <= 0;

        elsif rising_edge(reloj) then
            etapa_1 <= sensor_normalizado;
            etapa_2 <= etapa_1;
            sincronizacion_valida <= sincronizacion_valida(0) & '1';

            estado_actual <= estado_siguiente;

            case estado_actual is

                when INICIALIZAR =>
                    -- Tras el reset se exige observar el sensor libre.
                    if sincronizacion_valida(1) = '1' and etapa_2 = '0' then
                        if cuenta_estabilidad < CICLOS_ESTABLES-1 then
                            cuenta_estabilidad <= cuenta_estabilidad + 1;
                        end if;
                    else
                        cuenta_estabilidad <= 0;
                    end if;

                when CONFIRMAR_PRESENCIA =>
                    if etapa_2 = '1' then
                        if cuenta_estabilidad < CICLOS_ESTABLES-1 then
                            cuenta_estabilidad <= cuenta_estabilidad + 1;
                        end if;
                    else
                        cuenta_estabilidad <= 0;
                    end if;

                when CONFIRMAR_RETIRO =>
                    if etapa_2 = '0' then
                        if cuenta_estabilidad < CICLOS_ESTABLES-1 then
                            cuenta_estabilidad <= cuenta_estabilidad + 1;
                        end if;
                    else
                        cuenta_estabilidad <= 0;
                    end if;

                when others =>
                    cuenta_estabilidad <= 0;

            end case;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 2: logica del estado siguiente
    ------------------------------------------------------------------------
    process(estado_actual, etapa_2, cuenta_estabilidad, sincronizacion_valida)
    begin
        estado_siguiente <= estado_actual;

        case estado_actual is

            when INICIALIZAR =>
                if sincronizacion_valida(1) = '1' and etapa_2 = '0' and
                   cuenta_estabilidad = CICLOS_ESTABLES-1 then
                    estado_siguiente <= SIN_PIEZA;
                end if;

            when SIN_PIEZA =>
                if etapa_2 = '1' then
                    estado_siguiente <= CONFIRMAR_PRESENCIA;
                end if;

            when CONFIRMAR_PRESENCIA =>
                if etapa_2 = '0' then
                    estado_siguiente <= SIN_PIEZA;
                elsif cuenta_estabilidad = CICLOS_ESTABLES-1 then
                    estado_siguiente <= GENERAR_PULSO;
                end if;

            when GENERAR_PULSO =>
                estado_siguiente <= CON_PIEZA;

            when CON_PIEZA =>
                if etapa_2 = '0' then
                    estado_siguiente <= CONFIRMAR_RETIRO;
                end if;

            when CONFIRMAR_RETIRO =>
                if etapa_2 = '1' then
                    estado_siguiente <= CON_PIEZA;
                elsif cuenta_estabilidad = CICLOS_ESTABLES-1 then
                    estado_siguiente <= SIN_PIEZA;
                end if;

        end case;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 3: logica de salidas Moore
    ------------------------------------------------------------------------
    process(estado_actual)
    begin
        presencia_activa <= '0';
        pulso_pieza      <= '0';

        case estado_actual is

            when GENERAR_PULSO =>
                presencia_activa <= '1';
                pulso_pieza      <= '1';

            when CON_PIEZA | CONFIRMAR_RETIRO =>
                presencia_activa <= '1';

            when others =>
                null;

        end case;
    end process;

end architecture fsm_tres_procesos;
```

## Hardware_Sensores/lector_hcsr04.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Lector del HC-SR04 implementado como FSM Moore de tres procesos.
--
-- Estados:
--   ESPERA        : espera la orden iniciar.
--   DISPARO       : mantiene TRIG en alto durante 10 us.
--   ESPERAR_ECHO  : espera el flanco de subida de ECHO.
--   MEDIR_ECHO    : cuenta el tiempo que ECHO permanece en alto.
--   CALCULAR      : convierte el tiempo a distancia y clasifica el tamano.
--   FINALIZAR     : genera medicion_lista durante un ciclo.
entity lector_hcsr04 is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        UMBRAL_GRANDE_CM    : positive := 25;
        UMBRAL_PEQUENA_CM   : positive := 30;
        TIEMPO_MAXIMO_US    : positive := 40000;
        INTERVALO_MINIMO_US : positive := 61000
    );
    port (
        reloj           : in  std_logic;
        reinicio        : in  std_logic;
        iniciar         : in  std_logic;
        echo_entrada    : in  std_logic;

        trigger_salida  : out std_logic;
        distancia_cm    : out std_logic_vector(7 downto 0);
        tamano          : out std_logic;
        medicion_lista  : out std_logic;
        medicion_valida : out std_logic;
        ocupado         : out std_logic
    );
end entity lector_hcsr04;

architecture fsm_tres_procesos of lector_hcsr04 is

    constant CICLOS_POR_US : positive := FRECUENCIA_RELOJ_HZ / 1000000;
    constant CICLOS_TRIGGER : positive := 10 * CICLOS_POR_US;
    constant CICLOS_TIMEOUT : positive := TIEMPO_MAXIMO_US * CICLOS_POR_US;
    constant CICLOS_POR_CM  : positive := 58 * CICLOS_POR_US;

    constant CICLOS_INTERVALO : positive := INTERVALO_MINIMO_US * CICLOS_POR_US;

    type tipo_estado is (
        ESPERA,
        DISPARO,
        ESPERAR_ECHO,
        MEDIR_ECHO,
        CALCULAR,
        FINALIZAR
    );

    signal estado_actual    : tipo_estado := ESPERA;
    signal estado_siguiente : tipo_estado := ESPERA;

    signal inicio_anterior : std_logic := '0';
    signal cuenta_intervalo : integer range 0 to CICLOS_INTERVALO := CICLOS_INTERVALO;
    signal echo_1 : std_logic := '0';
    signal echo_2 : std_logic := '0';

    signal cuenta_trigger : integer range 0 to CICLOS_TRIGGER-1 := 0;
    signal cuenta_timeout : integer range 0 to CICLOS_TIMEOUT-1 := 0;
    signal cuenta_echo    : integer range 0 to CICLOS_TIMEOUT-1 := 0;
    signal echo_capturado : integer range 0 to CICLOS_TIMEOUT-1 := 0;
    -- Division por restas: un centimetro por ciclo, sin un divisor grande.
    signal resto_echo : integer range 0 to CICLOS_TIMEOUT+CICLOS_POR_CM := 0;
    signal distancia_calculo : integer range 0 to 255 := 0;

    signal distancia_reg : integer range 0 to 255 := 0;
    signal tamano_reg    : std_logic := '0';
    signal valida_reg    : std_logic := '0';

begin
    assert FRECUENCIA_RELOJ_HZ >= 1000000 and FRECUENCIA_RELOJ_HZ mod 1000000 = 0
        report "Usar un reloj multiplo entero de 1 MHz" severity failure;
    assert UMBRAL_GRANDE_CM < UMBRAL_PEQUENA_CM and UMBRAL_PEQUENA_CM <= 255
        report "Umbrales de tamano incorrectos" severity failure;

    ------------------------------------------------------------------------
    -- PROCESO 1: registro de estado, sincronizacion y registros de datos
    ------------------------------------------------------------------------
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            estado_actual    <= ESPERA;
            inicio_anterior <= '0';
            cuenta_intervalo <= CICLOS_INTERVALO;
            echo_1           <= '0';
            echo_2           <= '0';
            cuenta_trigger   <= 0;
            cuenta_timeout   <= 0;
            cuenta_echo      <= 0;
            echo_capturado   <= 0;
            resto_echo <= 0;
            distancia_calculo <= 0;
            distancia_reg    <= 0;
            tamano_reg       <= '0';
            valida_reg       <= '0';

        elsif rising_edge(reloj) then
            inicio_anterior <= iniciar;
            if cuenta_intervalo < CICLOS_INTERVALO then
                cuenta_intervalo <= cuenta_intervalo + 1;
            end if;
            echo_1 <= echo_entrada;
            echo_2 <= echo_1;

            estado_actual <= estado_siguiente;

            case estado_actual is

                when ESPERA =>
                    cuenta_trigger <= 0;
                    cuenta_timeout <= 0;
                    cuenta_echo    <= 0;

                    if iniciar = '1' and inicio_anterior = '0' and
                       cuenta_intervalo = CICLOS_INTERVALO then
                        cuenta_intervalo <= 0;
                        distancia_reg  <= 0;
                        tamano_reg     <= '0';
                        valida_reg     <= '0';
                        echo_capturado <= 0;
                        resto_echo <= 0;
                        distancia_calculo <= 0;
                    end if;

                when DISPARO =>
                    if cuenta_trigger = CICLOS_TRIGGER-1 then
                        cuenta_trigger <= 0;
                    else
                        cuenta_trigger <= cuenta_trigger + 1;
                    end if;

                when ESPERAR_ECHO =>
                    if echo_2 = '1' then
                        cuenta_timeout <= 0;
                        cuenta_echo    <= 1; -- Incluye el primer ciclo alto observado.

                    elsif cuenta_timeout = CICLOS_TIMEOUT-1 then
                        cuenta_timeout <= 0;
                        distancia_reg  <= 0;
                        tamano_reg     <= '0';
                        valida_reg     <= '0';

                    else
                        cuenta_timeout <= cuenta_timeout + 1;
                    end if;

                when MEDIR_ECHO =>
                    if echo_2 = '1' then
                        if cuenta_echo = CICLOS_TIMEOUT-1 then
                            cuenta_echo   <= 0;
                            distancia_reg <= 0;
                            tamano_reg    <= '0';
                            valida_reg    <= '0';
                        else
                            cuenta_echo <= cuenta_echo + 1;
                        end if;
                    else
                        echo_capturado <= cuenta_echo;
                        resto_echo <= cuenta_echo + CICLOS_POR_CM/2;
                        cuenta_echo    <= 0;
                    end if;

                when CALCULAR =>
                    if resto_echo >= CICLOS_POR_CM and distancia_calculo < 255 then
                        resto_echo <= resto_echo - CICLOS_POR_CM;
                        distancia_calculo <= distancia_calculo + 1;
                    else
                        distancia_reg <= distancia_calculo;

                    if echo_capturado >= 2*CICLOS_POR_CM and
                       echo_capturado <= UMBRAL_GRANDE_CM*CICLOS_POR_CM then
                        tamano_reg <= '1';
                        valida_reg <= '1';

                    elsif echo_capturado >= UMBRAL_PEQUENA_CM*CICLOS_POR_CM and
                          echo_capturado <= 255*CICLOS_POR_CM then
                        tamano_reg <= '0';
                        valida_reg <= '1';

                    else
                        tamano_reg <= '0';
                        valida_reg <= '0';
                    end if;
                    end if;

                when FINALIZAR =>
                    null;

            end case;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 2: logica del estado siguiente
    ------------------------------------------------------------------------
    process(
        estado_actual,
        iniciar,
        echo_2,
        cuenta_trigger,
        cuenta_timeout,
        cuenta_echo, inicio_anterior, cuenta_intervalo,
        resto_echo, distancia_calculo
    )
    begin
        estado_siguiente <= estado_actual;

        case estado_actual is

            when ESPERA =>
                if iniciar = '1' and inicio_anterior = '0' and
                   cuenta_intervalo = CICLOS_INTERVALO then
                    if echo_2 = '1' then
                        estado_siguiente <= FINALIZAR; -- ECHO atascado antes del disparo.
                    else
                        estado_siguiente <= DISPARO;
                    end if;
                end if;

            when DISPARO =>
                if cuenta_trigger = CICLOS_TRIGGER-1 then
                    estado_siguiente <= ESPERAR_ECHO;
                end if;

            when ESPERAR_ECHO =>
                if echo_2 = '1' then
                    estado_siguiente <= MEDIR_ECHO;
                elsif cuenta_timeout = CICLOS_TIMEOUT-1 then
                    estado_siguiente <= FINALIZAR;
                end if;

            when MEDIR_ECHO =>
                if echo_2 = '0' then
                    estado_siguiente <= CALCULAR;
                elsif cuenta_echo = CICLOS_TIMEOUT-1 then
                    estado_siguiente <= FINALIZAR;
                end if;

            when CALCULAR =>
                if resto_echo < CICLOS_POR_CM or distancia_calculo = 255 then
                    estado_siguiente <= FINALIZAR;
                end if;

            when FINALIZAR =>
                estado_siguiente <= ESPERA;

        end case;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 3: logica de salidas Moore
    ------------------------------------------------------------------------
    process(estado_actual)
    begin
        trigger_salida <= '0';
        medicion_lista <= '0';
        ocupado        <= '1';

        case estado_actual is

            when ESPERA =>
                ocupado <= '0';

            when DISPARO =>
                trigger_salida <= '1';

            when FINALIZAR =>
                ocupado        <= '0';
                medicion_lista <= '1';

            when others =>
                null;

        end case;
    end process;

    distancia_cm    <= std_logic_vector(to_unsigned(distancia_reg, 8));
    tamano          <= tamano_reg;
    medicion_valida <= valida_reg;

end architecture fsm_tres_procesos;
```

## Hardware_Sensores/lector_tcs3200.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Lector del TCS3200/GY-31 implementado como FSM Moore de tres procesos.
--
-- S0=1 y S1=0 seleccionan escala de frecuencia del 20 %.
-- La FSM asienta y mide los filtros rojo, verde y azul; despues clasifica.
-- La referencia negra quita el fondo; las ganancias compensan cada canal
-- usando la diferencia medida entre blanco y negro.
entity lector_tcs3200 is
    generic (
        VENTANA_CICLOS      : positive := 500000;
        ASENTAMIENTO_CICLOS : positive := 5000;
        CLASIFICACION_HABILITADA : boolean := false;
        BASE_NEGRA_ROJO     : natural  := 26;
        BASE_NEGRA_VERDE    : natural  := 26;
        BASE_NEGRA_AZUL     : natural  := 34;
        GANANCIA_ROJO_Q5    : positive := 85;
        GANANCIA_VERDE_Q5   : positive := 109;
        GANANCIA_AZUL_Q5    : positive := 115;
        SENAL_MINIMA        : positive := 10
    );
    port (
        reloj           : in  std_logic;
        reinicio        : in  std_logic;
        iniciar         : in  std_logic;
        tcs_out         : in  std_logic;

        tcs_s0          : out std_logic;
        tcs_s1          : out std_logic;
        tcs_s2          : out std_logic;
        tcs_s3          : out std_logic;

        color           : out std_logic_vector(1 downto 0);
        valor_rojo      : out std_logic_vector(15 downto 0);
        valor_verde     : out std_logic_vector(15 downto 0);
        valor_azul      : out std_logic_vector(15 downto 0);
        medicion_lista  : out std_logic;
        medicion_valida : out std_logic;
        ocupado         : out std_logic
    );
end entity lector_tcs3200;

architecture fsm_tres_procesos of lector_tcs3200 is

    type tipo_estado is (
        ESPERA,
        ASENTAR_ROJO,
        MEDIR_ROJO,
        ASENTAR_VERDE,
        MEDIR_VERDE,
        ASENTAR_AZUL,
        MEDIR_AZUL,
        CLASIFICAR,
        FINALIZAR
    );

    signal estado_actual    : tipo_estado := ESPERA;
    signal estado_siguiente : tipo_estado := ESPERA;

    signal inicio_anterior : std_logic := '0';
    signal out_1        : std_logic := '0';
    signal out_2        : std_logic := '0';
    signal out_anterior : std_logic := '0';
    signal flanco_subida: std_logic;

    signal cuenta_ventana      : integer range 0 to VENTANA_CICLOS-1 := 0;
    signal cuenta_asentamiento : integer range 0 to ASENTAMIENTO_CICLOS-1 := 0;
    signal cuenta_pulsos       : integer range 0 to 65535 := 0;

    signal rojo_reg  : integer range 0 to 65535 := 0;
    signal verde_reg : integer range 0 to 65535 := 0;
    signal azul_reg  : integer range 0 to 65535 := 0;

    signal color_reg  : std_logic_vector(1 downto 0) := "00";
    signal valida_reg : std_logic := '0';

begin
    flanco_subida <= out_2 and not out_anterior;

    ------------------------------------------------------------------------
    -- PROCESO 1: registro de estado, sincronizacion, contadores y datos
    ------------------------------------------------------------------------
    process(reloj, reinicio)
        variable pulsos_finales : integer;
        variable diferencia : integer range 0 to 65535;
        variable producto : integer range 0 to 8000000;
        variable puntaje_rojo : integer range 0 to 300000;
        variable puntaje_verde : integer range 0 to 300000;
        variable puntaje_azul : integer range 0 to 300000;
    begin
        if reinicio = '1' then
            estado_actual        <= ESPERA;
            inicio_anterior <= '0';
            out_1                <= '0';
            out_2                <= '0';
            out_anterior         <= '0';
            cuenta_ventana       <= 0;
            cuenta_asentamiento  <= 0;
            cuenta_pulsos        <= 0;
            rojo_reg             <= 0;
            verde_reg            <= 0;
            azul_reg             <= 0;
            color_reg            <= "00";
            valida_reg           <= '0';

        elsif rising_edge(reloj) then
            inicio_anterior <= iniciar;
            out_1        <= tcs_out;
            out_2        <= out_1;
            out_anterior <= out_2;

            estado_actual <= estado_siguiente;

            case estado_actual is

                when ESPERA =>
                    cuenta_ventana      <= 0;
                    cuenta_asentamiento <= 0;
                    cuenta_pulsos       <= 0;

                    if iniciar = '1' and inicio_anterior = '0' then
                        rojo_reg   <= 0;
                        verde_reg  <= 0;
                        azul_reg   <= 0;
                        color_reg  <= "00";
                        valida_reg <= '0';
                    end if;

                when ASENTAR_ROJO | ASENTAR_VERDE | ASENTAR_AZUL =>
                    cuenta_pulsos  <= 0;
                    cuenta_ventana <= 0;

                    if cuenta_asentamiento = ASENTAMIENTO_CICLOS-1 then
                        cuenta_asentamiento <= 0;
                    else
                        cuenta_asentamiento <= cuenta_asentamiento + 1;
                    end if;

                when MEDIR_ROJO =>
                    pulsos_finales := cuenta_pulsos;

                    if flanco_subida = '1' and pulsos_finales < 65535 then
                        pulsos_finales := pulsos_finales + 1;
                    end if;

                    if cuenta_ventana = VENTANA_CICLOS-1 then
                        rojo_reg       <= pulsos_finales;
                        cuenta_pulsos  <= 0;
                        cuenta_ventana <= 0;
                    else
                        cuenta_pulsos  <= pulsos_finales;
                        cuenta_ventana <= cuenta_ventana + 1;
                    end if;

                when MEDIR_VERDE =>
                    pulsos_finales := cuenta_pulsos;

                    if flanco_subida = '1' and pulsos_finales < 65535 then
                        pulsos_finales := pulsos_finales + 1;
                    end if;

                    if cuenta_ventana = VENTANA_CICLOS-1 then
                        verde_reg      <= pulsos_finales;
                        cuenta_pulsos  <= 0;
                        cuenta_ventana <= 0;
                    else
                        cuenta_pulsos  <= pulsos_finales;
                        cuenta_ventana <= cuenta_ventana + 1;
                    end if;

                when MEDIR_AZUL =>
                    pulsos_finales := cuenta_pulsos;

                    if flanco_subida = '1' and pulsos_finales < 65535 then
                        pulsos_finales := pulsos_finales + 1;
                    end if;

                    if cuenta_ventana = VENTANA_CICLOS-1 then
                        azul_reg       <= pulsos_finales;
                        cuenta_pulsos  <= 0;
                        cuenta_ventana <= 0;
                    else
                        cuenta_pulsos  <= pulsos_finales;
                        cuenta_ventana <= cuenta_ventana + 1;
                    end if;

                when CLASIFICAR =>
                    color_reg  <= "00";
                    valida_reg <= '0';

                    if CLASIFICACION_HABILITADA and
                       rojo_reg < 65535 and verde_reg < 65535 and azul_reg < 65535 then
                        -- Resta el nivel negro y compensa la sensibilidad
                        -- distinta de cada canal con la referencia blanca.
                        if rojo_reg > BASE_NEGRA_ROJO then
                            diferencia := rojo_reg - BASE_NEGRA_ROJO;
                        else
                            diferencia := 0;
                        end if;
                        producto := diferencia * GANANCIA_ROJO_Q5 + 16;
                        puntaje_rojo := producto / 32;

                        if verde_reg > BASE_NEGRA_VERDE then
                            diferencia := verde_reg - BASE_NEGRA_VERDE;
                        else
                            diferencia := 0;
                        end if;
                        producto := diferencia * GANANCIA_VERDE_Q5 + 16;
                        puntaje_verde := producto / 32;

                        if azul_reg > BASE_NEGRA_AZUL then
                            diferencia := azul_reg - BASE_NEGRA_AZUL;
                        else
                            diferencia := 0;
                        end if;
                        producto := diferencia * GANANCIA_AZUL_Q5 + 16;
                        puntaje_azul := producto / 32;

                        -- El canal ganador debe superar al segundo por >20 %.
                        -- El blanco queda equilibrado y se rechaza.
                        if puntaje_rojo >= SENAL_MINIMA and
                           puntaje_rojo * 5 > puntaje_verde * 6 and
                           puntaje_rojo * 5 > puntaje_azul * 6 then
                            color_reg  <= "01";
                            valida_reg <= '1';

                        elsif puntaje_verde >= SENAL_MINIMA and
                              puntaje_verde * 5 > puntaje_rojo * 6 and
                              puntaje_verde * 5 > puntaje_azul * 6 then
                            color_reg  <= "10";
                            valida_reg <= '1';

                        elsif puntaje_azul >= SENAL_MINIMA and
                              puntaje_azul * 5 > puntaje_rojo * 6 and
                              puntaje_azul * 5 > puntaje_verde * 6 then
                            color_reg  <= "11";
                            valida_reg <= '1';
                        end if;

                    end if;

                when FINALIZAR =>
                    null;

            end case;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 2: logica del estado siguiente
    ------------------------------------------------------------------------
    process(
        estado_actual,
        iniciar,
        cuenta_asentamiento,
        cuenta_ventana, inicio_anterior
    )
    begin
        estado_siguiente <= estado_actual;

        case estado_actual is

            when ESPERA =>
                if iniciar = '1' and inicio_anterior = '0' then
                    estado_siguiente <= ASENTAR_ROJO;
                end if;

            when ASENTAR_ROJO =>
                if cuenta_asentamiento = ASENTAMIENTO_CICLOS-1 then
                    estado_siguiente <= MEDIR_ROJO;
                end if;

            when MEDIR_ROJO =>
                if cuenta_ventana = VENTANA_CICLOS-1 then
                    estado_siguiente <= ASENTAR_VERDE;
                end if;

            when ASENTAR_VERDE =>
                if cuenta_asentamiento = ASENTAMIENTO_CICLOS-1 then
                    estado_siguiente <= MEDIR_VERDE;
                end if;

            when MEDIR_VERDE =>
                if cuenta_ventana = VENTANA_CICLOS-1 then
                    estado_siguiente <= ASENTAR_AZUL;
                end if;

            when ASENTAR_AZUL =>
                if cuenta_asentamiento = ASENTAMIENTO_CICLOS-1 then
                    estado_siguiente <= MEDIR_AZUL;
                end if;

            when MEDIR_AZUL =>
                if cuenta_ventana = VENTANA_CICLOS-1 then
                    estado_siguiente <= CLASIFICAR;
                end if;

            when CLASIFICAR =>
                estado_siguiente <= FINALIZAR;

            when FINALIZAR =>
                estado_siguiente <= ESPERA;

        end case;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 3: logica de salidas Moore
    ------------------------------------------------------------------------
    process(estado_actual)
    begin
        -- Escala de frecuencia del 20 %.
        tcs_s0 <= '1';
        tcs_s1 <= '0';

        -- Filtro rojo por defecto.
        tcs_s2 <= '0';
        tcs_s3 <= '0';

        medicion_lista <= '0';
        ocupado        <= '1';

        case estado_actual is

            when ESPERA =>
                ocupado <= '0';

            when ASENTAR_VERDE | MEDIR_VERDE =>
                tcs_s2 <= '1';
                tcs_s3 <= '1';

            when ASENTAR_AZUL | MEDIR_AZUL =>
                tcs_s2 <= '0';
                tcs_s3 <= '1';

            when FINALIZAR =>
                ocupado        <= '0';
                medicion_lista <= '1';

            when others =>
                null;

        end case;
    end process;

    color           <= color_reg;
    medicion_valida <= valida_reg;
    valor_rojo      <= std_logic_vector(to_unsigned(rojo_reg, 16));
    valor_verde     <= std_logic_vector(to_unsigned(verde_reg, 16));
    valor_azul      <= std_logic_vector(to_unsigned(azul_reg, 16));

end architecture fsm_tres_procesos;
```

## Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity Prueba_HCSR04 is
    port (
        CLOCK_50   : in  std_logic;
        BUTTON     : in  std_logic_vector(2 downto 0);
        HCSR04_ECHO: in  std_logic;
        HCSR04_TRIG: out std_logic;
        LEDG       : out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0)
    );
end entity Prueba_HCSR04;

architecture estructural of Prueba_HCSR04 is

    signal reinicio       : std_logic;
    signal boton_inicio   : std_logic;
    signal pulso_inicio   : std_logic;

    signal distancia      : std_logic_vector(7 downto 0);
    signal distancia_10   : std_logic_vector(9 downto 0);
    signal tamano         : std_logic;
    signal lista          : std_logic;
    signal valida         : std_logic;
    signal ocupado        : std_logic;
    signal alternador_fin : std_logic := '0';

    signal centenas, decenas, unidades : std_logic_vector(3 downto 0);
    signal segmentos_tamano : std_logic_vector(6 downto 0);
    signal digito_tamano : std_logic_vector(3 downto 0);

begin

    boton_inicio <= not BUTTON(0);
    distancia_10 <= "00" & distancia;
    digito_tamano <= "000" & tamano;

    U_REINICIO : entity work.reinicio_seguro
        port map (
            reloj => CLOCK_50,
            reinicio_bajo => BUTTON(1),
            reinicio_salida => reinicio
        );

    U_BOTON : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => 250000
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            boton_entrada => boton_inicio,
            pulso_salida => pulso_inicio,
            estado_salida => open
        );

    U_HCSR04 : entity work.lector_hcsr04
        generic map (
            FRECUENCIA_RELOJ_HZ => 50000000,
            UMBRAL_GRANDE_CM => 25,
            UMBRAL_PEQUENA_CM => 30,
            TIEMPO_MAXIMO_US => 40000
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            iniciar => pulso_inicio,
            echo_entrada => HCSR04_ECHO,
            trigger_salida => HCSR04_TRIG,
            distancia_cm => distancia,
            tamano => tamano,
            medicion_lista => lista,
            medicion_valida => valida,
            ocupado => ocupado
        );

    process(CLOCK_50, reinicio)
    begin
        if reinicio = '1' then
            alternador_fin <= '0';
        elsif rising_edge(CLOCK_50) then
            if lista = '1' then
                alternador_fin <= not alternador_fin;
            end if;
        end if;
    end process;

    U_DECIMAL : entity work.conversor_binario_decimal
        port map (
            numero_binario => distancia_10,
            centenas => centenas,
            decenas => decenas,
            unidades => unidades
        );

    U_HEX0 : entity work.decodificador_7segmentos
        port map (numero => unidades, segmentos => HEX0);

    U_HEX1 : entity work.decodificador_7segmentos
        port map (numero => decenas, segmentos => HEX1);

    U_HEX2 : entity work.decodificador_7segmentos
        port map (numero => centenas, segmentos => HEX2);

    U_HEX3 : entity work.decodificador_7segmentos
        port map (numero => digito_tamano, segmentos => segmentos_tamano);

    -- Un dato no valido no debe parecer una pieza pequena.
    HEX3 <= segmentos_tamano when valida = '1' else "1111111";

    LEDG(0) <= valida;
    LEDG(1) <= tamano;
    LEDG(2) <= ocupado;
    LEDG(3) <= alternador_fin;
    LEDG(9 downto 4) <= (others => '0');

end architecture estructural;
```

## Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity Prueba_TCS3200 is
    port (
        CLOCK_50 : in  std_logic;
        BUTTON   : in  std_logic_vector(2 downto 0);
        SW       : in  std_logic_vector(9 downto 0);

        TCS_OUT : in  std_logic;
        TCS_S0  : out std_logic;
        TCS_S1  : out std_logic;
        TCS_S2  : out std_logic;
        TCS_S3  : out std_logic;

        LEDG : out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2, HEX3 : out std_logic_vector(6 downto 0)
    );
end entity Prueba_TCS3200;

architecture estructural of Prueba_TCS3200 is

    signal reinicio       : std_logic;
    signal boton_inicio   : std_logic;
    signal pulso_inicio   : std_logic;

    signal color          : std_logic_vector(1 downto 0);
    signal rojo           : std_logic_vector(15 downto 0);
    signal verde          : std_logic_vector(15 downto 0);
    signal azul           : std_logic_vector(15 downto 0);
    signal valor_mostrado : std_logic_vector(15 downto 0);

    signal seleccion_1, seleccion_2 : std_logic_vector(1 downto 0) := "00";
    signal lista          : std_logic;
    signal valida         : std_logic;
    signal ocupado        : std_logic;
    signal alternador_fin : std_logic := '0';

begin

    boton_inicio <= not BUTTON(0);

    with seleccion_2 select
        valor_mostrado <=
            rojo  when "00",
            verde when "01",
            azul  when "10",
            (others => '0') when others;

    U_REINICIO : entity work.reinicio_seguro
        port map (
            reloj => CLOCK_50,
            reinicio_bajo => BUTTON(1),
            reinicio_salida => reinicio
        );

    U_BOTON : entity work.filtro_boton
        generic map (
            CICLOS_ESTABLES => 250000
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            boton_entrada => boton_inicio,
            pulso_salida => pulso_inicio,
            estado_salida => open
        );

    U_TCS3200 : entity work.lector_tcs3200
        generic map (
            VENTANA_CICLOS => 1500000,       -- 30 ms a 50 MHz
            ASENTAMIENTO_CICLOS => 25000,    -- 0.5 ms a 50 MHz
            CLASIFICACION_HABILITADA => true,
            BASE_NEGRA_ROJO => 26,
            BASE_NEGRA_VERDE => 26,
            BASE_NEGRA_AZUL => 34,
            GANANCIA_ROJO_Q5 => 85,
            GANANCIA_VERDE_Q5 => 109,
            GANANCIA_AZUL_Q5 => 115,
            SENAL_MINIMA => 10
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            iniciar => pulso_inicio,
            tcs_out => TCS_OUT,
            tcs_s0 => TCS_S0,
            tcs_s1 => TCS_S1,
            tcs_s2 => TCS_S2,
            tcs_s3 => TCS_S3,
            color => color,
            valor_rojo => rojo,
            valor_verde => verde,
            valor_azul => azul,
            medicion_lista => lista,
            medicion_valida => valida,
            ocupado => ocupado
        );

    process(CLOCK_50, reinicio)
    begin
        if reinicio = '1' then
            alternador_fin <= '0';
            seleccion_1 <= "00"; seleccion_2 <= "00";
        elsif rising_edge(CLOCK_50) then
            seleccion_1 <= SW(1 downto 0); seleccion_2 <= seleccion_1;
            if lista = '1' then
                alternador_fin <= not alternador_fin;
            end if;
        end if;
    end process;

    U_HEX0 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(3 downto 0), segmentos => HEX0);

    U_HEX1 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(7 downto 4), segmentos => HEX1);

    U_HEX2 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(11 downto 8), segmentos => HEX2);

    U_HEX3 : entity work.decodificador_7segmentos
        port map (numero => valor_mostrado(15 downto 12), segmentos => HEX3);

    LEDG(1 downto 0) <= color;
    LEDG(2) <= valida;
    LEDG(3) <= ocupado;
    LEDG(4) <= alternador_fin;
    LEDG(9 downto 5) <= (others => '0');

end architecture estructural;
```

## Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Prueba_V183 is
    generic (ACTIVO_BAJO : boolean := true);
    port (
        CLOCK_50 : in  std_logic;
        BUTTON   : in  std_logic_vector(2 downto 0);
        V183_OUT : in  std_logic;
        LEDG     : out std_logic_vector(9 downto 0)
    );
end entity Prueba_V183;

architecture estructural of Prueba_V183 is

    signal reinicio          : std_logic;
    signal presencia_activa  : std_logic;
    signal pulso_pieza       : std_logic;
    signal alternador_evento : std_logic := '0';
    signal cuenta_eventos : unsigned(6 downto 0) := (others => '0');
    signal nivel_1, nivel_2 : std_logic := '0';

begin

    U_REINICIO : entity work.reinicio_seguro
        port map (
            reloj => CLOCK_50,
            reinicio_bajo => BUTTON(1),
            reinicio_salida => reinicio
        );

    U_SENSOR : entity work.entrada_presencia_v183
        generic map (
            CICLOS_ESTABLES => 250000,
            ACTIVO_BAJO => ACTIVO_BAJO
        )
        port map (
            reloj => CLOCK_50,
            reinicio => reinicio,
            sensor_entrada => V183_OUT,
            presencia_activa => presencia_activa,
            pulso_pieza => pulso_pieza
        );

    process(CLOCK_50, reinicio)
    begin
        if reinicio = '1' then
            alternador_evento <= '0';
            cuenta_eventos <= (others => '0');
            nivel_1 <= '0'; nivel_2 <= '0';
        elsif rising_edge(CLOCK_50) then
            nivel_1 <= V183_OUT; nivel_2 <= nivel_1;
            if pulso_pieza = '1' then
                alternador_evento <= not alternador_evento;
                if cuenta_eventos < 127 then cuenta_eventos <= cuenta_eventos + 1; end if;
            end if;
        end if;
    end process;

    LEDG(0) <= presencia_activa;
    LEDG(1) <= alternador_evento;
    LEDG(2) <= nivel_2; -- Nivel electrico de OUT, sin invertir.
    LEDG(9 downto 3) <= std_logic_vector(cuenta_eventos);

end architecture estructural;
```

