package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func Eprintf(format string, args ...any) {
	fmt.Fprintf(os.Stderr, format, args...)
}

func ReadLinesFromFile(filename string) ([]string, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	lines := []string{}
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	return lines, nil
}

func FindHorizontalCount(lines []string) uint64 {
	count := 0
	word := "XMAS"
	reversedWord := "SAMX"

	for _, line := range lines {
		if strings.Contains(line, word) {
			count += strings.Count(line, word)
		}

		if strings.Contains(line, reversedWord) {
			count += strings.Count(line, reversedWord)
		}
	}

	return uint64(count)
}

func FindVerticalCount(lines []string) uint64 {
	count := 0
	word := "XMAS"
	reversedWord := "SAMX"

	for i := 0; i < len(lines); i++ {
		column := ""

		for j := 0; j < len(lines[i]); j++ {
			column += string(lines[j][i])
		}

		if strings.Contains(column, word) {
			count += strings.Count(column, word)
		}
		if strings.Contains(column, reversedWord) {
			count += strings.Count(column, reversedWord)
		}
	}

	return uint64(count)
}

func findDiagonalWords(lines []string, i int, j int, size int) (diagonalWord string, reverseDiagonalWord string) {
	words := make([]string, size)

	for k := 0; k < size; k++ {
		word := lines[i+k][j : j+size]
		words[k] = word
	}

	for i := 0; i < size; i++ {
		diagonalWord += string(words[i][i])
		reverseDiagonalWord += string(words[i][size-i-1])
	}

	return diagonalWord, reverseDiagonalWord
}

func FindDiagonalCount(lines []string) uint64 {
	count := 0
	word := "XMAS"
	reversedWord := "SAMX"

	for i := 0; i < len(lines); i++ {
		for j := 0; j < len(lines[i]); j++ {
			if i+len(word) > len(lines) || j+len(word) > len(lines) {
				break
			}

			diagonalWord, reverseDiagonalWord := findDiagonalWords(lines, i, j, 4)

			if diagonalWord == word {
				count++
			}
			if diagonalWord == reversedWord {
				count++
			}
			if reverseDiagonalWord == word {
				count++
			}
			if reverseDiagonalWord == reversedWord {
				count++
			}
		}
	}

	return uint64(count)
}

func FindXmasCount(lines []string) uint64 {
	count := uint64(0)
	count += FindHorizontalCount(lines)
	count += FindVerticalCount(lines)
	count += FindDiagonalCount(lines)

	return count
}

func FindXMasCount(lines []string) uint64 {
	count := uint64(0)
	word := "MAS"
	reversedWord := "SAM"

	for i := 0; i < len(lines); i++ {
		for j := 0; j < len(lines[i]); j++ {
			if i+len(word) > len(lines) || j+len(word) > len(lines[i]) {
				break
			}
			diagonalWord, reversedDiagonalWord := findDiagonalWords(lines, i, j, 3)

			if (diagonalWord == word || diagonalWord == reversedWord) && (reversedDiagonalWord == word || reversedDiagonalWord == reversedWord) {
				count++
			}
		}
	}

	return count
}

const EX_USAGE = 64
const EX_NOINPUT = 66

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <file>\n", os.Args[0])
		os.Exit(EX_USAGE)
	}

	lines, err := ReadLinesFromFile(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading file: %s\n", err)
		os.Exit(EX_NOINPUT)
	}

	xmasCount := FindXmasCount(lines)
	fmt.Printf("Part 1: %v\n", xmasCount)

	xMasCount := FindXMasCount(lines)
	fmt.Printf("Part 2: %v\n", xMasCount)
}
