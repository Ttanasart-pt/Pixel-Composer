
function bin_read_byte(_bin) {
	return file_bin_read_byte(_bin);
}

function bin_read_word(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	return b0 + (b1 << 8);
}

function bin_read_short(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	
	var short = b0 + (b1 << 8);
	var sig   = short >> 15;
	short = short & ~(1 << 15);
	return sig? -power(2, 15) + short : short;
}

function bin_read_dword(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	var b2 = file_bin_read_byte(_bin);
	var b3 = file_bin_read_byte(_bin);
	var dword = b0 + (b1 << 8) + (b2 << 16) + (b3 << 24);
	return dword;
}

function bin_read_long(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	var b2 = file_bin_read_byte(_bin);
	var b3 = file_bin_read_byte(_bin);
	var long = b0 + (b1 << 8) + (b2 << 16) + (b3 << 24);
	
	var sig   = long >> 31;
	long = long & ~(1 << 31);
	return sig? -power(2, 31) : long;
}

function bin_read_fixed(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	var b2 = file_bin_read_byte(_bin);
	var b3 = file_bin_read_byte(_bin);
	
	var fixInt = b0 + (b1 << 8);
	var fixFrc = b2 + (b3 << 8);
	return fixInt + bin_fraction(fixFrc, 16);
}

function bin_read_float(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	var b2 = file_bin_read_byte(_bin);
	var b3 = file_bin_read_byte(_bin);
	var float = b0 + (b1 << 8) + (b2 << 16) + (b3 << 24);
	
	var sig   = float >> 31;
	var expo  = (float & ~(1 << 31)) >> 23;
	var mant  = float & 0b00000000_01111111_11111111_11111111;
	
	var val = (1 + mant) * power(2, expo - 127);
	return sig? -val : val;
}

function bin_read_double(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	var b2 = file_bin_read_byte(_bin);
	var b3 = file_bin_read_byte(_bin);
	var b4 = file_bin_read_byte(_bin);
	var b5 = file_bin_read_byte(_bin);
	var b6 = file_bin_read_byte(_bin);
	var b7 = file_bin_read_byte(_bin);
	var double = b0 + (b1 << 8) + (b2 << 16) + (b3 << 24) + (b2 << 32) + (b3 << 40) + (b2 << 48) + (b3 << 56);
	
	var sig   = double >> 63;
	var expo  = (double & ~(1 << 63)) >> 52;
	var mant  = double & 0b00000000_00001111_11111111_11111111_11111111_11111111_11111111_11111111;
	
	var val = (1 + mant) * power(2, expo - 1023);
	return sig? -val : val;
}

function bin_read_qword(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	var b2 = file_bin_read_byte(_bin);
	var b3 = file_bin_read_byte(_bin);
	var b4 = file_bin_read_byte(_bin);
	var b5 = file_bin_read_byte(_bin);
	var b6 = file_bin_read_byte(_bin);
	var b7 = file_bin_read_byte(_bin);
	return b0 + (b1 << 8) + (b2 << 16) + (b3 << 24) + (b2 << 32) + (b3 << 40) + (b2 << 48) + (b3 << 56);
}

function bin_read_long64(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	var b2 = file_bin_read_byte(_bin);
	var b3 = file_bin_read_byte(_bin);
	var b4 = file_bin_read_byte(_bin);
	var b5 = file_bin_read_byte(_bin);
	var b6 = file_bin_read_byte(_bin);
	var b7 = file_bin_read_byte(_bin);
	var long = b0 + (b1 << 8) + (b2 << 16) + (b3 << 24) + (b2 << 32) + (b3 << 40) + (b2 << 48) + (b3 << 56);
	var sig   = long >> 63;
	long = long & ~(1 << 63);
	return sig? -long : long;
}

//
function bin_read_string(_bin) {
	var len = bin_read_word(_bin);
	var ss = "";
	repeat(len) {
		var utf = bin_read_byte(_bin);
		ss += chr(utf);
	}
	return ss;
}

function bin_read_point(_bin) { return [ bin_read_long(_bin),  bin_read_long(_bin) ]; }
function bin_read_size(_bin)  { return [ bin_read_long(_bin),  bin_read_long(_bin) ]; }
function bin_read_rect(_bin)  { return [ bin_read_point(_bin), bin_read_size(_bin) ]; }

function bin_read_color(_bin) {
	var r = bin_read_byte(_bin);
	var g = bin_read_byte(_bin);
	var b = bin_read_byte(_bin);
	
	return make_color_rgb(r, g, b);
}

function bin_read_pixel(_bin, type) {
	switch(type) {
		case 0 : return [ bin_read_byte(_bin), bin_read_byte(_bin), bin_read_byte(_bin), bin_read_byte(_bin) ];
		case 1 : return [ bin_read_byte(_bin), bin_read_byte(_bin) ];
		case 2 : return [ bin_read_byte(_bin) ];
	}
	return 0;
}