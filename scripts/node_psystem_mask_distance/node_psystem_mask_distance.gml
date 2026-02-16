function Node_pSystem_Mask_Distance(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Mask Distance";
	icon  = THEME.vfx;
	color = COLORS.node_blend_vfx;
	setDrawIcon(s_node_psystem_mask_distance);
	
	setDimension(96, 0);
	update_on_frame = true;
	
	////- =Particles
	newInput( 0, nodeValue_Particle( "Particles" ));
	newInput( 1, nodeValue_Buffer(   "Mask"      ));
	
	////- =Distance
	newInput( 2, nodeValue_Vec2( "Target", [0,0] )).setUnitSimple();
	
	////- =Remap
	newInput( 3, nodeValue_Range( "Distance Range", [0,1]        )).setUnitSimple(); 
	newInput( 4, nodeValue_Curve( "Remap Curve",    CURVE_DEF_01 )); 
	// 5
	
	newOutput(0, nodeValue_Output( "Particles", VALUE_TYPE.particle, noone ));
	newOutput(1, nodeValue_Output( "Mask",      VALUE_TYPE.buffer,   noone ));
	
	input_display_list = [ 
		[ "Particles", false ], 0, 
		[ "Distance",  false ], 2, 
		[ "Remap",     false ], 3, 4, 
	];
	
	////- Nodes
	
	mask_buffer  = undefined;
	curve_modi   = undefined;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _pos   = getInputData(2);
		var _dists = getInputData(3);
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
		var d0 = _dists[0] * _s;
		var d1 = _dists[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_circle(px, py, d0, 1);
		draw_circle_dash(px, py, d1);
		
		var _parts = getInputData(0);
		if(!is(_parts, pSystem_Particles)) return;
		_parts.drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _params);
	}
	
	static getDimension = function() { return is(inline_context, Node_pSystem_Inline)? inline_context.dimension : DEF_SURF; }
	
	static update = function(_frame = CURRENT_FRAME) {
		#region data
			var _parts = getInputData(0);
			var _masks = getInputData(1);
			
			var _targ = getInputData( 2);
			
			var _mapf = getInputData( 3);
			var _curv = getInputData( 4); 
			
			curve_modi = new curveMap(getInputData(4));
			
			if(!is(_parts, pSystem_Particles)) return;
		#endregion
		
		var _pools = _parts.poolSize;
		mask_buffer = buffer_verify(mask_buffer, _pools * 4);
		buffer_to_start(mask_buffer);
		
		outputs[0].setValue(_parts);
		outputs[1].setValue(mask_buffer);
		
		var _partAmo  = _parts.maxCursor;
		var _partBuff = _parts.buffer;
		var _off      = 0;
		
		var tx = _targ[0];
		var ty = _targ[1];
		
		repeat(_partAmo) {
			var _start = _off;
			buffer_seek(_partBuff, buffer_seek_start, _start);
			_off += global.pSystem_data_length;
			
			var _act    = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.active, buffer_bool );
			var _spwnId = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.sindex, buffer_u32  );
			if(!_act) { buffer_write(mask_buffer, buffer_f32, 0); continue; }
			
			var _px  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posx,   buffer_f64  );
			var _py  = buffer_read_at( _partBuff, _start + PSYSTEM_OFF.posy,   buffer_f64  );
			
			var _val = point_distance(_px, _py, tx, ty);
			var _inf = clamp(lerp_invert(_val, _mapf[0], _mapf[1]), 0, 1);
			    _inf = curve_modi.get(_inf);
			
			buffer_write(mask_buffer, buffer_f32, _inf);
		}
		
	}
	
}