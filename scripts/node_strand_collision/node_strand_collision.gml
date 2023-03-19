function Node_Strand_Collision(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Strand Collision";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	w = 96;
	
	inputs[| 0] = nodeValue("Strand", self, JUNCTION_CONNECT.input, VALUE_TYPE.strands, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Collision mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.mesh, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Strand", self, JUNCTION_CONNECT.output, VALUE_TYPE.strands, noone);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _msh = inputs[| 1].getValue();
		if(_msh == noone) return;
		
		draw_set_color(COLORS._main_accent);
		_msh.draw(_x, _y, _s);
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _str = inputs[| 0].getValue();
		var _msh = inputs[| 1].getValue();
		
		if(_str == noone) return;
		var __str = _str;
		if(!is_array(_str)) __str = [ _str ];
		
		if(instanceof(_msh) != "Mesh") return;
		
		for( var k = 0; k < array_length(__str); k++ ) 
		for( var i = 0; i < array_length(__str[k].hairs); i++ ) {
			var h = __str[k].hairs[i];
			
			for( var j = 1; j < array_length(h.points); j++ ) {
				var p = h.points[j];
				
				if(_msh.pointIn(p.x, p.y)) {
					p.x = p.px;
					p.y = p.py;
				}
			}
		}
		
		outputs[| 0].setValue(_str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strandSim_collide, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}