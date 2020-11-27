const std = @import("std");
const expect = std.testing.expect;
const assert = std.debug.assert;

pub const Color = packed enum(u8) {
    white,
    red,
    blue,
    orange,
    green,
    yellow,

    pub fn toStr(self: Color) []const u8 {
        return switch (self) {
            .white => "\x1B[37mw\x1B[m",
            .red => "\x1B[91mr\x1B[m",
            .blue => "\x1B[94mb\x1B[m",
            .orange => "\x1B[38;5;208mo\x1B[m",
            .green => "\x1B[32mg\x1B[m",
            .yellow => "\x1B[93my\x1B[m",
        };
    }
};

pub const Cube = packed struct {
    u: [8]Color = [_]Color{.white} ** 8,
    l: [8]Color = [_]Color{.red} ** 8,
    f: [8]Color = [_]Color{.blue} ** 8,
    r: [8]Color = [_]Color{.orange} ** 8,
    b: [8]Color = [_]Color{.green} ** 8,
    d: [8]Color = [_]Color{.yellow} ** 8,

    pub fn format(
        self: Cube,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        // up
        try writer.print(
            \\      +-+-+-+
            \\      |{s}|{s}|{s}|
            \\
        , .{ self.u[0].toStr(), self.u[1].toStr(), self.u[2].toStr() });
        try writer.print(
            \\      +-+-+-+
            \\      |{s}|{s}|{s}|
            \\
        , .{ self.u[7].toStr(), Color.white.toStr(), self.u[3].toStr() });
        try writer.print(
            \\      +-+-+-+
            \\      |{s}|{s}|{s}|
            \\
        , .{ self.u[6].toStr(), self.u[5].toStr(), self.u[4].toStr() });

        // left - front - right
        try writer.print(
            \\+-+-+-+-+-+-+-+-+-+
            \\|{s}|{s}|{s}|{s}|{s}|{s}|{s}|{s}|{s}|
            \\
        , .{
            self.l[0].toStr(), self.l[1].toStr(), self.l[2].toStr(),
            self.f[0].toStr(), self.f[1].toStr(), self.f[2].toStr(),
            self.r[0].toStr(), self.r[1].toStr(), self.r[2].toStr(),
        });
        try writer.print(
            \\+-+-+-+-+-+-+-+-+-+
            \\|{s}|{s}|{s}|{s}|{s}|{s}|{s}|{s}|{s}|
            \\
        , .{
            self.l[7].toStr(), Color.red.toStr(),    self.l[3].toStr(),
            self.f[7].toStr(), Color.blue.toStr(),   self.f[3].toStr(),
            self.r[7].toStr(), Color.orange.toStr(), self.r[3].toStr(),
        });
        try writer.print(
            \\+-+-+-+-+-+-+-+-+-+
            \\|{s}|{s}|{s}|{s}|{s}|{s}|{s}|{s}|{s}|
            \\
        , .{
            self.l[6].toStr(), self.l[5].toStr(), self.l[4].toStr(),
            self.f[6].toStr(), self.f[5].toStr(), self.f[4].toStr(),
            self.r[6].toStr(), self.r[5].toStr(), self.r[4].toStr(),
        });

        // down
        try writer.print(
            \\+-+-+-+-+-+-+-+-+-+
            \\      |{s}|{s}|{s}|
            \\
        , .{ self.d[0].toStr(), self.d[1].toStr(), self.d[2].toStr() });
        try writer.print(
            \\      +-+-+-+
            \\      |{s}|{s}|{s}|
            \\
        , .{ self.d[7].toStr(), Color.yellow.toStr(), self.d[3].toStr() });
        try writer.print(
            \\      +-+-+-+
            \\      |{s}|{s}|{s}|
            \\
        , .{ self.d[6].toStr(), self.d[5].toStr(), self.d[4].toStr() });

        // back
        try writer.print(
            \\      +-+-+-+
            \\      |{s}|{s}|{s}|
            \\
        , .{ self.b[4].toStr(), self.b[5].toStr(), self.b[6].toStr() });
        try writer.print(
            \\      +-+-+-+
            \\      |{s}|{s}|{s}|
            \\
        , .{ self.b[3].toStr(), Color.green.toStr(), self.b[7].toStr() });
        try writer.print(
            \\      +-+-+-+
            \\      |{s}|{s}|{s}|
            \\      +-+-+-+
            \\
        , .{ self.b[2].toStr(), self.b[1].toStr(), self.b[0].toStr() });
    }

    pub fn eql(a: Cube, b: Cube) bool {
        return (@as(u8, @boolToInt(@bitCast(u64, a.u) == @bitCast(u64, b.u))) +
            @boolToInt(@bitCast(u64, a.l) == @bitCast(u64, b.l)) +
            @boolToInt(@bitCast(u64, a.f) == @bitCast(u64, b.f)) +
            @boolToInt(@bitCast(u64, a.r) == @bitCast(u64, b.r)) +
            @boolToInt(@bitCast(u64, a.b) == @bitCast(u64, b.b)) +
            @boolToInt(@bitCast(u64, a.d) == @bitCast(u64, b.d))) == 6;
    }

    pub fn isSolved(self: Cube) bool {
        return self.eql(.{});
    }

    pub fn rotU(self: *Cube) void {
        self.u = @bitCast([8]Color, std.math.rotl(u64, @bitCast(u64, self.u), 2 * 8));
        // sides
        const tmp: [3]Color = self.r[0..3].*;
        self.r[0..3].* = self.b[0..3].*;
        self.b[0..3].* = self.l[0..3].*;
        self.l[0..3].* = self.f[0..3].*;
        self.f[0..3].* = tmp;
    }

    pub fn rotUPrime(self: *Cube) void {
        self.u = @bitCast([8]Color, std.math.rotr(u64, @bitCast(u64, self.u), 2 * 8));
        // sides
        const tmp: [3]Color = self.r[0..3].*;
        self.r[0..3].* = self.f[0..3].*;
        self.f[0..3].* = self.l[0..3].*;
        self.l[0..3].* = self.b[0..3].*;
        self.b[0..3].* = tmp;
    }

    pub fn rotL(self: *Cube) void {
        self.l = @bitCast([8]Color, std.math.rotl(u64, @bitCast(u64, self.l), 2 * 8));

        // faces
        const tmp: [3]Color = self.b[2..5].*;
        self.b[2..4].* = self.d[6..8].*;
        self.b[4] = self.d[0];

        self.d[6..8].* = self.f[6..8].*;
        self.d[0] = self.f[0];

        self.f[6..8].* = self.u[6..8].*;
        self.f[0] = self.u[0];
        
        self.u[6..8].* = tmp[0..2].*;
        self.u[0] = tmp[2];
    }

    pub fn rotLPrime(self: *Cube) void {
        self.l = @bitCast([8]Color, std.math.rotr(u64, @bitCast(u64, self.l), 2 * 8));

        // faces
        const tmp: [3]Color = self.b[2..5].*;
        self.b[2..4].* = self.u[6..8].*;
        self.b[4] = self.u[0];

        self.u[6..8].* = self.f[6..8].*;
        self.u[0] = self.f[0];

        self.f[6..8].* = self.d[6..8].*;
        self.f[0] = self.d[0];
        
        self.d[6..8].* = tmp[0..2].*;
        self.d[0] = tmp[2];
    }

    pub fn rotF(self: *Cube) void {
        self.f = @bitCast([8]Color, std.math.rotl(u64, @bitCast(u64, self.f), 2 * 8));

        // faces
        const tmp: [3]Color = self.l[2..5].*;
        self.l[2..5].* = self.d[0..3].*;

        self.d[0..2].* = self.r[6..8].*;
        self.d[2] = self.r[0];

        self.r[6..8].* = self.u[4..6].*;
        self.r[0] = self.u[6];
        
        self.u[4..7].* = tmp;
    }

    pub fn rotFPrime(self: *Cube) void {
        self.f = @bitCast([8]Color, std.math.rotr(u64, @bitCast(u64, self.f), 2 * 8));

        // faces
        const tmp: [3]Color = self.l[2..5].*;
        self.l[2..5].* = self.u[4..7].*;

        self.u[4..6].* = self.r[6..8].*;
        self.u[6] = self.r[0];

        self.r[6..8].* = self.d[0..2].*;
        self.r[0] = self.d[2];
        
        self.d[0..3].* = tmp;
    }

    pub fn rotR(self: *Cube) void {
        self.r = @bitCast([8]Color, std.math.rotl(u64, @bitCast(u64, self.r), 2 * 8));

        // faces
        const tmp: [3]Color = self.f[2..5].*;
        self.f[2..5].* = self.d[2..5].*;

        self.d[2..4].* = self.b[6..8].*;
        self.d[4] = self.b[0];

        self.b[6..8].* = self.u[2..4].*;
        self.b[0] = self.u[4];
        
        self.u[2..5].* = tmp;
    }

    pub fn rotRPrime(self: *Cube) void {
        self.r = @bitCast([8]Color, std.math.rotr(u64, @bitCast(u64, self.r), 2 * 8));

        // faces
        const tmp: [3]Color = self.f[2..5].*;
        self.f[2..5].* = self.u[2..5].*;

        self.u[2..4].* = self.b[6..8].*;
        self.u[4] = self.b[0];

        self.b[6..8].* = self.d[2..4].*;
        self.b[0] = self.d[4];
        
        self.d[2..5].* = tmp;
    }

    pub fn rotB(self: *Cube) void {
        self.b = @bitCast([8]Color, std.math.rotl(u64, @bitCast(u64, self.b), 2 * 8));

        // faces
        const tmp: [3]Color = self.r[2..5].*;
        self.r[2..5].* = self.d[4..7].*;

        self.d[4..6].* = self.l[6..8].*;
        self.d[6] = self.l[0];

        self.l[6..8].* = self.u[0..2].*;
        self.l[0] = self.u[2];
        
        self.u[0..3].* = tmp;
    }

    pub fn rotBPrime(self: *Cube) void {
        self.b = @bitCast([8]Color, std.math.rotr(u64, @bitCast(u64, self.b), 2 * 8));

        // faces
        const tmp: [3]Color = self.r[2..5].*;
        self.r[2..5].* = self.u[0..3].*;

        self.u[0..2].* = self.l[6..8].*;
        self.u[2] = self.l[0];

        self.l[6..8].* = self.d[4..6].*;
        self.l[0] = self.d[6];
        
        self.d[4..7].* = tmp;
    }

    pub fn rotD(self: *Cube) void {
        self.d = @bitCast([8]Color, std.math.rotl(u64, @bitCast(u64, self.d), 2 * 8));
        // sides
        const tmp: [3]Color = self.r[4..7].*;
        self.r[4..7].* = self.f[4..7].*;
        self.f[4..7].* = self.l[4..7].*;
        self.l[4..7].* = self.b[4..7].*;
        self.b[4..7].* = tmp;
    }

    pub fn rotDPrime(self: *Cube) void {
        self.d = @bitCast([8]Color, std.math.rotr(u64, @bitCast(u64, self.d), 2 * 8));
        // sides
        const tmp: [3]Color = self.r[4..7].*;
        self.r[4..7].* = self.b[4..7].*;
        self.b[4..7].* = self.l[4..7].*;
        self.l[4..7].* = self.f[4..7].*;
        self.f[4..7].* = tmp;
    }
};

test "isSolved" {
    var c: Cube = .{};
    expect(c.isSolved());
    c.rotU();
    expect(!c.isSolved());
    c.rotU();
    c.rotU();
    c.rotU();
    expect(c.isSolved());
}

test "cross" {
    var clockwise: Cube = .{};
    clockwise.rotU();
    clockwise.rotU();
    clockwise.rotD();
    clockwise.rotD();
    clockwise.rotL();
    clockwise.rotL();
    clockwise.rotR();
    clockwise.rotR();
    clockwise.rotF();
    clockwise.rotF();
    clockwise.rotB();
    clockwise.rotB();

    var counterclockwise: Cube = .{};
    counterclockwise.rotUPrime();
    counterclockwise.rotUPrime();
    counterclockwise.rotDPrime();
    counterclockwise.rotDPrime();
    counterclockwise.rotLPrime();
    counterclockwise.rotLPrime();
    counterclockwise.rotRPrime();
    counterclockwise.rotRPrime();
    counterclockwise.rotFPrime();
    counterclockwise.rotFPrime();
    counterclockwise.rotBPrime();
    counterclockwise.rotBPrime();

    expect(clockwise.eql(counterclockwise));
}
