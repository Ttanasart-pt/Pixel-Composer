function Node_pSystem_Render_Point(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Render Point";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	parameters.inline_draw_output = true;
	setDrawIcon(s_node_psystem_render_point);
	setDimension(96, 0);
	
	update_on_frame = true;
	
	////- =Particles
	newInput(0, nodeValue_Particle( "Particles" ));
	newInput(1, nodeValue_Buffer(   "Mask"      ));
	// 
	
	newOutput(0, nodeValue_Output( "Points", VALUE_TYPE.float, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		[ "Particles", false ], 0, 1, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		
		_parts.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		var _dim   = getDimension();
		var _parts = getInputData(0);
		var _masks = getInputData(1), use_mask = _masks != noone;
		
		if(!is(_parts, pSystem_Particles)) return;
		if(use_mask) buffer_to_start(_masks);
		
		var _poolSize = _parts.poolSize;
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off = 0;
		
		var _points = [];
		outputs[0].setValue(_points);
	
		repeat(_partAmo) {
			var _start = _off;
			_off += global.pSystem_data_length;
			
			var _mask   = use_mask? buffer_read(_masks, buffer_f32) : 1; if(_mask <= 0) continue;
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			var _lif    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.life,   buffer_f64  );
			if(!_act) continue;
			
			var _draw_x  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,  buffer_f64  );
			var _draw_y  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,  buffer_f64  );
			// var _draw_sx = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.scax,  buffer_f64  );
			
			array_push(_points, [_draw_x, _draw_y]);
		}
	}
	
}