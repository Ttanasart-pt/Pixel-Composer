// Generated at 2020-10-11 11:48:54 (313ms) for vnull+
#region metatype
	globalvar gif_std_haxe_type_markerValue; gif_std_haxe_type_markerValue = [];
	globalvar mt_Gif; mt_Gif = new gif_std_haxe_class(-1, "Gif");
	globalvar mt_GifFrame; mt_GifFrame = new gif_std_haxe_class(-1, "GifFrame");
	globalvar mt_GifReader; mt_GifReader = new gif_std_haxe_class(-1, "GifReader");
	globalvar mt_format_gif_Block; mt_format_gif_Block = new gif_std_haxe_enum(-1, "format_gif_Block");
	globalvar mt_format_gif_Extension; mt_format_gif_Extension = new gif_std_haxe_enum(-1, "format_gif_Extension");
	globalvar mt_format_gif_ApplicationExtension; mt_format_gif_ApplicationExtension = new gif_std_haxe_enum(-1, "format_gif_ApplicationExtension");
	globalvar mt_format_gif_Version; mt_format_gif_Version = new gif_std_haxe_enum(-1, "format_gif_Version");
	globalvar mt_format_gif_DisposalMethod; mt_format_gif_DisposalMethod = new gif_std_haxe_enum(-1, "format_gif_DisposalMethod");
	globalvar mt_gif_std_haxe_class; mt_gif_std_haxe_class = new gif_std_haxe_class(-1, "gif_std_haxe_class");
	globalvar mt_gif_std_haxe_enum; mt_gif_std_haxe_enum = new gif_std_haxe_class(-1, "gif_std_haxe_enum");
	globalvar mt_gif_std_haxe_io_Bytes; mt_gif_std_haxe_io_Bytes = new gif_std_haxe_class(-1, "gif_std_haxe_io_Bytes");
	globalvar mt_haxe_io_Input; mt_haxe_io_Input = new gif_std_haxe_class(-1, "haxe_io_Input");
	globalvar mt_haxe_io_BytesInput; mt_haxe_io_BytesInput = new gif_std_haxe_class(-1, "haxe_io_BytesInput");
	mt_haxe_io_BytesInput.superClass = mt_haxe_io_Input;
	globalvar mt_haxe_io_Output; mt_haxe_io_Output = new gif_std_haxe_class(-1, "haxe_io_Output");
	globalvar mt_haxe_io_BytesOutput; mt_haxe_io_BytesOutput = new gif_std_haxe_class(-1, "haxe_io_BytesOutput");
	mt_haxe_io_BytesOutput.superClass = mt_haxe_io_Output;
#endregion

function gif_std_enum_toString() {
	return gif_std_Std_stringify(self);
}
function gif_std_enum_getIndex() {
	return __enumIndex__;
}

#region Gif
	function Gif() constructor {
		static frames = undefined;
		static width = undefined;
		static height = undefined;
		static loops = undefined;
		static destroy = function() {
			var __g = 0;
			var __g1 = self.frames;
			var len = array_length(__g1);
			
			while (__g < len) {
				var _frame = __g1[__g];
				__g++;
				_frame.destroy();
			}
		}
		
		reader_data = undefined;
		
		static readBegin = function(_gif_buffer) {
			var _n = buffer_get_size(_gif_buffer);
			var _bytes = new gif_std_haxe_io_Bytes(array_create(_n, 0));
			var _i = 0;
			for (var __g1 = _n; _i < __g1; _i++) {
				var _v = buffer_peek(_gif_buffer, _i, buffer_u8);
				_bytes.b[@_i] = (_v & 255);
			}
			var _input = new haxe_io_BytesInput(_bytes, 0, _n);
			reader_data = new GifReader(_input);
			reader_data.readBegin();
		}
		
		static reading = function() {
			var res = reader_data.reading(self);
			if(res) readComplete();
			return res;
		}
		
		static readComplete = function() {
			width = reader_data.logicalScreenDescriptor.width;
			height = reader_data.logicalScreenDescriptor.height;
			var _gce = undefined;
			var _globalColorTable = undefined;
			if (reader_data.globalColorTable != undefined) 
				_globalColorTable = _Gif_GifTools_colorTableToVector(reader_data.globalColorTable, reader_data.logicalScreenDescriptor.globalColorTableSize);
			var __break = false;
			var __g = 0;
			var __g1 = reader_data.blocks;
			while (__g < array_length(__g1)) {
				var _block = __g1[__g];
				__g++;
				switch (_block.__enumIndex__/* format_gif_Block */) {
					case 0/* BFrame */:
						var _f = _block.frame;
						var _gf = new GifFrame();
						var _transparentIndex = -1;
						if (_gce != undefined) {
							_gf.delay = _gce.delay;
							if (_gce.hasTransparentColor) _transparentIndex = _gce.transparentIndex;
							switch (_gce.disposalMethod.__enumIndex__/* format_gif_DisposalMethod */) {
								case 2/* FILL_BACKGROUND */: _gf.disposalMethod = 1; break;
								case 3/* RENDER_PREVIOUS */: _gf.disposalMethod = 2; break;
							}
						}
						_gf.x = _f.x;
						_gf.y = _f.y;
						_gf.width = _f.width;
						_gf.height = _f.height;
						var _colorTable = _globalColorTable;
						if (_f.colorTable != undefined) _colorTable = _Gif_GifTools_colorTableToVector(_f.colorTable, _f.localColorTableSize);
						var _buf = buffer_create(_f.width * _f.height * 4, buffer_fixed, 1);
						var _i = 0;
						for (var __g3 = array_length(_f.pixels.b); _i < __g3; _i++) {
							var _col = _f.pixels.b[_i];
							if (_col == _transparentIndex) buffer_write(_buf, buffer_s32, 0); else buffer_write(_buf, buffer_s32, _colorTable[_col]);
						}
						_gf.buffer = _buf;
						var _sf = surface_create(_f.width, _f.height);
						gif_std_gml_io__Buffer_BufferImpl_setSurface(_buf, _sf, 0);
						_gf.surface = _sf;
						_gce = undefined;
						gif_std_gml_internal_ArrayImpl_push(self.frames, _gf);
						break;
					case 1/* BExtension */:
						var __g4 = _block.extension;
						switch (__g4.__enumIndex__/* format_gif_Extension */) {
							case 3/* EApplicationExtension */:
								var __g5 = __g4.ext;
								if (__g5.__enumIndex__/* format_gif_ApplicationExtension */ == 0/* AENetscapeLooping */) {
									var _n = __g5.loops;
									self.loops = _n;
								}
								break;
							case 0/* EGraphicControl */: _gce = __g4.gce; break;
						}
						break;
					case 2/* BEOF */: __break = true; break;
				}
				if (__break) break;
			}
		}
		
		self.loops = -1;
		self.height = 0;
		self.width = 0;
		self.frames = [];
		static __class__ = mt_Gif;
	}
	mt_Gif.i_constructor = Gif;

	function sprite_add_gif(_path1, _return_func) {
		if (false) throw argument[3];
		
		var _buf = buffer_load(_path1);
		var _gif = new Gif();
		_gif.readBegin(_buf);
		ds_list_add(GIF_READER, [_gif, _buf, _return_func] );
	}
	
	function __gif_sprite_builder(_gif) constructor {
		gif = _gif;
		_sf = surface_create(gif.width, gif.height);
		//show_debug_message("gif creation: width = " + string(_gif.width));
		_restoreBuf = -1;
		_spr = -1;
		spr_size = 0;
		_white32 = Gif_white32;
		if (_white32 == -1) {
			var _ws = surface_create(32, 32);
			surface_set_target(_ws);
			draw_clear(16777215);
			surface_reset_target();
			_white32 = sprite_create_from_surface(_ws, 0, 0, surface_get_width(_ws), surface_get_height(_ws), false, false, 0, 0);
			surface_free(_ws);
			Gif_white32 = _white32;
		}
		__color = draw_get_color();
		__alpha = draw_get_alpha();
		draw_set_color(16777215);
		draw_set_alpha(1);
		_firstDelay = 0;
		__g = 0;
		__g1 = gif.frames;
		amo = array_length(__g1);
		
		static building = function() {
			var _frame = __g1[__g++];
			if (_frame.disposalMethod == 2) {
				if (_restoreBuf == -1) _restoreBuf = buffer_create(gif.width * gif.height * 4, buffer_fixed, 1);
				gif_std_gml_io__Buffer_BufferImpl_getSurface(_restoreBuf, _sf, 0);
			}
			surface_copy(_sf, _frame.x, _frame.y, _frame.surface);
			
			if (_spr == -1) {
				_spr = sprite_create_from_surface(_sf, 0, 0, surface_get_width(_sf), surface_get_height(_sf), false, false, 0, 0); 
			} else {
				//spr_size = sprite_get_width(_spr) * sprite_get_height(_spr) * sprite_get_number(_spr);
				//show_debug_message(string(spr_size));
				sprite_add_from_surface(_spr, _sf, 0, 0, surface_get_width(_sf), surface_get_height(_sf), false, false);
			}
				
			var _fdelay = _frame.delay;
			if (_firstDelay <= 0 && _fdelay > 0) _firstDelay = _fdelay;
			switch (_frame.disposalMethod) {
				case 2: gif_std_gml_io__Buffer_BufferImpl_setSurface(_restoreBuf, _sf, 0); break;
				case 1:
					surface_set_target(_sf);
					var _mode = bm_subtract;
					gpu_set_blendmode(_mode);
					draw_sprite_stretched(_white32, 0, _frame.x, _frame.y, _frame.width, _frame.height);
					var _mode1 = bm_normal;
					gpu_set_blendmode(_mode1);
					surface_reset_target();
					break;
			}
			
			if(__g >= amo) {
				buildComplete();
				return true;
			}
			
			return false;
		}
		
		static buildComplete = function() {
			if (_firstDelay > 0) sprite_set_speed(_spr, 100 / _firstDelay, spritespeed_framespersecond);
			draw_set_color(__color);
			draw_set_alpha(__alpha);
			if (_restoreBuf != -1) buffer_delete(_restoreBuf);
			gif.destroy();
			surface_free(_sf);
		}
	}
	
	function __gif_create_sprite(_gif) {
		var _sf = surface_create(_gif.width, _gif.height);
		//show_debug_message("gif creation: width = " + string(_gif.width));
		var _restoreBuf = -1;
		var _spr = -1;
		var spr_size = 0;
		var _white32 = Gif_white32;
		if (_white32 == -1) {
			var _ws = surface_create(32, 32);
			surface_set_target(_ws);
			draw_clear(16777215);
			surface_reset_target();
			_white32 = sprite_create_from_surface(_ws, 0, 0, surface_get_width(_ws), surface_get_height(_ws), false, false, 0, 0);
			surface_free(_ws);
			Gif_white32 = _white32;
		}
		var __color = draw_get_color();
		var __alpha = draw_get_alpha();
		draw_set_color(16777215);
		draw_set_alpha(1);
		var _firstDelay = 0;
		var __g = 0;
		var __g1 = _gif.frames;
		var amo = array_length(__g1);
		for( var __g = 0; __g < amo; __g++ ) {
			var _frame = __g1[__g];
			if (_frame.disposalMethod == 2) {
				if (_restoreBuf == -1) _restoreBuf = buffer_create(_gif.width * _gif.height * 4, buffer_fixed, 1);
				gif_std_gml_io__Buffer_BufferImpl_getSurface(_restoreBuf, _sf, 0);
			}
			surface_copy(_sf, _frame.x, _frame.y, _frame.surface);
			
			if (_spr == -1) {
				_spr = sprite_create_from_surface(_sf, 0, 0, surface_get_width(_sf), surface_get_height(_sf), false, false, 0, 0); 
			} else {
				//spr_size = sprite_get_width(_spr) * sprite_get_height(_spr) * sprite_get_number(_spr);
				//show_debug_message(string(spr_size));
				sprite_add_from_surface(_spr, _sf, 0, 0, surface_get_width(_sf), surface_get_height(_sf), false, false);
			}
				
			var _fdelay = _frame.delay;
			if (_firstDelay <= 0 && _fdelay > 0) _firstDelay = _fdelay;
			switch (_frame.disposalMethod) {
				case 2: gif_std_gml_io__Buffer_BufferImpl_setSurface(_restoreBuf, _sf, 0); break;
				case 1:
					surface_set_target(_sf);
					var _mode = bm_subtract;
					gpu_set_blendmode(_mode);
					draw_sprite_stretched(_white32, 0, _frame.x, _frame.y, _frame.width, _frame.height);
					var _mode1 = bm_normal;
					gpu_set_blendmode(_mode1);
					surface_reset_target();
					break;
			}
		}
		if (_firstDelay > 0) sprite_set_speed(_spr, 100 / _firstDelay, spritespeed_framespersecond);
		draw_set_color(__color);
		draw_set_alpha(__alpha);
		if (_restoreBuf != -1) buffer_delete(_restoreBuf);
		_gif.destroy();
		surface_free(_sf);
		return _spr;
	}
#endregion

#region GifFrame
	function GifFrame() constructor {
		static delay = undefined;
		static surface = undefined;
		static buffer = undefined;
		/* static */x = undefined;
		/* static */y = undefined;
		static width = undefined;
		static height = undefined;
		static disposalMethod = undefined;
		static destroy = function() {
			if (surface_exists(self.surface)) {
				surface_free(self.surface);
			}
			buffer_delete(self.buffer);
		}
		self.disposalMethod = 0;
		self.delay = 0;
		static __class__ = mt_GifFrame;
	}
	mt_GifFrame.i_constructor = GifFrame;
#endregion

#region _Gif.GifTools
	function _Gif_GifTools_colorTableToVector(_pal, _num) {
		var _r, _g, _b;
		var _p = 0;
		var _a = 255;
		var _this1 = array_create(_num, undefined);
		var _vec = _this1;
		var _i = 0;
		for (var __g1 = _num; _i < __g1; _i++) {
			_r = _pal.b[_p];
			_g = _pal.b[_p + 1];
			_b = _pal.b[_p + 2];
			var _val = ((((_a << 24) | (_b << 16)) | (_g << 8)) | _r);
			_vec[@_i] = _val;
			_p += 3;
		}
		return _vec;
	}
#endregion

#region GifReader
	function GifReader(_i) constructor {
		static i = undefined;
		block_index = 0;
		blocks = [];
		
		static readBegin = function() {
			var _b = 71;
			if (self.i.readByte() != _b) throw string("Invalid header");
			var _b = 73;
			if (self.i.readByte() != _b) throw string("Invalid header");
			var _b = 70;
			if (self.i.readByte() != _b) throw string("Invalid header");
			var _gifVer = self.i.readString(3);
			var _version = format_gif_Version_GIF89a;
			switch (_gifVer) {
				case "87a": _version = format_gif_Version_GIF87a; break;
				case "89a": _version = format_gif_Version_GIF89a; break;
				default: _version = format_gif_Version_Unknown(_gifVer);
			}
			var _width = self.i.readUInt16();
			var _height = self.i.readUInt16();
			var _packedField = self.i.readByte();
			var _bgIndex = self.i.readByte();
			var _pixelAspectRatio = self.i.readByte();
			if (_pixelAspectRatio != 0) _pixelAspectRatio = (_pixelAspectRatio + 15) / 64; else _pixelAspectRatio = 1;
			var _lsd = {
				width: _width,
				height: _height,
				hasGlobalColorTable: (_packedField & 128) == 128,
				colorResolution: ((((_packedField & 112) & $FFFFFFFF) >> 4)),
				sorted: (_packedField & 8) == 8,
				globalColorTableSize: (2 << (_packedField & 7)),
				backgroundColorIndex: _bgIndex,
				pixelAspectRatio: _pixelAspectRatio
			}
			var _gct = undefined;
			if (_lsd.hasGlobalColorTable) _gct = self.readColorTable(_lsd.globalColorTableSize);
			
			version = _version;
			logicalScreenDescriptor = _lsd;
			globalColorTable = _gct;
		}
		static reading = function(_gif) {
			var _b = self.readBlock();
			blocks[@ block_index++] = _b;
			show_debug_message("reading block " + string(block_index));
			if (_b == format_gif_Block_BEOF)
				return true;
			return false;
		}
		
		static readBlock = function() {
			var _blockID = self.i.readByte();
			switch (_blockID) {
				case 44: return self.readImage();
				case 33: return self.readExtension();
				case 59: return format_gif_Block_BEOF;
			}
			return format_gif_Block_BEOF;
		}
		static readImage = function() {
			var _x = self.i.readUInt16();
			var _y = self.i.readUInt16();
			var _width = self.i.readUInt16();
			var _height = self.i.readUInt16();
			var _packed = self.i.readByte();
			var _localColorTable = (_packed & 128) == 128;
			var _interlaced = (_packed & 64) == 64;
			var _sorted = (_packed & 32) == 32;
			var _localColorTableSize = (2 << (_packed & 7));
			var _lct = undefined;
			if (_localColorTable) _lct = self.readColorTable(_localColorTableSize);
			return format_gif_Block_BFrame({
				x: _x,
				y: _y,
				width: _width,
				height: _height,
				localColorTable: _localColorTable,
				interlaced: _interlaced,
				sorted: _sorted,
				localColorTableSize: _localColorTableSize,
				pixels: self.readPixels(_width, _height, _interlaced),
				colorTable: _lct
			});
		}
		static readPixels = function(_width, _height, _interlaced) {
			var _input = self.i;
			var _pixelsCount = _width * _height;
			var _pixels = new gif_std_haxe_io_Bytes(array_create(_pixelsCount, 0));
			var _minCodeSize = _input.readByte();
			var _blockSize = _input.readByte() - 1;
			var _bits = _input.readByte();
			var _bitsCount = 8;
			var _clearCode = (1 << _minCodeSize);
			var _eoiCode = _clearCode + 1;
			var _codeSize = _minCodeSize + 1;
			var _codeSizeLimit = (1 << _codeSize);
			var _codeMask = _codeSizeLimit - 1;
			var _baseDict = [];
			var _i = 0;
			for (var __g1 = _clearCode; _i < __g1; _i++) {
				_baseDict[@_i] = [_i];
			}
			var _dict = [];
			var _dictLen = _clearCode + 2;
			var _newRecord;
			var _i = 0;
			var _code = 0;
			var _last;
			while (_i < _pixelsCount) {
				_last = _code;
				while (_bitsCount < _codeSize) {
					if (_blockSize == 0) break;
					_bits |= (_input.readByte() << _bitsCount);
					_bitsCount += 8;
					_blockSize--;
					if (_blockSize == 0) _blockSize = _input.readByte();
				}
				_code = (_bits & _codeMask);
				_bits = _bits >> _codeSize;
				_bitsCount -= _codeSize;
				if (_code == _clearCode) {
					_dict = gif_std_gml_internal_ArrayImpl_copy(_baseDict);
					_dictLen = _clearCode + 2;
					_codeSize = _minCodeSize + 1;
					_codeSizeLimit = (1 << _codeSize);
					_codeMask = _codeSizeLimit - 1;
					continue;
				}
				if (_code == _eoiCode) break;
				if (_code < _dictLen) {
					if (_last != _clearCode) {
						_newRecord = gif_std_gml_internal_ArrayImpl_copy(_dict[_last]);
						gif_std_gml_internal_ArrayImpl_push(_newRecord, _dict[_code][0]);
						_dict[@_dictLen++] = _newRecord;
					}
				} else {
					if (_code != _dictLen) throw string("Invalid LZW code. Excepted: " + string(_dictLen) + ", got: " + string(_code));
					_newRecord = gif_std_gml_internal_ArrayImpl_copy(_dict[_last]);
					gif_std_gml_internal_ArrayImpl_push(_newRecord, _newRecord[0]);
					_dict[@_dictLen++] = _newRecord;
				}
				_newRecord = _dict[_code];
				var __g = 0;
				while (__g < array_length(_newRecord)) {
					var _item = _newRecord[__g];
					__g++;
					_pixels.b[@_i++] = (_item & 255);
				}
				if (_dictLen == _codeSizeLimit && _codeSize < 12) {
					_codeSize++;
					_codeSizeLimit = (1 << _codeSize);
					_codeMask = _codeSizeLimit - 1;
				}
			}
			while (_blockSize > 0) {
				_input.readByte();
				_blockSize--;
				if (_blockSize == 0) _blockSize = _input.readByte();
			}
			while (_i < _pixelsCount) {
				_pixels.b[@_i++] = 0;
			}
			if (_interlaced) {
				var _buffer1 = new gif_std_haxe_io_Bytes(array_create(_pixelsCount, 0));
				var _offset = self.deinterlace(_pixels, _buffer1, 8, 0, 0, _width, _height);
				_offset = self.deinterlace(_pixels, _buffer1, 8, 4, _offset, _width, _height);
				_offset = self.deinterlace(_pixels, _buffer1, 4, 2, _offset, _width, _height);
				self.deinterlace(_pixels, _buffer1, 2, 1, _offset, _width, _height);
				_pixels = _buffer1;
			}
			return _pixels;
		}
		static deinterlace = function(_input, _output, _step, _y, _offset, _width, _height) {
			while (_y < _height) {
				array_copy(_output.b, _y * _width, _input.b, _offset, _width);
				_offset += _width;
				_y += _step;
			}
			return _offset;
		}
		static readExtension = function() {
			var _subId = self.i.readByte();
			switch (_subId) {
				case 249:
					if (self.i.readByte() != 4) throw string("Incorrect Graphic Control Extension block size!");
					var _packed = self.i.readByte();
					var _disposalMethod;
					switch ((_packed & 28) >> 2) {
						case 2: _disposalMethod = format_gif_DisposalMethod_FILL_BACKGROUND; break;
						case 3: _disposalMethod = format_gif_DisposalMethod_RENDER_PREVIOUS; break;
						case 1: _disposalMethod = format_gif_DisposalMethod_NO_ACTION; break;
						case 0: _disposalMethod = format_gif_DisposalMethod_UNSPECIFIED; break;
						default: _disposalMethod = format_gif_DisposalMethod_UNDEFINED(((_packed & 28) >> 2));
					}
					var _delay = self.i.readUInt16();
					var _b = format_gif_Block_BExtension(format_gif_Extension_EGraphicControl({
						disposalMethod: _disposalMethod,
						userInput: (_packed & 2) == 2,
						hasTransparentColor: (_packed & 1) == 1,
						delay: _delay,
						transparentIndex: self.i.readByte()
					}));
					self.i.readByte();
					return _b;
				case 1:
					if (self.i.readByte() != 12) throw string("Incorrect size of Plain Text Extension introducer block.");
					var _textGridX = self.i.readUInt16();
					var _textGridY = self.i.readUInt16();
					var _textGridWidth = self.i.readUInt16();
					var _textGridHeight = self.i.readUInt16();
					var _charCellWidth = self.i.readByte();
					var _charCellHeight = self.i.readByte();
					var _textForegroundColorIndex = self.i.readByte();
					var _textBackgroundColorIndex = self.i.readByte();
					var _buffer1 = new haxe_io_BytesOutput();
					var _bytes = new gif_std_haxe_io_Bytes(array_create(255, 0));
					for (var _len = self.i.readByte(); _len != 0; _len = self.i.readByte()) {
						self.i.readBytes(_bytes, 0, _len);
						_buffer1.writeBytes(_bytes, 0, _len);
					}
					_buffer1.flush();
					_bytes = new gif_std_haxe_io_Bytes(_buffer1.data);
					_buffer1.close();
					var __this = _bytes;
					return format_gif_Block_BExtension(format_gif_Extension_EText({
						textGridX: _textGridX,
						textGridY: _textGridY,
						textGridWidth: _textGridWidth,
						textGridHeight: _textGridHeight,
						charCellWidth: _charCellWidth,
						charCellHeight: _charCellHeight,
						textForegroundColorIndex: _textForegroundColorIndex,
						textBackgroundColorIndex: _textBackgroundColorIndex,
						text: haxe_io__Bytes_BytesImpl_getString(__this.b, 0, array_length(__this.b))
					}));
				case 254:
					var _buffer1 = new haxe_io_BytesOutput();
					var _bytes = new gif_std_haxe_io_Bytes(array_create(255, 0));
					for (var _len = self.i.readByte(); _len != 0; _len = self.i.readByte()) {
						self.i.readBytes(_bytes, 0, _len);
						_buffer1.writeBytes(_bytes, 0, _len);
					}
					_buffer1.flush();
					_bytes = new gif_std_haxe_io_Bytes(_buffer1.data);
					_buffer1.close();
					var __this = _bytes;
					return format_gif_Block_BExtension(format_gif_Extension_EComment(haxe_io__Bytes_BytesImpl_getString(__this.b, 0, array_length(__this.b))));
				case 255: return self.readApplicationExtension();
				default:
					var _buffer1 = new haxe_io_BytesOutput();
					var _bytes = new gif_std_haxe_io_Bytes(array_create(255, 0));
					for (var _len = self.i.readByte(); _len != 0; _len = self.i.readByte()) {
						self.i.readBytes(_bytes, 0, _len);
						_buffer1.writeBytes(_bytes, 0, _len);
					}
					_buffer1.flush();
					_bytes = new gif_std_haxe_io_Bytes(_buffer1.data);
					_buffer1.close();
					return format_gif_Block_BExtension(format_gif_Extension_EUnknown(_subId, _bytes));
			}
		}
		static readApplicationExtension = function() {
			if (self.i.readByte() != 11) throw string("Incorrect size of Application Extension introducer block.");
			var _name = self.i.readString(8);
			var _version = self.i.readString(3);
			var _buffer1 = new haxe_io_BytesOutput();
			var _bytes = new gif_std_haxe_io_Bytes(array_create(255, 0));
			for (var _len = self.i.readByte(); _len != 0; _len = self.i.readByte()) {
				self.i.readBytes(_bytes, 0, _len);
				_buffer1.writeBytes(_bytes, 0, _len);
			}
			_buffer1.flush();
			_bytes = new gif_std_haxe_io_Bytes(_buffer1.data);
			_buffer1.close();
			var _data = _bytes;
			if (_name == "NETSCAPE" && _version == "2.0" && _data.b[0] == 1) return format_gif_Block_BExtension(format_gif_Extension_EApplicationExtension(format_gif_ApplicationExtension_AENetscapeLooping((_data.b[1] | (_data.b[2] << 8)))));
			return format_gif_Block_BExtension(format_gif_Extension_EApplicationExtension(format_gif_ApplicationExtension_AEUnknown(_name, _version, _data)));
		}
		static readColorTable = function(_size) {
			_size *= 3;
			var _output = new gif_std_haxe_io_Bytes(array_create(_size, 0));
			for (var _c = 0; _c < _size; _c += 3) {
				var _v = self.i.readByte();
				_output.b[@_c] = (_v & 255);
				var _v1 = self.i.readByte();
				_output.b[@_c + 1] = (_v1 & 255);
				var _v2 = self.i.readByte();
				_output.b[@_c + 2] = (_v2 & 255);
			}
			return _output;
		}
		self.i = _i;
		_i.bigEndian = false;
		static __class__ = mt_GifReader;
	}
	mt_GifReader.i_constructor = GifReader;
#endregion

#region gif_std.Std
	function gif_std_Std_stringify(_value) {
		if (_value == undefined) return "null";
		if (is_string(_value)) return _value;
		var _n, _i, _s;
		if (is_struct(_value)) {
			var _e = variable_struct_get(_value, "__enum__");
			if (_e == undefined) return string(_value);
			var _ects = _e.constructors;
			if (_ects != undefined) {
				_i = _value.__enumIndex__;
				if (_i >= 0 && _i < array_length(_ects)) _s = _ects[_i]; else _s = "?";
			} else {
				_s = instanceof(_value);
				if (string_copy(_s, 1, 3) == "mc_") _s = string_delete(_s, 1, 3);
				_n = string_length(_e.name);
				if (string_copy(_s, 1, _n) == _e.name) _s = string_delete(_s, 1, _n + 1);
			}
			_s += "(";
			var _fields = _value.__enumParams__;
			_n = array_length(_fields);
			for (_i = -1; ++_i < _n; _s += gif_std_Std_stringify(variable_struct_get(_value, _fields[_i]))) {
				if (_i > 0) _s += ", ";
			}
			return _s + ")";
		}
		if (is_real(_value)) {
			_s = string_format(_value, 0, 16);
			if (os_browser != -1) {
				_n = string_length(_s);
				_i = _n;
				while (_i > 0) {
					switch (string_ord_at(_s, _i)) {
						case 48:
							_i--;
							continue;
						case 46: _i--; break;
					}
					break;
				}
			} else {
				_n = string_byte_length(_s);
				_i = _n;
				while (_i > 0) {
					switch (string_byte_at(_s, _i)) {
						case 48:
							_i--;
							continue;
						case 46: _i--; break;
					}
					break;
				}
			}
			return string_copy(_s, 1, _i);
		}
		return string(_value);
	}
#endregion

#region format.gif.Block
	function mc_format_gif_Block() constructor {
		static getIndex = method(undefined, gif_std_enum_getIndex);
		static toString = method(undefined, gif_std_enum_toString);
		static __enum__ = mt_format_gif_Block;
	}

	function mc_format_gif_Block_BFrame() : mc_format_gif_Block() constructor {
		static __enumParams__ = ["frame"];
		static __enumIndex__ = 0;
	}

	function format_gif_Block_BFrame(_frame) {
		var this = new mc_format_gif_Block_BFrame();
		this.frame = _frame;
		return this;
	}

	function mc_format_gif_Block_BExtension() : mc_format_gif_Block() constructor {
		static __enumParams__ = ["extension"];
		static __enumIndex__ = 1;
	}

	function format_gif_Block_BExtension(_extension) {
		var this = new mc_format_gif_Block_BExtension();
		this.extension = _extension;
		return this;
	}

	function mc_format_gif_Block_BEOF() : mc_format_gif_Block() constructor {
		static __enumParams__ = [];
		static __enumIndex__ = 2;
	}
	globalvar format_gif_Block_BEOF; format_gif_Block_BEOF = new mc_format_gif_Block_BEOF();
#endregion

#region format.gif.Extension
	function mc_format_gif_Extension() constructor {
		static getIndex = method(undefined, gif_std_enum_getIndex);
		static toString = method(undefined, gif_std_enum_toString);
		static __enum__ = mt_format_gif_Extension;
	}

	function mc_format_gif_Extension_EGraphicControl() : mc_format_gif_Extension() constructor {
		static __enumParams__ = ["gce"];
		static __enumIndex__ = 0;
	}

	function format_gif_Extension_EGraphicControl(_gce) {
		var this = new mc_format_gif_Extension_EGraphicControl();
		this.gce = _gce;
		return this;
	}

	function mc_format_gif_Extension_EComment() : mc_format_gif_Extension() constructor {
		static __enumParams__ = ["text"];
		static __enumIndex__ = 1;
	}

	function format_gif_Extension_EComment(_text) {
		var this = new mc_format_gif_Extension_EComment();
		this.text = _text;
		return this;
	}

	function mc_format_gif_Extension_EText() : mc_format_gif_Extension() constructor {
		static __enumParams__ = ["pte"];
		static __enumIndex__ = 2;
	}

	function format_gif_Extension_EText(_pte) {
		var this = new mc_format_gif_Extension_EText();
		this.pte = _pte;
		return this;
	}

	function mc_format_gif_Extension_EApplicationExtension() : mc_format_gif_Extension() constructor {
		static __enumParams__ = ["ext"];
		static __enumIndex__ = 3;
	}

	function format_gif_Extension_EApplicationExtension(_ext) {
		var this = new mc_format_gif_Extension_EApplicationExtension();
		this.ext = _ext;
		return this;
	}

	function mc_format_gif_Extension_EUnknown() : mc_format_gif_Extension() constructor {
		static __enumParams__ = ["id", "data"];
		static __enumIndex__ = 4;
	}

	function format_gif_Extension_EUnknown(_id, _data) {
		var this = new mc_format_gif_Extension_EUnknown();
		this.id = _id;
		this.data = _data;
		return this;
	}
#endregion

#region format.gif.ApplicationExtension
	function mc_format_gif_ApplicationExtension() constructor {
		static getIndex = method(undefined, gif_std_enum_getIndex);
		static toString = method(undefined, gif_std_enum_toString);
		static __enum__ = mt_format_gif_ApplicationExtension;
	}

	function mc_format_gif_ApplicationExtension_AENetscapeLooping() : mc_format_gif_ApplicationExtension() constructor {
		static __enumParams__ = ["loops"];
		static __enumIndex__ = 0;
	}

	function format_gif_ApplicationExtension_AENetscapeLooping(_loops) {
		var this = new mc_format_gif_ApplicationExtension_AENetscapeLooping();
		this.loops = _loops;
		return this;
	}

	function mc_format_gif_ApplicationExtension_AEUnknown() : mc_format_gif_ApplicationExtension() constructor {
		static __enumParams__ = ["name", "version", "data"];
		static __enumIndex__ = 1;
	}

	function format_gif_ApplicationExtension_AEUnknown(_name, _version, _data) {
		var this = new mc_format_gif_ApplicationExtension_AEUnknown();
		this.name = _name;
		this.version = _version;
		this.data = _data;
		return this;
	}
#endregion

#region format.gif.Version
	function mc_format_gif_Version() constructor {
		static getIndex = method(undefined, gif_std_enum_getIndex);
		static toString = method(undefined, gif_std_enum_toString);
		static __enum__ = mt_format_gif_Version;
	}

	function mc_format_gif_Version_GIF87a() : mc_format_gif_Version() constructor {
		static __enumParams__ = [];
		static __enumIndex__ = 0;
	}
	globalvar format_gif_Version_GIF87a; format_gif_Version_GIF87a = new mc_format_gif_Version_GIF87a();

	function mc_format_gif_Version_GIF89a() : mc_format_gif_Version() constructor {
		static __enumParams__ = [];
		static __enumIndex__ = 1;
	}
	globalvar format_gif_Version_GIF89a; format_gif_Version_GIF89a = new mc_format_gif_Version_GIF89a();

	function mc_format_gif_Version_Unknown() : mc_format_gif_Version() constructor {
		static __enumParams__ = ["version"];
		static __enumIndex__ = 2;
	}

	function format_gif_Version_Unknown(_version) {
		var this = new mc_format_gif_Version_Unknown();
		this.version = _version;
		return this;
	}
#endregion

#region format.gif.DisposalMethod
	function mc_format_gif_DisposalMethod() constructor {
		static getIndex = method(undefined, gif_std_enum_getIndex);
		static toString = method(undefined, gif_std_enum_toString);
		static __enum__ = mt_format_gif_DisposalMethod;
	}

	function mc_format_gif_DisposalMethod_UNSPECIFIED() : mc_format_gif_DisposalMethod() constructor {
		static __enumParams__ = [];
		static __enumIndex__ = 0;
	}
	globalvar format_gif_DisposalMethod_UNSPECIFIED; format_gif_DisposalMethod_UNSPECIFIED = new mc_format_gif_DisposalMethod_UNSPECIFIED();

	function mc_format_gif_DisposalMethod_NO_ACTION() : mc_format_gif_DisposalMethod() constructor {
		static __enumParams__ = [];
		static __enumIndex__ = 1;
	}
	globalvar format_gif_DisposalMethod_NO_ACTION; format_gif_DisposalMethod_NO_ACTION = new mc_format_gif_DisposalMethod_NO_ACTION();

	function mc_format_gif_DisposalMethod_FILL_BACKGROUND() : mc_format_gif_DisposalMethod() constructor {
		static __enumParams__ = [];
		static __enumIndex__ = 2;
	}
	globalvar format_gif_DisposalMethod_FILL_BACKGROUND; format_gif_DisposalMethod_FILL_BACKGROUND = new mc_format_gif_DisposalMethod_FILL_BACKGROUND();

	function mc_format_gif_DisposalMethod_RENDER_PREVIOUS() : mc_format_gif_DisposalMethod() constructor {
		static __enumParams__ = [];
		static __enumIndex__ = 3;
	}
	globalvar format_gif_DisposalMethod_RENDER_PREVIOUS; format_gif_DisposalMethod_RENDER_PREVIOUS = new mc_format_gif_DisposalMethod_RENDER_PREVIOUS();

	function mc_format_gif_DisposalMethod_UNDEFINED() : mc_format_gif_DisposalMethod() constructor {
		static __enumParams__ = ["index"];
		static __enumIndex__ = 4;
	}

	function format_gif_DisposalMethod_UNDEFINED(_index) {
		var this = new mc_format_gif_DisposalMethod_UNDEFINED();
		this.index = _index;
		return this;
	}
#endregion

#region gif_std.haxe.class
	function gif_std_haxe_class(_id, _name) constructor {
		static superClass = undefined;
		static i_constructor = undefined;
		static marker = undefined;
		static index = undefined;
		static name = undefined;
		self.superClass = undefined;
		self.marker = gif_std_haxe_type_markerValue;
		self.index = _id;
		self.name = _name;
		static __class__ = "class";
	}
	mt_gif_std_haxe_class.i_constructor = gif_std_haxe_class;
#endregion

#region gif_std.haxe.enum
	function gif_std_haxe_enum(_id, _name, _constructors) constructor {
		static constructors = undefined;
		static marker = undefined;
		static index = undefined;
		static name = undefined;
		if (false) throw argument[2];
		self.marker = gif_std_haxe_type_markerValue;
		self.index = _id;
		self.name = _name;
		self.constructors = _constructors;
		static __class__ = "enum";
	}
	mt_gif_std_haxe_enum.i_constructor = gif_std_haxe_enum;
#endregion

#region gif_std.gml.internal.ArrayImpl
	function gif_std_gml_internal_ArrayImpl_push(_arr, _val) {
		var _i = array_length(_arr);
		_arr[@_i] = _val;
		return _i;
	}

	function gif_std_gml_internal_ArrayImpl_copy(_arr) {
		var _out;
		var _len = array_length(_arr);
		if (_len > 0) {
			_out = [];
			array_copy(_out, 0, _arr, 0, _len);
		} else _out = [];
		return _out;
	}
#endregion

#region gif_std.gml.io._Buffer.BufferImpl
	function gif_std_gml_io__Buffer_BufferImpl_bufferSurfaceFunctionsHave3args_init() {
		var _rt = GM_runtime_version;
		if (string_pos("2.3.0.", _rt) == 1) return false;
		if (string_pos("23.1.1.", _rt) != 1) return true;
		var _buildStr = string_delete(_rt, 1, string_length("23.1.1."));
		if (string_digits(_buildStr) != _buildStr) return true;
		var _buildNum = real(_buildStr);
		return _buildNum >= 186;
	}

	function gif_std_gml_io__Buffer_BufferImpl_getSetSurface_init(_fn) {
		var _ctx = { fn: _fn }
		if (gif_std_gml_io__Buffer_BufferImpl_bufferSurfaceFunctionsHave3args) return method(_ctx, function(_buf, _surf, _offset) {
			self.fn(_buf, _surf, _offset);
		}); else return method(_ctx, function(_buf, _surf, _offset) {
			self.fn(_buf, _surf, 0, _offset, 0);
		});
	}
#endregion

#region gif_std.haxe.io.Bytes
	function gif_std_haxe_io_Bytes(_b) constructor {
		static b = undefined;
		self.b = _b;
		static __class__ = mt_gif_std_haxe_io_Bytes;
	}
	mt_gif_std_haxe_io_Bytes.i_constructor = gif_std_haxe_io_Bytes;
#endregion

#region haxe.io._Bytes.BytesImpl
	function haxe_io__Bytes_BytesImpl_getString(_d, _pos, _len) {
		var _b = haxe_io__Bytes_BytesImpl_buffer;
		buffer_seek(_b, buffer_seek_start, 0);
		while (--_len >= 0) {
			buffer_write(_b, buffer_u8, _d[_pos++]);
		}
		buffer_write(_b, buffer_u8, 0);
		buffer_seek(_b, buffer_seek_start, 0);
		return buffer_read(_b, buffer_string);
	}
#endregion

#region haxe.io.Input
	function haxe_io_Input_new() {
		self.bigEndian = false;
		self.dataPos = 0;
	}

	function haxe_io_Input() constructor {
		static data = undefined;
		static dataPos = undefined;
		static dataLen = undefined;
		static bigEndian = undefined;
		static readByte = method(undefined, haxe_io_Input_readByte);
		static readUInt16 = method(undefined, haxe_io_Input_readUInt16);
		static readBytes = method(undefined, haxe_io_Input_readBytes);
		static readString = method(undefined, haxe_io_Input_readString);
		method(self, haxe_io_Input_new)();
		static __class__ = mt_haxe_io_Input;
	}
	mt_haxe_io_Input.i_constructor = haxe_io_Input;

	function haxe_io_Input_readByte() {
		var _d = self.data;
		return _d[self.dataPos++];
	}

	function haxe_io_Input_readUInt16() {
		var _d = self.data;
		var _p = self.dataPos;
		var _c1 = _d[_p++];
		var _c2 = _d[_p++];
		self.dataPos = _p;
		if (self.bigEndian) return ((_c1 << 8) | _c2); else return (_c1 | (_c2 << 8));
	}

	function haxe_io_Input_readBytes(_to, _pos, _len) {
		var _start = self.dataPos;
		var _avail = self.dataLen - _start;
		if (_len > _avail) _len = _avail;
		array_copy(_to.b, _pos, self.data, _start, _len);
		self.dataPos = _start + _len;
		return _len;
	}

	function haxe_io_Input_readString(_count) {
		var _pos = self.dataPos;
		var _data = self.data;
		var _maxLen = self.dataLen - _pos;
		if (_count > _maxLen) _count = _maxLen;
		var _buf = haxe_io_Input_buffer;
		buffer_seek(_buf, buffer_seek_start, 0);
		repeat (_count) buffer_write(_buf, buffer_u8, _data[_pos++]);
		buffer_write(_buf, buffer_u8, 0);
		buffer_seek(_buf, buffer_seek_start, 0);
		self.dataPos = _pos;
		return buffer_read(_buf, buffer_string);
	}
#endregion

#region haxe.io.BytesInput
	function haxe_io_BytesInput(_sourceBytes, _sourcePos, _sourceLen) constructor {
		static data = undefined;
		static dataPos = undefined;
		static dataLen = undefined;
		static bigEndian = undefined;
		static readByte = method(undefined, haxe_io_Input_readByte);
		static readUInt16 = method(undefined, haxe_io_Input_readUInt16);
		static readBytes = method(undefined, haxe_io_Input_readBytes);
		static readString = method(undefined, haxe_io_Input_readString);
		if (_sourcePos == undefined) _sourcePos = 0;
		if (false) throw argument[2];
		method(self, haxe_io_Input_new)();
		if (_sourceLen == undefined) _sourceLen = array_length(_sourceBytes.b) - _sourcePos;
		self.data = _sourceBytes.b;
		self.dataPos = _sourcePos;
		self.dataLen = _sourceLen;
		static __class__ = mt_haxe_io_BytesInput;
	}
	mt_haxe_io_BytesInput.i_constructor = haxe_io_BytesInput;
#endregion

#region haxe.io.Output
	function haxe_io_Output_new() {
		self.dataLen = 32;
		self.dataPos = 0;
		self.data = array_create(32);
	}

	function haxe_io_Output() constructor {
		static data = undefined;
		static dataPos = undefined;
		static dataLen = undefined;
		static flush = method(undefined, haxe_io_Output_flush);
		static close = method(undefined, haxe_io_Output_close);
		static writeBytes = method(undefined, haxe_io_Output_writeBytes);
		method(self, haxe_io_Output_new)();
		static __class__ = mt_haxe_io_Output;
	}
	mt_haxe_io_Output.i_constructor = haxe_io_Output;

	function haxe_io_Output_flush() {
	
	}

	function haxe_io_Output_close() {
	
	}

	function haxe_io_Output_writeBytes(_b, _pos, _len) {
		var _bd = _b.b;
		var _p0 = self.dataPos;
		var _p1 = _p0 + _len;
		var _d = self.data;
		var _dlen = self.dataLen;
		if (_p1 > _dlen) {
			while (true) {
				_dlen *= 2;
				if (!(_p1 > _dlen)) break;
			}
			_dlen *= 2;
			_d[@_dlen - 1] = 0;
			self.dataLen = _dlen;
		}
		array_copy(_d, _p0, _bd, _pos, _len);
		self.dataPos = _p1;
		return _len;
	}
#endregion

#region haxe.io.BytesOutput
	function haxe_io_BytesOutput() constructor {
		static data = undefined;
		static dataPos = undefined;
		static dataLen = undefined;
		static flush = method(undefined, haxe_io_Output_flush);
		static close = method(undefined, haxe_io_Output_close);
		static writeBytes = method(undefined, haxe_io_Output_writeBytes);
		method(self, haxe_io_Output_new)();
		static __class__ = mt_haxe_io_BytesOutput;
	}
	mt_haxe_io_BytesOutput.i_constructor = haxe_io_BytesOutput;
#endregion

// Gif:
globalvar Gif_white32; Gif_white32 = -1;
// gif_std.gml.io._Buffer.BufferImpl:
globalvar gif_std_gml_io__Buffer_BufferImpl_bufferSurfaceFunctionsHave3args; gif_std_gml_io__Buffer_BufferImpl_bufferSurfaceFunctionsHave3args = gif_std_gml_io__Buffer_BufferImpl_bufferSurfaceFunctionsHave3args_init();
globalvar gif_std_gml_io__Buffer_BufferImpl_getSurface; gif_std_gml_io__Buffer_BufferImpl_getSurface = gif_std_gml_io__Buffer_BufferImpl_getSetSurface_init(method(undefined, buffer_get_surface));
globalvar gif_std_gml_io__Buffer_BufferImpl_setSurface; gif_std_gml_io__Buffer_BufferImpl_setSurface = gif_std_gml_io__Buffer_BufferImpl_getSetSurface_init(method(undefined, buffer_set_surface));
// haxe.io._Bytes.BytesImpl:
globalvar haxe_io__Bytes_BytesImpl_buffer; haxe_io__Bytes_BytesImpl_buffer = buffer_create(128, buffer_grow, 1);
// haxe.io.Input:
globalvar haxe_io_Input_buffer; haxe_io_Input_buffer = buffer_create(32, buffer_grow, 1);

