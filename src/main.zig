const std = @import("std");
const assert = std.debug.assert;
// const c = @cImport({
//     @cInclude("png.h");
// });

const c = @cImport({
    @cInclude("opus/opus.h");
});

fn assert_opus(err: c_int) void {
    if (err != c.OPUS_OK) {
        std.debug.panic("opus err: {}", .{err});
    }
}
pub const OpusEncoder = struct {
    const Self = @This();
    encoder: *c.OpusEncoder,

    const sample_rate = 48_000;
    const bit_rate = 48_000;
    const frame_size = 20;
    const channels = 1;

    pub fn init() OpusEncoder {
        var err: c_int = undefined;
        const encoder = c.opus_encoder_create(OpusEncoder.sample_rate, OpusEncoder.channels, c.OPUS_APPLICATION_VOIP, &err) orelse {
            std.debug.panic("opus encoder create failed", .{});
        };

        assert_opus(err);
        assert_opus(c.opus_encoder_ctl(encoder, c.OPUS_SET_BITRATE_REQUEST, @as(c_int, OpusEncoder.bit_rate)));

        return OpusEncoder{ .encoder = encoder };
    }

    pub fn destroy(self: *const Self) void {
        c.opus_encoder_destroy(self.encoder);
    }

    pub fn encode(self: *Self, pcm: []const i16, buffer: []u8) u32 {
        return c.opus_encode(self.encoder, pcm.ptr, OpusEncoder.frame_size, buffer.ptr, @as(c_int, buffer.len));
    }
};

pub const OggOpus = struct {
    const Self = @This();
    encoder: OpusEncoder,
    allocator: std.mem.Allocator, // Store the allocator for cleanup
    buffer: []i16,

    pub fn init(allocator: std.mem.Allocator, capacity: usize) !OggOpus {
        assert(capacity > 0);
        const buffer = try allocator.alloc(i16, capacity);
        return OggOpus{ .allocator = allocator, .buffer = buffer, .encoder = OpusEncoder.init() };
    }

    pub fn destroy(self: *const Self) void {
        self.encoder.destroy();
        self.allocator.free(self.buffer);
    }
};

pub fn main() anyerror!void {
    const gpa = std.heap.GeneralPurposeAllocator(.{});
    const allocator = gpa.allocator();
    var enc = OggOpus.init(allocator, 300) catch {
        std.debug.panic("opus err: alloc failed", .{});
    };
    defer enc.destroy();
}
