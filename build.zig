const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "my-opus-program",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();

    exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/include" }); // Homebrew include path
    exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" }); //
    exe.linkSystemLibrary("opus");
    //
    // Add Homebrew include path
    // exe.addIncludePath(.{ .path = "/opt/homebrew/Cellar/libopusenc/0.2.1/include" });

    // Link the library
    // exe.linkSystemLibrary("libpng");

    // Link libc
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
