function Node_Pixel_Builder(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "Pixel Builder";
	color = COLORS.node_blend_feedback;
	icon  = THEME.pixel_builder;
	
	reset_all_child = true;
	attributes.pure_function = false;
	layers = [];
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_b("Outline",   self, false));
	newInput(2, nodeValue_i("Thickness", self, 0));
	newInput(3, nodeValue_c("Color",     self, ca_white)).setInternalName("Outline Color");
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	layer_colors = [
		CDEF.main_dark,
		CDEF.main_grey,
		CDEF.main_ltgrey,
		CDEF.main_mdwhite,
		CDEF.main_white,
	];
	
	layer_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { 
		var  yy = _y;
		var  xx = _x + ui(8);
		var _hg = ui(32);
		var _hh = ui(8) + array_length(layers) * _hg;
		
		var ssh = _hg - ui(4);
		var _curr_layr   = undefined;
		var _layer_index = 0;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, yy, _w, _hh, COLORS.node_composite_bg_blend, 1);
		yy += ui(4);
		
		for( var i = array_length(layers) - 1; i >= 0; i-- ) {
			var _l = layers[i];
			
			var _surf = _l.data;
			var _layr = _l.layr;
			var _name = _l.getDisplayName();
			
			if(_curr_layr != _layr) {
				_layer_index++;
				_curr_layr = _layr;
			}
			
			#region draw surface
				var _sx0 = xx;
				var _sx1 = _sx0 + ssh;
				var _sy0 = yy + _hg / 2 - ssh / 2;
				var _sy1 = _sy0 + ssh;
				
				draw_surface_fit(_surf, _sx0 + ssh / 2, _sy0 + ssh / 2, ssh, ssh);
				draw_sprite_stretched_add(THEME.box_r2, 1, _sx0, _sy0, ssh, ssh, COLORS._main_icon, 0.3);
			#endregion
			
			var cc = layer_colors[_layer_index % array_length(layer_colors)];
			draw_set_text(f_p1b, fa_right, fa_center, cc);
			draw_text(_x + _w - ui(16), yy + _hg / 2, _layr);
			
			var hov = _hover && point_in_rectangle(_m[0], _m[1], _x, yy, _x + _w, yy + _hg);
			var cc  = COLORS._main_text_sub;
			if(hov) {
				cc  = COLORS._main_text;
				if(mouse_click(mb_left, _focus))
					PANEL_GRAPH.nodes_selecting = [ _l ];
			}
			
			draw_set_text(f_p2, fa_left, fa_center, cc);
			draw_text(xx + ssh + ui(8), yy + _hg / 2, _name);
			
			yy += _hg;
		}
		
		return _hh;
	});
	
	group_input_display_list  = [ 0, 
		["Layers",  false], layer_renderer, 
		["Border", false, 1], 2, 3, new Inspector_Spacer(ui(4), true, false, ui(4)) 
	];
	group_output_display_list = [ 0 ];
	
	custom_input_index  = array_length(inputs);
	custom_output_index = array_length(outputs);
	
	dimension    = [ 1, 1 ];
	temp_surface = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(!draw_input_overlay) return;
		
		for(var i = custom_input_index; i < array_length(inputs); i++) {
			var _in = inputs[i];
			var _hv = _in.from.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
			if(_hv != undefined) active &= !_hv;
		}
		
		inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static checkComplete = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _n = nodes[i];
			if(!is(_n, Node_PB_Output)) continue;
			if(!_n.rendered) continue;
		}
		
		buildPixel();
	}
	
	static buildPixel = function() {
		var _outSurf = outputs[0].getValue();
		_outSurf = surface_verify(_outSurf, dimension[0], dimension[1]);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], dimension[0], dimension[1]);
		
		var pr = ds_priority_create();
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _n = nodes[i];
			if(!is(_n, Node_PB_Output)) continue;
			if(!_n.drawA) continue;
			
			ds_priority_add(pr, _n, _n.layr);
		}
		
		layers = array_create(ds_priority_size(pr));
		var i = 0;
		
		surface_set_shader(temp_surface[0], noone);
			while(!ds_priority_empty(pr)) {
				var _n = ds_priority_delete_min(pr);
				var _surf = _n.data;
				var _blnd = _n.blend;
				layers[i++] = _n;
				
				switch(_blnd) {
					case 0 : BLEND_NORMAL;   break;
					case 1 : BLEND_SUBTRACT; break;
				}
				
				draw_surface_safe(_surf);
				
				BLEND_NORMAL
			}
		surface_reset_shader();
		ds_priority_destroy(pr);
		
		var _stk     = inputs[1].getValue();
		var _stk_thk = inputs[2].getValue();
		var _stk_col = inputs[3].getValue();
		
		surface_set_shader(_outSurf, sh_pb_main_draw);
			shader_set_2("dimension", dimension);
			shader_set_i("stroke",           _stk     );
			shader_set_f("stroke_thickness", _stk_thk );
			shader_set_c("stroke_color",     _stk_col );
			
			shader_set_f("corner_radius",    0 );
			
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
	}

	static update = function() {
		dimension = inputs[0].getValue();
	}
	
	static checkPureFunction = function() {
		isPure = false;
	}
	
	static getGraphPreviewSurface = function() /*=>*/ {return outputs[0].getValue()};
}