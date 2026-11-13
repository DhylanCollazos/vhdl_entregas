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
            USAR_VENTANAS_MM => true,
            GRANDE_MIN_MM => 20, GRANDE_MAX_MM => 28,
            PEQUENA_MIN_MM => 32, PEQUENA_MAX_MM => 48,
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

    U_DECIMAL : entity work.conversor_decimal_reloj
        port map (
            reloj => CLOCK_50,
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
