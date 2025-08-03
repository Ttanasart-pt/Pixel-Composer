function Node_Strand_Collision(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Collision";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Strand", self, CONNECT_TYPE.input, VALUE_TYPE.strands, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue("Collision mesh", self, CONNECT_TYPE.input, VALUE_TYPE.mesh, noone))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Strand", VALUE_TYPE.strands, noone));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _msh = getInputData(1);
		if(_msh == noone) return;
		
		draw_set_color(COLORS._main_accent);
		_msh.draw(_x, _y, _s);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _str = getInputData(0);
		var _msh = getInputData(1);
		
		if(_str == noone) return;
		var __str = _str;
		
		if(!is_array(_str)) __str = [ _str ];
		if(!is(_msh, Mesh)) return;
		
		for( var k = 0; k < array_length(__str); k++ ) 
		for( var i = 0, n = array_length(__str[k].hairs); i < n; i++ ) {
			var h = __str[k].hairs[i];
			
			for( var j = 1; j < array_length(h.points); j++ ) {
				var p = h.points[j];
				
				if(_msh.pointIn(p.x, p.y)) {
					p.x = p.px;
					p.y = p.py;
				}
			}
		}
		
		outputs[0].setValue(_str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strand_collision, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}