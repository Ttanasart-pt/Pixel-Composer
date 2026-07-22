function Node_MK_Tree_Render(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Render Tree";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	parameters.inline_draw_output = true;
	
	newInput( 0, nodeValue_Struct( "Tree",           noone )).setArrayDepth(1).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Outputs
	newInput( 1, nodeValue_Bool(   "Output Array",   false )).rejectArray();
	
	////- =Render
	newInput( 2, nodeValue_Bool(    "Draw From Root", true )).rejectArray();
	newInput( 3, nodeValue_EScroll( "Blend Mode",     0, [ "Normal", "Add", "Max", "Min" ]  )).rejectArray();
	
	////- =Filter
	newInput( 4, nodeValue_Bool(    "Filter Root Position", false )).rejectArray();
	newInput( 5, nodeValue_Range(   "Range",                [0,1] )).rejectArray();
	
	newInput( 6, nodeValue_Bool(    "Filter Random",        false )).rejectArray();
	newInput( 7, nodeValueSeed());
	newInput( 8, nodeValue_Slider(  "Chance",               .5    )).rejectArray();
	// 9
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ s_MKFX, 0, 
		[ "Outputs", false ],  1, 
		[ "Render",  false ],  2,  3, 
		[ "Filter",   true ],  
			[ "/Root Position", false, 4 ],  5, 
			[ "/Random",        false, 6 ],  7,  8, 
	];
	
	////- Nodes
	
	drawRoot = false;
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static preGetInputs = function() {
		var _tree = inputs[0].getValue();
		var _arr  = inputs[1].getValue();
		inputs[0].setArrayDepth(!_arr);
		
		if(!array_empty(_tree)) array_foreach(_tree, function(t,i) /*=>*/ { 
			t.drawn = false; 
			if(t.root) t.root.drawn = false; 
			return true;
		})
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		if(!is(inline_context, Node_MK_Tree_Inline)) return _outSurf;
		
		#region data
			var _tree = _data[ 0];
			var _arra = _data[ 1];
			
			drawRoot  = _data[ 2];
			var _blnd = _data[ 3];
			
			var _fRootPosUse = _data[ 4];
			var _fRootPos    = _data[ 5];
			
			var _fRandUse  = _data[ 6];
			var _fRandSeed = _data[ 7];
			var _fRandChan = _data[ 8];
			
			var _dim  = getDimension();
		#endregion
		
		if(!is_array(_tree)) _tree = [_tree];
		if(array_empty(_tree)) return _outSurf;
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			switch(_blnd) {
				case 0 : BLEND_NORMAL; break;
				case 1 : BLEND_ADD;    break;
				case 2 : BLEND_MAX;    break;
				case 3 : draw_clear_alpha(c_white, 0); BLEND_MIN; break;
			}
			
			draw_set_color(c_white);
			random_set_seed(_fRandSeed);
			
			for( var i = 0, n = array_length(_tree); i < n; i++ ) {
				var _t = _tree[i];
				
				if(!is(_t, __MK_Tree_Element)) continue;
			
				if(_fRootPosUse && (_t.rootPosition < _fRootPos[0] || _t.rootPosition > _fRootPos[1]))
					continue;
				
				if(_fRandUse && random(1) > _fRandChan)
					continue;
				
				if(is(_t, __MK_Tree)) { 
					var _drawT = drawRoot? _t.root : _t;
					if(_drawT.drawn) continue;
					
					_drawT.drawn = true;
					_drawT.draw();
					continue;
				}
				
				_t.draw();
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
	
	
}