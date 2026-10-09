function Node_Repeat_Path(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Repeat Path";
	
	////- =Surface
	newInput( 0, nodeValue_Surface("Surface In")).setRequired();
	
	////- =Path
	newInput( 1, nodeValue_Path( "Path" )).setVisible(true, true).setRequired();
	//
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		0
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _path = _data[ 1];
			
		#endregion
		
		return _outSurf; 
	}
}