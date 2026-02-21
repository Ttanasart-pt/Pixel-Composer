function Node_pSystem_Attract(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Attract";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_attract);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Attract
	newInput( 3, nodeValue_Range( "Strength", [ 1, 1], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	newInput( 5, nodeValue_Vec2(  "Target",   [.5,.5]       )).setUnitSimple();
	
	////- =Vortex
	newInput( 6, nodeValue_Range( "Vortex",       [ 0, 0], true )).setCurvable( 7, CURVE_DEF_11, "Over Lifespan"); 
	newInput( 8, nodeValue_Range( "Vortex Angle", [90,90], true )).setCurvable( 9, CURVE_DEF_11, "Over Lifespan"); 
	// 10
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Attract",   false ], 3, 4, 5, 
		[ "Vortex",    false ], 6, 7, 8, 9, 
	];
	
	////- Nodes
	
	curve_strn = undefined;
	curve_vert = undefined;
	curve_vang = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
		
		InputDrawOverlay(inputs[5].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static reset = function() {
		var _strn_curve = getInputData( 4);
		var _vert_curve = getInputData( 7);
		var _vang_curve = getInputData( 9);
		
		curve_strn = new curveMap(_strn_curve);
		curve_vert = new curveMap(_vert_curve);
		curve_vang = new curveMap(_vang_curve);
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = getInputData( 2);
		var _strn = getInputData( 3), _strn_curved = inputs[3].attributes.curved && curve_strn != undefined;
		var _targ = getInputData( 5);
		
		var _vort = getInputData( 6), _vort_curved = inputs[6].attributes.curved && curve_strn != undefined;
		var _vang = getInputData( 8), _vang_curved = inputs[8].attributes.curved && curve_strn != undefined;
		
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
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			
			var rat = _stat? (_frame + _lif + _spwnId * _lifMax) / TOTAL_FRAMES : _lif / (_lifMax - 1);
			    rat = clamp(rat, 0, 1);
			random_set_seed(_seed + _spwnId);
			
			var _strn_mod = _strn_curved? curve_strn.get(rat) : 1;
			var _strn_cur = random_range(_strn[0], _strn[1]) * _strn_mod * _mask;
			
			var _vort_mod = _vort_curved? curve_vort.get(rat) : 1;
			var _vort_cur = random_range(_vort[0], _vort[1]) * _vort_mod * _mask;
			
			var _vang_mod = _vang_curved? curve_vang.get(rat) : 1;
			var _vang_cur = random_range(_vang[0], _vang[1]) * _vang_mod * _mask;
			
			var _dir = point_direction(_px, _py, _targ[0], _targ[1]);
			var _dis = point_distance( _px, _py, _targ[0], _targ[1]);
			    _dis = min(_dis, _strn_cur);
			    
			_px += lengthdir_x(_dis, _dir);
			_py += lengthdir_y(_dis, _dir);
			
			_px += lengthdir_x(_dis * _vort_cur, _dir + _vang_cur);
			_py += lengthdir_y(_dis * _vort_cur, _dir + _vang_cur);
			
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _px );
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _py );
		}
		
	}
	
}