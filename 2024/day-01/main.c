#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __unix__
#include <sysexits.h>
#else
#define EX_USAGE 64
#define EX_NOINPUT 66
#endif

size_t getlines(FILE *fp) {
    size_t n_lines = 0;

    for (int c = fgetc(fp); c != EOF; c = fgetc(fp)) n_lines += (c == '\n');

    fseek(fp, 0, SEEK_SET);
    return n_lines;
}

int compare(const void *a, const void *b) {
    return *(int32_t *)a - *(int32_t *)b;
}

int64_t find_total_distance(int32_t *left, int32_t *right, size_t n_lines) {
    int64_t total_distance = 0;

    for (size_t i = 0; i < n_lines; i++)
        total_distance += abs(left[i] - right[i]);

    return total_distance;
}

int64_t find_n_same_numbers(int32_t *array, int32_t value, size_t n_lines) {
    int64_t n = 0;

    for (size_t i = 0; i < n_lines; i++)
        if (array[i] == value) n++;

    return n;
}

int64_t find_total_similarity_score(int32_t *left, int32_t *right,
                                    size_t n_lines) {
    int64_t total_similarity_score = 0;

    for (size_t i = 0; i < n_lines; i++)
        total_similarity_score +=
            left[i] * find_n_same_numbers(right, left[i], n_lines);

    return total_similarity_score;
}

int main(const int argc, const char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input>\n", argv[0]);
        return EX_USAGE;
    }

    FILE *fp = fopen(argv[1], "r");
    if (fp == NULL) {
        perror("fopen");
        return EX_NOINPUT;
    }

    size_t n_lines = getlines(fp);

    int32_t *left = (int32_t *)calloc(n_lines, sizeof(int32_t));
    if (left == NULL) {
        perror("calloc");
        return EX_OSERR;
    }

    int32_t *right = (int32_t *)calloc(n_lines, sizeof(int32_t));
    if (right == NULL) {
        perror("calloc");
        free(left);
        return EX_OSERR;
    }

    for (size_t i = 0; i < n_lines; i++)
        fscanf(fp, "%d   %d", left + i, right + i);

    qsort(left, n_lines, sizeof(int32_t), compare);
    qsort(right, n_lines, sizeof(int32_t), compare);

    int64_t total_distance = find_total_distance(left, right, n_lines);
    printf("Part 1: %ld\n", total_distance);

    int64_t total_similarity_score =
        find_total_similarity_score(left, right, n_lines);
    printf("Part 2: %ld\n", total_similarity_score);

    free(left);
    free(right);
    fclose(fp);
    return EXIT_SUCCESS;
}
