#macro STRAND_EFFECTOR_PRE																										\
	var _str = getInputData(0);																							\
	var _typ = getInputData(1);																							\
	var _pos = getInputData(2);																							\
	var _ran = getInputData(3);																							\
	var _dir = getInputData(4);																							\
	var _fal = getInputData(5); var fal = _ran * _fal;																	\
																																\
	if(_str == noone) return;																									\
	var __str = _str;																											\
	if(!is_array(_str)) __str = [ _str ];																						\
																																\
	for( var k = 0; k < array_length(__str); k++ )																				\
	for( var i = 0, n = array_length(__str[k].hairs); i < n; i++ ) {																	\
		var h = __str[k].hairs[i];																								\
																																\
		for( var j = 1; j < array_length(h.points); j++ ) {																		\
			var pnt  = h.points[j];																								\
			var mulp = 1, dis;																									\
																																\
			if(_typ == 0)																										\
				dis = point_distance(_pos[0], _pos[1], pnt.x, pnt.y);															\
			else if (_typ == 1)																									\
				dis = distance_to_line_infinite(pnt.x, pnt.y, _pos[0], _pos[1], _pos1[0], _pos1[1]);							\
																																\
			if(dis > _ran + fal) continue;																						\
			if(dis < _ran - fal) 																								\
				mulp = 1;																										\
			else 																												\
				mulp = (dis - (_ran - fal)) / (fal * 2);																		

#macro STRAND_EFFECTOR_POST																										\
			}																													\
	}																															\
	outputs[| 0].setValue(_str);																								

function _Node_Strand_Affector(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Affector";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Strand", self, JUNCTION_CONNECT.input, VALUE_TYPE.strands, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Point", "Band" ]);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4);
	
	inputs[| 4] = nodeValue("Direction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 5] = nodeValue("Falloff", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Strand", self, JUNCTION_CONNECT.output, VALUE_TYPE.strands, noone);
	
	input_fix_len = ds_list_size(inputs);
	
	input_display_list = [ 0, 
		["Shape",		false], 1, 2, 3, 4, 5, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _typ = getInputData(1);
		var _pos = getInputData(2);
		var _ran = getInputData(3);
		var _dir = getInputData(4);
		var _fal = getInputData(5);
		
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
		
		_ran *= _s;
		var fal = _fal * _ran;
		
		draw_set_color(COLORS._main_accent);
		
		if(_typ == 0) {
			draw_circle_prec(px, py, _ran, true);
			
			var x0 = px - (_ran + fal);
			var y0 = py - (_ran + fal);
			var x1 = px + (_ran + fal);
			var y1 = py + (_ran + fal);
			draw_ellipse_dash(x0, y0, x1, y1);
		
			var x0 = px - (_ran - fal);
			var y0 = py - (_ran - fal);
			var x1 = px + (_ran - fal);
			var y1 = py + (_ran - fal);
			draw_ellipse_dash(x0, y0, x1, y1);
		} else if(_typ == 1) {
			_dir += 90;
			
			var _px = px + lengthdir_x(_ran, _dir); var _py = py + lengthdir_y(_ran, _dir);
			
			var px0 = _px + lengthdir_x(1000, _dir - 90); var py0 = _py + lengthdir_y(1000, _dir - 90);
			var px1 = _px + lengthdir_x(1000, _dir + 90); var py1 = _py + lengthdir_y(1000, _dir + 90);
			
			draw_line(px0, py0, px1, py1);
			
			var _px = px - lengthdir_x(_ran, _dir); var _py = py - lengthdir_y(_ran, _dir);
			
			var px0 = _px + lengthdir_x(1000, _dir - 90); var py0 = _py + lengthdir_y(1000, _dir - 90);
			var px1 = _px + lengthdir_x(1000, _dir + 90); var py1 = _py + lengthdir_y(1000, _dir + 90);
			
			draw_line(px0, py0, px1, py1);
			
			//
			var _px = px + lengthdir_x(_ran - fal, _dir); var _py = py + lengthdir_y(_ran - fal, _dir);
			
			var px0 = _px + lengthdir_x(1000, _dir - 90); var py0 = _py + lengthdir_y(1000, _dir - 90);
			var px1 = _px + lengthdir_x(1000, _dir + 90); var py1 = _py + lengthdir_y(1000, _dir + 90); 
			
			draw_line_dashed(px0, py0, px1, py1);
			
			var _px = px + lengthdir_x(_ran + fal, _dir); var _py = py + lengthdir_y(_ran + fal, _dir);
			
			var px0 = _px + lengthdir_x(1000, _dir - 90); var py0 = _py + lengthdir_y(1000, _dir - 90);
			var px1 = _px + lengthdir_x(1000, _dir + 90); var py1 = _py + lengthdir_y(1000, _dir + 90); 
			
			draw_line_dashed(px0, py0, px1, py1);
			
			//
			var _px = px - lengthdir_x(_ran - fal, _dir); var _py = py - lengthdir_y(_ran - fal, _dir);
			
			var px0 = _px + lengthdir_x(1000, _dir - 90); var py0 = _py + lengthdir_y(1000, _dir - 90);
			var px1 = _px + lengthdir_x(1000, _dir + 90); var py1 = _py + lengthdir_y(1000, _dir + 90);
			
			draw_line_dashed(px0, py0, px1, py1);
			
			var _px = px - lengthdir_x(_ran + fal, _dir); var _py = py - lengthdir_y(_ran + fal, _dir);
			
			var px0 = _px + lengthdir_x(1000, _dir - 90); var py0 = _py + lengthdir_y(1000, _dir - 90);
			var px1 = _px + lengthdir_x(1000, _dir + 90); var py1 = _py + lengthdir_y(1000, _dir + 90);
			
			draw_line_dashed(px0, py0, px1, py1);
		}
		
		active &= inputs[| 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		active &= inputs[| 4].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);
		active &= inputs[| 3].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny, 0, 1, THEME.anchor_scale_hori);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _typ = getInputData(1);
		inputs[| 4].setVisible(_typ == 1);
		
		STRAND_EFFECTOR_PRE
			// add effect (pnt, mulp)
		STRAND_EFFECTOR_POST
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_strandSim_force, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}