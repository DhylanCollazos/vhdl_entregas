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
        INTERVALO_MINIMO_US : positive := 61000;
        USAR_VENTANAS_MM : boolean := false;
        GRANDE_MIN_MM : positive := 20;
        GRANDE_MAX_MM : positive := 28;
        PEQUENA_MIN_MM : positive := 32;
        PEQUENA_MAX_MM : positive := 48
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

                    if USAR_VENTANAS_MM then
                        valida_reg <= '0'; tamano_reg <= '0';
                        if echo_capturado >= (GRANDE_MIN_MM*CICLOS_POR_CM+9)/10 and
                           echo_capturado <= (GRANDE_MAX_MM*CICLOS_POR_CM)/10 then
                            valida_reg <= '1'; tamano_reg <= '1';
                        elsif echo_capturado >= (PEQUENA_MIN_MM*CICLOS_POR_CM+9)/10 and
                              echo_capturado <= (PEQUENA_MAX_MM*CICLOS_POR_CM)/10 then
                            valida_reg <= '1';
                        end if;
                    elsif echo_capturado >= 2*CICLOS_POR_CM and
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
