
#region format.gif
	function mc_format_gif_Block_BFrame(_frame)                  constructor { static __enumIndex__ = 0; frame     = _frame;        }
	function mc_format_gif_Block_BExtension(_extension)          constructor { static __enumIndex__ = 1; extension = _extension;    }
	globalvar format_gif_Block_BEOF; format_gif_Block_BEOF = { __enumIndex__: 2 };
	
	function mc_format_gif_Extension_EGraphicControl(_gce)       constructor { static __enumIndex__ = 0; gce  = _gce;              }
	function mc_format_gif_Extension_EComment(_text)             constructor { static __enumIndex__ = 1; text = _text;             }
	function mc_format_gif_Extension_EText(_pte)                 constructor { static __enumIndex__ = 2; pte  = _pte;              }
	function mc_format_gif_Extension_EApplicationExtension(_ext) constructor { static __enumIndex__ = 3; ext  = _ext;              }
	function mc_format_gif_Extension_EUnknown(_id, _data)        constructor { static __enumIndex__ = 4; id   = _id; data = _data; }
	
	function mc_format_gif_ApplicationExtension_AENetscapeLooping(_loops)         constructor { static __enumIndex__ = 0; loops = _loops; }
	function mc_format_gif_ApplicationExtension_AEUnknown(_name, _version, _data) constructor { static __enumIndex__ = 1; name  = _name; version = _version; data = _data; }
	
	enum GIF_VERSION {
		GIF87a,
		GIF89a,
		Unknown
	}
	
	enum GIF_DISPOSE {
		UNSPECIFIED,
		NO_ACTION,
		FILL_BACKGROUND,
		RENDER_PREVIOUS,
		UNDEFINED,
	}

	globalvar haxe_io__Bytes_BytesImpl_buffer; haxe_io__Bytes_BytesImpl_buffer = buffer_create(128, buffer_grow, 1);
	globalvar haxe_io_Input_buffer;            haxe_io_Input_buffer            = buffer_create( 32, buffer_grow, 1);
#endregion

#region Gif
	function Gif() constructor {
		static frames = undefined;
		static width  = undefined;
		static height = undefined;
		static loops  = undefined;
		static destroy = function() {
			var __g  = 0;
			var __g1 = self.frames;
			var len  = array_length(__g1);
			
			while (__g < len) {
				var _frame = __g1[__g];
				__g++;
				_frame.destroy();
			}
		}
		
		reader_data = undefined;
		
		static readBegin = function(_gif_buffer) {
			var _n = buffer_get_size(_gif_buffer);
			var _b = array_create(_n, 0);
			
			for (var _i = 0; _i < _n; _i++) {
				var _v = buffer_peek(_gif_buffer, _i, buffer_u8);
				_b[@_i] = (_v & 255);
			}
			
			var _input  = new haxe_io_BytesInput(_b, 0, _n);
			reader_data = new GifReader(_input);
			reader_data.readBegin();
		}
		
		static reading = function() {
			var res = reader_data.reading(self);
			if(res) readComplete();
			return res;
		}
		
		static readComplete = function() {
			width  = reader_data.logicalScreenDescriptor.width;
			height = reader_data.logicalScreenDescriptor.height;
			
			var _gce = undefined;
			var _globalColorTable = undefined;
			
			if (reader_data.globalColorTable != undefined) 
				_globalColorTable = _Gif_GifTools_colorTableToVector(reader_data.globalColorTable, reader_data.logicalScreenDescriptor.globalColorTableSize);
			
			var __g  = 0;
			var __g1 = reader_data.blocks;
			var __break = false;
			
			while (__g < array_length(__g1)) {
				var _block = __g1[__g];
				__g++;
				
				switch (_block.__enumIndex__) { // format_gif_Block
					case 0 : // BFrame
						var _f  = _block.frame;
						var _gf = new GifFrame();
						var _transparentIndex = -1;
						
						if (_gce != undefined) {
							_gf.delay = _gce.delay;
							if (_gce.hasTransparentColor) _transparentIndex = _gce.transparentIndex;
							
							switch (_gce.disposalMethod) {
								case 2: _gf.disposalMethod = GIF_DISPOSE.NO_ACTION;       break;
								case 3: _gf.disposalMethod = GIF_DISPOSE.FILL_BACKGROUND; break;
							}
						}
						
						_gf.x = _f.x;
						_gf.y = _f.y;
						_gf.width  = _f.width;
						_gf.height = _f.height;
						
						var _colorTable = _globalColorTable;
						if (_f.colorTable != undefined) _colorTable = _Gif_GifTools_colorTableToVector(_f.colorTable, _f.localColorTableSize);
						
						var _buf = buffer_create(_f.width * _f.height * 4, buffer_fixed, 1);
						var _i = 0;
						for (var __g3 = array_length(_f.pixels); _i < __g3; _i++) {
							var _col = _f.pixels[_i];
							if (_col == _transparentIndex) buffer_write(_buf, buffer_s32, 0); else buffer_write(_buf, buffer_s32, _colorTable[_col]);
						}
						
						_gf.buffer = _buf;
						var _sf = surface_create_valid(_f.width, _f.height);
						buffer_set_surface(_buf, _sf, 0);
						_gf.surface = _sf;
						_gce = undefined;
						
						array_push(self.frames, _gf);
						break;
						
					case 1 : // BExtension
						var __g4 = _block.extension;
						
						switch (__g4.__enumIndex__) { // format_gif_Extension
							case 3 : // EApplicationExtension
								var __g5 = __g4.ext;
								if (__g5.__enumIndex__ /* format_gif_ApplicationExtension */ == 0 /* AENetscapeLooping */) {
									var _n = __g5.loops;
									self.loops = _n;
								}
								break;
							case 0 : // EGraphicControl
								_gce = __g4.gce; 
								break;
						}
						break;
						
					case 2 : // BEOF
						__break = true; 
						break;
				}
				if (__break) break;
			}
		}
		
		self.loops  = -1;
		self.width  = 0;
		self.height = 0;
		self.frames = [];
	}
	

	function sprite_add_gif(_path, _return_func) {
		var _buf = buffer_load(_path);
		var _gif = new Gif();
		_gif.readBegin(_buf);
		ds_list_add(GIF_READER, [_gif, _buf, _return_func] );
	}
	
	function __gif_sprite_builder(_gif) constructor {
		gif = _gif;
		w   = gif.width;
		h   = gif.height;
		_sf = surface_create_valid(w, h);
		
		_restoreBuf = -1;
		_spr        = -1;
		spr_size    = 0;
		
		__color = draw_get_color();
		__alpha = draw_get_alpha();  
		draw_set_color(c_white);
		draw_set_alpha(1);
		
		_firstDelay = 0;
		__g  = 0;
		__g1 = gif.frames;
		amo  = array_length(__g1);
		
		static building = function() {
			var _frame = __g1[__g++];
			
			switch (_frame.disposalMethod) {
				
				case GIF_DISPOSE.UNSPECIFIED : 
					surface_set_target(_sf)
						draw_surface_safe(_frame.surface, _frame.x, _frame.y);
					surface_reset_target();
					break;
					
				case GIF_DISPOSE.NO_ACTION : 
					surface_copy(_sf, _frame.x, _frame.y, _frame.surface);
					break;
					
				case GIF_DISPOSE.FILL_BACKGROUND : 
					if (_restoreBuf == -1) _restoreBuf = buffer_create(w * h * 4, buffer_fixed, 1);
					buffer_get_surface(_restoreBuf, _sf, 0);
					
					surface_copy(_sf, _frame.x, _frame.y, _frame.surface);
					break;
				
			}
			
			if (_spr == -1) _spr = sprite_create_from_surface(_sf, 0, 0, w, h, false, false, 0, 0); 
			else                   sprite_add_from_surface(_spr, _sf, 0, 0, w, h, false, false);
			
			var _fdelay = _frame.delay;
			if (_firstDelay <= 0 && _fdelay > 0) _firstDelay = _fdelay;
			
			switch (_frame.disposalMethod) {
				case GIF_DISPOSE.NO_ACTION :       surface_clear(_sf); break;
				case GIF_DISPOSE.FILL_BACKGROUND : buffer_set_surface(_restoreBuf, _sf, 0); break;
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
	
	function GifFrame() constructor {
		static delay   = undefined;
		static surface = undefined;
		static buffer  = undefined;
		/* static */x  = undefined;
		/* static */y  = undefined;
		static width   = undefined;
		static height  = undefined;
		static disposalMethod = undefined;
		
		static destroy = function() {
			surface_free_safe(self.surface);
			buffer_delete(self.buffer);
		}
		
		self.disposalMethod = 0;
		self.delay = 0;
	} 
	
	function _Gif_GifTools_colorTableToVector(_pal, _num) {
		var _r, _g, _b;
		var _p   = 0;
		var _a   = 255;
		var _vec = array_create(_num, undefined);
		
		for (var _i = 0; _i < _num; _i++) {
			_r = _pal[_p];
			_g = _pal[_p + 1];
			_b = _pal[_p + 2];
			var _val = ((((_a << 24) | (_b << 16)) | (_g << 8)) | _r);
			_vec[@ _i] = _val;
			_p += 3;
		}
		return _vec;
	}

	function GifReader(_i) constructor {
		static i     = undefined;
		self.i       = _i;
		_i.bigEndian = false;
		
		block_index  = 0;
		blocks       = [];
		
		static readBegin = function() {
			if (self.i.readByte() != 71) throw string("Gif loader: Invalid header");
			if (self.i.readByte() != 73) throw string("Gif loader: Invalid header");
			if (self.i.readByte() != 70) throw string("Gif loader: Invalid header");
			
			var _gifVer  = self.i.readString(3);
			var _version = GIF_VERSION.GIF89a;
			
			switch (_gifVer) {
				case "87a" : _version = GIF_VERSION.GIF87a; break;
				case "89a" : _version = GIF_VERSION.GIF89a; break;
				default    : _version = GIF_VERSION.Unknown;
			}
			
			var _width  = self.i.readUInt16();
			var _height = self.i.readUInt16();
			var _packedField = self.i.readByte();
			var _bgIndex     = self.i.readByte();
			
			var _pixelAspectRatio = self.i.readByte();
			if (_pixelAspectRatio != 0) _pixelAspectRatio = (_pixelAspectRatio + 15) / 64; 
			else						_pixelAspectRatio = 1;
			
			var _lsd = {
				width:  _width,
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
			var _x      = self.i.readUInt16();
			var _y      = self.i.readUInt16();
			var _width  = self.i.readUInt16();
			var _height = self.i.readUInt16();
			var _packed = self.i.readByte();
			
			var _sorted          = (_packed & 32) == 32;
			var _interlaced      = (_packed & 64) == 64;
			var _localColorTable = (_packed & 128) == 128;
			var _localColorTableSize = (2 << (_packed & 7));
			var _lct = _localColorTable? self.readColorTable(_localColorTableSize) : undefined;
			
			return new mc_format_gif_Block_BFrame({
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
			var _input         = self.i;
			var _pixelsCount   = _width * _height;
			var _pixels        = array_create(_pixelsCount, 0);
			var _minCodeSize   = _input.readByte();
			var _blockSize     = _input.readByte() - 1;
			var _bits          = _input.readByte();
			var _bitsCount     = 8;
			var _clearCode     = (1 << _minCodeSize);
			var _eoiCode       = _clearCode + 1;
			var _codeSize      = _minCodeSize + 1;
			var _codeSizeLimit = (1 << _codeSize);
			var _codeMask      = _codeSizeLimit - 1;
			var _baseDict      = [];
			
			for (var _i = 0; _i < _clearCode; _i++)
				_baseDict[@_i] = [_i];
			
			var _dict    = [];
			var _dictLen = _clearCode + 2;
			var _code    = 0;
			var _i       = 0;
			var _newRecord;
			var _last;
			
			while (_i < _pixelsCount) {
				_last = _code;
				while (_bitsCount < _codeSize) {
					if (_blockSize == 0) break;
					_bits |= (_input.readByte() << _bitsCount);
					_bitsCount += 8;
					_blockSize--;
					if (_blockSize == 0) 
						_blockSize = _input.readByte();
				}
				
				_code = (_bits & _codeMask);
				_bits = _bits >> _codeSize;
				_bitsCount -= _codeSize;
				if (_code == _clearCode) {
					_dict     = variable_clone(_baseDict);
					_dictLen  = _clearCode + 2;
					_codeSize = _minCodeSize + 1;
					_codeSizeLimit = (1 << _codeSize);
					_codeMask = _codeSizeLimit - 1;
					continue;
				}
				
				if (_code == _eoiCode) break;
				if (_code < _dictLen) {
					if (_last != _clearCode) {
						_newRecord = variable_clone(_dict[_last]);
						array_push(_newRecord, _dict[_code][0]);
						_dict[@_dictLen++] = _newRecord;
					}
				} else {
					if (_code != _dictLen) throw string($"Invalid LZW code. Excepted: {_dictLen}, got: {_code}");
					
					_newRecord = variable_clone(_dict[_last]);
					array_push(_newRecord, _newRecord[0]);
					_dict[@_dictLen++] = _newRecord;
				}
				
				_newRecord = _dict[_code];
				
				var __g = 0;
				while (__g < array_length(_newRecord)) {
					var _item = _newRecord[__g];
					__g++;
					_pixels[@ _i++] = (_item & 255);
				}
				
				if (_dictLen == _codeSizeLimit && _codeSize < 12) {
					_codeSize++;
					_codeSizeLimit = (1 << _codeSize);
					_codeMask      = _codeSizeLimit - 1;
				}
			}
			
			while (_blockSize > 0) {
				_input.readByte();
				_blockSize--;
				if (_blockSize == 0) 
					_blockSize = _input.readByte();
			}
			
			while (_i < _pixelsCount) {
				_pixels[@_i++] = 0;
			}
			
			if (_interlaced) {
				var _buffer1 = array_create(_pixelsCount, 0);
				var _offset  = self.deinterlace(_pixels, _buffer1, 8, 0, 0, _width, _height);
				_offset = self.deinterlace(_pixels, _buffer1, 8, 4, _offset, _width, _height);
				_offset = self.deinterlace(_pixels, _buffer1, 4, 2, _offset, _width, _height);
				
				self.deinterlace(_pixels, _buffer1, 2, 1, _offset, _width, _height);
				_pixels = _buffer1;
			}
			
			return _pixels;
		}
		
		static deinterlace = function(_input, _output, _step, _y, _offset, _width, _height) {
			while (_y < _height) {
				array_copy(_output, _y * _width, _input, _offset, _width);
				_offset += _width;
				_y      += _step;
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
						case 2:  _disposalMethod = GIF_DISPOSE.FILL_BACKGROUND; break;
						case 3:  _disposalMethod = GIF_DISPOSE.RENDER_PREVIOUS; break;
						case 1:  _disposalMethod = GIF_DISPOSE.NO_ACTION;       break;
						case 0:  _disposalMethod = GIF_DISPOSE.UNSPECIFIED;     break;
						default: _disposalMethod = GIF_DISPOSE.UNDEFINED;
					}
					
					var _delay = self.i.readUInt16();
					var _b = new mc_format_gif_Block_BExtension(new mc_format_gif_Extension_EGraphicControl({
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
					
					var _textGridX      = self.i.readUInt16();
					var _textGridY      = self.i.readUInt16();
					var _textGridWidth  = self.i.readUInt16();
					var _textGridHeight = self.i.readUInt16();
					var _charCellWidth  = self.i.readByte();
					var _charCellHeight = self.i.readByte();
					var _textForegroundColorIndex = self.i.readByte();
					var _textBackgroundColorIndex = self.i.readByte();
					
					var _buffer1 = new haxe_io_BytesOutput();
					var _bytes   = array_create(255, 0);
					
					for (var _len = self.i.readByte(); _len != 0; _len = self.i.readByte()) {
						self.i.readBytes(_bytes, 0, _len);
						_buffer1.writeBytes(_bytes, 0, _len);
					}
					
					_bytes = _buffer1.data;
					
					return new mc_format_gif_Block_BExtension(new mc_format_gif_Extension_EText({
						textGridX: _textGridX,
						textGridY: _textGridY,
						textGridWidth: _textGridWidth,
						textGridHeight: _textGridHeight,
						charCellWidth: _charCellWidth,
						charCellHeight: _charCellHeight,
						textForegroundColorIndex: _textForegroundColorIndex,
						textBackgroundColorIndex: _textBackgroundColorIndex,
						text: haxe_io__Bytes_BytesImpl_getString(_bytes, 0, array_length(_bytes))
					}));
					
				case 254:
					var _buffer1 = new haxe_io_BytesOutput();
					var _bytes   = array_create(255, 0);
					
					for (var _len = self.i.readByte(); _len != 0; _len = self.i.readByte()) {
						self.i.readBytes(_bytes, 0, _len);
						_buffer1.writeBytes(_bytes, 0, _len);
					}
					
					_bytes = _buffer1.data;
					
					return new mc_format_gif_Block_BExtension(new mc_format_gif_Extension_EComment(haxe_io__Bytes_BytesImpl_getString(_bytes, 0, array_length(_bytes))));
					
				case 255: 
					return self.readApplicationExtension();
				
				default:
					var _buffer1 = new haxe_io_BytesOutput();
					var _bytes   = array_create(255, 0);
					
					for (var _len = self.i.readByte(); _len != 0; _len = self.i.readByte()) {
						self.i.readBytes(_bytes, 0, _len);
						_buffer1.writeBytes(_bytes, 0, _len);
					}
					
					_bytes = _buffer1.data;
					return new mc_format_gif_Block_BExtension(new mc_format_gif_Extension_EUnknown(_subId, _bytes));
			}
		}
		
		static readApplicationExtension = function() {
			if (self.i.readByte() != 11) throw string("Incorrect size of Application Extension introducer block.");
			
			var _name    = self.i.readString(8);
			var _version = self.i.readString(3);
			var _buffer1 = new haxe_io_BytesOutput();
			var _bytes   = array_create(255, 0);
			
			for (var _len = self.i.readByte(); _len != 0; _len = self.i.readByte()) {
				self.i.readBytes(_bytes, 0, _len);
				_buffer1.writeBytes(_bytes, 0, _len);
			}
			
			_bytes = _buffer1.data;
			
			if (_name == "NETSCAPE" && _version == "2.0" && _bytes[0] == 1) 
				return new mc_format_gif_Block_BExtension(new mc_format_gif_Extension_EApplicationExtension(new mc_format_gif_ApplicationExtension_AENetscapeLooping((_bytes[1] | (_bytes[2] << 8)))));
			return new mc_format_gif_Block_BExtension(new mc_format_gif_Extension_EApplicationExtension(new mc_format_gif_ApplicationExtension_AEUnknown(_name, _version, _bytes)));
		}
		
		static readColorTable = function(_size) {
			_size *= 3;
			var _output = array_create(_size, 0);
			
			for (var _c = 0; _c < _size; _c += 3) {
				var _v = self.i.readByte();
				_output[@_c] = (_v & 255);
				
				var _v1 = self.i.readByte();
				_output[@_c + 1] = (_v1 & 255);
				
				var _v2 = self.i.readByte();
				_output[@_c + 2] = (_v2 & 255);
			}
			
			return _output;
		}
		
	}
#endregion

#region haxe.io
	function haxe_io__Bytes_BytesImpl_getString(_d, _pos, _len) { 
		var _b = haxe_io__Bytes_BytesImpl_buffer;
		buffer_seek(_b, buffer_seek_start, 0);
		while (--_len >= 0)
			buffer_write(_b, buffer_u8, _d[_pos++]);
		
		buffer_write(_b, buffer_u8, 0);
		buffer_seek(_b, buffer_seek_start, 0);
		return buffer_read(_b, buffer_string);
	}
	
	function haxe_io_Input_readByte() { 
		var _d = self.data;
		return _d[self.dataPos++];
	} 

	function haxe_io_Input_readUInt16() { 
		var _d  = self.data;
		var _p  = self.dataPos;
		var _c1 = _d[_p++];
		var _c2 = _d[_p++];
		self.dataPos = _p;
		if (self.bigEndian) return ((_c1 << 8) | _c2); else return (_c1 | (_c2 << 8));
	} 

	function haxe_io_Input_readBytes(_to, _pos, _len) { 
		var _start = self.dataPos;
		var _avail = self.dataLen - _start;
		if (_len > _avail) _len = _avail;
		
		array_copy(_to, _pos, self.data, _start, _len);
		self.dataPos = _start + _len;
		return _len;
	} 

	function haxe_io_Input_readString(_count) { 
		var _pos    = self.dataPos;
		var _data   = self.data;
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

	function haxe_io_BytesInput(_sourceBytes, _sourcePos, _sourceLen) constructor { 
		static data       = undefined;
		static dataPos    = undefined;
		static dataLen    = undefined;
		static bigEndian  = undefined;
		static readByte   = method(undefined, haxe_io_Input_readByte);
		static readUInt16 = method(undefined, haxe_io_Input_readUInt16);
		static readBytes  = method(undefined, haxe_io_Input_readBytes);
		static readString = method(undefined, haxe_io_Input_readString);
		_sourcePos ??= 0;
		
		if (false) throw argument[2];
		
		self.bigEndian = false;
		self.dataPos   = 0;
		
		_sourceLen ??= array_length(_sourceBytes) - _sourcePos;
		self.data    = _sourceBytes;
		self.dataPos = _sourcePos;
		self.dataLen = _sourceLen;
	} 
	
	function haxe_io_Output_writeBytes(_b, _pos, _len) { 
		var _bd   = _b;
		var _p0   = self.dataPos;
		var _p1   = _p0 + _len;
		var _d    = self.data;
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

	function haxe_io_BytesOutput() constructor { 
		static data       = undefined;
		static dataPos    = undefined;
		static dataLen    = undefined;
		static writeBytes = method(undefined, haxe_io_Output_writeBytes);
		
		self.dataLen = 32;
		self.dataPos = 0;
		self.data    = array_create(32);
	} 
#endregion
