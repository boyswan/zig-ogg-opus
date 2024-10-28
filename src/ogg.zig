const std = @import("std");

pub const OggPageHeader = struct {
    capture_pattern: [4]u8,
    version: u8,
    headerType: u8,
    granulePos: i64,
    serialNumber: u32,
    pageSequence: u32,
    checkSum: u32,
    pageSegments: u8,

    pub fn init() OggPageHeader {
        return OggPageHeader{
            .capture_pattern = "OggS".*,
            .version = 0,
            .headerType = 0,
            .granulePos = 0,
            .serialNumber = 0,
            .pageSequence = 0,
            .checkSum = 0,
            .pageSegments = 0,
        };
    }

    pub fn toBytes(self: *OggPageHeader, allocator: std.mem.Allocator) ![]u8 {
        var buffer = try allocator.alloc(u8, 27);
        @memcpy(buffer[0..4], &self.capture_pattern);
        buffer[4] = self.version;
        buffer[5] = self.headerType;
        @memcpy(buffer[6..14], std.mem.asBytes(&self.granulePos));
        @memcpy(buffer[14..18], std.mem.asBytes(&self.serialNumber));
        @memcpy(buffer[18..22], std.mem.asBytes(&self.pageSequence));
        @memcpy(buffer[22..26], std.mem.asBytes(&self.checkSum));
        buffer[26] = self.pageSegments;
        return buffer;
    }
};
