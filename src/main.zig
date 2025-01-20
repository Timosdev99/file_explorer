const std = @import("std");
const FileExplorer = @import("file_explorer.zig").FileExplorer;

pub fn main() !void {
    // Initialize general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Get current directory as starting point

    var buf: [std.fs.max_path_bytes]u8 = undefined;
    const current_dir = try std.os.getcwd(&buf);

    // Initialize file explorer
    var explorer = try FileExplorer.init(allocator, current_dir);
    defer explorer.deinit();

    // List current directory contents
    std.debug.print("\nListing directory contents:\n", .{});
    try explorer.listDirectory();

    // Try to get info about a specific file
    std.debug.print("\nGetting file info for 'file_explorer.zig':\n", .{});
    explorer.getFileInfo("file_explorer.zig") catch |err| {
        std.debug.print("Error getting file info: {}\n", .{err});
    };
}
