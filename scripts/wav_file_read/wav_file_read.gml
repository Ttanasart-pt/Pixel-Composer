function file_read_ASCII(file, amo = 1) {
	var b = "";
	repeat(amo) b += chr(buffer_read(file, buffer_u8));
	return b;
}

function file_read_wav(path) {
	wav_file_reader  = buffer_load(path);
	wav_file_reading = true;
	wav_file_prg = 0;
	
	if(wav_file_reader == -1) {
		noti_warning("File read error.");
		return noone;
	}
	
	wav_file_load_time = current_time;
	var _buffer_size   = buffer_get_size(wav_file_reader);
	
	//RIFF
	var debug_str = $">> READING WAV [{path}] <<\n";
	debug_str += $"Buffer size: {_buffer_size}\n\n";
	
	debug_str += "-- RIFF --\n";
	var b = file_read_ASCII(wav_file_reader, 4);		debug_str += $"{b}\n";
	var l = buffer_read(wav_file_reader, buffer_u32);	debug_str += $"Packages: {l}\n";
	var w = file_read_ASCII(wav_file_reader, 4);		debug_str += $"{w}\n";
	
	if(b != "RIFF" || w != "WAVE") {
		printIf(global.FLAG.wav_import, debug_str);
		noti_warning("Not a valid .wav file.");
		return noone;
	}
	
	if(buffer_get_size(wav_file_reader) != l + 8)
		noti_warning(".wav file has different size than the package header. This may cause reading error.");
	
	//FORMAT
	debug_str += "-- FORMAT --\n";
	var b  = file_read_ASCII(wav_file_reader, 4);		debug_str += $"{b}\n";
	var l  = buffer_read(wav_file_reader, buffer_u32);	debug_str += $"Length:   {l}\n";
	var f  = buffer_read(wav_file_reader, buffer_u16);	debug_str += $"Linear quantize: {f}\n";
	
	if(l != 16 || f != 1) {
		printIf(global.FLAG.wav_import, debug_str);
		noti_warning("File format not supported, the audio file need to be 8, 16, 32 bit uncompressed PCM wav with no extension.");
		return noone;
	}
	
	var ch = buffer_read(wav_file_reader, buffer_u16);	debug_str += $"Channels: {ch}\n";
	var sm = buffer_read(wav_file_reader, buffer_u32);	debug_str += $"Sample:   {sm}\n";
	var l  = buffer_read(wav_file_reader, buffer_u32);	debug_str += $"BPS:   {l}\n";
	var br = buffer_read(wav_file_reader, buffer_u16);	debug_str += $"Byterate: {br}\n";
	var l  = buffer_read(wav_file_reader, buffer_u16);	debug_str += $"Bit/Sam:  {l}\n";
	
	//DATA
	debug_str += "-- DATA --\n";
	var b = file_read_ASCII(wav_file_reader, 4);		debug_str += $"{b}\n";
	var l = buffer_read(wav_file_reader, buffer_u32);	debug_str += $"Length:   {l}\n";
	
	var bpc  = br / ch;
	var bits = l / br;
	var data  = array_create(ch);
	var dataF = [ array_create(bits) ];
	
	debug_str += "-- READ --\n";
	debug_str += $"Channels: {ch}\n";
	debug_str += $"BPC:      {bpc * 8}\n";
	debug_str += $"bits:     {bits}\n";
	debug_str += $"samples:  {sm}\n";
	debug_str += $"duration: {real(bits) / real(sm)}s\n";
	
	for( var j = 0; j < ch; j++ )
		data[j]  = array_create(bits);
	
	wav_file_range = [0, 0];
	
	var _buffer_left = _buffer_size - buffer_tell(wav_file_reader);
	if(_buffer_left < l) {
		noti_warning($"The file is smaller than the definded length. ({_buffer_left} < {l})");
		bits = floor(_buffer_left / br);
	}
	
	content = new audioObject(sm, ch);
	content.sound     = data;
	content.soundF    = dataF;
	content.bit_depth = bpc * 8;
	content.duration  = real(bits) / real(sm);
	content.packet 	  = bits;
	
	printIf(global.FLAG.wav_import, debug_str);
	logNode(debug_str);
	
	print($"Reading buffer {bits} pack from data length {l} with remaining data {_buffer_left}");
	
	return content;
}

function file_read_wav_step() {
	if(!wav_file_reading) return false;
	if(!content)          return false;
	
	var t = current_time;
	var bf_type, lim;
	if(content.bit_depth == 8)		 { bf_type = buffer_u8;	 lim =           255; }
	else if(content.bit_depth == 16) { bf_type = buffer_s16; lim =        32_768; }
	else if(content.bit_depth == 32) { bf_type = buffer_s32; lim = 2_147_483_648; }
	
	// print($"Reading {wav_file_prg} to {content.packet} ({content.packet - wav_file_prg}) with remaining data {(buffer_get_size(wav_file_reader) - buffer_tell(wav_file_reader)) / (content.bit_depth / 8)}");
	while(wav_file_prg < content.packet) {
		var ch  = 0;
		var cha = content.channels;
		var j   = 0;
		
		repeat( cha ) {
			var b = buffer_read(wav_file_reader, bf_type) / lim;
			ch += b;
			content.sound[j][wav_file_prg] = b;
			j++;
		}
		
		content.soundF[0][wav_file_prg] = ch / content.channels;
		wav_file_prg++;
		
		if(current_time - t > 1000 / 30) return false;
	}
	
	//printIf(global.FLAG.wav_import, $"Wav range: {wav_file_range}");
	printIf(global.FLAG.wav_import, $"Load file complete in: {(current_time - wav_file_load_time) / 1000} s.");
	
	wav_file_reading = false;
	buffer_delete(wav_file_reader);
	return true;
}