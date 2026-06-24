function Node_Crack_Pattern(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Crack Pattern";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	
	////- =Pattern
	newInput( 1, nodeValue_EButton( "Pattern", 0, [ "Cross", "Xor" ]));
	// 2
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		[ "Output",   true ],  0, 
		[ "Pattern", false ],  1, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			
		#endregion
		
		return _outSurf; 
	}
}