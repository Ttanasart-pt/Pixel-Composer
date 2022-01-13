function bin_read_byte(bin) {
	return file_bin_read_byte(bin);
}
function bin_read_word(bin) {
	return file_bin_read_byte(bin) + file_bin_read_byte(bin);
}
function bin_read_short(bin) {
	return file_bin_read_byte(bin) + file_bin_read_byte(bin);
}
function bin_read_dword(bin) {
	return file_bin_read_byte(bin) + file_bin_read_byte(bin) + file_bin_read_byte(bin) + file_bin_read_byte(bin);
}
function bin_read_long(bin) {
	return file_bin_read_byte(bin) + file_bin_read_byte(bin) + file_bin_read_byte(bin) + file_bin_read_byte(bin);
}