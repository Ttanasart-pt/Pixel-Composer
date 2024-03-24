function Node_Biterator(_x, _y, _group = noone) : Node_VCT(_x, _y, _group) constructor {
	name = "Biterator";
	vct  = new Biterator(self);
}

function Biterator(node) : VCT(node) constructor {
	panel = Biterator_Panel;
	
	dimension = VCT_var(VALUE_TYPE.integer, 0);
	shape	  = VCT_var(VALUE_TYPE.integer, 0);
	
	shape_par[0] = VCT_var(VALUE_TYPE.integer, 0).setDisplay(VALUE_DISPLAY.slider, { range: [- 8,  8, 0.1] });
	shape_par[1] = VCT_var(VALUE_TYPE.integer, 0).setDisplay(VALUE_DISPLAY.slider, { range: [- 8,  8, 0.1] });
	shape_par[2] = VCT_var(VALUE_TYPE.integer, 2).setDisplay(VALUE_DISPLAY.slider, { range: [  0,  4, 0.1] });
	shape_par[3] = VCT_var(VALUE_TYPE.integer, 2).setDisplay(VALUE_DISPLAY.slider, { range: [  0,  4, 0.1] });
	shape_par[4] = VCT_var(VALUE_TYPE.integer, 0).setDisplay(VALUE_DISPLAY.slider, { range: [ -4,  4, 0.1] });
	shape_par[5] = VCT_var(VALUE_TYPE.integer, 0).setDisplay(VALUE_DISPLAY.slider, { range: [ -4,  4, 0.1] });
	
	shape_par[5] = VCT_var(VALUE_TYPE.integer, 0).setDisplay(VALUE_DISPLAY.slider, { range: [ -4,  4, 0.1] });
	
	for( var i = 0; i < 3; i++ )
		color[i] = VCT_var(VALUE_TYPE.color, c_white);
	
	shape_knob[0] = VCT_var(VALUE_TYPE.integer, 0).setDisplay(VALUE_DISPLAY.rotation, [0, 7, 1]);
	shape_knob[1] = VCT_var(VALUE_TYPE.integer, 0).setDisplay(VALUE_DISPLAY.rotation, [0, 6, 1]);
	shape_knob[2] = VCT_var(VALUE_TYPE.integer, 0).setDisplay(VALUE_DISPLAY.rotation, [0, 6, 1]);
		
	for( var i = 0; i < 2; i++ )
		color_knob[i] = VCT_var(VALUE_TYPE.float, 0).setDisplay(VALUE_DISPLAY.rotation, [-1, 1, 0.01]);
	
	for( var i = 0; i < 4; i++ )
		kernel_toggle[i] = VCT_var(VALUE_TYPE.boolean, 0);
	for( var i = 0; i < 8; i++ )
		kernel_value[i] = VCT_var(VALUE_TYPE.integer, 1).setDisplay(VALUE_DISPLAY.slider, { range: [1, 4, 1] });
	
	function process() {
		var _dimension = dimension.get();
		var _dim = _dimension == 0? 8 : 16;
		var surf = surface_create(_dim, _dim);
		var shap = surface_create(_dim, _dim);
		
		var _shape = shape.get();
		var _posx  = shape_par[0].get();
		var _posy  = shape_par[1].get();
		var _scax  = shape_par[2].get();
		var _scay  = shape_par[3].get();
		var _shrx  = shape_par[4].get();
		var _shry  = shape_par[5].get();
		
		var _cx = _dim / 2 + _posx - 1;
		var _cy = _dim / 2 - _posy - 1;
		
		surface_set_target(shap);
			DRAW_CLEAR
			
			draw_set_color(c_white);
			
			switch(_shape) {
				case 0 :
					var _x0 = _cx - _scax + 1;
					var _y0 = _cy - _scay + 1;
					var _x1 = _cx + _scax;
					var _y1 = _cy + _scay;
					
					var r = shape_knob[1].get();
					draw_rectangle(_x0, _y0, _x1, _y1, false);
					
					BLEND_SUBTRACT
						switch(r) {
							case 6 : 
							case 5 : 
							case 4 : 
								draw_point(_x0 + 1, _y0 + 1);
								draw_point(_x1 - 1, _y0 + 1);
								draw_point(_x0 + 1, _y1 - 1);
								draw_point(_x1 - 1, _y1 - 1);
							case 3 : 
								draw_point(_x0 + 2, _y0 + 0);
								draw_point(_x0 + 0, _y0 + 2);
								
								draw_point(_x1 - 2, _y0 + 0);
								draw_point(_x1 - 0, _y0 + 2);
								
								draw_point(_x0 + 2, _y1 - 0);
								draw_point(_x0 + 0, _y1 - 2);
								
								draw_point(_x1 - 2, _y1 - 0);
								draw_point(_x1 - 0, _y1 - 2);
							case 2 : 	
								draw_point(_x0 + 1, _y0 + 0);
								draw_point(_x0 + 0, _y0 + 1);
								
								draw_point(_x1 - 1, _y0 + 0);
								draw_point(_x1 + 0, _y0 + 1);
								
								draw_point(_x0 + 1, _y1 + 0);
								draw_point(_x0 + 0, _y1 - 1);
								
								draw_point(_x1 - 1, _y1 + 0);
								draw_point(_x1 + 0, _y1 - 1);
							case 1 : 	
								draw_point(_x0, _y0);
								draw_point(_x1, _y0);
								draw_point(_x0, _y1);
								draw_point(_x1, _y1);
								break;
						}
					BLEND_NORMAL
					break;
				case 1 :
					draw_ellipse(_cx - _scax, _cy - _scay, _cx + _scax, _cy + _scay, false);
					break;
				case 2 :
					var rt = shape_knob[1].get();
					var rb = shape_knob[2].get();
					
					var _x0 = _cx - _scax + 1;
					var _y0 = _cy - _scay + 1;
					var _x1 = _cx + _scax;
					var _y1 = _cy + _scay;
					
					draw_rectangle(_x0, _y0, _x1, _y1, false);
					
					BLEND_SUBTRACT
						switch(rt) {
							case 6 : 
								draw_point(_x0 + 0, _y0 + 3);
								draw_point(_x1 + 0, _y0 + 3);
							case 5 : 
								draw_point(_x0 + 1, _y0 + 1);
								draw_point(_x1 - 1, _y0 + 1);
							case 4 : 
								draw_point(_x0 + 2, _y0 + 0);
								draw_point(_x1 - 2, _y0 + 0);
							case 3 : 
								draw_point(_x0 + 0, _y0 + 2);
								draw_point(_x1 + 0, _y0 + 2);
							case 2 : 	
								draw_point(_x0 + 1, _y0 + 0);
								draw_point(_x0 + 0, _y0 + 1);
								
								draw_point(_x1 - 1, _y0 + 0);
								draw_point(_x1 + 0, _y0 + 1);
							case 1 : 	
								draw_point(_x0, _y0);
								draw_point(_x1, _y0);
						}
						
						switch(rb) {
							case 6 :
							case 5 :
							case 4 :
							case 3 :
								draw_point(_x0 + 1, _y1 - 0);
								draw_point(_x1 - 1, _y1 - 0);
							case 2 :
								draw_point(_x0 + 0, _y1 - 1);
								draw_point(_x1 + 0, _y1 - 1);
							case 1 : 
								draw_point(_x0, _y1);
								draw_point(_x1, _y1);
						}
					BLEND_NORMAL
					break;
				case 3 :
					var angle = shape_knob[0].get() / 8 * 180;
					draw_line_width(_cx - lengthdir_x(_dim * 2, angle), _cy - lengthdir_y(_dim * 2, angle), 
								    _cx + lengthdir_x(_dim * 2, angle), _cy + lengthdir_y(_dim * 2, angle), _scax * 2);
					break;
				case 4 :
					for( var i = 0; i < _dim; i++ ) 
					for( var j = 0; j < _dim; j++ ) {
						if((i + j) % 2) draw_point(i, j);
					}
					break;
			}
		surface_reset_target();
		
		surface_set_target(surf);
			DRAW_CLEAR
			if(_shape == 3) {
				var ang = shape_knob[0].get() / 8 * 360;
				var p   = point_rotate(0, 0, _dim / 2, _dim / 2, ang);
				draw_surface_ext_safe(shap, p[0], p[1], 1, 1, ang, c_white, 1);
			} else
				draw_surface(shap, 0, 0);
		surface_reset_target();
		
		surface_free(shap);
		
		return surf;
	}
}

function Biterator_Panel(vct) : PanelVCT(vct) constructor {
	title = "Biterator";
	w = ui(608);
	h = ui(462);
	
	page = 0;
	
	slider_shape = array_create(6, 0);
	slider_kernel= array_create(8, 0);
	knob_shape   = array_create(3, 0);
	knob_color   = array_create(2, 0);
	
	function drawContent(panel) {
		sprite_scale = 2;
		
		draw_clear(c_white);
		
		draw_sprite_ext(s_biterator_bg, 0, 0, 0, 2, 2, 0, c_white, 1);
		BLEND_ADD
			draw_sprite_ext(s_biterator_bg, 1, 0, 0, 2, 2, 0, c_white, 0.5);
		BLEND_NORMAL
		draw_sprite_ext(s_biterator_tab_content, page, 129 * 2, 115 * 2, 2, 2, 0, c_white, 1);
		draw_sprite_ext(s_biterator_canvas, 0, 105 * 2, 21 * 2, 2, 2, 0, c_white, 1);
		
		var s = vct.process();
		draw_surface_stretched(s, (105 + 2) * 2, (21 + 3) * 2, 80 * 2, 80 * 2);
		
		draw_sprite_ext(s_biterator_canvas_cover, vct.dimension.get(), 105 * 2, 21 * 2, 2, 2, 0, c_white, 1);
		
		for( var i = 0; i < 5; i++ ) {
			var bx = 13 * 2 + 32 * i;
			var by = 12 * 2;
			
			if(vct_button(bx, by, false, [ vct.shape.get() == i? s_biterator_b_shape_press : s_biterator_b_shape_idle, s_biterator_b_shape_press ], i))
				vct.shape.set(i);
		}
		
		#region settings
			var kx = vct.dimension.get()? 246 * 2 : 210 * 2;
			var ky = 50 * 2;
			draw_sprite_ext(s_biterator_b_grey_long, 0, kx, ky, 2, 2, 0, c_white, 1);
			
			if(vct_button(kx, ky, false, s_biterator_b_grey_long,, s_biterator_dim_label, vct.dimension.get()))
				vct.dimension.set(!vct.dimension.get());
			
			var kx = 210 * 2;
			var ky =  74 * 2;
			if(vct_button(kx, ky, false, s_biterator_b_grey_short,, s_biterator_b_labels, 0))
				vct.reset();
			
			var kx = 237 * 2;
			var ky =  74 * 2;
			if(vct_button(kx, ky, false, s_biterator_b_grey_short,, s_biterator_b_labels, 1))
				vct.reset();
			
			var kx = 264 * 2;
			var ky =  74 * 2;
			if(vct_button(kx, ky, false, s_biterator_b_grey_short,, s_biterator_b_labels, 2))
				vct.reset();
		#endregion
		
		#region shape
			for( var i = 0; i < 3; i++ ) {
				var kx = (33 + 18 * i) * 2;
				var ky = 41 * 2;
				knob_shape[i] = vct_knob(knob_shape[i], s_biterator_knob, kx, ky, vct.shape_knob[i]);
			}
			
			for( var i = 0; i < 6; i++ ) {
				var sx = (20 + 13 * i) * 2;
				var sy = 94 * 2;
				var ex = sx;
				var ey = 57 * 2;
				slider_shape[i] = vct_slider(slider_shape[i], s_biterator_slider, sx, sy, ex, ey, vct.shape_par[i]);
			}
		#endregion
		
		#region color
			//var col = vct.color[0].get();
			
			for( var i = 0; i < 2; i++ ) {
				var kx = (40 + 25 * i) * 2;
				var ky = 208 * 2;
				knob_color[i] = vct_knob(knob_color[i], s_biterator_knob, kx, ky, vct.color_knob[i]);
			}
		#endregion
		
		#region pages
			for( var i = 0; i < 4; i++ ) {
				var kx = 102 * 2;
				var ky = (115 + 27 * i) * 2;
				
				var ss = i == page? s_biterator_tab_active : s_biterator_tab_inactive;
				if(vct_button(kx, ky, true, [ss, s_biterator_tab_active], i))
					page = i;
			}
			
		#endregion
		
		if(page == 0) { #region kernel
			for( var i = 0; i < 4; i++ ) {
				var kx = (141 + 39 * i) * 2;
				var ky = 122 * 2;
				vct_toggle(s_biterator_toggler, kx, ky, vct.kernel_toggle[i]);
				
				var sx = (145 + 39 * i) * 2;
				var sy = 215 * 2;
				var ex = sx;
				var ey = 178 * 2;
				slider_kernel[i * 2 + 0] = vct_slider(slider_kernel[i * 2 + 0], s_biterator_slider, sx, sy, ex, ey, vct.kernel_value[i * 2 + 0]);
				
				var sx = (162 + 39 * i) * 2;
				var ex = sx;
				slider_kernel[i * 2 + 1] = vct_slider(slider_kernel[i * 2 + 1], s_biterator_slider, sx, sy, ex, ey, vct.kernel_value[i * 2 + 1]);
			}
		#endregion
		}
	}
}