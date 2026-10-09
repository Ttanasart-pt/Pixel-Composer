function Node_Surface_Get_BBOX(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Get BBOX";
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Surface("Surface In")).setRequired();
	// 1
	
	newOutput( 0, nodeValue_Output( "BBOX", VALUE_TYPE.float, [0,0,0,0] )).setDisplay(VALUE_DISPLAY.vector);
	newOutput( 1, nodeValue_Output( "Area", VALUE_TYPE.float, DEF_AREA  )).setDisplay(VALUE_DISPLAY.area);
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static step = function() {}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			if(!is_surface(_surf)) return _outData;
		#endregion
		
		var bbox = surface_get_bbox(_surf);
		
		var _cx = bbox[0] + bbox[2] / 2;
		var _cy = bbox[1] + bbox[3] / 2;
		var _ww = bbox[2] / 2;
		var _hh = bbox[3] / 2;
		
		_outData[0] = bbox;
		_outData[1] = [ _cx, _cy, _ww, _hh, AREA_SHAPE.rectangle, AREA_MODE.area ];
		
		return _outData;
	}
}