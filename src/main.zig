const std = @import("std");
const bench = @import("./bench.zig");
const benchmark = bench.benchmark;

fn Gausser(comptime width: usize) type {
    return struct {
        const Row = @Vector(width, f64);
        fn printMatrix(rows: []Row) void {
            for (rows) |row| {
                for (0..width) |i| {
                    std.debug.print("{d} ", .{row[i]});
                }
                std.debug.print("\n", .{});
            }
        }
        // Rewritten from the C# version from https://rosettacode.org/wiki/Reduced_row_echelon_form#C#
        fn gauss(rows: []Row) void {
            var lead: usize = 0;
            const row_count = rows.len;
            const column_count = width;
            for(0..row_count) |r| {
                if (column_count <= lead) {
                    break;
                }
                var i = r;
                while(rows[i][lead] == 0) {
                    i += 1;
                    if (i == row_count) {
                        i = r;
                        lead += 1;
                        if (column_count == lead) {
                            lead -= 1;
                            break;
                        }
                    }
                }
                const temp_row = rows[r];
                rows[r] = rows[i];
                rows[i] = temp_row;

                const div = rows[r][lead];
                if (div != 0) {
                    rows[r] /= @splat(div);
                }
                for (0..row_count) |j| {
                    if (j != r) {
                        const sub = rows[j][lead];
                        for(0..column_count) |k| {
                            rows[j][k] -= (sub * rows[r][k]);
                        }
                    }
                }
                lead += 1;
            }
        }
    };
}

pub fn main() !void {
    const G = Gausser(4);

    std.debug.print("the small matrix:\n", .{});
    var matrix: [3]G.Row = .{
        .{0, 1, 1, 1},
        .{0, 3, 0, 1},
        .{1, 0, 0, 1},
    };
    G.printMatrix(&matrix);
    G.gauss(&matrix);
    G.printMatrix(&matrix);


    std.debug.print("now for the big matrix:\n", .{});
    const input_buf = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, "big_matrix.txt", 2048);
    defer std.heap.page_allocator.free(input_buf);
    var iter = std.mem.tokenizeAny(u8, input_buf, &std.ascii.whitespace);

    var b_matrix: [8]G8.Row = .{
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
    };
    G8.printMatrix(&b_matrix);
    G8.gauss(&b_matrix);
    G8.printMatrix(&b_matrix);
}

const G4 = Gausser(4);
var small_matrix = std.mem.zeroes([3]G4.Row);

fn read_int(it: *std.mem.TokenIterator(u8, .any)) f64 {
    const i = std.fmt.parseInt(i64, it.next().?, 10);
    return @floatFromInt(i catch @panic("malformd int"));
}

test "benchmark small gauss" {
    const input_buf = try std.fs.cwd().readFileAlloc(std.testing.allocator, "small_matrix.txt", 1024);
    defer std.testing.allocator.free(input_buf);
    var iter = std.mem.tokenizeAny(u8, input_buf, &std.ascii.whitespace);

    small_matrix = .{
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
    };

    try benchmark(struct {
        pub const min_iterations = 10000000;
        pub const max_iterations = 10000001;
        pub fn small_gauss() [3]G4.Row {
            var copy_matrix = small_matrix;
            G4.gauss(&copy_matrix);

            return copy_matrix;
        }
    });
}

const G8 = Gausser(8);
var big_matrix = std.mem.zeroes([8]G8.Row);

test "benchmark big gauss" {
    const input_buf = try std.fs.cwd().readFileAlloc(std.testing.allocator, "big_matrix.txt", 2048);
    defer std.testing.allocator.free(input_buf);
    var iter = std.mem.tokenizeAny(u8, input_buf, &std.ascii.whitespace);

    big_matrix = .{
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
    };

    try benchmark(struct {
        pub const min_iterations = 10000000;
        pub const max_iterations = 10000001;
        pub fn big_gauss() [8]G8.Row {
            var copy_matrix = big_matrix;
            G8.gauss(&copy_matrix);
            return copy_matrix;
        }
    });
}


const G16 = Gausser(16);
var bigger_matrix = std.mem.zeroes([8]G16.Row);

test "benchmark bigger gauss" {
    const input_buf = try std.fs.cwd().readFileAlloc(std.testing.allocator, "bigger_matrix.txt", 2048);
    defer std.testing.allocator.free(input_buf);
    var iter = std.mem.tokenizeAny(u8, input_buf, &std.ascii.whitespace);

    bigger_matrix = .{
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
        .{read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter), read_int(&iter) },
    };

    try benchmark(struct {
        pub const min_iterations = 10000000;
        pub const max_iterations = 10000001;
        pub fn bigger_gauss() [8]G16.Row {
            var copy_matrix = bigger_matrix;
            G16.gauss(&copy_matrix);
            return copy_matrix;
        }
    });
}
