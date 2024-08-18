function Node_WAV_File_Write(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "WAV File Out";
	color = COLORS.node_blend_input;
	setDimension(, 72);
	
	newInput(0, nodeValue_Path("Path", self, ""))
		.setDisplay(VALUE_DISPLAY.path_save, { filter: "audio file|*.wav" })
		.rejectArray()
		.setVisible(true);
	
	newInput(1, nodeValue_Float("Audio Data", self, [[]]))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(2, nodeValue_Int("Sample", self, 44100));
	
	newInput(3, nodeValue_Enum_Scroll("Bit Depth", self,  0, [ "8 bit positive", "16 bit integer" ]));
		
	newInput(4, nodeValue_Bool("Remap Data", self, false))
	
	newInput(5, nodeValue_Vec2("Data Range", self, [ 0, 1 ]));
	
	input_display_list = [ 
		[ "Data",	false], 1, 0, 4, 5, 
		[ "Format",	false], 2, 3, 
	]
	
	insp1UpdateTooltip  = "Export";
	insp1UpdateIcon     = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() {
		export();
	}
	
	static step = function() {
		var remap = getInputData(4);
		
		inputs[5].setVisible(remap);
	}
	
	static export = function() {
		var path = getInputData(0);
		var data = getInputData(1);
		var samp = getInputData(2);
		var bitd = getInputData(3) + 1;
		
		var remp = getInputData(4);
		var rern = getInputData(5);
		
		if(!is_array(data)) return;
		
		var _chn = array_length(data);
		var _siz = 0;
		
		for( var i = 0; i < _chn; i++ ) {
			if(!is_array(data[i])) {
				var _txt = "Audio Export: Malformed data. Expects 2D array [channel x number array].";
				logNode(_txt); noti_warning(_txt);
				return;
			}
			var len = array_length(data[i]);
			
			if(_siz && _siz != len) {
				var _txt = "Audio Export: Uneven sample per channel.";
				logNode(_txt); noti_warning(_txt);
				return;
			}
			
			_siz = len;
		}
		
		if(filename_ext(path) != ".wav") path += ".wav";
		
		var buff = buffer_create(1, buffer_grow, 1);
		var _pkg = _chn * _siz * bitd + 12 + 24 + 8;
		
		buffer_write(buff, buffer_text,  "RIFF");
		buffer_write(buff, buffer_u32,   _pkg);	//package size
		buffer_write(buff, buffer_text,  "WAVE");
		
		buffer_write(buff, buffer_text,  "fmt ");
		buffer_write(buff, buffer_u32,    16);		//chunk size
		buffer_write(buff, buffer_u16,     1);		//format
		buffer_write(buff, buffer_u16,  _chn);		//channels
		buffer_write(buff, buffer_u32,  samp);		//sampling rate
		buffer_write(buff, buffer_u32,  samp * bitd);	//data rate
		buffer_write(buff, buffer_u16,  bitd);		//bitrate (byte)
		buffer_write(buff, buffer_u16,  bitd * 8);	//bit per sample
		
		buffer_write(buff, buffer_text,  "data");	//bit per sample
		buffer_write(buff, buffer_u32,  _siz);		//data length
		
		var typ = bitd == 1? buffer_u8 : buffer_s16;
		var rerng = rern[1] - rern[0];
		
		for( var i = 0; i < _siz; i++ )
		for( var j = 0; j < _chn; j++ ) {
			var _dat = data[j][i];
			if(remp) {
				if(bitd == 1)		_dat = (_dat - rern[0]) / rerng * 255;
				else if(bitd == 2)  _dat = (_dat - rern[0]) / rerng * 65535 - 32768;
				_dat = round(_dat);
			}
			
			buffer_write(buff, typ, _dat);
		}
		
		buffer_save(buff, path);
		buffer_delete(buff);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_wav_file_write, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}