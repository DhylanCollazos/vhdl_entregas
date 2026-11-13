# Todos los codigos de los proyectos individuales

Base: octava version. Cada bloque es un archivo completo; la ruta es relativa a Pruebas_Sensores_DE0_v8. Incluye dependencias copiadas, lectores, tops, configuraciones y testbench.

## comunes/conversor_binario_decimal.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conversor_binario_decimal is
    port (
        numero_binario : in std_logic_vector(9 downto 0);

        centenas : out std_logic_vector(3 downto 0);
        decenas  : out std_logic_vector(3 downto 0);
        unidades : out std_logic_vector(3 downto 0)
    );
end entity conversor_binario_decimal;

architecture comportamiento of conversor_binario_decimal is
begin

    process(numero_binario)

        variable numero : integer range 0 to 1023;
        variable valor_centenas : integer range 0 to 9;
        variable valor_decenas : integer range 0 to 9;
        variable valor_unidades : integer range 0 to 9;

    begin

        numero := to_integer(unsigned(numero_binario));

        if numero > 999 then
            numero := 999;
        end if;

        valor_centenas := numero / 100;
        valor_decenas := (numero / 10) mod 10;
        valor_unidades := numero mod 10;

        centenas <= std_logic_vector(
            to_unsigned(valor_centenas, 4)
        );

        decenas <= std_logic_vector(
            to_unsigned(valor_decenas, 4)
        );

        unidades <= std_logic_vector(
            to_unsigned(valor_unidades, 4)
        );

    end process;

end architecture comportamiento;
```

## comunes/decodificador_7segmentos.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity decodificador_7segmentos is
    port (
        numero : in std_logic_vector(3 downto 0);
        segmentos : out std_logic_vector(6 downto 0)
    );
end entity decodificador_7segmentos;

architecture combinacional of decodificador_7segmentos is
begin

    process(numero)
    begin
        case numero is
            when "0000" => segmentos <= "1000000"; -- 0
            when "0001" => segmentos <= "1111001"; -- 1
            when "0010" => segmentos <= "0100100"; -- 2
            when "0011" => segmentos <= "0110000"; -- 3
            when "0100" => segmentos <= "0011001"; -- 4
            when "0101" => segmentos <= "0010010"; -- 5
            when "0110" => segmentos <= "0000010"; -- 6
            when "0111" => segmentos <= "1111000"; -- 7
            when "1000" => segmentos <= "0000000"; -- 8
            when "1001" => segmentos <= "0010000"; -- 9
            when "1010" => segmentos <= "0001000"; -- A
            when "1011" => segmentos <= "0000011"; -- b
            when "1100" => segmentos <= "1000110"; -- C
            when "1101" => segmentos <= "0100001"; -- d
            when "1110" => segmentos <= "0000110"; -- E
            when "1111" => segmentos <= "0001110"; -- F

            when others =>
                segmentos <= "1111111"; -- Apagado
        end case;
    end process;

end architecture combinacional;
```

## comunes/filtro_boton.vhd

```vhdl
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
```

## comunes/reinicio_seguro.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity reinicio_seguro is
    port (
        reloj           : in std_logic;
        reinicio_bajo   : in std_logic;
        reinicio_salida : out std_logic
    );
end entity reinicio_seguro;

architecture comportamiento of reinicio_seguro is

    signal paso1 : std_logic := '1';
    signal paso2 : std_logic := '1';

begin

    process(reloj, reinicio_bajo)
    begin

        -- El pulsador activa el reinicio cuando vale cero
        if reinicio_bajo = '0' then

            paso1 <= '1';
            paso2 <= '1';

        -- La liberacion del reinicio sigue el reloj
        elsif rising_edge(reloj) then

            paso1 <= '0';
            paso2 <= paso1;

        end if;

    end process;

    -- La segunda etapa entrega el reinicio al resto del circuito
    reinicio_salida <= paso2;

end architecture comportamiento;
```

## comunes/reloj.sdc

```tcl
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
derive_clock_uncertainty
```

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

## Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.qpf

```text
QUARTUS_VERSION = "13.1"
PROJECT_REVISION = "Prueba_HCSR04"
```

## Hardware_Sensores/Pruebas_Fisicas/HCSR04/Prueba_HCSR04.qsf

```tcl
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name SDC_FILE ../../../comunes/reloj.sdc

set_location_assignment PIN_G21 -to CLOCK_50

set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]

set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_location_assignment PIN_E11 -to HEX0[0]
set_location_assignment PIN_F11 -to HEX0[1]
set_location_assignment PIN_H12 -to HEX0[2]
set_location_assignment PIN_H13 -to HEX0[3]
set_location_assignment PIN_G12 -to HEX0[4]
set_location_assignment PIN_F12 -to HEX0[5]
set_location_assignment PIN_F13 -to HEX0[6]
set_location_assignment PIN_A13 -to HEX1[0]
set_location_assignment PIN_B13 -to HEX1[1]
set_location_assignment PIN_C13 -to HEX1[2]
set_location_assignment PIN_A14 -to HEX1[3]
set_location_assignment PIN_B14 -to HEX1[4]
set_location_assignment PIN_E14 -to HEX1[5]
set_location_assignment PIN_A15 -to HEX1[6]
set_location_assignment PIN_D15 -to HEX2[0]
set_location_assignment PIN_A16 -to HEX2[1]
set_location_assignment PIN_B16 -to HEX2[2]
set_location_assignment PIN_E15 -to HEX2[3]
set_location_assignment PIN_A17 -to HEX2[4]
set_location_assignment PIN_B17 -to HEX2[5]
set_location_assignment PIN_F14 -to HEX2[6]
set_location_assignment PIN_B18 -to HEX3[0]
set_location_assignment PIN_F15 -to HEX3[1]
set_location_assignment PIN_A19 -to HEX3[2]
set_location_assignment PIN_B19 -to HEX3[3]
set_location_assignment PIN_C19 -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_location_assignment PIN_G15 -to HEX3[6]
set_global_assignment -name TOP_LEVEL_ENTITY Prueba_HCSR04
set_global_assignment -name VHDL_FILE ../../../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/filtro_boton.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/conversor_binario_decimal.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/decodificador_7segmentos.vhd
set_global_assignment -name VHDL_FILE ../../lector_hcsr04.vhd
set_global_assignment -name VHDL_FILE Prueba_HCSR04.vhd
set_location_assignment PIN_AA16 -to HCSR04_TRIG
set_location_assignment PIN_AA15 -to HCSR04_ECHO

set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HCSR04_TRIG
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HCSR04_ECHO
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

## Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.qpf

```text
QUARTUS_VERSION = "13.1"
PROJECT_REVISION = "Prueba_TCS3200"
```

## Hardware_Sensores/Pruebas_Fisicas/TCS3200/Prueba_TCS3200.qsf

```tcl
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name SDC_FILE ../../../comunes/reloj.sdc

set_location_assignment PIN_G21 -to CLOCK_50

set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]

set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_location_assignment PIN_E11 -to HEX0[0]
set_location_assignment PIN_F11 -to HEX0[1]
set_location_assignment PIN_H12 -to HEX0[2]
set_location_assignment PIN_H13 -to HEX0[3]
set_location_assignment PIN_G12 -to HEX0[4]
set_location_assignment PIN_F12 -to HEX0[5]
set_location_assignment PIN_F13 -to HEX0[6]
set_location_assignment PIN_A13 -to HEX1[0]
set_location_assignment PIN_B13 -to HEX1[1]
set_location_assignment PIN_C13 -to HEX1[2]
set_location_assignment PIN_A14 -to HEX1[3]
set_location_assignment PIN_B14 -to HEX1[4]
set_location_assignment PIN_E14 -to HEX1[5]
set_location_assignment PIN_A15 -to HEX1[6]
set_location_assignment PIN_D15 -to HEX2[0]
set_location_assignment PIN_A16 -to HEX2[1]
set_location_assignment PIN_B16 -to HEX2[2]
set_location_assignment PIN_E15 -to HEX2[3]
set_location_assignment PIN_A17 -to HEX2[4]
set_location_assignment PIN_B17 -to HEX2[5]
set_location_assignment PIN_F14 -to HEX2[6]
set_location_assignment PIN_B18 -to HEX3[0]
set_location_assignment PIN_F15 -to HEX3[1]
set_location_assignment PIN_A19 -to HEX3[2]
set_location_assignment PIN_B19 -to HEX3[3]
set_location_assignment PIN_C19 -to HEX3[4]
set_location_assignment PIN_D19 -to HEX3[5]
set_location_assignment PIN_G15 -to HEX3[6]
set_global_assignment -name TOP_LEVEL_ENTITY Prueba_TCS3200
set_location_assignment PIN_J6 -to SW[0]
set_location_assignment PIN_H5 -to SW[1]
set_location_assignment PIN_H6 -to SW[2]
set_location_assignment PIN_G4 -to SW[3]
set_location_assignment PIN_G5 -to SW[4]
set_location_assignment PIN_J7 -to SW[5]
set_location_assignment PIN_H7 -to SW[6]
set_location_assignment PIN_E3 -to SW[7]
set_location_assignment PIN_E4 -to SW[8]
set_location_assignment PIN_D2 -to SW[9]
set_global_assignment -name VHDL_FILE ../../../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/filtro_boton.vhd
set_global_assignment -name VHDL_FILE ../../../comunes/decodificador_7segmentos.vhd
set_global_assignment -name VHDL_FILE ../../lector_tcs3200.vhd
set_global_assignment -name VHDL_FILE Prueba_TCS3200.vhd
set_location_assignment PIN_AB15 -to TCS_OUT
set_location_assignment PIN_AA14 -to TCS_S2
set_location_assignment PIN_AB14 -to TCS_S3
set_location_assignment PIN_AB13 -to TCS_S0
set_location_assignment PIN_AA13 -to TCS_S1

set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX0[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX1[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX2[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HEX3[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_OUT
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S2
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S3
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S0
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to TCS_S1
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

## Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.qpf

```text
PROJECT_REVISION = "Prueba_V183"
PROJECT_REVISION = "Prueba_V183_Activo_Alto"
```

## Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183.qsf

```tcl
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name SDC_FILE ../../../comunes/reloj.sdc

set_location_assignment PIN_G21 -to CLOCK_50

set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]

set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_global_assignment -name TOP_LEVEL_ENTITY Prueba_V183
set_global_assignment -name VHDL_FILE ../../../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../../entrada_presencia_v183.vhd
set_global_assignment -name VHDL_FILE Prueba_V183.vhd
set_location_assignment PIN_AB16 -to V183_OUT

set_parameter -name ACTIVO_BAJO true

set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to V183_OUT
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

## Hardware_Sensores/Pruebas_Fisicas/V183/Prueba_V183_Activo_Alto.qsf

```tcl
set_global_assignment -name FAMILY "Cyclone III"
set_global_assignment -name DEVICE EP3C16F484C6
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name SDC_FILE ../../../comunes/reloj.sdc

set_location_assignment PIN_G21 -to CLOCK_50

set_location_assignment PIN_H2 -to BUTTON[0]
set_location_assignment PIN_G3 -to BUTTON[1]
set_location_assignment PIN_F1 -to BUTTON[2]

set_location_assignment PIN_J1 -to LEDG[0]
set_location_assignment PIN_J2 -to LEDG[1]
set_location_assignment PIN_J3 -to LEDG[2]
set_location_assignment PIN_H1 -to LEDG[3]
set_location_assignment PIN_F2 -to LEDG[4]
set_location_assignment PIN_E1 -to LEDG[5]
set_location_assignment PIN_C1 -to LEDG[6]
set_location_assignment PIN_C2 -to LEDG[7]
set_location_assignment PIN_B2 -to LEDG[8]
set_location_assignment PIN_B1 -to LEDG[9]
set_global_assignment -name TOP_LEVEL_ENTITY Prueba_V183
set_global_assignment -name VHDL_FILE ../../../comunes/reinicio_seguro.vhd
set_global_assignment -name VHDL_FILE ../../entrada_presencia_v183.vhd
set_global_assignment -name VHDL_FILE Prueba_V183.vhd
set_location_assignment PIN_AB16 -to V183_OUT

set_parameter -name ACTIVO_BAJO false

set_global_assignment -name VHDL_INPUT_VERSION VHDL_1993

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BUTTON[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[8]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LEDG[9]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to V183_OUT
```

## Pruebas_ModelSim/entrada_presencia_v183_TB.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity entrada_presencia_v183_TB is
    generic (BAJO : boolean := true; FILTRO : positive := 5);
end entity;

architecture prueba of entrada_presencia_v183_TB is
    signal reloj : std_logic := '0';
    signal reinicio : std_logic := '1';
    signal pieza : std_logic := '1';
    signal entrada, presencia, pulso : std_logic;
    signal eventos : natural := 0;
    signal terminar : boolean := false;
begin
    reloj <= not reloj after 10 ns when not terminar else '0';
    entrada <= not pieza when BAJO else pieza;
    DUT: entity work.entrada_presencia_v183
        generic map (CICLOS_ESTABLES => FILTRO, ACTIVO_BAJO => BAJO)
        port map (reloj, reinicio, entrada, presencia, pulso);

    process(reloj, reinicio)
        variable anterior : std_logic := '0';
    begin
        if reinicio = '1' then
            eventos <= 0; anterior := '0';
        elsif rising_edge(reloj) then
            assert not (pulso = '1' and anterior = '1')
                report "El evento dura mas de un ciclo" severity failure;
            if pulso = '1' then eventos <= eventos + 1; end if;
            anterior := pulso;
        end if;
    end process;

    process
        procedure ciclos(n : positive) is
        begin
            for i in 1 to n loop wait until falling_edge(reloj); end loop;
        end procedure;
    begin
        ciclos(4); reinicio <= '0'; ciclos(30);
        assert eventos = 0 report "Pieza al arrancar genero un evento falso" severity failure;
        pieza <= '0'; ciclos(30);
        assert presencia = '0' severity failure;
        if FILTRO > 1 then
            pieza <= '1'; ciclos(1); pieza <= '0'; ciclos(30);
            assert eventos = 0 report "No filtro una perturbacion corta" severity failure;
        end if;
        pieza <= '1'; ciclos(30);
        assert presencia = '1' and eventos = 1 report "Primera pieza incorrecta" severity failure;
        ciclos(80);
        assert eventos = 1 report "Repite eventos con la pieza sostenida" severity failure;
        if FILTRO > 1 then
            pieza <= '0'; ciclos(1); pieza <= '1'; ciclos(30);
            assert eventos = 1 and presencia = '1' report "Retiro breve rearma el sensor" severity failure;
        end if;
        pieza <= '0'; ciclos(30); pieza <= '1'; ciclos(30);
        assert eventos = 2 report "No reconocio la segunda pieza" severity failure;
        reinicio <= '1'; ciclos(4); reinicio <= '0'; ciclos(30);
        assert eventos = 0 report "Reset con pieza produjo evento" severity failure;
        pieza <= '0'; ciclos(30); pieza <= '1'; ciclos(30);
        assert eventos = 1 report "No rearmo despues del reset y retiro" severity failure;
        report "OK: V183, polaridad, arranque ocupado, rebotes, retencion y reset" severity note;
        terminar <= true; wait;
    end process;
end architecture;
```

## Pruebas_ModelSim/lector_hcsr04_TB.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lector_hcsr04_TB is end entity;
architecture prueba of lector_hcsr04_TB is
    signal reloj : std_logic := '0';
    signal reinicio : std_logic := '1';
    signal iniciar, echo, trig, tamano, lista, valida, ocupado : std_logic := '0';
    signal distancia : std_logic_vector(7 downto 0);
    signal terminar : boolean := false;
    signal disparos, resultados : natural := 0;
begin
    -- 1 MHz solo para acelerar simulacion; la placa usa 50 MHz.
    reloj <= not reloj after 500 ns when not terminar else '0';
    DUT: entity work.lector_hcsr04
        generic map (FRECUENCIA_RELOJ_HZ => 1000000)
        port map (reloj, reinicio, iniciar, echo, trig, distancia, tamano, lista, valida, ocupado);
    process(trig)
    begin
        if rising_edge(trig) then disparos <= disparos + 1; end if;
    end process;
    process(reloj)
        variable anterior : std_logic := '0';
    begin
        if rising_edge(reloj) then
            assert not (lista = '1' and anterior = '1') report "Lista dura mas de un ciclo" severity failure;
            if lista = '1' then resultados <= resultados + 1; end if;
            anterior := lista;
        end if;
    end process;
    process
        procedure ciclos(n : positive) is
        begin
            for i in 1 to n loop wait until falling_edge(reloj); end loop;
        end procedure;
        procedure orden is
        begin
            iniciar <= '1'; ciclos(1); iniciar <= '0';
        end procedure;
        procedure medir(ancho_us, esperado_cm : natural; valido, grande : std_logic) is
            variable t : time;
            variable prev : natural;
        begin
            ciclos(62000);
            iniciar <= '1';
            wait until trig = '1' for 20 us;
            assert trig = '1' report "No genera TRIG" severity failure;
            t := now;
            wait until trig = '0' for 20 us;
            assert now-t = 10 us report "TRIG no dura 10 us" severity failure;
            iniciar <= '0';
            wait until falling_edge(reloj); ciclos(20);
            if ancho_us > 0 then
                echo <= '1'; wait for ancho_us*1 us; echo <= '0';
            end if;
            wait until lista = '1' for 81000 us;
            assert lista = '1' report "Medicion nunca termina" severity failure;
            wait for 1 ns;
            assert to_integer(unsigned(distancia)) = esperado_cm report "Distancia incorrecta" severity failure;
            assert valida = valido report "Validez incorrecta en limite de distancia" severity failure;
            if valido = '1' then assert tamano = grande report "Tamano incorrecto" severity failure; end if;
            ciclos(3);
            prev := disparos;
            orden; ciclos(100);
            assert disparos = prev report "Acepto disparo antes de 61 ms" severity failure;
        end procedure;
        variable prev : natural;
    begin
        ciclos(4); reinicio <= '0'; ciclos(4);
        medir(23*58,23,'1','1'); medir(25*58,25,'1','1');
        medir(1479,26,'0','0'); -- 25.5 cm: no redondear hacia una clase valida.
        medir(26*58,26,'0','0'); medir(27*58,27,'0','0'); medir(29*58,29,'0','0');
        medir(30*58,30,'1','0'); medir(32*58,32,'1','0');
        medir(2*58,2,'1','1'); medir(58,1,'0','0');
        medir(256*58,255,'0','0'); medir(0,0,'0','0');
        ciclos(62000); echo <= '1'; ciclos(5); prev := disparos;
        iniciar <= '1';
        wait until lista = '1' for 20 us;
        assert lista = '1' and valida = '0' report "No detecto ECHO alto inicial" severity failure;
        ciclos(70000);
        assert disparos = prev report "Repitio la orden sostenida" severity failure;
        iniciar <= '0'; echo <= '0'; ciclos(62000);
        orden;
        wait until trig = '0' for 30 us; ciclos(20); echo <= '1';
        wait until lista = '1' for 41000 us;
        assert lista = '1' and valida = '0' report "Falta timeout de ECHO sostenido" severity failure;
        echo <= '0'; ciclos(4);
        reinicio <= '1'; ciclos(4); reinicio <= '0'; ciclos(4);
        assert ocupado = '0' and valida = '0' and trig = '0' severity failure;
        report "OK: HCSR04, limites, TRIG, intervalo, orden sostenida y timeouts" severity note;
        terminar <= true; wait;
    end process;
end architecture;
```

## Pruebas_ModelSim/lector_tcs3200_TB.vhd

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity lector_tcs3200_TB is end entity;
architecture prueba of lector_tcs3200_TB is
    signal reloj : std_logic := '0';
    signal reinicio : std_logic := '1';
    signal iniciar, entrada, s0, s1, s2, s3, lista, valida, ocupado : std_logic := '0';
    signal color, color_prueba : std_logic_vector(1 downto 0);
    signal rojo, verde, azul : std_logic_vector(15 downto 0);
    signal valida_prueba : std_logic;
    signal caso : natural range 0 to 4 := 0;
    signal terminar : boolean := false;
begin
    reloj <= not reloj after 10 ns when not terminar else '0';
    DUT: entity work.lector_tcs3200
        generic map (VENTANA_CICLOS => 100, ASENTAMIENTO_CICLOS => 10)
        port map (reloj,reinicio,iniciar,entrada,s0,s1,s2,s3,color,rojo,verde,azul,lista,valida,ocupado);
    -- Umbrales SINTETICOS solo para probar el algoritmo; NO son calibracion fisica.
    DUT_ALGORITMO: entity work.lector_tcs3200
        generic map (VENTANA_CICLOS => 100, ASENTAMIENTO_CICLOS => 10,
                     CLASIFICACION_HABILITADA => true,
                     BASE_NEGRA_ROJO => 0, BASE_NEGRA_VERDE => 0, BASE_NEGRA_AZUL => 0,
                     GANANCIA_ROJO_Q5 => 32, GANANCIA_VERDE_Q5 => 32, GANANCIA_AZUL_Q5 => 32,
                     SENAL_MINIMA => 3)
        port map (reloj,reinicio,iniciar,entrada,open,open,open,open,color_prueba,
                  open,open,open,open,valida_prueba,open);
    process(reloj)
        variable fase : natural := 0;
        variable periodo : positive := 10;
        variable anterior : std_logic_vector(1 downto 0) := "00";
        variable filtro : std_logic_vector(1 downto 0);
    begin
        if falling_edge(reloj) then
            filtro := s2 & s3;
            periodo := 20;
            if filtro = "01" then periodo := 25; end if;
            if (caso=0 and filtro="00") or (caso=1 and filtro="11") or
               (caso=2 and filtro="01") or caso=3 then periodo := 10; end if;
            if filtro /= anterior or fase >= periodo-1 then fase := 0;
            else fase := fase+1; end if;
            anterior := filtro;
            if caso=4 then entrada <= '0';
            elsif fase < periodo/2 then entrada <= '1'; else entrada <= '0'; end if;
        end if;
    end process;
    process
        procedure ciclos(n : positive) is
        begin
            for i in 1 to n loop wait until rising_edge(reloj); wait for 1 ns; end loop;
        end procedure;
        procedure muestra(c : natural; r,g,b : natural; codigo : std_logic_vector(1 downto 0)) is
        begin
            caso <= c; ciclos(30); iniciar <= '1';
            wait until ocupado = '1' for 1 us;
            assert ocupado = '1' and s2='0' and s3='0' severity failure;
            wait until s2='1' and s3='1' for 3 us;
            assert s2='1' and s3='1' report "Falta filtro verde" severity failure;
            wait until s2='0' and s3='1' for 3 us;
            assert s2='0' and s3='1' report "Falta filtro azul" severity failure;
            wait until lista='1' for 3 us; wait for 1 ns;
            assert lista='1' report "Falta pulso final TCS" severity failure;
            assert to_integer(unsigned(rojo))=r and to_integer(unsigned(verde))=g and
                   to_integer(unsigned(azul))=b report "Conteos RGB incorrectos" severity failure;
            assert color="00" and valida='0' report "Clasifica sin calibracion" severity failure;
            assert color_prueba=codigo report "Algoritmo sintetico incorrecto" severity failure;
            if codigo="00" then assert valida_prueba='0' severity failure;
            else assert valida_prueba='1' severity failure; end if;
            assert s0='1' and s1='0' report "Escala no es 20 por ciento" severity failure;
            ciclos(1); assert lista='0' report "Pulso lista demasiado largo" severity failure;
            ciclos(400); assert ocupado='0' and lista='0' report "Orden sostenida repite medicion" severity failure;
            iniciar <= '0'; ciclos(5);
        end procedure;
    begin
        ciclos(5); reinicio <= '0'; ciclos(5);
        muestra(0,10,5,4,"01"); muestra(1,5,10,4,"10");
        muestra(2,5,5,10,"11"); muestra(3,10,10,10,"00");
        muestra(4,0,0,0,"00");
        iniciar <= '1'; ciclos(40); reinicio <= '1'; ciclos(5);
        iniciar <= '0'; reinicio <= '0'; ciclos(5);
        assert ocupado='0' and lista='0' and rojo=x"0000" and verde=x"0000" and azul=x"0000"
            report "Reset durante medicion incorrecto" severity failure;
        report "OK: TCS3200, filtros RGB, conteos, calibracion, empates, reset y orden sostenida" severity note;
        terminar <= true; wait;
    end process;
end architecture;
```

## Pruebas_ModelSim/simular_sensores.do

```tcl
onerror {quit -f -code 1}
onbreak {quit -f -code 1}
# Ejecutar desde esta carpeta: do simular_sensores.do
if {![file isdirectory work]} {vlib work}
vmap work work
vcom -93 ../Hardware_Sensores/entrada_presencia_v183.vhd
vcom -93 ../Hardware_Sensores/lector_hcsr04.vhd
vcom -93 ../Hardware_Sensores/lector_tcs3200.vhd
vcom -93 entrada_presencia_v183_TB.vhd
vcom -93 lector_hcsr04_TB.vhd
vcom -93 lector_tcs3200_TB.vhd
foreach bajo {true false} {
    foreach filtro {1 5} {
        vsim work.entrada_presencia_v183_TB -gBAJO=$bajo -gFILTRO=$filtro
        run -all
        quit -sim
    }
}
vsim work.lector_hcsr04_TB
run -all
quit -sim
vsim work.lector_tcs3200_TB
run -all
quit -sim
echo "Pruebas terminadas: revisar los mensajes OK y cualquier asercion."
```

