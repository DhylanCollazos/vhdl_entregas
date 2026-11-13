library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RF3_Clasificacion_TB is
end entity RF3_Clasificacion_TB;

architecture RF3_Clasificacion_TB_arch
of RF3_Clasificacion_TB is

    component RF3_Clasificacion is
        generic (
            CICLOS_FILTRO : positive := 500000;
            CICLOS_ATASCO : positive := 250000000
        );
        port (
            RELOJ, REINICIO_BAJO, PRESENCIA :
                in std_logic;

            SELECTOR_COLOR :
                in std_logic_vector(1 downto 0);

            SELECTOR_TAMANO :
                in std_logic;

            LED_COLOR :
                out std_logic_vector(1 downto 0);

            LED_TAMANO :
                out std_logic;

            RUTA_PIEZA :
                out std_logic_vector(3 downto 0);

            ALARMA :
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

    signal LED_COLOR_TB :
        std_logic_vector(1 downto 0);

    signal LED_TAMANO_TB :
        std_logic;

    signal RUTA_PIEZA_TB :
        std_logic_vector(3 downto 0);

    signal ALARMA_TB :
        std_logic;

    signal FIN_TB :
        boolean := false;

begin

    RELOJ_TB <= not RELOJ_TB after 10 ns
        when not FIN_TB else '0';

    DUT1 : RF3_Clasificacion
        generic map (
            CICLOS_FILTRO => 3,
            CICLOS_ATASCO => 100
        )
        port map (
            RELOJ           => RELOJ_TB,
            REINICIO_BAJO   => REINICIO_BAJO_TB,
            PRESENCIA       => PRESENCIA_TB,
            SELECTOR_COLOR  => SELECTOR_COLOR_TB,
            SELECTOR_TAMANO => SELECTOR_TAMANO_TB,
            LED_COLOR       => LED_COLOR_TB,
            LED_TAMANO      => LED_TAMANO_TB,
            RUTA_PIEZA      => RUTA_PIEZA_TB,
            ALARMA          => ALARMA_TB
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

    begin

        esperar(4);
        REINICIO_BAJO_TB <= '1';
        esperar(10);

        assert
            RUTA_PIEZA_TB = "0000" and
            ALARMA_TB = '0'

            report "Estado inicial incorrecto"
            severity failure;

        -- Las seis combinaciones deben ser válidas.
        for i in 1 to 6 loop

            ingresar(i);

            assert
                RUTA_PIEZA_TB =
                    std_logic_vector(to_unsigned(i, 4))

                report "Categoria incorrecta"
                severity failure;

            assert ALARMA_TB = '0'
                report "Categoria valida genero alarma"
                severity failure;

        end loop;

        -- Color 00 debe ser rechazo.
        SELECTOR_COLOR_TB <= "00";
        esperar(8);

        PRESENCIA_TB <= '0';
        esperar(10);

        PRESENCIA_TB <= '1';
        esperar(10);

        assert
            RUTA_PIEZA_TB = "1000" and
            ALARMA_TB = '1'

            report "El rechazo no funciona"
            severity failure;

        report "OK: RF3_Clasificacion_TB"
            severity note;

        FIN_TB <= true;
        wait;

    end process STIMULUS;

end architecture RF3_Clasificacion_TB_arch;