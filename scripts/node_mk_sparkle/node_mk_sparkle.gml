enum MKSPARK_DIRR { main, diag }
enum MKSPARK      { dir, y, x, speed, length, lendel, time }

function Node_MK_Sparkle(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Sparkle";
	dimension_index = -1;
	update_on_frame = true;
	
	newInput(0, nodeValue_Int("Size", 5));
	
	newInput(1, nodeValueSeed());
	
	newInput(2, nodeValue_Slider("Speed", 1));
	
	newInput(3, nodeValue_Bool("Shade", false));
	
	newInput(4, nodeValue_Slider("Amount", 0.5));
		
	newInput(5, nodeValue_Slider("Scatter", 0.5));
		
	newInput(6, nodeValue_Palette("Colors", [ ca_black, ca_white ]))
		
	newInput(7, nodeValue_Bool("Additive", false))
		
	newInput(8, nodeValue_Slider("Diagonal", 0.2));
		
	newInput(9, nodeValue_Enum_Scroll("Loop", false, [ "None", "Loop", "Ping-pong" ]));
	
	newInput(10, nodeValue_Int("Loop Length", 4));
	
	newInput(11, nodeValue_Int("Frame Shift", 0));
	
	newInput(12, nodeValue_Bool("Array", false));
	
	newInput(13, nodeValue_Int("Array Length", 1));
	
	/////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 
		["Output",    false], 0, 12, 13, 
		["Sparkle",	  false], 4, 5, 8, 
		["Animation", false], 2, 11, 9, 10, 
		["Color",	  false, 3], 6, 7, 
	]
	
	temp_surface = array_create(3);
	
	_loop = 0;
	_lopl = 0;
	_sped = 0;
	
	_seed = 0;
	_size = 0;
	_amou = 0;
	_scat = 0;
	_diag = 0;
	_shad = 0;
	_palt = 0;
	_badd = 0;

	static generate = function(_surf, _frame = CURRENT_FRAME) {
		
		var _f = _frame;
		var st_sz = ceil( _size / 2);
		var st_ps = floor(_size / 2);
		
		switch(_loop) {
			case 1 : _f = safe_mod(_f, _lopl); break;
			case 2 : 
				_f = safe_mod(_f, _lopl * 2);
				if(_f >= _lopl)
					_f = _lopl * 2 - 2 - _f;
				break;
		}
		
		_f = _f * _sped - _fshf;
		
		_surf = surface_verify(_surf, _size, _size);
		random_set_seed(_seed);
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
				
			var _amo = 3 + irandom(st_ps * _amou);
			var _ind = 0;
			var _sct = lerp(25, 1, power(_scat, 0.1));
			var _pal_sz = array_length(_palt);
			
			draw_set_color(c_white);
			if(_badd) BLEND_ADD
			
			repeat(_amo) {
				if(_shad) {
					var _in = _ind / (_amo - 1);
					draw_set_color(_palt[(_pal_sz - 1) * _in]);
				}
				_ind++;
				
				var dy = power(random(1), _sct) * (st_ps / 2);
				var dx = power(random(1), _sct) * (st_ps / 2);
				
				var sx = irandom_range(1, st_ps / 4);
				var sl = irandom_range(1, st_ps / 4) * -1;
				var ll = irandom_range(1, st_ps / 2);
				
				var len  = max(0, ll + _f * sl);
				var diam = random(1) < _diag * 0.2;
				var diag = random(1) < _diag;
				
				if(len <= 0) continue;
				
				if(diam) {
					var lx  = -1 + dx        - _f * sx;
					var ly  = st_sz - 1 - dy - _f * sx;
					
					draw_line(lx, ly, lx - len, ly - len);
					
				} else if(diag) {
					var lx  = -1 + dx        + _f * sx;
					var ly  = st_sz - 1 - dy - _f * sx;
					
					draw_line(lx, ly, lx + len, ly - len);
					
				} else {
					var ly  = st_sz - 1 - dy;
					var lx0 = -1 + _f * sx + dx;
					var lx1 = lx0 + len;
					
					draw_line(lx0, ly, lx1, ly);
				}
			}
		surface_reset_target();
		BLEND_NORMAL
		
		surface_set_target(temp_surface[1]);
			DRAW_CLEAR
			
			draw_surface_ext(temp_surface[0], st_ps, 0,  1,  1, 0, c_white, 1);
			draw_surface_ext(temp_surface[0], st_sz, 0, -1,  1, 0, c_white, 1);
		surface_reset_target();
		
		surface_set_target(temp_surface[2]);
			DRAW_CLEAR
			
			draw_surface_ext(temp_surface[1], 0,     0,  1,  1, 0, c_white, 1);
			draw_surface_ext(temp_surface[1], 0, _size,  1, -1, 0, c_white, 1);
		surface_reset_target();
		
		surface_set_target(_surf);
			DRAW_CLEAR
			
			draw_surface_ext(temp_surface[2], 0,     0, 1, 1,  0, c_white, 1);
			draw_surface_ext(temp_surface[2], 0, _size, 1, 1, 90, c_white, 1);
		surface_reset_target();
		
		return _surf;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
		_sped = _data[2];
		_loop = _data[9];
		_lopl = _data[10]; _lopl = max(_lopl, 1);
		_fshf = _data[11];
		_oarr = _data[12];
		
		_seed = _data[1];
		_size = _data[0];
		
		_amou = _data[4];
		_scat = _data[5];
		_diag = _data[8];
		
		_shad = _data[3];
		_palt = _data[6];
		_badd = _data[7];
		
		inputs[10].setVisible(_loop > 0);
		inputs[13].setVisible(_oarr == 1);
		update_on_frame = _oarr == 0;
		
		var st_sz = ceil( _size / 2);
		var st_ps = floor(_size / 2);
		temp_surface[0] = surface_verify(temp_surface[0], st_sz, st_sz);
		temp_surface[1] = surface_verify(temp_surface[1], _size, _size);
		temp_surface[2] = surface_verify(temp_surface[2], _size, _size);
		
		if(_oarr == 0) {
			
			return generate(_outSurf);
			
		} else if(_oarr == 1) {
			var _arrl = _data[13];
			_outSurf = array_verify(_outSurf, _arrl);
			
			for( var i = 0; i < _arrl; i++ )
				_outSurf[i] = generate(_outSurf[i], i);
		}
		
		return _outSurf;
	}
}