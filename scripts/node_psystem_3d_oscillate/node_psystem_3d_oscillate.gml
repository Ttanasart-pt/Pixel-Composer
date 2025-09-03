function Node_pSystem_3D_Oscillate(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Oscillate";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_oscillate;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Oscillate
	newInput( 3, nodeValue_Range( "Strength",  [1,1], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	newInput( 5, nodeValue_Range( "Amplitude", [4,4], true )).setCurvable( 6, CURVE_DEF_11, "Over Lifespan"); 
	newInput( 7, nodeValue_Range( "Frequency", [4,4], true )).setCurvable( 8, CURVE_DEF_11, "Over Lifespan"); 
	// 9
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Oscillate", false ], 3, 4, 5, 6, 7, 8, 
	];
	
	////- Nodes
	
	curve_strn = undefined;
	curve_ampl = undefined;
	curve_freq = undefined;
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return _parts;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = getInputData( 2);
		var _strn = getInputData( 3), _strn_curved = inputs[3].attributes.curved && curve_strn != undefined;
		var _ampl = getInputData( 5), _ampl_curved = inputs[5].attributes.curved && curve_ampl != undefined;
		var _freq = getInputData( 7), _freq_curved = inputs[7].attributes.curved && curve_freq != undefined;
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
			
			var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			
			var _ppx    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospx,  buffer_f64  );
			var _ppy    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospy,  buffer_f64  );
			
			var _dpx    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dposx,  buffer_f64  );
			var _dpy    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dposy,  buffer_f64  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			_dfg |= 0b100;
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dflag, buffer_u16, _dfg );
			
			var _strn_mod = _strn_curved? curve_strn.get(rat) : 1;
			var _strn_cur = random_range(_strn[0], _strn[1]) * _strn_mod;
			
			var _ampl_mod = _ampl_curved? curve_ampl.get(rat) : 1;
			var _ampl_cur = random_range(_ampl[0], _ampl[1]) * _ampl_mod;
			
			var _freq_mod = _freq_curved? curve_freq.get(rat) : 1;
			var _freq_cur = random_range(_freq[0], _freq[1]) * _freq_mod;
			
			var _dir = point_direction(_ppx, _ppy, _px + _vx, _py + _vy);
			var _osc = dsin(rat * _freq_cur * 360) * _ampl_cur * _strn_cur * _mask;
			
			var _ox = lengthdir_x(_osc, _dir + 90);
			var _oy = lengthdir_y(_osc, _dir + 90);
			
			_dpx = _px + _ox;
			_dpy = _py + _oy;
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dposx, buffer_f64, _dpx );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dposy, buffer_f64, _dpy );
		}
		
		return _parts;
	}
	
	static reset = function() {
		curve_strn = new curveMap(getInputData(4));
		curve_ampl = new curveMap(getInputData(6));
		curve_freq = new curveMap(getInputData(8));
	}
}