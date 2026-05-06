#region data
	global.MKBLAST_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_mkblast},
		color: function() /*=>*/ {return COLORS.node_blend_mkblast},
		widg:  function() /*=>*/ {return new mkblastBox()},
	}
	
#endregion

function Node_MK_Blast_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "MK Blast";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	is_simulation = true;
	
	seed       = 0;
	gravityDir = -90;
	dimension  = undefined;
	
	if(NODE_NEW_MANUAL) {
		var _flame   = nodeBuild("Node_MK_Blast_Flame",  x,       y, self);
		var _render  = nodeBuild("Node_MK_Blast_Render", x + 256, y, self);
		
		_render.inputs[0].setFrom(_flame.outputs[0]);
		
		addNode(_flame);
		addNode(_render);
	}
	
	////- =Inputs
	
	newInput(0, nodeValueSeed( VALUE_TYPE.integer  ));
	newInput(1, nodeValue_Rotation( "Gravity", -90 ));
	newInput(2, nodeValue_Dimension());
	
	input_display_list = [ s_MKFX, 0, 2, 
		[ "Physics", false ], 1, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ { dimension = dimension ?? inputs[2].getValue(); return dimension; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _dim = getDimension();
		var _cx  = _x + _dim[0] / 2 * _s;
		var _cy  = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my ));
	}
	
	static update = function() {
		seed       = inputs[0].getValue();
		gravityDir = inputs[1].getValue();
		dimension  = inputs[2].getValue();
	}
}

function MKBlast_Layer() constructor {
	x = 0;
	y = 0;
	colorize = undefined;
	flames   = [];
	
	static draw = function(_surfs, _mask = -1, _param = {}) {
		var _dim = surface_get_dimension(_surfs[0]);
		
		surface_set_target_ext(0, _surfs[0]);
		surface_set_target_ext(1, _surfs[2]);
			BLEND_OVERRIDE
			shader_set(sh_mk_blast_clear);
				draw_empty();
			shader_reset();
			BLEND_NORMAL
			
			for( var i = 0, m = array_length(flames); i < m; i++ ) {
				var _flm = flames[i];
				if(_mask != -1 && (_mask & _flm.mask) == 0) continue;
				_flm.draw();
			}
		surface_reset_target();
		
		surface_set_target(_surfs[1]);
			shader_set(sh_mk_blast_colorize);
			shader_set_2("dimension", _dim);
			shader_set_s("depthBase", _surfs[3]);
			shader_set_s("depth",     _surfs[2]);
			shader_set_i("useDepth",  _param.useDepth);
			shader_set_gradient(colorize);
			
			draw_surface(_surfs[0], 0, 0);
			
			shader_reset();
		surface_reset_target();
		
		surface_set_target(_surfs[3]);
			BLEND_MAX
			draw_surface(_surfs[2], 0, 0);
			BLEND_NORMAL
		surface_reset_target();
	}
	
}

enum MKBlast_Mask {
	flame = 1 << 0,
	smoke = 1 << 1, 
}

function MKBlast_Element() constructor {
	mask = 1;
	
	#region Life
		life      = 0;
		lifeTotal = 0;
		lifeRatio = 0;
	#endregion
	
	#region Position Data
		sx = 0; 
		sy = 0; 
		
		ex = 0; 
		ey = 0; 
		
		px = 0;
		py = 0;
		
		gx = 1;
		gy = 1;
	#endregion
	
	#region Transformation
		x = 0; 
		y = 0; 
		depth = 0;
		
		angle  = 0;
		angleS = 0;
		rotate = 0;
		
		size   = [0,8];
		aspect = [1,1];
	#endregion
	
	#region Physics
		speed      = 0;
		direction  = 0;
		
		gravity    = 0;
		gravityDir = -90;
		friction   = 0;
		
		moveType   = 0;
		moveCurve  = undefined;
			
		animCurve  = undefined;
	#endregion
	
	#region Rendering
		__p = [0,0];
		
		color   = c_white;
		texture = undefined;
		
		discard = false;
		level   = [0,1];
		normal  = [0,0];
		
		origin      = [0,0];
		originDim   = [1,1];
		perspective = 2;
	#endregion
	
	#region Blast
		blastRatio  = 0;
		radiusBlast = .4;
		
		doDecay     = true;
		decay       = 6;
	#endregion
	
	#region Shape
		shape    = 0;
	
		spiralSize      = 0;
		spiralIntensity = 0;
		spiralRotation  = 0;
		spiralPhase     = 0;
		spiralMultiply  = 1;
	
		arrowSize       = 0;
		lineThickness   = 2;
		lineShape       = [1];
		pathData        = [];
	#endregion
		
	static step = function() {
		var _life = max(life / lifeTotal, 0);
		var _blas = max((life - decay) / lifeTotal, 0);
		
		if(animCurve) _life = animCurve.get(_life);
		
		lifeRatio   = _life;
		blastRatio  = _blas;
		
		// Movement
		if(moveType == 1 && moveCurve != undefined) {
			var _tDist = speed * lifeTotal;
			var _cDist = moveCurve.get(clamp(_life, 0, 1)) * _tDist;
			
			x = sx + lengthdir_x(_cDist, direction) * gx;
			y = sy + lengthdir_y(_cDist, direction) * gy;
			
		} else {
			var _dist = (speed + max(0, speed - friction * life)) / 2 * life;
			x = sx + lengthdir_x(_dist, direction) * gx;
			y = sy + lengthdir_y(_dist, direction) * gy;
		}
		
		// Gravity
		x += lengthdir_x(gravity, gravityDir) * sqr(max(0, life));
		y += lengthdir_y(gravity, gravityDir) * sqr(max(0, life));
		
		px = x;
		py = y;
		
		angleS = direction;
	}
	
	static draw = function(_x = 0, _y = 0, _r = 0, _s = 1) {
		var rad = lerp(size[0], size[1], lifeRatio);
		var ro  = rad * _s;
		if(life < 0 || ro <= 0) return;
		
		var ars = ro * arrowSize;
		
		var xx = _x + x * _s;
		var yy = _y + y * _s;
		
		normal[0] = (x - origin[0]) / originDim[0] * perspective;
		normal[1] = (y - origin[1]) / originDim[1] * perspective;
		
		angle = angleS + lifeRatio * rotate;
		
		var blastRad = max(0, blastRatio) * radiusBlast;
		
		BLEND_MAX
		shader_set(sh_mk_blast_flameball);
			shader_set_i( "shapeIndex",      shape      );
			shader_set_i( "mask",            mask       );
			shader_set_f( "particleDepth",   yy + depth );
			
			shader_set_f( "innerRad",        doDecay? blastRad : 0 );
			shader_set_2( "origin",          normal    );
			shader_set_i( "discardBlack",    discard   );
			
			shader_set_f( "rotation",        angle     );
			shader_set_2( "scale",           aspect    );
			
			shader_set_f( "spiralSize",      spiralSize      );
			shader_set_f( "spiralPhase",     spiralPhase     );
			shader_set_f( "spiralIntensity", spiralIntensity );
			shader_set_f( "spiralRotation",  spiralRotation * life  );
			shader_set_i( "spiralMultiply",  spiralMultiply  );
			
			shader_set_i( "useTexture", is_surface(texture) );
			if(is_surface(texture)) shader_set_s("texture", texture);
			
			shader_set_2("level",    level);
			
			var cc = c_white;
			var aa = doDecay? 1 : 1 - clamp((life - decay) / lifeTotal, 0, 1);
			
			switch(shape) {
				case 0 : // Circle
					draw_sprite_ext(s_fx_pixel2, 0, xx, yy, ro, ro, 0, cc, aa); 
					break;
				
				case 1 : // Arrow
					var xc = xx + lengthdir_x(ars, angle + 180);
					var yc = yy + lengthdir_y(ars, angle + 180);
					
					var x0 = xx + lengthdir_x(ro, angle +   0);
					var y0 = yy + lengthdir_y(ro, angle +   0);
					
					var x1 = xx + lengthdir_x(ro, angle + 135);
					var y1 = yy + lengthdir_y(ro, angle + 135);
					
					var x2 = xx + lengthdir_x(ro, angle - 135);
					var y2 = yy + lengthdir_y(ro, angle - 135);
					
					draw_primitive_begin(pr_trianglelist);
						draw_vertex_texture_color(xc, yc, .5, .5, cc, aa);
						draw_vertex_texture_color(x0, y0,  1,  0, cc, aa);
						draw_vertex_texture_color(x1, y1,  0,  0, cc, aa);
						
						draw_vertex_texture_color(xc, yc, .5, .5, cc, aa);
						draw_vertex_texture_color(x0, y0,  1,  1, cc, aa);
						draw_vertex_texture_color(x2, y2,  0,  1, cc, aa);
					draw_primitive_end();
					break;
				
				case 2 : // Line
					shader_set_f_array("lineShape", lineShape);
					shader_set_2("textureRange", [0,1]);
					
					var x0 = xx + lengthdir_x(ro, angle);
					var y0 = yy + lengthdir_y(ro, angle);
					
					var x1 = xx + lengthdir_x(ro, angle + 180);
					var y1 = yy + lengthdir_y(ro, angle + 180);
					
					var dx = lengthdir_x(lineThickness / 2, angle + 90);
					var dy = lengthdir_y(lineThickness / 2, angle + 90);
					
					var _x0 = x0 + dx, _y0 = y0 + dy;
					var _x1 = x0 - dx, _y1 = y0 - dy;
					var _x2 = x1 + dx, _y2 = y1 + dy;
					var _x3 = x1 - dx, _y3 = y1 - dy;
					
					draw_primitive_begin(pr_trianglelist);
						draw_vertex_texture_color(_x0, _y0, 0, 0, cc, 1);
						draw_vertex_texture_color(_x1, _y1, 0, 1, cc, 1);
						draw_vertex_texture_color(_x2, _y2, 1, 0, cc, 1);
						
						draw_vertex_texture_color(_x1, _y1, 0, 1, cc, 1);
						draw_vertex_texture_color(_x2, _y2, 1, 0, cc, 1);
						draw_vertex_texture_color(_x3, _y3, 1, 1, cc, 1);
					draw_primitive_end();
					break;
					
				case 3 : // Path
					if(array_length(pathData) < 2) break;
					shader_set_f_array("lineShape", lineShape);
					
					var len = array_length(pathData);
					var ox = pathData[0][0];
					var oy = pathData[0][1];
					var nx = pathData[1][0];
					var ny = pathData[1][1];
					var od = point_direction(ox, oy, nx, ny);
					var nd;
					
					var rcos  = cos(angle);
					var rsin  = sin(angle);
					var trans = [
						 lifeRatio * rcos,  lifeRatio * rsin, 0, 0, 
						 lifeRatio * rsin, -lifeRatio * rcos, 0, 0, 
						                0,                 0, 1, 0, 
						               xx,                yy, 0, 1
					];
					
					var stl = 1 / (len - 1);
					
					matrix_set(matrix_world, trans);
					for( var i = 1; i < len; i++ ) {
						nx = pathData[i][0];
						ny = pathData[i][1];
						nd = point_direction(ox, oy, nx, ny);
						
						shader_set_2("textureRange", [(i-1) * stl, i * stl]);
						draw_primitive_begin(pr_trianglelist);
						draw_line_width2_angle(ox, oy, nx, ny, lineThickness, lineThickness, od+90, nd+90, cc, cc);
						draw_primitive_end();
						
						ox = nx;
						oy = ny;
						od = nd;
					}
					matrix_set(matrix_world, MATRIX_IDENTITY);
					
					break;
			}
		shader_reset();
		BLEND_NORMAL
		
	}
}
