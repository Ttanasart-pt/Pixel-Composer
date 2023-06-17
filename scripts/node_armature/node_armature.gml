function Node_Armature(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Create";
	
	//inputs[| 0] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	input_fix_len = ds_list_size(inputs);
	data_length = 1;
	
	static createBone = function(parent, distance, direction) {
		var bone  = new __Bone(parent, distance, direction);
		parent.addChild(bone);
		
		if(parent == attributes.bones) 
			bone.parent_anchor = false;
		return bone;
	}
	
	outputs[| 0] = nodeValue("Armature", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attributes.bones = new __Bone();
	attributes.bones.is_main = true;
	
	tools = [
		new NodeTool( "Add bones", THEME.path_tools_transform ),
		new NodeTool( "Remove bones", THEME.path_tools_transform ),
	];
	
	anchor_selecting = noone;
	builder_bone = noone;
	builder_type = 0;
	builder_sx = 0;
	builder_sy = 0;
	builder_mx = 0;
	builder_my = 0;
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		anchor_selecting = attributes.bones.draw(active, _x, _y, _s, _mx, _my, true, anchor_selecting);
		
		var mx = (_mx - _x) / _s;
		var my = (_my - _y) / _s;
		
		if(builder_bone != noone) {
			var dir = point_direction(builder_sx, builder_sy, mx, my);
			var dis = point_distance(builder_sx, builder_sy, mx, my);
			
			if(!key_mod_press(ALT)) {
				if(builder_type == 0) {
					var bo = builder_bone.getPoint(builder_bone.length, builder_bone.angle);
					
					builder_bone.direction = dir;
					builder_bone.distance  = dis;
					
					var bn = builder_bone.getPoint(0, 0);
					
					builder_bone.angle  = point_direction(bo.x, bo.y, bn.x, bn.y);
					builder_bone.length = point_distance( bo.x, bo.y, bn.x, bn.y);
				} else if(builder_type == 1) {
					var chs = [];
					for( var i = 0; i < array_length(builder_bone.childs); i++ ) {
						var ch = builder_bone.childs[i];
						chs[i] = ch.getPoint(ch.length, ch.angle);
					}
				
					builder_bone.angle  = dir;
					builder_bone.length = dis;
					
					for( var i = 0; i < array_length(builder_bone.childs); i++ ) {
						var ch = builder_bone.childs[i];
						var c0 = ch.getPoint(0, 0);
					
						ch.angle  = point_direction(c0.x, c0.y, chs[i].x, chs[i].y);
						ch.length = point_distance( c0.x, c0.y, chs[i].x, chs[i].y);
					}
				}
			} else {
				if(builder_type == 0) {
					builder_bone.direction = dir;
					builder_bone.distance  = dis;
				} else if(builder_type == 1) {
					builder_bone.angle  = dir;
					builder_bone.length = dis;
				} else if(builder_type == 2) {
					var bo = builder_bone.getPoint(0, 0);
					var bx = bo.x + (mx - builder_mx) / _s;
					var by = bo.y + (my - builder_my) / _s;
					
					if(builder_bone.parent_anchor) {
						
					} else {
						builder_bone.direction = point_direction(builder_sx, builder_sy, bx, by);
						builder_bone.distance  = point_distance( builder_sx, builder_sy, bx, by);
					}
				}
			}
			
			if(mouse_release(mb_left))
				builder_bone = noone;
		}
			
		if(isUsingTool(0)) { // builder
			if(mouse_press(mb_left, active)) {
				if(anchor_selecting == noone) {
					builder_bone = createBone(attributes.bones, point_distance(0, 0, mx, my), point_direction(0, 0, mx, my));
					builder_type = 1;
					builder_sx = mx;
					builder_sy = my;
				} else if(anchor_selecting[1] == 1) {
					builder_bone = createBone(anchor_selecting[0], 0, 0);
					builder_type = 1;
					builder_sx = mx;
					builder_sy = my;
				}
			}
		} else { //mover
			if(anchor_selecting != noone && mouse_press(mb_left, active)) {
				builder_bone = anchor_selecting[0];
				builder_type = anchor_selecting[1];
				
				if(builder_type == 0) {
					var orig = builder_bone.parent.getPoint(0, 0);
					builder_sx = orig.x;
					builder_sy = orig.y;
				} else if(builder_type == 1) {
					var orig = builder_bone.getPoint(0, 0);
					builder_sx = orig.x;
					builder_sy = orig.y;
				} else if(builder_type == 2) {
					var _par = builder_bone.parent;
					var orig = _par.getPoint(_par.length, _par.angle);
					builder_sx = orig.x;
					builder_sy = orig.y;
					builder_mx = mx;
					builder_my = my;
				}
			}
		}
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		outputs[| 0].setValue(attributes.bones);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map.inputs;
		
		for(var i = input_fix_len; i < array_length(_inputs); i += data_length)
			createBone();
	}
}

