function Node_create_Scale_Algo(_x, _y, _group = noone, _param = {}) {
	var query = struct_try_get(_param, "query", "");
	var node  = new Node_Scale_Algo(_x, _y, _group);
	node.skipDefault();
	
	switch(query) {
		case "scale2x" :   node.inputs[1].setValue(0); break;	
		case "scale3x" :   node.inputs[1].setValue(1); break;	
		case "cleanedge" : node.inputs[1].setValue(2); break;	
	}
	
	return node;
}

function Node_Scale_Algo(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scale Algorithm";
	manage_atlas = false;
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Enum_Scroll("Algorithm", self,  0, [ "Scale2x", "Scale3x", "CleanEdge" ]));
		
	newInput(2, nodeValue_Float("Tolerance", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
		
	newInput(4, nodeValue_Bool("Scale atlas position", self, true));
	
	newInput(5, nodeValue_Float("Scale", self, 4));
		
	newInput(6, nodeValue_Rotation("Rotation", self, 0));
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3,
		["Surfaces", false], 0, 
		["Scale",	 false], 1, 2, 4, 5, 6, 
	]
	
	attribute_surface_depth();
	
	static step = function() {
		var _surf = getSingleValue(0);
		var _type = getSingleValue(1);
		
		var _atlas = is_instanceof(_surf, SurfaceAtlas);
		inputs[4].setVisible(_atlas);
		inputs[5].setVisible(_type == 2);
		inputs[6].setVisible(_type == 2);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var inSurf = _data[0];
		var algo   = _data[1];
		var _atlS  = _data[4];
		var _scal  = _data[5];
		var _rota  = _data[6];
		var ww     = surface_get_width_safe(inSurf);
		var hh     = surface_get_height_safe(inSurf);
		var cDep   = attrDepth();
		var sc = 2, sw, sh;
		var shader;
		
		var isAtlas = is_instanceof(_data[0], SurfaceAtlas);
		if(isAtlas && !is_instanceof(_outSurf, SurfaceAtlas))
			_outSurf = _data[0].clone(true);
			
		var _surf = isAtlas? _outSurf.getSurface() : _outSurf;
		
		switch(algo) {
			case 0 :
				shader = sh_scale2x;
				sc = 2;
				sw = ww * 2;
				sh = hh * 2;
				
				_surf = surface_verify(_surf, sw, sh, cDep);
				break;
				
			case 1 :
				shader = sh_scale3x;
				sc = 3;
				sw = ww * 3;
				sh = hh * 3;
				
				_surf = surface_verify(_surf, sw, sh, cDep);
				break;
				
			case 2 :
				shader = sh_scale_cleanedge;
				sc  = _scal;
				ww *= sc;
				hh *= sc;
				
				_surf = surface_verify(_surf, ww, hh, cDep);
				break;
				
		}
		
		surface_set_shader(_surf, shader);
			shader_set_f("dimension",        [ ww, hh ]);
			shader_set_f("tol",     		 _data[2]);
			shader_set_f("similarThreshold", _data[2]);
			shader_set_f("scale",   		 _scal);
			shader_set_f("rotation",   		 degtorad(_rota));
			
			draw_surface_ext_safe(_data[0], 0, 0, sc, sc, 0, c_white, 1);
		surface_reset_shader();
		gpu_set_texfilter(false);
		
		if(isAtlas) {
			if(_atlS) {
				_outSurf.x = _data[0].x * sc;
				_outSurf.y = _data[0].y * sc;
			} else {
				_outSurf.x = _data[0].x;
				_outSurf.y = _data[0].y;
			}
			
			_outSurf.setSurface(_surf);
			
		} else {
			_outSurf = _surf;
		}
		
		return _outSurf;
	}
}