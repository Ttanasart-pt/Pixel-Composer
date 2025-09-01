function Node_pSystem_Render_Trail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render Trail";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	
	update_on_frame = true;
	
	newInput(2, nodeValueSeed());
	
	////- =Particles
	newInput(0, nodeValue_Particle( "Particles" ));
	newInput(1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Trail
	newInput(3, nodeValue_Range( "Frames", [4,4], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	newInput(5, nodeValue_Bool(  "End Trail",  true )).setTooltip("Render trail for dead particles.");
	
	////- =Render
	newInput(6, nodeValue_Range( "Thickness", [1,1], true )).setTooltip("This value then multiply by particle X scale for the final thickness.");
	// 
	
	newOutput(0, nodeValue_Output( "Rendered", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Trail",     false ], 3, 4, 5, 
		[ "Render",    false ], 6, 
	];
	
	////- Nodes
	
	curve_fram       = undefined;
	trail_buffer     = undefined;
	buffer_data_size = 8 + 8 + 8 + 4; // px, py, thick, color
	
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
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		outputs[0].setValue(_outSurf);
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _seed = getInputData(2);
		var _fram = getInputData(3), _fram_curved = inputs[3].attributes.curved && curve_fram != undefined;
		var _endt = getInputData(5);
		
		var _thck = getInputData(6);
		
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
			
			var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
			
			var _bldR   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnr,   buffer_u8  );
			var _bldG   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blng,   buffer_u8  );
			var _bldB   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnb,   buffer_u8  );
			var _bldA   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blna,   buffer_u8  );
			
			var _draw_x  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx),   buffer_f64  );
			var _draw_y  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposy : PSYSTEM_OFF.posy),   buffer_f64  );
			var _draw_sx = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b010)? PSYSTEM_OFF.dscax : PSYSTEM_OFF.scax),   buffer_f64  );
			
			var _buffOffStart = _bufDatLen * _spwnId;
			var _buffInd = _lif % _lenMax;
			var _buffOff = _buffOffStart + 2 + _buffInd * buffer_data_size;
			
			buffer_write_at(trail_buffer, _buffOffStart, buffer_u16, _lif);
			buffer_seek(trail_buffer, buffer_seek_start, _buffOff);
			
			buffer_write(trail_buffer, buffer_f64, _draw_x);
			buffer_write(trail_buffer, buffer_f64, _draw_y);
			buffer_write(trail_buffer, buffer_f64, _draw_sx);
			
			buffer_write(trail_buffer, buffer_u8, _bldR);
			buffer_write(trail_buffer, buffer_u8, _bldG);
			buffer_write(trail_buffer, buffer_u8, _bldB);
			buffer_write(trail_buffer, buffer_u8, _bldA);
		}
		
		if(!is(inline_context, Node_pSystem_Inline) || inline_context.prerendering) return;
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var _partAmo  = _parts.maxCursor;
			var _partBuff = _parts.buffer;
			var _off = 0;
			
			repeat(_partAmo) {
				var _start = _off;
				_off += global.pSystem_data_length;
				
				var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
				var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
				var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
				
				if(!_act && (_lif == 0 || !_endt)) continue;
				
				var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
				var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
				
				random_set_seed(_seed + _spwnId);
				var rat = clamp(_lif / (_lifMax - 1), 0, 1);
				var _fram_mod = _fram_curved? curve_fram.get(rat) : 1;
				var _fram_cur = round(random_range(_fram[0], _fram[1]) * _fram_mod * _mask);
				
				var _buffOffStart = _bufDatLen * _spwnId;
				
				var _trailLife = min(_fram_cur, _lif);
				var _posIndx   = _lif;
				
				if(!_act) {
					_trailLife = min(_trailLife, _lifMax - (_lif - _trailLife) - 1);
					_posIndx   = _lifMax - 1;
				}
				
				if(_trailLife <= 0) continue;
				
				var _thck_base = random_range(_thck[0], _thck[1]);
				
				var _segIndex = 0; 
				var ox, oy, ot, oc, oa;
				var nx, ny, nt, nc, na;
				
				repeat(_trailLife) {
					var _buffInd = _posIndx % _lenMax;
					var _buffOff = _buffOffStart + 2 + _buffInd * buffer_data_size;
					
					buffer_seek(trail_buffer, buffer_seek_start, _buffOff);
					nx = buffer_read( trail_buffer, buffer_f64 );
					ny = buffer_read( trail_buffer, buffer_f64 );
					nt = buffer_read( trail_buffer, buffer_f64 ) * _thck_base;
					
					var _r = buffer_read( trail_buffer, buffer_u8 );
					var _g = buffer_read( trail_buffer, buffer_u8 );
					var _b = buffer_read( trail_buffer, buffer_u8 );
					var _a = buffer_read( trail_buffer, buffer_u8 );
					
					nc = make_color_rgb(_r, _g, _b);
					na = _a;
					
					if(_segIndex) draw_line_width2(ox, oy, nx, ny, ot, nt, true, oc, nc);
					
					ox = nx;
					oy = ny;
					ot = nt;
					oc = nc;
					oa = na;
					
					_segIndex++;
					_posIndx--;
				}
			}
			
			draw_set_alpha(1);
		surface_reset_target();
	}
	
	static cleanUp = function() {
		buffer_delete_safe(trail_buffer);
	}
}