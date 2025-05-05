function Node_Flood_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Flood Fill";
	
	newInput(0, nodeValue_Surface("Surface In", self));
		
	newInput(1, nodeValue_Surface("Mask", self));
	
	newInput(2, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
		
	newInput(4, nodeValue_Vec2("Position", self, [ 1, 1 ]));
		
	newInput(5, nodeValue_Color("Colors", self, ca_black ));
	
	newInput(6, nodeValue_Float("Threshold", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(7, nodeValue_Bool("Diagonal", self, false));
	
	__init_mask_modifier(1); // inputs 8, 9
	
	newInput(10, nodeValue_Enum_Scroll("Blend", self,  0, [ "Override", "Multiply" ]));
	
	newOutput(0, nodeValue_Output("Surface Out",	self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3,
		["Surfaces", false], 0, 1, 2, 8, 9, 
		["Fill",	 false], 4, 6, 5, 7, 10, 
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {

		var hv = inputs[4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny); OVERLAY_HV
		
		return w_hovering;
	}
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var inSurf = _data[0];
		if(!is_surface(inSurf)) return _outSurf;
		
		var _pos = _data[ 4];
		var _col = _data[ 5];
		var _thr = _data[ 6];
		var _dia = _data[ 7];
		var _bnd = _data[10];
		
		var _filC = surface_get_pixel_ext(inSurf, _pos[0], _pos[1]);
		
		var sw = surface_get_width_safe(inSurf);
		var sh = surface_get_height_safe(inSurf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			temp_surface[i] = surface_verify(temp_surface[i], sw, sh, attrDepth());
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			
			shader_set(sh_flood_fill_thres);
			shader_set_f("color", colaToVec4(_filC));
			shader_set_f("thres", _thr);
				BLEND_OVERRIDE
				draw_surface_safe(inSurf);
				BLEND_NORMAL
			shader_reset();
			
			BLEND_OVERRIDE
			draw_set_color(c_red);
			draw_point(_pos[0] - 1, _pos[1] - 1);
			BLEND_NORMAL
		surface_reset_target();
		
		var ind = 0;
		var it  = attributes.fill_iteration == -1? 8 : attributes.fill_iteration;
		repeat(it) {
			ind = !ind;
			
			surface_set_shader(temp_surface[ind], sh_flood_fill_it);
				shader_set_f("dimension", [ sw, sh ]);
				shader_set_i("diagonal", _dia);
				draw_surface_safe(temp_surface[!ind]);
			surface_reset_shader();
		}
		
		surface_set_shader(_outSurf, sh_flood_fill_replace);
			shader_set_color("color",  _col);
			shader_set_surface("mask", temp_surface[ind]);
			shader_set_i("blend",      _bnd);
			
			draw_surface_safe(inSurf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		return _outSurf;
	}
}
