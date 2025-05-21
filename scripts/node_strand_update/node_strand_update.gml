function Node_Strand_Update(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Update";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue("Strand", self, CONNECT_TYPE.input, VALUE_TYPE.strands, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Step", 4))
	
	newOutput(0, nodeValue_Output("Strand", VALUE_TYPE.strands, noone));
	
	static update = function(frame = CURRENT_FRAME) {
		var _str = getInputData(0);
		var _itr = getInputData(1);
		
		if(_str == noone) return;
		var __str = _str;
		if(!is_array(_str)) __str = [ _str ];
		
		for( var i = 0, n = array_length(__str); i < n; i++ ) 
			__str[i].step(_itr);
		outputs[0].setValue(_str);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strand_update, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}