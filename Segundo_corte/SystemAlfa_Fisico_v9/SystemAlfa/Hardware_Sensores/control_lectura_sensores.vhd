library ieee;
use ieee.std_logic_1164.all;

-- Coordinador de presencia, HC-SR04 y TCS3200 implementado como FSM Moore.
--
-- Estados:
--   ESPERA               : espera una nueva pieza del V183.
--   INICIAR_MEDICIONES   : genera pulsos de inicio para ambos lectores.
--   ESPERAR_MEDICIONES   : espera que terminen ultrasonido y color.
--   PREPARAR_EVENTO      : guarda los datos o prepara un rechazo.
--   ENVIAR_EVENTO        : genera PRESENCIA activa-baja al nucleo.
--   ESPERAR_RETIRO       : espera que la pieza salga del V183.
--   ESPERAR_LIBERACION   : confirma que el sensor quedo libre.
entity control_lectura_sensores is
    generic (
        CICLOS_PULSO_CORE : positive := 1000000;
        CICLOS_LIBERACION : positive := 1000000
    );
    port (
        reloj               : in  std_logic;
        reinicio            : in  std_logic;

        pulso_presencia     : in  std_logic;
        presencia_fisica    : in  std_logic;

        hc_lista            : in  std_logic;
        hc_valida           : in  std_logic;
        hc_tamano           : in  std_logic;

        tcs_lista           : in  std_logic;
        tcs_valida          : in  std_logic;
        tcs_color           : in  std_logic_vector(1 downto 0);

        iniciar_hc          : out std_logic;
        iniciar_tcs         : out std_logic;

        presencia_core_n    : out std_logic;
        color_core          : out std_logic_vector(1 downto 0);
        tamano_core         : out std_logic;

        ocupado             : out std_logic;
        error_sensores      : out std_logic
    );
end entity control_lectura_sensores;

architecture fsm_tres_procesos of control_lectura_sensores is

    type tipo_estado is (
        ESPERA,
        INICIAR_MEDICIONES,
        ESPERAR_MEDICIONES,
        PREPARAR_EVENTO,
        ENVIAR_EVENTO,
        ESPERAR_RETIRO,
        ESPERAR_LIBERACION
    );

    signal estado_actual    : tipo_estado := ESPERA;
    signal estado_siguiente : tipo_estado := ESPERA;

    signal hc_termino  : std_logic := '0';
    signal tcs_termino : std_logic := '0';

    signal hc_valida_guardada  : std_logic := '0';
    signal tcs_valida_guardada : std_logic := '0';
    signal tamano_guardado     : std_logic := '0';
    signal color_guardado      : std_logic_vector(1 downto 0) := "00";

    signal color_core_reg  : std_logic_vector(1 downto 0) := "00";
    signal tamano_core_reg : std_logic := '0';
    signal error_reg       : std_logic := '0';

    signal cuenta_pulso      : integer range 0 to CICLOS_PULSO_CORE-1 := 0;
    signal cuenta_liberacion : integer range 0 to CICLOS_LIBERACION-1 := 0;

begin

    ------------------------------------------------------------------------
    -- PROCESO 1: registro de estado, datos y contadores
    ------------------------------------------------------------------------
    process(reloj, reinicio)
    begin
        if reinicio = '1' then
            estado_actual        <= ESPERA;
            hc_termino           <= '0';
            tcs_termino          <= '0';
            hc_valida_guardada   <= '0';
            tcs_valida_guardada  <= '0';
            tamano_guardado      <= '0';
            color_guardado       <= "00";
            color_core_reg       <= "00";
            tamano_core_reg      <= '0';
            error_reg            <= '0';
            cuenta_pulso         <= 0;
            cuenta_liberacion    <= 0;

        elsif rising_edge(reloj) then
            estado_actual <= estado_siguiente;

            case estado_actual is

                when ESPERA =>
                    hc_termino          <= '0';
                    tcs_termino         <= '0';
                    hc_valida_guardada  <= '0';
                    tcs_valida_guardada <= '0';
                    cuenta_pulso        <= 0;
                    cuenta_liberacion   <= 0;
                    error_reg           <= '0';

                when INICIAR_MEDICIONES =>
                    color_core_reg  <= "00";
                    tamano_core_reg <= '0';

                when ESPERAR_MEDICIONES =>
                    if hc_lista = '1' then
                        hc_termino          <= '1';
                        hc_valida_guardada  <= hc_valida;
                        tamano_guardado     <= hc_tamano;
                    end if;

                    if tcs_lista = '1' then
                        tcs_termino          <= '1';
                        tcs_valida_guardada  <= tcs_valida;
                        color_guardado       <= tcs_color;
                    end if;

                when PREPARAR_EVENTO =>
                    cuenta_pulso <= 0;

                    if hc_valida_guardada = '1' and
                       tcs_valida_guardada = '1' then
                        color_core_reg  <= color_guardado;
                        tamano_core_reg <= tamano_guardado;
                        error_reg       <= '0';
                    else
                        -- Color 00 obliga a la ROM del nucleo a generar rechazo.
                        color_core_reg  <= "00";
                        tamano_core_reg <= '0';
                        error_reg       <= '1';
                    end if;

                when ENVIAR_EVENTO =>
                    if cuenta_pulso = CICLOS_PULSO_CORE-1 then
                        cuenta_pulso <= 0;
                    else
                        cuenta_pulso <= cuenta_pulso + 1;
                    end if;

                when ESPERAR_RETIRO =>
                    if presencia_fisica = '0' then
                        cuenta_liberacion <= 0;
                    end if;

                when ESPERAR_LIBERACION =>
                    if presencia_fisica = '1' then
                        cuenta_liberacion <= 0;
                    elsif cuenta_liberacion = CICLOS_LIBERACION-1 then
                        cuenta_liberacion <= 0;
                    else
                        cuenta_liberacion <= cuenta_liberacion + 1;
                    end if;

            end case;
        end if;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 2: logica del estado siguiente
    ------------------------------------------------------------------------
    process(
        estado_actual,
        pulso_presencia,
        presencia_fisica,
        hc_termino,
        tcs_termino,
        hc_lista,
        tcs_lista,
        cuenta_pulso,
        cuenta_liberacion
    )
    begin
        estado_siguiente <= estado_actual;

        case estado_actual is

            when ESPERA =>
                if pulso_presencia = '1' then
                    estado_siguiente <= INICIAR_MEDICIONES;
                end if;

            when INICIAR_MEDICIONES =>
                estado_siguiente <= ESPERAR_MEDICIONES;

            when ESPERAR_MEDICIONES =>
                if (hc_termino = '1' or hc_lista = '1') and
                   (tcs_termino = '1' or tcs_lista = '1') then
                    estado_siguiente <= PREPARAR_EVENTO;
                end if;

            when PREPARAR_EVENTO =>
                estado_siguiente <= ENVIAR_EVENTO;

            when ENVIAR_EVENTO =>
                if cuenta_pulso = CICLOS_PULSO_CORE-1 then
                    estado_siguiente <= ESPERAR_RETIRO;
                end if;

            when ESPERAR_RETIRO =>
                if presencia_fisica = '0' then
                    estado_siguiente <= ESPERAR_LIBERACION;
                end if;

            when ESPERAR_LIBERACION =>
                if presencia_fisica = '1' then
                    estado_siguiente <= ESPERAR_RETIRO;
                elsif cuenta_liberacion = CICLOS_LIBERACION-1 then
                    estado_siguiente <= ESPERA;
                end if;

        end case;
    end process;

    ------------------------------------------------------------------------
    -- PROCESO 3: logica de salidas Moore
    ------------------------------------------------------------------------
    process(estado_actual)
    begin
        iniciar_hc       <= '0';
        iniciar_tcs      <= '0';
        presencia_core_n <= '1';
        ocupado          <= '1';

        case estado_actual is

            when ESPERA =>
                ocupado <= '0';

            when INICIAR_MEDICIONES =>
                iniciar_hc  <= '1';
                iniciar_tcs <= '1';

            when ENVIAR_EVENTO =>
                presencia_core_n <= '0';

            when others =>
                null;

        end case;
    end process;

    color_core     <= color_core_reg;
    tamano_core    <= tamano_core_reg;
    error_sensores <= error_reg;

end architecture fsm_tres_procesos;
