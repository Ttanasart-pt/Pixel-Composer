function Node_Biterator(_x, _y, _group = noone) : Node_VCT(_x, _y, _group) constructor {
	name = "Biterator";
	vct  = new Biterator(self);
}

function Biterator(node) : VCT(node) constructor {
	panel = Biterator_Panel;
	
	dimension = VCT_var(VALUE_TYPE.integer, 0);
	shape	  = VCT_var(VALUE_TYPE.integer, 0);
	pos_x	  = VCT_var(VALUE_TYPE.integer, 0);
	pos_y	  = VCT_var(VALUE_TYPE.integer, 0);
	sca_x	  = VCT_var(VALUE_TYPE.integer, 0);
	sca_y	  = VCT_var(VALUE_TYPE.integer, 0);
	
	function process() {
		var _dimension = dimension.get();
		var _dim = _dimension == 0? 8 : 16;
		var surf = surface_create(_dim, _dim);
		
		surface_set_target(surf);
			DRAW_CLEAR
		surface_reset_target();
		
		return surf;
	}
}

function Biterator_Panel(vct) : PanelVCT(vct) constructor {
	title = "Biterator";
	w = ui(608);
	h = ui(462);
	
	page = 0;
	
	function drawContent(panel) {
		draw_clear(c_white);
		
		draw_sprite_ext(s_biterator_bg, 0, 0, 0, 2, 2, 0, c_white, 1);
		draw_sprite_ext(s_biterator_tab_content, page, 129 * 2, 115 * 2, 2, 2, 0, c_white, 1);
		draw_sprite_ext(s_biterator_canvas, vct.dimension.get(), 105 * 2, 21 * 2, 2, 2, 0, c_white, 1);
		
		for( var i = 0; i < 5; i++ ) {
			var bx = 13 * 2 + 32 * i;
			var by = 12 * 2;
			
			if(vct_button(bx, by, [ vct.shape.get() == i? s_biterator_b_shape_press : s_biterator_b_shape_idle, s_biterator_b_shape_press ], i))
				vct.shape.set(i);
		}
		
		#region settings
			var kx = vct.dimension.get()? 246 * 2 : 210 * 2;
			var ky = 50 * 2;
			draw_sprite_ext(s_biterator_b_grey_long, 0, kx, ky, 2, 2, 0, c_white, 1);
			
			if(vct_button(kx, ky, s_biterator_b_grey_long,, s_biterator_dim_label, vct.dimension.get()))
				vct.dimension.set(!vct.dimension.get());
			
			var kx = 210 * 2;
			var ky =  74 * 2;
			if(vct_button(kx, ky, s_biterator_b_grey_short,, s_biterator_b_labels, 0))
				vct.reset();
			
			var kx = 237 * 2;
			var ky =  74 * 2;
			if(vct_button(kx, ky, s_biterator_b_grey_short,, s_biterator_b_labels, 1))
				vct.reset();
			
			var kx = 264 * 2;
			var ky =  74 * 2;
			if(vct_button(kx, ky, s_biterator_b_grey_short,, s_biterator_b_labels, 2))
				vct.reset();
		#endregion
		
		#region shape
			var kx = 33 * 2;
			var ky = 41 * 2;
			draw_sprite_ext(s_biterator_knob, 0, kx, ky, 2, 2, 0, c_white, 1);
		
			var kx = 51 * 2;
			var ky = 41 * 2;
			draw_sprite_ext(s_biterator_knob, 0, kx, ky, 2, 2, 0, c_white, 1);
		
			var kx = 69 * 2;
			var ky = 41 * 2;
			draw_sprite_ext(s_biterator_knob, 0, kx, ky, 2, 2, 0, c_white, 1);
			
			var kx = 20 * 2;
			var ky = 63 * 2;
			draw_sprite_ext(s_biterator_slider, 0, kx, ky, 2, 2, 0, c_white, 1);
		
			var kx = 33 * 2;
			var ky = 63 * 2;
			draw_sprite_ext(s_biterator_slider, 0, kx, ky, 2, 2, 0, c_white, 1);
		
			var kx = 46 * 2;
			var ky = 63 * 2;
			draw_sprite_ext(s_biterator_slider, 0, kx, ky, 2, 2, 0, c_white, 1);
		
			var kx = 59 * 2;
			var ky = 63 * 2;
			draw_sprite_ext(s_biterator_slider, 0, kx, ky, 2, 2, 0, c_white, 1);
		
			var kx = 72 * 2;
			var ky = 63 * 2;
			draw_sprite_ext(s_biterator_slider, 0, kx, ky, 2, 2, 0, c_white, 1);
		
			var kx = 85 * 2;
			var ky = 63 * 2;
			draw_sprite_ext(s_biterator_slider, 0, kx, ky, 2, 2, 0, c_white, 1);
		#endregion
		
		#region color
			var kx =  40 * 2;
			var ky = 208 * 2;
			draw_sprite_ext(s_biterator_knob, 0, kx, ky, 2, 2, 0, c_white, 1);
			
			var kx =  65 * 2;
			var ky = 208 * 2;
			draw_sprite_ext(s_biterator_knob, 0, kx, ky, 2, 2, 0, c_white, 1);
		#endregion
		
		#region pages
			for( var i = 0; i < 4; i++ ) {
				var kx = 102 * 2;
				var ky = (115 + 27 * i) * 2;
				
				var ss = i == page? s_biterator_tab_active : s_biterator_tab_inactive;
				if(vct_button(kx, ky, [ss, s_biterator_tab_active], i))
					page = i;
			}
			
		#endregion
		
		if(page == 0) { #region kernel
			for( var i = 0; i < 4; i++ ) {
				var kx = (141 + 39 * i) * 2;
				var ky = 122 * 2;
				draw_sprite_ext(s_biterator_toggler, 0, kx, ky, 2, 2, 0, c_white, 1);
				
				var kx = (145 + 39 * i) * 2;
				var ky = 184 * 2;
				draw_sprite_ext(s_biterator_slider, 0, kx, ky, 2, 2, 0, c_white, 1);
				
				var kx = (162 + 39 * i) * 2;
				var ky = 184 * 2;
				draw_sprite_ext(s_biterator_slider, 0, kx, ky, 2, 2, 0, c_white, 1);
			}
		#endregion
		}
	}
}