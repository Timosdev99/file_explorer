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

        // List name in dir
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

    pub fn changeDirectory(self: *FileExplorer, new_path: []const u8) !void {
        // Determine the new absolute path
        const new_absolute_path = if (std.fs.path.isAbsolute(new_path))
            try self.allocator.dupe(u8, new_path)
        else blk: {
            const joined_path = try std.fs.path.join(self.allocator, &[_][]const u8{ self.current_path, new_path });
            defer self.allocator.free(joined_path);
            break :blk try self.allocator.dupe(u8, joined_path);
        };

        // Free allocated memory on exit (error or not)
        errdefer self.allocator.free(new_absolute_path);

        // Attempt to open the directory at the new absolute path
        var open_dir = try std.fs.openDirAbsolute(new_absolute_path, .{ .iterate = false });

        // Close the directory once validated
        open_dir.close();

        // Free the previous current_path and update to the new path
        self.allocator.free(self.current_path);
        self.current_path = new_absolute_path;
        //Show current path
        std.debug.print("Current path: .{s}\n", .{self.current_path});
    }

    pub fn getFileInfo(self: *FileExplorer, filename: []const u8) !void {
        // Get filename
        const file_path = try std.fs.path.join(self.allocator, &[_][]const u8{ self.current_path, filename });
        // Freee memory allocated to path
        defer self.allocator.free(file_path);

        // Open file
        const file = try std.fs.openFileAbsolute(file_path, .{});
        // Close file
        defer file.close();

        // Get file metadata
        const stat = try file.stat();
        std.debug.print("File: {s}\nSize: {d} bytes\nModified: {}\n", .{
            filename,
            stat.size,
            stat.mtime,
        });
    }
};
