function Node_pSystem_Trigger_Event(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Trigger";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_trigger_event);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	newInput( 2, nodeValueSeed());
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Event
	newInput( 3, nodeValue_Range( "Step Period", [1,1], true )).setCurvable( 4, CURVE_DEF_11, "Over Lifespan");
	newInput( 5, nodeValue_Range( "Chance",      [1,1], true )).setCurvable( 6, CURVE_DEF_11, "Over Lifespan"); 
	// 7
	
	newOutput(0, nodeValue_Output("On Event", VALUE_TYPE.trigger,  false ));
	
	input_display_list = [ 2, 
		[ "Particles", false ], 0, 1, 
		[ "Event",     false ], 3, 4, 5, 6, 
	];
	
	////- Nodes
	
	stepTrig   = undefined; stepCount = 0;
	curve_step = undefined;
	curve_chan = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : PROJ_SURF; }
	
	static update = function(_frame = CURRENT_FRAME) {
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		outputs[0].setValue(_parts);
		
		var _seed = getInputData( 2);
		var _step = getInputData( 3), _step_curved = inputs[3].attributes.curved && curve_step != undefined;
		var _chan = getInputData( 5), _chan_curved = inputs[5].attributes.curved && curve_chan != undefined;
		
		var _poolSize = _parts.poolSize;
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		stepTrig  = buffer_verify(stepTrig, 4 + _poolSize * global.pSystem_trig_length);
		stepCount = 0;
		buffer_seek(stepTrig, buffer_seek_start, 4);
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _stat   = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.stat,   buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) continue;
				
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			var _lifMax = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.mlife,  buffer_f64  );
					
			var rat = _stat? (_frame + _lif + _spwnId * _lifMax) / TOTAL_FRAMES : _lif / (_lifMax - 1);
			    rat = clamp(rat, 0, 1);
			random_set_seed(_seed + _spwnId);
			
			var _step_mod = _step_curved? curve_step.get(rat) : 1;
			var _step_cur = round(random_range(_step[0], _step[1]) * _step_mod);
			
			var _chan_mod = _chan_curved? curve_chan.get(rat) : 1;
			var _chan_cur = random_range(_chan[0], _chan[1]) * _chan_mod * _mask;
			
			if((_step_cur == 0 || _lif % _step_cur == 0) && random(1) <= _chan_cur) {
				var _dfg      = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.dflag,  buffer_u16  );
				var _draw_x   = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposx : PSYSTEM_OFF.posx), buffer_f64 );
				var _draw_y   = buffer_read_at( _partBuff, _start + (bool(_dfg & 0b100)? PSYSTEM_OFF.dposy : PSYSTEM_OFF.posy), buffer_f64 );
				
				var _vx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.velx, buffer_f64  );
				var _vy = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.vely, buffer_f64  );
						
				buffer_write(stepTrig, buffer_f64, _draw_x);
				buffer_write(stepTrig, buffer_f64, _draw_y);
				buffer_write(stepTrig, buffer_f64,       0);
				
				buffer_write(stepTrig, buffer_f64, _vx);
				buffer_write(stepTrig, buffer_f64, _vy);
				buffer_write(stepTrig, buffer_f64,   0);
				stepCount++;
			}
		}
		
		buffer_write_at(stepTrig, 0, buffer_u32, stepCount);
		outputs[0].setValue(stepTrig);
	}
	
	static reset = function() {
		curve_step = new curveMap(getInputData(4));
		curve_chan = new curveMap(getInputData(6));
	}
}