#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Sky", "Model > Toggle",      "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 3); });
		addHotkey("Node_Sky", "Coordinate > Toggle", "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 2); });
	});
#endregion

function Node_Sky(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Sky";
	
	newInput(0, nodeValue_Dimension());
	
	////- =Surface
	newInput(10, nodeValue_Surface( "Mask" ));
	
	////- =Transform
	newInput(1, nodeValue_Vec2( "Offset", [0,0] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(2, nodeValue_Vec2( "Scale",  [1,1] ));
	
	////- =Sky
	newInput(3, nodeValue_Enum_Scroll( "Model",     0, [ "Preetham", "Basic scattering", "Hosek" ]));
	newInput(4, nodeValue_Float(       "Turbidity", 2 ));
	newInput(8, nodeValue_Float(       "Albedo",    1 ));
	
	////- =Sun
	newInput(5, nodeValue_Vec2(        "Sun",          [.2,.2] )).setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(6, nodeValue_Float(       "Sun Radius",     500   ));
	newInput(7, nodeValue_Float(       "Sun Radiance",   20    ));
	newInput(9, nodeValue_Enum_Scroll( "Coordinate",     0, [ "Rectangular", "Polar" ] ));
	// input 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Surface",    true], 10, 
		// ["Transform", false], 1, 2, 
		["Sky",	      false], 3, 4, 8, 
		["Sun",       false], 5, 6, 7, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		
		var _mod    = _data[3];
		var _tur    = _data[4];
		var _sun    = _data[5];
		var _sunRad = _data[6];
		var _sunRdd = _data[7];
		var _alb    = _data[8];
		var _map    = _data[9];
		
		if(_mod == 0) {
		    inputs[4].setVisible( true);
		    inputs[6].setVisible(false);
		    inputs[7].setVisible(false);
		    inputs[8].setVisible(false);
		    
    		surface_set_shader(_outSurf, sh_sky_preetham);
    			DRAW_CLEAR
    			
    			shader_set_2("dimension",   _dim);
    			shader_set_2("position",    _pos);
    			shader_set_2("scale",       _sca);
    			shader_set_2("sunPosition", _sun);
    			shader_set_f("turbidity",   _tur);
    			shader_set_i("mapping",     _map);
    			
    			draw_empty();
    		surface_reset_shader();
    		
		} else if(_mod == 1) {
		    inputs[4].setVisible(false);
		    inputs[6].setVisible( true);
		    inputs[7].setVisible( true);
		    inputs[8].setVisible(false);
		    
    		surface_set_shader(_outSurf, sh_sky_scattering);
    			DRAW_CLEAR
    			
    			shader_set_2("dimension",   _dim);
    			shader_set_2("position",    _pos);
    			shader_set_2("scale",       _sca);
    			shader_set_2("sunPosition", _sun);
    			shader_set_f("sunRadius",   _sunRad);
    			shader_set_f("sunRadiance", _sunRdd);
    			shader_set_i("mapping",     _map);
    			
    			draw_empty();
    		surface_reset_shader();
    		
		} else if(_mod == 2) {
		    inputs[4].setVisible(false);
		    inputs[6].setVisible(false);
		    inputs[7].setVisible(false);
		    inputs[8].setVisible(false);
		    
    		surface_set_shader(_outSurf, sh_sky_hosek);
    			DRAW_CLEAR
    			
    			shader_set_2("dimension",   _dim);
    			shader_set_2("position",    _pos);
    			shader_set_2("scale",       _sca);
    			shader_set_2("sunPosition", _sun);
    			shader_set_f("turbidity",   3);
    			shader_set_f("albedo",      1);
    			shader_set_i("mapping",     _map);
    			
    			draw_empty();
    		surface_reset_shader();
		}
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}