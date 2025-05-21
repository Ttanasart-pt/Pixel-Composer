function Node_PB_Draw_Triangle(_x, _y, _group = noone) : Node_PB_Draw(_x, _y, _group) constructor {
	name = "Triangle";
	
	newInput(pbi+0, nodeValue_Enum_Button("Base", 0, array_create(4, s_node_pb_draw_tri_base)));
	
	newInput(pbi+1, nodeValue_Slider("Apex Ratio", 0.5));
	
	newInput(pbi+2, nodeValue_Enum_Button("Mode", 0, array_create(2, s_node_pb_draw_tri_apex)));
	
	newInput(pbi+3, nodeValue_Enum_Button("Apex Corner", 0, array_create(4, s_node_pb_draw_tri_apexc)));
	
	array_insert_array(input_display_list, input_display_shape_index, [
		["Shape", false], pbi+2, pbi+0, pbi+3, pbi+1, 
	]);
	
	resetDynamicInput();
	
	static pbDrawSurface = function(_data, _bbox) {
		var _x0 = _bbox[0] - 1;
		var _y0 = _bbox[1] - 1;
		var _x1 = _bbox[2] - 1;
		var _y1 = _bbox[3] - 1;
		
		var _mode = _data[pbi+2];
		var _base = _data[pbi+0];
		var _apex = _data[pbi+1];
		var _apxc = _data[pbi+3];
		
		inputs[pbi+0].setVisible(_mode == 0);
		inputs[pbi+3].setVisible(_mode == 1);
		
		var _b0x = _x0, _b0y = _y0;
		var _b1x = _x1, _b1y = _y1;
		var _cx  = _x0, _cy  = _y0;
		
		if(_mode == 0) {
    		switch(_base) {
    		    case 0 :
    		        _b0x = _x0; _b0y = _y1;
                    _b1x = _x1; _b1y = _y1;
                    
                    _cx = lerp(_x0, _x1, _apex);
                    _cy = _y0;
                    break;
                    
                case 1 :
    		        _b0x = _x0; _b0y = _y0;
                    _b1x = _x0; _b1y = _y1;
                    
                    _cx = _x1;
                    _cy = lerp(_y0, _y1, _apex);
                    break;
                    
                case 2 :
    		        _b0x = _x0; _b0y = _y0;
                    _b1x = _x1; _b1y = _y0;
                    
                    _cx = lerp(_x0, _x1, _apex);
                    _cy = _y1;
                    break;
                    
                case 3 :
    		        _b0x = _x1; _b0y = _y0;
                    _b1x = _x1; _b1y = _y1;
                    
                    _cx = _x0;
                    _cy = lerp(_y0, _y1, _apex);
                    break;
                    
    		}
    		
		} else if(_mode == 1) {
    		switch(_apxc) {
    		    case 0 :
    		        _b0x = _x1; 
    		        _b0y = lerp(_y1, _y0, _apex);
                    _b1x = lerp(_x1, _x0, _apex);
                    _b1y = _y1;
                    
                    _cx = _x0;
                    _cy = _y0;
                    break;
                    
                case 1 :
    		        _b0x = _x0; 
    		        _b0y = lerp(_y1, _y0, _apex);
                    _b1x = lerp(_x0, _x1, _apex);
                    _b1y = _y1;
                    
                    _cx = _x1;
                    _cy = _y0;
                    break;
                    
                case 2 :
    		        _b0x = _x0; 
    		        _b0y = lerp(_y0, _y1, _apex);
                    _b1x = lerp(_x0, _x1, _apex);
                    _b1y = _y0;
                    
                    _cx = _x1;
                    _cy = _y1;
                    break;
                    
                case 3 :
    		        _b0x = _x1; 
    		        _b0y = lerp(_y0, _y1, _apex);
                    _b1x = lerp(_x1, _x0, _apex);
                    _b1y = _y0;
                    
                    _cx = _x0;
                    _cy = _y1;
                    break;
                    
    		}
		}
		
		draw_triangle(_b0x, _b0y, _b1x, _b1y, _cx, _cy, false);
	}
}