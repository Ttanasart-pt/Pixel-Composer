function Node_Straighten(_x, _y, _group = noone) : Node_Shader_Processor(_x, _y, _group) constructor {
	name   = "Straighten";
	shader = sh_straighten;
	
	var i = shader_index;
	
	////- =Straighten
	newInput(i+ 0, nodeValue_EScroll( "Mode", 0, [ "2D", "Perspective" ] )).setShaderProp("mode");
	
	newInput(i+ 1, nodeValue_Vec2( "Point Start", [0,.5] )).setUnitSimple().setShaderProp("points1");
	newInput(i+ 2, nodeValue_Vec2( "Point End",   [1,.5] )).setUnitSimple().setShaderProp("points2");
	
	newInput(i+ 3, nodeValue_Vec2( "Guide 1 Point Start", [0,0] )).setUnitSimple().setShaderProp("persPoints1");
	newInput(i+ 4, nodeValue_Vec2( "Guide 1 Point End",   [1,0] )).setUnitSimple().setShaderProp("persPoints2");
	newInput(i+ 5, nodeValue_Vec2( "Guide 2 Point Start", [0,1] )).setUnitSimple().setShaderProp("persPoints3");
	newInput(i+ 6, nodeValue_Vec2( "Guide 2 Point End",   [1,1] )).setUnitSimple().setShaderProp("persPoints4");
	
	array_append(input_display_list, [ 
		[ "Straighten", false ], i+0, i+1, i+2, i+3, i+4, i+5, i+6, 
	]);
	
	////- Node
	
	attribute_interpolation(false, true);
	attribute_oversample();
	
	tools = [ new NodeTool( "Preview Original", THEME.tools_image ) ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var i = shader_index;
		var _mode = getInputData(i+ 0);
		
		switch(_mode) {
			case 0:
				var p1 = getInputData(i+ 1);
				var p2 = getInputData(i+ 2);
				
				var p1x = _x + p1[0] * _s;
				var p1y = _y + p1[1] * _s;
				
				var p2x = _x + p2[0] * _s;
				var p2y = _y + p2[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(p1x, p1y, p2x, p2y);
				
				drawOverlayInput(inputs[i+ 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				drawOverlayInput(inputs[i+ 2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				break;
			
			case 1:
				var p3 = getInputData(i+ 3);
				var p4 = getInputData(i+ 4);
				var p5 = getInputData(i+ 5);
				var p6 = getInputData(i+ 6);
				
				var p3x = _x + p3[0] * _s;
				var p3y = _y + p3[1] * _s;
				
				var p4x = _x + p4[0] * _s;
				var p4y = _y + p4[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(p3x, p3y, p4x, p4y);
				
				var p5x = _x + p5[0] * _s;
				var p5y = _y + p5[1] * _s;
				
				var p6x = _x + p6[0] * _s;
				var p6y = _y + p6[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(p5x, p5y, p6x, p6y);
				
				drawOverlayInput(inputs[i+ 3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				drawOverlayInput(inputs[i+ 4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				drawOverlayInput(inputs[i+ 5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				drawOverlayInput(inputs[i+ 6].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
				break;
		}
		
	}
	
	static onProcessData = function(_outSurf, _data, _array_index) {
		var i = shader_index;
		var _mode = _data[i +  0];
		
		inputs[i+ 1].setVisible(_mode == 0);
		inputs[i+ 2].setVisible(_mode == 0);
		
		inputs[i+ 3].setVisible(_mode == 1);
		inputs[i+ 4].setVisible(_mode == 1);
		inputs[i+ 5].setVisible(_mode == 1);
		inputs[i+ 6].setVisible(_mode == 1);
	}
	
	static getPreviewValues = function() { return isUsingTool("Preview Original")? inputs[0].getValue() : outputs[0].getValue(); }
	
}