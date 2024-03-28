#macro draw_sprite_ext draw_sprite_ext_override
#macro __draw_sprite_ext draw_sprite_ext

function draw_sprite_ext_override(spr, ind, _x, _y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1) { #region
	INLINE
	__draw_sprite_ext(spr, ind, round(_x), round(_y), xscale, yscale, rot, color, alpha);
} #endregion

#macro draw_sprite_stretched_ext draw_sprite_stretched_ext_override
#macro __draw_sprite_stretched_ext draw_sprite_stretched_ext

function draw_sprite_stretched_ext_override(spr, ind, _x, _y, w = 1, h = 1, color = c_white, alpha = 1) { #region
	INLINE
	__draw_sprite_stretched_ext(spr, ind, round(_x), round(_y), round(w), round(h), color, alpha);
} #endregion

#macro draw_sprite_stretched draw_sprite_stretched_override
#macro __draw_sprite_stretched draw_sprite_stretched

function draw_sprite_stretched_override(spr, ind, _x, _y, w = 1, h = 1) { #region
	INLINE
	__draw_sprite_stretched(spr, ind, round(_x), round(_y), round(w), round(h));
} #endregion

function draw_sprite_ext_add(spr, ind, _x, _y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1) { #region
	INLINE
	BLEND_ADD
	__draw_sprite_ext(spr, ind, round(_x), round(_y), xscale, yscale, rot, color, alpha);
	BLEND_NORMAL
} #endregion

function draw_sprite_stretched_points(spr, ind, _x0, _y0, _x1, _y1, color = c_white, alpha = 1) { #region
	INLINE
	
	var _xs = min(_x0, _x1);
	var _ys = min(_y0, _y1);
	var _w  = max(_x0, _x1) - _xs;
	var _h  = max(_y0, _y1) - _ys;
	
	__draw_sprite_stretched_ext(spr, ind, _xs, _ys, _w, _h, color, alpha);
} #endregion

function draw_sprite_stretched_points_clamp(spr, ind, _x0, _y0, _x1, _y1, color = c_white, alpha = 1, _min = 12) { #region
	INLINE
	
	var _xs = min(_x0, _x1);
	var _ys = min(_y0, _y1);
	var _w  = max(_min, max(_x0, _x1) - _xs);
	var _h  = max(_min, max(_y0, _y1) - _ys);
	
	__draw_sprite_stretched_ext(spr, ind, _xs, _ys, _w, _h, color, alpha);
} #endregion

function draw_sprite_bbox(spr, ind, _bbox) { #region
	INLINE
	if(_bbox == noone) return;
	__draw_sprite_stretched(spr, ind, _bbox.x0, _bbox.y0, _bbox.w, _bbox.h);
} #endregion

function draw_sprite_uniform(spr, ind, _x, _y, scale, color = c_white) { #region
	INLINE
	draw_sprite_ext(spr, ind, _x, _y, scale, scale, 0, color, 1);
} #endregion

function draw_sprite_ui(spr, ind, _x, _y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1) { #region
	INLINE
	draw_sprite_ext(spr, ind, _x, _y, xscale * UI_SCALE, yscale * UI_SCALE, rot, color, alpha);
} #endregion

function draw_sprite_ui_uniform(spr, ind, _x, _y, scale = 1, color = c_white, alpha = 1, rot = 0) { #region
	INLINE
	draw_sprite_ui(spr, ind, _x, _y, scale, scale, rot, color, alpha);
} #endregion

function draw_sprite_colored(spr, ind, _x, _y, scale = 1, rot = 0, color = COLORS._main_accent) { #region
	INLINE
	var num = sprite_get_number(spr);
	
	draw_sprite_ui(spr, ind, _x, _y, scale, scale, rot, c_white);
	if(num % 2 == 0) draw_sprite_ui(spr, num / 2 + ind, _x, _y, scale, scale, rot, color);
} #endregion
	
function draw_anchor(_index, _x, _y, _r) { #region
	shader_set(sh_node_widget_scalar);
		shader_set_color("color", COLORS._main_accent);
		shader_set_f("index",     _index);
		
		draw_sprite_stretched(s_fx_pixel, 0, _x - _r, _y - _r, _r * 2, _r * 2);
	shader_reset();
} #endregion
	
function draw_anchor_cross(_index, _x, _y, _r) { #region
	shader_set(sh_node_widget_scalar_cross);
		shader_set_color("color", COLORS._main_accent);
		shader_set_f("index",     _index);
		
		draw_sprite_stretched(s_fx_pixel, 0, _x - _r, _y - _r, _r * 2, _r * 2);
	shader_reset();
} #endregion
	
function draw_anchor_line(_index, _x, _y, _r, _a) { #region
	shader_set(sh_node_widget_scalar_line);
		shader_set_color("color", COLORS._main_accent);
		shader_set_f("index",     _index);
		shader_set_f("angle",     degtorad(_a));
		
		draw_sprite_stretched(s_fx_pixel, 0, _x - _r, _y - _r, _r * 2, _r * 2);
	shader_reset();
} #endregion