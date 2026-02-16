#region
	FN_NODE_TOOL_INVOKE {
		hotkeyCustom("Node_pSystem_3D_Boids", "Move Target", "G");
	});
	
#endregion

function Node_pSystem_3D_Boids(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Boids";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_3d_boid);
	
	target_gizmo = new __3dGizmoAxis(.5, c_white, .75 );
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Separation
	newInput( 3, nodeValue_Bool(   "Separate",  true ));
	newInput( 4, nodeValue_Float(  "Radius",    1    )).setInternalName("sep_radius");
	newInput( 5, nodeValue_Slider( "Influence", 0.2  )).setInternalName("sep_influence");
	
	////- =Alignment
	newInput( 6, nodeValue_Bool(   "Align",     true ));
	newInput( 7, nodeValue_Float(  "Radius",    2    )).setInternalName("ali_radius");
	newInput( 8, nodeValue_Slider( "Influence", 0.2  )).setInternalName("ali_influence");
	
	////- =Grouping
	newInput( 9, nodeValue_Bool(   "Group",     true ));
	newInput(10, nodeValue_Float(  "Radius",    2    )).setInternalName("grp_radius");
	newInput(11, nodeValue_Slider( "Influence", 0.2  )).setInternalName("grp_influence");
	
	////- =Follow
	newInput(12, nodeValue_Bool(   "Follow point", false   ));
	newInput(13, nodeValue_Vec3(   "Point",        [0,0,0] ));
	newInput(14, nodeValue_Slider( "Influence",    .1      )).setInternalName("fol_influence");
	
	// 15
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	input_display_list = [ 2, 
		[ "Particles",  false     ],  0,  1, 
		[ "Separation", false,  3 ],  4,  5, 
		[ "Alignment",  false,  6 ],  7,  8, 
		[ "Grouping",   false,  9 ], 10, 11, 
		[ "Follow",     false, 12 ], 13, 14, 
	];
	
	////- Tools
	
	tool_attribute.context = 0;
	tool_ori_obj = new d3d_transform_tool_position(self);
	tool_ori     = new NodeTool( "Move Target", THEME.tools_3d_transform, "Node_pSystem_3D_Boids" ).setToolObject(tool_ori_obj);
	tools = [ tool_ori ];
	
	static drawOverlay3D = function(active, _mx, _my, _params) { 
		var _ori = new __vec3(inputs[13].getValue(,,, true));
		
		if(isUsingTool("Move Target")) tool_ori_obj.drawOverlay3D(13, noone, _ori, active, _mx, _my, _params);
	} 
	
	////- Nodes
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		var _parts = _data[ 0];
		var _masks = _data[ 1], use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = _data[ 2];
		
		var _use_sep = _data[ 3];
		var _sep_rad = _data[ 4], _sep_rad2 = _sep_rad * _sep_rad;
		var _sep_amo = _data[ 5];
		
		var _use_ali = _data[ 6];
		var _ali_rad = _data[ 7], _ali_rad2 = _ali_rad * _ali_rad;
		var _ali_amo = _data[ 8];
		
		var _use_grp = _data[ 9];
		var _grp_rad = _data[10], _grp_rad2 = _grp_rad * _grp_rad;
		var _grp_amo = _data[11];
		var _spd_amp = 1;
		
		var _fol_pnt = _data[12];
		var _pnt_tar = _data[13];
		var _fol_inf = _data[14];
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		var p0x, p0y, p0z, p0vx, p0vy, p0vz;
		var p1x, p1y, p1z, p1vx, p1vy, p1vz;
		var avx, avy, avz, avc;
		var ax,  ay,  az,  ac;
		
		var tarx = _pnt_tar[0];
		var tary = _pnt_tar[1];
		var tarz = _pnt_tar[2];
		
		var max_rad2 = max(_sep_rad2, _ali_rad2, _grp_rad2);
		
		#region preview
			target_gizmo.transform.position.set( _pnt_tar );
			target_gizmo.transform.applyMatrix();
		#endregion
		
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
			
			var _px     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			var _pz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posz,   buffer_f64  );
			
			var _vx     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx,   buffer_f64  );
			var _vy     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely,   buffer_f64  );
			var _vz     = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velz,   buffer_f64  );
			
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
			
			var rat = _lif / (_lifMax - 1);
			random_set_seed(_seed + _spwnId);
			
			p0x  = _px;
			p0y  = _py;
			p0z  = _pz;
			
			p0vx = _vx;
			p0vy = _vy;
			p0vz = _vz;
			
			avx = 0;
			avy = 0;
			avz = 0;
			avc = 0;
			
			ax  = 0;
			ay  = 0;
			az  = 0;
			ac  = 0;
			
			var dis   = sqrt(p0vx * p0vx + p0vy * p0vy + p0vz * p0vz) * _spd_amp;
			var _off2 = 0;
			
			repeat(_partAmo) {
				var _start2 = _off2;
				_off2 += global.pSystem_data_length;
				if(_start == _start2) continue;
				
				var _act = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.active, buffer_bool );
				if(!_act) continue;
				
				p1x  = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.posx,   buffer_f64  );
				p1y  = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.posy,   buffer_f64  );
				p1z  = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.posz,   buffer_f64  );
				
				p1vx = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.velx,   buffer_f64  );
				p1vy = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.vely,   buffer_f64  );
				p1vz = buffer_read_at( _partBuff, _start2 + PSYSTEM_OFF.velz,   buffer_f64  );
				
				var _dx = p0x - p1x;
				var _dy = p0y - p1y;
				var _dz = p0z - p1z;
				
				var _dist = _dx*_dx + _dy*_dy + _dz*_dz;
				if(_dist >= max_rad2) continue;
				
				if(_use_sep && _dist < _sep_rad2) {
					p0x += (p0x - p1x) * _sep_amo * _mask;
					p0y += (p0y - p1y) * _sep_amo * _mask;
					p0z += (p0z - p1z) * _sep_amo * _mask;
				}
				
				if(_use_ali && _dist < _ali_rad2) {
					avx += p1vx;
					avy += p1vy;
					avz += p1vz;
					avc++;
				}
				
				if(_use_grp && _dist < _grp_rad2) {
					ax += p1x;
					ay += p1y;
					az += p1z;
					ac++;
				}
			}
			
			if(_use_ali && avc) {
				avx /= avc;
				avy /= avc;
				avz /= avc;
				
				p0vx += (avx - p0vx) * _ali_amo * _mask;
				p0vy += (avy - p0vy) * _ali_amo * _mask;
				p0vz += (avz - p0vz) * _ali_amo * _mask;
			}
			
			if(_use_grp && ac) {
				ax /= ac;
				ay /= ac;
				az /= ac;
				
				p0x += (ax - p0x) * _grp_amo * _mask;
				p0y += (ay - p0y) * _grp_amo * _mask;
				p0z += (az - p0z) * _grp_amo * _mask;
			}
			
			if(_fol_pnt) {
				p0x += (tarx - p0x) * _fol_inf * _mask;
				p0y += (tary - p0y) * _fol_inf * _mask;
				p0z += (tarz - p0z) * _fol_inf * _mask;
			}
			
			var _disn = point_distance( _px, _py, p0x, p0y);
			
			var _dx = p0x - _px;
			var _dy = p0y - _py;
			var _dz = p0z - _pz;
			var _dd = sqrt(_dx*_dx + _dy*_dy + _dz*_dz);
			
			if(_dd == 0) continue;
			
			var _vx = _dx / _dd * _disn;
			var _vy = _dy / _dd * _disn;
			var _vz = _dz / _dd * _disn;
			
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.velx, buffer_f64, _vx );
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.vely, buffer_f64, _vy );
			buffer_write_at(_partBuff, _start + PSYSTEM_OFF.velz, buffer_f64, _vz );
		}
		
		return;
	}
	
	static reset = function() {
		
	}
	
	////- Draw
	
	static getPreviewObject        = function() /*=>*/ {return noone};
	static getPreviewObjects       = function() /*=>*/ {return [ target_gizmo ]};
	static getPreviewObjectOutline = function() /*=>*/ {return [ target_gizmo ]};
		
}