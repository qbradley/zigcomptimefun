//! By convention, root.zig is the root source file when making a library. If
//! you are making an executable, the convention is to delete this file and
//! start with main.zig instead.
const std = @import("std");
const testing = std.testing;
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

test "Example" {
    const expression1 = multiply(value(3), add(value(5), value(6)));
    const result1 = expression1.work();
    std.debug.print("Result: {}\n", .{result1});

    const expression2 = multiplier(Value, adder(Value, Value)).init(Value.init(3), adder(Value, Value).init(Value.init(1), Value.init(2)));

    const result2 = expression2.work();
    std.debug.print("Result: {}\n", .{result2});
}
