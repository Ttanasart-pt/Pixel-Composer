function Node_pSystem_Acceleration(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Accelerate";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_acceleration;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Acceleration
	newInput( 3, nodeValue_Range( "Acceleration", [0,0], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	// 6
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles",    false ], 0, 1, 
		[ "Acceleration", false ], 3, 4,
	];
	
	////- Nodes
	
	curve_acel = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = getInputData( 2);
		var _acel = getInputData( 3), _acel_curved = inputs[3].attributes.curved && curve_acel != undefined;
		var _dirr = getInputData( 5);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		var _gx = lengthdir_x(1, _dirr);
		var _gy = lengthdir_y(1, _dirr);
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			var _acel_mod = _acel_curved? curve_acel.get(rat) : 1;
			var _acel_cur = random_range(_acel[0], _acel[1]) * _acel_mod;
			
			_vx = max(_vx * (1 + _acel_cur * _mask), 0);
			_vy = max(_vy * (1 + _acel_cur * _mask), 0);
			
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.velx, buffer_f64, _vx );
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.vely, buffer_f64, _vy );
		}
		
	}
	
	static reset = function() {
		var _acel_curve = getInputData( 4);
		
		curve_acel = new curveMap(_acel_curve);
	}
}