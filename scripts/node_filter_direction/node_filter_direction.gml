function Node_Filter_Direction(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Filter Direction";
	shader = sh_filter_direction;
	
	var i = shader_index;
	
	////- =Direction
	newInput(i+0, nodeValue_Rot(   "Direction", 90 )).setShaderProp("direction").setHotkey("R").setPieMenu();
	newInput(i+1, nodeValue_Float( "Range",      0 )).setShaderProp("sweep").setPieMenu();
	
	////- =Range
	newInput(i+2, nodeValue_Float( "Distance",   4 )).setUnitSimple(false).setShaderProp("radius").setHotkey("S").setPieMenu();
	
	////- =Rendering
	newInput(i+3, nodeValue_Bool(  "Shaded",      true         )).setShaderProp("shade").setPieMenu();
	newInput(i+5, nodeValue_Curve( "Curve",       CURVE_DEF_01 )).setShaderProp("shadeMap");
	newInput(i+6, nodeValue_Bool(  "Inverted",    false        )).setShaderProp("inverted");
	newInput(i+4, nodeValue_Bool(  "Transparent", false        )).setShaderProp("transparent");
	// i+7
	
	array_append(input_display_list, [ 
		[ "Direction", false ], i+0, i+1, 
		[ "Range",     false ], i+2, 
		[ "Rendering", false ], i+3, i+5, i+6, i+4, 
	]);
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		var i   = shader_index;
		var dis = getInputData(i+2);
		
		draw_set_color(COLORS._main_accent);
		draw_line_dashed(_cx, _cy, _cx + dis * _s, _cy);
		
		drawOverlayInput(inputs[i+0].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		drawOverlayInput(inputs[i+2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static onProcessData = function(_outSurf, _data, _array_index) {
		#region data
			var i = shader_index;
			var _shade = _data[i+3];
			
			inputs[i+5].setVisible(_shade);
		#endregion
	}
	
}