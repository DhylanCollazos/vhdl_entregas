library ieee;
use ieee.std_logic_1164.all;

-- Laboratorio 7, parte IV.
-- Codificador Morse con tres procesos.
--
-- KEY(0): reset asincrono activo en cero.
-- KEY(1): inicio activo en cero.
-- SW(2 downto 0): seleccion de la letra.
-- LEDR(0): salida Morse.
--
-- Los interruptores deben estar estables antes de iniciar.

entity morse_fsm is
    generic (
        -- 50 MHz * 0.5 segundos = 25 000 000 ciclos.
        -- El testbench reemplaza este valor para acelerar la simulacion.
        G_TICKS_05S : positive := 25_000_000
    );

    port (
        CLOCK_50 : in  std_logic;
        SW       : in  std_logic_vector(2 downto 0);
        KEY      : in  std_logic_vector(1 downto 0);
        LEDR     : out std_logic_vector(0 downto 0)
    );
end entity morse_fsm;


architecture rtl of morse_fsm is

    type estado_t is (
        ESPERA,
        PULSO,
        PAUSA,
        ESPERA_SOLTAR
    );

    signal estado_actual    : estado_t := ESPERA;
    signal estado_siguiente : estado_t := ESPERA;

    -- Sincronizacion de entradas externas.
    -- Estas dos etapas no son un filtro antirrebote.
    signal key1_meta : std_logic := '1';
    signal key1_sync : std_logic := '1';

    signal sw_meta : std_logic_vector(2 downto 0) :=
        (others => '0');

    signal sw_sync : std_logic_vector(2 downto 0) :=
        (others => '0');

    -- Registro Morse:
    -- 0 representa un punto.
    -- 1 representa una raya.
    -- Se transmite primero el bit 3.
    signal registro : std_logic_vector(3 downto 0) :=
        (others => '0');

    signal pendientes : integer range 0 to 4 := 0;

    signal contador : integer range
        0 to 3 * G_TICKS_05S - 1 := 0;

    signal fin_pulso : std_logic;
    signal fin_pausa : std_logic;

begin

    -- Determina si termino el punto o la raya actual.
    fin_pulso <= '1' when
        (
            registro(3) = '0' and
            contador = G_TICKS_05S - 1
        )
        or
        (
            registro(3) = '1' and
            contador = 3 * G_TICKS_05S - 1
        )
        else '0';

    -- Determina si termino la pausa entre simbolos.
    fin_pausa <= '1' when
        contador = G_TICKS_05S - 1
        else '0';


    -- ==========================================================
    -- PROCESO 1: MEMORIA DE ESTADO Y REGISTROS AUXILIARES
    -- ==========================================================
    p_memoria_estado : process (CLOCK_50, KEY(0))
    begin

        if KEY(0) = '0' then

            estado_actual <= ESPERA;

            key1_meta <= '1';
            key1_sync <= '1';

            sw_meta <= (others => '0');
            sw_sync <= (others => '0');

            registro   <= (others => '0');
            pendientes <= 0;
            contador   <= 0;

        elsif rising_edge(CLOCK_50) then

            -- Memoria del estado de la FSM.
            estado_actual <= estado_siguiente;

            -- Sincronizacion de entradas.
            key1_meta <= KEY(1);
            key1_sync <= key1_meta;

            sw_meta <= SW;
            sw_sync <= sw_meta;

            -- Actualizacion de registros y contadores.
            case estado_actual is

                when ESPERA =>

                    contador <= 0;

                    if key1_sync = '0' then

                        case sw_sync is

                            when "000" =>
                                -- A: .-
                                registro   <= "0100";
                                pendientes <= 2;

                            when "001" =>
                                -- B: -...
                                registro   <= "1000";
                                pendientes <= 4;

                            when "010" =>
                                -- C: -.-.
                                registro   <= "1010";
                                pendientes <= 4;

                            when "011" =>
                                -- D: -..
                                registro   <= "1000";
                                pendientes <= 3;

                            when "100" =>
                                -- E: .
                                registro   <= "0000";
                                pendientes <= 1;

                            when "101" =>
                                -- F: ..-.
                                registro   <= "0010";
                                pendientes <= 4;

                            when "110" =>
                                -- G: --.
                                registro   <= "1100";
                                pendientes <= 3;

                            when "111" =>
                                -- H: ....
                                registro   <= "0000";
                                pendientes <= 4;

                            when others =>
                                -- Caso de valores desconocidos
                                -- durante la simulacion.
                                registro   <= "0000";
                                pendientes <= 1;

                        end case;

                    end if;

                when PULSO =>

                    if fin_pulso = '1' then

                        contador <= 0;

                        -- Coloca el siguiente simbolo en el bit 3.
                        registro <= registro(2 downto 0) & '0';

                        if pendientes > 0 then
                            pendientes <= pendientes - 1;
                        end if;

                    else
                        contador <= contador + 1;
                    end if;

                when PAUSA =>

                    if fin_pausa = '1' then
                        contador <= 0;
                    else
                        contador <= contador + 1;
                    end if;

                when ESPERA_SOLTAR =>

                    contador <= 0;

            end case;

        end if;

    end process p_memoria_estado;


    -- ==========================================================
    -- PROCESO 2: TRANSICION DE ESTADOS
    -- ==========================================================
    p_transicion_estados : process (
        estado_actual,
        key1_sync,
        fin_pulso,
        fin_pausa,
        pendientes
    )
    begin

        -- Por defecto, permanece en el estado actual.
        estado_siguiente <= estado_actual;

        case estado_actual is

            when ESPERA =>

                if key1_sync = '0' then
                    estado_siguiente <= PULSO;
                end if;

            when PULSO =>

                if fin_pulso = '1' then

                    if pendientes <= 1 then
                        estado_siguiente <= ESPERA_SOLTAR;
                    else
                        estado_siguiente <= PAUSA;
                    end if;

                end if;

            when PAUSA =>

                if fin_pausa = '1' then
                    estado_siguiente <= PULSO;
                end if;

            when ESPERA_SOLTAR =>

                if key1_sync = '1' then
                    estado_siguiente <= ESPERA;
                end if;

        end case;

    end process p_transicion_estados;


    -- ==========================================================
    -- PROCESO 3: LOGICA DE SALIDA
    -- ==========================================================
    p_logica_salida : process (estado_actual)
    begin

        LEDR <= (others => '0');

        case estado_actual is

            when PULSO =>
                LEDR(0) <= '1';

            when others =>
                null;

        end case;

    end process p_logica_salida;

end architecture rtl;