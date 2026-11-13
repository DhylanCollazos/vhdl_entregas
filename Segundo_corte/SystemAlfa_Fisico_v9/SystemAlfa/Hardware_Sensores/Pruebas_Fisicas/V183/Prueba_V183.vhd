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
