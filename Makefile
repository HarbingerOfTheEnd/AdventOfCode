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

test-day-04: 2024/day-04/main.go
	go run ./2024/day-04/main.go ./2024/day-04/test-input.txt

day-04: 2024/day-04/main.go
	go run ./2024/day-04/main.go ./2024/day-04/input.txt

test-day-05: 2024/day-05/main.ts
	./2024/day-05/main.ts ./2024/day-05/test-input.txt

day-05: 2024/day-05/main.ts
	./2024/day-05/main.ts ./2024/day-05/input.txt

test-day-06: 2024/day-06/Main.java
	javac 2024/day-06/Main.java && java 2024/day-06/Main.java ./2024/day-06/test-input.txt

day-06: 2024/day-06/Main.java
	javac 2024/day-06/Main.java && java 2024/day-06/Main.java ./2024/day-06/input.txt
