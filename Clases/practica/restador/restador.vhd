library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity restador is
    port
    (
        x, y     : in std_logic_vector(3 downto 0);

        sign     : out std_logic;
        magnitud : out std_logic_vector(3 downto 0)
    );
end restador;

architecture arch_restador of restador is
begin

    process(x, y)

        variable x_num : unsigned(3 downto 0);
        variable y_num : unsigned(3 downto 0);

    begin

        -- Interpretamos las entradas como numeros sin signo.
        x_num := unsigned(x);
        y_num := unsigned(y);

        if x_num >= y_num then

            -- Resultado positivo o cero.
            sign <= '0';
            magnitud <= std_logic_vector(x_num - y_num);

        else

            -- Resultado negativo: guardamos su magnitud.
            sign <= '1';
            magnitud <= std_logic_vector(y_num - x_num);

        end if;

    end process;

end arch_restador;