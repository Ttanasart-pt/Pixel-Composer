function Node_pSystem_3D_Destroy(_x, _y, _group = noone) : Node_3D(_x, _y, _group) constructor {
	name  = "Destroy";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	node_draw_icon = s_node_psystem_3d_destroy;
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Destroy
	newInput( 3, nodeValue_Range(    "Chance",  [1,1], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan"); 
	// 5
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	newOutput(1, nodeValue_Output("On Destroy", VALUE_TYPE.trigger,  false )).setVisible(false);
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Destroy",   false ], 3, 4, 
	];
	
	////- Nodes
	
	destroyTrig = undefined;
	curve_strn  = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static reset = function() {
		curve_strn = new curveMap(getInputData(4));
	}
	
	static update = function(_frame = CURRENT_FRAME) { 
		var _data = inputs_data;
		
		var _parts = _data[0];
		var _masks = _data[1], use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _seed = _data[ 2];
		var _strn = _data[ 3], _strn_curved = inputs[3].attributes.curved && curve_strn != undefined;
		
		var _poolSize = _parts.poolSize;
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		destroyTrig  = buffer_verify(destroyTrig, 4 + _poolSize * global.pSystem_trig_length);
		var destroyCount = 0;
		buffer_seek(destroyTrig, buffer_seek_start, 4);
		
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
			
			var _strn_mod = _strn_curved? curve_strn.get(rat) : 1;
			var _strn_cur = random_range(_strn[0], _strn[1]) * _strn_mod;
			
			if(random(1) < _strn_cur * _mask) {
				var _dfg = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
				var _dx  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx), buffer_f64 );
				var _dy  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposy : PSYSTEM_OFF.posy), buffer_f64 );
				var _dz  = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposz : PSYSTEM_OFF.posz), buffer_f64 );
				
				var _vx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx, buffer_f64  );
				var _vy = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely, buffer_f64  );
				var _vz = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velz, buffer_f64  );
						
				buffer_write_at(_partBuff, _start + PSYSTEM_OFF.active, buffer_bool, false );
				
				buffer_write(destroyTrig, buffer_f64, _dx);
				buffer_write(destroyTrig, buffer_f64, _dy);
				buffer_write(destroyTrig, buffer_f64, _dz);
				
				buffer_write(destroyTrig, buffer_f64, _vx);
				buffer_write(destroyTrig, buffer_f64, _vy);
				buffer_write(destroyTrig, buffer_f64, _vz);
				destroyCount++;
			}
			
		}
		
		buffer_write_at(destroyTrig, 0, buffer_u32, destroyCount);
		
		outputs[0].setValue(_parts);
		outputs[1].setValue(destroyTrig);
	}
	
}