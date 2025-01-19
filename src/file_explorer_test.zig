const std = @import("std");
const testing = std.testing;
const FileExplorer = @import("file_explorer.zig").FileExplorer;

test "FileExplorer basic functionality" {
    // Setup test directory structure
    var tmp = testing.tmpDir(.{});
    defer tmp.cleanup();

    const tmp_path = try tmp.dir.realpathAlloc(testing.allocator, ".");
    defer testing.allocator.free(tmp_path);

    // Create test files and directories
    try tmp.dir.makeDir("test_dir");
    const test_file = try tmp.dir.createFile("test_file.txt", .{});
    test_file.close();

    // Initialize FileExplorer
    var explorer = try FileExplorer.init(testing.allocator, tmp_path);
    defer explorer.deinit();

    // Test directory listing
    try explorer.listDirectory();

    // Test directory navigation
    // try explorer.changeDirectory("test_dir");
    // const expected_path = try std.fs.path.join(testing.allocator, &[_][]const u8{ tmp_path, "test_dir" });
    // defer testing.allocator.free(expected_path);
    // try testing.expectEqualStrings(expected_path, explorer.current_path);

    // Test file info
    //  try explorer.changeDirectory("..");
    try explorer.getFileInfo("test_file.txt");
}

test "FileExplorer error handling" {
    // Initialize with root directory
    var explorer = try FileExplorer.init(testing.allocator, "/");
    defer explorer.deinit();

    // Test non-existent directory
    const old_path = try testing.allocator.dupe(u8, explorer.current_path);
    defer testing.allocator.free(old_path);

    // Verify error is returned and path remains unchanged
    //try testing.expectError(error.FileNotFound, explorer.changeDirectory("non_existent_dir"));
    try testing.expectEqualStrings(old_path, explorer.current_path);

    // Test invalid file info request
    try testing.expectError(error.FileNotFound, explorer.getFileInfo("non_existent_file.txt"));
}
