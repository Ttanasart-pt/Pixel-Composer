#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_PB_Output", "Layer > Set",  KEY_GROUP.numeric, MOD_KEY.none, function(val) /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue(toNumber(chr(keyboard_key))); });
	});
#endregion

function Node_PB_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "PB Output";
	color = COLORS.node_blend_feedback;
	data  = noone;
	layr  = 0;
	blend = 0;
	drawA = true;
	
	setDimension(32, 32);
	
	junction_hover = noone;
	isHovering     = false;
	hover_scale    = 0;
	hover_scale_to = 0;
	hover_alpha    = 0;
	
	newInput(0, nodeValue_Surface("Surface", self));
	
	newInput(1, nodeValue_Float("Layer", self, 1));
	
	newInput(2, nodeValue_Enum_Button("Blend Mode", self, 0, [ "Normal", "Subtract" ]));
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
	
	input_display_list = [ 3, 0, 
		["Rendering", false], 1, 2 
	];
	
	static update = function() {
	    data  = inputs[0].getValue();
	    layr  = inputs[1].getValue();
	    blend = inputs[2].getValue();
	    drawA = inputs[3].getValue();
	    
	    rendered = true;
	    group.checkComplete();
	}
	
	////- Rendering
	
	static getNextNodes = function(checkLoop = false) {
		if(checkLoop) return;
		var _out = group.outputs[0];
		
		var nodes = [];
		for(var j = 0; j < array_length(_out.value_to); j++) {
			var _to = _out.value_to[j];
			
			if(!_to.node.isRenderActive())					continue;
			if(!_to.node.active || _to.value_from == noone) continue;
			if(_to.value_from.node != group)				continue;
			
			array_push(nodes, _to.node);
		}
		
		return nodes;
	}
	
	////- Draw
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	}
	
	static preDraw = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		inputs[0].x = xx;
		inputs[0].y = yy;
		
		inputs[1].x = xx;
		inputs[1].y = yy;
	}
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s, _panel = noone) {}
	
	static drawJunctions = function(_draw, _x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		isHovering = point_in_circle(_mx, _my, xx, yy, _s * 24);
		
		gpu_set_tex_filter(true);
		junction_hover = inputs[0].drawJunction(_draw, _s, _mx, _my);
		gpu_set_tex_filter(false);
		
		if(!isHovering) return noone;
		if(!junction_hover) draw_sprite_ui(THEME.view_pan, 0, _mx + ui(16), _my + ui(24), 1, 1, 0, COLORS._main_accent);
		
		hover_scale_to = 1;
		
		return junction_hover? inputs[0] : noone;
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {
		if(!_draw) return drawJunctions(_draw, _x, _y, _mx, _my, _s);
		
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		hover_alpha = 0.5;
		if(active_draw_index > -1) {
			hover_alpha		  =  1;
			hover_scale_to	  =  1;
			active_draw_index = -1;
		}
		
		#region draw arc
			shader_set(sh_node_arc);
				shader_set_color("color", inputs[0].color_display, hover_alpha);
				shader_set_f("angle", degtorad(90));
				
				var _r = _s * 20;
				shader_set_f("amount", 0.4, 0.5);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = _s * 30;
				shader_set_f("amount", 0.45, 0.525);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
				var _r = _s * 40;
				shader_set_f("amount", 0.475, 0.55);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				
			shader_reset();
		#endregion
			
		if(hover_scale > 0) {
			var _r = hover_scale * _s * 16;
			shader_set(sh_node_circle);
				shader_set_color("color", COLORS._main_accent, hover_alpha);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
			shader_reset();
		}
		
		hover_scale    = lerp_float(hover_scale, hover_scale_to && !junction_hover, 3);
		hover_scale_to = 0;
		
		draw_set_text(f_sdf, fa_center, fa_bottom, COLORS._main_text);
		draw_text_transformed(xx, yy - 12 * _s, string(layr), _s * .3, _s * .3, 0);
		
		return drawJunctions(_draw, _x, _y, _mx, _my, _s);
	}
	
	static getPreviewValues = function() /*=>*/ { return group == noone? data : group.outputs[0].getValue(); };
	
}