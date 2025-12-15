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
	newInput(11, nodeValue_Surface( "UV Map"     ));
	newInput(12, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(10, nodeValue_Surface( "Mask"       ));
	
	////- =Transform
	newInput(1, nodeValue_Vec2( "Offset", [0,0] )).setUnitSimple();
	newInput(2, nodeValue_Vec2( "Scale",  [1,1] ));
	
	////- =Sky
	newInput(3, nodeValue_EScroll( "Model",     0, [ "Preetham", "Basic scattering", "Hosek" ]));
	newInput(4, nodeValue_Float(   "Turbidity", 2 )).setMappable(13);
	newInput(8, nodeValue_Float(   "Albedo",    1 ));
	
	////- =Sun
	newInput(5, nodeValue_Vec2(    "Sun",          [.2,.2] )).setHotkey("G").setUnitSimple();
	newInput(6, nodeValue_Float(   "Sun Radius",     500   ));
	newInput(7, nodeValue_Float(   "Sun Radiance",   20    )).setMappable(14);
	newInput(9, nodeValue_EScroll( "Coordinate",     0, [ "Rectangular", "Polar" ] ));
	// input 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Surface", true ], 11, 12, 10, 
		[ "Sky",    false ],  3,  4, 13,  8, 
		[ "Sun",    false ],  5,  6,  7, 14, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim    = _data[0];
			var _pos    = _data[1];
			var _sca    = _data[2];
			
			var _mod    = _data[3];
			var _tur    = _data[4];
			var _sun    = _data[5];
			var _sunRad = _data[6];
			var _sunRdd = _data[7];
			var _alb    = _data[8];
			var _map    = _data[9];
		#endregion
		
		if(_mod == 0) {
		    inputs[4].setVisible( true);
		    inputs[6].setVisible(false);
		    inputs[7].setVisible(false);
		    inputs[8].setVisible(false);
		    
    		surface_set_shader(_outSurf, sh_sky_preetham);
	    		shader_set_uv(_data[11], _data[12]);
    			shader_set_i( "mapping",       _map );
    			shader_set_2( "dimension",     _dim );
    			shader_set_2( "position",      _pos );
    			shader_set_2( "scale",         _sca );
    			shader_set_2( "sunPosition",   _sun );
    			shader_set_f_map( "turbidity", _tur, _data[13], inputs[4] );
    			
    			draw_empty();
    		surface_reset_shader();
    		
		} else if(_mod == 1) {
		    inputs[4].setVisible(false);
		    inputs[6].setVisible( true);
		    inputs[7].setVisible( true);
		    inputs[8].setVisible(false);
		    
    		surface_set_shader(_outSurf, sh_sky_scattering);
	    		shader_set_uv(_data[11], _data[12]);
    			shader_set_i( "mapping",     _map    );
    			shader_set_2( "dimension",   _dim    );
    			shader_set_2( "position",    _pos    );
    			shader_set_2( "scale",       _sca    );
    			shader_set_2( "sunPosition", _sun    );
    			shader_set_f( "sunRadius",   _sunRad );
    			shader_set_f_map( "sunRadiance", _sunRdd, _data[14], inputs[7] );
    			
    			draw_empty();
    		surface_reset_shader();
    		
		} else if(_mod == 2) {
		    inputs[4].setVisible( true);
		    inputs[6].setVisible(false);
		    inputs[7].setVisible(false);
		    inputs[8].setVisible(false);
		    
    		surface_set_shader(_outSurf, sh_sky_hosek);
	    		shader_set_uv(_data[11], _data[12]);
    			shader_set_i( "mapping",       _map );
    			shader_set_2( "dimension",     _dim );
    			shader_set_2( "position",      _pos );
    			shader_set_2( "scale",         _sca );
    			shader_set_2( "sunPosition",   _sun );
    			shader_set_f_map( "turbidity", _tur, _data[13], inputs[4] );
    			shader_set_f( "albedo", 1 );
    			
    			draw_empty();
    		surface_reset_shader();
		}
		
		_outSurf = mask_apply_empty(_outSurf, _data[input_mask_index]);
		return _outSurf;
	}
}