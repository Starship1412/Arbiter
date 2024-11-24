library IEEE;
use ieee.std_logic_1164.all;
use ieee.math_real.all; -- for UNIFORM, TRUNC
use ieee.numeric_std.all; -- for TO_UNSIGNED
use std.textio.all;
use ieee.std_logic_textio.all;

entity driver is
	port (
		clk : in std_logic;
		cmd : inout std_logic;
		n1, n2, n3 : in signed(2 downto 0);
		req : inout std_logic_vector(2 downto 0)
	);
end entity;

architecture behavioral of driver is
constant n : real:=10.0;
begin
clk <= not(clk) after 10 ns;
	process(clk)
	-- Seed values for random generator
	variable seed1, seed2: positive;
	-- Random real-number value in range 0 to 1.0
	variable rand: real;
	-- Random integer value in range 0..7
	variable int_rand_wait, int_rand_req, count: integer := 0;
	-- Next req
	variable req_next : std_logic_vector(2 downto 0) :="000";
	begin
	-- initialise seed1, seed2 if you want --
	-- otherwise they're initialised to 1 by default
		if count = 0 then
			-- Random wait
			UNIFORM(seed1, seed2, rand);
			-- 1. rescale to 1..n, find integer part
			int_rand_wait := INTEGER(TRUNC(rand*n)) + 1;
			-- Random req
			UNIFORM(seed1, seed2, rand);
			-- get a 3-bit random value...
			-- 1. rescale to 0..7, find integer part
			int_rand_req := INTEGER(TRUNC(rand*8.0));
			-- 2. convert to std_logic_vector
			req_next := std_logic_vector(to_unsigned(int_rand_req, req'LENGTH));
		end if;
    begin
	-- initialise seed1, seed2 if you want -
	-- otherwise they're initialised to 1 by default
		if count=0 then
			-- Random wait
			UNIFORM(seed1, seed2, rand);
			-- 1. rescale to 1..n, find integer part
			int_rand_wait := INTEGER(TRUNC(rand*n)) + 1;
			-- Random req
			UNIFORM(seed1, seed2, rand);
			-- get a 3-bit random value...
			-- 1. rescale to 0..7, find integer part
			int_rand_req := INTEGER(TRUNC(rand*8.0));
			-- 2. convert to std_logic_vector
			req_next := std_logic_vector(to_unsigned(int_rand_req, req'LENGTH));
		end if;
		if rising_edge(clk) then
			-- Generate the request and control signals on rising edge of clock
			if count = 0 then
				cmd <= '1';  -- Set cmd to '1' to indicate that a new request is active
				req <= req_next;  -- Set req to the generated random request value
				count := int_rand_wait;  -- Reset count to the random wait time
			else
				cmd <= '0';  -- If waiting, cmd is set to '0'
				count := count - 1;  -- Decrement the count until it reaches zero
			end if;
		end if;
	end process;
	process(cmd)
	file output_file: text open write_mode is "C:\Users\stars\Xilinx_Files\Arbiter\Display.txt";
	variable line_buf: line;
	begin
		if cmd = '1' then
			-- Write the values of req, n1, n2, and n3 to the output file
			write(line_buf, string'("req: "));
			write(line_buf, req);
			write(line_buf, string'(" n1: "));
			write(line_buf, n1);
			write(line_buf, string'(" n2: "));
			write(line_buf, n2);
			write(line_buf, string'(" n3: "));
			write(line_buf, n3);
			writeline(output_file, line_buf);
		end if;
	end process;         
end architecture;