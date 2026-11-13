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
