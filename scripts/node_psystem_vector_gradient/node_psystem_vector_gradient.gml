function Node_pSystem_Vector_Gradient(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Vector Gradient";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_vector_gradient);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Vector
	newInput( 3, nodeValue_Surface( "Vector Field" )); 
	newInput( 4, nodeValue_Range(   "Intensity", [4,4], true )).setCurvable( 5, CURVE_DEF_11, "Over Lifespan"); 
	newInput( 6, nodeValue_Slider(  "Midpoint", .5 )); 
	newInput( 7, nodeValue_EScroll( "Overflow",  0, [ "Repeat", "Clamp" ] )); 
	newInput( 8, nodeValue_Rotation("Rotate",    0 )); 
	// 9
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 
		[ "Particles", false ], 0, 1, 
		[ "Vector",    false ], 3, 4, 5, 7, 8, 
	];
	
	////- Nodes
	
	curve_ints   = undefined;
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : PROJ_SURF; }
	
	static update = function(_frame = CURRENT_FRAME) {
		#region data
			var _parts = getInputData(0);
			var _masks = getInputData(1), use_mask = _masks != noone;
			
			if(!is(_parts, pSystem_Particles)) return;
			if(use_mask) buffer_to_start(_masks);
			outputs[0].setValue(_parts);
			
			var _vect = getInputData( 3);
			var _ints = getInputData( 4), _ints_curved = inputs[4].attributes.curved && curve_ints != undefined;
			var _midp = getInputData( 6);
			var _ovfr = getInputData( 7);
			var _rota = getInputData( 8);
			
			if(!is_surface(_vect)) return;
		#endregion
		
		var vw = surface_get_width_safe(_vect);
		var vh = surface_get_height_safe(_vect);
		temp_surface[0] = surface_verify(temp_surface[0], vw, vh, surface_rgba16float);
		
		surface_set_shader(temp_surface[0], sh_psystem_gradient);
			shader_set_2("dimension",  [vw, vh] );
			shader_set_i("oversample", _ovfr    );
			shader_set_f("rotation",   _rota    );
			draw_surface(_vect, 0, 0);
		surface_reset_shader();
		
		var vectr_samp = new Surface_sampler(temp_surface[0]);
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _stat   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.stat,   buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			
			var _ppx    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospx,  buffer_f64  );
			var _ppy    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospy,  buffer_f64  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var rat = _stat? (_frame + _lif + _spwnId * _lifMax) / TOTAL_FRAMES : _lif / (_lifMax - 1);
			    rat = clamp(rat, 0, 1);
			
			var _ints_mod = _ints_curved? curve_ints.get(rat) : 1;
			var _ints_cur = random_range(_ints[0], _ints[1]) * _ints_mod;
			
			var sx = _ovfr == 0? (round(_px) % vw + vw) % vw : clamp(round(_px), 0, vw);
			var sy = _ovfr == 0? (round(_py) % vh + vh) % vh : clamp(round(_py), 0, vh);
			
			var _sampClr = vectr_samp.getPixel4F16(sx, sy);
			var _dx = _sampClr[0] * 4 * _ints_cur;
			var _dy = _sampClr[1] * 4 * _ints_cur;
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _px + _dx );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _py + _dy );
		}
		
		vectr_samp.free();
	}
	
	static reset = function() {
		curve_ints = new curveMap(getInputData(5));
	}
}