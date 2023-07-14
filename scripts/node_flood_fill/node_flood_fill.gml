function Node_Flood_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Flood Fill";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0)
		.rejectArray();
		
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
		
	inputs[| 4] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 5] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black )
	
	inputs[| 6] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 7] = nodeValue("Diagonal", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out",	self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3,
		["Output",	 false], 0, 1, 2, 
		["Fill",	 false], 4, 6, 5, 7, 
	]
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	
	attribute_surface_depth();
	
	attributes.fill_iteration = -1;
	array_push(attributeEditors, "Algorithm");
	array_push(attributeEditors, ["Fill iteration", function() { return attributes.fill_iteration; }, 
		new textBox(TEXTBOX_INPUT.number, function(val) { 
			attributes.fill_iteration = val; 
			triggerRender();
		})]);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var inSurf = _data[0];
		if(!is_surface(inSurf)) return _outSurf;
		
		var _pos = _data[4];
		var _col = _data[5];
		var _thr = _data[6];
		var _dia = _data[7];
		
		var _filC = surface_get_pixel_ext(inSurf, _pos[0], _pos[1]);
		
		var sw = surface_get_width(inSurf);
		var sh = surface_get_height(inSurf);
		
		for( var i = 0; i < array_length(temp_surface); i++ )
			temp_surface[i] = surface_verify(temp_surface[i], sw, sh, attrDepth());
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			
			shader_set(sh_flood_fill_thres);
			shader_set_f("color", colaToVec4(_filC));
			shader_set_f("thres", _thr);
				BLEND_OVERRIDE
				draw_surface_safe(inSurf, 0, 0);
				BLEND_NORMAL
			shader_reset();
			
			BLEND_OVERRIDE
			draw_set_color(c_red);
			draw_point(_pos[0] - 1, _pos[1] - 1);
			BLEND_NORMAL
		surface_reset_target();
		
		var ind = 0;
		var it  = attributes.fill_iteration == -1? sw + sh : attributes.fill_iteration;
		repeat(it) {
			ind = !ind;
			
			surface_set_target(temp_surface[ind]);
			DRAW_CLEAR
			
			shader_set(sh_flood_fill_it);
			shader_set_f("dimension", [ sw, sh ]);
			shader_set_i("diagonal", _dia);
				BLEND_OVERRIDE
				draw_surface_safe(temp_surface[!ind], 0, 0);
				BLEND_NORMAL
			shader_reset();
			surface_reset_target();
		}
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		
		shader_set(sh_flood_fill_replace);
		shader_set_f("color", colToVec4(_col));
		shader_set_surface("mask", temp_surface[ind]);
			BLEND_OVERRIDE
			draw_surface_safe(inSurf, 0, 0);
			BLEND_NORMAL
		shader_reset();
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		return _outSurf;
	}
}
