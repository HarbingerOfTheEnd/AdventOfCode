use std::{env::args, error::Error, fs::read_to_string, process::exit};

const EX_USAGE: i32 = 64;

fn main() -> Result<(), Box<dyn Error>> {
    let mut args = args();
    if args.len() != 2 {
        eprintln!("Usage: {} <file>", args.next().unwrap());
        exit(EX_USAGE);
    }

    let input_file = args.skip(1).next().unwrap();
    let lines = read_to_string(input_file)?
        .lines()
        .map(|line| line.to_owned())
        .collect::<Vec<_>>();
    let mut filtered_list = vec![];

    filter_test_results(lines.clone(), &mut filtered_list, false);
    let sum = filtered_list.iter().sum::<u64>();
    println!("Part 1 Result: {sum}");

    filtered_list.clear();

    filter_test_results(lines, &mut filtered_list, true);
    let sum = filtered_list.iter().sum::<u64>();
    println!("Part 2 Result: {sum}");

    Ok(())
}

fn filter_test_results(lines: Vec<String>, filtered_list: &mut Vec<u64>, part2: bool) {
    for line in lines {
        let (test_result, operands) = parse_line(&line);
        let mut operations = vec![];
        generate_operation_combinations(&mut operations, operands.len() - 1, part2);

        if correct_test_result(test_result, &operands, &operations, part2) {
            filtered_list.push(test_result);
        }
    }
}

fn correct_test_result(
    test_result: u64,
    operands: &Vec<u64>,
    operations: &[Vec<&'static str>],
    part2: bool,
) -> bool {
    for operation in operations {
        let mut operands = operands.clone();
        let mut total = operands.remove(0);

        for operator in operation {
            if *operator == "+" {
                total += operands.remove(0);
            } else if *operator == "*" {
                total *= operands.remove(0);
            } else if part2 && *operator == "||" {
                let mut new_total = total.to_string();
                new_total.push_str(operands.remove(0).to_string().as_str());
                total = new_total.parse().unwrap();
            }
        }

        if total == test_result {
            return true;
        }
    }

    false
}

fn generate_operation_combinations(
    operations: &mut Vec<Vec<&'static str>>,
    combination_size: usize,
    part2: bool,
) {
    let mut combinations = vec![""; combination_size];
    generate_combinations(operations, &mut combinations, 0, part2);
}

fn generate_combinations(
    operations: &mut Vec<Vec<&'static str>>,
    combinations: &mut Vec<&'static str>,
    i: usize,
    part2: bool,
) {
    if i == combinations.len() {
        operations.push(combinations.clone());
        return;
    }

    combinations[i] = "+";
    generate_combinations(operations, combinations, i + 1, part2);

    combinations[i] = "*";
    generate_combinations(operations, combinations, i + 1, part2);

    if part2 {
        combinations[i] = "||";
        generate_combinations(operations, combinations, i + 1, part2);
    }
}

fn parse_line(line: &str) -> (u64, Vec<u64>) {
    let parts = line.split(':').map(|line| line.trim()).collect::<Vec<_>>();
    let test_result = parts[0].parse().unwrap();
    let operands = parts[1]
        .split_whitespace()
        .map(|part| part.parse().unwrap())
        .collect::<Vec<_>>();

    (test_result, operands)
}
