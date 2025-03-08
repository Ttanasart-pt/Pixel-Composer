function Node_VFX_Variable(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "VFX Variable";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	node_draw_icon     = s_node_vfx_variable;
	manual_ungroupable = false;
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Particle("Particles", self, -1 ))
		.setVisible(true, true);
	
	newOutput( 0, nodeValue_Output("Positions", self, VALUE_TYPE.float,   []    ));
	newOutput( 1, nodeValue_Output("Scales",    self, VALUE_TYPE.float,   []    ));
	newOutput( 2, nodeValue_Output("Rotations", self, VALUE_TYPE.float,   0     ));
	newOutput( 3, nodeValue_Output("Blending",  self, VALUE_TYPE.color,   0     ));
	newOutput( 4, nodeValue_Output("Alpha",     self, VALUE_TYPE.float,   0     ));
	newOutput( 5, nodeValue_Output("Life",      self, VALUE_TYPE.float,   0     ));
	newOutput( 6, nodeValue_Output("Max life",  self, VALUE_TYPE.float,   0     ));
	newOutput( 7, nodeValue_Output("Surface",   self, VALUE_TYPE.surface, noone ));
	newOutput( 8, nodeValue_Output("Velocity",  self, VALUE_TYPE.float,   []    ));
	newOutput( 9, nodeValue_Output("Seed",      self, VALUE_TYPE.float,   0     ));
	
	newOutput(10, nodeValue_Output("Spawn Positions", self, VALUE_TYPE.float,   []    ));
	
	input_display_list  = [ 0 ];
	output_display_list = [ 
		0, 10, 
		1, 2, 3, 4, 5, 6, 7, 8, 9
	];
	
	array_foreach(outputs, function(o) /*=>*/ {return o.setDisplay(VALUE_DISPLAY.none).setArrayDepth(1).setVisible(false)});
		
	static update = function(frame = CURRENT_FRAME) {
		parts = getInputData(0);
		if(!is_array(parts)) return;
		
		var _len   = array_length(parts);
		var _vouts = [];
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			_vouts[i] = array_verify(outputs[i].getValue(), _len); 
			outputs[i].setValue(_vouts[i]);
		}
		
		if(outputs[ 0].visible_manual) array_map_ext(_vouts[ 0], function(_,i) /*=>*/ {return [parts[i].x, parts[i].y]}           ); 
		if(outputs[ 1].visible_manual) array_map_ext(_vouts[ 1], function(_,i) /*=>*/ {return [parts[i].scx, parts[i].scy]}       ); 
		if(outputs[ 2].visible_manual) array_map_ext(_vouts[ 2], function(_,i) /*=>*/  {return parts[i].rot}                      ); 
		if(outputs[ 3].visible_manual) array_map_ext(_vouts[ 3], function(_,i) /*=>*/  {return parts[i].blend}                    ); 
		if(outputs[ 4].visible_manual) array_map_ext(_vouts[ 4], function(_,i) /*=>*/  {return parts[i].alp}                      ); 
		if(outputs[ 5].visible_manual) array_map_ext(_vouts[ 5], function(_,i) /*=>*/  {return parts[i].life}                     ); 
		if(outputs[ 6].visible_manual) array_map_ext(_vouts[ 6], function(_,i) /*=>*/  {return parts[i].life_total}               ); 
		if(outputs[ 7].visible_manual) array_map_ext(_vouts[ 7], function(_,i) /*=>*/  {return parts[i].surf}                     ); 
		if(outputs[ 8].visible_manual) array_map_ext(_vouts[ 8], function(_,i) /*=>*/ {return [parts[i].speedx, parts[i].speedy]} ); 
		if(outputs[ 9].visible_manual) array_map_ext(_vouts[ 9], function(_,i) /*=>*/  {return parts[i].seed}                     ); 
		if(outputs[10].visible_manual) array_map_ext(_vouts[10], function(_,i) /*=>*/ {return [parts[i].startx, parts[i].starty]} ); 
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(node_draw_icon, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	static getPreviewingNode = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewingNode() : self; }
	static getPreviewValues  = function() { return is(inline_context, Node_VFX_Group_Inline)? inline_context.getPreviewValues()  : self; }
}