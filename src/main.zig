const Value = struct {
    value: i32,

    fn init(value_: i32) Value {
        return .{ .value = value_ };
    }

    fn work(self: @This()) i32 {
        return self.value;
    }
};

fn multiplier(Left: type, Right: type) type {
    return struct {
        left: Left,
        right: Right,

        fn init(left_val: Left, right_val: Right) @This() {
            return .{ .left = left_val, .right = right_val };
        }

        fn work(self: @This()) i32 {
            return self.left.work() * self.right.work();
        }
    };
}

fn adder(Left: type, Right: type) type {
    return struct {
        left: Left,
        right: Right,

        fn init(left_val: Left, right_val: Right) @This() {
            return .{ .left = left_val, .right = right_val };
        }

        fn work(self: @This()) i32 {
            return self.left.work() + self.right.work();
        }
    };
}

fn value(value_: i32) Value {
    return .{ .value = value_ };
}

fn add(left: anytype, right: anytype) adder(@TypeOf(left), @TypeOf(right)) {
    return adder(@TypeOf(left), @TypeOf(right)).init(left, right);
}

fn multiply(left: anytype, right: anytype) multiplier(@TypeOf(left), @TypeOf(right)) {
    return multiplier(@TypeOf(left), @TypeOf(right)).init(left, right);
}

fn dumpstack(stack: []i32) void {
    std.debug.print("[", .{});
    for (stack) |item| {
        std.debug.print("{},", .{item});
    }
    std.debug.print("]\n", .{});
}

fn parse(comptime input: []const u8) type {
    return struct {
        const Code = input;
        fn eval(start: i32) i32 {
            var stackpointer: usize = 1;
            var stack: [16]i32 = undefined;
            stack[0] = start;
            inline for (input, 0..) |c, i| {
                _ = i;

                switch (c) {
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' => {
                        const result = c - '0';
                        stack[stackpointer] = result;
                        stackpointer += 1;
                    },
                    '+' => {
                        const value1 = stack[stackpointer - 1];
                        const value2 = stack[stackpointer - 2];
                        const result = value1 + value2;
                        stack[stackpointer - 2] = result;
                        stackpointer -= 1;
                    },
                    '*' => {
                        const value1 = stack[stackpointer - 1];
                        const value2 = stack[stackpointer - 2];
                        const result = value1 * value2;
                        stack[stackpointer - 2] = result;
                        stackpointer -= 1;
                    },
                    else => {},
                }

                dumpstack(stack[0..stackpointer]);
            }

            return stack[stackpointer - 1];
        }
    };
}

pub fn main() !void {
    const parser = parse("2 1 + *", .{ .debug = true });
    const expression3 = parser.eval(5);
    std.debug.print("Evaluating '{s}'' resulted in: {}\n", .{ parser.Code, expression3 });

    const expression1 = multiply(value(3), add(value(5), value(6)));
    const result1 = expression1.work();
    std.debug.print("Result: {}\n", .{result1});

    const expression2 = multiplier(Value, adder(Value, Value)).init(Value.init(3), adder(Value, Value).init(Value.init(1), Value.init(2)));

    const result = expression2.work();
    std.debug.print("Result: {}\n", .{result});
}

test "simple test" {}

test "use other module" {}

const std = @import("std");
const lib = @import("interp_lib");
