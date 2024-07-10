function Node_Mesh_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Mesh Warp";
	
	attributes.mesh_bound  = [];
	
	points    = [];
	mesh_data = { points : [], tris : [], links : [], controls: [] };
	
	function _Point(node, index, _x, _y) constructor {
		self.index = index;
		self.node  = node;
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
		
		u = 0;
		v = 0;
		
		controlWeights = [];
		
		static reset = function(_mesh_data) {
			x  = sx; 
			y  = sy;
			xp = x;  
			yp = y;
			
			var dist = 0;
			
			for( var i = 0, n = array_length(_mesh_data.controls); i < n; i++ ) {
				var c = _mesh_data.controls[i];
				var d = point_distance(x, y, c[PUPPET_CONTROL.cx], c[PUPPET_CONTROL.cy]);
				
				controlWeights[i] = 1 / d;
				dist += 1 / d;
			}
			
			for( var i = 0, n = array_length(controlWeights); i < n; i++ )
				controlWeights[i] /= dist;
		}
		
		static draw = function(_x, _y, _s) {
			if(pin) {
				draw_set_color(COLORS._main_accent);
				draw_circle_prec(_x + x * _s, _y + y * _s, 3, false);
			} else {
				draw_set_color(COLORS.node_overlay_gizmo_inactive);
				draw_circle_prec(_x + x * _s, _y + y * _s, 2, false);
			}
		}
		
		static mapTexture = function(ww, hh) { u = x / ww; v = y / hh; }
		static move       = function(dx, dy) { if(pin) return;   x += dx;   y += dy; }
		static planMove   = function(dx, dy) { if(pin) return; ndx += dx; ndy += dy; }
		static stepMove   = function(rat)    { if(pin) return; move(ndx * rat, ndy * rat); }
		static clearMove  = function(rat)    { if(pin) return; ndx = 0; ndy = 0; }
		static setPin     = function(pin)    { self.pin = pin; }
		static equal      = function(point)  { return x == point.x && y == point.y; }
	}
	
	function _Link(_p0, _p1, _k = 1) constructor {
		p0 = _p0;
		p1 = _p1;
		k  = _k;
	
		len = point_distance(p0.x, p0.y, p1.x, p1.y);
		
		static resolve = function(strength = 1) {
			INLINE
			
			var _len = point_distance(p0.x, p0.y, p1.x, p1.y);
			var _dir = point_direction(p0.x, p0.y, p1.x, p1.y);
			
			var _slen = lerp(_len, len, strength);
			var f     = k * (_len - _slen);
			var dx    = lengthdir_x(f, _dir);
			var dy    = lengthdir_y(f, _dir);
			
			p0.move( dx / 2,  dy / 2);
			p1.move(-dx / 2, -dy / 2);
		}
		
		static draw = function(_x, _y, _s) {
			INLINE
			
			draw_set_color(c_red);
			draw_line(_x + p0.x * _s, _y + p0.y * _s, _x + p1.x * _s, _y + p1.y * _s);
		}
	}
	
	function _Triangle(_p0, _p1, _p2) constructor {
		p0 = _p0;
		p1 = _p1;
		p2 = _p2;
		
		static reset = function(_mesh_data) {
			INLINE
			
			p0.reset(_mesh_data);
			p1.reset(_mesh_data);
			p2.reset(_mesh_data);
		}
		
		static initSurface = function(surf) {
			INLINE
			
			p0.mapTexture(surface_get_width_safe(surf), surface_get_height_safe(surf));
			p1.mapTexture(surface_get_width_safe(surf), surface_get_height_safe(surf));
			p2.mapTexture(surface_get_width_safe(surf), surface_get_height_safe(surf));	
		}
		
		static drawSurface = function(surf) {
			INLINE
			
			draw_set_color(c_white);
			draw_set_alpha(1);
			
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(surf));
			draw_vertex_texture(p0.x, p0.y, p0.u, p0.v);
			draw_vertex_texture(p1.x, p1.y, p1.u, p1.v);
			draw_vertex_texture(p2.x, p2.y, p2.u, p2.v);
			draw_primitive_end();
		}
		
		static drawPoints = function(_x, _y, _s) {
			INLINE
			
			p0.draw(_x, _y, _s);
			p1.draw(_x, _y, _s);
			p2.draw(_x, _y, _s);
		}
		
		static contain = function(p) {
			INLINE
			
			return p == p0 || p == p1 || p == p2;
		}
	}
	
	is_convex       = true;
	hover           = -1;
	anchor_dragging = -1;
	anchor_drag_sx  = -1;
	anchor_drag_sy  = -1;
	anchor_drag_mx  = -1;
	anchor_drag_my  = -1;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8, "Amount of grid subdivision. Higher number means more grid, detail.")
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 2, 32, 0.1 ] });
	
	inputs[| 2] = nodeValue("Spring Force", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false )
		.setDisplay(VALUE_DISPLAY.button, { name: "Generate", UI : true, onClick: function() { Mesh_setTriangle(); } });
	
	inputs[| 4] = nodeValue("Diagonal Link", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Include diagonal link to prevent drastic grid deformation.");
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Link Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0, "Link length preservation, setting it to 1 will prevent any stretching, contraction.")
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 7] = nodeValue("Full Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 8] = nodeValue("Mesh Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Grid",   s_node_mesh_type, 0), 
												 new scrollItem("Custom", s_node_mesh_type, 1), ] );
	
	inputs[| 9] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 9].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Mesh data", self, JUNCTION_CONNECT.output, VALUE_TYPE.object, mesh_data);
	
	input_display_list = [ 5, 
		["Mesh",			false],	0, 8, 9, 1, 7, 3, 
		["Link",			false],	4, 6,
		["Control points",	false], 
	];
	
	control_index = ds_list_size(inputs);
	
	function createControl() { #region
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue("Control point", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ PUPPET_FORCE_MODE.move, 16, 16, 8, 0, 8, 8 ])
			.setDisplay(VALUE_DISPLAY.puppet_control)
		
		array_push(input_display_list, index);
		return inputs[| index];
	} #endregion
	
	attribute_surface_depth();
	attribute_interpolation();

	input_display_index = array_length(input_display_list);
	
	#region ============ attributes & tools ============
		array_push(attributeEditors, "Warp");
	
		attributes.iteration = 4;
		array_push(attributeEditors, ["Iteration", function() { return attributes.iteration; }, 
			new textBox(TEXTBOX_INPUT.number, function(val) { 
				attributes.iteration = val;
				triggerRender();
			})]);
	
		tools = [];
	
		tools_edit = [
			new NodeTool( "Edit control point", THEME.control_add ),
			new NodeTool( "Pin mesh",			THEME.control_pin ),
		];
	
		tools_mesh = [
			tools_edit[0],
			tools_edit[1],
			new NodeTool( "Mesh edit",			THEME.mesh_tool_edit ),
			new NodeTool( "Mesh anchor remove", THEME.mesh_tool_delete ),
		];
	#endregion
	
	insp1UpdateTooltip = "Generate";
	insp1UpdateIcon    = [ THEME.refresh_icon, 1, COLORS._main_value_positive ];
	will_triangluate   = false;
	
	static onInspector1Update = function() {
		Mesh_setTriangle();
	}
	
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING) return;
		if(index == 0 && array_empty(mesh_data.tris))
			Mesh_setTriangle();
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		var _type = getInputData(8);
		if(_type == 1 && (isUsingTool("Mesh edit") || isUsingTool("Mesh anchor remove"))) {
			var mesh = attributes.mesh_bound;
			var len  = array_length(mesh);
			var _hover = -0.5, _side = 0;
			
			draw_set_color(is_convex? COLORS._main_accent : COLORS._main_value_negative);
			is_convex = true;
		
			for( var i = 0; i < len; i++ ) {
				var _px0 = mesh[safe_mod(i + 0, len)][0];
				var _py0 = mesh[safe_mod(i + 0, len)][1];
				var _px1 = mesh[safe_mod(i + 1, len)][0];
				var _py1 = mesh[safe_mod(i + 1, len)][1];
				var _px2 = mesh[safe_mod(i + 2, len)][0];
				var _py2 = mesh[safe_mod(i + 2, len)][1];
			
				var side = cross_product(_px0, _py0, _px1, _py1, _px2, _py2);
				if(_side != 0 && sign(_side) != sign(side)) 
					is_convex = false;
				_side = side;
			
				var _dx0 = _x + _px0 * _s;
				var _dy0 = _y + _py0 * _s;
				var _dx1 = _x + _px1 * _s;
				var _dy1 = _y + _py1 * _s;
			
				draw_line_width(_dx0, _dy0, _dx1, _dy1, hover == i + 0.5? 4 : 2);
			
				if(isUsingTool("Mesh edit") && distance_to_line(_mx, _my, _dx0, _dy0, _dx1, _dy1) < 6)
					_hover = i + 0.5;
			}
		
			draw_set_color(COLORS._main_accent);
		
			for( var i = 0; i < len; i++ ) {
				var _px = mesh[i][0];
				var _py = mesh[i][1];
			
				var _dx = _x + _px * _s;
				var _dy = _y + _py * _s;
			
				draw_circle_prec(_dx, _dy, hover == i? 6 : 4, false);
			
				if((isUsingTool("Mesh edit") || isUsingTool("Mesh anchor remove")) && point_distance(_dx, _dy, _mx, _my) < 6)
					_hover = i;
			}
		
			hover = _hover;
		
			if(anchor_dragging > -1) {
				var dx = anchor_drag_sx + (_mx - anchor_drag_mx) / _s;
				var dy = anchor_drag_sy + (_my - anchor_drag_my) / _s;
			
				dx = value_snap(dx, _snx);
				dy = value_snap(dy, _sny);
			
				attributes.mesh_bound[anchor_dragging][0] = dx;
				attributes.mesh_bound[anchor_dragging][1] = dy;
				Mesh_setTriangle();
			
				if(mouse_release(mb_left))
					anchor_dragging = -1;
			}
		
			if(mouse_press(mb_left, active)) {
				if(frac(hover) == 0) {
					if(isUsingTool("Mesh edit")) {
						anchor_dragging = hover;
						anchor_drag_sx  = mesh[hover][0];
						anchor_drag_sy  = mesh[hover][1];
						anchor_drag_mx  = _mx;
						anchor_drag_my  = _my;
					} else if(isUsingTool("Mesh anchor remove")) {
						if(array_length(mesh) > 3) {
							array_delete(mesh, hover, 1);
							Mesh_setTriangle();
						}
					}
				} else if(isUsingTool("Mesh edit")) {
					var ind = hover == -0.5? len : ceil(hover);
					array_insert(attributes.mesh_bound, ind, [ mx, my ]);
				
					anchor_dragging = ind;
					anchor_drag_sx  =  mx;
					anchor_drag_sy  =  my;
					anchor_drag_mx  = _mx;
					anchor_drag_my  = _my;
				}
			}
		}
		
		for(var i = 0; i < array_length(mesh_data.links); i++)
			mesh_data.links[i].draw(_x, _y, _s);
		for(var i = 0; i < array_length(mesh_data.tris); i++)
			mesh_data.tris[i].drawPoints(_x, _y, _s);
		
		var _hover = -1;
		for(var i = control_index; i < ds_list_size(inputs); i++) {
			if(inputs[| i].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny))
				_hover = i;
		}
		
		if(isUsingTool("Edit control point")) {
			if(key_mod_press(SHIFT))
				draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 16, _my + 16);
			else
				draw_sprite_ui_uniform(THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			if(mouse_press(mb_left, active)) {
				if(_hover == -1) {
					var i = createControl();
					i.setValue( [ PUPPET_FORCE_MODE.move, value_snap(_mx - _x, _snx) / _s, value_snap(_my - _y, _sny) / _s, 0, 0, 8, 8 ] );
					i.drag_type = 2;
					i.drag_sx   = 0;
					i.drag_sy   = 0;
					i.drag_mx   = _mx;
					i.drag_my   = _my;
				} else if(key_mod_press(SHIFT)) {
					ds_list_delete(inputs, _hover);	
					array_delete(input_display_list, input_display_index + _hover - control_index, 1);
				}
				
				reset();
				control(input_display_list);
			}
		} else if(isUsingTool("Pin mesh")) {
			draw_sprite_ui_uniform(key_mod_press(SHIFT)? THEME.cursor_path_remove : THEME.cursor_path_add, 0, _mx + 16, _my + 16);
			
			draw_set_color(COLORS._main_accent);
			var rad = 16;
			draw_circle_prec(_mx, _my, rad, true);
			var _xx = (_mx - _x) / _s;
			var _yy = (_my - _y) / _s;
			
			if(mouse_click(mb_left, active)) {
				for(var j = 0; j < array_length(mesh_data.tris); j++) {
					var t = mesh_data.tris[j];
					
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
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	static step = function() {
		var _type = getInputData(8);
		
		inputs[| 2].setVisible(_type == 0);
		inputs[| 4].setVisible(_type == 0);
		inputs[| 7].setVisible(_type == 0);
		
		if(_type == 0)		 tools = tools_edit;
		else if (_type == 1) tools = tools_mesh;
	}
	
	static reset = function() {
		for(var i = 0; i < array_length(mesh_data.tris); i++)
			mesh_data.tris[i].reset(mesh_data);
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	static Mesh_regularTri = function(surf) { #region
		if(is_array(surf)) surf = array_safe_get_fast(surf, 0);
		
		if(!is_surface(surf))       return;
		if(!inputs[| 0].value_from) return;
		
		var sample = getInputData(1);
		var spring = getInputData(2);
		var diagon = getInputData(4);
		var fullmh = getInputData(7);
		
		var ww = surface_get_width_safe(surf);
		var hh = surface_get_height_safe(surf);
		
		var gw   = ww / sample;
		var gh   = hh / sample;
		var cont = noone;
		
		if(!fullmh) { #region alpha filter
			cont = surface_create_valid(ww, hh);
			
			surface_set_target(cont);
				shader_set(sh_content_sampler);
				var uniform_dim = shader_get_uniform(sh_content_sampler, "dimension");
				var uniform_sam = shader_get_uniform(sh_content_sampler, "sampler");
			
				shader_set_uniform_f_array_safe(uniform_dim, [ww, hh]);
				shader_set_uniform_f_array_safe(uniform_sam, [gw, gh]);
				draw_surface_safe(surf);
				shader_reset();
			surface_reset_target();
		} #endregion
		
		var _sam = sample + 1;
		
		mesh_data.points = array_create(_sam * _sam);
		
		var ind = 0;
		for(var i = 0; i < _sam; i++) 
		for(var j = 0; j < _sam; j++) { #region mesh
			var fill = false;
			
			if(fullmh) {
				fill = true;
			} else {
				var _i = i * gh;
				var _j = j * gw;
				
				fill |= surface_get_pixel(cont, _j - 1, _i - 1);
				fill |= surface_get_pixel(cont, _j - 1, _i);
				fill |= surface_get_pixel(cont, _j - 1, _i + 1);
				
				fill |= surface_get_pixel(cont, _j, _i - 1);
				fill |= surface_get_pixel(cont, _j, _i);
				fill |= surface_get_pixel(cont, _j, _i + 1);
				
				fill |= surface_get_pixel(cont, _j + 1, _i - 1);
				fill |= surface_get_pixel(cont, _j + 1, _i);
				fill |= surface_get_pixel(cont, _j + 1, _i + 1);
			}
			
			if(!fill) continue;
			
			var px = min(j * gw, ww);
			var py = min(i * gh, hh);
			
			mesh_data.points[i * _sam + j] = new _Point(self, ind++, px, py);
			if(i == 0) continue;
				
			if(j && mesh_data.points[(i - 1) * _sam + j] != 0 && mesh_data.points[i * _sam + j - 1] != 0) 
				array_push(mesh_data.tris, new _Triangle(mesh_data.points[(i - 1) * _sam + j], mesh_data.points[i * _sam + j - 1], mesh_data.points[i * _sam + j]));
				
			if(j < sample && mesh_data.points[(i - 1) * _sam + j] != 0 && mesh_data.points[(i - 1) * _sam + j + 1] != 0)
				array_push(mesh_data.tris, new _Triangle(mesh_data.points[(i - 1) * _sam + j], mesh_data.points[(i - 1) * _sam + j + 1], mesh_data.points[i * _sam + j]));
		} #endregion
		
		for(var i = 0; i < _sam; i++)
		for(var j = 0; j < _sam; j++) { #region diagonal
			var p0 = i && j? mesh_data.points[ (i - 1) * _sam + j - 1 ] : 0;
			var p1 = i?      mesh_data.points[ (i - 1) * _sam + j     ] : 0;
			var p2 =      j? mesh_data.points[ (i    ) * _sam + j - 1 ] : 0;
			var p3 =         mesh_data.points[ (i    ) * _sam + j     ];
			
			if(p3 && p1) array_push(mesh_data.links, new _Link(p3, p1));
			if(p3 && p2) array_push(mesh_data.links, new _Link(p3, p2));
			
			var d0 = p0 && p3;
			var d1 = p1 && p2;
			
			if(diagon || d0 ^ d1) {
				if(d0) array_push(mesh_data.links, new _Link(p0, p3, spring));
				if(d1) array_push(mesh_data.links, new _Link(p1, p2, spring));
			}
		} #endregion
		
		if(is_surface(cont)) surface_free(cont);
	} #endregion
	
	static Mesh_triangulate = function(surf) { #region
		var sample = getInputData(1);
		var seed   = getInputData(9);
		
		if(!inputs[| 0].value_from) return;
		if(is_array(surf)) surf = surf[0];
		
		var ww = surface_get_width_safe(surf);
		var hh = surface_get_height_safe(surf);
		
		var _m = attributes.mesh_bound;
		if(array_length(_m) < 3) return;
		
		var _mb		= array_length(_m);
		var ind		= 0;
		
		var minX, maxX, minY, maxY;
    
	    for (var i = 0; i < array_length(_m); i++) {
	        var point = _m[i];
	        var _x = point[0];
	        var _y = point[1];
			
	        if (i == 0) {
	            minX = _x; maxX = _x;
	            minY = _y; maxY = _y; 
	        } else {
	            minX = min(minX, _x);
	            maxX = max(maxX, _x);
	            minY = min(minY, _y);
	            maxY = max(maxY, _y);
	        }
	    }
		
		var gw = ww / sample / 3;
		var gh = hh / sample / 3;
		
		random_set_seed(seed);
		var _p = [];
		for( var i = 0; i <= sample; i++ )
		for( var j = 0; j <= sample; j++ ) {
			var px = lerp(minX, maxX, i / sample);
			var py = lerp(minY, maxY, j / sample);
			
			px += random_range(-gw, gw);
			py += random_range(-gh, gh);
			
			if(point_in_polygon(px, py, _m))
				array_push(_p, [ px, py ]);
		}
		
		mesh_data.points = array_create(_mb + array_length(_p));
		
		for( var i = 0, n = _mb; i < n; i++ )
			mesh_data.points[i] = new _Point(self, ind++, _m[i][0], _m[i][1]);
		for( var i = 0, n = array_length(_p); i < n; i++ )
			mesh_data.points[_mb + i] = new _Point(self, ind++, _p[i][0], _p[i][1]);
		
		var _t = delaunay_triangulation(mesh_data.points);
		
		for( var i = 0, n = array_length(_t); i < n; i++ ) {
			var t = _t[i];
			array_push(mesh_data.tris,  new _Triangle(t[0], t[1], t[2]));
			
			array_push(mesh_data.links, new _Link(t[0], t[1]));
			array_push(mesh_data.links, new _Link(t[1], t[2]));
			array_push(mesh_data.links, new _Link(t[2], t[0]));
		}
	} #endregion
	
	static Mesh_setTriangle = function() { #region
		var _inSurf = getInputData(0);
		var _type   = getInputData(8);
		
		points = [];
		mesh_data   = { points : [], tris : [], links : [], controls: [] };
		
		switch(_type) {
			case 0 : Mesh_regularTri(_inSurf);   break;
			case 1 : Mesh_triangulate(_inSurf);	break;
		}
		
		for(var i = 0; i < array_length(mesh_data.tris); i++)
			mesh_data.tris[i].initSurface(is_array(_inSurf)? _inSurf[0] : _inSurf);
		
		triggerRender();
		
		if(loadPin != noone) {
			for( var i = 0, n = array_length(loadPin); i < n; i++ ) {
				var ind = loadPin[i];
				if(ind < array_length(points))
					points[ind].pin = true;
			}
			loadPin = noone;
		}
	} #endregion
	
	static Control_affectPoint = function(c, p) { #region
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
	} #endregion
	
	static control = function() {
		var lStr = getInputData(6);
		
		for(var i = control_index, n = ds_list_size(inputs); i < n; i++) {
			var c = getInputData(i);
			
			for( var j = 0, m = array_length(mesh_data.points); j < m; j++ ) {
				if(mesh_data.points[j] == 0) continue;
				Control_affectPoint(c, mesh_data.points[j]);
			}
		}
		
		for( var i = 0, n = array_length(mesh_data.points); i < n; i++ ) {
			var _p = mesh_data.points[i]; if(_p == 0) continue;
			var _dx = 0;
			var _dy = 0;
			
			for( var j = 0, m = array_length(mesh_data.controls); j < m; j++ ) {
				var _c = mesh_data.controls[j];
				
				_dx += _c[PUPPET_CONTROL.fx] * _p.controlWeights[j];
				_dy += _c[PUPPET_CONTROL.fy] * _p.controlWeights[j];
			}
			
			_p.planMove(_dx, _dy);
		}
		
		var it    = attributes.iteration;
		var _rat  = 1 / it;
		
		repeat(it) {
			for( var j = 0; j < array_length(mesh_data.points); j++ ) {
				if(mesh_data.points[j] == 0) continue;
				mesh_data.points[j].stepMove(_rat);
			}
			
			if(lStr > 0)
			repeat(it) {
				for(var i = 0; i < array_length(mesh_data.links); i++)
					mesh_data.links[i].resolve(lStr);
			}
		}
		
		for( var j = 0; j < array_length(mesh_data.points); j++ ) {
			if(mesh_data.points[j] == 0) continue;
			mesh_data.points[j].clearMove();
		}
	}
	
	static processData = function(_outData, _data, _output_index, _array_index) { #region
		if(will_triangluate) {
			Mesh_setTriangle();
			will_triangluate = false;
		}
		
		var _outSurf = _outData[0];
		var _inSurf  = _data[0];
		if(!is_surface(_inSurf)) return [ _outSurf, mesh_data ];
		
		mesh_data.controls = [];
		for(var i = control_index; i < ds_list_size(inputs); i++) {
			var c = getInputData(i);
			
			if(c[0] == PUPPET_FORCE_MODE.puppet) 
				array_push(mesh_data.controls, c);
		}
		
		reset();
		control();
		
		var _sw  = surface_get_width_safe(_inSurf);
		var _sh  = surface_get_height_safe(_inSurf);
		_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		
		surface_set_shader(_outSurf);
		shader_set_interpolation(_outSurf);
		
			if(array_length(mesh_data.tris) == 0) {
				draw_surface_safe(_inSurf);
			} else {
				for(var i = 0; i < array_length(mesh_data.tris); i++)
					mesh_data.tris[i].drawSurface(_inSurf);
			}
		
		surface_reset_shader();	
		
		return [ _outSurf, mesh_data ];
	} #endregion
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for(var i = control_index; i < array_length(_inputs); i++) {
			var inp = createControl();
			inp.applyDeserialize(_inputs[i]);
		}
	}
	
	static attributeSerialize = function() {
		var att = {};
		struct_append(att, attributes);
		
		var pinList = [];
		for( var j = 0; j < array_length(mesh_data.points); j++ ) {
			var p = mesh_data.points[j];
			if(p == 0) continue;
			if(p.pin) array_push(pinList, p.index);
		}
		
		att.pin = pinList;
		att.mesh_bound = attributes.mesh_bound;
		
		return att;
	}
	
	loadPin = noone;
	static attributeDeserialize = function(attr) {
		struct_append(attributes, attr);
		
		if(struct_has(attr, "pin"))			loadPin = attr.pin;
		if(struct_has(attr, "mesh_bound"))  attributes.mesh_bound = attr.mesh_bound;;
	}
	
	static postLoad = function() {
		will_triangluate = true;
	}
}