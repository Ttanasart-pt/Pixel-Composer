function Node_Anim_Speed(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Animation Speed";
	setCacheManual();
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Animation
	newInput( 1, nodeValue_Float(   "Speed",    1 ));
	newInput( 2, nodeValue_EScroll( "Overflow", 0, ["Loop", "Pingpong", "Empty"] ));
	// 3
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Surface",   false ],  0,
		[ "Animation", false ],  1,
	];
	
	////- Nodes
	
	static update = function(_frame = CURRENT_FRAME) {
		#region data
			var _surf = getInputData( 0);
			
			var _sped = getInputData( 1);
			var _over = getInputData( 2);
		#endregion
		
		cacheCurrentFrame(_surf);
		
		var _ftarg = _frame * _sped;
		var _total = TOTAL_FRAMES;
		
		switch(_over) {
			case 0 : _ftarg = safe_mod(_ftarg, _total); break;
			case 1 : 
				_ftarg = safe_mod(_ftarg, _total + 1 + _total); 
				if(_ftarg > _total) _ftarg = (_total + _total) - _ftarg;
			break;
			
			case 2 : 
				if(_ftarg < 0 || _ftarg >= _total) {
					var _dim = surface_get_dimension(_surf);
					
					var _out = outputs[0].getValue();
					_out = surface_verify(_out, _dim[0], _dim[1]);
					surface_clear(_out);
					outputs[0].getValue(_out);
					return;
				}
				
			break;
		}
		
		var _res = getCacheFrame(_ftarg);
		outputs[0].setValue(_res);
	}
}
