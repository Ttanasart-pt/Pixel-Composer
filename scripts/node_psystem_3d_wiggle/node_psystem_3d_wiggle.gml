function Node_pSystem_3D_Wiggle(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Wiggle";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_3d_wiggle;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Position
	newInput( 3, nodeValue_Bool(  "Use Wiggle", 0 )).setInternalName("pos_use");
	newInput( 4, nodeValue_Range( "Amplitude", [0,0], true )).setCurvable(19, CURVE_DEF_11, "Over Lifespan").setInternalName("pos_amplitude");
	newInput( 5, nodeValue_Float( "Period",     4 )).setInternalName("pos_period");
	newInput( 6, nodeValue_Float( "Octave",     1 )).setInternalName("pos_octave");
	
	////- =Rotation
	newInput( 7, nodeValue_Bool(  "Use Wiggle", 0 )).setInternalName("rot_use");
	newInput( 8, nodeValue_Range( "Amplitude", [0,0], true )).setCurvable(20, CURVE_DEF_11, "Over Lifespan").setInternalName("rot_amplitude");
	newInput( 9, nodeValue_Float( "Period",     4 )).setInternalName("rot_period");
	newInput(10, nodeValue_Float( "Octave",     1 )).setInternalName("rot_octave");
	
	////- =Scale
	newInput(11, nodeValue_Bool(  "Use Wiggle", 0 )).setInternalName("sca_use");
	newInput(12, nodeValue_Range( "Amplitude", [0,0], true )).setCurvable(21, CURVE_DEF_11, "Over Lifespan").setInternalName("sca_amplitude");
	newInput(13, nodeValue_Float( "Period",     4 )).setInternalName("sca_period");
	newInput(14, nodeValue_Float( "Octave",     1 )).setInternalName("sca_octave");
	
	////- =Direction
	newInput(15, nodeValue_Bool(  "Use Wiggle", 0 )).setInternalName("dir_use");
	newInput(16, nodeValue_Range( "Amplitude", [0,0], true )).setCurvable(22, CURVE_DEF_11, "Over Lifespan").setInternalName("dir_amplitude");
	newInput(17, nodeValue_Float( "Period",     4 )).setInternalName("dir_period");
	newInput(18, nodeValue_Float( "Octave",     1 )).setInternalName("dir_octave");
	
	// 23
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false     ], 0, 1, 
		[ "Position",  false,  3 ],  4, 19,  5,  6, 
		[ "Rotation",  false,  7 ],  8, 20,  9, 10, 
		[ "Scale",     false, 11 ], 12, 21, 13, 14, 
		[ "Direction", false, 15 ], 16, 22, 17, 18, 
	];
	
	////- Nodes
	
	wig_psx = new wiggleMap(0, 1, 1024);
	wig_psy = new wiggleMap(0, 1, 1024);
	wig_psz = new wiggleMap(0, 1, 1024);
	
	wig_rtx = new wiggleMap(0, 1, 1024);
	wig_rty = new wiggleMap(0, 1, 1024);
	wig_rtz = new wiggleMap(0, 1, 1024);
	
	wig_scx = new wiggleMap(0, 1, 1024);
	wig_scy = new wiggleMap(0, 1, 1024);
	wig_scz = new wiggleMap(0, 1, 1024);
	
	wig_dir = new wiggleMap(0, 1, 1024);
	
	curve_pos = undefined;
	curve_rot = undefined;
	curve_sca = undefined;
	curve_dir = undefined;
	
	static reset = function() {
		var _seed    = getInputData( 2);
		
		var _pos_per = getInputData( 5);
		var _pos_oct = getInputData( 6);
		
		var _rot_per = getInputData( 9);
		var _rot_oct = getInputData(10);
		
		var _sca_per = getInputData(13);
		var _sca_oct = getInputData(14);
		
		var _dir_per = getInputData(17);
		var _dir_oct = getInputData(18);
		
		wig_psx.check(1, 1 / _pos_per, _seed + 10, _pos_oct);
		wig_psy.check(1, 1 / _pos_per, _seed + 20, _pos_oct);
		wig_psz.check(1, 1 / _pos_per, _seed + 30, _pos_oct);
		
		wig_rtx.check(1, 1 / _rot_per, _seed + 40, _rot_oct);
		wig_rty.check(1, 1 / _rot_per, _seed + 50, _rot_oct);
		wig_rtz.check(1, 1 / _rot_per, _seed + 60, _rot_oct);
		
		wig_scx.check(1, 1 / _sca_per, _seed + 70, _sca_oct);
		wig_scy.check(1, 1 / _sca_per, _seed + 80, _sca_oct);
		wig_scz.check(1, 1 / _sca_per, _seed + 90, _sca_oct);
		
		wig_dir.check(1, 1 / _dir_per, _seed + 100, _dir_oct);
		
		curve_pos = new curveMap(getInputData(19));
		curve_rot = new curveMap(getInputData(20));
		curve_sca = new curveMap(getInputData(21));
		curve_dir = new curveMap(getInputData(22));
	}
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		var _parts = _data[ 0];
		var _masks = _data[ 1], use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = _data[ 2];
		
		var _pos_use = _data[ 3];
		var _pos_amp = _data[ 4], _pos_curved = inputs[ 4].attributes.curved && curve_pos != undefined;
		
		var _rot_use = _data[ 7];
		var _rot_amp = _data[ 8], _rot_curved = inputs[ 8].attributes.curved && curve_rot != undefined;
		
		var _sca_use = _data[11];
		var _sca_amp = _data[12], _sca_curved = inputs[12].attributes.curved && curve_sca != undefined;
		
		var _dir_use = _data[15];
		var _dir_amp = _data[16], _dir_curved = inputs[16].attributes.curved && curve_dir != undefined;
		
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
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			if(_pos_use) {
				var _px = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
				var _py = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
				var _pz = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posz,   buffer_f64  );
				
				var _pos_mod = _pos_curved? curve_pos.get(rat) : 1;
				var _pos_cur = random_range(_pos_amp[0], _pos_amp[1]) * _pos_mod * _mask;
				
				_px  += wig_psx.getDelta(_seed + _lif) * _pos_cur * _mask;
				_py  += wig_psy.getDelta(_seed + _lif) * _pos_cur * _mask;
				_pz  += wig_psz.getDelta(_seed + _lif) * _pos_cur * _mask;
				
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _px  );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _py  );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posz, buffer_f64, _pz  );
			}
			
			if(_rot_use) {
				var _rx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.rotx, buffer_f64  );
				var _ry = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.roty, buffer_f64  );
				var _rz = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.rotz, buffer_f64  );
				
				var _rot_mod = _rot_curved? curve_rot.get(rat) : 1;
				var _rot_cur = random_range(_rot_amp[0], _rot_amp[1]) * _rot_mod * _mask;
				
				_rx += wig_rtx.getDelta(_seed + _lif) * _rot_cur * _mask;
				_ry += wig_rty.getDelta(_seed + _lif) * _rot_cur * _mask;
				_rz += wig_rtz.getDelta(_seed + _lif) * _rot_cur * _mask;
				
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.rotx,  buffer_f64, _rx );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.roty,  buffer_f64, _ry );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.rotz,  buffer_f64, _rz );
			}
			
			if(_sca_use) {
				var _sx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scax,   buffer_f64  );
				var _sy = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scay,   buffer_f64  );
				var _sz = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scaz,   buffer_f64  );
				
				var _sca_mod = _sca_curved? curve_sca.get(rat) : 1;
				var _sca_cur = random_range(_sca_amp[0], _sca_amp[1]) * _sca_mod * _mask;
				
				_sx  += wig_scy.getDelta(_seed + _lif) * _sca_cur * _mask;
				_sy  += wig_scy.getDelta(_seed + _lif) * _sca_cur * _mask;
				_sz  += wig_scz.getDelta(_seed + _lif) * _sca_cur * _mask;
				
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scax, buffer_f64, _sx  );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scay, buffer_f64, _sy  );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scaz, buffer_f64, _sz  );
			}
			
			if(_dir_use) {
				var _vx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
				var _vy = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
				var _vz = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velz,   buffer_f64  );
				var _vv = sqrt(_vx*_vx + _vy*_vy + _vz*_vz);
				
				var _dir_mod = _dir_curved? curve_dir.get(rat) : 1;
				var _dir_cur = random_range(_dir_amp[0], _dir_amp[1]) * _dir_mod * _mask;
				
				var _nx = _vx / _vv;
				var _ny = _vy / _vv;
				var _nz = _vz / _vv;
				
				_vv += wig_dir.getDelta(_seed + _lif) * _dir_cur * _mask;
				
				_vx = _nx * _vv;
				_vy = _ny * _vv;
				_vz = _nz * _vv;
			}
		}
		
	}
	
}