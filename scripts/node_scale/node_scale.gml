#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Scale", "Mode > Toggle", "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 2); });
		addHotkey("Node_Scale", "Scale > Set", KEY_GROUP.numeric, MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[1].setValue(KEYBOARD_NUMBER); });
	});
#endregion

function Node_Scale(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scale";
	dimension_index = -1;
	
	manage_atlas = false;
	
	newActiveInput(4);
	
	////- Surfaces
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- Scale
	
	newInput(2, nodeValue_Enum_Button( "Mode", 0, [ "Upscale", "Scale to fit" ]));
	newInput(6, nodeValue_Enum_Button( "Fit Mode", 0, [ "Stretch", "Minimum", "Maximum" ]));
	newInput(1, nodeValue_Float(       "Scale", 1));
	newInput(3, nodeValue_Vec2(        "Target Dimension", DEF_SURF));
	newInput(5, nodeValue_Bool(        "Scale Atlas Position", true));
	
	// inputs 6
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 4, 
		["Surfaces", true], 0,
		["Scale",	false], 2, 6, 1, 3, 5, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { return array_safe_get(draw_transforms, preview_index, noone); }
	
	static processData = function(_outSurf, _data, _array_index) {
		var surf  = _data[0]; 
		
		var mode  = _data[2];
		var fmode = _data[6];
		var scale = _data[1];
		var targ  = _data[3];
		var _atlS = _data[5];
		var cDep  = attrDepth();
		
		inputs[1].setVisible(mode == 0);
		inputs[3].setVisible(mode == 1);
		inputs[5].setVisible(is(surf, SurfaceAtlas));
		inputs[6].setVisible(mode == 1);
		
		var isAtlas = is(surf, SurfaceAtlas);
		if(isAtlas && !is(_outSurf, SurfaceAtlas))
			_outSurf = _data[0].clone(true);
			
		var _surf = isAtlas? _outSurf.getSurface() : _outSurf;
		
		var ww, hh, scx = 1, scy = 1;
		var _sw = surface_get_width_safe(surf);
		var _sh = surface_get_height_safe(surf);
		
		switch(mode) {
			case 0 :
				scx = scale;
				scy = scale;
				ww	= scale * _sw;
				hh	= scale * _sh;
				break;
				
			case 1 : 
				scx = targ[0] / _sw;
				scy = targ[1] / _sh;
				
				switch(fmode) {
					case 0 : 
						ww	= targ[0];
						hh	= targ[1];
						break;
					
					case 1 :
						scx = min(scx, scy);
						scy = scx;
						ww  = _sw * scx;
						hh  = _sh * scx;
						break;
						
					case 2 :
						scx = max(scx, scy);
						scy = scx;
						ww  = _sw * scx;
						hh  = _sh * scx;
						break;
						
				}
				break;
		}
		
		_surf = surface_verify(_surf, ww, hh, cDep);
		
		surface_set_shader(_surf);
			shader_set_interpolation(surf);
			draw_surface_stretched_safe(surf, 0, 0, ww, hh);
		surface_reset_shader();
		
		draw_transforms[_array_index] = [ 0, 0, ww * _sw, hh * _sh, 0];
		
		if(!isAtlas) return _surf;
		
		if(_atlS) {
			_outSurf.x = surf.x * scx;
			_outSurf.y = surf.y * scy;
		} else {
			_outSurf.x = surf.x;
			_outSurf.y = surf.y;
		}
		
		_outSurf.setSurface(_surf);
		return _outSurf;
	}
}