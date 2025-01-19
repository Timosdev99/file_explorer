const std = @import("std");

pub const FileExplorer = struct {
    allocator: std.mem.Allocator,
    current_path: []const u8,

    pub fn init(allocator: std.mem.Allocator, initial_path: []const u8) !FileExplorer {
        return FileExplorer{
            .allocator = allocator,
            .current_path = try allocator.dupe(u8, initial_path),
        };
    }

    pub fn deinit(self: *FileExplorer) void {
        self.allocator.free(self.current_path);
    }

    pub fn listDirectory(self: *FileExplorer) !void {
        var dir = try std.fs.openDirAbsolute(self.current_path, .{ .iterate = true });
        defer dir.close();

        var iter = dir.iterate();
        while (try iter.next()) |entry| {
            switch (entry.kind) {
                .file => std.debug.print("FILE: {s}\n", .{entry.name}),
                .directory => std.debug.print("DIR:  {s}\n", .{entry.name}),
                .sym_link => std.debug.print("LINK: {s}\n", .{entry.name}),
                else => std.debug.print("OTHER: {s}\n", .{entry.name}),
            }
        }
    }

    // pub fn changeDirectory(self: *FileExplorer, new_path: []const u8) !void {
    //     const new_absolute_path = if (std.fs.path.isAbsolute(new_path))
    //         try self.allocator.dupe(u8, new_path)
    //     else
    //         try std.fs.path.join(self.allocator, &[_][]const u8{ self.current_path, new_path });

    //     // Use errdefer to free the new path if anything fails after this point
    //     errdefer self.allocator.free(new_absolute_path);

    //     // Try to open the directory to verify it exists
    //     if (std.fs.openDirAbsolute(new_absolute_path, .{})) |dir| {
    //         defer dir.close();
    //         // Only free the old path after we're sure the new path is valid
    //         self.allocator.free(self.current_path);
    //         self.current_path = new_absolute_path;
    //     } else |err| {
    //         return err;
    //     }
    // }

    pub fn getFileInfo(self: *FileExplorer, filename: []const u8) !void {
        const file_path = try std.fs.path.join(self.allocator, &[_][]const u8{ self.current_path, filename });
        defer self.allocator.free(file_path);

        const file = try std.fs.openFileAbsolute(file_path, .{});
        defer file.close();

        const stat = try file.stat();
        std.debug.print("File: {s}\nSize: {d} bytes\nModified: {}\n", .{
            filename,
            stat.size,
            stat.mtime,
        });
    }
};
