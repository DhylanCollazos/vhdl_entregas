library ieee;
use ieee.std_logic_1164.all;

entity tabla_reglas is
    port (
        color  : in std_logic_vector(1 downto 0);
        tamano : in std_logic;

        ruta   : out std_logic_vector(3 downto 0);
        valida : out std_logic
    );
end entity tabla_reglas;

architecture tabla of tabla_reglas is

    signal direccion : std_logic_vector(2 downto 0);

begin

    direccion <= color & tamano;

    process(direccion)
    begin

        -- Por defecto: pieza rechazada.
        ruta <= "1000";
        valida <= '0';

        case direccion is

            when "010" =>
                ruta <= "0001"; -- Rojo pequeno
                valida <= '1';

            when "011" =>
                ruta <= "0010"; -- Rojo grande
                valida <= '1';

            when "100" =>
                ruta <= "0011"; -- Verde pequeno
                valida <= '1';

            when "101" =>
                ruta <= "0100"; -- Verde grande
                valida <= '1';

            when "110" =>
                ruta <= "0101"; -- Azul pequeno
                valida <= '1';

            when "111" =>
                ruta <= "0110"; -- Azul grande
                valida <= '1';

            when others =>
                null;

        end case;

    end process;

end architecture tabla;