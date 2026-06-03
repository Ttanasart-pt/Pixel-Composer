function Panel_CubeMarch_Guide() : PanelContent() constructor {
	title    = "CubeMarch Guide";
	auto_pin = true;
	w = ui(800);
	h = ui(640);
	
	angle      = -30;
	angle_to   = angle;
	flipz      = false;
	marchIndex = 0;
	drawTri    = true;
	
	refCube = new __3dRmCubeMarch();
	
	function drawContent(panel) {
		HOTKEY_BLOCK = true;
		
		var s0 = marchIndex & (1 << 0);
		var s1 = marchIndex & (1 << 1);
		var s2 = marchIndex & (1 << 2);
		var s3 = marchIndex & (1 << 3);
		var s4 = marchIndex & (1 << 4);
		var s5 = marchIndex & (1 << 5);
		var s6 = marchIndex & (1 << 6);
		var s7 = marchIndex & (1 << 7);

		var p0x = w * 2/6, p0y = h * 4/6;
		var p1x = w * 5/6, p1y = h * 4/6;
		var p2x = w * 1/6, p2y = h * 5/6;
		var p3x = w * 4/6, p3y = h * 5/6;
		
		var p4x = w * 2/6, p4y = h * 1/6;
		var p5x = w * 5/6, p5y = h * 1/6;
		var p6x = w * 1/6, p6y = h * 2/6;
		var p7x = w * 4/6, p7y = h * 2/6;
			
			var cx = w / 2;
			var cw = w * 2.5/6;
			var ch = h * 1/6;
			
			var cy = flipz? h * 1.5/6 : h * 4.5/6;
	
			var p0x = cx + lengthdir_x(cw, 135 + angle), p0y = cy + lengthdir_y(ch, 135 + angle);
			var p1x = cx + lengthdir_x(cw,  45 + angle), p1y = cy + lengthdir_y(ch,  45 + angle);
			var p2x = cx + lengthdir_x(cw, 225 + angle), p2y = cy + lengthdir_y(ch, 225 + angle);
			var p3x = cx + lengthdir_x(cw, 315 + angle), p3y = cy + lengthdir_y(ch, 315 + angle);
			
			var cy = flipz? h * 4.5/6 : h * 1.5/6;
			
			var p4x = cx + lengthdir_x(cw, 135 + angle), p4y = cy + lengthdir_y(ch, 135 + angle);
			var p5x = cx + lengthdir_x(cw,  45 + angle), p5y = cy + lengthdir_y(ch,  45 + angle);
			var p6x = cx + lengthdir_x(cw, 225 + angle), p6y = cy + lengthdir_y(ch, 225 + angle);
			var p7x = cx + lengthdir_x(cw, 315 + angle), p7y = cy + lengthdir_y(ch, 315 + angle);
			
		var p01x = (p0x + p1x) / 2, p01y = (p0y + p1y) / 2;
		var p02x = (p0x + p2x) / 2, p02y = (p0y + p2y) / 2;
		var p13x = (p3x + p1x) / 2, p13y = (p3y + p1y) / 2;
		var p23x = (p3x + p2x) / 2, p23y = (p3y + p2y) / 2;
		
		var p45x = (p4x + p5x) / 2, p45y = (p4y + p5y) / 2;
		var p46x = (p4x + p6x) / 2, p46y = (p4y + p6y) / 2;
		var p57x = (p7x + p5x) / 2, p57y = (p7y + p5y) / 2;
		var p67x = (p7x + p6x) / 2, p67y = (p7y + p6y) / 2;
		
		var p04x = (p0x + p4x) / 2, p04y = (p0y + p4y) / 2;
		var p15x = (p1x + p5x) / 2, p15y = (p1y + p5y) / 2;
		var p26x = (p2x + p6x) / 2, p26y = (p2y + p6y) / 2;
		var p37x = (p3x + p7x) / 2, p37y = (p3y + p7y) / 2;
		
		#region triangls
			var _tind = (marchIndex >= 128)? 127 - (marchIndex - 128) : marchIndex;
			var _tris = refCube.triTables[_tind];
			var edges = [];
			
			edges[ 0] = [ p04x, p04y ];
			edges[ 1] = [ p15x, p15y ];
			edges[ 2] = [ p26x, p26y ];
			edges[ 3] = [ p37x, p37y ];
			
			edges[ 4] = [ p01x, p01y ];
			edges[ 5] = [ p02x, p02y ];
			edges[ 6] = [ p13x, p13y ];
			edges[ 7] = [ p23x, p23y ];
			
			edges[ 8] = [ p45x, p45y ];
			edges[ 9] = [ p46x, p46y ];
			edges[10] = [ p57x, p57y ];
			edges[11] = [ p67x, p67y ];
			
			if(drawTri) {
				for( var i = 0, n = array_length(_tris); i < n; i += 3 ) {
					var ei0 = _tris[i+0];
					var ei1 = _tris[i+1];
					var ei2 = _tris[i+2];
					
					var ei0x = edges[ei0][0];
					var ei0y = edges[ei0][1];
					var ei1x = edges[ei1][0];
					var ei1y = edges[ei1][1];
					var ei2x = edges[ei2][0];
					var ei2y = edges[ei2][1];
					
					var ccw = ((ei1x - ei0x) * (ei2y - ei0y) - (ei2x - ei0x) * (ei1y - ei0y)) > 0;
					
					draw_set_color_alpha(ccw? CDEF.blue : CDEF.red, .4);
					draw_triangle(ei0x, ei0y, ei1x, ei1y, ei2x, ei2y, false);
					draw_set_alpha(1);
				}
				
				for( var i = 0, n = array_length(_tris); i < n; i += 3 ) {
					var ei0 = _tris[i+0];
					var ei1 = _tris[i+1];
					var ei2 = _tris[i+2];
					
					draw_set_color_alpha(CDEF.white);
					draw_triangle(edges[ei0][0], edges[ei0][1], edges[ei1][0], edges[ei1][1], edges[ei2][0], edges[ei2][1], true);
					draw_set_alpha(1);
				}
			}
		#endregion
		
		#region lines
		draw_set_color(COLORS._main_icon);
			draw_set_alpha(.5 + .5 * s0) draw_line(p0x, p0y, p01x, p01y);
			draw_set_alpha(.5 + .5 * s1) draw_line(p1x, p1y, p01x, p01y);
			
			draw_set_alpha(.5 + .5 * s0) draw_line(p0x, p0y, p02x, p02y);
			draw_set_alpha(.5 + .5 * s2) draw_line(p2x, p2y, p02x, p02y);
			
			draw_set_alpha(.5 + .5 * s1) draw_line(p1x, p1y, p13x, p13y);
			draw_set_alpha(.5 + .5 * s3) draw_line(p3x, p3y, p13x, p13y);
			
			draw_set_alpha(.5 + .5 * s2) draw_line(p2x, p2y, p23x, p23y);
			draw_set_alpha(.5 + .5 * s3) draw_line(p3x, p3y, p23x, p23y);
			
			
			draw_set_alpha(.5 + .5 * s4) draw_line(p4x, p4y, p45x, p45y);
			draw_set_alpha(.5 + .5 * s5) draw_line(p5x, p5y, p45x, p45y);
			
			draw_set_alpha(.5 + .5 * s4) draw_line(p4x, p4y, p46x, p46y);
			draw_set_alpha(.5 + .5 * s6) draw_line(p6x, p6y, p46x, p46y);
			
			draw_set_alpha(.5 + .5 * s5) draw_line(p5x, p5y, p57x, p57y);
			draw_set_alpha(.5 + .5 * s7) draw_line(p7x, p7y, p57x, p57y);
			
			draw_set_alpha(.5 + .5 * s6) draw_line(p6x, p6y, p67x, p67y);
			draw_set_alpha(.5 + .5 * s7) draw_line(p7x, p7y, p67x, p67y);
			
			
			draw_set_alpha(.5 + .5 * s0) draw_line(p0x, p0y, p04x, p04y);
			draw_set_alpha(.5 + .5 * s4) draw_line(p4x, p4y, p04x, p04y);
			
			draw_set_alpha(.5 + .5 * s1) draw_line(p1x, p1y, p15x, p15y);
			draw_set_alpha(.5 + .5 * s5) draw_line(p5x, p5y, p15x, p15y);
			
			draw_set_alpha(.5 + .5 * s2) draw_line(p2x, p2y, p26x, p26y);
			draw_set_alpha(.5 + .5 * s6) draw_line(p6x, p6y, p26x, p26y);
			
			draw_set_alpha(.5 + .5 * s3) draw_line(p3x, p3y, p37x, p37y);
			draw_set_alpha(.5 + .5 * s7) draw_line(p7x, p7y, p37x, p37y);
		draw_set_alpha(1);
		#endregion
		
		#region markers
			BLEND_SUBTRACT
			draw_set_color(c_white);
			draw_circle(p0x, p0y, ui(16), false);
			draw_circle(p1x, p1y, ui(16), false);
			draw_circle(p2x, p2y, ui(16), false);
			draw_circle(p3x, p3y, ui(16), false);
			
			draw_circle(p4x, p4y, ui(16), false);
			draw_circle(p5x, p5y, ui(16), false);
			draw_circle(p6x, p6y, ui(16), false);
			draw_circle(p7x, p7y, ui(16), false);
			BLEND_NORMAL
			
			var ca  = COLORS._main_accent;
			var ct0 = COLORS._main_text_on_accent;
			var ct1 = COLORS._main_text_sub;
			
			draw_set_text(f_p1, fa_center, fa_center);
			draw_set_color(ca) if(s0) draw_circle(p0x, p0y, ui(12), 0); draw_set_color(s0? ct0 : ct1) draw_text_add(p0x, p0y, "0");
			draw_set_color(ca) if(s1) draw_circle(p1x, p1y, ui(12), 0); draw_set_color(s1? ct0 : ct1) draw_text_add(p1x, p1y, "1");
			draw_set_color(ca) if(s2) draw_circle(p2x, p2y, ui(12), 0); draw_set_color(s2? ct0 : ct1) draw_text_add(p2x, p2y, "2");
			draw_set_color(ca) if(s3) draw_circle(p3x, p3y, ui(12), 0); draw_set_color(s3? ct0 : ct1) draw_text_add(p3x, p3y, "3");
			
			draw_set_color(ca) if(s4) draw_circle(p4x, p4y, ui(12), 0); draw_set_color(s4? ct0 : ct1) draw_text_add(p4x, p4y, "4");
			draw_set_color(ca) if(s5) draw_circle(p5x, p5y, ui(12), 0); draw_set_color(s5? ct0 : ct1) draw_text_add(p5x, p5y, "5");
			draw_set_color(ca) if(s6) draw_circle(p6x, p6y, ui(12), 0); draw_set_color(s6? ct0 : ct1) draw_text_add(p6x, p6y, "6");
			draw_set_color(ca) if(s7) draw_circle(p7x, p7y, ui(12), 0); draw_set_color(s7? ct0 : ct1) draw_text_add(p7x, p7y, "7");
			
			var ci = COLORS._main_icon_dark;
			var ct = COLORS._main_text_accent;
			
			draw_set_text(f_p1b, fa_center, fa_center);
			if(s0 ^^ s4) { draw_set_color(ci) draw_circle(p04x, p04y, ui(12), 0); draw_set_color(ct) draw_text_add(p04x, p04y, "0"); }
			if(s1 ^^ s5) { draw_set_color(ci) draw_circle(p15x, p15y, ui(12), 0); draw_set_color(ct) draw_text_add(p15x, p15y, "1"); }
			if(s2 ^^ s6) { draw_set_color(ci) draw_circle(p26x, p26y, ui(12), 0); draw_set_color(ct) draw_text_add(p26x, p26y, "2"); }
			if(s3 ^^ s7) { draw_set_color(ci) draw_circle(p37x, p37y, ui(12), 0); draw_set_color(ct) draw_text_add(p37x, p37y, "3"); }
			
			if(s0 ^^ s1) { draw_set_color(ci) draw_circle(p01x, p01y, ui(12), 0); draw_set_color(ct) draw_text_add(p01x, p01y, "4"); }
			if(s0 ^^ s2) { draw_set_color(ci) draw_circle(p02x, p02y, ui(12), 0); draw_set_color(ct) draw_text_add(p02x, p02y, "5"); }
			if(s1 ^^ s3) { draw_set_color(ci) draw_circle(p13x, p13y, ui(12), 0); draw_set_color(ct) draw_text_add(p13x, p13y, "6"); }
			if(s2 ^^ s3) { draw_set_color(ci) draw_circle(p23x, p23y, ui(12), 0); draw_set_color(ct) draw_text_add(p23x, p23y, "7"); }
			
			if(s4 ^^ s5) { draw_set_color(ci) draw_circle(p45x, p45y, ui(12), 0); draw_set_color(ct) draw_text_add(p45x, p45y, "8"); }
			if(s4 ^^ s6) { draw_set_color(ci) draw_circle(p46x, p46y, ui(12), 0); draw_set_color(ct) draw_text_add(p46x, p46y, "9"); }
			if(s5 ^^ s7) { draw_set_color(ci) draw_circle(p57x, p57y, ui(12), 0); draw_set_color(ct) draw_text_add(p57x, p57y, "10"); }
			if(s6 ^^ s7) { draw_set_color(ci) draw_circle(p67x, p67y, ui(12), 0); draw_set_color(ct) draw_text_add(p67x, p67y, "11"); }
		#endregion
		
		draw_set_text(f_h3, fa_left, fa_top, COLORS._main_text);
		draw_text_add(ui(16), ui(10), marchIndex);
		
		draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_add(ui(16), ui(48), $"{angle_to} {flipz? "[Z flip]" : ""}");
		
		if(key_press(vk_left))  
			marchIndex = (marchIndex - 1 + 256) % 256;
		if(key_press(vk_right) || key_press(vk_space)) 
			marchIndex = (marchIndex + 1 + 256) % 256;
			
		if(key_press(ord("Z"))) flipz   = !flipz;
		if(key_press(ord("T"))) drawTri = !drawTri;
			
		angle_to += MOUSE_WHEEL * 5;
		angle = lerp_float(angle, angle_to, 3)
	}
}