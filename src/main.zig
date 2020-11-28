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
            var new =  Edge{
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

pub const Edges = packed struct {
    ub: bool = false,
    ur: bool = false,
    uf: bool = false,
    ul: bool = false,
    fr: bool = false,
    fl: bool = false,
    bl: bool = false,
    br: bool = false,
    df: bool = false,
    dr: bool = false,
    db: bool = false,
    dl: bool = false,

    pub fn all(self: Edges) bool {
        return @bitCast(u12, self) == std.math.maxInt(u12);
    }

    pub fn mark(self: *Edges, edge: Edge) void {
        const norm = edge.normalize();

        switch (norm.a) {
            .white => switch (norm.b) {
                .green => self.ub = true,
                .orange => self.ur = true,
                .blue => self.uf = true,
                .red => self.ul = true,
                else => unreachable,
            },
            .blue => switch (norm.b) {
                .orange => self.fr = true,
                .red => self.fl = true,
                else => unreachable,
            },
            .green => switch (norm.b) {
                .red => self.bl = true,
                .orange => self.br = true,
                else => unreachable,
            },
            .yellow => switch (norm.b) {
                .blue => self.df = true,
                .orange => self.dr = true,
                .green => self.db = true,
                .red => self.dl = true,
                else => unreachable,
            },
            else => unreachable,
        }
    }

    pub fn get(self: *Edges, edge: Edge) bool {
        const norm = edge.normalize();

        switch (norm.a) {
            .white => return switch (norm.b) {
                .green => self.ub,
                .orange => self.ur,
                .blue => self.uf,
                .red => self.ur,
                else => unreachable,
            },
            .blue => return switch (norm.b) {
                .orange => self.fr,
                .red => self.fl,
                else => unreachable,
            },
            .green => return switch (norm.b) {
                .red => self.bl,
                .orange => self.br,
                else => unreachable,
            },
            .yellow => return switch (norm.b) {
                .blue => self.df,
                .orange => self.dr,
                .green => self.db,
                .red => self.dl,
                else => unreachable,
            },
        }
    }

    pub fn findUnsolved(self: *Edges, cube: Cube) ?Edge {
        if (self.all()) return null;
        while (true) {
            var e: Edge = undefined;
            if (!self.ub) {
                e = .{.a = .white, .b = .green};
            } else if (!self.ur) {
                e = .{.a = .white, .b = .orange};
            } else if (!self.uf) {
                e = .{.a = .white, .b = .blue};
            } else if (!self.ul) {
                e = .{.a = .white, .b = .red};
            } else if (!self.fr) {
                e = .{.a = .blue, .b = .orange};
            } else if (!self.fl) {
                e = .{.a = .blue, .b = .red};
            } else if (!self.bl) {
                e = .{.a = .green, .b = .red};
            } else if (!self.br) {
                e = .{.a = .green, .b = .orange};
            } else if (!self.dr) {
                e = .{.a = .yellow, .b = .orange};
            } else if (!self.db) {
                e = .{.a = .yellow, .b = .green};
            } else if (!self.dl) {
                e = .{.a = .yellow, .b = .red};
            } else return null;


            if (e.eql(cube.edgeAt(e))) {
                self.mark(e); // already solved
            } else {
                return e;
            }
        }
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
        var seen: Edges = .{};

        var prev: Edge = .{
            .a = self.d[1],
            .b = self.f[5],
        };
        seen.mark(prev);

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
                    buf[i+1] = prev.m2name(false);
                    buf[i+2] = '\n';
                    i += 3;
                    first_letter = null;
                } else if (prev.m2name(true) != 'u' and prev.m2name(true) != 'k') {
                    // 'u' and 'k' should never be printed
                    first_letter = prev.m2name(true);
                }
                if (seen.findUnsolved(self)) |some| {
                    prev = some;
                    seen.mark(prev);
                    end = prev.normalize();
                } else {
                    if (first_letter) |some| {
                        buf[i] = some;
                        buf[i+1..][0..8].* = " parity\n".*;
                        i += 9;
                    }
                    return buf[0..i];
                }
            }

            if (first_letter) |some| {
                buf[i] = some;
                buf[i+1] = prev.m2name(false);
                buf[i+2] = '\n';
                i += 3;
                first_letter = null;
            } else {
                first_letter = prev.m2name(true);
            }
            prev = self.edgeAt(prev);
            seen.mark(prev);
        }
        unreachable;
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
