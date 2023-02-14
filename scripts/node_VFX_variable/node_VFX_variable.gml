function Node_VFX_Variable(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "VFX Variable";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	previewable = false;
	node_draw_icon = s_node_vfx_variable;
	
	w = 96;
	h = 80;
	min_h = h;
	
	inputs[| 0] = nodeValue("Particles", self, JUNCTION_CONNECT.input, VALUE_TYPE.particle, -1 )
		.setVisible(true, true);
	
	input_display_list = [ 0 ];
	
	outputs[| 0] = nodeValue("Positions", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 1] = nodeValue("Scales", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 2] = nodeValue("Rotations", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 );
	
	outputs[| 3] = nodeValue("Blending", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, 0 );
	
	outputs[| 4] = nodeValue("Alpha", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 );
	
	outputs[| 5] = nodeValue("Life", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 );
	
	outputs[| 6] = nodeValue("Max life", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0 );
	
	static update = function(frame = ANIMATOR.current_frame) {
		var parts = inputs[| 0].getValue();
		if(!is_array(parts)) return;
		
		var _get = [];
		var _val = [];
		
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			_get[i] = false;
			var _in = outputs[| i];
			for( var j = 0; j < ds_list_size(_in.value_to); j++ )
				if(_in.value_to[| j].value_from == _in) _get[i] = true;
			
			_val[i] = [];
			if(_get[i]) _val[i] = array_create(array_length(parts));
		}
		
		for( var i = 0; i < array_length(parts); i++ ) {
			var part = parts[i];
			
			if(_get[0]) _val[0][i] = [part.x,   part.y];
			if(_get[1]) _val[1][i] = [part.scx, part.scy];
			if(_get[2]) _val[2][i] = part.rot;
			if(_get[3]) _val[3][i] = part.blend;
			if(_get[4]) _val[4][i] = part.alp;
			if(_get[5]) _val[5][i] = part.life;
			if(_get[6]) _val[6][i] = part.life_total;
		}
		
		for( var i = 0; i < ds_list_size(outputs); i++ )
			if(_get[i]) outputs[| i].setValue(_val[i]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}