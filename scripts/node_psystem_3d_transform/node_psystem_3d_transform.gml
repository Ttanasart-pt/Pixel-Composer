function Node_pSystem_3D_Transform(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Transform";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_3d_transform);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Direct Move
	newInput(14, nodeValue_Bool(       "Do Move", false ));
	newInput( 3, nodeValue_Vec3_Range( "Move", [0,0,0,0,0,0] )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	
	////- =Vector Move
	/*UNUSED*/ newInput(15, nodeValue_Bool(  "Do Vector Move", false ));
	/*UNUSED*/ newInput( 9, nodeValue_Range( "Speed", [0,0],   true  )).setCurvable(10, CURVE_DEF_11, "Over Lifespan"); 
	/*UNUSED*/ newInput(11, nodeValue_Rotation_Random( "Direction", ROTATION_RANDOM_DEF_0_360 ));
	
	////- =Rotation
	newInput(16, nodeValue_Bool(        "Do Rotate",  false ));
	newInput(13, nodeValue_Enum_Scroll( "Mode",        0, [ "Add", "Multiply", "Override" ] )).setInternalName("scale_mode");
	newInput( 5, nodeValue_Vec3_Range(  "Rotate",   [0,0,0,0,0,0] )).setCurvable(6, CURVE_DEF_11, "Over Lifespan"); 
	
	////- =Scale
	newInput(17, nodeValue_Bool(       "Do Scae", false ));
	newInput(12, nodeValue_Enum_Scroll( "Mode",   1, [ "Add", "Multiply", "Override" ] )).setInternalName("scale_mode");
	newInput( 7, nodeValue_Vec3_Range(  "Scale", [1,1,1,1,1,1], true )).setCurvable(8, CURVE_DEF_11, "Over Lifespan"); 
	// 19
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles",   false     ], 0, 1, 
		[ "Direct Move", false, 14 ], 3, 4, 
		[ "Rotation",    false, 16 ], 13, 5, 6, 
		[ "Scale",       false, 17 ], 12, 7, 8, 
	];
	
	////- Nodes
	
	curve_move = undefined;
	curve_sped = undefined;
	curve_rota = undefined;
	curve_scal = undefined;
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		var _parts = _data[0];
		var _masks = _data[1], use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed      = _data[ 2];
		
		var _do_move   = _data[14];
		var _move      = _data[ 3], _move_curved = inputs[3].attributes.curved && curve_move != undefined;
		
		var _do_rota   = _data[16];
		var _rota_mode = _data[13];
		var _rota      = _data[ 5], _rota_curved = inputs[5].attributes.curved && curve_rota != undefined;
		
		var _do_scal   = _data[17];
		var _scal_mode = _data[12];
		var _scal      = _data[ 7], _scal_curved = inputs[7].attributes.curved && curve_scal != undefined;
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			if(!_act) continue;
			
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
				
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,  buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife, buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			if(_do_move) {
				var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64  );
				var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64  );
				var _pz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posz, buffer_f64  );
				
				var _move_mod = _move_curved? curve_move.get(rat) : 1;
				_px += random_range(_move[0], _move[1]) * _move_mod * _mask;
				_py += random_range(_move[2], _move[3]) * _move_mod * _mask;
				_pz += random_range(_move[4], _move[5]) * _move_mod * _mask;
				
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _px );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _py );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posz, buffer_f64, _pz );
			}
			
			if(_do_rota) {
				var _rx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.rotx,  buffer_f64  );
				var _ry = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.roty,  buffer_f64  );
				var _rz = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.rotz,  buffer_f64  );
				
				var _rota_mod = _rota_curved? curve_rota.get(rat) : 1;
				var _rot_dx = random_range(_rota[0], _rota[1]) * _rota_mod;
				var _rot_dy = random_range(_rota[2], _rota[3]) * _rota_mod;
				var _rot_dz = random_range(_rota[4], _rota[5]) * _rota_mod;
				var _rot_tx = _rx;
				var _rot_ty = _ry;
				var _rot_tz = _rz;
				
				switch(_rota_mode) {
					case 0 : _rot_tx = _rot_tx + _rot_dx; 
						     _rot_ty = _rot_ty + _rot_dy; 
						     _rot_tz = _rot_tz + _rot_dz; break;
						
					case 1 : _rot_tx = _rot_tx * _rot_dx; 
						     _rot_ty = _rot_ty * _rot_dy; 
						     _rot_tz = _rot_tz * _rot_dz; break;
						
					case 2 : _rot_tx = _rot_dx;          
						     _rot_ty = _rot_dy;          
						     _rot_tz = _rot_dz; break;
						
				}
				
				_rx = lerp(_rx, _rot_tx, _mask);
				_ry = lerp(_ry, _rot_ty, _mask);
				_rz = lerp(_rz, _rot_tz, _mask);
				
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.rotx, buffer_f64, _rx );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.roty, buffer_f64, _ry );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.rotz, buffer_f64, _rz );
			}
			
			if(_do_scal) {
				var _sx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scax, buffer_f64  );
				var _sy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scay, buffer_f64  );
				var _sz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scaz, buffer_f64  );
				
				var _scal_mod = _scal_curved? curve_scal.get(rat) : 1;
				var _sx_t = _sx, _sx_d = random_range(_scal[0], _scal[1]) * _scal_mod;
				var _sy_t = _sy, _sy_d = random_range(_scal[2], _scal[3]) * _scal_mod;
				var _sz_t = _sz, _sz_d = random_range(_scal[4], _scal[5]) * _scal_mod;
				
				switch(_scal_mode) {
					case 0 : _sx_t = _sx + _sx_d;
					         _sy_t = _sy + _sy_d; 
					         _sz_t = _sz + _sz_d; break;
					
					case 1 : _sx_t = _sx * _sx_d;
					         _sy_t = _sy * _sy_d; 
					         _sz_t = _sz * _sz_d; break;
						
					case 2 : _sx_t = _sx_d;
					         _sy_t = _sy_d;
					         _sz_t = _sz_d; break;
				}
				
				_sx = lerp(_sx, _sx_t, _mask);
				_sy = lerp(_sy, _sy_t, _mask);
				_sz = lerp(_sz, _sz_t, _mask);
				
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scax, buffer_f64, _sx );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scay, buffer_f64, _sy );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scaz, buffer_f64, _sz );
			}
			
		}
		
	}
	
	static reset = function() {
		var _move_curve = getInputData( 4);
		var _sped_curve = getInputData(10);
		var _rota_curve = getInputData( 6);
		var _scal_curve = getInputData( 8);
		
		curve_move = new curveMap(_move_curve);
		curve_sped = new curveMap(_sped_curve);
		curve_rota = new curveMap(_rota_curve);
		curve_scal = new curveMap(_scal_curve);
	}
}