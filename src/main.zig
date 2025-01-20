const std = @import("std");
const FileExplorer = @import("file_explorer.zig").FileExplorer;

pub fn main() !void {
    // Initialize general-purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Get current directory as starting point
    const current_dir = try std.fs.cwd().realpathAlloc(allocator, ".");
    defer allocator.free(current_dir);

    // Initialize file explorer
    var explorer = try FileExplorer.init(allocator, current_dir);
    defer explorer.deinit();

    // List current directory contents
    std.debug.print("\nListing directory contents:\n", .{});
    try explorer.listDirectory();

    // Try to get info about a specific file
    std.debug.print("\nGetting file info for 'file':\n", .{});
    explorer.getFileInfo(current_dir) catch |err| {
        std.debug.print("Error getting file info: {}\n", .{err});
    };
}
