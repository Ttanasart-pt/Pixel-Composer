function file_read_ASCII(file, amo = 1) {
	var b = "";
	repeat(amo)
		b += chr(file_bin_read_byte(file));
	return b;
}

function file_read_bytes(file, amo = 1, signed = false, little_endian = true) {
	var b = 0;
	var m = little_endian? 1 : 1 << ((amo - 1) * 8);
	repeat(amo) {
		b += file_bin_read_byte(file) * m;
		m  = little_endian? m * 256 : m / 256;
	}
	
	if(signed) {
		var mv = 1 << (amo * 8 - 1) - 1;
		if(b > mv)
			b -= (1 << (amo * 8));
	}
	
	return b;
}

global.DEBUG_FLAG.wav_import = true;

function file_read_wav(path) {
	var f = file_bin_open(path, 0);

	//RIFF
	printIf(global.DEBUG_FLAG.wav_import, "-- RIFF --")
	var b = file_read_ASCII(f, 4);		printIf(global.DEBUG_FLAG.wav_import, b);
	var l = file_read_bytes(f, 4);		printIf(global.DEBUG_FLAG.wav_import, $"Packages: {l}");
	var w = file_read_ASCII(f, 4);		printIf(global.DEBUG_FLAG.wav_import, w);

	//FORMAT
	printIf(global.DEBUG_FLAG.wav_import, "-- FORMAT --")
	var b  = file_read_ASCII(f, 4);		printIf(global.DEBUG_FLAG.wav_import, b);
	var l  = file_read_bytes(f, 4);		printIf(global.DEBUG_FLAG.wav_import, $"Length:   {l}");
	var l  = file_read_bytes(f, 2);		printIf(global.DEBUG_FLAG.wav_import, $"0x01:     {l}");
	var ch = file_read_bytes(f, 2);		printIf(global.DEBUG_FLAG.wav_import, $"Channels: {ch}");
	var sm = file_read_bytes(f, 4);		printIf(global.DEBUG_FLAG.wav_import, $"Sample:   {sm}");
	var l  = file_read_bytes(f, 4);		printIf(global.DEBUG_FLAG.wav_import, $"BPS:	   {l}");
	var br = file_read_bytes(f, 2);		printIf(global.DEBUG_FLAG.wav_import, $"Bitrate:  {br}");
	var l  = file_read_bytes(f, 2);		printIf(global.DEBUG_FLAG.wav_import, $"Bit/Sam:  {l}");

	//DATA
	printIf(global.DEBUG_FLAG.wav_import, "-- DATA --")
	var b = file_read_ASCII(f, 4);		printIf(global.DEBUG_FLAG.wav_import, b);
	var l = file_read_bytes(f, 4);		printIf(global.DEBUG_FLAG.wav_import, $"Length:   {l}");

	var bpc  = br / ch;
	var bits = l / br;
	var data = array_create(ch);
	var lim  = 1 << (8 * bpc - 2);

	printIf(global.DEBUG_FLAG.wav_import, "-- READ --")
	printIf(global.DEBUG_FLAG.wav_import, $"Channels: {ch}");
	printIf(global.DEBUG_FLAG.wav_import, $"BPC:      {bpc * 8}");
	printIf(global.DEBUG_FLAG.wav_import, $"bits:     {bits}");
	printIf(global.DEBUG_FLAG.wav_import, $"lim:      {lim}");
	printIf(global.DEBUG_FLAG.wav_import, $"duration: {bits / sm}");

	var _mn = 0, _mx = 0;
	for( var i = 0; i < bits; i++ )
	for( var j = 0; j < ch; j++ ) {
		data[j][i] = file_read_bytes(f, bpc, true) / lim;
		_mn = min(_mn, data[j][i]);
		_mx = max(_mx, data[j][i]);
	}
	
	file_bin_close(f);
	
	return {
		sound:		data,
		sample:		sm,
		channels:	ch,
		bit_depth:	bpc * 8,
		duration:	bits / sm,
	};
}