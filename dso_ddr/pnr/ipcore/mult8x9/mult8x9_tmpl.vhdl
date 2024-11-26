-- Created by IP Generator (Version 2022.1 build 99559)
-- Instantiation Template
--
-- Insert the following codes into your VHDL file.
--   * Change the_instance_name to your own instance name.
--   * Change the net names in the port map.


COMPONENT mult8x9
  PORT (
    a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    ce : IN STD_LOGIC;
    p : OUT STD_LOGIC_VECTOR(16 DOWNTO 0)
  );
END COMPONENT;


the_instance_name : mult8x9
  PORT MAP (
    a => a,
    b => b,
    clk => clk,
    rst => rst,
    ce => ce,
    p => p
  );
