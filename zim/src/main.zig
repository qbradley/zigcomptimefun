const std = @import("std");
const lib = @import("zim_lib");


pub fn main() !void {
  var args: std.process.ArgIterator = std.process.args();
  _ = args.next();
  const a = try std.fmt.parseInt(i64, args.next() orelse "0", 10);
  const b = try std.fmt.parseInt(i64, args.next() orelse "0", 10);

  const env_t = struct {a: i64, b: i64};
  const src = "a*6";
  const e = comptime try lib.parse(env_t, src);

  var env: env_t = .{.a = a, .b = b};
  const r = e.work(&env);

  std.debug.print("[ " ++ src ++ " ] -> {d}\n", .{r});
  std.debug.print("codegen_test(a,b) -> {d}\n", .{lib.codegen_test(a,b)});
}
