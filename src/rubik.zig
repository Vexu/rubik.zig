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

pub const Edge = struct {
    a: Color,
    b: Color,

    pub fn m2name(edge: Edge, first: bool) u8 {
        switch (edge.a) {
            .white => return switch (edge.b) {
                .green => 'a',
                .orange => 'b',
                .blue => return if (first) 'c' else 'w',
                .red => 'd',
                else => unreachable,
            },
            .red => return switch (edge.b) {
                .white => 'e',
                .blue => 'f',
                .yellow => 'g',
                .green => 'h',
                else => unreachable,
            },
            .blue => return switch (edge.b) {
                .white => return if (first) 'i' else 's',
                .orange => 'j',
                .yellow => 'k',
                .red => 'l',
                else => unreachable,
            },
            .orange => return switch (edge.b) {
                .white => 'm',
                .green => 'n',
                .yellow => 'o',
                .blue => 'p',
                else => unreachable,
            },
            .green => return switch (edge.b) {
                .white => 'q',
                .red => 'r',
                .yellow => return if (first) 's' else 'i',
                .orange => 't',
                else => unreachable,
            },
            .yellow => return switch (edge.b) {
                .blue => 'u',
                .orange => 'v',
                .green => return if (first) 'w' else 'c',
                .red => 'x',
                else => unreachable,
            },
        }
    }

    /// Normalize edge so that `a` is white, yellow, green or blue
    pub fn normalize(edge: Edge) Edge {
        if (edge.a == .white or edge.a == .yellow) {
            return edge;
        } else if (edge.b == .white or edge.b == .yellow or edge.b == .blue or edge.b == .green) {
            var new = Edge{
                .a = edge.b,
                .b = edge.a,
            };
            return new;
        } else {
            return edge;
        }
    }

    pub fn eql(a: Edge, b: Edge) bool {
        return a.a == b.a and a.b == b.b;
    }
};

pub const Corner = struct {
    a: Color,
    b: Color,
    c: Color,

    pub fn opName(corner: Corner) u8 {
        switch (corner.a) {
            .white => switch (corner.b) {
                .green => return switch (corner.c) {
                    .red => 'A',
                    .orange => 'B',
                    else => unreachable,
                },
                .orange => return switch (corner.c) {
                    .green => 'B',
                    .blue => 'C',
                    else => unreachable,
                },
                .blue => return switch (corner.c) {
                    .orange => 'C',
                    .red => 'D',
                    else => unreachable,
                },
                .red => return switch (corner.c) {
                    .blue => 'D',
                    .green => 'A',
                    else => unreachable,
                },
                else => unreachable,
            },
            .red => switch (corner.b) {
                .green => return switch (corner.c) {
                    .white => 'E',
                    .yellow => 'H',
                    else => unreachable,
                },
                .white => return switch (corner.c) {
                    .green => 'E',
                    .blue => 'F',
                    else => unreachable,
                },
                .blue => return switch (corner.c) {
                    .white => 'F',
                    .yellow => 'G',
                    else => unreachable,
                },
                .yellow => return switch (corner.c) {
                    .blue => 'G',
                    .green => 'H',
                    else => unreachable,
                },
                else => unreachable,
            },
            .blue => switch (corner.b) {
                .red => return switch (corner.c) {
                    .white => 'I',
                    .yellow => 'L',
                    else => unreachable,
                },
                .white => return switch (corner.c) {
                    .red => 'I',
                    .orange => 'J',
                    else => unreachable,
                },
                .orange => return switch (corner.c) {
                    .white => 'J',
                    .yellow => 'K',
                    else => unreachable,
                },
                .yellow => return switch (corner.c) {
                    .orange => 'K',
                    .red => 'L',
                    else => unreachable,
                },
                else => unreachable,
            },
            .orange => switch (corner.b) {
                .blue => return switch (corner.c) {
                    .white => 'M',
                    .yellow => 'P',
                    else => unreachable,
                },
                .white => return switch (corner.c) {
                    .blue => 'M',
                    .green => 'N',
                    else => unreachable,
                },
                .green => return switch (corner.c) {
                    .white => 'N',
                    .yellow => 'O',
                    else => unreachable,
                },
                .yellow => return switch (corner.c) {
                    .green => 'O',
                    .blue => 'P',
                    else => unreachable,
                },
                else => unreachable,
            },
            .green => switch (corner.b) {
                .orange => return switch (corner.c) {
                    .white => 'Q',
                    .yellow => 'T',
                    else => unreachable,
                },
                .white => return switch (corner.c) {
                    .orange => 'Q',
                    .red => 'R',
                    else => unreachable,
                },
                .red => return switch (corner.c) {
                    .white => 'R',
                    .yellow => 'S',
                    else => unreachable,
                },
                .yellow => return switch (corner.c) {
                    .red => 'S',
                    .orange => 'I',
                    else => unreachable,
                },
                else => unreachable,
            },
            .yellow => switch (corner.b) {
                .red => return switch (corner.c) {
                    .blue => 'U',
                    .green => 'X',
                    else => unreachable,
                },
                .blue => return switch (corner.c) {
                    .red => 'U',
                    .orange => 'V',
                    else => unreachable,
                },
                .orange => return switch (corner.c) {
                    .blue => 'V',
                    .green => 'W',
                    else => unreachable,
                },
                .green => return switch (corner.c) {
                    .orange => 'W',
                    .red => 'X',
                    else => unreachable,
                },
                else => unreachable,
            },
        }
    }

    /// Normalize the corner so that `a` is white or yellow, `b` is green or blue and `c` is red or orange.
    pub fn normalize(corner: Corner) Corner {
        var res = corner;
        switch (corner.a) {
            .white, .yellow => res.a = corner.a,
            .green, .blue => res.b = corner.a,
            .red, .orange => res.c = corner.a,
        }
        switch (corner.b) {
            .white, .yellow => res.a = corner.b,
            .green, .blue => res.b = corner.b,
            .red, .orange => res.c = corner.b,
        }
        switch (corner.c) {
            .white, .yellow => res.a = corner.c,
            .green, .blue => res.b = corner.c,
            .red, .orange => res.c = corner.c,
        }
        return res;
    }

    pub fn eql(a: Corner, b: Corner) bool {
        return a.a == b.a and a.b == b.b and a.c == b.c;
    }
};

pub const Cube = struct {
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

    pub fn shuffleLog(self: *Cube, seed: u64, buf: *[32][]const u8) [][]const u8 {
        var prng = std.rand.DefaultPrng.init(seed);
        const moves = prng.random.intRangeAtMost(u8, 10, 32);
        var i: u8 = 0;
        var prev: u8 = 99;
        while (i < moves) {
            const next = prng.random.intRangeAtMost(u8, 0, 11);
            if ((next + 6) % 12 == prev) {
                continue;
            }
            prev = next;

            switch (next) {
                0 => {
                    buf[i] = "U";
                    self.rotU();
                },
                1 => {
                    buf[i] = "L";
                    self.rotL();
                },
                2 => {
                    buf[i] = "F";
                    self.rotF();
                },
                3 => {
                    buf[i] = "R";
                    self.rotR();
                },
                4 => {
                    buf[i] = "B";
                    self.rotB();
                },
                5 => {
                    buf[i] = "D";
                    self.rotD();
                },
                6 => {
                    buf[i] = "U'";
                    self.rotUPrime();
                },
                7 => {
                    buf[i] = "L'";
                    self.rotLPrime();
                },
                8 => {
                    buf[i] = "F'";
                    self.rotFPrime();
                },
                9 => {
                    buf[i] = "R'";
                    self.rotRPrime();
                },
                10 => {
                    buf[i] = "B'";
                    self.rotBPrime();
                },
                11 => {
                    buf[i] = "D'";
                    self.rotDPrime();
                },
                else => unreachable,
            }
            i += 1;
        }
        return buf[0..i];
    }

    pub fn shuffle(self: *Cube, seed: u64) void {
        var buf: [32][]const u8 = undefined;
        _ = self.shuffleLog(seed, &buf);
    }

    pub fn edgeAt(self: Cube, edge: Edge) Edge {
        switch (edge.a) {
            .white => return switch (edge.b) {
                .green => .{
                    .a = self.u[1],
                    .b = self.b[1],
                },
                .orange => .{
                    .a = self.u[3],
                    .b = self.r[1],
                },
                .blue => .{
                    .a = self.u[5],
                    .b = self.f[1],
                },
                .red => .{
                    .a = self.u[7],
                    .b = self.l[1],
                },
                else => unreachable,
            },
            .red => return switch (edge.b) {
                .white => .{
                    .a = self.l[1],
                    .b = self.u[7],
                },
                .blue => .{
                    .a = self.l[3],
                    .b = self.f[7],
                },
                .yellow => .{
                    .a = self.l[5],
                    .b = self.d[7],
                },
                .green => .{
                    .a = self.l[7],
                    .b = self.b[3],
                },
                else => unreachable,
            },
            .blue => return switch (edge.b) {
                .white => .{
                    .a = self.f[1],
                    .b = self.u[5],
                },
                .orange => .{
                    .a = self.f[3],
                    .b = self.r[7],
                },
                .yellow => .{
                    .a = self.f[5],
                    .b = self.d[1],
                },
                .red => .{
                    .a = self.f[7],
                    .b = self.l[3],
                },
                else => unreachable,
            },
            .orange => return switch (edge.b) {
                .white => .{
                    .a = self.r[1],
                    .b = self.u[3],
                },
                .green => .{
                    .a = self.r[3],
                    .b = self.b[7],
                },
                .yellow => .{
                    .a = self.r[5],
                    .b = self.d[3],
                },
                .blue => .{
                    .a = self.r[7],
                    .b = self.f[3],
                },
                else => unreachable,
            },
            .green => return switch (edge.b) {
                .white => .{
                    .a = self.b[1],
                    .b = self.u[1],
                },
                .red => .{
                    .a = self.b[3],
                    .b = self.l[7],
                },
                .yellow => .{
                    .a = self.b[5],
                    .b = self.d[5],
                },
                .orange => .{
                    .a = self.b[7],
                    .b = self.r[3],
                },
                else => unreachable,
            },

            .yellow => return switch (edge.b) {
                .blue => .{
                    .a = self.d[1],
                    .b = self.f[5],
                },
                .orange => .{
                    .a = self.d[3],
                    .b = self.r[5],
                },
                .green => .{
                    .a = self.d[5],
                    .b = self.b[5],
                },
                .red => .{
                    .a = self.d[7],
                    .b = self.l[5],
                },
                else => unreachable,
            },
        }
    }

    pub fn getM2Pairs(self: Cube, buf: []u8) []const u8 {
        assert(buf.len > 42);
        var seen: [12]bool = [_]bool{false} ** 12;

        var prev: Edge = .{
            .a = self.d[1],
            .b = self.f[5],
        };
        markEdge(&seen, prev);

        var end: Edge = .{
            .a = .yellow,
            .b = .blue,
        };
        var first_letter: ?u8 = null;
        var i: u8 = 0;

        while (true) {
            if (prev.normalize().eql(end)) {
                if (first_letter) |some| {
                    buf[i] = some;
                    buf[i + 1] = prev.m2name(false);
                    buf[i + 2] = '\n';
                    i += 3;
                    first_letter = null;
                } else if (prev.m2name(true) != 'u' and prev.m2name(true) != 'k') {
                    // 'u' and 'k' should never be printed
                    first_letter = prev.m2name(true);
                }
                if (self.findUnsolvedEdge(&seen)) |some| {
                    prev = some;
                    markEdge(&seen, prev);
                    end = prev.normalize();
                } else {
                    if (first_letter) |some| {
                        buf[i] = some;
                        buf[i + 1 ..][0..8].* = " parity\n".*;
                        i += 9;
                    }
                    return buf[0..i];
                }
            }

            if (first_letter) |some| {
                buf[i] = some;
                buf[i + 1] = prev.m2name(false);
                buf[i + 2] = '\n';
                i += 3;
                first_letter = null;
            } else {
                first_letter = prev.m2name(true);
            }
            prev = self.edgeAt(prev);
            markEdge(&seen, prev);
        }
        unreachable;
    }

    fn markEdge(edges: *[12]bool, edge: Edge) void {
        const norm = edge.normalize();
        var index: u8 = undefined;
        switch (norm.a) {
            .white => index = switch (norm.b) {
                .green => 0,
                .orange => 1,
                .blue => 2,
                .red => 3,
                else => unreachable,
            },
            .blue => index = switch (norm.b) {
                .orange => 4,
                .red => 5,
                else => unreachable,
            },
            .green => index = switch (norm.b) {
                .red => 6,
                .orange => 7,
                else => unreachable,
            },
            .yellow => index = switch (norm.b) {
                .blue => 8,
                .orange => 9,
                .green => 10,
                .red => 11,
                else => unreachable,
            },
            else => unreachable,
        }

        edges[index] = true;
    }

    fn findUnsolvedEdge(cube: Cube, edges: *[12]bool) ?Edge {
        for (edges) |s, i| {
            if (s) continue;
            const e: Edge = switch (i) {
                0 => .{ .a = .white, .b = .green },
                1 => .{ .a = .white, .b = .orange },
                2 => .{ .a = .white, .b = .blue },
                3 => .{ .a = .white, .b = .red },
                4 => .{ .a = .blue, .b = .orange },
                5 => .{ .a = .blue, .b = .red },
                6 => .{ .a = .green, .b = .red },
                7 => .{ .a = .green, .b = .orange },
                8 => continue,
                9 => .{ .a = .yellow, .b = .orange },
                10 => .{ .a = .yellow, .b = .green },
                11 => .{ .a = .yellow, .b = .red },
                else => unreachable,
            };

            if (e.eql(cube.edgeAt(e))) {
                markEdge(edges, e); // already solved
            } else {
                return e;
            }
        }
        return null;
    }

    pub fn cornerAt(self: Cube, corner: Corner) Corner {
        switch (corner.a) {
            .white => switch (corner.b) {
                .green => return switch (corner.c) {
                    .red => .{ .a = self.u[0], .b = self.b[2], .c = self.l[0] },
                    .orange => .{ .a = self.u[2], .b = self.b[0], .c = self.r[2] },
                    else => unreachable,
                },
                .orange => return switch (corner.c) {
                    .green => .{ .a = self.u[2], .b = self.r[2], .c = self.b[0] },
                    .blue => .{ .a = self.u[4], .b = self.r[0], .c = self.f[2] },
                    else => unreachable,
                },
                .blue => return switch (corner.c) {
                    .orange => .{ .a = self.u[4], .b = self.f[2], .c = self.r[0] },
                    .red => .{ .a = self.u[6], .b = self.f[0], .c = self.l[2] },
                    else => unreachable,
                },
                .red => return switch (corner.c) {
                    .blue => .{ .a = self.u[6], .b = self.l[2], .c = self.f[0] },
                    .green => .{ .a = self.u[0], .b = self.l[0], .c = self.b[2] },
                    else => unreachable,
                },
                else => unreachable,
            },
            .red => switch (corner.b) {
                .white => return switch (corner.c) {
                    .green => .{ .a = self.l[0], .b = self.u[0], .c = self.b[2] },
                    .blue => .{ .a = self.l[2], .b = self.u[6], .c = self.f[0] },
                    else => unreachable,
                },
                .blue => return switch (corner.c) {
                    .white => .{ .a = self.l[2], .b = self.f[0], .c = self.u[6] },
                    .yellow => .{ .a = self.l[4], .b = self.f[6], .c = self.d[0] },
                    else => unreachable,
                },
                .yellow => return switch (corner.c) {
                    .blue => .{ .a = self.l[4], .b = self.d[0], .c = self.f[6] },
                    .green => .{ .a = self.l[6], .b = self.d[6], .c = self.b[4] },
                    else => unreachable,
                },
                .green => return switch (corner.c) {
                    .white => .{ .a = self.l[6], .b = self.b[2], .c = self.u[0] },
                    .yellow => .{ .a = self.l[0], .b = self.b[4], .c = self.d[6] },
                    else => unreachable,
                },
                else => unreachable,
            },
            .blue => switch (corner.b) {
                .white => return switch (corner.c) {
                    .red => .{ .a = self.f[0], .b = self.u[6], .c = self.l[2] },
                    .orange => .{ .a = self.f[2], .b = self.u[4], .c = self.r[0] },
                    else => unreachable,
                },
                .orange => return switch (corner.c) {
                    .white => .{ .a = self.f[2], .b = self.r[0], .c = self.u[4] },
                    .yellow => .{ .a = self.f[4], .b = self.r[6], .c = self.d[2] },
                    else => unreachable,
                },
                .yellow => return switch (corner.c) {
                    .orange => .{ .a = self.f[4], .b = self.d[2], .c = self.r[6] },
                    .red => .{ .a = self.f[6], .b = self.d[0], .c = self.l[4] },
                    else => unreachable,
                },
                .red => return switch (corner.c) {
                    .white => .{ .a = self.f[0], .b = self.l[2], .c = self.u[6] },
                    .yellow => .{ .a = self.f[6], .b = self.l[4], .c = self.d[0] },
                    else => unreachable,
                },
                else => unreachable,
            },
            .orange => switch (corner.b) {
                .white => return switch (corner.c) {
                    .blue => .{ .a = self.r[0], .b = self.u[4], .c = self.f[2] },
                    .green => .{ .a = self.r[2], .b = self.u[2], .c = self.b[6] },
                    else => unreachable,
                },
                .green => return switch (corner.c) {
                    .white => .{ .a = self.r[2], .b = self.b[0], .c = self.u[2] },
                    .yellow => .{ .a = self.r[4], .b = self.b[6], .c = self.d[4] },
                    else => unreachable,
                },
                .yellow => return switch (corner.c) {
                    .green => .{ .a = self.r[4], .b = self.d[4], .c = self.b[6] },
                    .blue => .{ .a = self.r[6], .b = self.d[2], .c = self.f[4] },
                    else => unreachable,
                },
                .blue => return switch (corner.c) {
                    .yellow => .{ .a = self.r[6], .b = self.f[4], .c = self.d[2] },
                    .white => .{ .a = self.r[0], .b = self.f[2], .c = self.u[4] },
                    else => unreachable,
                },
                else => unreachable,
            },
            .green => switch (corner.b) {
                .white => return switch (corner.c) {
                    .orange => .{ .a = self.b[0], .b = self.u[2], .c = self.r[2] },
                    .red => .{ .a = self.b[2], .b = self.u[0], .c = self.l[0] },
                    else => unreachable,
                },
                .red => return switch (corner.c) {
                    .white => .{ .a = self.b[2], .b = self.l[0], .c = self.u[0] },
                    .yellow => .{ .a = self.b[4], .b = self.l[6], .c = self.d[6] },
                    else => unreachable,
                },
                .yellow => return switch (corner.c) {
                    .red => .{ .a = self.b[4], .b = self.d[6], .c = self.l[6] },
                    .orange => .{ .a = self.b[6], .b = self.d[4], .c = self.r[4] },
                    else => unreachable,
                },
                .orange => return switch (corner.c) {
                    .yellow => .{ .a = self.b[6], .b = self.r[4], .c = self.d[4] },
                    .white => .{ .a = self.b[0], .b = self.r[2], .c = self.u[2] },
                    else => unreachable,
                },
                else => unreachable,
            },
            .yellow => switch (corner.b) {
                .blue => return switch (corner.c) {
                    .red => .{ .a = self.d[0], .b = self.f[6], .c = self.l[4] },
                    .orange => .{ .a = self.d[2], .b = self.f[4], .c = self.r[6] },
                    else => unreachable,
                },
                .orange => return switch (corner.c) {
                    .blue => .{ .a = self.d[2], .b = self.r[6], .c = self.f[4] },
                    .green => .{ .a = self.d[4], .b = self.r[4], .c = self.b[6] },
                    else => unreachable,
                },
                .green => return switch (corner.c) {
                    .orange => .{ .a = self.d[4], .b = self.b[6], .c = self.r[4] },
                    .red => .{ .a = self.d[6], .b = self.b[4], .c = self.l[6] },
                    else => unreachable,
                },
                .red => return switch (corner.c) {
                    .green => .{ .a = self.d[6], .b = self.l[6], .c = self.b[4] },
                    .blue => .{ .a = self.d[0], .b = self.l[4], .c = self.f[6] },
                    else => unreachable,
                },
                else => unreachable,
            },
        }
    }

    pub fn getOpPairs(self: Cube, buf: []u8) []const u8 {
        assert(buf.len > 8 * 3);
        var seen: [8]bool = [_]bool{false} ** 8;

        var prev: Corner = .{
            .a = self.l[0],
            .b = self.u[0],
            .c = self.b[2],
        };
        markCorner(&seen, prev);

        var end: Corner = .{
            .a = .white,
            .b = .green,
            .c = .red,
        };
        var first_letter: ?u8 = null;
        var i: u8 = 0;

        while (true) {
            if (prev.normalize().eql(end)) {
                if (first_letter) |some| {
                    buf[i] = some;
                    buf[i + 1] = prev.opName();
                    buf[i + 2] = '\n';
                    i += 3;
                    first_letter = null;
                } else switch (prev.opName()) {
                    'A', 'E', 'R' => {},
                    else => first_letter = prev.opName(),
                }

                if (self.findUnsolvedCorner(&seen)) |some| {
                    prev = some;
                    markCorner(&seen, prev);
                    end = prev.normalize();
                } else {
                    if (first_letter) |some| {
                        buf[i] = some;
                        buf[i + 1] = '\n';
                        i += 2;
                    }
                    return buf[0..i];
                }
            }

            if (first_letter) |some| {
                buf[i] = some;
                buf[i + 1] = prev.opName();
                buf[i + 2] = '\n';
                i += 3;
                first_letter = null;
            } else {
                first_letter = prev.opName();
            }
            prev = self.cornerAt(prev);
            markCorner(&seen, prev);
        }
        unreachable;
    }

    fn markCorner(corners: *[8]bool, corner: Corner) void {
        const norm = corner.normalize();
        var index: u8 = undefined;
        switch (norm.a) {
            .white => switch (norm.b) {
                .green => index = switch (norm.c) {
                    .red => 0,
                    .orange => 1,
                    else => unreachable,
                },
                .blue => index = switch (norm.c) {
                    .orange => 2,
                    .red => 3,
                    else => unreachable,
                },
                else => unreachable,
            },
            .yellow => switch (norm.b) {
                .blue => index = switch (norm.c) {
                    .red => 4,
                    .orange => 5,
                    else => unreachable,
                },
                .green => index = switch (norm.c) {
                    .orange => 6,
                    .red => 7,
                    else => unreachable,
                },
                else => unreachable,
            },
            else => unreachable,
        }

        corners[index] = true;
    }

    fn findUnsolvedCorner(cube: Cube, corners: *[8]bool) ?Corner {
        for (corners) |s, i| {
            if (s) continue;
            const c: Corner = switch (i) {
                0 => continue,
                1 => .{ .a = .white, .b = .green, .c = .orange },
                2 => .{ .a = .white, .b = .blue, .c = .orange },
                3 => .{ .a = .white, .b = .blue, .c = .red },
                4 => .{ .a = .yellow, .b = .blue, .c = .red },
                5 => .{ .a = .yellow, .b = .blue, .c = .orange },
                6 => .{ .a = .yellow, .b = .green, .c = .orange },
                7 => .{ .a = .yellow, .b = .green, .c = .red },
                else => unreachable,
            };

            if (c.eql(cube.cornerAt(c))) {
                markCorner(corners, c); // already solved
            } else {
                return c;
            }
        }
        return null;
    }

    pub fn doMoves(self: *Cube, moves: []const u8) error{InvalidCharacter}!void {
        var it = std.mem.tokenize(moves, " ");
        while (it.next()) |move| {
            assert(move.len != 0); // guaranteed by mem.tokenize

            var inverse = false;
            var double = false;
            if (move.len > 1) {
                switch (move[1]) {
                    '0' => continue,
                    '1' => {},
                    '2' => double = true,
                    '3' => inverse = true,
                    '4' => continue,
                    '\'' => inverse = true,
                    else => return error.InvalidCharacter,
                }
                if (move.len > 2) return error.InvalidCharacter;
            }
            switch (move[0]) {
                'u', 'U' => if (inverse) {
                    self.rotUPrime();
                } else if (double) {
                    self.rotU();
                    self.rotU();
                } else {
                    self.rotU();
                },
                'l', 'L' =>  if (inverse) {
                    self.rotLPrime();
                } else if (double) {
                    self.rotL();
                    self.rotL();
                } else {
                    self.rotL();
                },
                'f', 'F' =>  if (inverse) {
                    self.rotFPrime();
                } else if (double) {
                    self.rotF();
                    self.rotF();
                } else {
                    self.rotF();
                },
                'r', 'R' =>  if (inverse) {
                    self.rotRPrime();
                } else if (double) {
                    self.rotR();
                    self.rotR();
                } else {
                    self.rotR();
                },
                'b', 'B' =>  if (inverse) {
                    self.rotBPrime();
                } else if (double) {
                    self.rotB();
                    self.rotB();
                } else {
                    self.rotB();
                },
                'd', 'D' =>  if (inverse) {
                    self.rotDPrime();
                } else if (double) {
                    self.rotD();
                    self.rotD();
                } else {
                    self.rotD();
                },
                else => return error.InvalidCharacter,
            }
        }
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

test "shuffle" {
    var c: Cube = .{};
    c.shuffle(420);
    expect(!c.isSolved());

    var res: Cube = .{};
    res.rotBPrime();
    res.rotU();
    res.rotDPrime();
    res.rotF();
    res.rotB();
    res.rotF();
    res.rotUPrime();
    res.rotL();
    res.rotRPrime();
    res.rotBPrime();
    res.rotDPrime();
    res.rotB();
    res.rotF();
    res.rotF();
    res.rotL();
    res.rotF();
    res.rotL();
    res.rotDPrime();
    res.rotDPrime();
    res.rotDPrime();
    res.rotF();
    res.rotRPrime();
    res.rotFPrime();
    res.rotRPrime();
    res.rotBPrime();
    res.rotDPrime();
    res.rotFPrime();
    expect(c.eql(res));
}

test "edge.eql" {
    var a: Edge = .{
        .a = .white,
        .b = .blue,
    };
    var b: Edge = .{
        .a = .blue,
        .b = .white,
    };
    expect(!a.eql(b));
    expect(a.eql(b.normalize()));
}

test "m2 pairs" {
    var buf: [64]u8 = undefined;
    var c: Cube = .{};
    c.shuffle(6666);
    var res = c.getM2Pairs(&buf);
    std.testing.expectEqualStrings("th\nox\ndq\nws\nbm\njl\np parity\n", res);

    // superflip
    c = .{};
    c.rotU();
    c.rotR();
    c.rotR();
    c.rotF();
    c.rotB();
    c.rotR();
    c.rotB();
    c.rotB();
    c.rotR();
    c.rotU();
    c.rotU();
    c.rotL();
    c.rotB();
    c.rotB();
    c.rotR();
    c.rotUPrime();
    c.rotDPrime();
    c.rotR();
    c.rotR();
    c.rotF();
    c.rotRPrime();
    c.rotL();
    c.rotB();
    c.rotB();
    c.rotU();
    c.rotU();
    c.rotF();
    c.rotF();
    res = c.getM2Pairs(&buf);
    std.testing.expectEqualStrings("aq\nbm\ncs\nde\njp\nlf\nrh\ntn\nvo\nwi\nxg\n", res);
}

test "old pochman corners" {
    var buf: [64]u8 = undefined;
    var c: Cube = .{};
    c.shuffle(6666);
    var res = c.getOpPairs(&buf);
    std.testing.expectEqualStrings("BW\nLN\nCV\nMD\nF\n", res);

    // superflip
    c = .{};
    c.rotU();
    c.rotR();
    c.rotR();
    c.rotF();
    c.rotB();
    c.rotR();
    c.rotB();
    c.rotB();
    c.rotR();
    c.rotU();
    c.rotU();
    c.rotL();
    c.rotB();
    c.rotB();
    c.rotR();
    c.rotUPrime();
    c.rotDPrime();
    c.rotR();
    c.rotR();
    c.rotF();
    c.rotRPrime();
    c.rotL();
    c.rotB();
    c.rotB();
    c.rotU();
    c.rotU();
    c.rotF();
    c.rotF();
    res = c.getOpPairs(&buf);
    std.testing.expectEqualStrings("", res);
}

test "full blind solve" {
    var buf: [128]u8 = undefined;
    var c: Cube = .{};
    c.doMoves("R B' U' R' U' B2 U R2 B L' F2 D' B2 U2 F2 D B2 R2 D' L2 U'") catch unreachable;

    var edges = c.getM2Pairs(&buf);
    std.testing.expectEqualStrings("lh\ngo\nap\nqb\nmw\ndn\nws\n", edges);
    var corners = c.getOpPairs(buf[edges.len..]);
    std.testing.expectEqualStrings("IS\nPG\nMQ\n", corners);

    c = .{};
    c.doMoves("D R' U' F2 R2 F2 L2 F2 R' D2 F' R' F R2 B' U' L2 D2 B U' F2 U R F D2") catch unreachable;
    edges = c.getM2Pairs(&buf);
    std.testing.expectEqualStrings("md\npc\nat\nxl\nho\nia\n", edges);
    corners = c.getOpPairs(buf[edges.len..]);
    std.testing.expectEqualStrings("KB\nMX\nOD\nUG\n", corners);
}

test "doMoves" {
    var a: Cube = .{};
    a.rotR();
    a.rotBPrime();
    a.rotUPrime();
    a.rotRPrime();
    a.rotUPrime();
    a.rotB();
    a.rotB();
    a.rotU();
    a.rotR();
    a.rotR();
    a.rotB();
    a.rotLPrime();
    a.rotF();
    a.rotF();
    a.rotDPrime();
    a.rotB();
    a.rotB();
    a.rotU();
    a.rotU();
    a.rotF();
    a.rotF();
    a.rotD();
    a.rotB();
    a.rotB();
    a.rotR();
    a.rotR();
    a.rotDPrime();
    a.rotL();
    a.rotL();
    a.rotUPrime();

    var b: Cube = .{};
    b.doMoves("R B' U' R' U' B2 U R2 B L' F2 D' B2 U2 F2 D B2 R2 D' L2 U'") catch unreachable;

    expect(a.eql(b));
}

pub fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format ++ "\n", args);
    std.process.exit(1);
}

const usage =
    \\Usage: rubik [command] [args]
    \\
    \\Commands:
    \\
    \\  do [moves]              Do the given moves and print the result
    \\  help                    Print this help and exit
    \\  solve-blind [moves]     Solve the m2 and Old Pochman pairs for this scramble
    \\  version                 Print version number and exit
    \\
;

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = &general_purpose_allocator.allocator;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    defer _ = general_purpose_allocator.deinit();

    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    const args = try std.process.argsAlloc(&arena_instance.allocator);

    if (args.len <= 1) {
        std.debug.print("{}", .{usage});
        fatal("expected command argument", .{});
    }

    if (std.mem.eql(u8, args[1], "do")) {
        if (args.len != 3) {
            fatal("expected exactly one scramble argument", .{});
        }
        var cube: Cube = .{};
        cube.doMoves(args[2]) catch {
            fatal("invalid scramble: \"{}\"", .{args[2]});
        };

        try stdout.print("{}\n", .{cube});
    } else if (std.mem.eql(u8, args[1], "help")) {
        try stdout.writeAll(usage);
    } else if (std.mem.eql(u8, args[1], "solve-blind")) {
        if (args.len != 3) {
            fatal("expected exactly one scramble argument", .{});
        }
        var cube: Cube = .{};
        cube.doMoves(args[2]) catch {
            fatal("invalid scramble: \"{}\"", .{args[2]});
        };

        var buf: [128]u8 = undefined;
        const edges = cube.getM2Pairs(&buf);
        const corners = cube.getOpPairs(buf[edges.len..]);

        if (edges.len == 0) {
            try stdout.writeAll("edges solved\n");
        } else {
            try stdout.print("edges:\n{s}", .{edges});
        }

        if (corners.len == 0) {
            try stdout.writeAll("corners solved\n");
        } else {
            try stdout.print("corners:\n{s}", .{corners});
        }
    } else if (std.mem.eql(u8, args[1], "version")) {
        try stdout.print("{}", .{@import("build_options").rubik_version});
    } else {
        std.debug.print("{}", .{usage});
        fatal("unknown command: {}", .{args[1]});
    }
}
