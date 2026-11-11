function Node_Randomizer_Varient_Collect(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Collect Varient";
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In"      ));
	newInput( 2, nodeValue_Bool(    "Animated", false ));
	
	////- =Variant
	newInput( 1, nodeValue_Int( "Variant Index", 0 )).setVisible(true, true);
	// 3
	
	newOutput( 0, nodeValue_Output("Surface Array", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surface", false ],  0,  2, 
		[ "Variant", false ],  1, 
	];
	
	////- Nodes
	
	collectedSurface = [];
	
	static resetArray = function() {
		collectedSurface = [];
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _surf = getInputData( 0);
			var _anim = getInputData( 2);
			
			var _indx = getInputData( 1);
			
			update_on_frame = _anim;
		#endregion
		
		if(!is_surface(_surf)) return;
		
		var _arr = array_safe_get(collectedSurface, _indx, []);
		if(_anim) {
			_arr[frame] = surface_clone(_surf);
			collectedSurface[_indx] = _arr;
			
		} else 
			collectedSurface[_indx] = surface_clone(_surf);
		
		outputs[0].setValue(collectedSurface);
	}
}
