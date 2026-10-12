library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF5_Conteo_TB is
end entity RF5_Conteo_TB;

architecture RF5_Conteo_TB_arch
of RF5_Conteo_TB is

    component RF5_Conteo is
        generic (
            FRECUENCIA_RELOJ_HZ : positive := 50000000;
            CICLOS_FILTRO       : positive := 500000;
            CICLOS_ATASCO       : positive := 250000000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO,
            CAMBIO_VELOCIDAD,
            LINEA_MARCHA :
                in std_logic;

            VISOR_TOTAL,
            VISOR_TOTAL_MEDIO,
            VISOR_TOTAL_ALTO :
                out std_logic_vector(6 downto 0);

            VISOR_VELOCIDAD :
                out std_logic_vector(6 downto 0);

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO,
            LINEA_ACTIVA,
            LED_RECHAZO,
            ALARMA,
            LED_LIMITE :
                out std_logic
        );
    end component;

    signal RELOJ_TB         : std_logic := '0';
    signal REINICIO_BAJO_TB : std_logic := '0';
    signal PRESENCIA_TB     : std_logic := '1';

    signal SELECTOR_COLOR_TB :
        std_logic_vector(1 downto 0) := "00";

    signal SELECTOR_TAMANO_TB :
        std_logic := '0';

    signal CAMBIO_VELOCIDAD_TB :
        std_logic := '1';

    signal LINEA_MARCHA_TB :
        std_logic := '0';

    signal VISOR_TOTAL_TB,
           VISOR_TOTAL_MEDIO_TB,
           VISOR_TOTAL_ALTO_TB :
        std_logic_vector(6 downto 0);

    signal VISOR_VELOCIDAD_TB :
        std_logic_vector(6 downto 0);

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB,
           LINEA_ACTIVA_TB,
           LED_RECHAZO_TB,
           ALARMA_TB,
           LED_LIMITE_TB :
        std_logic;

    signal FIN_TB :
        boolean := false;

    type tabla_segmentos is
        array (0 to 15) of std_logic_vector(6 downto 0);

    constant PATRONES : tabla_segmentos := (
        "1000000", "1111001", "0100100", "0110000",
        "0011001", "0010010", "0000010", "1111000",
        "0000000", "0010000", "0001000", "0000011",
        "1000110", "0100001", "0000110", "0001110"
    );

    function leer_hex(
        s : std_logic_vector(6 downto 0)
    ) return integer is
    begin

        for i in 0 to 15 loop
            if s = PATRONES(i) then
                return i;
            end if;
        end loop;

        return -1;

    end function;

    function leer_decimal(
        c, d, u : std_logic_vector(6 downto 0)
    ) return integer is

        variable a, b, e : integer;

    begin

        a := leer_hex(c);
        b := leer_hex(d);
        e := leer_hex(u);

        if
            a < 0 or a > 9 or
            b < 0 or b > 9 or
            e < 0 or e > 9
        then
            return -1;
        end if;

        return 100*a + 10*b + e;

    end function;

begin

    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF5_Conteo
        generic map (
            FRECUENCIA_RELOJ_HZ => 60,
            CICLOS_FILTRO       => 3,
            CICLOS_ATASCO       => 10000
        )
        port map (
            RELOJ               => RELOJ_TB,
            REINICIO_BAJO       => REINICIO_BAJO_TB,
            PRESENCIA           => PRESENCIA_TB,
            SELECTOR_COLOR      => SELECTOR_COLOR_TB,
            SELECTOR_TAMANO     => SELECTOR_TAMANO_TB,
            CAMBIO_VELOCIDAD    => CAMBIO_VELOCIDAD_TB,
            LINEA_MARCHA        => LINEA_MARCHA_TB,
            VISOR_TOTAL         => VISOR_TOTAL_TB,
            VISOR_TOTAL_MEDIO   => VISOR_TOTAL_MEDIO_TB,
            VISOR_TOTAL_ALTO    => VISOR_TOTAL_ALTO_TB,
            VISOR_VELOCIDAD     => VISOR_VELOCIDAD_TB,
            LED_COLOR           => LED_COLOR_TB,
            LED_TAMANO          => LED_TAMANO_TB,
            LINEA_ACTIVA        => LINEA_ACTIVA_TB,
            LED_RECHAZO         => LED_RECHAZO_TB,
            ALARMA              => ALARMA_TB,
            LED_LIMITE          => LED_LIMITE_TB
        );

    STIMULUS : process

        procedure esperar(n : positive := 1) is
        begin
            for i in 1 to n loop
                wait until rising_edge(RELOJ_TB);
                wait for 1 ns;
            end loop;
        end procedure;

        procedure ingresar(categoria : positive) is
        begin

            SELECTOR_COLOR_TB <=
                std_logic_vector(
                    to_unsigned((categoria + 1) / 2, 2)
                );

            if categoria mod 2 = 0 then
                SELECTOR_TAMANO_TB <= '1';
            else
                SELECTOR_TAMANO_TB <= '0';
            end if;

            esperar(8);

            PRESENCIA_TB <= '0';
            esperar(10);

            PRESENCIA_TB <= '1';
            esperar(10);

        end procedure;

        procedure comprobar(n : natural) is
        begin

            assert
                leer_decimal(
                    VISOR_TOTAL_ALTO_TB,
                    VISOR_TOTAL_MEDIO_TB,
                    VISOR_TOTAL_TB
                ) = n

                report "Total decimal incorrecto"
                severity failure;

        end procedure;

    begin

        -- Reset.
        esperar(4);
        REINICIO_BAJO_TB <= '1';
        esperar(12);

        -- Rearmar línea.
        LINEA_MARCHA_TB <= '0';
        esperar(8);

        LINEA_MARCHA_TB <= '1';
        esperar(8);

        comprobar(0);

        -- Las seis categorías válidas deben contar.
        for i in 1 to 6 loop
            ingresar(i);
            comprobar(i);
        end loop;

        -- Detener línea: no debe contar.
        LINEA_MARCHA_TB <= '0';
        esperar(8);

        ingresar(1);
        comprobar(6);

        -- Reanudar.
        LINEA_MARCHA_TB <= '1';
        esperar(8);

        -- Color inválido.
        SELECTOR_COLOR_TB <= "00";
        esperar(8);

        PRESENCIA_TB <= '0';
        esperar(10);

        PRESENCIA_TB <= '1';
        esperar(10);

        comprobar(6);

        assert
            ALARMA_TB = '1' and
            LED_RECHAZO_TB = '1' and
            LINEA_ACTIVA_TB = '0'

            report "Rechazo incorrecto"
            severity failure;

        report "OK: RF5_Conteo_TB"
            severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF5_Conteo_TB_arch;