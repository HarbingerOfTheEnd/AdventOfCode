test-day-01: 2024/day-01/main.c
	clang -o 2024/day-01/main 2024/day-01/main.c -Wall -Wextra -Werror -std=c23 -pedantic -O3 && ./2024/day-01/main ./2024/day-01/test-input.txt

day-01: 2024/day-01/main.c
	clang -o 2024/day-01/main 2024/day-01/main.c -Wall -Wextra -Werror -std=c23 -pedantic -O3 && ./2024/day-01/main ./2024/day-01/input.txt