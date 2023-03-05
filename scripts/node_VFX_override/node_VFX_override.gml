function Node_VFX_Override(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "VFX Override";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	previewable = false;
	node_draw_icon = s_node_vfx_override;
	
	w = 96;
	h = 80;
	min_h = h;
	
	inputs[| 0] = nodeValue("Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.particle, -1 )
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Positions", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Rotations", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Scales", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	inputs[| 4] = nodeValue("Blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 5] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 );
	
	outputs[| 0] = nodeValue("Particles", self, JUNCTION_CONNECT.output, VALUE_TYPE.particle, -1 );
	
	static update = function(frame = ANIMATOR.current_frame) {
		var parts = inputs[| 0].getValue();
		if(!is_array(parts)) return;
		
		var _pos = inputs[| 1].getValue();
		var _sca = inputs[| 2].getValue();
		var _rot = inputs[| 3].getValue();
		var _col = inputs[| 4].getValue();
		var _alp = inputs[| 5].getValue();
		
		for( var i = 0; i < array_length(parts); i++ ) {
			var part = parts[i];
			
			if(is_array(_pos) && array_length(_pos) > i && is_array(_pos[i])) {
				part.x = _pos[i][0];
				part.y = _pos[i][1];
			}
			
			if(is_array(_sca) && array_length(_sca) > i && is_array(_sca[i])) {
				part.scx = _sca[i][0];
				part.scy = _sca[i][1];
			}
			
			if(is_array(_rot) && array_length(_rot) > i )
				part.rot = array_safe_get(_rot, i);
			
			if(is_array(_col) && array_length(_col) > i )
				part.blend = array_safe_get(_col, i);
			
			if(is_array(_alp) && array_length(_alp) > i )
				part.alp = array_safe_get(_alp, i);
		}
		
		outputs[| 0].setValue(parts);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}