function Node_Strand_Create(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Create";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	w     = 96;
	
	update_on_frame      = true;
	manual_ungroupable	 = false;
	
	inputs[| 0] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Point", "Path", "Mesh" ]);
	
	inputs[| 1] = nodeValue("Density", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8, "How many strands to generate.");
	
	inputs[| 2] = nodeValue("Length", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Segment", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4);
	
	inputs[| 4] = nodeValue("Elasticity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.05, "Length preservation, the higher the value the easier it is to stretch each segment.")
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone);
	
	inputs[| 6] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 7] = nodeValue("Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Inner", "Outer", "Both" ]);
	
	inputs[| 8] = nodeValue("Spring", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.8, "Angular stiffness, the higher the value the easier it is to bend each segment.")
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Structure", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2, "The ability to keep its original shape.")
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 10] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom_range(10000, 99999));
	
	inputs[| 11] = nodeValue("Curl frequency", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 12] = nodeValue("Curliness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 13] = nodeValue("Mesh", self, JUNCTION_CONNECT.input, VALUE_TYPE.mesh, noone);
	
	inputs[| 14] = nodeValue("Distribution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Uniform", "Random" ]);
	
	inputs[| 15] = nodeValue("Bake hair", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, 0, "Prevent strand reseting to apply manual modification. Unbaking will remove all changes.")
		.setDisplay(VALUE_DISPLAY.button, { name: "Bake", onClick: function() { 
			attributes.use_groom = !attributes.use_groom; 
			if(attributes.use_groom)
				groomed = strands.clone();
			strandUpdate(true);
		} });
	
	inputs[| 16] = nodeValue("View fix hair", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 17] = nodeValue("Root strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [-1, -1], "The force required to break strand from its root. Set to -1 to make strand infinitely strong.")
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue("Strand", self, JUNCTION_CONNECT.output, VALUE_TYPE.strands, noone);
	
	input_display_list = [ 10, 
		["Generation",	false], 0, 1, 5, 6, 7, 13, 14, 15, 
		["Strand",		false], 2, 3, 4, 8, 9, 17, 
		["Curl",		false], 11, 12, 
		["Preview",		 true], 16, 
	];
	
	attributes.use_groom = false;
	groomed = new StrandMesh();
	strands = new StrandMesh();
	
	#region ---- tools ----
		tool_push = new NodeTool( "Push", THEME.strand_push )
			.addSetting("Radius",	  VALUE_TYPE.float,		function(val) { tool_push.attribute.radius = val; }, "radius", 6)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(val) { tool_push.attribute.strength = val; }, "strength", 0.2)
			.addSetting("Falloff",	  VALUE_TYPE.float,		function(val) { tool_push.attribute.fall = val; }, "fall", 0.1)
			.addSetting("Fix length", VALUE_TYPE.boolean,	function() { tool_push.attribute.fix = !tool_push.attribute.fix; }, "fix", false)
	
		tool_comb = new NodeTool( "Comb", THEME.strand_comb )
			.addSetting("Width",	  VALUE_TYPE.float,		function(val) { tool_comb.attribute.width = val; }, "width", 8)
			.addSetting("Thick",	  VALUE_TYPE.float,		function(val) { tool_comb.attribute.thick = val; }, "thick", 4)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(val) { tool_comb.attribute.strength = val; }, "strength", 0.75)
	
		tool_stretch = new NodeTool( "Stretch", THEME.strand_stretch )
			.addSetting("Radius",	  VALUE_TYPE.float,		function(val) { tool_stretch.attribute.radius = val; }, "radius", 6)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(val) { tool_stretch.attribute.strength = val; }, "strength", 0.5)
			.addSetting("Falloff",	  VALUE_TYPE.float,		function(val) { tool_stretch.attribute.fall = val; }, "fall", 0.1)
	
		tool_cut = new NodeTool( "Shorten", THEME.strand_cut )
			.addSetting("Radius",	  VALUE_TYPE.float,		function(val) { tool_cut.attribute.radius = val; }, "radius", 6)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(val) { tool_cut.attribute.strength = val; }, "strength", 0.5)
			.addSetting("Falloff",	  VALUE_TYPE.float,		function(val) { tool_cut.attribute.fall = val; }, "fall", 0.1)
	
		tool_grab = new NodeTool( "Grab", THEME.strand_grab )
			.addSetting("Radius",	  VALUE_TYPE.float,		function(val) { tool_grab.attribute.radius = val; }, "radius", 4)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(val) { tool_grab.attribute.strength = val; }, "strength", 1)
			.addSetting("Falloff",	  VALUE_TYPE.float,		function(val) { tool_grab.attribute.fall = val; }, "fall", 0.2)
	
		groomTools = [
			tool_push,
			tool_comb,
			tool_stretch,
			tool_cut,
			tool_grab,
		];
	
		tool_dragging = noone;
		tool_mx  = 0;
		tool_my  = 0;
		tool_dmx = 0;
		tool_dmy = 0;
		tool_dir = 0;
		tool_dir_fix = 0;
		tool_dir_to = 0;
	
		tool_grabbing = [];
	#endregion
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _typ = getInputData(0);
		var _pre = getInputData(16);
		if(!attributes.use_groom) 
			strands.draw(_x, _y, _s, _pre);
		
		tools = attributes.use_groom? groomTools : -1;
		
		if(_typ == 0) {
			if(tool_dragging == noone)
				inputs[| 6].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		} else if(_typ == 1) {
			var _pth = getInputData(5);
			var _sid = getInputData(7);
			
			if(!struct_has(_pth, "getPointRatio")) return;
			var lines = struct_has(_pth, "getLineCount")? _pth.getLineCount() : 1;
			
			draw_set_color(COLORS._main_accent);
			var ox, oy, nx, ny;
			for( var l = 0; l < lines; l++ )
			for( var i = 0; i < 32; i++ ) {
				var _p = _pth.getPointRatio(i / 32, l);
				nx = _x + _p.x * _s;
				ny = _y + _p.y * _s;
				
				if(i) draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
		} else if(_typ == 2) {
			var _msh = getInputData(13);
			if(_msh == noone) return;
			
			draw_set_color(COLORS._main_accent);
			_msh.draw(_x, _y, _s);
		}
		
		if(!attributes.use_groom) return;
		groomed.draw(_x, _y, _s, _pre, true);
		
		var __mx = (_mx - _x) / _s;
		var __my = (_my - _y) / _s;
		
		if(tool_dmx != __mx || tool_dmy != __my) {
			tool_dir_to = point_direction(tool_dmx, tool_dmy, __mx, __my);
			tool_dir = lerp_angle(tool_dir, tool_dir_to, 10);
		}
				
		if(tool_dragging == tool_push) {
			var rad  = tool_push.attribute.radius;
			var fall = tool_push.attribute.fall;
			var fix  = tool_push.attribute.fix;
			var stn  = tool_push.attribute.strength;
			var dx   = __mx - tool_mx;
			var dy   = __my - tool_my;
			
			if(dx != 0 || dy != 0)
			for( var i = 0, n = array_length(groomed.hairs); i < n; i++ ) {
				var h = groomed.hairs[i];
				for( var j = 1; j < array_length(h.points); j++ ) {
					var p = h.points[j];
					
					var d = point_distance(p.x, p.y, __mx, __my);
					if(d > rad * (1 + fall)) continue;
					
					var fl = 1 - clamp((d - rad * (1 + fall)) / (rad * fall * 2), 0, 1);
					
					p.x += dx * stn * fl;
					p.y += dy * stn * fl;
				}
			}
			
			tool_mx = __mx;
			tool_my = __my;
			
			if(mouse_release(mb_left)) {
				groomed.freeze(fix);
				tool_dragging = noone;
			}
		} else if(tool_dragging == tool_comb) {
			var wid = tool_comb.attribute.width;
			var thk = tool_comb.attribute.thick;
			var stn = tool_comb.attribute.strength;
			stn = power(stn, 2);
			
			var p0x = __mx + lengthdir_x(wid, tool_dir_fix + 90);
			var p0y = __my + lengthdir_y(wid, tool_dir_fix + 90);
			var p1x = __mx + lengthdir_x(wid, tool_dir_fix - 90);
			var p1y = __my + lengthdir_y(wid, tool_dir_fix - 90);
			
			if(tool_dmx != __mx || tool_dmy != __my)
			for( var i = 0, n = array_length(groomed.hairs); i < n; i++ ) {
				var h = groomed.hairs[i];
				var op, np;
				
				for( var j = 0; j < array_length(h.points); j++ ) {
					np = h.points[j];
					np.targetAngle = tool_dir_fix;
					var dst = distance_to_line(np.x, np.y, p0x, p0y, p1x, p1y);
					
					if(j) {
						var dir = np.storeAngle;
						var dis = np.storeDistance;
						
						var ang = dst < thk? lerp_angle_direct(dir, tool_dir_fix, lerp(stn, 1, (1 - dst) / thk)) : dir;
						np.storeAngle = ang;
						
						np.x = op.x + lengthdir_x(dis, np.storeAngle);
						np.y = op.y + lengthdir_y(dis, np.storeAngle);
					}
					
					op = np;
				}
			}
			
			if(mouse_release(mb_left)) {
				groomed.freeze(true);
				tool_dragging = noone;
			}
		} else if(tool_dragging == tool_stretch || tool_dragging == tool_cut) {
			var rad  = tool_dragging.attribute.radius;
			var fall = tool_dragging.attribute.fall;
			var stn  = tool_dragging.attribute.strength;
			stn = tool_dragging == tool_stretch? stn / game_get_speed(gamespeed_fps) : stn / 10;
			
			for( var i = 0, n = array_length(groomed.hairs); i < n; i++ ) {
				var h = groomed.hairs[i];
				var op, np;
				var amo = array_length(h.points);
				var l = [];
				
				for( var j = 0; j < amo; j++ ) {
					np = h.points[j];
					if(j) l[j] = point_distance(op.x, op.y, np.x, np.y);
					op = np;
				}
				
				for( var j = 0; j < amo; j++ ) {
					var ind = tool_dragging == tool_stretch? j : amo - 1 - j;
					np = h.points[ind];
					
					if(j) {
						var dir = point_direction(op.x, op.y, np.x, np.y);
						var dis = l[ind];
						var mds = point_distance(__mx, __my, (op.x + np.x) / 2, (op.y + np.y) / 2);
						
						if(mds < rad * (1 + fall)) {
							var fl = clamp((rad * (1 + fall) - mds) / (rad * fall * 2), 0, 1);
							var st = dis * (1 + fl * stn * (tool_dragging == tool_stretch? 1 : -1));
							
							if(tool_dragging == tool_stretch)
								l[j] = st;
							else 
								l[amo - 1 - j] = st;
							//print(string(st) + ": " + string(dis) + ", " + 
							//	string(1 + fl * stn * (tool_dragging == 2? 1 : -1)));
						}
					}
					
					op = np;
				}
				
				for( var j = 0; j < amo; j++ ) {
					np = h.points[j];
					if(j) {
						var dr = point_direction(op.x, op.y, np.x, np.y);
						np.x = op.x + lengthdir_x(l[j], dr);
						np.y = op.y + lengthdir_y(l[j], dr);
					}
					op = np;
				}
				
			}
			
			if(mouse_release(mb_left)) {
				groomed.freeze(false);
				tool_dragging = noone;
			}
		} else if(tool_dragging == tool_grab) {
			var rad  = tool_grab.attribute.radius;
			var stn  = tool_grab.attribute.strength;
			var dx   = __mx - tool_mx;
			var dy   = __my - tool_my;
			
			if(dx != 0 || dy != 0)
			for( var i = 0, n = array_length(tool_grabbing); i < n; i++ ) {
				var h   = tool_grabbing[i][0];
				var p   = tool_grabbing[i][1];
				var inf = tool_grabbing[i][2];
				
				p.ikx = p.x + dx * inf;
				p.iky = p.y + dy * inf;
				
				h.FABRIK(4);
			}
			
			tool_mx = __mx;
			tool_my = __my;
			
			if(mouse_release(mb_left)) {
				groomed.freeze(true);
				tool_dragging = noone;
			}
		} 
				
		if(isUsingTool(0)) {
			var rad  = tool_push.attribute.radius;
			var fall = tool_push.attribute.fall;
			
			draw_set_color(COLORS._main_accent);
			draw_circle_prec(_mx, _my, rad * _s, true);
			draw_circle_dash(_mx, _my, rad * _s * (1 - fall), true);
			draw_circle_dash(_mx, _my, rad * _s * (1 + fall), true);
			
			if(mouse_press(mb_left, active)) {
				tool_dragging = tool_push;
				tool_mx = (_mx - _x) / _s;
				tool_my = (_my - _y) / _s;
			}
		} else if(isUsingTool(1)) {
			if(tool_dragging == noone)
				tool_dir_fix = tool_dir;
			var wid = tool_comb.attribute.width;
			var thk = tool_comb.attribute.thick;
			
			var p0x = _mx + lengthdir_x(wid * _s, tool_dir_fix + 90);
			var p0y = _my + lengthdir_y(wid * _s, tool_dir_fix + 90);
			var p1x = _mx + lengthdir_x(wid * _s, tool_dir_fix - 90);
			var p1y = _my + lengthdir_y(wid * _s, tool_dir_fix - 90);
			
			draw_set_color(COLORS._main_accent);
			draw_line(p0x, p0y, p1x, p1y);
			
			var _p0x = p0x + lengthdir_x(thk * _s, tool_dir_fix);
			var _p0y = p0y + lengthdir_y(thk * _s, tool_dir_fix);
			var _p1x = p1x + lengthdir_x(thk * _s, tool_dir_fix);
			var _p1y = p1y + lengthdir_y(thk * _s, tool_dir_fix);
			
			draw_line_dashed(_p0x, _p0y, _p1x, _p1y);
			
			var __p0x = p0x - lengthdir_x(thk * _s, tool_dir_fix);
			var __p0y = p0y - lengthdir_y(thk * _s, tool_dir_fix);
			var __p1x = p1x - lengthdir_x(thk * _s, tool_dir_fix);
			var __p1y = p1y - lengthdir_y(thk * _s, tool_dir_fix);
			
			draw_line_dashed(__p0x, __p0y, __p1x, __p1y);
			
			draw_line_dashed(_p0x, _p0y, __p0x, __p0y);
			draw_line_dashed(_p1x, _p1y, __p1x, __p1y);
			
			if(mouse_press(mb_left, active)) {
				groomed.store();
				tool_dragging = tool_comb;
				tool_mx = (_mx - _x) / _s;
				tool_my = (_my - _y) / _s;
			}
		} else if(isUsingTool(2) || isUsingTool(3)) {
			var rad  = isUsingTool(2)? tool_stretch.attribute.radius : tool_cut.attribute.radius;
			var fall = isUsingTool(2)? tool_stretch.attribute.fall   : tool_cut.attribute.fall;
			
			draw_set_color(COLORS._main_accent);
			draw_circle_prec(_mx, _my, rad * _s, true);
			draw_circle_dash(_mx, _my, rad * _s * (1 - fall), true);
			draw_circle_dash(_mx, _my, rad * _s * (1 + fall), true);
			
			if(mouse_press(mb_left, active)) {
				tool_dragging = isUsingTool(2)? tool_stretch : tool_cut;
				tool_mx = (_mx - _x) / _s;
				tool_my = (_my - _y) / _s;
			}
		} else if(isUsingTool(4)) {
			var rad  = tool_grab.attribute.radius;
			var fall = tool_grab.attribute.fall;
			
			draw_set_color(COLORS._main_accent);
			draw_circle_prec(_mx, _my, rad * _s, true);
			draw_circle_dash(_mx, _my, rad * _s * (1 - fall), true);
			draw_circle_dash(_mx, _my, rad * _s * (1 + fall), true);
			
			if(mouse_press(mb_left, active)) {
				tool_dragging = tool_grab;
				tool_mx = (_mx - _x) / _s;
				tool_my = (_my - _y) / _s;
				
				tool_grabbing = [];
				for( var i = 0, n = array_length(groomed.hairs); i < n; i++ ) {
					var h = groomed.hairs[i];
					var p = h.points[array_length(h.points) - 1];
						
					var d = point_distance(p.x, p.y, tool_mx, tool_my);
					if(d > rad * (1 + fall)) continue;
					var fl = clamp((rad * (1 + fall) - d) / (rad * fall * 2), 0, 1);
						
					array_push(tool_grabbing, [ h, p, fl ]);
				}
			}
		} 
		
		
		tool_dmx = __mx;
		tool_dmy = __my;
	} #endregion
	
	static step = function() { #region
		var _typ = getInputData(0);
		
		inputs[|  5].setVisible(_typ == 1, _typ == 1);
		inputs[|  7].setVisible(_typ == 1);
		inputs[| 13].setVisible(_typ == 2, _typ == 2);
		inputs[| 14].setVisible(_typ != 2);
		
		inputs[| 15].editWidget.text  = attributes.use_groom? "Unbake" : "Bake";
		inputs[| 15].editWidget.blend = attributes.use_groom? COLORS._main_value_negative : COLORS._main_value_positive;
	} #endregion
	
	static strandUpdate = function(willReset = false) { #region
		var _typ = getInputData(0);
		var _den = getInputData(1);
		var _len = getInputData(2);
		var _seg = getInputData(3); _seg = _seg + 1;
		var _ten = getInputData(4); _ten = 1 - _ten;
		var _pth = getInputData(5);
		var _pos = getInputData(6);
		var _sid = getInputData(7);
		var _spr = getInputData(8);
		var _ang = getInputData(9);
		var _sed = getInputData(10);
		var _crF = getInputData(11);
		var _crS = getInputData(12);
		var _msh = getInputData(13);
		var _rnd = getInputData(14);
		var _rot = getInputData(17);
		var sx, sy, prog, dir;
		
		if(willReset) {
			if(attributes.use_groom) {
				strands = groomed.clone();
				outputs[| 0].setValue(strands);
				return;
			}
			
			strands = new StrandMesh();
		}
		
		outputs[| 0].setValue(strands);
		
		if(_typ == 0)
			strands.loop = true;
		else if(_typ == 1) {
			if(!struct_has(_pth, "getPointRatio"))
				return;
			
			var _p0 = _pth.getPointRatio(0);
			var _p1 = _pth.getPointRatio(0.999);
			strands.loop = abs(_p0.x - _p1.x) < 1 && abs(_p0.y - _p1.y) < 1;
		} else if(_typ == 2) {
			if(_msh == noone) return;
			strands.mesh = _msh;
			strands.loop = false;
		}
		
		var lines = 1;
		if(_typ == 1 && struct_has(_pth, "getLineCount"))
			lines = _pth.getLineCount();
		
		var ind = 0;
		
		for( var k = 0; k < lines; k++ )
		for( var i = 0; i < _den; i++ ) {
			prog = i / _den;
			
			if(_typ == 0) {
				sx  = _pos[0];
				sy  = _pos[1];
				dir = _rnd? random1D(_sed, 0, 360) : 360 * prog; _sed++;
			} else if(_typ == 1) {
				var rat = _rnd? random1D(_sed) : prog; _sed++;
				rat = clamp(rat, 0.01, 0.99);
				
				var _p = _pth.getPointRatio(rat, k);
				sx  = _pos[0] + _p.x;
				sy  = _pos[1] + _p.y;
				
				var _p0 = _pth.getPointRatio(clamp(rat - 0.001, 0, 1));
				var _p1 = _pth.getPointRatio(clamp(rat + 0.001, 0, 1));
				dir = point_direction(_p0.x, _p0.y, _p1.x, _p1.y) + 90;
				
				if(_sid == 1)	   dir += 180;
				else if(_sid == 2) dir += 180 * (_rnd? choose(0, 1) : i % 2);
			} else if(_typ == 2) {
				var _p = strands.mesh.getRandomPoint(_sed); _sed += 5;
				sx  = _pos[0] + _p.x;
				sy  = _pos[1] + _p.y;
				dir = irandom(360);
			}
			
			if(willReset || array_safe_get(strands.hairs, i, noone) == noone) {
				var h = new Strand(sx, sy, _seg, random_range(_len[0], _len[1]), dir, _crF, _crS);
				h.rootStrength = random1D(h.id, _rot[0], _rot[1]);
				strands.hairs[ind] = h;
			}
			
			if(ind >= array_length(strands.hairs)) return;
			
			var h = strands.hairs[ind];
			h.setOrigin(sx, sy);
			h.tension		 = _ten;
			h.spring		 = _spr;
			h.angularTension = _ang;
			h.curl_freq		 = _crF;
			h.curl_size		 = _crS;
			
			ind++;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		strandUpdate(IS_FIRST_FRAME);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strandSim_create, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
	
	static attributeSerialize = function() { #region
		var att = {};
		att.use_groom = attributes.use_groom;
		att.fixStrand = groomed.serialize();
		return att;
	} #endregion
	
	static attributeDeserialize = function(attr) { #region
		if(struct_has(attr, "fixStrand"))
			groomed.deserialize(attr.fixStrand);
			
		attributes.use_groom = struct_try_get(attr, "use_groom", false);
	} #endregion
}