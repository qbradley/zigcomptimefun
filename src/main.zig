
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

fn parse(input: []const u8) i32 {
}

pub fn main() !void {

    let expression3 = parse("+ * 3 2 1");

    const expression1 = multiply(value(3), add(value(5), value(6)));
    const result1 = expression1.work();
    std.debug.print("Result: {}\n", .{result1});
 
    const expression2 = multiplier(Value, adder(Value, Value)).init(Value.init(3), adder(Value, Value).init(Value.init(1), Value.init(2)));

    const result = expression2.work();
    std.debug.print("Result: {}\n", .{result});
}

test "simple test" {
}

test "use other module" {
}

const std = @import("std");
const lib = @import("interp_lib");
