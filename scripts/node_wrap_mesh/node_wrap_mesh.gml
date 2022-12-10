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
	inputs[| 1] = nodeValue(1, "Sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8)
		.setDisplay(VALUE_DISPLAY.slider, [ 2, 32, 1 ] );
	
	inputs[| 2] = nodeValue(2, "Spring force", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ] );
	
	inputs[| 3] = nodeValue(3, "Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { setTriangle(); doUpdate(); }, "Generate"] );
	
	inputs[| 4] = nodeValue(4, "Diagonal link", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	control_index = ds_list_size(inputs);
	
	function createControl() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue(index, "Control point", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ PUPPET_FORCE_MODE.move, 16, 16, 8, 0, 8, 8])
			.setDisplay(VALUE_DISPLAY.puppet_control)
		
		array_push(input_display_list, index);
		return inputs[| index];
	}
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	outputs[| 1] = nodeValue(1, "Mesh data", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, data);
	
	input_display_list = [ 
		["Mesh",			false],	0, 1, 2, 4, 3,
		["Control points",	false], 
	];
	
	input_display_index = array_length(input_display_list);
	
	tools = [
		[ "Add / Remove control point",  THEME.control_edit ],
		[ "Pin, unpin mesh", [THEME.control_pin, THEME.control_unpin] ]
	];
	
	attributes[? "pin"] = ds_map_create();
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		for(var i = 0; i < ds_list_size(data.tris); i++) {
			data.tris[| i].drawPoints(_x, _y, _s);
		}
		for(var i = 0; i < ds_list_size(data.links); i++) {
			data.links[| i].draw(_x, _y, _s);
		}
		
		var hover = -1;
		for(var i = control_index; i < ds_list_size(inputs); i++) {
			if(inputs[| i].drawOverlay(_active, _x, _y, _s, _mx, _my))
				hover = i;
		}
		
		var _tool = PANEL_PREVIEW.tool_index;
		var _sub_tool = PANEL_PREVIEW.tool_sub_index;
		
		if(!_active) return;
		if(_tool == 0) {
			if(mouse_press(mb_left)) {
				if(hover == -1) {
					var i = createControl();
					i.setValue( [PUPPET_FORCE_MODE.move, (_mx - _x) / _s, (_my - _y) / _s, 0, 0, 8, 8] );
					i.drag_type = 2;
					i.drag_sx   = 0;
					i.drag_sy   = 0;
					i.drag_mx   = _mx;
					i.drag_my   = _my;
				} else {
					ds_list_delete(inputs, hover);	
					array_delete(input_display_list, input_display_index + hover - control_index, 1);
				}
				
				reset();
				control(input_display_list);
			}
		} else if(_tool == 1) {
			draw_set_color(COLORS._main_accent);
			var rad = 16;
			draw_circle(_mx, _my, rad, true);
			var _xx = (_mx - _x) / _s;
			var _yy = (_my - _y) / _s;
			
			if(mouse_click(mb_left)) {
				for(var j = 0; j < ds_list_size(data.tris); j++) {
					var t = data.tris[| j];
					
					if(point_in_circle(t.p0.x, t.p0.y, _xx, _yy, rad / _s))
						t.p0.setPin(!_sub_tool);
					if(point_in_circle(t.p1.x, t.p1.y, _xx, _yy, rad / _s))
						t.p1.setPin(!_sub_tool);
					if(point_in_circle(t.p2.x, t.p2.y, _xx, _yy, rad / _s))
						t.p2.setPin(!_sub_tool);
				}
			}
		}
	}
	
	function point(node, index, _x, _y) constructor {
		self.index = index;
		self.node = node;
		x = _x;
		y = _y;
		xp = x;
		yp = y;
		
		ndx = 0;
		ndy = 0;
		
		sx = x;
		sy = y;
		pin = ds_map_exists(node.attributes[? "pin"], index);
		
		static reset = function() {
			x = sx;
			y = sy;
			xp = x;
			yp = y;
		}
		
		static draw = function(_x, _y, _s) {
			if(pin) {
				draw_set_color(COLORS._main_accent);
				draw_circle(_x + x * _s, _y + y * _s, 3, false);
			} else {
				draw_set_color(COLORS.node_overlay_gizmo_inactive);
				draw_circle(_x + x * _s, _y + y * _s, 2, false);
			}
		}
		
		u = 0;
		v = 0;
		static mapTexture = function(ww, hh) {
			u = x / ww;
			v = y / hh;
		}
		
		static move = function(dx, dy) {
			if(pin) return;
			
			x += dx;
			y += dy;
		}
		
		static planMove = function(dx, dy) {
			if(pin) return;
			
			ndx += dx;
			ndy += dy;
		}
		
		static stepMove = function(rat) {
			if(pin) return;
			
			move(ndx * rat, ndy * rat);
		}
		
		static clearMove = function(rat) {
			if(pin) return;
			
			ndx = 0;
			ndy = 0;
		}
		
		static setPin = function(pin) {
			if(!pin && ds_map_exists(node.attributes[? "pin"], index))
				ds_map_delete(node.attributes[? "pin"], index);
			if(pin && !ds_map_exists(node.attributes[? "pin"], index))
				ds_map_add(node.attributes[? "pin"], index, 1);
			
			self.pin = pin;	
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
			
			p0.move( dx / 2,  dy / 2);
			p1.move(-dx / 2, -dy / 2);
		}
		
		static draw = function(_x, _y, _s) {
			draw_set_color(c_red);
			draw_line(_x + p0.x * _s, _y + p0.y * _s, _x + p1.x * _s, _y + p1.y * _s);
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
			//draw_set_color(c_white);
			//draw_triangle(_x + p0.x * _s, _y + p0.y * _s, _x + p1.x * _s, _y + p1.y * _s, _x + p2.x * _s, _y + p2.y * _s, false)
			
			p0.draw(_x, _y, _s);
			p1.draw(_x, _y, _s);
			p2.draw(_x, _y, _s);
		}
		
		static contain = function(p) {
			return p == p0 || p == p1 || p == p2;
		}
	}
	
	static regularTri = function(surf) {
		var sample = inputs[| 1].getValue();
		var spring = inputs[| 2].getValue();
		var diagon = inputs[| 4].getValue();
		
		if(!inputs[| 0].value_from) return;
		var ww = surface_get_width(surf);
		var hh = surface_get_height(surf);
		
		var gw = ww / sample;
		var gh = hh / sample;
		
		var cont = surface_create_valid(ww, hh)
		surface_set_target(cont);
			shader_set(sh_content_sampler);
			var uniform_dim = shader_get_uniform(sh_content_sampler, "dimension");
			var uniform_sam = shader_get_uniform(sh_content_sampler, "sampler");
			
			shader_set_uniform_f_array(uniform_dim, [ww, hh]);
			shader_set_uniform_f_array(uniform_sam, [gw, gh]);
			draw_surface_safe(surf, 0, 0);
			shader_reset();
		surface_reset_target();
		
		data.points = [[]];
		ds_list_clear(data.tris);
		ds_list_clear(data.links);
		
		var ind = 0;
		for(var i = 0; i <= sample; i++) 
		for(var j = 0; j <= sample; j++) {
			var c0 = surface_getpixel(cont, j * gw,     i * gh);
			var c1 = surface_getpixel(cont, j * gw - 1, i * gh);
			var c2 = surface_getpixel(cont, j * gw,     i * gh - 1);
			var c3 = surface_getpixel(cont, j * gw - 1, i * gh - 1);
			
			if(c0 + c1 + c2 + c3 > 0) {
				data.points[i][j] = new point(self, ind++, min(j * gw, ww), min(i * gh, hh));
				if(i == 0) continue;
				
				if(j && data.points[i - 1][j] != 0 && data.points[i][j - 1] != 0) 
					ds_list_add(data.tris, new triangle(data.points[i - 1][j], data.points[i][j - 1], data.points[i][j]));
				if(j < sample && data.points[i - 1][j] != 0 && data.points[i - 1][j + 1] != 0)
					ds_list_add(data.tris, new triangle(data.points[i - 1][j], data.points[i - 1][j + 1], data.points[i][j]));
			} else
				data.points[i][j] = 0;
		}
		
		for(var i = 0; i <= sample; i++)
		for(var j = 0; j <= sample; j++) {
			if(data.points[i][j] == 0) continue;
			
			if(i && data.points[i - 1][j] != 0) {
				ds_list_add(data.links, new link(data.points[i][j], data.points[i - 1][j]));
			}
			if(j && data.points[i][j - 1] != 0) {
				ds_list_add(data.links, new link(data.points[i][j], data.points[i][j - 1]));
			}
			
			if(diagon) {
				if(i && j && data.points[i - 1][j - 1] != 0) {
					var l = new link(data.points[i][j], data.points[i - 1][j - 1]);
					l.k = spring;
					ds_list_add(data.links, l);
				}
				if(i && j < sample && data.points[i - 1][j + 1] != 0) {
					var l = new link(data.points[i][j], data.points[i - 1][j + 1]);
					l.k = spring;
					ds_list_add(data.links, l);
				}
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
		var mode = c[PUPPET_CONTROL.mode];
		var cx   = c[PUPPET_CONTROL.cx];
		var cy   = c[PUPPET_CONTROL.cy];
		var fx   = c[PUPPET_CONTROL.fx];
		var fy   = c[PUPPET_CONTROL.fy];
		var cw   = c[PUPPET_CONTROL.width];
		var ch   = c[PUPPET_CONTROL.height];
		
		switch(mode) {
			case PUPPET_FORCE_MODE.move:
				var dis = point_distance(cx, cy, p.x, p.y);
				var inf = clamp(1 - dis / cw, 0, 1);
				inf = ease_cubic_inout(inf);
				
				p.planMove(fx * inf, fy * inf);
				break;
			case PUPPET_FORCE_MODE.pinch:
				var dis = point_distance(cx, cy, p.x, p.y);
				var inf = power(clamp(1 - dis / cw, 0, 1), 2) / 2;
				var dir = point_direction(p.x, p.y, cx, cy);
				
				p.planMove(lengthdir_x(inf, dir) * ch, lengthdir_y(inf, dir) * ch);
				break;
			case PUPPET_FORCE_MODE.inflate:
				var dis = point_distance(cx, cy, p.x, p.y);
				var inf = power(clamp(1 - dis / cw, 0, 1), 2) / 2;
				var dir = point_direction(cx, cy, p.x, p.y);
				
				p.planMove(lengthdir_x(inf, dir) * ch, lengthdir_y(inf, dir) * ch);
				break;
			case PUPPET_FORCE_MODE.wind:
				var lx0 = cx + lengthdir_x(1000, fy);
				var ly0 = cy + lengthdir_y(1000, fy);
				var lx1 = cx - lengthdir_x(1000, fy);
				var ly1 = cy - lengthdir_y(1000, fy);
				
				var dist = distance_to_line(p.x, p.y, lx0, ly0, lx1, ly1);
				var inf = clamp(1 - dist / cw, 0, 1);
				inf = ease_cubic_inout(inf);
				
				p.planMove(lengthdir_x(fx * inf, fy), lengthdir_y(fx * inf, fy));
				break;
		}
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
		
		var it = PREF_MAP[? "verlet_iteration"];
		var resit = it;
		var _rat = power(1 / it, 2);
		
		repeat(it) {
			for(var j = 0; j < ds_list_size(data.tris); j++) {
				var t = data.tris[| j];
				t.p0.stepMove(_rat);
				t.p1.stepMove(_rat);
				t.p2.stepMove(_rat);
			}
			
			repeat(resit) {
				for(var i = 0; i < ds_list_size(data.links); i++)
					data.links[| i].resolve();
			}
		}
		
		for(var j = 0; j < ds_list_size(data.tris); j++) {
			var t = data.tris[| j];
			t.p0.clearMove();
			t.p1.clearMove();
			t.p2.clearMove();
		}
	}
	
	static update = function() {
		var _inSurf		= inputs[| 0].getValue();
		var _outSurf	= outputs[| 0].getValue();
		
		if(is_surface(_outSurf)) 
			surface_size_to(_outSurf, surface_get_width(_inSurf), surface_get_height(_inSurf));
		else {
			_outSurf = surface_create_valid(surface_get_width(_inSurf), surface_get_height(_inSurf));
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
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = control_index; i < ds_list_size(_inputs); i++) {
			createControl();
			inputs[| i].deserialize(_inputs[| i]);
		}
	}
	
	static attributeSerialize = function() {
		var att = ds_map_create();
		ds_map_add_map(att, "pin", attributes[? "pin"]);
		return att;
	}
	
	static attributeDeserialize = function(attr) {
		if(ds_map_exists(attr, "pin"))
			attributes[? "pin"] = ds_map_clone(attr[? "pin"]);
	}
}