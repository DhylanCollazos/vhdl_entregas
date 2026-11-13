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
