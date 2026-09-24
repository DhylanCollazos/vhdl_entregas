library ieee;
use ieee.std_logic_1164.all;

entity RF5_Conteo is
    generic (
        FRECUENCIA_RELOJ_HZ : positive := 50000000;
        CICLOS_FILTRO : positive := 500000;
        CICLOS_ATASCO : positive := 250000000
    );
    port (
        RELOJ, REINICIO_BAJO, PRESENCIA : in std_logic;
        SELECTOR_COLOR : in std_logic_vector(1 downto 0);

        SELECTOR_TAMANO, CAMBIO_VELOCIDAD, LINEA_MARCHA :
            in std_logic;

        VISOR_TOTAL, VISOR_TOTAL_MEDIO, VISOR_TOTAL_ALTO :
            out std_logic_vector(6 downto 0);

        VISOR_VELOCIDAD : out std_logic_vector(6 downto 0);
        LED_COLOR : out std_logic_vector(1 downto 0);

        LED_TAMANO, LINEA_ACTIVA, LED_RECHAZO, ALARMA, LED_LIMITE :
            out std_logic
    );
end entity RF5_Conteo;

architecture estructural of RF5_Conteo is

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

    component contador_ascendente is
        generic (
            ANCHO_BITS : positive := 4
        );
        port (
            reloj, reinicio, habilitar : in std_logic;
            CUENTA : out std_logic_vector(ANCHO_BITS-1 downto 0)
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
            pulso_motor, led_linea, en_marcha :
                out std_logic
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

    component decodificador_7segmentos is
        port (
            numero : in std_logic_vector(3 downto 0);
            segmentos : out std_logic_vector(6 downto 0)
        );
    end component;

    signal reinicio_alto, nueva, presente, tamano, valida :
        std_logic;

    signal color : std_logic_vector(1 downto 0);
    signal total : std_logic_vector(11 downto 0);

    signal contar, error, limite, bloqueo,
           marcha_real, pulso_linea :
        std_logic;

    signal segmentos_velocidad :
        std_logic_vector(6 downto 0);

begin

    U_REINICIO : reinicio_seguro
        port map (
            reloj           => RELOJ,
            reinicio_bajo   => REINICIO_BAJO,
            reinicio_salida => reinicio_alto
        );

    U_CAPTURA : captura_pieza
        generic map (
            CICLOS_FILTRO => CICLOS_FILTRO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            presencia_baja   => PRESENCIA,
            color_selector   => SELECTOR_COLOR,
            tamano_selector  => SELECTOR_TAMANO,
            nueva_pieza      => nueva,
            presencia_activa => presente,
            color            => color,
            tamano           => tamano
        );

    U_REGLAS : tabla_reglas
        port map (
            color  => color,
            tamano => tamano,
            ruta   => open,
            valida => valida
        );

    limite <= '1' when total = x"FFF" else '0';
    bloqueo <= error or limite;

    -- El conteo no depende de los pulsos de velocidad.
    contar <= nueva and valida and marcha_real;

    U_TOTAL : contador_ascendente
        generic map (
            ANCHO_BITS => 12
        )
        port map (
            reloj     => RELOJ,
            reinicio  => reinicio_alto,
            habilitar => contar,
            CUENTA    => total
        );

    U_VELOCIDAD : selector_velocidad
        generic map (
            FRECUENCIA_RELOJ_HZ => FRECUENCIA_RELOJ_HZ,
            CICLOS_FILTRO       => CICLOS_FILTRO
        )
        port map (
            reloj        => RELOJ,
            reinicio     => reinicio_alto,
            boton_bajo   => CAMBIO_VELOCIDAD,
            nivel_salida => open,
            pulso_linea  => pulso_linea,
            segmentos    => segmentos_velocidad
        );

    U_LINEA : control_linea
        port map (
            reloj              => RELOJ,
            reinicio           => reinicio_alto,
            marcha             => LINEA_MARCHA,
            bloqueo            => bloqueo,
            pulso_linea_entrada => pulso_linea,
            pulso_motor        => open,
            led_linea          => LINEA_ACTIVA,
            en_marcha          => marcha_real
        );

    U_ERRORES : supervisor_error
        generic map (
            CICLOS_ATASCO => CICLOS_ATASCO
        )
        port map (
            reloj            => RELOJ,
            reinicio         => reinicio_alto,
            marcha           => marcha_real,
            presencia_activa => presente,
            nueva_pieza      => nueva,
            pieza_valida     => valida,
            alarma           => error
        );

    U_TOTAL0 : decodificador_7segmentos
        port map (
            numero    => total(3 downto 0),
            segmentos => VISOR_TOTAL
        );

    U_TOTAL1 : decodificador_7segmentos
        port map (
            numero    => total(7 downto 4),
            segmentos => VISOR_TOTAL_MEDIO
        );

    U_TOTAL2 : decodificador_7segmentos
        port map (
            numero    => total(11 downto 8),
            segmentos => VISOR_TOTAL_ALTO
        );

    -- La linea detenida se representa con un guion.
    VISOR_VELOCIDAD <= segmentos_velocidad
        when marcha_real = '1' else "0111111";

    process(RELOJ, reinicio_alto)
    begin
        if reinicio_alto = '1' then
            LED_RECHAZO <= '0';

        elsif rising_edge(RELOJ) then
            if nueva = '1' then
                LED_RECHAZO <= not valida;
            end if;
        end if;
    end process;

    LED_COLOR <= color;
    LED_TAMANO <= tamano;
    ALARMA <= error;
    LED_LIMITE <= limite;

end architecture estructural;