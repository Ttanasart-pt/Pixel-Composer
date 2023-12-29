/// @description Insert description here
/*
draw_set_color(c_white);
draw_set_alpha(1);
for( var i = 0; i < numParticles; i++ ) {
	var _x = particlePos[i * 2];
	var _y = particlePos[i * 2 + 1];
	
	draw_circle(dx + _x, dy + _y, particleRadius * 1, false);
	//draw_point(_x, _y);
}

obstracles[0].draw();
obstracles[1].draw();

draw_set_color(c_white);
draw_set_halign(fa_right);
draw_text(room_width - 16, 16, fps_real);