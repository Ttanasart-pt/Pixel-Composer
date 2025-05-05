#region
	FN_NODE_TOOL_INVOKE {
		hotkeyTool("Node_Mesh_Warp", "Edit control point", "V");
		hotkeyTool("Node_Mesh_Warp", "Pin mesh",           "P");
		hotkeyTool("Node_Mesh_Warp", "Mesh edit",          "M");
		hotkeyTool("Node_Mesh_Warp", "Mesh anchor remove", "E");	
	});
#endregion

function MeshedSurface() : Mesh() constructor {
	surface   = noone;
	points    = [];
	tris      = [];
	links     = [];
	controls  = [];
	
	static clone = function() {
		var msh = new MeshedSurface();
		msh.surface  = surface;
		msh.controls = controls;
		
		p = array_create_ext(array_length(points), function(i) /*=>*/ { return is(points[i], MeshedPoint)? points[i].clone() : points[i]; });
		msh.points = p;
		msh.links  = array_create_ext(array_length(links), function(i) /*=>*/ {return links[i].clone(p)});
		msh.tris   = array_create_ext(array_length(tris),  function(i) /*=>*/ {return tris[i].clone(p)});
		
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			msh.triangles[i] = [
				triangles[i][0].clone(),
				triangles[i][1].clone(),
				triangles[i][2].clone(),
			];
		}
		
		msh.center = [ center[0], center[1] ];
		
		return msh;
	}
}

function MeshedPoint(index, _x, _y) constructor {
	self.index = index;
	
	x  = _x;
	y  = _y;
	xp = x;
	yp = y;
	
	ndx = 0;
	ndy = 0;
	
	sx  = x;
	sy  = y;
	pin = false;
	
	u = 0;
	v = 0;
	
	drx = 0;
	dry = 0;
	
	weight = 0;
	color  = c_white;
	
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
		draw_set_circle_precision(4);
		
		if(pin) {
			draw_set_color(COLORS._main_accent);
			draw_circle_prec(_x + x * _s, _y + y * _s, 3, false);
		} else {
			draw_set_color(COLORS.node_overlay_gizmo_inactive);
			draw_circle_prec(_x + x * _s, _y + y * _s, 2, false);
		}
	}
	
	static mapTexture = function(ww, hh) { u = x / ww; v = y / hh;                     }
	
	static move       = function(dx, dy) { if(pin) return;   x += dx;   y += dy;       }
	static planMove   = function(dx, dy) { if(pin) return; ndx += dx; ndy += dy;       }
	static stepMove   = function(rat)    { if(pin) return; move(ndx * rat, ndy * rat); }
	static clearMove  = function(rat)    { if(pin) return; ndx = 0; ndy = 0;           }
	
	static setPin     = function(pin)    { self.pin = pin;                             }
	static equal      = function(point)  { return x == point.x && y == point.y;        }
	
	static clone = function() { 
		var p = new MeshedPoint(index, x, y);
		p.u = u;
		p.v = v;
		
		return p;
	}
}

function MeshedLink(_p0, _p1, _k = 1) constructor {
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
		
		draw_set_color(COLORS._main_accent);
		draw_line(_x + p0.x * _s, _y + p0.y * _s, _x + p1.x * _s, _y + p1.y * _s);
	}
	
	static clone = function(pointArr) {
		var _p0 = pointArr[p0.index];
		var _p1 = pointArr[p1.index];
		return new MeshedLink(_p0, _p1, k);
	}
}

function MeshedTriangle(_p0, _p1, _p2) constructor {
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
	
	static clone = function(pointArr) {
		var _p0 = pointArr[p0.index];
		var _p1 = pointArr[p1.index];
		var _p2 = pointArr[p2.index];
		
		return new MeshedTriangle(_p0, _p1, _p2);
	}
}

function Node_Mesh_Warp(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Mesh Warp";
	
	attributes.mesh_bound  = [];
	
	points      = [];
	mesh_data   = new MeshedSurface();
	
	is_convex       = true;
	hover           = -1;
	anchor_dragging = -1;
	anchor_drag_sx  = -1;
	anchor_drag_sy  = -1;
	anchor_drag_mx  = -1;
	anchor_drag_my  = -1;
	
	newActiveInput(5, nodeValue_Bool("Active", self, true));
	newInput(9, nodeValueSeed(self));
	
	////- Mesh
	
	newInput( 0, nodeValue_Surface(     "Surface In", self));
	newInput( 8, nodeValue_Enum_Button( "Mesh Type",  self, 0, [ "Grid", "Custom" ] ));
	newInput( 1, nodeValue_ISlider(     "Sample",     self, 8, [ 2, 32, 0.1 ])).setTooltip("Amount of grid subdivision. Higher number means more grid, detail.");
	newInput( 7, nodeValue_Bool(        "Full Mesh",  self, false));
	newInput(10, nodeValue_Slider(      "Randomness", self, 0.5));
	newInput( 3, nodeValue_Trigger(     "Mesh",       self )).setDisplay(VALUE_DISPLAY.button, { name: "Generate", UI : true, onClick: function() /*=>*/ {return Mesh_build()} });
	
	////- Link
	
	newInput(2, nodeValue_Slider( "Spring Force",  self, 0.5));
	newInput(4, nodeValue_Bool(   "Diagonal Link", self, false)).setTooltip("Include diagonal link to prevent drastic grid deformation.");
	newInput(6, nodeValue_Slider ("Link Strength", self, 0)).setTooltip("Link length preservation, setting it to 1 will prevent any stretching, contraction.");
		
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output( "Surface Out", self, VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output( "Mesh data",   self, VALUE_TYPE.mesh, new Mesh()));
	
	input_display_list = [ 5, 9, 
		["Mesh",			false],	0, 8, 1, 7, 10, 3, 
		["Link",			false],	4, 6,
		["Control points",	false], 
	];
	
	control_index = array_length(inputs);
	
	function createControl() {
		var index = array_length(inputs);
		newInput(index, nodeValue_Float("Control point", self, [ PUPPET_FORCE_MODE.move, 16, 16, 8, 0, 8, 8 ]))
			.setDisplay(VALUE_DISPLAY.puppet_control);
		
		array_push(input_display_list, index);
		
		recordAction(ACTION_TYPE.array_insert, inputs, [ inputs[index], index, $"Create control point {index}" ]);
		recordAction(ACTION_TYPE.array_insert, input_display_list, [ array_last(input_display_list), array_length(input_display_list) - 1 ]);
		return inputs[index];
	}
	
	attribute_surface_depth();
	attribute_interpolation();

	input_display_index = array_length(input_display_list);
	
	#region ============ attributes & tools ============
		array_push(attributeEditors, "Warp");
		
		attributes.iteration = 4;
		array_push(attributeEditors, ["Iteration", function() /*=>*/ {return attributes.iteration}, textBox_Number(function(v) /*=>*/ { attributes.iteration = v; triggerRender(); })]);
	
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
	
	setTrigger(1, "Generate", [ THEME.refresh_icon, 1, COLORS._main_value_positive ], function() /*=>*/ {return Mesh_build()});
	will_triangluate   = false;
	
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
				Mesh_build();
			
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
							Mesh_build();
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
		for(var i = control_index; i < array_length(inputs); i++) {
			var hv = inputs[i].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny); OVERLAY_HV
			if(hv) _hover = i;
		}
		
		if(isUsingTool("Edit control point")) {
			if(key_mod_press(SHIFT)) draw_sprite_ui_uniform(THEME.cursor_path_remove, 0, _mx + 4, _my + 4);
			else                     draw_sprite_ui_uniform(THEME.cursor_path_add,    0, _mx + 4, _my + 4);
			
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
					array_delete(inputs, _hover, 1);
					array_delete(input_display_list, input_display_index + _hover - control_index, 1);
				}
				
				reset();
				control(input_display_list);
			}
		} else if(isUsingTool("Pin mesh")) {
			draw_sprite_ui_uniform(key_mod_press(SHIFT)? THEME.cursor_path_remove : THEME.cursor_path_add, 0, _mx + 4, _my + 4);
			
			draw_set_color(COLORS._main_accent);
			var rad = 16;
			draw_circle_prec(_mx, _my, rad, true);
			var _xx = (_mx - _x) / _s;
			var _yy = (_my - _y) / _s;
			var _rr = rad / _s;
			
			if(mouse_click(mb_left, active)) {
				var _pin = !key_mod_press(SHIFT);
				
				for(var j = 0; j < array_length(mesh_data.tris); j++) {
					var t = mesh_data.tris[j];
					
					if(point_in_circle(t.p0.x, t.p0.y, _xx, _yy, _rr)) t.p0.setPin(_pin);
					if(point_in_circle(t.p1.x, t.p1.y, _xx, _yy, _rr)) t.p1.setPin(_pin);
					if(point_in_circle(t.p2.x, t.p2.y, _xx, _yy, _rr)) t.p2.setPin(_pin);
				}
			}
		} 
	}
	
	////- Mesh
	
	static reset = function() {
		for(var i = 0; i < array_length(mesh_data.tris); i++)
			mesh_data.tris[i].reset(mesh_data);
	}
	
	static Mesh_build_RegularTri = function(surf) {
		if(is_array(surf)) surf = array_safe_get_fast(surf, 0);
		
		if(!is_surface(surf))     return;
		if(!inputs[0].value_from) return;
		
		var sample = getInputData(1);
		var spring = getInputData(2);
		var diagon = getInputData(4);
		var fullmh = getInputData(7);
		
		var ww = surface_get_width_safe(surf);
		var hh = surface_get_height_safe(surf);
		
		var gw   = ww / sample;
		var gh   = hh / sample;
		var cont = noone;
		
		if(!fullmh) { // alpha filter
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
		}
		
		var _sam = sample + 1;
		
		mesh_data.points = array_create(_sam * _sam);
		
		var ind = 0;
		for(var i = 0; i < _sam; i++) 
		for(var j = 0; j < _sam; j++) { // mesh
			var fill = false;
			
			if(fullmh) {
				fill = true;
			} else {
				var _i = i * gh;
				var _j = j * gw;
				
				fill = fill || surface_get_pixel(cont, _j - 1, _i - 1);
				fill = fill || surface_get_pixel(cont, _j - 1, _i);
				fill = fill || surface_get_pixel(cont, _j - 1, _i + 1);
				
				fill = fill || surface_get_pixel(cont, _j, _i - 1);
				fill = fill || surface_get_pixel(cont, _j, _i);
				fill = fill || surface_get_pixel(cont, _j, _i + 1);
				
				fill = fill || surface_get_pixel(cont, _j + 1, _i - 1);
				fill = fill || surface_get_pixel(cont, _j + 1, _i);
				fill = fill || surface_get_pixel(cont, _j + 1, _i + 1);
			}
			
			if(!fill) continue;
			
			var px = min(j * gw, ww);
			var py = min(i * gh, hh);
			
			mesh_data.points[i * _sam + j] = new MeshedPoint(i * _sam + j, px, py);
			if(i == 0) continue;
				
			if(j && mesh_data.points[(i - 1) * _sam + j] != 0 && mesh_data.points[i * _sam + j - 1] != 0) 
				array_push(mesh_data.tris, new MeshedTriangle(mesh_data.points[(i - 1) * _sam + j], mesh_data.points[i * _sam + j - 1], mesh_data.points[i * _sam + j]));
				
			if(j < sample && mesh_data.points[(i - 1) * _sam + j] != 0 && mesh_data.points[(i - 1) * _sam + j + 1] != 0)
				array_push(mesh_data.tris, new MeshedTriangle(mesh_data.points[(i - 1) * _sam + j], mesh_data.points[(i - 1) * _sam + j + 1], mesh_data.points[i * _sam + j]));
		}
		
		for(var i = 0; i < _sam; i++)
		for(var j = 0; j < _sam; j++) { // diagonal
			var p0 = i && j? mesh_data.points[ (i - 1) * _sam + j - 1 ] : 0;
			var p1 = i?      mesh_data.points[ (i - 1) * _sam + j     ] : 0;
			var p2 =      j? mesh_data.points[ (i    ) * _sam + j - 1 ] : 0;
			var p3 =         mesh_data.points[ (i    ) * _sam + j     ];
			
			if(p3 && p1) array_push(mesh_data.links, new MeshedLink(p3, p1));
			if(p3 && p2) array_push(mesh_data.links, new MeshedLink(p3, p2));
			
			var d0 = p0 && p3;
			var d1 = p1 && p2;
			
			if(diagon || d0 ^ d1) {
				if(d0) array_push(mesh_data.links, new MeshedLink(p0, p3, spring));
				if(d1) array_push(mesh_data.links, new MeshedLink(p1, p2, spring));
			}
		}
		
		if(is_surface(cont)) surface_free(cont);
	}
	
	static Mesh_build_Triangulate = function(surf) {
		var sample = getInputData( 1);
		var seed   = getInputData( 9);
		var _rand  = getInputData(10);
		
		if(!inputs[0].value_from) return;
		if(is_array(surf)) surf = surf[0];
		
		var ww = surface_get_width_safe(surf);
		var hh = surface_get_height_safe(surf);
		
		var _m = attributes.mesh_bound;
		if(array_length(_m) < 3) return;
		
		var _mb	= array_length(_m);
		var ind	= 0;
		
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
		
		var gw = ww / sample / 3 * _rand;
		var gh = hh / sample / 3 * _rand;
		
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
		var _i = 0;
		var _sp = min(ww, hh) / sample;
		
		for( var i = 0, n = _mb; i < n; i++ ) {
			mesh_data.points[_i] = new MeshedPoint(_i, _m[i][0], _m[i][1]); _i++;
			
			var _p0 = _m[i];
			var _p1 = _m[(i + 1) % n];
			var _ds = point_distance(_p0[0], _p0[1], _p1[0], _p1[1]);
			var _sm = round(_ds / _sp);
			for( var j = 0; j < _sm; j++ ) {
				mesh_data.points[_i] = new MeshedPoint(_i, lerp(_p0[0], _p1[0], j / _sm), lerp(_p0[1], _p1[1], j / _sm)); _i++;
			}
		}
			
		for( var i = 0, n = array_length(_p); i < n; i++ ) {
			mesh_data.points[_i] = new MeshedPoint(_i, _p[i][0], _p[i][1]); _i++;
		}
		
		var _t = delaunay_triangulation_c(mesh_data.points, _m);
		
		for( var i = 0, n = array_length(_t); i < n; i++ ) {
			var t = _t[i];
			
			array_push(mesh_data.tris,  new MeshedTriangle(t[0], t[1], t[2]));
			
			array_push(mesh_data.links, new MeshedLink(t[0], t[1]));
			array_push(mesh_data.links, new MeshedLink(t[1], t[2]));
			array_push(mesh_data.links, new MeshedLink(t[2], t[0]));
		}
	}
	
	static Mesh_build = function(_render = true) {
		var _inSurf = getInputData(0);
		var _type   = getInputData(8);
		
		if(_render) {
			recordAction_variable_change(self, "points",    points).setName("Build Mesh").setRef(self);
			recordAction_variable_change(self, "mesh_data", mesh_data).setRef(self);
		}
		
		points    = [];
		mesh_data = new MeshedSurface();
		
		switch(_type) {
			case 0 : Mesh_build_RegularTri(_inSurf);  break;
			case 1 : Mesh_build_Triangulate(_inSurf); break;
		}
		
		for(var i = 0; i < array_length(mesh_data.tris); i++)
			mesh_data.tris[i].initSurface(is_array(_inSurf)? _inSurf[0] : _inSurf);
		
		if(_render) triggerRender();
		
		if(loadPin != noone) {
			for( var i = 0, n = array_length(loadPin); i < n; i++ ) {
				var ind = loadPin[i];
				if(ind < array_length(points))
					points[ind].pin = true;
			}
			
			loadPin = noone;
		}
	}
	
	static control_affectPoint = function(c, p) {
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
		var lStr = getInputData(6);
		
		for(var i = control_index, n = array_length(inputs); i < n; i++) {
			var c = getInputData(i);
			
			for( var j = 0, m = array_length(mesh_data.points); j < m; j++ ) {
				if(mesh_data.points[j] == 0) continue;
				control_affectPoint(c, mesh_data.points[j]);
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
	
	////- Update
	
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING) return;
		
		if(index == 0 && array_empty(mesh_data.tris))
			Mesh_build();
	}
	
	static step = function() {
		var _type = getInputData(8);
		
		inputs[ 2].setVisible(_type == 0);
		inputs[ 4].setVisible(_type == 0);
		inputs[ 7].setVisible(_type == 0);
		inputs[10].setVisible(_type == 1);
		
			 if(_type == 0) tools = tools_edit;
		else if(_type == 1) tools = tools_mesh;
	}
	
	static processData = function(_outData, _data, _output_index, _array_index) {
		if(will_triangluate) {
			Mesh_build(false);
			will_triangluate = false;
		}
		
		var _outSurf = _outData[0];
		var _inSurf  = _data[0];
		
		mesh_data.surface = inputs_data[0];
		if(!is_surface(_inSurf)) return [ _outSurf, mesh_data ];
		
		mesh_data.controls = [];
		for(var i = control_index; i < array_length(inputs); i++) {
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
		
		var _tris = array_length(mesh_data.tris), _t;
		mesh_data.triangles = array_verify(mesh_data.triangles, _tris);
		
		for(var i = 0; i < _tris; i++) {
			_t = mesh_data.tris[i];
			mesh_data.triangles[i] = [ _t.p0, _t.p1, _t.p2 ];
		}
		
		return [ _outSurf, mesh_data ];
	}
	
	////- Serialize
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for(var i = control_index; i < array_length(_inputs); i++) {
			var inp = createControl();
			inp.applyDeserialize(_inputs[i]);
		}
	}
	
	static attributeSerialize = function() {
		var att = {};
		
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
		if(struct_has(attr, "mesh_bound"))  attributes.mesh_bound = attr.mesh_bound;
	}
	
	static postLoad = function() {
		will_triangluate = true;
	}
}