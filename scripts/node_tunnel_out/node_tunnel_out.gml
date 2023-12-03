function Node_Tunnel_Out(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tunnel Out";
	color = COLORS.node_blend_tunnel;
	is_group_io = true;
	
	w = 96;
	
	inputs[| 0] = nodeValue("Name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" )
		.rejectArray();
	
	outputs[| 0] = nodeValue("Value out", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, noone );
	
	insp2UpdateTooltip = "Goto tunnel in";
	insp2UpdateIcon    = [ THEME.tunnel, 1, c_white ];
	
	static onInspector2Update = function() { #region
		var _key = getInputData(0);
		if(!ds_map_exists(TUNNELS_IN, _key)) return;
		
		var _node = TUNNELS_IN[? _key].node;
		graphFocusNode(_node);
	} #endregion
	
	static isRenderable = function() { #region
		var _key = getInputData(0);
		if(!ds_map_exists(TUNNELS_IN, _key)) return false;
		
		return TUNNELS_IN[? _key].node.rendered;
	} #endregion
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) { #region
		var xx = _x + x * _s;
		var yy = _y + y * _s;
		
		var hover = PANEL_GRAPH.pHOVER && point_in_rectangle(_mx, _my, xx, yy, xx + w * _s, yy + h * _s);
		var tun   = findPanel("Panel_Tunnels");
		hover |= tun && tun.tunnel_hover == self;
		if(!hover) return;
		
		var _key = getInputData(0);
		if(!ds_map_exists(TUNNELS_IN, _key)) return;
		
		var node = TUNNELS_IN[? _key].node;
		if(node.group != group) return;
		
		draw_set_color(COLORS.node_blend_tunnel);
		draw_set_alpha(0.35);
		var frx = _x + (node.x + node.w / 2) * _s;
		var fry = _y + (node.y + node.h / 2) * _s;
		var tox = xx + w * _s / 2;
		var toy = yy + h * _s / 2;
		draw_line_dashed(frx, fry, tox, toy, 8 * _s, 16 * _s, current_time / 10);
		draw_set_alpha(1);
	} #endregion
	
	static onValueUpdate = function(index = -1) { #region
		var _key = getInputData(0);
		
		TUNNELS_OUT[? node_id] = _key;
		
		if(index == 0) { RENDER_ALL_REORDER }
	} #endregion
	
	static step = function() { #region
		var _key = getInputData(0);
		if(ds_map_exists(TUNNELS_IN, _key)) {
			outputs[| 0].setType(TUNNELS_IN[? _key].type);
			outputs[| 0].display_type = TUNNELS_IN[? _key].display_type;
		} else {
			outputs[| 0].setType(VALUE_TYPE.any);
			outputs[| 0].display_type = VALUE_DISPLAY._default;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _key = getInputData(0);
		
		if(ds_map_exists(TUNNELS_IN, _key))
			outputs[| 0].setValue(TUNNELS_IN[? _key].getValue());
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str	= string(getInputData(0));
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
	
	static onClone = function() { onValueUpdate(0); }
	
	static postConnect = function() { onValueUpdate(0); }
}