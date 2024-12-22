#!/usr/bin/env -S python -OO

from __future__ import annotations

import sys
from re import Pattern, compile, finditer, fullmatch

EX_USAGE = 64


def find_part_1_result(txt: str, mul_pattern: Pattern, full_pattern: Pattern) -> int:
    result = 0

    for match in finditer(full_pattern, txt):
        if mul_match := fullmatch(mul_pattern, match.group()):
            a, b = map(int, mul_match.groups())
            result += a * b

    return result


def find_part_2_result(
    txt: str,
    mul_pattern: Pattern,
    do_pattern: Pattern,
    dont_pattern: Pattern,
    full_pattern: Pattern,
) -> int:
    result = 0
    do = True

    for match in finditer(full_pattern, txt):
        if fullmatch(do_pattern, match.group()):
            do = True
        elif fullmatch(dont_pattern, match.group()):
            do = False
        elif (mul_match := fullmatch(mul_pattern, match.group())) and do:
            a, b = map(int, mul_match.groups())
            result += a * b

    return result


def main(argv: list[str]) -> None:
    if len(argv) != 2:
        print(f"Usage: {argv[0]} <file>", file=sys.stderr)
        exit(EX_USAGE)

    mul_pattern = compile(r"mul\((\d+),(\d+)\)")
    do_pattern = compile(r"do\(\)")
    dont_pattern = compile(r"don't\(\)")
    pattern = compile(r"don't\(\)|do\(\)|mul\((\d+),(\d+)\)")

    with open(argv[1], "r") as f:
        txt = f.read().strip()
        part_1_result = find_part_1_result(txt, mul_pattern, pattern)
        part_2_result = find_part_2_result(
            txt,
            mul_pattern,
            do_pattern,
            dont_pattern,
            pattern,
        )

    print(f"Part 1: {part_1_result}")
    print(f"Part 2: {part_2_result}")


if __name__ == "__main__":
    main(sys.argv)
