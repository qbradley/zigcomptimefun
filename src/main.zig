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

const ParseOptions = struct {
    debug: bool = false,
};

const Stack = struct {
    stack: [16]i32,
    top: usize,

    pub fn init() @This() {
        return .{
            .stack = undefined,
            .top = 0,
        };
    }

    pub fn push(self: *@This(), new_value: i32) void {
        const top = self.top;
        self.stack[top] = new_value;
        self.top = top + 1;
    }

    pub fn pop(self: *@This()) i32 {
        self.top -= 1;
        return self.stack[self.top];
    }
};

fn parse(comptime input: []const u8, comptime options: ParseOptions) type {
    return struct {
        const Code = input;
        fn eval(stack: *Stack) void {
            inline for (input, 0..) |c, i| {
                _ = i;

                switch (c) {
                    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' => {
                        stack.push(c - '0');
                    },
                    '+' => {
                        stack.push(stack.pop() + stack.pop());
                    },
                    '*' => {
                        stack.push(stack.pop() * stack.pop());
                    },
                    else => {},
                }

                if (options.debug) {
                    dumpstack(stack.stack[0..stack.top]);
                }
            }
        }
    };
}

pub fn main() !void {
    const parser = parse("2 1 + *", .{});

    var stack = Stack.init();
    stack.push(5);
    parser.eval(&stack);
    const result = stack.pop();

    std.debug.print("Evaluating '{s}'' resulted in: {}\n", .{ parser.Code, result });

    const expression1 = multiply(value(3), add(value(5), value(6)));
    const result1 = expression1.work();
    std.debug.print("Result: {}\n", .{result1});

    const expression2 = multiplier(Value, adder(Value, Value)).init(Value.init(3), adder(Value, Value).init(Value.init(1), Value.init(2)));

    const result2 = expression2.work();
    std.debug.print("Result: {}\n", .{result2});
}

test "simple test" {}

test "use other module" {}

const std = @import("std");
const lib = @import("interp_lib");
