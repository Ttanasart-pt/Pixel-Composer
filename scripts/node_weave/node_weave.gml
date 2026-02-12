function Node_Weave(_x, _y, _group = noone) : Node_Shader_Generator(_x, _y, _group) constructor {
	name   = "Weave";
	shader = sh_weave;
	
	newInput(9, nodeValueSeed()).setShaderProp("seed");
	
	////- =Output
	newInput( 1, nodeValue_Surface( "UV Map"     ));
	newInput( 2, nodeValue_Slider(  "UV Mix", 1  ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	
	////- =Transform
	newInput( 4, nodeValue_Vec2(     "Position", [.5,.5]   )).setHotkey("G").setShaderProp("position").setUnitSimple();
	newInput( 6, nodeValue_Rotation( "Angle",    0         )).setShaderProp("rotation");
	newInput( 5, nodeValue_Vec2(     "Scale",    [.25,.25] )).setHotkey("S").setShaderProp("scale").setUnitSimple();
	
	////- =Weave
	newInput(18, nodeValue_EScroll( "Weave Pattern", 0, [ "Random", "Checker", "Map" ] )).setShaderProp("wtype");
	newInput(19, nodeValue_Surface( "Weave Map",           )).setShaderProp("wmap");
	newInput(10, nodeValue_Vec2(    "Width", [.5, .5], { linked: true } )).setShaderProp("wwidth");
	
	////- =Color
	newInput( 7, nodeValue_Color(    "BG Color",     ca_black )).setShaderProp("color1");
	newInput(14, nodeValue_EScroll(  "Color Type",   0, [ "Solid", "Axis", "Random" ] )).setShaderProp("colorType");
	newInput( 8, nodeValue_Color(    "Color",        ca_white )).setShaderProp("color2");
	newInput(15, nodeValue_Color(    "Color 2",      ca_white )).setShaderProp("color3");
	newInput(16, nodeValue_Gradient( "Random Color", gra_black_white )).setShaderProp("gradient");
	
	////- =Shading
	newInput(17, nodeValue_Color(  "Shade Color", ca_black )).setShaderProp("shadeColor");
	newInput(13, nodeValue_Slider( "Shade Span",  .5     )).setShaderProp("shadeSpan");
	newInput(11, nodeValue_Slider( "Shading",     .5     )).setShaderProp("shading").setCurvable(12, CURVE_DEF_01);
	// 20
	
	input_display_list = [ 9, 
		[ "Output",     true ],  0,  1,  2,  3, 
		[ "Transform", false ],  4,  6,  5, 
		[ "Weave",     false ], 18, 19, 10, 
		[ "Color",     false ],  7, 14,  8, 15, 16, 
		[ "Shading",   false ], 17, 13, 11, 12, 
	];
	
	////- Node
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _pos = inputs[4].getValue();
	    var _px  = _x + _pos[0] * _s;
	    var _py  = _y + _pos[1] * _s;
	    
	    InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
	    
	    return w_hovering;
	}
	
	static onProcessData = function(_outSurf, _data, _array_index) {
		#region data
			var _wType = _data[18];
			
			var _cType = _data[14];
			
			inputs[19].setVisible(_wType == 2);
			
			inputs[15].setVisible(_cType == 1);
			inputs[16].setVisible(_cType == 2);
		#endregion
	}
	
}