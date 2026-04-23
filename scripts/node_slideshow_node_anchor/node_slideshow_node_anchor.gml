function Node_Slideshow_Node_Anchor(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Slideshow Node";
	color = COLORS._main_accent;
	
	is_controller = true;
	slide_obj = undefined;
	node_obj  = undefined;
	
	node_init_x = 0;
	node_init_y = 0;
	
	////- =Anchor
	newInput( 0, nodeValue_Text( "Slide ID" ));
	newInput( 1, nodeValue_Text( "Node ID"  ));
	
	input_display_list = [ 
		[ "Anchor", false ], 0, 1, 
	];
	
	////- Node
	
	static step = function() {
		var slide_id = inputs[0].getValue();
		slide_obj = project.getNodeFromID(slide_id);
		
		if(!is(slide_obj, Node_Slideshow)) return;
		slide_obj.anchors[$ node_id] = self;
	}
	
	////- Slideshow
	
	static slideInit = function() {
		var _node_id = inputs[1].getValue();
		node_obj = project.getNodeFromID(_node_id);
		if(!is(node_obj, Node)) return;
		
		node_init_x = node_obj.x;
		node_init_y = node_obj.y;
		
		w = node_obj.w;
		h = node_obj.h;
	}
	
	static slideStep = function(_t = 0) {
		if(!is(node_obj, Node)) return;
		
		node_obj.x = lerp(node_init_x, x, _t);
		node_obj.y = lerp(node_init_y, y, _t);
	}
	
	////- Draw
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s, _panel = noone) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		var ww = w * _s;
		var hh = h * _s;
		
		// var hov = point_in_rectangle(_mx, _my, xx, yy, xx + ww, yy + hh);
		var hov = point_in_circle(_mx, _my, xx, yy, 16 * _s);
		
		if(hov) draw_sprite_stretched_ext(bg_spr, 0, xx, yy, ww, hh, color, .2); 
		draw_sprite_stretched_ext(bg_spr, 1, xx, yy, ww, hh, color, 1); 
		draw_anchor_cross(0, xx, yy, 16 * _s, 1);
		return hov;
	}
	
	static drawNodeFG = function(_x, _y, _mx, _my, _s, _panel = noone) {
	}
}