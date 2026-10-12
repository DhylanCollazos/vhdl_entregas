LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY contador_ascendente IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        Q     : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END contador_ascendente;


ARCHITECTURE synth OF contador_ascendente IS

    SIGNAL contador : UNSIGNED(3 DOWNTO 0);

BEGIN

    PROCESS(clk, reset)
    BEGIN

        IF reset = '1' THEN
            contador <= "0000";

        ELSIF rising_edge(clk) THEN
            contador <= contador + 1;
        END IF;

    END PROCESS;

    Q <= STD_LOGIC_VECTOR(contador);

END synth;