const std = @import("std");

const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;
const File = std.fs.File;
const cwd = std.fs.cwd;
const getStdOut = std.io.getStdOut;
const getStdErr = std.io.getStdErr;
const ArenaAllocator = std.heap.ArenaAllocator;
const page_allocator = std.heap.page_allocator;
const Allocator = std.mem.Allocator;
const splitScalar = std.mem.splitScalar;
const trim = std.mem.trim;
const argsAlloc = std.process.argsAlloc;
const argsFree = std.process.argsFree;
const exit = std.process.exit;

const EX_USAGE = 64;

pub fn main() !void {
    var arena = ArenaAllocator.init(page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const argv = try argsAlloc(allocator);
    defer argsFree(allocator, argv);

    const stdout = getStdOut().writer();
    const stderr = getStdErr().writer();

    if (argv.len != 2) {
        try stderr.print("Usage: {s} <file>\n", .{argv[0]});
        exit(EX_USAGE);
        return error.Usage;
    }

    const safe_report_count = try find_safe_report_count(allocator, argv[1]);
    try stdout.print("Part 1: {}\n", .{safe_report_count});
}

fn find_safe_report_count(allocator: Allocator, filename: [:0]const u8) !u64 {
    // const stdout = getStdOut().writer();
    const file = try cwd().openFileZ(filename, .{ .mode = .read_only });
    defer file.close();

    const file_size = try find_file_size(file);

    const input = trim(
        u8,
        try file.reader().readAllAlloc(allocator, file_size),
        "\n",
    );
    defer allocator.free(input);

    var safe_report_count = @as(u64, 0);
    var lines = splitScalar(u8, input, '\n');

    while (lines.next()) |line| {
        var levels = ArrayList(i32).init(allocator);
        defer levels.deinit();

        var level_parts = splitScalar(u8, line, ' ');

        while (level_parts.next()) |level|
            try levels.append(try parseInt(i32, level, 10));

        var safe = isSafe(levels.items);

        if (!safe) {
            for (0..levels.items.len) |i| {
                const temp = levels.orderedRemove(i);
                safe = isSafe(levels.items);
                if (safe)
                    break;

                try levels.insert(i, temp);
            }
        }

        if (safe)
            safe_report_count += 1;
    }

    return safe_report_count;
}

fn isSafe(levels: []const i32) bool {
    var is_increasing = false;
    var is_decreasing = false;

    for (0..levels.len - 1) |i| {
        const difference = levels[i] - levels[i + 1];

        if (difference > 0)
            is_increasing = true;
        if (difference < 0)
            is_decreasing = true;

        if (is_increasing and is_decreasing or !(0 < @abs(difference) and @abs(difference) <= 3))
            return false;
    }

    return true;
}

fn find_file_size(file: File) !usize {
    const file_size = @as(usize, try file.seekableStream().getEndPos());
    try file.seekTo(0);
    return file_size;
}
