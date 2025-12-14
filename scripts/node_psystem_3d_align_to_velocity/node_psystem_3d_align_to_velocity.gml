function Node_pSystem_3D_Align_to_Velocity(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Align Velocity";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_3d_align_to_velocity);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Alignment
	newInput( 3, nodeValue_Enum_Button( "Axis", 0, ["X", "Y", "Z"] ));
	// 4
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		// [ "Alignment", false ], 3, 
	];
	
	////- Nodes
	
	_qup = new BBMOD_Vec3(0, 0, -1);
	_for = new BBMOD_Vec3(0, 0, 0);
	
	static reset = function() {
		
	}
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		var _parts = _data[ 0];
		var _masks = _data[ 1], use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = _data[ 2];
		var _axis = _data[ 3];
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		var _rot = [0,0,0];
		
		var _qi1x = 0;
		var _qi1y = -sqrt(2)/2;
		var _qi1z = 0;
		var _qi1w = sqrt(2)/2;
		
		var _qi2x = sqrt(2)/2;
		var _qi2y = 0;
		var _qi2z = 0;
		var _qi2w = sqrt(2)/2;
		
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
			var _pz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posz,   buffer_f64  );
			
			var _ppx    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospx,  buffer_f64  );
			var _ppy    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospy,  buffer_f64  );
			var _ppz    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.pospz,  buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			var _vz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velz,   buffer_f64  );
			
			var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
			
			random_set_seed(_seed + _spwnId);
			
			var _fx  = _px + _vx - _ppx;
			var _fy  = _py + _vy - _ppy;
			var _fz  = _pz + _vz - _ppz;
			
			if(_fx == 0 && _fy == 0 && _fz == 0) continue;
			
			_for.X = _fx;
			_for.Y = _fy;
			_for.Z = _fz;
			
			_qup.X =  0;
			_qup.Y =  0;
			_qup.Z = -1;
			
			// print(_fx, _fy, _fz, _qup);
			
			var qx = 0;
			var qy = 0;
			var qz = 0;
			var qw = 1;
			
			if (_for.Orthonormalize(_qup)) {
				var _rgx = _qup.Y * _for.Z - _qup.Z * _for.Y;
				var _rgy = _qup.Z * _for.X - _qup.X * _for.Z;
				var _rgz = _qup.X * _for.Y - _qup.Y * _for.X;
				
				var _w = sqrt(abs(1.0 + _rgx + _qup.Y + _for.Z)) * 0.5;
				var _w4Recip = _w == 0? 0 : 1.0 / (4.0 * _w);
				
				qx = (_qup.Z - _for.Y) * _w4Recip;
				qy = (_for.X - _rgz) * _w4Recip;
				qz = (_rgy - _qup.X) * _w4Recip;
				qw = _w;
			}
			
			var q2x = qx * _qi1w - qz * _qi1y;
			var q2y = qw * _qi1y + qy * _qi1w;
			var q2z = qz * _qi1w + qx * _qi1y;
			var q2w = qw * _qi1w - qy * _qi1y;
				
			var X = q2w * _qi2x + q2x * _qi2w;
			var Y = q2y * _qi2w + q2z * _qi2x;
			var Z = q2z * _qi2w - q2y * _qi2x;
			var W = q2w * _qi2w - q2x * _qi2x;
				
			var ysqr = Y * Y;

		    // roll (x-axis rotation)
		    var t0 = +2.0 * (W * X + Y * Z);
		    var t1 = +1.0 - 2.0 * (X * X + ysqr);
		    var roll = arctan2(t0, t1);
	
		    // pitch (y-axis rotation)
		    var t2 = +2.0 * (W * Y - Z * X);
		    t2 = clamp(t2, -1.0, 1.0);  // Prevent numerical instability
		    var pitch = arcsin(t2);
	
		    // yaw (z-axis rotation)
		    var t3 = +2.0 * (W * Z + X * Y);
		    var t4 = +1.0 - 2.0 * (ysqr + Z * Z);
		    var yaw = arctan2(t3, t4);
	
		    // Convert radians to degrees
		    var _rx = roll  * 180.0 / pi;
		    var _ry = pitch * 180.0 / pi;
		    var _rz = yaw   * 180.0 / pi;
	
			buffer_write_at(_partBuff, _start + (bool(_dfg & 0b001)? PSYSTEM_OFF.drotx : PSYSTEM_OFF.rotx), buffer_f64, _rx );
			buffer_write_at(_partBuff, _start + (bool(_dfg & 0b001)? PSYSTEM_OFF.droty : PSYSTEM_OFF.roty), buffer_f64, _ry );
			buffer_write_at(_partBuff, _start + (bool(_dfg & 0b001)? PSYSTEM_OFF.drotz : PSYSTEM_OFF.rotz), buffer_f64, _rz );
			
		}
		
	}
	
}