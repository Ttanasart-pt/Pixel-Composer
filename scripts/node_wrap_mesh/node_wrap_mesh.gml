function Node_create_Mesh_Warp(_x, _y) {
	var node = new Node_Mesh_Warp(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Mesh_Warp(_x, _y) : Node(_x, _y) constructor {
	name = "Mesh warp";
	
	data = {
		points : [[]],
		tris   : ds_list_create(),
		links  : ds_list_create()
	}
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Sample size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 2] = nodeValue(2, "Spring force", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ] );
	
	inputs[| 3] = nodeValue(3, "Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { setTriangle(); doUpdate(); }, "Generate"] );
	
	control_index = ds_list_size(inputs);
	
	function createControl() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue(index, "Control point range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16, 8, 0, 32])
			.setDisplay(VALUE_DISPLAY.puppet_control)
			.setVisible(false);
		
		return inputs[| index];
	}
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	outputs[| 1] = nodeValue(1, "Mesh data", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, data);
	
	tools = [
		[ "Add / Remove control point",  s_control_edit ]
	];
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		for(var i = 0; i < ds_list_size(data.tris); i++) {
			data.tris[| i].drawPoints(_x, _y, _s);
		}
		
		var hover = -1;
		for(var i = control_index; i < ds_list_size(inputs); i++) {
			if(inputs[| i].drawOverlay(_active, _x, _y, _s, _mx, _my))
				hover = i;
		}
		
		if(_active && PANEL_PREVIEW.tool_index == 0) {
			if(mouse_check_button_pressed(mb_left)) {
				if(hover == -1) {
					var i = createControl();
					i.setValue( [(_mx - _x) / _s, (_my - _y) / _s, 0, 0, 8] );
					i.drag_type = 2;
					i.drag_sx   = 0;
					i.drag_sy   = 0;
					i.drag_mx   = _mx;
					i.drag_my   = _my;
				} else {
					ds_list_delete(inputs, hover);	
				}
				
				reset();
				control();
			}
		}
	}
	
	function point(_x, _y) constructor {
		x = _x;
		y = _y;
		xp = x;
		yp = y;
		
		sx = x;
		sy = y;
		
		static reset = function() {
			x = sx;
			y = sy;
			xp = x;
			yp = y;
		}
		
		static draw = function() {
			draw_set_color(c_white);
			draw_circle(x, y, 4, false);
		}
		
		u = 0;
		v = 0;
		static mapTexture = function(ww, hh) {
			u = x / ww;
			v = y / hh;
		}
	}
	
	function link(_p0, _p1) constructor {
		p0 = _p0;
		p1 = _p1;
		k  = 1;
	
		len = point_distance(p0.x, p0.y, p1.x, p1.y);
		
		static resolve = function() {
			var _len = point_distance(p0.x, p0.y, p1.x, p1.y);
			var _dir = point_direction(p0.x, p0.y, p1.x, p1.y);
		
			var f  = k * (_len - len);
			var dx = lengthdir_x(f, _dir);
			var dy = lengthdir_y(f, _dir);
		
			p0.x += dx / 2;
			p0.y += dy / 2;
		
			p1.x -= dx / 2;
			p1.y -= dy / 2;
		}
	}
	
	function triangle(_p0, _p1, _p2) constructor {
		p0 = _p0;
		p1 = _p1;
		p2 = _p2;
		
		static reset = function() {
			p0.reset();
			p1.reset();
			p2.reset();
		}
		
		static initSurface = function(surf) {
			p0.mapTexture(surface_get_width(surf), surface_get_height(surf));
			p1.mapTexture(surface_get_width(surf), surface_get_height(surf));
			p2.mapTexture(surface_get_width(surf), surface_get_height(surf));	
		}
		
		static drawSurface = function(surf) {
			draw_set_color(c_white);
			draw_set_alpha(1);
			
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(surf));
			draw_vertex_texture(p0.x, p0.y, p0.u, p0.v);
			draw_vertex_texture(p1.x, p1.y, p1.u, p1.v);
			draw_vertex_texture(p2.x, p2.y, p2.u, p2.v);
			draw_primitive_end();
		}
		
		static drawPoints = function(_x, _y, _s) {
			draw_set_color(c_ui_blue_dkgrey);
			draw_line(_x + p0.x * _s, _y + p0.y * _s, _x + p1.x * _s, _y + p1.y * _s);
			draw_line(_x + p0.x * _s, _y + p0.y * _s, _x + p2.x * _s, _y + p2.y * _s);
			draw_line(_x + p1.x * _s, _y + p1.y * _s, _x + p2.x * _s, _y + p2.y * _s);
			
			draw_set_color(c_ui_blue_grey);
			draw_circle(_x + p0.x * _s, _y + p0.y * _s, 2, false);
			draw_circle(_x + p1.x * _s, _y + p1.y * _s, 2, false);
			draw_circle(_x + p2.x * _s, _y + p2.y * _s, 2, false);
		}
		
		static contain = function(p) {
			return p == p0 || p == p1 || p == p2;
		}
	}
	
	static regularTri = function(surf) {
		var sample = inputs[| 1].getValue();
		var spring = inputs[| 2].getValue();
		
		if(!inputs[| 0].value_from) return;
		var ww = surface_get_width(surf);
		var hh = surface_get_height(surf);
		
		var gw = floor(ww / sample) + 1;
		var gh = floor(hh / sample) + 1;
		
		var cont = surface_create(ww, hh)
		surface_set_target(cont);
			shader_set(sh_content_sampler);
			var uniform_dim = shader_get_uniform(sh_content_sampler, "dimension");
			var uniform_sam = shader_get_uniform(sh_content_sampler, "sampler");
		
			shader_set_uniform_f_array(uniform_dim, [ww, hh]);
			shader_set_uniform_f_array(uniform_sam, [sample, sample]);
			draw_surface_safe(surf, 0, 0);
			shader_reset();
		surface_reset_target();
		
		data.points = [[]];
		ds_list_clear(data.tris);
		ds_list_clear(data.links);
		
		for(var i = 0; i < gh; i++) 
		for(var j = 0; j < gw; j++) {
			var c0 = surface_getpixel(cont, j * sample,     i * sample);
			var c1 = surface_getpixel(cont, j * sample - 1, i * sample);
			var c2 = surface_getpixel(cont, j * sample,     i * sample - 1);
			var c3 = surface_getpixel(cont, j * sample - 1, i * sample - 1);
			
			if(c0 + c1 + c2 + c3 > 0) {
				data.points[i][j] = new point(min(j * sample, ww), min(i * sample, hh));
				if(i) {
					if(j && data.points[i - 1][j] != 0 && data.points[i][j - 1] != 0) 
						ds_list_add(data.tris, new triangle(data.points[i - 1][j], data.points[i][j - 1], data.points[i][j]));
					if(j + 1 < gw && data.points[i - 1][j] != 0 && data.points[i - 1][j + 1] != 0)
						ds_list_add(data.tris, new triangle(data.points[i - 1][j], data.points[i - 1][j + 1], data.points[i][j]));
				}
			} else
				data.points[i][j] = 0;
		}
		
		for(var i = 0; i < gh; i++)
		for(var j = 0; j < gw; j++) {
			if(data.points[i][j] == 0) continue;
			
			if(i && data.points[i - 1][j] != 0) {
				ds_list_add(data.links, new link(data.points[i][j], data.points[i - 1][j]));
			}
			if(j && data.points[i][j - 1] != 0) {
				ds_list_add(data.links, new link(data.points[i][j], data.points[i][j - 1]));
			}
			if(i && j && data.points[i - 1][j - 1] != 0) {
				var l = new link(data.points[i][j], data.points[i - 1][j - 1]);
				l.k = spring;
				ds_list_add(data.links, l);
			}
			if(i && j < gw - 1 && data.points[i - 1][j + 1] != 0) {
				var l = new link(data.points[i][j], data.points[i - 1][j + 1]);
				l.k = spring;
				ds_list_add(data.links, l);
			}
		}
		
		surface_free(cont);
	}
	
	static reset = function() {
		for(var i = 0; i < ds_list_size(data.tris); i++) {
			data.tris[| i].reset();
		}
	}
	
	static setTriangle = function() {
		var _inSurf		= inputs[| 0].getValue();
		
		regularTri(_inSurf);
		for(var i = 0; i < ds_list_size(data.tris); i++) {
			data.tris[| i].initSurface(_inSurf);
		}
	}
	
	static affectPoint = function(c, p) {
		var dis = point_distance(c[0], c[1], p.x, p.y);
		var range = c[4];
		var inf = clamp(1 - dis / range, 0, 1);
		
		var dx = c[2] * inf / 2;
		var dy = c[3] * inf / 2;
		
		p.x += dx;
		p.y += dy;
	}
	
	static control = function() {
		for(var i = control_index; i < ds_list_size(inputs); i++) {
			var c = inputs[| i].getValue();
			
			for(var j = 0; j < ds_list_size(data.tris); j++) {
				affectPoint(c, data.tris[| j].p0);
				affectPoint(c, data.tris[| j].p1);
				affectPoint(c, data.tris[| j].p2);
			}
		}
		
		repeat(4)
		for(var i = 0; i < ds_list_size(data.links); i++)
			data.links[| i].resolve();
	}
	
	static update = function() {
		var _inSurf		= inputs[| 0].getValue();
		var _outSurf	= outputs[| 0].getValue();
		
		if(is_surface(_outSurf)) 
			surface_size_to(_outSurf, surface_get_width(_inSurf), surface_get_height(_inSurf));
		else {
			_outSurf = surface_create(surface_get_width(_inSurf), surface_get_height(_inSurf));
			outputs[| 0].setValue(_outSurf);
		}
		
		reset();
		control();
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
			for(var i = 0; i < ds_list_size(data.tris); i++) {
				data.tris[| i].drawSurface(_inSurf);
			}
		surface_reset_target();	
	}
	
	static doDeserialize = function(_map) {
		var _inputs = _map[? "inputs"];
		
		for(var i = control_index; i < ds_list_size(_inputs); i++) {
			createControl();
			inputs[| i].deserialize(_inputs[| i]);
		}
	}
}