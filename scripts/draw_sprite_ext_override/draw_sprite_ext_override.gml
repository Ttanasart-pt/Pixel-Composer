#macro draw_sprite_ext draw_sprite_ext_override
#macro __draw_sprite_ext draw_sprite_ext

function draw_sprite_ext_override(spr, ind, _x, _y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1) {
	__draw_sprite_ext(spr, ind, round(_x), round(_y), xscale, yscale, rot, color, alpha);
}

#macro draw_sprite_stretched_ext draw_sprite_stretched_ext_override
#macro __draw_sprite_stretched_ext draw_sprite_stretched_ext

function draw_sprite_stretched_ext_override(spr, ind, _x, _y, w = 1, h = 1, color = c_white, alpha = 1) {
	__draw_sprite_stretched_ext(spr, ind, round(_x), round(_y), round(w), round(h), color, alpha);
}

#macro draw_sprite_stretched draw_sprite_stretched_override
#macro __draw_sprite_stretched draw_sprite_stretched

function draw_sprite_stretched_override(spr, ind, _x, _y, w = 1, h = 1) {
	__draw_sprite_stretched(spr, ind, round(_x), round(_y), round(w), round(h));
}

function draw_sprite_uniform(spr, ind, _x, _y, scale, color = c_white) {
	draw_sprite_ext(spr, ind, round(_x), round(_y), scale, scale, 0, color, 1);
}

function draw_sprite_ui(spr, ind, _x, _y, xscale = 1, yscale = 1, rot = 0, color = c_white, alpha = 1) {
	static UI_SPRITE_SCALE = 2;
	
	var xscale_ui = ui(xscale) / UI_SPRITE_SCALE;
	var yscale_ui = ui(yscale) / UI_SPRITE_SCALE;
	
	draw_sprite_ext(spr, ind, round(_x), round(_y), xscale_ui, yscale_ui, rot, color, alpha);
}

function draw_sprite_ui_uniform(spr, ind, _x, _y, scale = 1, color = c_white, alpha = 1, rot = 0) {
	draw_sprite_ui(spr, ind, round(_x), round(_y), scale, scale, rot, color, alpha);
}

function draw_sprite_colored(spr, ind, _x, _y, scale = 1, rot = 0) {
	var num = sprite_get_number(spr);
	
	draw_sprite_ui(spr, ind, _x, _y, scale, scale, rot, c_white);
	
	if(num % 2 == 0)
		draw_sprite_ui(spr, num / 2 + ind, _x, _y, scale, scale, rot, COLORS._main_accent);
}