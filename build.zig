const std = @import("std");
const Builder = std.build.Builder;

const version = "0.0.0-dev";

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("rubik", "src/rubik.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    exe.addBuildOption(std.SemanticVersion, "rubik_version", std.SemanticVersion.parse(version) catch unreachable);

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const tests = b.addTest("src/rubik.zig");
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&tests.step);
}
