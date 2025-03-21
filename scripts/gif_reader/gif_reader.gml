
#region format.gif
	function gifBlockFrame(_frame)         constructor { static __enumIndex__ = 0; frame     = _frame;        }
	function gifBlockExtension(_extension) constructor { static __enumIndex__ = 1; extension = _extension;    }
	globalvar gifBlockEOF; gifBlockEOF = { __enumIndex__: 2 };
	
	function gifExtEGraphicControl(_gce) constructor { static __enumIndex__ = 0; gce  = _gce;              }
	function gifExtEComment(_text)       constructor { static __enumIndex__ = 1; text = _text;             }
	function gifExtEText(_pte)           constructor { static __enumIndex__ = 2; pte  = _pte;              }
	function gifExtEApp(_ext)            constructor { static __enumIndex__ = 3; ext  = _ext;              }
	function gifExtEUnknown(_id, _data)  constructor { static __enumIndex__ = 4; id   = _id; data = _data; }
	
	function gifAppLoop(_loops)                    constructor { static __enumIndex__ = 0; loops = _loops; }
	function gifAppUnknown(_name, _version, _data) constructor { static __enumIndex__ = 1; name  = _name; version = _version; data = _data; }
	
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

#endregion

#region Gif
	function sprite_add_gif(_path, _return_func) {
		var _buf = buffer_load(_path);
		var _gif = new Gif(_buf);
		ds_list_add(GIF_READER, [_gif, _buf, _return_func] );
	}
	
	function Gif(_buff) constructor {
		buffer = _buff;
		loops  = -1;
		width  =  0;
		height =  0;
		frames = [];
		reader_data = undefined;
		
		static destroy = function() {
			var len = array_length(frames);
			var i = 0;
			
			repeat(len) {
				var _frame = frames[i++];
				_frame.destroy();
			}
		}
		
		static readBegin = function() {
			var _input  = new hio_input(buffer);
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
				_globalColorTable = _colorTableToVector(reader_data.globalColorTable, reader_data.logicalScreenDescriptor.globalColorTableSize);
			
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
						if (_f.colorTable != undefined) _colorTable = _colorTableToVector(_f.colorTable, _f.localColorTableSize);
						
						var _buf = buffer_create(_f.width * _f.height * 4, buffer_fixed, 1);
						if(_transparentIndex >= 0) _colorTable[_transparentIndex] = 0;
						
						var _pxBuff  = _f.pixels;
						var _pxCount = buffer_get_size(_pxBuff), _i = 0;
						
						buffer_to_start(_pxBuff);
						repeat(_pxCount) buffer_write(_buf, buffer_s32, _colorTable[buffer_read(_pxBuff, buffer_u8)]);
						buffer_delete(_pxBuff);
						
						_gf.buffer = _buf;
						var _sf = surface_create(_f.width, _f.height);
						buffer_set_surface(_buf, _sf, 0);
						_gf.surface = _sf;
						_gce = undefined;
						
						array_push(frames, _gf);
						break;
						
					case 1 : // BExtension
						var __g4 = _block.extension;
						
						switch (__g4.__enumIndex__) { // format_gif_Extension
							case 3 :
								var __g5 = __g4.ext;
								if (__g5.__enumIndex__ == 0)
									loops = __g5.loops;
								break;
								
							case 0 : _gce = __g4.gce; break;
						}
						break;
						
					case 2 : // BEOF
						__break = true; 
						break;
				}
				if (__break) break;
			}
			
			buffer_delete(buffer);
		}
		
		static _colorTableToVector = function(_pal, _num) {
			var _r, _g, _b;
			var _p   = 0;
			var _a   = 255;
			var _vec = array_create(_num, undefined);
			
			for (var _i = 0; _i < _num; _i++) {
				_r = _pal[_p  ];
				_g = _pal[_p+1];
				_b = _pal[_p+2];
				
				_vec[_i] = ((((_a << 24) | (_b << 16)) | (_g << 8)) | _r);
				_p += 3;
			}
			return _vec;
		}

		readBegin();
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
		frameIndex  = 0;
		frames      = gif.frames;
		frameAmount = array_length(frames);
		
		static building = function() {
			if(frameIndex >= frameAmount) { buildComplete(); return true; }
			var _frame = frames[frameIndex++];
			
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
					// if (_restoreBuf == -1) _restoreBuf = buffer_create(w * h * 4, buffer_fixed, 1);
					// buffer_get_surface(_restoreBuf, _sf, 0);
					surface_copy(_sf, _frame.x, _frame.y, _frame.surface);
					break;
				
			}
			
			if (_spr == -1) _spr = sprite_create_from_surface(_sf, 0, 0, w, h, false, false, 0, 0); 
			else                   sprite_add_from_surface(_spr, _sf, 0, 0, w, h, false, false);
			
			var _fdelay = _frame.delay;
			if (_firstDelay <= 0 && _fdelay > 0) _firstDelay = _fdelay;
			
			switch (_frame.disposalMethod) {
				case GIF_DISPOSE.NO_ACTION :       surface_clear(_sf); break;
				// case GIF_DISPOSE.FILL_BACKGROUND : buffer_set_surface(_restoreBuf, _sf, 0); break;
			}
			
			if(frameIndex >= frameAmount) { buildComplete(); return true; }
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
		static surface = undefined;
		static buffer  = undefined;
		/* static */x  = undefined;
		/* static */y  = undefined;
		static width   = undefined;
		static height  = undefined;
		
		static destroy = function() {
			surface_free_safe(surface);
			buffer_delete(buffer);
		}
		
		disposalMethod = 0;
		delay = 0;
	} 
	
	function GifReader(_input) constructor {
		input = _input;
		data  = input.data;
		
		block_index  = 0;
		blocks       = [];
		
		static readBegin = function() {
			if (buffer_read(data, buffer_u8) != 71) throw string("Gif loader: Invalid header");
			if (buffer_read(data, buffer_u8) != 73) throw string("Gif loader: Invalid header");
			if (buffer_read(data, buffer_u8) != 70) throw string("Gif loader: Invalid header");
			
			var _gifVer  = input.readString(3);
			var _version = GIF_VERSION.GIF89a;
			
			switch (_gifVer) {
				case "87a" : _version = GIF_VERSION.GIF87a; break;
				case "89a" : _version = GIF_VERSION.GIF89a; break;
				default    : _version = GIF_VERSION.Unknown;
			}
			
			var _width       = buffer_read(data, buffer_u16);
			var _height      = buffer_read(data, buffer_u16);
			var _packedField = buffer_read(data, buffer_u8);
			var _bgIndex     = buffer_read(data, buffer_u8);
			
			var _pixelAspectRatio = buffer_read(data, buffer_u8);
			if (_pixelAspectRatio != 0) _pixelAspectRatio = (_pixelAspectRatio + 15) / 64; 
			else						_pixelAspectRatio = 1;
			
			var _lsd = {
				width                : _width,
				height               : _height,
				hasGlobalColorTable  : (_packedField & 128) == 128,
				colorResolution      : ((((_packedField & 112) & $FFFFFFFF) >> 4)),
				sorted               : (_packedField & 8) == 8,
				globalColorTableSize : (2 << (_packedField & 7)),
				backgroundColorIndex : _bgIndex,
				pixelAspectRatio     : _pixelAspectRatio
			}
			
			var _gct = undefined;
			if (_lsd.hasGlobalColorTable) _gct = readColorTable(_lsd.globalColorTableSize);
			
			logicalScreenDescriptor = _lsd;
			globalColorTable        = _gct;
			version                 = _version;
		}
		
		static reading = function(_gif) {
			var _b = readBlock();
			blocks[block_index++] = _b;
			
			if (_b == gifBlockEOF) return true;
			return false;
		}
		
		static readBlock = function() {
			var _data    = data;
			var _blockID = buffer_read(_data, buffer_u8);
			
			switch (_blockID) {
				case 44: return readImage();
				case 33: return readExtension();
				case 59: return gifBlockEOF;
			}
			return gifBlockEOF;
		}
		
		static readImage = function() {
			var _data   = data;
			var _x      = buffer_read(_data, buffer_u16);
			var _y      = buffer_read(_data, buffer_u16);
			var _width  = buffer_read(_data, buffer_u16);
			var _height = buffer_read(_data, buffer_u16);
			var _packed = buffer_read(_data, buffer_u8);
			
			var _sorted              = (_packed &  32) ==  32;
			var _interlaced          = (_packed &  64) ==  64;
			var _localColorTable     = (_packed & 128) == 128;
			var _localColorTableSize = (2 << (_packed & 7));
			var _lct = _localColorTable? readColorTable(_localColorTableSize) : undefined;
			
			return new gifBlockFrame({
				x                   : _x,
				y                   : _y,
				width               : _width,
				height              : _height,
				localColorTable     : _localColorTable,
				interlaced          : _interlaced,
				sorted              : _sorted,
				localColorTableSize : _localColorTableSize,
				pixels              : readPixels(_width, _height, _interlaced),
				colorTable          : _lct
			});
		}
		
		static readPixels = function(_width, _height, _interlaced) {
			var _data          = data;
			var _input         = input;
			var _pixelsCount   = _width * _height;
			var _pixels        = buffer_create(_pixelsCount, buffer_fixed, 1); buffer_to_start(_pixels);
			var _minCodeSize   = buffer_read(_data, buffer_u8);
			var _blockSize     = buffer_read(_data, buffer_u8) - 1;
			var _bits          = buffer_read(_data, buffer_u8);
			var _bitsCount     = 8;
			var _clearCode     = (1 << _minCodeSize);
			var _eoiCode       = _clearCode + 1;
			var _codeSize      = _minCodeSize + 1;
			var _codeSizeLimit = (1 << _codeSize);
			var _codeMask      = _codeSizeLimit - 1;
			var _baseDict      = [];
			
			
			for (var _i = 0; _i < _clearCode; _i++)
				_baseDict[_i] = [_i];
			
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
					_bits |= (buffer_read(_data, buffer_u8) << _bitsCount);
					_bitsCount += 8;
					_blockSize--;
					if (_blockSize == 0) 
						_blockSize = buffer_read(_data, buffer_u8);
				}
				
				_code = (_bits & _codeMask);
				_bits = _bits >> _codeSize;
				_bitsCount -= _codeSize;
				if (_code == _clearCode) {
					_dict     = variable_clone(_baseDict, 1);
					_dictLen  = _clearCode + 2;
					_codeSize = _minCodeSize + 1;
					
					_codeSizeLimit = (1 << _codeSize);
					_codeMask = _codeSizeLimit - 1;
					continue;
				}
				
				if (_code == _eoiCode) break;
				if (_code < _dictLen) {
					if (_last != _clearCode) {
						_newRecord = variable_clone(_dict[_last], 1);
						array_push(_newRecord, _dict[_code][0]);
						_dict[_dictLen++] = _newRecord;
					}
				} else {
					if (_code != _dictLen) throw string($"Invalid LZW code. Excepted: {_dictLen}, got: {_code}");
					
					_newRecord = variable_clone(_dict[_last], 1);
					array_push(_newRecord, _newRecord[0]);
					_dict[_dictLen++] = _newRecord;
				}
				
				_newRecord = _dict[_code];
				
				var _l = array_length(_newRecord);
				var _g = 0;
				repeat(_l) buffer_write(_pixels, buffer_u8, _newRecord[_g++]);
				_i += _l;
				
				if (_dictLen == _codeSizeLimit && _codeSize < 12) {
					_codeSize++;
					_codeSizeLimit = (1 << _codeSize);
					_codeMask      = _codeSizeLimit - 1;
				}
			}
			
			while (_blockSize > 0) {
				buffer_read(_data, buffer_u8);
				_blockSize--;
				if (_blockSize == 0) 
					_blockSize = buffer_read(_data, buffer_u8);
			}
			
			var _rep = _pixelsCount - _i;
			repeat(_rep) buffer_write(_pixels, buffer_u8, 0); 
			
			if (_interlaced) {
				var _buffer1 = buffer_create(_pixelsCount, buffer_fixed, 1); buffer_to_start(_buffer1);
				
				var _offset = deinterlace(_pixels, _buffer1, 8, 0,       0, _width, _height);
				    _offset = deinterlace(_pixels, _buffer1, 8, 4, _offset, _width, _height);
				    _offset = deinterlace(_pixels, _buffer1, 4, 2, _offset, _width, _height);
				
				deinterlace(_pixels, _buffer1, 2, 1, _offset, _width, _height);
				buffer_delete(_pixels);
				
				_pixels = _buffer1;
			}
			
			return _pixels;
		}
		
		static deinterlace = function(_input, _output, _step, _y, _offset, _width, _height) {
			while (_y < _height) {
				buffer_copy(_input, _offset, _width, _output, _y * _width);
				_offset += _width;
				_y      += _step;
			}
			return _offset;
		}
		
		static readExtension = function() {
			var _data  = data;
			var _subId = buffer_read(_data, buffer_u8);
			
			switch (_subId) {
				case 249:
					if (buffer_read(_data, buffer_u8) != 4) throw string("Incorrect Graphic Control Extension block size!");
					
					var _packed = buffer_read(_data, buffer_u8);
					var _disposalMethod;
					
					switch ((_packed & 28) >> 2) {
						case 2:  _disposalMethod = GIF_DISPOSE.FILL_BACKGROUND; break;
						case 3:  _disposalMethod = GIF_DISPOSE.RENDER_PREVIOUS; break;
						case 1:  _disposalMethod = GIF_DISPOSE.NO_ACTION;       break;
						case 0:  _disposalMethod = GIF_DISPOSE.UNSPECIFIED;     break;
						default: _disposalMethod = GIF_DISPOSE.UNDEFINED;
					}
					
					var _delay = buffer_read(_data, buffer_u16);
					var _b = new gifBlockExtension(new gifExtEGraphicControl({
						disposalMethod      : _disposalMethod,
						userInput           : (_packed & 2) == 2,
						hasTransparentColor : (_packed & 1) == 1,
						delay               : _delay,
						transparentIndex    : buffer_read(_data, buffer_u8)
					}));
					
					buffer_read(_data, buffer_u8);
					return _b;
					
				case 1:
					if (buffer_read(_data, buffer_u8) != 12) throw string("Incorrect size of Plain Text Extension introducer block.");
					
					var textGridX      = buffer_read(_data, buffer_u16);
					var textGridY      = buffer_read(_data, buffer_u16);
					var textGridWidth  = buffer_read(_data, buffer_u16);
					var textGridHeight = buffer_read(_data, buffer_u16);
					var charCellWidth  = buffer_read(_data, buffer_u8);
					var charCellHeight = buffer_read(_data, buffer_u8);
					var textForegroundColorIndex = buffer_read(_data, buffer_u8);
					var textBackgroundColorIndex = buffer_read(_data, buffer_u8);
					
					var _sfts  = 0;
					var _bytes = buffer_create(1, buffer_grow, 1); 
					buffer_to_start(_bytes);
					
					for (var _len = buffer_read(_data, buffer_u8); _len != 0; _len = buffer_read(_data, buffer_u8)) {
						input.readBytes(_bytes, _sfts, _len);
						_sfts += _len;
					}
					
					return new gifBlockExtension(new gifExtEText({
						textGridX,
						textGridY,
						textGridWidth,
						textGridHeight,
						charCellWidth,
						charCellHeight,
						textForegroundColorIndex,
						textBackgroundColorIndex,
						text: buffer_read(_bytes, buffer_string)
					}));
					
				case 254:
					var _sfts  = 0;
					var _bytes = buffer_create(1, buffer_grow, 1); 
					buffer_to_start(_bytes);
					
					for (var _len = buffer_read(_data, buffer_u8); _len != 0; _len = buffer_read(_data, buffer_u8)) {
						input.readBytes(_bytes, _sfts, _len);
						_sfts += _len;
					}
					
					return new gifBlockExtension(new gifExtEComment(buffer_read(_bytes, buffer_string)));
					
				case 255: return readApplicationExtension();
				
				default:
					var _sfts  = 0;
					var _bytes = buffer_create(1, buffer_grow, 1); 
					buffer_to_start(_bytes);
					
					for (var _len = buffer_read(_data, buffer_u8); _len != 0; _len = buffer_read(_data, buffer_u8)) {
						input.readBytes(_bytes, _sfts, _len);
						_sfts += _len;
					}
					
					return new gifBlockExtension(new gifExtEUnknown(_subId, _bytes));
			}
		}
		
		static readApplicationExtension = function() {
			var _data = data;
			if (buffer_read(_data, buffer_u8) != 11) throw string("Incorrect size of Application Extension introducer block.");
			
			var _name    = input.readString(8);
			var _version = input.readString(3);
			
			var _sfts  = 0;
			var _bytes = buffer_create(1, buffer_grow, 1); 
			buffer_to_start(_bytes);
			
			for (var _len = buffer_read(_data, buffer_u8); _len != 0; _len = buffer_read(_data, buffer_u8)) {
				input.readBytes(_bytes, _sfts, _len);
				_sfts += _len;
			}
			
			var _app;
			if (_name == "NETSCAPE" && _version == "2.0" && buffer_read_at(_bytes, 0, buffer_u8)) 
				_app = new gifAppLoop(buffer_read_at(_bytes, 1, buffer_u16));
			else 
				_app = new gifAppUnknown(_name, _version, _bytes);
			
			return new gifBlockExtension(new gifExtEApp(_app));
		}
		
		static readColorTable = function(_size) {
			_size *= 3;
			var _output = array_create(_size, 0);
			var _data   = data;
			
			for (var _c = 0; _c < _size; _c += 3) {
				_output[_c  ] = buffer_read(_data, buffer_u8) & 255;
				_output[_c+1] = buffer_read(_data, buffer_u8) & 255;
				_output[_c+2] = buffer_read(_data, buffer_u8) & 255;
			}
			
			return _output;
		}
		
	}
#endregion

#region haxe.io
	globalvar haxe_io_Input_buffer; haxe_io_Input_buffer = buffer_create( 32, buffer_grow, 1);
	
	function hio_input(_sourceBytes) constructor { 
		data    = _sourceBytes;
		dataLen = buffer_get_size(data);
		buffer_to_start(data);
		
		static tell       = function() { return buffer_tell(data);             }
		static readByte   = function() { return buffer_read(data, buffer_u8);  }
		static readUInt16 = function() { return buffer_read(data, buffer_u16); }
		
		static readBytes  = function(_to, _pos, _len) { 
			_len = min(_len, dataLen - buffer_tell(data));
			buffer_copy(data, buffer_tell(data), _len, _to, _pos);
			buffer_seek(data, buffer_seek_relative, _len);
			
			return _len;
		} 
		
		static readString = function(_count) { 
			_count = min(_count, dataLen - buffer_tell(data));
			
			var _buf = haxe_io_Input_buffer;
			buffer_seek(_buf, buffer_seek_start, 0);
			repeat (_count) buffer_write(_buf, buffer_u8, buffer_read(data, buffer_u8));
			buffer_write(_buf, buffer_u8, 0);
			buffer_seek(_buf, buffer_seek_start, 0);
			
			return buffer_read(_buf, buffer_string);
		}
	} 
#endregion