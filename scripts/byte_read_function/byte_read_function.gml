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
	
	var sht = b0 + (b1 << 8);
	var sig = sht >> 15;
	sht = sht & ~(1 << 15);
	return sig? sht - power(2, 15) : sht;
}

function bin_read_dword(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	var b2 = file_bin_read_byte(_bin);
	var b3 = file_bin_read_byte(_bin);
	var dw = b0 + (b1 << 8) + (b2 << 16) + (b3 << 24);
	return dw;
}

function bin_read_long(_bin) {
	var b0 = file_bin_read_byte(_bin);
	var b1 = file_bin_read_byte(_bin);
	var b2 = file_bin_read_byte(_bin);
	var b3 = file_bin_read_byte(_bin);
	var lng = b0 + (b1 << 8) + (b2 << 16) + (b3 << 24);
	
	var sig = lng >> 31;
	lng = lng & ~(1 << 31);
	return sig? lng - power(2, 31) : lng;
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
	var flt = b0 + (b1 << 8) + (b2 << 16) + (b3 << 24);
	
	var sig   = flt >> 31;
	var expo  = (flt & ~(1 << 31)) >> 23;
	var mant  = flt & 0b00000000_01111111_11111111_11111111;
	
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
	var dub = int64(b0 + (b1 << 8) + (b2 << 16) + (b3 << 24) + (b2 << 32) + (b3 << 40) + (b2 << 48) + (b3 << 56));
	
	var sig   = dub >> 63;
	var expo  = (dub & ~(1 << 63)) >> 52;
	var mant  = dub & 0b00000000_00001111_11111111_11111111_11111111_11111111_11111111_11111111;
	
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
	return int64(b0 + (b1 << 8) + (b2 << 16) + (b3 << 24) + (b2 << 32) + (b3 << 40) + (b2 << 48) + (b3 << 56));
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
	var lng = int64(b0 + (b1 << 8) + (b2 << 16) + (b3 << 24) + (b2 << 32) + (b3 << 40) + (b2 << 48) + (b3 << 56));
	var sig = lng >> 63;
	lng = lng & ~(1 << 63);
	return sig? -lng : lng;
}

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