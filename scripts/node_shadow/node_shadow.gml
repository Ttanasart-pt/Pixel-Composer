#region create
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Shadow", "Grow",     "G", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[4].setValue(KEYBOARD_NUMBER); });
		addHotkey("Node_Shadow", "Sharpen",  "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS        _n.inputs[5].setValue(0);               });
	});
#endregion

function Node_Shadow(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shadow";
	
	newActiveInput(8);
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 6, nodeValue_Surface( "Mask"       ));
	newInput( 7, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(6, 9); // inputs 9, 10
	
	////- =Shadow
	newInput( 1, nodeValue_Color(       "Color",           ca_black ));
	newInput( 2, nodeValue_Slider(      "Strength",       .5, [ 0, 2, 0.01] )).setCurvable(13).setHotkey("S").hideLabel();
	newInput(11, nodeValue_Enum_Button( "Positioning",     0, [ "Shift", "Light" ] ));
	newInput( 3, nodeValue_Vec2(        "Shift",          [4,4] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}).hideLabel();
	newInput(12, nodeValue_Vec2(        "Light Position", [0,0] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}).hideLabel();
	newInput( 4, nodeValue_ISlider(     "Grow", 3, [0, 16, 0.1] ));
	newInput( 5, nodeValue_ISlider(     "Blur", 3, [0, 16, 0.1] ));
	// input 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 8, 
		["Surfaces", true],  0,  6,  7,  9, 10, 
		["Shadow",	false],  1,  2, 13, 11,  3, 12,  4,  5, 
	];
	
	surface_blur_init();
	attribute_surface_depth();
		
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _dim = getDimension();
		var ww   = _s * _dim[0];
		var hh   = _s * _dim[1];
		var cx   = _x + ww / 2;
		var cy   = _y + ww / 2;
		
		var _typ = getSingleValue(11);
		
		if(_typ == 0) {
			var shf = getSingleValue(3);
			var sx  = cx + shf[0] * _s;
			var sy  = cy + shf[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_line_dashed(cx, cy, sx, sy);
			
	 		InputDrawOverlay(inputs[ 3].drawOverlay(w_hoverable, active, cx, cy, _s, _mx, _my, _snx, _sny, 1));
	 		
		} else if(_typ == 1) {
			var shf = getSingleValue(12);
			var sx  = _x + shf[0] * _s;
			var sy  = _y + shf[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_line_dashed(cx, cy, sx, sy);
			
			InputDrawOverlay(inputs[12].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 1));
		}
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s * _dim[0], _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf   = _data[0];
			var cl      = _data[1];
			var _stre   = _data[2];
			var _border = _data[4];
			var _size   = _data[5];
			
			var _posi   = _data[11];
			var _shf    = _data[ 3];
			var _lgh    = _data[12];
			var _dim    = surface_get_dimension(_surf);
		#endregion
			
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], attrDepth());	
		var _shax = _shf[0]; 
		var _shay = _shf[1];
		
		if(_posi == 1) {
			_shax = _dim[0] / 2 - _lgh[0];
			_shay = _dim[1] / 2 - _lgh[1];
		}
		
		inputs[ 3].setVisible(_posi == 0);
		inputs[12].setVisible(_posi == 1);
		
		surface_set_shader(temp_surface[0], sh_outline_only);
			shader_set_f("dimension",   _dim);
			shader_set_f("borderSize",  _border);
			shader_set_f("borderColor", [ 1., 1., 1., 1. ]);
				
			draw_surface_safe(_data[0], _shax, _shay);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, noone);
			var args = new blur_gauss_args(temp_surface[0], _size + 1, 3).setBG(false, cl);
			if(inputs[2].attributes.curved) args.setSizeCurve(_data[13]);
			
			var _s   = surface_apply_gaussian(args);
			draw_surface_ext_safe(_s, 0, 0, 1, 1, 0, cl, _stre * _color_get_alpha(cl));
			
			BLEND_ALPHA_MULP
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[6], _data[7]);
		
		return _outSurf;
	}
}