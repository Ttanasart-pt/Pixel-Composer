function Node_pSystem_3D_Render_Model(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Render Model";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	update_on_frame = true;
	
	newInput(2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Mesh
	newInput( 3, nodeValue_D3Mesh("Mesh", noone)).setVisible(true, true);
	
	////- =Render
	newInput( 4, nodeValue_Enum_Scroll( "Blend Mode",     0, [ "Normal", "Alpha", "Additive", "Maximum" ]));
	newInput( 5, nodeValue_Bool(        "Billboard",      false ));
	// 
	
	newOutput(0, nodeValue_Output( "Mesh", VALUE_TYPE.d3Mesh, noone ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Mesh",      false ], 3, 
		[ "Render",    false ], 4, 5,  
	];
	
	////- Nodes
	
	particleSystem   = new __3dObjectParticle();
	buffer_transform = undefined;
	buffer_particle  = undefined;
	buffer_particle2 = undefined;
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		if(!is(inline_context, Node_pSystem_3D_Inline) || inline_context.prerendering) return;
		
		var _parts = _data[0];
		var _masks = _data[1], use_mask = _masks != noone;
		var _obj   = _data[3];
		
		var _blnd_mode = _data[4];
		var _billboard = _data[5];
			
		if(!is(_parts, pSystem_Particles)) return;
		if(!is(_obj, __3dInstance))        return;
		if(use_mask) buffer_to_start(_masks);
		
		var _poolSize = _parts.poolSize;
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		
		#region buffer
			buffer_transform  = buffer_verify(buffer_transform, 64 * _poolSize);
			buffer_particle   = buffer_verify(buffer_particle,  64 * _poolSize);
			buffer_particle2  = buffer_verify(buffer_particle2, 16 * _poolSize);
		#endregion
		
		#region base instancer
			var system = particleSystem;
			if(IS_FIRST_FRAME) {
				system.instance_amount = _poolSize;
				system.transparent     = false;
				system.objectTransform = _obj.transform;
				system.objectTransform.applyMatrix();
				
				var _flat_vb = d3d_flattern(_obj);
				system.VB = _flat_vb.VB;
				system.materials = _flat_vb.materials;
				
				buffer_clear(buffer_transform);
				buffer_clear(buffer_particle);
				buffer_clear(buffer_particle2);
			}
		#endregion
		
		#region constant buffer
			buffer_to_start(buffer_transform);
			buffer_to_start(buffer_particle);
			buffer_to_start(buffer_particle2);
				
			var _off     = 0;
			var _partAct = 0;
			
			repeat(_partAmo) {
				var _start = _off;
				buffer_seek(_partBuff, buffer_seek_start, _start);
				_off += global.pSystem_data_length;
				
				var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
				var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
				if(!_act) continue;
				
				var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
				var _life   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_u32  );
				var _mlife  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_u32  );
				
				var _surf_  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.surf,   buffer_f64 );
				var _bldR   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnr,   buffer_u8  );
				var _bldG   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blng,   buffer_u8  );
				var _bldB   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blnb,   buffer_u8  );
				var _bldA   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.blna,   buffer_u8  );
				
				var _dfg    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
				
				var _px  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx), buffer_f64 );
				var _py  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposy : PSYSTEM_OFF.posy), buffer_f64 );
				var _pz  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposz : PSYSTEM_OFF.posz), buffer_f64 );
				
				var _sx  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b010)? PSYSTEM_OFF.dscax : PSYSTEM_OFF.scax), buffer_f64 );
				var _sy  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b010)? PSYSTEM_OFF.dscay : PSYSTEM_OFF.scay), buffer_f64 );
				var _sz  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b010)? PSYSTEM_OFF.dscaz : PSYSTEM_OFF.scaz), buffer_f64 );
				
				var _rx  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b001)? PSYSTEM_OFF.drotx : PSYSTEM_OFF.rotx), buffer_f64 );
				var _ry  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b001)? PSYSTEM_OFF.droty : PSYSTEM_OFF.roty), buffer_f64 );
				var _rz  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b001)? PSYSTEM_OFF.drotz : PSYSTEM_OFF.rotz), buffer_f64 );
				
				var _vx  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx, buffer_f64 );
				var _vy  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely, buffer_f64 );
				var _vz  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velz, buffer_f64 );
				
				var _psx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.possx, buffer_f64 );
				var _psy = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.possy, buffer_f64 );
				var _psz = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.possz, buffer_f64 );
				
				var _nx  = 0;
				var _ny  = 0;
				var _nz  = 1;
				
				var _flag = (_billboard * 0b0001);
				
				// print(_spwnId, _px, _py, _pz);
				
				buffer_write(buffer_transform, buffer_f32, _px); // pos X
				buffer_write(buffer_transform, buffer_f32, _py); // pos Y
				buffer_write(buffer_transform, buffer_f32, _pz); // pos Z
				buffer_write(buffer_transform, buffer_f32, 0);
				
				buffer_write(buffer_transform, buffer_f32, _rx); // rot X 
				buffer_write(buffer_transform, buffer_f32, _ry); // rot Y 
				buffer_write(buffer_transform, buffer_f32, _rz); // rot Z
				buffer_write(buffer_transform, buffer_f32, 0);
				
				buffer_write(buffer_transform, buffer_f32, _sx); // sca X 
				buffer_write(buffer_transform, buffer_f32, _sy); // sca Y 
				buffer_write(buffer_transform, buffer_f32, _sz); // sca Z
				buffer_write(buffer_transform, buffer_f32, 0);
				
				buffer_write(buffer_transform, buffer_f32, _nx); // norm X
				buffer_write(buffer_transform, buffer_f32, _ny); // norm Y
				buffer_write(buffer_transform, buffer_f32, _nz); // norm Z
				buffer_write(buffer_transform, buffer_f32, 0);
				
				buffer_write(buffer_particle, buffer_f32, _act);    // active
				buffer_write(buffer_particle, buffer_f32, _spwnId); // particle index
				buffer_write(buffer_particle, buffer_f32, _mlife);  // life max
				buffer_write(buffer_particle, buffer_f32, _life);   // life curr
				
				buffer_write(buffer_particle, buffer_f32, _flag); // render flag
				buffer_write(buffer_particle, buffer_f32, 0); // 
				buffer_write(buffer_particle, buffer_f32, 0); // 
				buffer_write(buffer_particle, buffer_f32, 0); // 
				
				buffer_write(buffer_particle, buffer_f32, _bldR / 255); // color R
				buffer_write(buffer_particle, buffer_f32, _bldG / 255); // color G
				buffer_write(buffer_particle, buffer_f32, _bldB / 255); // color B
				buffer_write(buffer_particle, buffer_f32, _bldA / 255); // color A
				
				buffer_write(buffer_particle, buffer_f32, _vx); // velocity X
				buffer_write(buffer_particle, buffer_f32, _vy); // velocity Y
				buffer_write(buffer_particle, buffer_f32, _vz); // velocity Z
				buffer_write(buffer_particle, buffer_f32, 0);
				
				buffer_write(buffer_particle2, buffer_f32, _psx); // start position X
				buffer_write(buffer_particle2, buffer_f32, _psy); // start position Y
				buffer_write(buffer_particle2, buffer_f32, _psz); // start position Z
				buffer_write(buffer_particle2, buffer_f32, 0);
			
				_partAct++;
			}
			
			system.batch_count = 1;
			system.setBuffer(         buffer_transform, 0, _partAct );
			system.setBufferParticle( buffer_particle,  0, _partAct );
			
			switch(_blnd_mode) {
				case 0 : system.blend_mode = BLEND.normal;  break;
				case 1 : system.blend_mode = BLEND.alpha;   break;
				case 2 : system.blend_mode = BLEND.add;     break;
				case 3 : system.blend_mode = BLEND.maximum; break;
			}
		#endregion
		
		outputs[0].setValue(system);
	}
	
	static reset = function() {
		
	}
	
	////- Draw
	
	static getPreviewObject        = function() /*=>*/ {return particleSystem};
	static getPreviewObjects       = function() /*=>*/ {return [ particleSystem ]};
	static getPreviewObjectOutline = function() /*=>*/ {return [ particleSystem ]};
	
	static cleanUp = function() {
		buffer_delete_safe(buffer_transform);
		buffer_delete_safe(buffer_particle);
		buffer_delete_safe(buffer_particle2);
	}
}