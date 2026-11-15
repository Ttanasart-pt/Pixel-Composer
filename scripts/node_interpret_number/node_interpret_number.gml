#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Interpret_Number", "Mode > Toggle", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 2); });
	});
#endregion

function Node_Interpret_Number(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Interpret Number";
	dimension_index = -1;
	
	newInput(0, nodeValue_Float( "Number", [] )).setVisible(true, true).setArrayDepth(1);
	
	////- =Values
	newInput( 1, nodeValue_EButton(  "Mode",      0, [ "Greyscale", "Palette", "Gradient" ] ));
	newInput( 2, nodeValue_Range(    "Range",    [0,1]     ));
	
	newInput( 6, nodeValue_Palette(  "Palette"             ));
	newInput( 3, nodeValue_Gradient( "Gradient", gra_white )).setMappable(4).addShift(7);
	
	////- =Output
	newInput( 8, nodeValue_EScroll( "Shape",  0, [ "Linear", "Grid" ] ));
	newInput( 9, nodeValue_Int(     "Column", 4 ));
	newInput(10, nodeValue_Int(     "Scale",  1 ));
	// 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	b_auto_range = button(function() /*=>*/ {
		var vals = getInputData(0);
		if(array_invalid(vals)) return;
		
		var vmin =  infinity;
		var vmax = -infinity;
		for( var i = 0, n = array_length(vals); i < n; i++ ) {
			var v = vals[i];
			vmin = min(vmin, v);
			vmax = max(vmax, v);
		}
		
		inputs[2].setValue([vmin, vmax]);
	}).setText(__txt("Auto-Range"));
	
	input_display_list = [  0,
		[ "Interpret", false ],  1,  2,  6, [3, false],  4,  7, -1, b_auto_range, 
		[ "Output",    false ],  8,  9, 10, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, getDimension()));
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var BATCH_SIZE = OS == os_windows? 1024 : 256;
			
			var _val = _data[ 0];
			var _mod = _data[ 1];
			var _ran = _data[ 2];
			var _pal = _data[ 6];
			
			var _pat = _data[ 8];
			var _col = _data[ 9];
			var _sca = _data[10];
			
			inputs[ 6].setVisible(_mod == 1);
			inputs[ 3].setVisible(_mod == 2);
			
			inputs[ 9].setVisible(_pat == 1);
		#endregion
		
		if(is_array(_val) && array_empty(_val)) return _outSurf;
		if(!is_array(_val)) _val = [ _val ];
		var _num = array_spread(_val);
		var _amo = array_length(_num);
		
		var sw = 1;
		var sh = 1;
		
		switch(_pat) {
			case 0 : sw = _amo; sh = 1;                 break;
			case 1 : sw = _col; sh = ceil(_amo / _col); break;
		}
		
		_outSurf = surface_verify(_outSurf, sw, sh, attrDepth());
		if(_amo == 0) return _outSurf;
		
		surface_set_shader(_outSurf, sh_interpret_number);
			shader_set_2( "dimension", [sw,sh] );
			shader_set_i( "mode",      _mod    );
			shader_set_i( "pattern",   _pat    );
			shader_set_i( "amount",    _amo    );
			shader_set_f( "range",     _ran    );
			shader_set_palette(_pal);
			
			shader_set_f( "gradient_shift", _data[7] );
			shader_set_gradient(_data[3], _data[4], _data[5], inputs[3]);
			
			shader_set_f("number", _num);
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
}