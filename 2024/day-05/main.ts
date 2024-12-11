#!/usr/bin/env -S deno run --allow-read

type FilterFunc = (value: number[]) => boolean;

const EX_USAGE = 64;

function parse(
    fileContents: string,
): [Array<[number, number]>, Array<Array<number>>] {
    const [rulesPart, updatesPart] = fileContents.split("\n\n");
    const orderingRules = rulesPart
        .trim()
        .split("\n")
        .map((line) =>
            line.trim().split("|").map((value) => Number.parseInt(value))
        ) as Array<[number, number]>;
    const updates = updatesPart
        .trim()
        .split("\n")
        .map((line) =>
            line.trim().split(",").map((value) => Number.parseInt(value))
        );

    return [orderingRules, updates] as const;
}

function filterCorrectUpdates(
    orderingRules: Array<[number, number]>,
): FilterFunc {
    return (update) => {
        for (const [i, page] of update.entries()) {
            const pageRules = orderingRules.filter((rule) => page === rule[0]);

            for (const rule of pageRules) {
                for (const [j, otherPage] of update.entries()) {
                    if (page === otherPage) {
                        continue;
                    }

                    if (rule[1] === otherPage && j < i) {
                        return false;
                    }
                }
            }
        }

        return true;
    };
}

function rectify(
    currentPage: Array<number>,
    orderingRules: Array<[number, number]>,
): Array<number> {
    for (const currentNumber of currentPage) {
        const pageRules = orderingRules.filter((rule) =>
            rule[0] === currentNumber
        );

        for (const currentRule of pageRules) {
            if (currentPage.includes(currentRule[1])) {
                const ruleIndex = currentPage.indexOf(currentRule[1]);
                const currentPageIndex = currentPage.indexOf(currentRule[0]);

                if (currentPageIndex > ruleIndex) {
                    currentPage.splice(currentPageIndex, 1);
                    currentPage.splice(ruleIndex, 0, currentRule[0]);
                }
            }
        }
    }

    return currentPage;
}

function main(args: Array<string>): void {
    if (args.length !== 1) {
        console.error(
            "Usage: deno run --allow-read 2024/day-05/main.ts <file>",
        );
        Deno.exit(EX_USAGE);
    }

    const fileContents = Deno.readTextFileSync(args[0]);
    const [orderingRules, updates] = parse(fileContents);
    const correctUpdates = updates.filter(filterCorrectUpdates(orderingRules));
    const incorrectUpdates = updates.filter((value) =>
        !filterCorrectUpdates(orderingRules)(value)
    );

    const uncorrectedMiddlePageSum = correctUpdates
        .map((update) => update[Math.floor(update.length / 2)])
        .reduce((acc, value) => acc + value, 0);

    console.log(`Part 1: ${uncorrectedMiddlePageSum}`);
    const correctedMiddlePageSum = incorrectUpdates
        .map((update) => rectify(update, orderingRules))
        .map((update) => update[Math.floor(update.length / 2)])
        .reduce((acc, value) => acc + value, 0);
    console.log(`Part 2: ${correctedMiddlePageSum}`);
}

if (import.meta.main) {
    main(Deno.args);
}
