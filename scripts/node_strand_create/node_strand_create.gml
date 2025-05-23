#region
	FN_NODE_TOOL_INVOKE {
		hotkeyTool("Node_Strand_Create", "Push",    "P");
		hotkeyTool("Node_Strand_Create", "Comb",    "C");
		hotkeyTool("Node_Strand_Create", "Stretch", "S");
		hotkeyTool("Node_Strand_Create", "Shorten", "D");
		hotkeyTool("Node_Strand_Create", "Grab",    "G");
	});
#endregion

function Node_Strand_Create(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Strand Create";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	
	update_on_frame      = true;
	manual_ungroupable	 = false;
	
	newInput(10, nodeValueSeed());
	
	////- Generation
	
	newInput( 0, nodeValue_Enum_Scroll( "Source", 0, [ "Point", "Path", "Mesh" ]));
	newInput( 1, nodeValue_Int(         "Density", 8, "How many strands to generate."));
	newInput( 5, nodeValue_PathNode(    "Path"));
	newInput( 6, nodeValue_Vec2(        "Position", [ 0, 0 ]));
	newInput( 7, nodeValue_Enum_Button( "Side", 0, [ "Inner", "Outer", "Both" ]));
	newInput(13, nodeValue(             "Mesh",         self, CONNECT_TYPE.input, VALUE_TYPE.mesh, noone));
	newInput(14, nodeValue_Enum_Scroll( "Distribution", 0, [ "Uniform", "Random" ]));
	newInput(15, nodeValue_Trigger(     "Bake hair", "Prevent strand reseting to apply manual modification. Unbaking will remove all changes."))
		.setDisplay(VALUE_DISPLAY.button, { name: "Bake", UI : true, onClick: function() /*=>*/ { 
			attributes.use_groom = !attributes.use_groom; 
			if(attributes.use_groom) groomed = strands.clone();
			strandUpdate(true);
		} });
		
	////- Strand
	
	newInput( 2, nodeValue_Vec2(            "Length", [ 4, 4 ]));
	newInput( 3, nodeValue_Int(             "Segment", 4));
	newInput(18, nodeValue_Rotation_Random( "Direction", ROTATION_RANDOM_DEF_0_360));
	newInput( 4, nodeValue_Slider(          "Elasticity", 0.05)).setTooltip("Length preservation, the higher the value the easier it is to stretch each segment.");
	newInput( 8, nodeValue_Slider(          "Spring", 0.8 ));
	newInput( 9, nodeValue_Slider(          "Structure", 0.2 )).setTooltip("The ability to keep its original shape.");
	newInput(17, nodeValue_Vec2(            "Root Strength", [-1, -1])).setTooltip("The force required to break strand from its root. Set to -1 to make strand infinitely strong.");
	newInput(19, nodeValue_Float(           "Restitution", .01)).setTooltip("Minimum speed before the strand stops moving completely.");
	
	////- Curl
	
	newInput(11, nodeValue_Float(  "Curl frequency", 0));
	newInput(12, nodeValue_Slider( "Curliness", 1));
	
	////- Preview
	
	newInput(16, nodeValue_Bool("View fix hair", false));
	
	//// inputs 20
	
	newOutput(0, nodeValue_Output("Strand", VALUE_TYPE.strands, noone));
	
	input_display_list = [ 10, 
		["Generation",	false], 0, 1, 5, 6, 7, 13, 14, 15, 
		["Strand",		false], 2, 3, 18, 4, 8, 9, 17, 19, 
		["Curl",		false], 11, 12, 
		["Preview",		 true], 16, 
	];
	
	attributes.use_groom = false;
	groomed = new StrandMesh();
	strands = new StrandMesh();
	
	attributes.show_strand = true;
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, [ "Draw Strand", function() /*=>*/ {return attributes.show_strand}, new checkBox(function() /*=>*/ {return toggleAttribute("show_strand")}) ]);
	
	#region ---- tools ----
		tool_push = new NodeTool( "Push", THEME.strand_push )
			.addSetting("Radius",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_push.attribute.radius   = v; }, "radius",   6)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_push.attribute.strength = v; }, "strength", 0.2)
			.addSetting("Falloff",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_push.attribute.fall     = v; }, "fall",     0.1)
			.addSetting("Fix length", VALUE_TYPE.boolean,	function( ) /*=>*/ { tool_push.attribute.fix      = !tool_push.attribute.fix; }, "fix", false)
	
		tool_comb = new NodeTool( "Comb", THEME.strand_comb )
			.addSetting("Width",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_comb.attribute.width    = v; }, "width",    8)
			.addSetting("Thick",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_comb.attribute.thick    = v; }, "thick",    4)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_comb.attribute.strength = v; }, "strength", 0.75)
	
		tool_stretch = new NodeTool( "Stretch", THEME.strand_stretch )
			.addSetting("Radius",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_stretch.attribute.radius   = v; }, "radius",   6)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_stretch.attribute.strength = v; }, "strength", 0.5)
			.addSetting("Falloff",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_stretch.attribute.fall     = v; }, "fall",     0.1)
	
		tool_cut = new NodeTool( "Shorten", THEME.strand_cut )
			.addSetting("Radius",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_cut.attribute.radius   = v; }, "radius",   6)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_cut.attribute.strength = v; }, "strength", 0.5)
			.addSetting("Falloff",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_cut.attribute.fall     = v; }, "fall",     0.1)
	
		tool_grab = new NodeTool( "Grab", THEME.strand_grab )
			.addSetting("Radius",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_grab.attribute.radius   = v; }, "radius",   4)
			.addSetting("Strength",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_grab.attribute.strength = v; }, "strength", 1)
			.addSetting("Falloff",	  VALUE_TYPE.float,		function(v) /*=>*/ { tool_grab.attribute.fall     = v; }, "fall",     0.2)
	
		groomTools = [
			tool_push,
			tool_comb,
			tool_stretch,
			tool_cut,
			tool_grab,
		];
	
		tool_dragging = noone;
		tool_mx       = 0;
		tool_my       = 0;
		tool_dmx      = 0;
		tool_dmy      = 0;
		tool_dir      = 0;
		tool_dir_fix  = 0;
		tool_dir_to   = 0;
		tool_grabbing = [];
	#endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _typ = getInputData(0);
		var _pre = getInputData(16);
		if(!attributes.use_groom && attributes.show_strand) strands.draw(_x, _y, _s, _pre);
		
		tools = attributes.use_groom? groomTools : -1;
		
		if(_typ == 0) {
			if(tool_dragging == noone) InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			
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
					var p = array_last(h.points);
						
					var d = point_distance(p.x, p.y, tool_mx, tool_my);
					if(d > rad * (1 + fall)) continue;
					var fl = clamp((rad * (1 + fall) - d) / (rad * fall * 2), 0, 1);
						
					array_push(tool_grabbing, [ h, p, fl ]);
				}
			}
		} 
		
		
		tool_dmx = __mx;
		tool_dmy = __my;
	}
	
	////- Nodes
	
	static step = function() {
		var _typ = getInputData(0);
		
		inputs[15].editWidget.text  = attributes.use_groom? "Unbake" : "Bake";
		inputs[15].editWidget.blend = attributes.use_groom? COLORS._main_value_negative : COLORS._main_value_positive;
	}
	
	static strandUpdate = function(willReset = false) {
		var _sed = getInputData(10);
		
		var _typ = getInputData( 0);
		var _den = getInputData( 1);
		var _pth = getInputData( 5);
		var _pos = getInputData( 6);
		var _sid = getInputData( 7);
		var _msh = getInputData(13);
		var _rnd = getInputData(14);
		
		var _length = getInputData( 2);
		var _segmnt = getInputData( 3);
		var _direct = getInputData(18);
		var _tenson = getInputData( 4);
		var _spring = getInputData( 8);
		var _struct = getInputData( 9);
		var _rotstr = getInputData(17);
		var _restit = getInputData(19);
		
		var _crF = getInputData(11);
		var _crS = getInputData(12);
		var sx, sy, prog, dir;
		
		inputs[ 5].setVisible(_typ == 1, _typ == 1);
		inputs[ 7].setVisible(_typ == 1);
		inputs[13].setVisible(_typ == 2, _typ == 2);
		inputs[14].setVisible(_typ != 2);
		
		if(willReset) {
			if(attributes.use_groom) {
				strands = groomed.clone();
				outputs[0].setValue(strands);
				return;
			}
			
			strands = new StrandMesh();
		}
		
		outputs[0].setValue(strands);
		
		var lines = 1;
		
		switch(_typ) {
			case 0 : strands.loop = true; break;
			
			case 1 : 
				if(!struct_has(_pth, "getPointRatio")) return;
				
				var _p0 = _pth.getPointRatio(0);
				var _p1 = _pth.getPointRatio(0.999);
				strands.loop = abs(_p0.x - _p1.x) < 1 && abs(_p0.y - _p1.y) < 1;
				lines = _pth.getLineCount();
				break;
			
			case 2 :
				if(_msh == noone) return;
				strands.mesh = _msh;
				strands.loop = false;
				break;
		}
		
		var ind = 0;
		
		for( var k = 0; k < lines; k++ )
		for( var i = 0; i < _den; i++ ) {
			prog = i / _den;
			
			switch(_typ) {
				case 0 :
					sx  = _pos[0];
					sy  = _pos[1];
					dir = _rnd? rotation_random_eval_fast(_direct, _sed++) : 360 * prog;
					break;
					
				case 1 : 
					var rat = _rnd? random1D(_sed) : prog; _sed++;
					rat = clamp(rat, 0.01, 0.99);
					
					var _p = _pth.getPointRatio(rat, k);
					sx  = _pos[0] + _p.x;
					sy  = _pos[1] + _p.y;
					
					var _p0 = _pth.getPointRatio(clamp(rat - 0.001, 0, 1));
					var _p1 = _pth.getPointRatio(clamp(rat + 0.001, 0, 1));
					dir = point_direction(_p0.x, _p0.y, _p1.x, _p1.y) + 90;
					
					     if(_sid == 1) dir += 180;
					else if(_sid == 2) dir += 180 * (_rnd? choose(0, 1) : i % 2);
					break;
					
				case 2 : 
					var _p = strands.mesh.getRandomPoint(_sed); _sed += 5;
					sx  = _pos[0] + _p.x;
					sy  = _pos[1] + _p.y;
					dir = rotation_random_eval_fast(_direct, _sed++);
					break;
			}
			
			if(willReset || array_safe_get_fast(strands.hairs, i, noone) == noone) {
				var _len = random_range(_length[0], _length[1]);
				
				var hair = new Strand(sx, sy, _segmnt + 1, _len, dir, _crF, _crS);
				hair.rootStrength = random1D(hair.id, _rotstr[0], _rotstr[1]);
				strands.hairs[ind] = hair;
			}
			
			if(ind >= array_length(strands.hairs)) return;
			
			var h = strands.hairs[ind];
			h.setOrigin(sx, sy);
			h.tension		 = 1 - _tenson;
			h.spring		 = _spring;
			h.angularTension = _struct;
			h.restitution    = _restit;
			
			h.curl_freq		 = _crF;
			h.curl_size		 = _crS;
			
			ind++;
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		strandUpdate(IS_FIRST_FRAME);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strand_create, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
	
	////- Serialize
	
	static attributeSerialize = function() {
		var att = {};
		att.use_groom = attributes.use_groom;
		att.fixStrand = groomed.serialize();
		return att;
	}
	
	static attributeDeserialize = function(attr) {
		struct_append(attributes, attr); 
		
		if(struct_has(attr, "fixStrand"))
			groomed.deserialize(attr.fixStrand);
			
		attributes.use_groom = struct_try_get(attr, "use_groom", false);
	}
}