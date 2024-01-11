const std = @import("std");
const args = @import("args.zig");
const x11_color = @import("../terminal/main.zig").x11_color;

pub const Options = struct {
    pub fn deinit(self: Options) void {
        _ = self;
    }
};

/// The "list-colors" command is used to list all the named RGB colors in
/// Ghostty.
pub fn run(alloc: std.mem.Allocator) !u8 {
    var opts: Options = .{};
    defer opts.deinit();

    {
        var iter = try std.process.argsWithAllocator(alloc);
        defer iter.deinit();
        try args.parse(Options, alloc, &opts, &iter);
    }

    const stdout = std.io.getStdOut().writer();

    var keys = std.ArrayList([]const u8).init(alloc);
    defer keys.deinit();
    for (x11_color.map.kvs) |kv| try keys.append(kv.key);

    std.mem.sortUnstable([]const u8, keys.items, {}, struct {
        fn lessThan(_: void, lhs: []const u8, rhs: []const u8) bool {
            return std.ascii.orderIgnoreCase(lhs, rhs) == .lt;
        }
    }.lessThan);

    for (keys.items) |name| {
        const rgb = x11_color.map.get(name).?;
        try stdout.print("{s} = #{x:0>2}{x:0>2}{x:0>2}\n", .{
            name,
            rgb.r,
            rgb.g,
            rgb.b,
        });
    }

    return 0;
}