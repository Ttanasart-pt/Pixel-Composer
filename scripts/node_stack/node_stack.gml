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
			       
	newInput(0, nodeValue_EScroll( "Axis",     0, _axis_enum                  ));
	newInput(1, nodeValue_EButton( "Align",    1, [ "Start", "Middle", "End"] ));
	newInput(2, nodeValue_Int(     "Spacing",  0                              ));
	newInput(3, nodeValue_Padding( "Padding", [0,0,0,0]                       ));
	
	////- =Render
	newInput(4, nodeValue_Enum_Scroll( "Blend Mode", 0, BLEND_TYPES ));
	array_foreach(inputs, function(i) /*=>*/ {return i.rejectArray()});
	// 5
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Atlas data",  VALUE_TYPE.atlas,   []    ));
	
	input_display_list = [
		["Stack",    false], 0, 1, 2, 3, 
		["Render",   false], 4, 
		["Surfaces", false], 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Surface("Input")).setVisible(true, true);
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	} 
	
	setDynamicInput(1, true, VALUE_TYPE.surface);
	
	////- Node
	
	temp_surface = [ noone, noone, noone ];
	
	attribute_surface_depth();
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { 
		var _df  = draw_transforms;
		var _amo = min(array_length(draw_transforms), getInputAmount());
		
		for( var i = 0; i < _amo; i++ ) {
			if(_node == inputs[input_fix_len + i].getNodeFrom())
				return _df[i];
		}
		
		return noone;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _axis = getInputData(0);
		var _alig = getInputData(1);
		var _spac = getInputData(2);
		var _padd = getInputData(3);
		var _blnd = getInputData(4);
		
		inputs[1].setVisible(_axis != 2);
		inputs[2].setVisible(_axis != 2);
		
		var ww = 0;
		var hh = 0;
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			var _surf = getInputData(i);
			if(!is_array(_surf)) _surf = [ _surf ];
			
			for( var j = 0; j < array_length(_surf); j++ ) {
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
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, ow, oh, attrDepth());
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], ow, oh, attrDepth());
			surface_clear(temp_surface[i]);
		}
		
		blend_temp_surface = temp_surface[2];
		
		var atlas = [];
		var ppind = 0;
		var sx = 0; 
		var sy = 0;
		var ai = 0;
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			var _surf = getInputData(i);
			if(!is_array(_surf)) _surf = [ _surf ];
				
			for( var j = 0; j < array_length(_surf); j++ ) {
				if(!is_surface(_surf[j])) continue;
				var sw = surface_get_width_safe(_surf[j]);
				var sh = surface_get_height_safe(_surf[j]);
					
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
					
				array_push(atlas, new SurfaceAtlas(_surf[j], sx, sy));
				draw_transforms[ai++] = [ px, py, 1, 1, 0];
				
				surface_set_shader(temp_surface[!ppind], noone, true, BLEND.over);
					draw_surface_blend_ext(temp_surface[ppind], _surf[j], px, py, 1, 1, 0, c_white, 1, _blnd);
				surface_reset_shader();
				
				ppind = !ppind;
					
					 if(_axis == 0) sx += sw + _spac;
				else if(_axis == 1) sy += sh + _spac;
			}
		}
		
		surface_set_target(_outSurf);
			DRAW_CLEAR 
			BLEND_OVERRIDE
			draw_surface_safe(temp_surface[ppind]);
			BLEND_NORMAL
		surface_reset_target();
		
		outputs[0].setValue(_outSurf);
		outputs[1].setValue(atlas);
	}
}

