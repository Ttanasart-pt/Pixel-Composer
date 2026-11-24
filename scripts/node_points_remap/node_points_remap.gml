function Node_Points_Remap(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Points Remap";
	color = COLORS.node_blend_number;
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Points
	newInput( 0, nodeValue_Vec2(    "Points", [[0,0]]  )).setArrayDepth(1).setVisible(true, true);
	newInput( 5, nodeValue_Bool(    "Output UV", false ));
	
	////- =Mapping
	newInput( 1, nodeValue_Surface( "UV Map"    ));
	newInput( 2, nodeValue_Slider(  "Amount", 1 ));
	newInput( 3, nodeValue_Bool(    "Use UV Dimension", true ));
	newInput( 4, nodeValue_Dimension());
	// 6
	
	newOutput( 0, nodeValue_Output( "Points", VALUE_TYPE.float, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	// newOutput( 1, nodeValue_Output( "UVs",    VALUE_TYPE.float, [0,0] )).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		[ "Points",  false ],  0,  //5, 
		[ "Mapping", false ],  1,  2,  3,  4, 
	];
	
	////- Nodes
	
	uvSampler = new Surface_sampler();
	
	static update = function() {
		#region data
			var _points = getInputData( 0);
			var _outuv  = getInputData( 5);
			
			var _uvmap  = getInputData( 1);
			var _uvamo  = getInputData( 2);
			var _uvdim  = getInputData( 3);
			var _csdim  = getInputData( 4);
			
			inputs[4].setVisible(!_uvdim);
			
			var _outData = outputs[0].getValue();
		#endregion
		
		if(!is_surface(_uvmap)) return;
		uvSampler.setSurface(_uvmap);
		
		var ww = _uvdim? surface_get_width(_uvmap)  : _csdim[0];
		var hh = _uvdim? surface_get_height(_uvmap) : _csdim[1];
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
		
		outputs[0].setTypeSignature(array_create(array_length(_outData), VALUE_TYPE.float));
		
	}
}
