function buffer_write_int8_little(buffer, value) {
    buffer_write(buffer, buffer_u8, clamp(value, -128, 127));
}

function buffer_write_int16_little(buffer, value) {
    value = ((value & 0xFF) << 8) | ((value & 0xFF00) >> 8);
    buffer_write(buffer, buffer_s16, value);
}

function buffer_write_int32_little(buffer, value) {
    value = ((value & 0xFF) << 24) | ((value & 0xFF00) << 8) | ((value & 0xFF0000) >> 8) | ((value & 0xFF000000) >> 24);
    buffer_write(buffer, buffer_s32, value);
}

function buffer_write_uint8_little(buffer, value) {
    buffer_write(buffer, buffer_u8, clamp(value, 0, 255));
}

function buffer_write_uint16_little(buffer, value) {
    value = ((value & 0xFF) << 8) | ((value & 0xFF00) >> 8);
    buffer_write(buffer, buffer_u16, value);
}

function buffer_write_uint32_little(buffer, value) {
	value = ((value & 0xFF) << 24) | ((value & 0xFF00) << 8) | ((value & 0xFF0000) >> 8) | ((value & 0xFF000000) >> 24);
	buffer_write(buffer, buffer_u32, value);
}
