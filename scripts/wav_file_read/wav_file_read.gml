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
	var format = false;
	var b  = file_read_ASCII(wav_file_reader, 4);		debug_str += $"{b}\n"; 
	while(b != "data") {
		if(b == "fmt ") {
			format = true;
			var l  = buffer_read(wav_file_reader, buffer_u32);	debug_str += $"Length:   {l}\n";
			var f  = buffer_read(wav_file_reader, buffer_u16);	debug_str += $"Linear quantize: {f}\n";
			
			if(l != 16 || f != 1) {
				printIf(global.FLAG.wav_import, debug_str);
				noti_warning("File format not supported, the audio file need to be 8, 16, 32 bit uncompressed PCM wav with no extension.");
				return noone;
			}
			
			var ch = buffer_read(wav_file_reader, buffer_u16);	debug_str += $"Channels:    {ch}\n";
			var sm = buffer_read(wav_file_reader, buffer_u32);	debug_str += $"Sample rate: {sm}\n";
			var dt = buffer_read(wav_file_reader, buffer_u32);	debug_str += $"Data rate:   {dt}\n";
			var br = buffer_read(wav_file_reader, buffer_u16);	debug_str += $"Block size:  {br}\n";
			var bs = buffer_read(wav_file_reader, buffer_u16);	debug_str += $"Bit/Sam:     {bs}\n";
			
		} else {
			var o  = buffer_read(wav_file_reader, buffer_u32);	debug_str += $"Offset:   {o}\n";
			repeat(o) buffer_read(wav_file_reader, buffer_u8);
		}
		
		var b = file_read_ASCII(wav_file_reader, 4);		debug_str += $"{b}\n";
	}
	
	if(!format) { 
		printIf(global.FLAG.wav_import, debug_str);
		noti_warning("Canot find format data");
		return noone;
	}
	
	//DATA
	debug_str += "-- DATA --\n";
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
	content.sound      = data;
	content.soundMono  = dataF;
	content.duration   = real(bits) / real(sm);
	content.packet 	   = bits;
	
	content.bit_depth  = bpc * 8;
	content.bit_sample = bs;
	content.bit_range  = power(2, content.bit_sample - 1);
	
	printIf(global.FLAG.wav_import, debug_str);
	logNode(debug_str);
	
	// print($"Reading buffer {bits} pack from data length {l} with remaining data {_buffer_left}");
	
	return content;
}

function file_read_wav_step() {
	if(!wav_file_reading) return false;
	if(!content)          return false;
	
	var t       = current_time;
	var norm    = content.bit_range;
	var bf_type = undefined;
	
	switch(content.bit_depth) {
		case  8 : bf_type = buffer_u8;  break;
		case 16 : bf_type = buffer_s16; break;
		case 32 : bf_type = buffer_s32; break;
		
		default :
			noti_warning($"Bit depth {content.bit_depth} not supported, the audio file need to be 8, 16, 32 bit uncompressed PCM wav with no extension.");
			return true;
	}
	
	// print($"Reading {wav_file_prg} to {content.packet} ({content.packet - wav_file_prg}) with remaining data {(buffer_get_size(wav_file_reader) - buffer_tell(wav_file_reader)) / (content.bit_depth / 8)}");
	while(wav_file_prg < content.packet) {
		var ch  = 0;
		var cha = content.channels;
		var i   = 0;
		
		repeat( cha ) {
			var b = buffer_read(wav_file_reader, bf_type);
			content.sound[i++][wav_file_prg] = b / norm;
			ch += b;
		}
		
		content.soundMono[0][wav_file_prg] = ch / content.channels / norm;
		wav_file_prg++;
		
		if(current_time - t > 1000 / 30) return false;
	}
	
	//printIf(global.FLAG.wav_import, $"Wav range: {wav_file_range}");
	printIf(global.FLAG.wav_import, $"Load file complete in: {(current_time - wav_file_load_time) / 1000} s.");
	
	wav_file_reading = false;
	buffer_delete(wav_file_reader);
	return true;
}

function WAV_get_length(path) {
	var _wav = buffer_load(path);
	if(_wav == -1) return -1; 
	
	var _buffer_size   = buffer_get_size(_wav);
	
	//RIFF
	var debug_str = $">> READING WAV [{path}] <<\n";
	debug_str += $"Buffer size: {_buffer_size}\n\n";
	
	debug_str += "-- RIFF --\n";
	var b = file_read_ASCII(_wav, 4);		debug_str += $"{b}\n";
	var l = buffer_read(_wav, buffer_u32);	debug_str += $"Packages: {l}\n";
	var w = file_read_ASCII(_wav, 4);		debug_str += $"{w}\n";
	if(b != "RIFF" || w != "WAVE") { print(debug_str); return -2; }
	
	if(buffer_get_size(_wav) != l + 8)
		noti_warning(".wav file has different size than the package header. This may cause reading error.");
	
	//FORMAT
	debug_str += "-- FORMAT --\n";
	var format = false;
	var b  = file_read_ASCII(_wav, 4);		debug_str += $"{b}\n"; 
	while(b != "data") {
		if(b == "fmt ") {
			format = true;
			var l  = buffer_read(_wav, buffer_u32);	debug_str += $"Length:   {l}\n";
			var f  = buffer_read(_wav, buffer_u16);	debug_str += $"Linear quantize: {f}\n";
			
			if(l != 16 || f != 1) { print(debug_str); return -3; }
			
			var ch = buffer_read(_wav, buffer_u16);	debug_str += $"Channels:    {ch}\n";
			var sm = buffer_read(_wav, buffer_u32);	debug_str += $"Sample rate: {sm}\n";
			var dt = buffer_read(_wav, buffer_u32);	debug_str += $"Data rate:   {dt}\n";
			var br = buffer_read(_wav, buffer_u16);	debug_str += $"Block size:  {br}\n";
			var bs = buffer_read(_wav, buffer_u16);	debug_str += $"Bit/Sam:     {bs}\n";
			
		} else {
			var o  = buffer_read(_wav, buffer_u32);	debug_str += $"Offset:   {o}\n";
			repeat(o) buffer_read(_wav, buffer_u8);
		}
		
		var b = file_read_ASCII(_wav, 4);		debug_str += $"{b}\n";
	}
	
	if(!format) { print(debug_str); return -3; }
		
	//DATA
	debug_str += "-- DATA --\n";
	var l = buffer_read(_wav, buffer_u32);	debug_str += $"Length:   {l}\n";
	
	var bits = l / br;
	
	var _duration = real(bits) / real(sm);
	return _duration;
}