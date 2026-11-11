function Node_Randomizer_Varient_Collect(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Collect Varient";
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Variant
	newInput( 1, nodeValue_Int( "Variant Index", 0 )).setVisible(true, true);
	// 2
	
	newOutput( 0, nodeValue_Output("Surface Array", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surface", false ],  0, 
		[ "Variant", false ],  1, 
	];
	
	////- Nodes
	
	collectedSurface = [];
	
	static resetArray = function() {
		collectedSurface = [];
	}
	
	static update = function() {
		#region data
			var _surf = getInputData( 0);
			var _indx = getInputData( 1);
		#endregion
		
		if(!is_surface(_surf)) return;
		collectedSurface[_indx] = surface_clone(_surf);
		
		outputs[0].setValue(collectedSurface);
	}
}
