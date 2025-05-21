function Node_Strand_Gravity(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Gravity";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Strand", self, CONNECT_TYPE.input, VALUE_TYPE.strands, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Gravity", 1));
	
	newInput(2, nodeValue_Rotation("Direction", 0));
	
	newOutput(0, nodeValue_Output("Strand", VALUE_TYPE.strands, noone));
	
	static update = function(frame = CURRENT_FRAME) {
		var _str = getInputData(0);
		var _gra = getInputData(1);
		var _dir = getInputData(2);
		
		if(_str == noone) return;
		var __str = _str;
		if(!is_array(_str)) __str = [ _str ];
		
		var gx = lengthdir_x(_gra, _dir);
		var gy = lengthdir_y(_gra, _dir);
		
		for( var k = 0; k < array_length(__str); k++ )
		for( var i = 0, n = array_length(__str[k].hairs); i < n; i++ ) {
			var h = __str[k].hairs[i];
			
			for( var j = 1; j < array_length(h.points); j++ ) {
				h.points[j].x += gx;
				h.points[j].y += gy;
			}
		}
		
		outputs[0].setValue(_str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strand_gravity, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}