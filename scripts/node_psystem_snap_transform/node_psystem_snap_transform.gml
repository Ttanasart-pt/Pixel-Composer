function Node_pSystem_Snap_Transform(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Snap Transform";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_snap_transform);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Position
	newInput(16, nodeValue_Bool(  "Snap Position", false ));
	newInput( 8, nodeValue_Vec2_Range( "Position Snap",  [0,0,0,0], true )).setCurvable( 9, CURVE_DEF_11, "Over Lifespan"); 
	newInput(10, nodeValue_Vec2_Range( "Position Shift", [0,0,0,0], true )); 
	newInput(14, nodeValue_Bool(  "Override Position" ));
	
	////- =Angle
	newInput(17, nodeValue_Bool(  "Snap Angle", false ));
	newInput( 3, nodeValue_Range( "Angle Snap",  [1,1], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	newInput( 5, nodeValue_Range( "Angle Shift", [0,0], true )).setCurvable( 6, CURVE_DEF_11, "Over Lifespan"); 
	newInput( 7, nodeValue_Bool(  "Override Angle" ));
	
	////- =Scale
	newInput(18, nodeValue_Bool(  "Snap Scale", false ));
	newInput(11, nodeValue_Vec2_Range( "Scale Snap",  [0,0,0,0], true )).setCurvable(12, CURVE_DEF_11, "Over Lifespan"); 
	newInput(13, nodeValue_Vec2_Range( "Scale Shift", [0,0,0,0], true )); 
	newInput(15, nodeValue_Bool(  "Override Scale" ));
	// 19
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false     ], 0, 1, 
		[ "Position",  false, 16 ], 8, 9, 10, 14, 
		[ "Angle",     false, 17 ], 3, 4, 5, 6, 7, 
		[ "Scale",     false, 18 ], 11, 12, 13, 15, 
	];
	
	////- Nodes
	
	curve_posi_snap = undefined;
	curve_posi_shft = undefined;
	curve_rota_snap = undefined;
	curve_rota_shft = undefined;
	curve_scal_snap = undefined;
	curve_scal_shft = undefined;
	
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
		
		var _seed      = getInputData( 2);
		
		var _posi      = getInputData(16);
		var _posi_snap = getInputData( 8), _posi_snap_curved = inputs[8].attributes.curved && curve_posi_snap != undefined;
		var _posi_shft = getInputData(10);
		var _posi_over = getInputData(14);
		
		var _rota      = getInputData(17);
		var _rota_snap = getInputData( 3), _rota_snap_curved = inputs[3].attributes.curved && curve_rota_snap != undefined;
		var _rota_shft = getInputData( 5), _rota_shft_curved = inputs[5].attributes.curved && curve_rota_shft != undefined;
		var _rota_over = getInputData( 7);
		
		var _scal      = getInputData(18);
		var _scal_snap = getInputData(11), _scal_snap_curved = inputs[11].attributes.curved && curve_scal_snap != undefined;
		var _scal_shft = getInputData(13);
		var _scal_over = getInputData(15);
		
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
			if(!_act) continue;
			
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			var _sx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scax,   buffer_f64  );
			var _sy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scay,   buffer_f64  );
			var _rot    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.rotx,    buffer_f64  );
			
			var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var rat = _stat? (_frame + _lif + _spwnId * _lifMax) / TOTAL_FRAMES : _lif / (_lifMax - 1);
			    rat = clamp(rat, 0, 1);
			random_set_seed(_seed + _spwnId);
			
			if(_posi) {
				var _posi_snap_mod    = _posi_snap_curved? curve_posi_snap.get(rat) : 1;
				var _posi_snap_x_curr = random_range(_posi_snap[0], _posi_snap[1]) * _posi_snap_mod;
				var _posi_snap_y_curr = random_range(_posi_snap[2], _posi_snap[3]) * _posi_snap_mod;
				
				var _posi_shft_x_curr = random_range(_posi_shft[0], _posi_shft[1]);
				var _posi_shft_y_curr = random_range(_posi_shft[2], _posi_shft[3]);
				
				_px = value_snap(_px - _posi_shft_x_curr, _posi_snap_x_curr) + _posi_shft_x_curr;
				_py = value_snap(_py - _posi_shft_y_curr, _posi_snap_y_curr) + _posi_shft_y_curr;
				
				_dfg |= 0b100 * !_posi_over;
			}
			
			if(_rota) {
				var _rota_snap_mod  = _rota_snap_curved? curve_rota_snap.get(rat) : 1;
				var _rota_snap_curr = random_range(_rota_snap[0], _rota_snap[1]) * _rota_snap_mod;
				
				var _rota_shft_mod  = _rota_shft_curved? curve_rota_shft.get(rat) : 1;
				var _rota_shft_curr = random_range(_rota_shft[0], _rota_shft[1]) * _rota_shft_mod;
				
				_rot = value_snap(_rot - _rota_shft_curr, _rota_snap_curr) + _rota_shft_curr;
				
				_dfg |= 0b001 * !_rota_over;
			}
			
			if(_scal) {
				var _scal_snap_mod    = _scal_snap_curved? curve_scal_snap.get(rat) : 1;
				var _scal_snap_x_curr = random_range(_scal_snap[0], _scal_snap[1]) * _scal_snap_mod;
				var _scal_snap_y_curr = random_range(_scal_snap[2], _scal_snap[3]) * _scal_snap_mod;
				
				var _scal_shft_x_curr = random_range(_scal_shft[0], _scal_shft[1]);
				var _scal_shft_y_curr = random_range(_scal_shft[2], _scal_shft[3]);
				
				_sx = value_snap(_sx - _scal_shft_x_curr, _scal_snap_x_curr) + _scal_shft_x_curr;
				_sy = value_snap(_sy - _scal_shft_y_curr, _scal_snap_y_curr) + _scal_shft_y_curr;
				
				_dfg |= 0b010 * !_scal_over;
			}
			
			buffer_write_at( _partBuff, _start + ( _posi_over? PSYSTEM_OFF.posx : PSYSTEM_OFF.dposx ), buffer_f64, _px  );
			buffer_write_at( _partBuff, _start + ( _posi_over? PSYSTEM_OFF.posy : PSYSTEM_OFF.dposy ), buffer_f64, _py  );
			buffer_write_at( _partBuff, _start + ( _scal_over? PSYSTEM_OFF.scax : PSYSTEM_OFF.dscax ), buffer_f64, _sx  );
			buffer_write_at( _partBuff, _start + ( _scal_over? PSYSTEM_OFF.scay : PSYSTEM_OFF.dscay ), buffer_f64, _sy  );
			buffer_write_at( _partBuff, _start + ( _rota_over? PSYSTEM_OFF.rotx  : PSYSTEM_OFF.drotx  ), buffer_f64, _rot );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.dflag, buffer_u16, _dfg );
		}
		
	}
	
	static reset = function() {
		var _posi_snap_curve = getInputData( 9);
		var _rota_snap_curve = getInputData( 4);
		var _rota_shft_curve = getInputData( 6);
		var _scal_snap_curve = getInputData(12);
		
		curve_posi_snap = new curveMap(_posi_snap_curve);
		curve_rota_snap = new curveMap(_rota_snap_curve);
		curve_rota_shft = new curveMap(_rota_shft_curve);
		curve_scal_snap = new curveMap(_scal_snap_curve);
	}
}