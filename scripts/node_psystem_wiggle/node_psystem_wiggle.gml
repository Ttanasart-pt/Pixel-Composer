function Node_pSystem_Wiggle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wiggle";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_wiggle;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Position
	newInput( 3, nodeValue_Bool(  "Use Wiggle", 0 )).setInternalName("pos_use");
	newInput( 4, nodeValue_Float( "Amplitude",  0 )).setInternalName("pos_amplitude");
	newInput( 5, nodeValue_Float( "Period",     4 )).setInternalName("pos_period");
	newInput( 6, nodeValue_Float( "Octave",     1 )).setInternalName("pos_octave");
	
	////- =Rotation
	newInput( 7, nodeValue_Bool(  "Use Wiggle", 0 )).setInternalName("rot_use");
	newInput( 8, nodeValue_Float( "Amplitude",  0 )).setInternalName("rot_amplitude");
	newInput( 9, nodeValue_Float( "Period",     4 )).setInternalName("rot_period");
	newInput(10, nodeValue_Float( "Octave",     1 )).setInternalName("rot_octave");
	
	////- =Scale
	newInput(11, nodeValue_Bool(  "Use Wiggle", 0 )).setInternalName("sca_use");
	newInput(12, nodeValue_Float( "Amplitude",  0 )).setInternalName("sca_amplitude");
	newInput(13, nodeValue_Float( "Period",     4 )).setInternalName("sca_period");
	newInput(14, nodeValue_Float( "Octave",     1 )).setInternalName("sca_octave");
	
	////- =Direction
	newInput(15, nodeValue_Bool(  "Use Wiggle", 0 )).setInternalName("dir_use");
	newInput(16, nodeValue_Float( "Amplitude",  0 )).setInternalName("dir_amplitude");
	newInput(17, nodeValue_Float( "Period",     4 )).setInternalName("dir_period");
	newInput(18, nodeValue_Float( "Octave",     1 )).setInternalName("dir_octave");
	
	// 19
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false     ], 0, 1, 
		[ "Position",  false,  3 ],  4,  5,  6, 
		[ "Rotation",  false,  7 ],  8,  9, 10, 
		[ "Scale",     false, 11 ], 12, 13, 14, 
		[ "Direction", false, 15 ], 16, 17, 18, 
	];
	
	////- Nodes
	
	wig_psx = new wiggleMap(0, 1, 1024);
	wig_psy = new wiggleMap(0, 1, 1024);
	wig_rot = new wiggleMap(0, 1, 1024);
	wig_scx = new wiggleMap(0, 1, 1024);
	wig_scy = new wiggleMap(0, 1, 1024);
	wig_dir = new wiggleMap(0, 1, 1024);
	
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
		
		var _pos_use = getInputData( 3);
		var _rot_use = getInputData( 7);
		var _sca_use = getInputData(11);
		var _dir_use = getInputData(15);
		
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
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _sx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scax,   buffer_f64  );
			var _sy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scay,   buffer_f64  );
			
			var _rot    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.rot,    buffer_f64  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			if(_pos_use) {
				_px  += wig_psx.getDelta(_seed + _lif) * _mask;
				_py  += wig_psy.getDelta(_seed + _lif) * _mask;
				
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _px  );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _py  );
			}
			
			if(_rot_use) {
				_rot += wig_rot.getDelta(_seed + _lif) * _mask;
				
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.rot,  buffer_f64, _rot );
			}
			
			if(_sca_use) {
				_sx  += wig_scy.getDelta(_seed + _lif) * _mask;
				_sy  += wig_scy.getDelta(_seed + _lif) * _mask;
				
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scax, buffer_f64, _sx  );
				buffer_write_at( _partBuff, _start + PSYSTEM_OFF.scay, buffer_f64, _sy  );
			}
			
			if(_dir_use) {
				var _dir = radtodeg(arctan2(_vy, _vx));
				var _dis = point_distance(0, 0, _vx, _vy) * _mask;
				_dir += wig_dir.getDelta(_seed + _lif) * _mask;
				
				_vx = lengthdir_x( _dis, _dir );
				_vy = lengthdir_y( _dis, _dir );
			}
		}
		
	}
	
	static reset = function() {
		var _seed    = getInputData( 2);
		
		var _pos_amp = getInputData( 4);
		var _pos_per = getInputData( 5);
		var _pos_oct = getInputData( 6);
		
		var _rot_amp = getInputData( 8);
		var _rot_per = getInputData( 9);
		var _rot_oct = getInputData(10);
		
		var _sca_amp = getInputData(12);
		var _sca_per = getInputData(13);
		var _sca_oct = getInputData(14);
		
		var _dir_amp = getInputData(16);
		var _dir_per = getInputData(17);
		var _dir_oct = getInputData(18);
		
		wig_psx.check(_pos_amp, 1 / _pos_per, _seed + 10, _pos_oct);
		wig_psy.check(_pos_amp, 1 / _pos_per, _seed + 20, _pos_oct);
		
		wig_rot.check(_rot_amp, 1 / _rot_per, _seed + 30, _rot_oct);
		
		wig_scx.check(_sca_amp, 1 / _sca_per, _seed + 40, _sca_oct);
		wig_scy.check(_sca_amp, 1 / _sca_per, _seed + 50, _sca_oct);
		
		wig_dir.check(_dir_amp, 1 / _dir_per, _seed + 60, _dir_oct);
		
	}
}