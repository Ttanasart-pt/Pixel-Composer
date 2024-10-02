#region enums
	
#endregion

#region macro
	#macro BLEND_NORMAL		gpu_set_blendmode(bm_normal); gpu_set_blendequation(bm_eq_add);
	#macro BLEND_ADD		gpu_set_blendmode(bm_add);
	#macro BLEND_OVERRIDE	gpu_set_blendmode_ext(bm_one, bm_zero);
	//#macro BLEND_ADD_ALPHA	gpu_set_blendmode_ext_sepalpha(bm_one, bm_inv_src_alpha, bm_one, bm_one)
		
	#macro BLEND_ALPHA		gpu_set_blendmode_ext_sepalpha(bm_one, bm_inv_src_alpha, bm_one, bm_one);
	#macro BLEND_ALPHA_MULP gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one);
	#macro BLEND_MAX        gpu_set_blendmode(bm_normal); gpu_set_blendequation(bm_eq_max);
	
	#macro BLEND_MULTIPLY	gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
	#macro BLEND_SUBTRACT	gpu_set_blendmode(bm_subtract);
	
	#macro DRAW_CLEAR draw_clear_alpha(0, 0);
#endregion