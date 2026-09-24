library ieee;
use ieee.std_logic_1164.all;

entity tabla_reglas is
    port (
        color : in std_logic_vector(1 downto 0);
        tamano : in std_logic;

        ruta : out std_logic_vector(3 downto 0);
        valida : out std_logic
    );
end entity tabla_reglas;

architecture tabla of tabla_reglas is

    signal direccion : std_logic_vector(2 downto 0);

begin

    direccion <= color & tamano;

    process(direccion)
    begin
        -- Por defecto, la pieza se rechaza.
        ruta <= "1000";
        valida <= '0';

        case direccion is
            when "011" =>               -- Rojo grande
                ruta <= "0001";
                valida <= '1';

            when "100" =>               -- Verde pequena
                ruta <= "0010";
                valida <= '1';

            when "111" =>               -- Azul grande
                ruta <= "0100";
                valida <= '1';

            when others =>
                null;
        end case;
    end process;

end architecture tabla;