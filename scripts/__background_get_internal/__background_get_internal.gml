function __background_get_internal(__prop, __bind, __backinfo) {
	if ((__backinfo[0] == -1)
		|| (layer_background_exists(__backinfo[1], __backinfo[0]) == false))	// this can happen when we change between backgrounds and foregrounds (because layers and elements get destroyed)
	{
		// Try getting the background info again from the bind index
		__backinfo = __background_get_element(__bind);
	
		if (__backinfo[0] == -1)	
			return -1;	// erm
	}



	var __res = -1;

	var __backid = __backinfo[0];
	var __layerid = __backinfo[1];
	var __isfore = __backinfo[2];

	switch(__prop)
	{
	case e__BG.Visible: __res = layer_background_get_visible(__backid); break;
	case e__BG.Foreground: __res = __isfore; break;
	case e__BG.Index: __res = layer_background_get_sprite(__backid)  break;
	case e__BG.X: __res = layer_get_x(__layerid); break;
	case e__BG.Y: __res = layer_get_y(__layerid); break;
	case e__BG.Width: __res = sprite_get_width(layer_background_get_index(__backid)); break;
	case e__BG.Height: __res = sprite_get_height(layer_background_get_index(__backid)); break;
	case e__BG.HTiled: __res = layer_background_get_htiled(__backid); break;
	case e__BG.VTiled: __res = layer_background_get_vtiled(__backid); break;
	case e__BG.XScale: __res = layer_background_get_xscale(__backid); break;
	case e__BG.YScale: __res = layer_background_get_yscale(__backid); break;
	case e__BG.HSpeed: __res = layer_get_hspeed(__layerid); break;
	case e__BG.VSpeed: __res = layer_get_vspeed(__layerid); break;
	case e__BG.Blend: __res = layer_background_get_blend(__backid); break;
	case e__BG.Alpha: __res = layer_background_get_alpha(__backid); break;
	default: break;
	};

	return __res;


}
