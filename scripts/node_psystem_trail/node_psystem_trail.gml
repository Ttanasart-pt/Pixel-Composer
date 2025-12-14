function Node_pSystem_Trail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Trail";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_trail);
	
	update_on_frame = true;
	
	newInput(2, nodeValueSeed());
	
	////- =Particles
	newInput(0, nodeValue_Particle( "Particles" ));
	newInput(1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Trail
	newInput(3, nodeValue_Range( "Frames", [4,4], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	
	////- =Render
	// 
	
	newOutput(0, nodeValue_Output( "Rendered", VALUE_TYPE.pathnode, self ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Trail",     false ], 3, 4, 
		[ "Render",    false ], 
	];
	
	////- Nodes
	
	curve_fram       = undefined;
	trail_buffer  = undefined;
	buffer_data_size = 8 + 8; // life, px, py
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static reset = function() {
		curve_fram = new curveMap(getInputData( 4));
		
		var _parts = getInputData(0);
		var _fram  = getInputData(3);
		
		if(!is(_parts, pSystem_Particles)) return;
		
		var _poolSize = _parts.poolSize;
		var _lenMax   = max(_fram[0], _fram[1]);
		var _bufLen   = (2 + buffer_data_size * _lenMax) * _poolSize;
		
		trail_buffer = buffer_verify(trail_buffer, _bufLen, buffer_grow);
		buffer_clear(trail_buffer);
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		
		var _dim   = getDimension();
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _seed = getInputData(2);
		var _fram = getInputData(3), _fram_curved = inputs[3].attributes.curved && curve_fram != undefined;
		
		var _poolSize  = _parts.poolSize;
		var _lenMax    = max(_fram[0], _fram[1]);
		var _bufDatLen = 2 + buffer_data_size * _lenMax;
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		if(trail_buffer == undefined) reset();
		
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			
			if(!_act) continue;
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
			var _dpx    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dposx,  buffer_f64  );
			var _dpy    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dposy,  buffer_f64  );
			
			var _draw_x = round(bool(_dfg & 0b100)? _dpx : _px);
			var _draw_y = round(bool(_dfg & 0b100)? _dpy : _py);
			
			var _buffOffStart = _bufDatLen * _spwnId;
			var _buffInd = _lif % _lenMax;
			var _buffOff = _buffOffStart + 2 + _buffInd * buffer_data_size;
			
			buffer_write_at(trail_buffer, _buffOffStart, buffer_u16, _lif);
			buffer_write_at(trail_buffer, _buffOff +  0, buffer_f64, _draw_x);
			buffer_write_at(trail_buffer, _buffOff +  8, buffer_f64, _draw_y);
		}
		
		if(!is(inline_context, Node_pSystem_Inline) || inline_context.prerendering) return;
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			
			if(!_act && _lif == 0) continue;
			
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var rat = clamp(_lif / (_lifMax - 1), 0, 1);
			var _fram_mod = _fram_curved? curve_fram.get(rat) : 1;
			var _fram_cur = round(random_range(_fram[0], _fram[1]) * _fram_mod * _mask);
			    // _fram_cur = min(_fram_cur, TOTAL_FRAMES - _lifMax - 1); // prevent trail overflow through loop
			
			var _buffOffStart = _bufDatLen * _spwnId;
			
			var _trailLife = min(_fram_cur, _lif);
			var _posIndx   = _lif;
			
			if(!_act) {
				_trailLife = min(_trailLife, _lifMax - (_lif - _trailLife) - 1);
				_posIndx   = _lifMax - 1;
			}
			
			if(_trailLife <= 0) continue;
			
			var ox, oy, nx, ny;
			var _segIndex = 0; 
			
			repeat(_trailLife) {
				var _buffInd = _posIndx % _lenMax;
				var _buffOff = _buffOffStart + 2 + _buffInd * buffer_data_size;
				
				nx = buffer_read_at( trail_buffer, _buffOff + 0, buffer_f64 );
				ny = buffer_read_at( trail_buffer, _buffOff + 8, buffer_f64 );
				
				if(_segIndex) {
					var _cc = _segIndex / _trailLife;
					var _gg = _act? make_color_grey(1 - _cc) : _make_color_rgb(1 - _cc, 0, 0);
					
					draw_set_color_alpha(_gg, 1);
					draw_line(ox, oy, nx, ny);
				}
				
				ox = nx;
				oy = ny;
				
				_segIndex++;
				_posIndx--;
			}
		}
		
	}
	
	static cleanUp = function() {
		buffer_delete_safe(trail_buffer);
	}
}