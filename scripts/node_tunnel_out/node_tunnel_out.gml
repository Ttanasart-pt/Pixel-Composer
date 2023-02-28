function Node_Tunnel_Out(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Tunnel Out";
	previewable = false;
	color = COLORS.node_blend_tunnel;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
		.rejectArray();
	
	outputs[| 0] = nodeValue("Value out", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, noone );
	
	static isRenderable = function(trigger = false) { return false; }
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) {
		var xx = _x + x * _s;
		var yy = _y + y * _s;
		
		var hover = point_in_rectangle(_mx, _my, xx, yy, xx + w * _s, yy + h * _s);
		if(!hover) return;
		
		var _key = inputs[| 0].getValue();
		if(!ds_map_exists(TUNNELS_IN, _key)) return;
		
		var node = TUNNELS_IN[? _key].node;
		if(node.group != group) return;
		
		draw_set_color(COLORS.node_blend_tunnel);
		draw_set_alpha(0.35);
		draw_line_width(xx + w * _s / 2, yy + h * _s / 2, _x + (node.x + node.w / 2) * _s, _y + (node.y + node.h / 2) * _s, 6 * _s);
		draw_set_alpha(1);
	}
	
	static onClone = function() { onValueUpdate(); }
	
	static onValueUpdate = function() {
		var _key = inputs[| 0].getValue();
		
		TUNNELS_OUT[? node_id] = _key;
	}
	
	static step = function() {
		var _key = inputs[| 0].getValue();
		if(ds_map_exists(TUNNELS_IN, _key)) {
			outputs[| 0].type = TUNNELS_IN[? _key].type;
			outputs[| 0].display_type = TUNNELS_IN[? _key].display_type;
		} else {
			outputs[| 0].type = VALUE_TYPE.any;
			outputs[| 0].display_type = VALUE_DISPLAY._default;
		}
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _key = inputs[| 0].getValue();
		
		if(ds_map_exists(TUNNELS_IN, _key))
			outputs[| 0].setValue(TUNNELS_IN[? _key].getValue());
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str	= string(inputs[| 0].getValue());
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
	
	static postConnect = function() { onValueUpdate(); }
}