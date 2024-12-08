test-day-01: 2024/day-01/main.c
	clang -o 2024/day-01/main 2024/day-01/main.c -Wall -Wextra -Werror -std=c23 -pedantic -O3 && ./2024/day-01/main ./2024/day-01/test-input.txt

day-01: 2024/day-01/main.c
	clang -o 2024/day-01/main 2024/day-01/main.c -Wall -Wextra -Werror -std=c23 -pedantic -O3 && ./2024/day-01/main ./2024/day-01/input.txt

test-day-02: 2024/day-02/main.zig
	zig run 2024/day-02/main.zig -- ./2024/day-02/test-input.txt

day-02: 2024/day-02/main.zig
	zig run 2024/day-02/main.zig -- ./2024/day-02/input.txt

test-day-03: 2024/day-03/main.py
	./2024/day-03/main.py ./2024/day-03/test-input.txt

day-03: 2024/day-03/main.py
	./2024/day-03/main.py ./2024/day-03/input.txt
