#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Stack", "Axis > Toggle",  "X", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[0].setValue((_n.inputs[0].getValue() + 1) % 3); });
		addHotkey("Node_Stack", "Align > Toggle", "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 1) % 3); });
	});
#endregion

function Node_Stack(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Stack";
	
	////- =Stack
	_axis_enum = [ new scrollItem("Horizontal", s_node_alignment, 0), 
			       new scrollItem("Vertical",   s_node_alignment, 1), 
			       new scrollItem("On top",     s_node_alignment, 3), ];
			       
	newInput( 0, nodeValue_EScroll(  "Axis",     0, _axis_enum                  ));
	newInput( 1, nodeValue_EButton(  "Align",    1, [ "Start", "Middle", "End"] ));
	newInput( 2, nodeValue_Int(      "Spacing",  0                              ));
	newInput( 3, nodeValue_IPadding( "Padding", [0,0,0,0]                       ));
	
	////- =Render
	newInput( 4, nodeValue_EScroll( "Blend Mode",    0, BLEND_TYPES ));
	newInput( 5, nodeValue_Bool(    "Reverse Depth", false          ));
	// 6
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Atlas data",  VALUE_TYPE.atlas,   []    ));
	
	array_foreach(inputs, function(i,_) /*=>*/ {return i.rejectArray()});
	input_display_list = [
		[ "Stack",    false ],  0,  1,  2,  3, 
		[ "Render",   false ],  4,  5, 
		[ "Surfaces", false ], 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Surface("Input")).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		postCreateNewInput(index);
		return inputs[index];
	} 
	
	setDynamicInput(1, true, VALUE_TYPE.surface);
	
	////- Node
	
	temp_surface = [ noone, noone, noone ];
	
	attribute_surface_depth();
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { 
		var _df  = draw_transforms;
		var _amo = min(array_length(_df), getInputAmount());
		
		for( var i = 0; i < _amo; i++ ) {
			if(_node == inputs[input_fix_len + i].getNodeFrom())
				return _df[i];
		}
		
		return noone;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _axis = getInputData( 0);
			var _alig = getInputData( 1);
			var _spac = getInputData( 2);
			var _padd = getInputData( 3);
			
			var _blnd = getInputData( 4);
			var _revr = getInputData( 5);
			
			inputs[1].setVisible(_axis != 2);
			inputs[2].setVisible(_axis != 2);
		#endregion
		
		#region dimension
			var ww = 0;
			var hh = 0;
			
			for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
				var _surf = getInputData(i);
				if(!is_array(_surf)) _surf = [ _surf ];
				
				for( var j = 0, m = array_length(_surf); j < m; j++ ) {
					if(!is_surface(_surf[j])) continue;
					var sw = surface_get_width_safe(_surf[j]);
					var sh = surface_get_height_safe(_surf[j]);
					
					if(_axis == 0) {
						ww += sw + _spac;
						hh = max(hh, sh + _spac);
						
					} else if(_axis == 1) {
						ww = max(ww, sw + _spac);
						hh += sh + _spac;
						
					} else if(_axis == 2) {
						ww = max(ww, sw);
						hh = max(hh, sh);
					}
				}
			}
			
			ww -= _spac;
			hh -= _spac;
			
			var ow = ww + _padd[PADDING.left] + _padd[PADDING.right]; 
			var oh = hh + _padd[PADDING.top] + _padd[PADDING.bottom]; 
		#endregion
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, ow, oh, attrDepth());
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], ow, oh, attrDepth());
			surface_clear(temp_surface[i]);
		}
		
		blend_temp_surface = temp_surface[2];
		
		#region position calculation
			draw_transforms = [];
			
			var _surfs = [];
			var atlas  = [];
			var sx = 0; 
			var sy = 0;
			
			for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
				var _surf = getInputData(i);
					
				if(is_array(_surf)) {
					for( var j = 0, m = array_length(_surf); j < m; j++ )
						if(is_surface(_surf[j])) array_push(_surfs, _surf[j]);
				} else 
					if(is_surface(_surf)) array_push(_surfs, _surf);
			}
			
			for( var i = 0, n = array_length(_surfs); i < n; i++ ) {
				var _surf = _surfs[i];
				var sw = surface_get_width_safe(_surf);
				var sh = surface_get_height_safe(_surf);
				
				if(_axis == 0) {
					switch(_alig) {
						case fa_left:	sy = 0;					break;
						case fa_center:	sy = hh / 2 - sh / 2;	break;
						case fa_right:	sy = hh - sh;			break;
					}
					
				} else if(_axis == 1) {
					switch(_alig) {
						case fa_left:	sx = 0;					break;
						case fa_center:	sx = ww / 2 - sw / 2;	break;
						case fa_right:	sx = ww - sw;			break;
					}
					
				} else if(_axis == 2) {
					sx = ww / 2 - sw / 2;
					sy = hh / 2 - sh / 2;
				}
					
				var px = sx + _padd[PADDING.left];
				var py = sy + _padd[PADDING.top]
					
				px = round(px);
				py = round(py);
					
				array_push(atlas, new SurfaceAtlas(_surf, sx, sy));
				array_push(draw_transforms, [px, py, 1, 1, 0, _surf]);
				
					 if(_axis == 0) sx += sw + _spac;
				else if(_axis == 1) sy += sh + _spac;
			}
		#endregion
		
		#region render
			var ppind = 0;
			
			if(_revr) array_reverse_ext(draw_transforms);
			for( var i = 0, n = array_length(draw_transforms); i < n; i++ ) {
				var _drawTrans = draw_transforms[i];
				var _surf = _drawTrans[ 5];
				var  px   = _drawTrans[ 0];
				var  py   = _drawTrans[ 1];
				
				surface_set_shader(temp_surface[!ppind], noone, true, BLEND.over);
					draw_surface_blend_ext(temp_surface[ppind], _surf, px, py, 1, 1, 0, c_white, 1, _blnd);
				surface_reset_shader();
				
				ppind = !ppind;
					
			}
			
			surface_set_shader(_outSurf, noone, true, BLEND.over);
				draw_surface_safe(temp_surface[ppind]);
			surface_reset_target();
		#endregion
		
		outputs[0].setValue(_outSurf);
		outputs[1].setValue(atlas);
	}
}

