fn get_tbl_elem(idx: u32) u32 {
    var r = idx << 24;
    for (0..8) |_| {
        r = (r << 1) ^ (-((r >> 31) & 1) & 0x04c11db7);
    }
    return r;
}

fn lookup_array() [256]u32 {
    var arr: [256]u32 = undefined;
    for (0..256) |i| {
        arr[i] = get_tbl_elem(i);
    }
    return arr;
}

const crc_table = lookup_array();

// pub fn vorbisCRC32Update(cur: u32, array: []const u8) u32 {
//     var ret = cur;
//     for (array) |av| {
//         ret = (ret << 8) ^ CRCLookupArray[@intCast(av ^ (ret >> 24))];
//     }
//     return ret;
// }
