/// @description Insert description here
if(mouse_press(mb_middle)) anim = 0; 

prog = lerp_linear(prog, anim, 0.05);
if(prog == 0) instance_destroy();

surface = surface_verify(surface, w, h);
surface_set_target(surface);
	DRAW_CLEAR
	
	draw_sprite_stretched_ext(s_dialog_bg_l, 0, 0, 0, w, h, c_white, .99);
	draw_sprite(s_icon_64, 0, h / 2, h / 2);

	draw_set_text(f_h2, fa_left, fa_bottom, c_white);
	draw_text(210, h / 2 + 12, "Pixel Composer");

	draw_set_text(f_h3, fa_left, fa_top, c_white);
	draw_set_alpha(0.7);
	draw_text(210, h / 2 + 10, "Tutorial 20: 3D in 1.16");
	draw_set_alpha(1);
	
surface_reset_target();

x0 = WIN_W / 2 - w / 2;
y0 = WIN_H / 2 - h / 2 - (1 - prog) * 128;

draw_surface_ext(surface, x0, y0, 1, 1, 0, c_white, animation_curve_eval(ac_disappear, prog));