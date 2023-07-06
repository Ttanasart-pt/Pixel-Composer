function Node_Strand_Gravity(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Strand Gravity";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	w = 96;
	
	inputs[| 0] = nodeValue("Strand", self, JUNCTION_CONNECT.input, VALUE_TYPE.strands, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Gravity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 2] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, -90)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	outputs[| 0] = nodeValue("Strand", self, JUNCTION_CONNECT.output, VALUE_TYPE.strands, noone);
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _str = inputs[| 0].getValue();
		var _gra = inputs[| 1].getValue();
		var _dir = inputs[| 2].getValue();
		
		if(_str == noone) return;
		var __str = _str;
		if(!is_array(_str)) __str = [ _str ];
		
		var gx = lengthdir_x(_gra, _dir);
		var gy = lengthdir_y(_gra, _dir);
		
		for( var k = 0; k < array_length(__str); k++ )
		for( var i = 0; i < array_length(__str[k].hairs); i++ ) {
			var h = __str[k].hairs[i];
			
			for( var j = 1; j < array_length(h.points); j++ ) {
				h.points[j].x += gx;
				h.points[j].y += gy;
			}
		}
		
		outputs[| 0].setValue(_str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strandSim_gravity, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}