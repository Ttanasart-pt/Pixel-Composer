function file_read_ASCII(file, amo = 1) {
	var b = "";
	repeat(amo)
		b += chr(buffer_read(file, buffer_u8));
		//b += chr(file_bin_read_byte(file));
	return b;
}

function file_read_bytes(file, amo = 1, signed = false, little_endian = true) {
	var b = 0;
	var m = little_endian? 1 : 1 << ((amo - 1) * 8);
	repeat(amo) {
		//b += file_bin_read_byte(file) * m;
		b += buffer_read(file, buffer_u8) * m;
		m  = little_endian? m * 256 : m / 256;
	}
	
	if(signed) {
		var mv = 1 << (amo * 8 - 1) - 1;
		if(b > mv)
			b -= (1 << (amo * 8));
	}
	
	return b;
}

global.FLAG.wav_import = true;

function file_read_wav(path) {
	wav_file_reader = buffer_load(path);
	wav_file_reading = true;
	wav_file_prg = 0;
	
	wav_file_load_time = current_time;
	
	//RIFF
	printIf(global.FLAG.wav_import, "-- RIFF --")
	var b = file_read_ASCII(wav_file_reader, 4);		printIf(global.FLAG.wav_import, b);
	var l = buffer_read(wav_file_reader, buffer_u32);	printIf(global.FLAG.wav_import, $"Packages: {l}");
	var w = file_read_ASCII(wav_file_reader, 4);		printIf(global.FLAG.wav_import, w);
	
	//FORMAT
	printIf(global.FLAG.wav_import, "-- FORMAT --")
	var b  = file_read_ASCII(wav_file_reader, 4);		printIf(global.FLAG.wav_import, b);
	var l  = buffer_read(wav_file_reader, buffer_u32);	printIf(global.FLAG.wav_import, $"Length:   {l}");
	
	if(l != 16) {
		noti_warning("File format not supported, the audio file need to be 8, 16 bit PCM wav with no extension.");
		return noone;
	}
	
	var l  = buffer_read(wav_file_reader, buffer_u16);	printIf(global.FLAG.wav_import, $"0x01:     {l}");
	var ch = buffer_read(wav_file_reader, buffer_u16);	printIf(global.FLAG.wav_import, $"Channels: {ch}");
	var sm = buffer_read(wav_file_reader, buffer_u32);	printIf(global.FLAG.wav_import, $"Sample:   {sm}");
	var l  = buffer_read(wav_file_reader, buffer_u32);	printIf(global.FLAG.wav_import, $"BPS:	    {l}");
	var br = buffer_read(wav_file_reader, buffer_u16);	printIf(global.FLAG.wav_import, $"Bitrate:  {br}");
	var l  = buffer_read(wav_file_reader, buffer_u16);	printIf(global.FLAG.wav_import, $"Bit/Sam:  {l}");
	
	//DATA
	printIf(global.FLAG.wav_import, "-- DATA --")
	var b = file_read_ASCII(wav_file_reader, 4);		printIf(global.FLAG.wav_import, b);
	var l = buffer_read(wav_file_reader, buffer_u32);	printIf(global.FLAG.wav_import, $"Length:   {l}");
	
	var bpc  = br / ch;
	var bits = l / br;
	var data = array_create(ch);
	
	printIf(global.FLAG.wav_import, "-- READ --")
	printIf(global.FLAG.wav_import, $"Channels: {ch}");
	printIf(global.FLAG.wav_import, $"BPC:      {bpc * 8}");
	printIf(global.FLAG.wav_import, $"bits:     {bits}");
	printIf(global.FLAG.wav_import, $"duration: {bits / sm}");
	
	printIf(global.FLAG.wav_import, $"-- READING DATA --");
	for( var j = 0; j < ch; j++ ) 
		data[j] = array_create(bits);
	
	wav_file_range = [0, 0];
	content = {
		sound:		data,
		sample:		sm,
		channels:	ch,
		bit_depth:	bpc * 8,
		duration:	bits / sm,
		packet:		bits,
	};
	
	return content;
}

function file_read_wav_step() {
	if(!wav_file_reading) return false;
	
	var t = current_time;
	var bf_type, lim;
	if(content.bit_depth == 8)		 { bf_type = buffer_u8;	 lim =           255; }
	else if(content.bit_depth == 16) { bf_type = buffer_s16; lim =        32_768; }
	else if(content.bit_depth == 32) { bf_type = buffer_s32; lim = 2_147_483_648; }
	
	for(; wav_file_prg < content.packet; wav_file_prg++ ) {
		for( var j = 0; j < content.channels; j++ )
			content.sound[j][wav_file_prg] = buffer_read(wav_file_reader, bf_type) / lim;
		
		//wav_file_range[0] = min(wav_file_range[0], content.sound[0][wav_file_prg]);
		//wav_file_range[1] = max(wav_file_range[1], content.sound[0][wav_file_prg]);
		
		if(current_time - t > 1000 / 30) return false;
	}
	
	//printIf(global.FLAG.wav_import, $"Wav range: {wav_file_range}");
	printIf(global.FLAG.wav_import, $"Load file complete in: {(current_time - wav_file_load_time) / 1000} s.");
	
	wav_file_reading = false;
	buffer_delete(wav_file_reader);
	return true;
}