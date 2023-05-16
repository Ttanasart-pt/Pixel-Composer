function Node_Mesh_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Mesh Warp";
	
	data = {
		points : [[]],
		tris   : [],
		links  : []
	}
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8, "Amount of grid subdivision. Higher number means more grid, detail.")
		.setDisplay(VALUE_DISPLAY.slider, [ 2, 32, 1 ] );
	
	inputs[| 2] = nodeValue("Spring force", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ] );
	
	inputs[| 3] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0)
		.setDisplay(VALUE_DISPLAY.button, [ function() { setTriangle(); doUpdate(); }, "Generate"] );
	
	inputs[| 4] = nodeValue("Diagonal link", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Include diagonal link to prevent drastic grid deformation.");
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Link strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0, "Link length preservation, setting it to 1 will prevent any stretching, contraction.")
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ] );
		
	control_index = ds_list_size(inputs);
	
	function createControl() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Control point", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ PUPPET_FORCE_MODE.move, 16, 16, 8, 0, 8, 8 ])
			.setDisplay(VALUE_DISPLAY.puppet_control)
		
		array_push(input_display_list, index);
		return inputs[| index];
	}
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Mesh data", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, data);
	
	input_display_list = [ 5, 
		["Mesh",			false],	0, 1, 3,
		["Link",			false],	4, 6,
		["Control points",	false], 
	];
	
	attribute_surface_depth();
	attribute_interpolation();

	input_display_index = array_length(input_display_list);
	points = [];
	
	attributes[? "iteration"] = 4;
	array_push(attributeEditors, ["Iteration", "iteration", 
		new textBox(TEXTBOX_INPUT.number, function(val) { 
			attributes[? "iteration"] = val;
			triggerRender();
		})]);
	
	tools = [
		new NodeTool( "Add / Remove (+ Shift) control point",  THEME.control_add ),
		new NodeTool( "Pin / unpin (+ Shift) mesh", THEME.control_pin )
	];
	
	static onValueFromUpdate = function(index) {
		if(index == 0 && array_empty(data.tris))
			setTriangle();
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { 
		for(var i = 0; i < array_length(data.links); i++)
			data.links[i].draw(_x, _y, _s);
		for(var i = 0; i < array_length(data.tris); i++)
			data.tris[i].drawPoints(_x, _y, _s);
		
		var hover = -1;
		for(var i = control_index; i < ds_list_size(inputs); i++) {
			if(inputs[| i].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny))
				hover = i;
		}
		
		if(!active) return;
		if(isUsingTool(0)) {
			if(key_mod_press(SHIFT))
				draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 16, _my + 16);
			else
				draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left)) {
				if(hover == -1) {
					var i = createControl();
					i.setValue( [ PUPPET_FORCE_MODE.move, value_snap(_mx - _x, _snx) / _s, value_snap(_my - _y, _sny) / _s, 0, 0, 8, 8 ] );
					i.drag_type = 2;
					i.drag_sx   = 0;
					i.drag_sy   = 0;
					i.drag_mx   = _mx;
					i.drag_my   = _my;
				} else if(key_mod_press(SHIFT)) {
					ds_list_delete(inputs, hover);	
					array_delete(input_display_list, input_display_index + hover - control_index, 1);
				}
				
				reset();
				control(input_display_list);
			}
		} else if(isUsingTool(1)) {
			draw_sprite_ui_uniform(key_mod_press(SHIFT)? THEME.cursor_path_remove : THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			draw_set_color(COLORS._main_accent);
			var rad = 16;
			draw_circle(_mx, _my, rad, true);
			var _xx = (_mx - _x) / _s;
			var _yy = (_my - _y) / _s;
			
			if(mouse_click(mb_left)) {
				for(var j = 0; j < array_length(data.tris); j++) {
					var t = data.tris[j];
					
					if(point_in_circle(t.p0.x, t.p0.y, _xx, _yy, rad / _s))
						t.p0.setPin(!key_mod_press(SHIFT));
					if(point_in_circle(t.p1.x, t.p1.y, _xx, _yy, rad / _s))
						t.p1.setPin(!key_mod_press(SHIFT));
					if(point_in_circle(t.p2.x, t.p2.y, _xx, _yy, rad / _s))
						t.p2.setPin(!key_mod_press(SHIFT));
				}
			}
		}
	}
	
	function _Point(node, index, _x, _y) constructor {
		self.index = index;
		self.node = node;
		x  = _x;
		y  = _y;
		xp = x;
		yp = y;
		
		node.points[index] = self;
		
		ndx = 0;
		ndy = 0;
		
		sx  = x;
		sy  = y;
		pin = false;
		
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
			self.pin = pin;	
		}
	}
	
	function link(_p0, _p1) constructor {
		p0 = _p0;
		p1 = _p1;
		k  = 1;
	
		len = point_distance(p0.x, p0.y, p1.x, p1.y);
		
		static resolve = function(strength = 1) {
			var _len = point_distance(p0.x, p0.y, p1.x, p1.y);
			var _dir = point_direction(p0.x, p0.y, p1.x, p1.y);
			
			var _slen = lerp(_len, len, strength);
			var f  = k * (_len - _slen);
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
	
	function _Triangle(_p0, _p1, _p2) constructor {
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
		var useArray = is_array(surf);
		var ww = useArray? surface_get_width(surf[0]) : surface_get_width(surf);
		var hh = useArray? surface_get_height(surf[0]) : surface_get_height(surf);
		
		var gw = ww / sample;
		var gh = hh / sample;
		
		if(!useArray) {
			var cont = surface_create_valid(ww, hh);
			
			surface_set_target(cont);
				shader_set(sh_content_sampler);
				var uniform_dim = shader_get_uniform(sh_content_sampler, "dimension");
				var uniform_sam = shader_get_uniform(sh_content_sampler, "sampler");
			
				shader_set_uniform_f_array_safe(uniform_dim, [ww, hh]);
				shader_set_uniform_f_array_safe(uniform_sam, [gw, gh]);
				draw_surface_safe(surf, 0, 0);
				shader_reset();
			surface_reset_target();
		}
		
		points	    = [];
		data.points = [[]];
		data.tris	= [];
		data.links	= [];
		
		var ind = 0;
		for(var i = 0; i <= sample; i++) 
		for(var j = 0; j <= sample; j++) {
			var fill = false;
			if(useArray) {
				fill = true;
			} else {
				var c0 = surface_get_pixel(cont, j * gw,     i * gh);
				var c1 = surface_get_pixel(cont, j * gw - 1, i * gh);
				var c2 = surface_get_pixel(cont, j * gw,     i * gh - 1);
				var c3 = surface_get_pixel(cont, j * gw - 1, i * gh - 1);
				fill = c0 + c1 + c2 + c3 > 0;
			}
			
			if(fill) {
				data.points[i][j] = new _Point(self, ind++, min(j * gw, ww), min(i * gh, hh));
				if(i == 0) continue;
				
				if(j && data.points[i - 1][j] != 0 && data.points[i][j - 1] != 0) 
					array_push(data.tris, new _Triangle(data.points[i - 1][j], data.points[i][j - 1], data.points[i][j]));
				if(j < sample && data.points[i - 1][j] != 0 && data.points[i - 1][j + 1] != 0)
					array_push(data.tris, new _Triangle(data.points[i - 1][j], data.points[i - 1][j + 1], data.points[i][j]));
			} else
				data.points[i][j] = 0;
		}
		
		for(var i = 0; i <= sample; i++)
		for(var j = 0; j <= sample; j++) {
			if(data.points[i][j] == 0) continue;
			
			if(i && data.points[i - 1][j] != 0) {
				array_push(data.links, new link(data.points[i][j], data.points[i - 1][j]));
			}
			if(j && data.points[i][j - 1] != 0) {
				array_push(data.links, new link(data.points[i][j], data.points[i][j - 1]));
			}
			
			if(diagon) {
				if(i && j && data.points[i - 1][j - 1] != 0) {
					var l = new link(data.points[i][j], data.points[i - 1][j - 1]);
					l.k = spring;
					array_push(data.links, l);
				}
				if(i && j < sample && data.points[i - 1][j + 1] != 0) {
					var l = new link(data.points[i][j], data.points[i - 1][j + 1]);
					l.k = spring;
					array_push(data.links, l);
				}
			}
		}
		
		if(!useArray)
			surface_free(cont);
	}
	
	static reset = function() {
		for(var i = 0; i < array_length(data.tris); i++)
			data.tris[i].reset();
	}
	
	static setTriangle = function() {
		var _inSurf = inputs[| 0].getValue();
		regularTri(_inSurf);
		
		for(var i = 0; i < array_length(data.tris); i++)
			data.tris[i].initSurface(is_array(_inSurf)? _inSurf[0] : _inSurf);
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
		var lStr = inputs[| 6].getValue();
		
		for(var i = control_index; i < ds_list_size(inputs); i++) {
			var c = inputs[| i].getValue();
			
			for( var j = 0; j < array_length(data.points); j++ )
			for( var k = 0; k < array_length(data.points[j]); k++ ) {
				if(data.points[j][k] == 0) continue;
				affectPoint(c, data.points[j][k]);
			}
		}
		
		var it    = attributes[? "iteration"];
		var _rat  = 1 / it;
		
		repeat(it) {
			for( var j = 0; j < array_length(data.points); j++ )
			for( var k = 0; k < array_length(data.points[j]); k++ ) {
				if(data.points[j][k] == 0) continue;
				data.points[j][k].stepMove(_rat);
			}
			
			if(lStr > 0)
			repeat(it) {
				for(var i = 0; i < array_length(data.links); i++)
					data.links[i].resolve(lStr);
			}
		}
		
		for( var j = 0; j < array_length(data.points); j++ )
		for( var k = 0; k < array_length(data.points[j]); k++ ) {
			if(data.points[j][k] == 0) continue;
			data.points[j][k].clearMove();
		}
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _inSurf		= _data[0];
		if(!is_surface(_inSurf)) return _outSurf;
		
		reset();
		control();
		
		_outSurf = surface_verify(_outSurf, surface_get_width(_inSurf), surface_get_height(_inSurf), attrDepth());
		
		surface_set_shader(_outSurf);
		shader_set_interpolation(_outSurf);
		
		if(array_length(data.tris) == 0) {
			draw_surface_safe(_inSurf);
		} else {
			for(var i = 0; i < array_length(data.tris); i++)
				data.tris[i].drawSurface(_inSurf);
		}
		
		surface_reset_shader();	
		
		return _outSurf;
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = control_index; i < ds_list_size(_inputs); i++) {
			var inp = createControl();
			print(instanceof(inp))
			inp.applyDeserialize(_inputs[| i]);
		}
	}
	
	static attributeSerialize = function() {
		var att = ds_map_create();
		
		var pinList = ds_list_create();
		for( var j = 0; j < array_length(data.points); j++ )
		for( var k = 0; k < array_length(data.points[j]); k++ ) {
			var p = data.points[j][k];
			if(p == 0) continue;
			if(p.pin) ds_list_add(pinList, p.index);
		}
			
		ds_map_add_list(att, "pin", pinList);
		return att;
	}
	
	loadPin = noone;
	static attributeDeserialize = function(attr) {
		if(ds_map_exists(attr, "pin")) 
			loadPin = attr[? "pin"];
	}
	
	static postConnect = function() {
		setTriangle();
		
		if(loadPin != noone) {
			for( var i = 0; i < ds_list_size(loadPin); i++ ) {
				var ind = loadPin[| i];
				if(ind < array_length(points))
					points[ind].pin = true;
			}
			loadPin = noone;
		}
	}
}