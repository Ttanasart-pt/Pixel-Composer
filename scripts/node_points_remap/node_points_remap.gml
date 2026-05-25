/*
#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("", " > Set", KEY_GROUP.numeric, MOD_KEY.none, () => { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
		addHotkey("", " > ", "", MOD_KEY.none, () => { GRAPH_FOCUS _n.inputs[1].setValue(); });
		addHotkey("", " > Toggle", "", MOD_KEY.none, () => { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 2); });
	});
#endregion
*/

function Node_Points_Remap(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Points Remap";
	color = COLORS.node_blend_number;
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Points
	newInput( 0, nodeValue_Vec2(    "Points", [[0,0]])).setArrayDepth(1).setVisible(true, true);
	
	////- =Mapping
	newInput( 1, nodeValue_Surface( "UV Map"    ));
	newInput( 2, nodeValue_Slider(  "Amount", 1 ));
	// 3
	
	newOutput(0, nodeValue_Output( "Points", VALUE_TYPE.float, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		[ "Points",  false ], 0, 
		[ "Mapping", false ], 1, 2, 
	];
	
	////- Nodes
	
	uvSampler = new Surface_sampler();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static update = function() {
		#region data
			var _points = getInputData( 0);
			
			var _uvmap  = getInputData( 1);
			var _uvamo  = getInputData( 2);
			
			if(!is_surface(_uvmap)) return;
			
			var _outData = outputs[0].getValue();
		#endregion
		
		uvSampler.setSurface(_uvmap);
		
		var ww = surface_get_width(_uvmap);
		var hh = surface_get_height(_uvmap);
		var vx, vy;
		
		var pamo = array_length(_points);
		_outData = array_verify_ext(_outData, pamo, function() /*=>*/ {return [0,0]});
		
		for( var i = 0; i < pamo; i++ ) {
			var px = _points[i][0];
			var py = _points[i][1];
			
			var _val = uvSampler.getPixel(px, py);
			
			if(is_array(_val)) {
				vx = _val[0] * ww;
				vy = _val[1] * hh;
				
			} else {
				vx = _color_get_r(_val) * ww;
				vy = _color_get_g(_val) * hh;
				
			}
			
			_outData[i][0] = lerp(px, vx, _uvamo);
			_outData[i][1] = lerp(py, vy, _uvamo);
		}
		
	}
}
