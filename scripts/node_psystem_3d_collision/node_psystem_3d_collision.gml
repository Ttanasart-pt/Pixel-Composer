function Node_pSystem_3D_Collision(_x, _y, _group = noone) : Node_3D_Object(_x, _y, _group) constructor {
	name  = "Collide";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_3d_collision);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	gizmo_sphere = new __3dGizmoSphere(,, 0.75);
	gizmo_plane  = new __3dGizmoPlane(,, 0.75);
	gizmo_object = noone;
	
	var i = in_d3d;
	
	newInput(i+ 2, nodeValueSeed());
	
	////- =Particles
	newInput(i+ 0, nodeValue_Particle( "Particles" ));
	newInput(i+ 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Collider
	newInput(i+ 3, nodeValue_Enum_Scroll( "Shape",       0, [ "Ground", "Ellipse" ] )); 
	newInput(i+ 4, nodeValue_Slider(      "Chance",      1     )); 
	
	////- =Physics
	newInput(i+ 5, nodeValue_Slider( "Bounciness", .5  )); 
	newInput(i+ 6, nodeValue_Slider( "Friction",   .5  )); 
	newInput(i+ 7, nodeValue_Slider( "Threshold",  .05 )); 
	// 11
	
	newOutput(0, nodeValue_Output("Particles",      VALUE_TYPE.particle, noone ));
	newOutput(1, nodeValue_Output("On Collide",     VALUE_TYPE.trigger,  false )).setVisible(false);
	newOutput(2, nodeValue_Output("Collision Mask", VALUE_TYPE.buffer,   false )).setVisible(false);
	
	input_display_list = [ i+2, 
		[ "Particles", false ], i+0, i+1, 
		[ "Collider",  false ], i+3, 0, 1, 2, i+4, 
		[ "Physics",   false ], i+5, i+6, i+7,  
	];
	
	////- Nodes
	
	shape_type  = 0;
	mask_buffer = undefined;
	collideTrig = undefined;
	
	static reset = function() {
		
	}
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		var i = in_d3d;
		var _parts = _data[i+0];
		var _masks = _data[i+1], use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _seed = _data[i+2];
		
		var _shap = _data[i+3];
		var _pos  = _data[  0];
		var _rot  = _data[  1];
		var _sca  = _data[  2];
		var _chan = _data[i+4];
		
		var _boun = _data[i+5];
		var _fric = _data[i+6];
		var _thrs = _data[i+7];
		
		var _poolSize = _parts.poolSize;
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off  = 0;
		var _maxs = max(_sca[0], _sca[1], _sca[2]);
			
		shape_type = _shap;
		
		if(_shap == 0) {
			gizmo_object = gizmo_plane;
			
			setTransform(gizmo_plane, _data);
			gizmo_plane.transform.scale.set(1, 1, 1);
			gizmo_plane.transform.applyMatrix();
			
			var _prot    = new BBMOD_Quaternion(_rot[0], _rot[1], _rot[2], _rot[3]);
			plane_normal = _prot.Rotate(new BBMOD_Vec3(0, 0, 1)).ToArray();
			
		} else if(_shap == 1) {
			gizmo_object = gizmo_sphere;
			
			setTransform(gizmo_sphere, _data);
			gizmo_sphere.transform.scale.set(_maxs, _maxs, _maxs);
			gizmo_sphere.transform.applyMatrix();
			
		}
		
		var _pools = _parts.poolSize;
		mask_buffer = buffer_verify(mask_buffer, _pools * 4);
		buffer_to_start(mask_buffer);
		
		collideTrig  = buffer_verify(collideTrig, 4 + _poolSize * global.pSystem_trig_length);
		var collideCount = 0;
		buffer_seek(collideTrig, buffer_seek_start, 4);
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) { buffer_write(mask_buffer, buffer_f32, 0); continue; }
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			var _pz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posz,   buffer_f64  );
			
			var _sx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scax,   buffer_f64  );
			var _sy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scay,   buffer_f64  );
			var _sz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scaz,   buffer_f64  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			var _vz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velz,   buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			var _groundDist = 1;
			var _nx = 0;
			var _ny = 0;
			var _nz = 1;
			
			switch(_shap) {
				case 0 : // ground
					_groundDist = d3d_point_to_plane(_pos, plane_normal, [_px, _py, _pz]);
					_nx   = plane_normal[0];
					_ny   = plane_normal[1];
					_nz   = plane_normal[2];
					break;
					
				case 1 : // ellipse
					var _dis = point_distance_3d(_pos[0], _pos[1], _pos[2], _px, _py, _pz);
					_groundDist = _dis - _maxs / 2;
					
					_nx = _pos[0] - _px;
					_ny = _pos[1] - _py;
					_nz = _pos[2] - _pz;
					
					var _dd = sqrt(_nx*_nx + _ny*_ny + _nz*_nz);
					_nx /= _dd;
					_ny /= _dd;
					_nz /= _dd;
					break;
			}
			
			if(_groundDist > 0 || random(1) > _chan) {
				buffer_write(mask_buffer, buffer_f32, 0);
				continue;
			}
			
			var _diss = point_distance_3d(0,0,0, _vx, _vy, _vz );
			var _dot  = _vx * _nx + _vy * _ny + _vz * _nz;
		    
	        var _rx = _vx - 2 * _dot * _nx;
	        var _ry = _vy - 2 * _dot * _ny;
	        var _rz = _vz - 2 * _dot * _nz;
		    
		    var _rr = point_distance_3d(0,0,0, _rx, _ry, _rz );
		    
			var _rnx = _rx / _rr;
			var _rny = _ry / _rr;
			var _rnz = _rz / _rr;
			
			var _cx = _px - _rnx * _groundDist;
			var _cy = _py - _rny * _groundDist;
			var _cz = _pz - _rnz * _groundDist;
			
			if(_diss < _thrs) {
				_vx = 0;
				_vy = 0;
				_vy = 0;
				
			} else {
				_vx = _diss * _rnx * _boun;
				_vy = _diss * _rny * _boun;
				_vz = _diss * _rnz * _boun;
				
				buffer_write(collideTrig, buffer_f64, _cx);
				buffer_write(collideTrig, buffer_f64, _cy);
				buffer_write(collideTrig, buffer_f64, _cz);
				
				buffer_write(collideTrig, buffer_f64, _vx);
				buffer_write(collideTrig, buffer_f64, _vy);
				buffer_write(collideTrig, buffer_f64, _vz);
				collideCount++;
			}
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posx, buffer_f64, _cx );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posy, buffer_f64, _cy );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.posz, buffer_f64, _cz );
			
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.velx, buffer_f64, _vx );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.vely, buffer_f64, _vy );
			buffer_write_at( _partBuff, _start + PSYSTEM_OFF.velz, buffer_f64, _vz );
			
			buffer_write(mask_buffer, buffer_f32, 1);
		}
		
		buffer_write_at(collideTrig, 0, buffer_u32, collideCount);
		
		outputs[0].setValue(_parts);
		outputs[1].setValue(collideTrig);
		outputs[2].setValue(mask_buffer);
	}
	
	static getPreviewObjects		= function() /*=>*/ {return [getPreviewObject(), gizmo_object]};
	static getPreviewObjectOutline  = function() /*=>*/ {return [gizmo_object]};
}