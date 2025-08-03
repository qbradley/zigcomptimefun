const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const mecha = @import("mecha");


fn unpack_bin(f: fn(type, type) type) fn(struct {type, type}) type {
  return struct { fn unpack_f(ab: struct {type, type}) type {
    return f(ab[0], ab[1]);
  } }.unpack_f;
}

fn meta(env_t: type) type {
  return struct {
    fn imm(v: i64) type {
      return struct {
        pub inline fn work(_: *env_t) i64 { return v; }
      };
    }
    fn param(name: []const u8) type {
      return struct {
        pub inline fn work(e: *env_t) i64 { return @field(e, name); }
      };
    }

    fn add(a: type, b: type) type {
      return struct {
        pub inline fn work(e: *env_t) i64 { return a.work(e) + b.work(e); }
      };
    }
    fn mul(a: type, b: type) type {
      return struct {
        pub inline fn work(e: *env_t) i64 { return a.work(e) * b.work(e); }
      };
    }

    const addu = unpack_bin(add);
    const mulu = unpack_bin(mul);
  };
}

const id = mecha.combine(.{
  mecha.oneOf(.{
    mecha.ascii.alphabetic.discard(), mecha.ascii.char('_').discard(),
  }),
  mecha.many(mecha.oneOf(.{
    mecha.ascii.alphabetic.discard(), mecha.ascii.char('_').discard(),
    mecha.ascii.digit(10).discard(),
  }), .{.collect = false}).discard(),
}).asStr();

pub fn parse(env_t: type, s: []const u8) !type {
  const m = meta(env_t);
  const atom = mecha.oneOf(.{
    id.map(m.param),
    mecha.int(i64, .{.parse_sign = false}).map(m.imm),
  });
  const expr = mecha.oneOf(.{
    mecha.combine(.{atom, mecha.ascii.char('+').discard(), atom}).map(m.addu),
    mecha.combine(.{atom, mecha.ascii.char('*').discard(), atom}).map(m.mulu),
  });

  const r = try expr.parse(undefined, s);
  return switch (r.value) {
    .ok => |v| v,
    .err => @compileError("parse error"),
  };
}

pub export fn codegen_test(x: i64, y: i64) i64 {
  const env_t = struct {x: i64, y: i64};
  const m = meta(env_t);

  const xp = m.param("x");
  const yp = m.param("y");
  // x + x * y * (y + x * 42) + x * (y + y) + 99
  const e = m.add(m.add(
    m.add(xp,m.mul(m.mul(xp,yp),m.add(yp,m.mul(xp,m.imm(42))))),
    m.mul(xp,m.add(yp,yp))
  ),m.imm(99));

  var env: env_t = .{.x = x, .y = y};
  return e.work(&env);
}


test "parse" {
  const test_env_t = struct { xx2: i64, _999_y: i64 };

  comptime {
    const e0 = try parse(test_env_t, "_999_y+3");
    var env0: test_env_t = .{.xx2 = 5, ._999_y = 7};
    try testing.expectEqual(e0.work(&env0), 10);
  }

  const e1 = comptime try parse(test_env_t, "2*xx2");
  var env1: test_env_t = .{.xx2 = 5, ._999_y = 7};
  try testing.expectEqual(e1.work(&env1), 10);
}
