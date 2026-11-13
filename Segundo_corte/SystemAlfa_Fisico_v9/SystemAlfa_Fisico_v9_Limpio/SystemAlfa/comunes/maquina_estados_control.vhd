library ieee;
use ieee.std_logic_1164.all;

-- Maquina de estados principal.
--
-- Modelo clasico de tres procesos:
--
-- 1. Registro del estado
-- 2. Logica de transicion
-- 3. Logica de salidas

entity maquina_estados_control is
    port (
        reloj,
        reinicio :
            in std_logic;

        marcha :
            in std_logic;

        nueva_pieza :
            in std_logic;

        pieza_valida :
            in std_logic;

        registrar_evento :
            out std_logic;

        contar_pieza :
            out std_logic;

        alarma_estado :
            out std_logic;

        ocupado :
            out std_logic;

        estado_codigo :
            out std_logic_vector(2 downto 0)
    );
end entity maquina_estados_control;

architecture fsm_tres_procesos
of maquina_estados_control is

    ------------------------------------------------------------
    -- ESTADOS
    ------------------------------------------------------------

    type tipo_estado is (

        ESPERA,
        DETECCION,
        LECTURA_COLOR,
        CLASIFICACION,
        REGISTRO,
        ERROR_ESTADO

    );

    signal estado_actual :
        tipo_estado := ESPERA;

    signal estado_siguiente :
        tipo_estado := ESPERA;

begin

    -- PROCESO 1
    -- REGISTRO DE ESTADO

    process(reloj, reinicio)
    begin

        if reinicio = '1' then

            estado_actual <= ESPERA;

        elsif rising_edge(reloj) then

            estado_actual <=
                estado_siguiente;

        end if;

    end process;

    -- PROCESO 2
    -- LOGICA DE TRANSICION

    process(
        estado_actual,
        marcha,
        nueva_pieza,
        pieza_valida
    )
    begin

        estado_siguiente <=
            estado_actual;

        case estado_actual is

            ----------------------------------------------------
            -- ESPERA
            ----------------------------------------------------

            when ESPERA =>

                if
                    marcha = '1'
                    and
                    nueva_pieza = '1'
                then

                    estado_siguiente <=
                        DETECCION;

                end if;

            ----------------------------------------------------
            -- DETECCION
            ----------------------------------------------------

            when DETECCION =>

                estado_siguiente <=
                    LECTURA_COLOR;

            ----------------------------------------------------
            -- LECTURA COLOR Y TAMANO
            ----------------------------------------------------

            when LECTURA_COLOR =>

                estado_siguiente <=
                    CLASIFICACION;

            ----------------------------------------------------
            -- CLASIFICACION
            ----------------------------------------------------

            when CLASIFICACION =>

                if pieza_valida = '1' then

                    estado_siguiente <=
                        REGISTRO;

                else

                    estado_siguiente <=
                        ERROR_ESTADO;

                end if;

            ----------------------------------------------------
            -- REGISTRO
            ----------------------------------------------------

            when REGISTRO =>

                estado_siguiente <=
                    ESPERA;

            ----------------------------------------------------
            -- ERROR
            ----------------------------------------------------

            when ERROR_ESTADO =>

                -- Permanece aqui hasta reinicio.
                estado_siguiente <=
                    ERROR_ESTADO;

        end case;

    end process;

    -- PROCESO 3
    -- LOGICA DE SALIDAS

    process(
        estado_actual,
        pieza_valida
    )
    begin

        --------------------------------------------------------
        -- VALORES POR DEFECTO
        --------------------------------------------------------

        registrar_evento <= '0';
        contar_pieza      <= '0';
        alarma_estado     <= '0';

        ocupado <= '1';

        estado_codigo <= "000";

        case estado_actual is

            ----------------------------------------------------
            -- ESPERA
            ----------------------------------------------------

            when ESPERA =>

                ocupado <= '0';

                estado_codigo <=
                    "000";

            ----------------------------------------------------
            -- DETECCION
            ----------------------------------------------------

            when DETECCION =>

                estado_codigo <=
                    "001";

            ----------------------------------------------------
            -- LECTURA
            ----------------------------------------------------

            when LECTURA_COLOR =>

                estado_codigo <=
                    "010";

            ----------------------------------------------------
            -- CLASIFICACION
            ----------------------------------------------------

            when CLASIFICACION =>

                estado_codigo <=
                    "011";

                -- Una pieza invalida se registra,
                -- pero NO se suma como valida.

                if pieza_valida = '0' then

                    registrar_evento <= '1';

                    alarma_estado <= '1';

                end if;

            ----------------------------------------------------
            -- REGISTRO VALIDO
            ----------------------------------------------------

            when REGISTRO =>

                estado_codigo <=
                    "100";

                registrar_evento <=
                    '1';

                contar_pieza <=
                    '1';

            ----------------------------------------------------
            -- ERROR
            ----------------------------------------------------

            when ERROR_ESTADO =>

                estado_codigo <=
                    "101";

                alarma_estado <=
                    '1';

        end case;

    end process;

end architecture fsm_tres_procesos;