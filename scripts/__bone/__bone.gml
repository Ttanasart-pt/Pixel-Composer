function __Bone(parent = noone, distance = 0, direction = 0, angle = 0, length = 0, node = noone) constructor {
	ID = UUID_generate();
	self.name = "New bone";
	self.distance	 = distance;
	self.direction	 = direction;
	self.angle		 = angle;
	self.length		 = length;
	self.node		 = node;
	
	init_length      = length;
	init_angle       = angle;
	
	pose_angle       = 0;
	pose_scale       = 1;
	pose_posit       = [ 0, 0 ];
	pose_local_angle = 0;
	pose_local_scale = 1;
	pose_local_posit = [ 0, 0 ];
	
	apply_scale      = true;
	apply_rotation   = true;
	
	childs  = [];
	is_main = false;
	parent_anchor = true;
	
	tb_name = new textBox(TEXTBOX_INPUT.text, function(_name) /*=>*/ { name = _name; if(node) node.triggerRender(); });
	tb_name.font = f_p2;
	tb_name.hide = true;
	
	updated = false;
	
	IKlength   = 0;
	IKTargetID = "";
	IKTarget   = noone;
	
	freeze_data = {};
	
	self.parent = parent;
	if(parent != noone) {
		distance = parent.length;
		direction = parent.angle;
	}
	
	static addChild = function(bone) {
		array_push(childs, bone);
		bone.parent = self;
		return self;
	}
	
	static childCount = function() {
		var amo = array_length(childs);
		for( var i = 0, n = array_length(childs); i < n; i++ )
			amo += childs[i].childCount();
		return amo;
	}
	
	static freeze = function() {
		freeze_data = {
			angle: angle,
			length: length,
			distance: distance,
			direction: direction
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].freeze();
	}
	
	static findBone = function(_id) {
		if(ID == _id) 
			return self;
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var b = childs[i].findBone(_id);
			if(b != noone)
				return b;
		}
		
		return noone;
	}
	
	static findBoneByName = function(_name) {
		//print($"Print {string_length(string_trim(name))} : {string_length(string_trim(_name))}");
		if(string_trim(name) == string_trim(_name)) 
			return self;
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var b = childs[i].findBoneByName(_name);
			if(b != noone)
				return b;
		}
		
		return noone;
	}
	
	static getPoint = function(progress, pose = true) {
		var _len = pose? length : init_length;
		var _ang = pose? angle  : init_angle;
		
		var len = _len * progress;
		
		if(parent == noone)
			return new __vec2(lengthdir_x(distance, direction), lengthdir_y(distance, direction))
						.addElement(lengthdir_x(len, _ang), lengthdir_y(len, _ang));
		
		if(parent_anchor) {
			var p = parent.getPoint(1, pose)
						  .addElement(lengthdir_x(len, _ang), lengthdir_y(len, _ang))
			return p;
		}
		
		var p = parent.getPoint(0, pose)
					  .addElement(lengthdir_x(distance, direction), lengthdir_y(distance, direction))
					  .addElement(lengthdir_x(len, _ang), lengthdir_y(len, _ang))
		return p;
	}
	
	static draw = function(attributes, edit = false, _x = 0, _y = 0, _s = 1, _mx = 0, _my = 0, hovering = noone, selecting = noone) {
		var hover = _drawBone(attributes, edit, _x, _y, _s, _mx, _my, hovering, selecting);
		drawControl(attributes);
		return hover;
	}
	
	control_x0 = 0; control_y0 = 0; control_i0 = 0;
	control_x1 = 0; control_y1 = 0; control_i1 = 0;
	
	static _drawBone = function(attributes, edit = false, _x = 0, _y = 0, _s = 1, _mx = 0, _my = 0, hovering = noone, selecting = noone) {
		var hover = noone;
		
		var p0 = getPoint(0);
		var p1 = getPoint(1);
		
		p0.x = _x + p0.x * _s;
		p0.y = _y + p0.y * _s;
		p1.x = _x + p1.x * _s;
		p1.y = _y + p1.y * _s;
		
		control_x0 = p0.x; control_y0 = p0.y;
		control_x1 = p1.x; control_y1 = p1.y;
	
		if(parent != noone) {
			if(selecting && selecting.ID == self.ID) {
				draw_set_color(COLORS._main_value_positive);
				draw_set_alpha(0.75);
			} else if(hovering != noone && hovering[0].ID == self.ID && hovering[1] == 2) {
				draw_set_color(c_white);
				draw_set_alpha(1);
			} else {
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(0.75);
			}
			
			if(IKlength == 0) {
				if(!parent_anchor && parent.parent != noone) {
					var _p = parent.getPoint(0);
					_p.x = _x + _p.x * _s;
					_p.y = _y + _p.y * _s;
					draw_line_dashed(_p.x, _p.y, p0.x, p0.y, 1);
				}
				
				if(attributes.display_bone == 0) {
					var _ppx = lerp(p0.x, p1.x, 0.2);
					var _ppy = lerp(p0.y, p1.y, 0.2);
					var _prr = point_direction(p0.x, p0.y, p1.x, p1.y) + 90;
					var _prx = lengthdir_x(6 * pose_scale, _prr);
					var _pry = lengthdir_y(6 * pose_scale, _prr);
					
					draw_primitive_begin(pr_trianglelist);
						draw_vertex(p0.x, p0.y);
						draw_vertex(_ppx, _ppy);
						draw_vertex(_ppx + _prx, _ppy + _pry);
						
						draw_vertex(p0.x, p0.y);
						draw_vertex(_ppx, _ppy);
						draw_vertex(_ppx - _prx, _ppy - _pry);
						
						draw_vertex(p1.x, p1.y);
						draw_vertex(_ppx, _ppy);
						draw_vertex(_ppx + _prx, _ppy + _pry);
						
						draw_vertex(p1.x, p1.y);
						draw_vertex(_ppx, _ppy);
						draw_vertex(_ppx - _prx, _ppy - _pry);
					draw_primitive_end();
					
					if((edit & 0b100) && distance_to_line(_mx, _my, p0.x, p0.y, p1.x, p1.y) <= 12) //drag bone
						hover = [ self, 2, p0 ];
						
				} else if(attributes.display_bone == 1) {
					draw_line_width(p0.x, p0.y, p1.x, p1.y, 3);
					
					if((edit & 0b100) && distance_to_line(_mx, _my, p0.x, p0.y, p1.x, p1.y) <= 6) //drag bone
						hover = [ self, 2, p0 ];
				} 
			} else {
				draw_set_color(c_white);
				if(!parent_anchor && parent.parent != noone) {
					var _p = parent.getPoint(1);
					_p.x = _x + _p.x * _s;
					_p.y = _y + _p.y * _s;
					draw_line_dashed(_p.x, _p.y, p0.x, p0.y, 1);
				}
			
				draw_sprite_ui(THEME.preview_bone_IK, 0, p0.x, p0.y,,,, c_white, draw_get_alpha());
				
				if((edit & 0b100) && point_in_circle(_mx, _my, p0.x, p0.y, 24))
					hover = [ self, 2, p0 ];
			}
			draw_set_alpha(1.00);
			
			if(attributes.display_name && IKlength == 0) {
				if(abs(p0.y - p1.y) < abs(p0.x - p1.x)) {
					draw_set_text(f_p3, fa_center, fa_bottom, COLORS._main_accent);
					draw_text_add((p0.x + p1.x) / 2, (p0.y + p1.y) / 2 - 4, name);
				} else {
					draw_set_text(f_p3, fa_left, fa_center, COLORS._main_accent);
					draw_text_add((p0.x + p1.x) / 2 + 4, (p0.y + p1.y) / 2, name);
				}
			}
			
			if(IKlength == 0) {
				if(!parent_anchor) {
					control_i0 = (hovering != noone && hovering[0] == self && hovering[1] == 0)? 0 : 2;
					
					if((edit & 0b001) && point_in_circle(_mx, _my, p0.x, p0.y, ui(16))) //drag head
						hover = [ self, 0, p0 ];
				}
			
				control_i1 = (hovering != noone && hovering[0] == self && hovering[1] == 1)? 0 : 2;
				
				if((edit & 0b010) && point_in_circle(_mx, _my, p1.x, p1.y, ui(16))) //drag tail
					hover = [ self, 1, p1 ];
			}
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var h = childs[i]._drawBone(attributes, edit, _x, _y, _s, _mx, _my, hovering, selecting);
			if(hover == noone && h != noone)
				hover = h;
		}
		
		return hover;
	}
	
	static drawControl = function(attributes) {
		if(parent != noone && IKlength == 0) {
			var spr, ind0, ind1;
			if(attributes.display_bone == 0) {
				if(!parent_anchor) 
					draw_sprite_colored(THEME.anchor_selector, control_i0, control_x0, control_y0); 
				draw_sprite_colored(THEME.anchor_selector, control_i1, control_x1, control_y1); 
			} else {
				if(!parent_anchor) 
					draw_sprite_ext(THEME.anchor_bone_stick, control_i0 / 2, control_x0, control_y0, 1, 1, 0, COLORS._main_accent, 1); 
				draw_sprite_ext(THEME.anchor_bone_stick, control_i1 / 2, control_x1, control_y1, 1, 1, 0, COLORS._main_accent, 1); 
			}
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].drawControl(attributes);
	}
	
	static resetPose = function() {
		pose_angle = 0;
		pose_scale = 1;
		pose_posit = [ 0, 0 ];
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].resetPose();
	}
	
	static setPose = function(_position = [ 0, 0 ], _angle = 0, _scale = 1) {
		setPoseTransform(_position, _angle, _scale);
		setIKconstrain();
	}
	
	static setPoseTransform = function(_position = [ 0, 0 ], _angle = 0, _scale = 1) {
		if(is_main) {
			for( var i = 0, n = array_length(childs); i < n; i++ )
				childs[i].setPoseTransform(_position, _angle, _scale);
			return;
		}
		
		pose_posit[0] += _position[0];
		pose_posit[1] += _position[1];
		if(apply_rotation)	pose_angle += _angle;
		if(apply_scale)		pose_scale *= _scale;
		
		pose_local_angle = pose_angle;
		pose_local_scale = pose_scale;
		pose_local_posit = pose_posit;
		
		var _x = lengthdir_x(distance, direction) + pose_posit[0];
		var _y = lengthdir_y(distance, direction) + pose_posit[1];
		
		direction = point_direction(0, 0, _x, _y) + _angle;
		distance  = point_distance(0, 0, _x, _y)  * _scale;
		
		init_length = length;
		init_angle  = angle;
		angle  += pose_angle;
		length *= pose_scale;
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].setPoseTransform(_position, pose_angle, pose_scale);
	}
	
	static setIKconstrain = function() {
		if(IKlength > 0 && IKTarget != noone) {
			var points  = array_create(IKlength + 1);
			var lengths = array_create(IKlength);
			var bones   = array_create(IKlength);
			var bn      = IKTarget;
			
			for( var i = IKlength; i > 0; i-- ) {
				var _p = bn.getPoint(1);
				bones[i - 1]  = bn;
				points[i] = {
					x: _p.x,
					y: _p.y
				};
				bn = bn.parent;
			}
			
			_p = bn.getPoint(1);
			points[0] = {
				x: _p.x,
				y: _p.y
			};
			
			for( var i = 0; i < IKlength; i++ ) {
				var p0 = points[i];
				var p1 = points[i + 1];
				
				lengths[i] = point_distance(p0.x, p0.y, p1.x, p1.y);
			}
			
			var p = parent.getPoint(0);
			p.x += lengthdir_x(distance, direction);
			p.y += lengthdir_y(distance, direction);
			
			FABRIK(bones, points, lengths, p.x, p.y);
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].setIKconstrain();
	}
	
	FABRIK_result = [];
	static FABRIK = function(bones, points, lengths, dx, dy) {
		var threshold = 0.01;
		var _bo = array_create(array_length(points));
		for( var i = 0, n = array_length(points); i < n; i++ )
			_bo[i] = { x: points[i].x, y: points[i].y };
		var sx = points[0].x;
		var sy = points[0].y;
		var itr = 0;
		
		do {
			FABRIK_backward(points, lengths, dx, dy);
			FABRIK_forward(points, lengths, sx, sy);
			
			var delta = 0;
			var _bn = array_create(array_length(points));
			for( var i = 0, n = array_length(points); i < n; i++ ) {
				_bn[i] = { x: points[i].x, y: points[i].y };
				delta += point_distance(_bo[i].x, _bo[i].y, _bn[i].x, _bn[i].y);
			}
			
			_bo = _bn;
			if(++itr >= 64) break;
		} until(delta <= threshold);
		
		for( var i = 0, n = array_length(points) - 1; i < n; i++ ) {
			var bone = bones[i];
			var p0  = points[i];
			var p1  = points[i + 1];
			
			var dir = point_direction(p0.x, p0.y, p1.x, p1.y);
			bone.angle = dir;
			
			FABRIK_result[i] = p0;
		}
		
		FABRIK_result[i] = p1;
	}
	
	static FABRIK_backward = function(points, lengths, dx, dy) {
		var tx = dx;
		var ty = dy;
		
		for( var i = array_length(points) - 1; i > 0; i-- ) {
			var p1  = points[i];
			var p0  = points[i - 1];
			var len = lengths[i - 1];
			var dir = point_direction(tx, ty, p0.x, p0.y);
			
			p1.x = tx;
			p1.y = ty;
			
			p0.x = p1.x + lengthdir_x(len, dir);
			p0.y = p1.y + lengthdir_y(len, dir);
			
			tx = p0.x;
			ty = p0.y;
		}
	}
	
	static FABRIK_forward = function(points, lengths, sx, sy) {
		var tx = sx;
		var ty = sy;
		
		for( var i = 0, n = array_length(points) - 1; i < n; i++ ) {
			var p0  = points[i];
			var p1  = points[i + 1];
			var len = lengths[i];
			var dir = point_direction(tx, ty, p1.x, p1.y);
			
			p0.x = tx;
			p0.y = ty;
			
			p1.x = p0.x + lengthdir_x(len, dir);
			p1.y = p0.y + lengthdir_y(len, dir);
			
			tx = p1.x;
			ty = p1.y;
		}
	}
	
	static __getBBOX = function() {
		var p0 = getPoint(0);
		var p1 = getPoint(1);
		
		var x0 = min(p0.x, p1.x);
		var y0 = min(p0.y, p1.y);
		var x1 = max(p0.x, p1.x);
		var y1 = max(p0.y, p1.y);
		
		return [ x0, y0, x1, y1 ];
	}
	
	static bbox = function() {
		var _bbox = __getBBOX();
		//print($"BBOX: {_bbox}")
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var _bbox_ch = childs[i].bbox();
			//print($"BBOX ch: {_bbox_ch}")
			
			_bbox[0] = min(_bbox[0], _bbox_ch[0]);
			_bbox[1] = min(_bbox[1], _bbox_ch[1]);
			_bbox[2] = max(_bbox[2], _bbox_ch[2]);
			_bbox[3] = max(_bbox[3], _bbox_ch[3]);
		}
		
		return _bbox;
	}
	
	static serialize = function() {
		var bone = {};
		
		bone.ID			= ID;
		bone.name		= name;
		bone.distance	= distance;
		bone.direction	= direction;
		bone.angle		= angle;
		bone.length		= length;
		
		bone.is_main		= is_main;
		bone.parent_anchor	= parent_anchor;
		
		bone.IKlength	= IKlength;
		bone.IKTargetID	= IKTargetID;
		
		bone.apply_rotation	= apply_rotation;
		bone.apply_scale	= apply_scale;
		
		bone.childs = [];
		for( var i = 0, n = array_length(childs); i < n; i++ )
			bone.childs[i] = childs[i].serialize();
			
		return bone;
	}
	
	static deserialize = function(bone, node) {
		ID			= bone.ID;
		name		= bone.name;
		distance	= bone.distance;
		direction	= bone.direction;
		angle		= bone.angle;
		length		= bone.length;
		
		is_main			= bone.is_main;
		parent_anchor	= bone.parent_anchor;
		
		self.node		= node;
		
		IKlength	= bone.IKlength;
		IKTargetID	= struct_try_get(bone, "IKTargetID", "");
		
		apply_rotation	= bone.apply_rotation;
		apply_scale		= bone.apply_scale;
		
		childs = [];
		for( var i = 0, n = array_length(bone.childs); i < n; i++ ) {
			var _b = new __Bone().deserialize(bone.childs[i], node);
			addChild(_b);
		}
		
		return self;
	}
	
	static connect = function() {
		IKTarget = noone;
		if(parent != noone && IKTargetID != "") 
			IKTarget = parent.findBone(IKTargetID);
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].connect();
	}
	
	static clone = function() {
		var _b = new __Bone(parent, distance, direction, angle, length);
		_b.ID		= ID;
		_b.name		= name;
		_b.is_main	= is_main;
		_b.parent_anchor = parent_anchor;
		
		_b.IKlength		= IKlength;
		_b.IKTargetID	= IKTargetID;
		
		_b.apply_rotation	= apply_rotation;
		_b.apply_scale		= apply_scale;
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			_b.addChild(childs[i].clone());
		
		return _b;
	}
	
	static toString = function() { return $"Bone {name} [{ID}]"; }
	
	static toArray = function(arr = []) {
		array_push(arr, self);
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].toArray(arr);
			
		return arr;
	}
}