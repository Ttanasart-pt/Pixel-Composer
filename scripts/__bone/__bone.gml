#region
	enum BONE_EDIT {
		head = 0b001,
		tail = 0b010,
		body = 0b100,
	}
#endregion

function __Bone(_parent = noone, _distance = 0, _direction = 0, _angle = 0, _length = 0, _node = noone) constructor {
	ID      = UUID_generate();
	name    = "New bone";
	node    = _node;
	parent  = _parent;
	is_main = false;
	tb_name = new textBox(TEXTBOX_INPUT.text, function(n) /*=>*/ { name = n; if(node) node.triggerRender(); }).setFont(f_p2).setHide(true);
	
	childs        = [];
	parent_anchor = true;
	
	distance  = _distance;  pose_distance    = _distance;
	direction = _direction; pose_direction   = _direction;
	angle     = _angle;     pose_angle       = _angle;
	length    = _length;    pose_length      = _length;
	
	pose_posit  = [0,0]; pose_local_posit  = [0,0]; pose_apply_posit  = [0,0];
	pose_rotate = 0;     pose_local_rotate = 0;     pose_apply_rotate = 0;
	pose_scale  = 1;     pose_local_scale  = 1;     pose_apply_scale  = 1;
	
	bone_head_init = new __vec2(); bone_head_pose = new __vec2();
	bone_tail_init = new __vec2(); bone_tail_pose = new __vec2();
	
	apply_scale    = true;
	apply_rotation = true;
	
	IKlength   = 0;
	IKTargetID = "";
	IKTarget   = noone;
	
	constrains = [];
	control_x0 = 0; control_y0 = 0; control_i0 = 0;
	control_x1 = 0; control_y1 = 0; control_i1 = 0;
	
	static addChild   = function(bone) { array_push(childs, bone); bone.parent = self; return self; }
	static childCount = function()     { return array_reduce(childs, function(amo, ch) /*=>*/ { return amo + ch.childCount(); }, array_length(childs)); }
	
	////- Find
	
	static findBone = function(_id) {
		if(ID == _id) return self;
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var b = childs[i].findBone(_id);
			if(b != noone) return b;
		}
		
		return noone;
	}
	
	static findBoneByName = function(_name) {
		if(string_trim(name) == string_trim(_name)) 
			return self;
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var b = childs[i].findBoneByName(_name);
			if(b != noone) return b;
		}
		
		return noone;
	}
	
	////- Get position
	
	static getHead = function(pose = true) { return pose? bone_head_pose.clone() : bone_head_init.clone(); }
	static getTail = function(pose = true) { return pose? bone_tail_pose.clone() : bone_tail_init.clone(); }
	
	static getPoint = function(progress, pose = true) {
		var _dir, _dis, _len, _ang;
		
		if(pose) {
			_dir = pose_direction;
			_dis = pose_distance;
			
			_len = pose_length;
			_ang = pose_angle;
			
		} else {
			_dir = direction;
			_dis = distance;
			
			_len = length;
			_ang = angle;
		}
		
		var len = _len * progress;
		
		var _dx = lengthdir_x(_dis, _dir), _dy = lengthdir_y(_dis, _dir);
		var _lx = lengthdir_x( len, _ang), _ly = lengthdir_y( len, _ang);
		
		if(parent == noone)
			return new __vec2(_dx, _dy)
						.addElement(_lx, _ly);
		
		if(parent_anchor)
			return parent.getTail(pose)
						.addElement(_lx, _ly);
		
		return parent.getHead(pose)
				  .addElement(_dx, _dy)
				  .addElement(_lx, _ly);
	}
	
	////- Draw
	
	static draw = function(attributes, edit=false, _x=0, _y=0, _s=1, _mx=0, _my=0, _hover=noone, _select=noone, _blend=c_white, _alpha=1) {
		setControl(_x, _y, _s);
		
		var hover = noone, h;
		
		if(parent != noone) {
			h = drawBone(attributes, edit, _x, _y, _s, _mx, _my, _hover, _select, _blend, _alpha);
			if(h != noone) hover = h;
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			h = childs[i].draw(attributes, edit, _x, _y, _s, _mx, _my, _hover, _select, _blend, _alpha);
			if(h == noone) continue;
			
			if(hover == noone || IKlength) hover = h;
			if(h[1] != 2) hover = h;
		}
		
		return hover;
	}
	
	static drawBone = function(attributes, edit=false, _x=0, _y=0, _s=1, _mx=0, _my=0, _hover=noone, _select=noone, _blend=c_white, _alpha=1) {
		var hover = noone;
		
		var p0x = _x + bone_head_pose.x * _s;
		var p0y = _y + bone_head_pose.y * _s;
		var p1x = _x + bone_tail_pose.x * _s;
		var p1y = _y + bone_tail_pose.y * _s;
		var _selecting = false;
		
		if(is(_select, __Bone))     _selecting = _select.ID == self.ID; 
		else if(is_string(_select)) _selecting = _select    == name; 
		
		if(_selecting) {
			draw_set_color(COLORS._main_value_positive);
			draw_set_alpha(1 * _alpha);
			
		} else if(_hover != noone && _hover[0].ID == self.ID && _hover[1] == 2) {
			draw_set_color(c_white);
			draw_set_alpha(1 * _alpha);
			
		} else {
			draw_set_color(COLORS._main_accent);
			draw_set_alpha(.75 * _alpha);
		}
		
		if(IKlength == 0) {
			if(pose_rotate != 0) {
				var nx = p0x + lengthdir_x(16, angle + pose_rotate);
				var ny = p0y + lengthdir_y(16, angle + pose_rotate);
				
				draw_line_width(p0x, p0y, nx, ny, 2);
			}
			
			if(!parent_anchor && parent.parent != noone) {
				var _p  = parent.getTail();
				var _px = _x + _p.x * _s;
				var _py = _y + _p.y * _s;
				draw_line_dashed(_px, _py, p0x, p0y, 2, 8);
			}
			
			if(attributes.display_bone == 0) {
				var _ppx = lerp(p0x, p1x, 0.2);
				var _ppy = lerp(p0y, p1y, 0.2);
				var _prr = point_direction(p0x, p0y, p1x, p1y) + 90;
				var _prx = lengthdir_x(6 * pose_scale, _prr);
				var _pry = lengthdir_y(6 * pose_scale, _prr);
				
				draw_primitive_begin(pr_trianglelist);
					draw_vertex(p0x, p0y);
					draw_vertex(_ppx, _ppy);
					draw_vertex(_ppx + _prx, _ppy + _pry);
					
					draw_vertex(p0x, p0y);
					draw_vertex(_ppx, _ppy);
					draw_vertex(_ppx - _prx, _ppy - _pry);
					
					draw_vertex(p1x, p1y);
					draw_vertex(_ppx, _ppy);
					draw_vertex(_ppx + _prx, _ppy + _pry);
					
					draw_vertex(p1x, p1y);
					draw_vertex(_ppx, _ppy);
					draw_vertex(_ppx - _prx, _ppy - _pry);
				draw_primitive_end();
				
				if((edit & BONE_EDIT.body) && distance_to_line(_mx, _my, p0x, p0y, p1x, p1y) <= 12) //drag bone
					hover = [ self, 2, bone_head_pose ];
					
			} else if(attributes.display_bone == 1) {
				draw_line_width(p0x, p0y, p1x, p1y, 3);
				
				if((edit & BONE_EDIT.body) && distance_to_line(_mx, _my, p0x, p0y, p1x, p1y) <= 6) //drag bone
					hover = [ self, 2, bone_head_pose ];
			} 
			
		} else {
			var cc = draw_get_color();
			draw_set_color(c_white);
			if(!parent_anchor && parent.parent != noone) {
				var _p  = parent.getTail();
				var _px = _x + _p.x * _s;
				var _py = _y + _p.y * _s;
				draw_line_dashed(_px, _py, p0x, p0y, 1);
			}
			
			draw_sprite_ui(THEME.preview_bone_IK, 0, p0x, p0y,,,, cc, draw_get_alpha());
			
			if((edit & BONE_EDIT.body) && point_in_circle(_mx, _my, p0x, p0y, 24))
				hover = [ self, 2, bone_head_pose ];
		}
		draw_set_alpha(1);
		
		if(attributes.display_name && IKlength == 0) {
			if(abs(p0y - p1y) < abs(p0x - p1x)) {
				draw_set_text(f_p3, fa_center, fa_bottom, COLORS._main_accent);
				draw_text_add((p0x + p1x) / 2, (p0y + p1y) / 2 - 4, name);
				
			} else {
				draw_set_text(f_p3, fa_left, fa_center, COLORS._main_accent);
				draw_text_add((p0x + p1x) / 2 + 4, (p0y + p1y) / 2, name);
			}
		}
		
		if(IKlength == 0) {
			if(!parent_anchor) {
				control_i0 = (_hover != noone && _hover[0] == self && _hover[1] == 0)? 1 : 0;
				
				if((edit & BONE_EDIT.head) && point_in_circle(_mx, _my, p0x, p0y, ui(16))) //drag head
					hover = [ self, 0, bone_head_pose ];
			}
		
			control_i1 = (_hover != noone && _hover[0] == self && _hover[1] == 1)? 1 : 0;
			
			if((edit & BONE_EDIT.tail) && point_in_circle(_mx, _my, p1x, p1y, ui(16))) //drag tail
				hover = [ self, 1, bone_tail_pose ];
		}
		
		return hover;
	}
	
	static drawThumbnail = function(_s, _bbox, _bone_bbox = undefined) {
		_bone_bbox ??= bbox();
		
		if(!is_main && is_array(_bone_bbox)) {
			var _bw = max(1, _bone_bbox[4]);
			var _bh = max(1, _bone_bbox[5]);
			
			var boxs = min(_bbox.w / _bw, _bbox.h / _bh);
			
			_bbox.w = boxs * _bw;
			_bbox.h = boxs * _bh;
			
			_bbox.x0 = _bbox.xc - _bbox.w / 2;
			_bbox.x1 = _bbox.xc + _bbox.w / 2;
			
			_bbox.y0 = _bbox.yc - _bbox.h / 2;
			_bbox.y1 = _bbox.yc + _bbox.h / 2;
			
			var p0x = _bbox.x0 + _bbox.w * (bone_head_pose.x - _bone_bbox[0]) / _bw;
			var p0y = _bbox.y0 + _bbox.h * (bone_head_pose.y - _bone_bbox[1]) / _bh;
			var p1x = _bbox.x0 + _bbox.w * (bone_tail_pose.x - _bone_bbox[0]) / _bw;
			var p1y = _bbox.y0 + _bbox.h * (bone_tail_pose.y - _bone_bbox[1]) / _bh;
			
			draw_set_circle_precision(8);
			
			draw_set_color(COLORS._main_accent);
			draw_line_width(p0x, p0y, p1x, p1y, 1.5 * _s);
			
			draw_set_color(COLORS._main_icon_dark);
			draw_circle(p0x, p0y, 4 * _s, false);
			draw_circle(p1x, p1y, 4 * _s, false);
			
			draw_set_color(COLORS._main_accent);
			draw_circle(p0x, p0y, 2 * _s, false);
			draw_circle(p1x, p1y, 2 * _s, false);
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) 
			childs[i].drawThumbnail(_s, _bbox, _bone_bbox);
	}
	
	static setControl = function(_x = 0, _y = 0, _s = 1) {
		control_x0 = _x + bone_head_pose.x * _s;
		control_y0 = _y + bone_head_pose.y * _s;
		control_x1 = _x + bone_tail_pose.x * _s;
		control_y1 = _y + bone_tail_pose.y * _s;
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) 
			childs[i].setControl(_x, _y, _s);
	}
		
	static drawControl = function(attributes) {
		if(parent != noone && IKlength == 0) {
			if(!parent_anchor) 
				draw_anchor(control_i0 * .5, control_x0, control_y0, ui(8), attributes.display_bone); 
			draw_anchor(control_i1 * .5, control_x1, control_y1, ui(8), attributes.display_bone); 
		}
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].drawControl(attributes);
	}
	
	////- Pose
	
	static resetPose = function() {
		pose_distance  = distance;
		pose_direction = direction;
		pose_angle     = angle;
		pose_length    = length;
		
		pose_posit  = [ 0, 0 ];
		pose_rotate = 0;
		pose_scale  = 1;
		
		pose_local_posit  = [ 0, 0 ];
		pose_local_rotate = 0;
		pose_local_scale  = 1;
		
		pose_apply_posit  = [ 0, 0 ];
		pose_apply_rotate = 0;
		pose_apply_scale  = 1;
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].resetPose();
		
		return self;
	}
	
	static __setPosition = function() {
		bone_head_init = getPoint(0, false);
		bone_head_pose = getPoint(0, true);
		bone_tail_init = getPoint(1, false);
		bone_tail_pose = getPoint(1, true);
	}
		
	static setPosition = function() {
		__setPosition();
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].setPosition();
		
		return self;
	}
	
	static setPose = function(_ik = true) {
		__c_bone = self;
		
		setPosition();
			setPoseTransform();
			if(_ik) { setPosition(); setIKconstrain(); }
			array_foreach(constrains, function(c) /*=>*/ {return c.constrain(__c_bone)});
		setPosition();
		
		return self;
	}
	
	static setPoseTransform = function() {
		if(is_main) {
			array_foreach(childs, function(c) /*=>*/ {return c.setPoseTransform()});
			return;
		}
		
		pose_apply_posit  = [ pose_posit[0], pose_posit[1] ];
		pose_apply_rotate = pose_rotate;
		pose_apply_scale  = pose_scale;
		
		if(parent) { // do this instead of recursion.
			pose_local_posit     = parent.pose_apply_posit;
			pose_local_rotate    = apply_rotation? parent.pose_apply_rotate : 0;
			pose_local_scale     = apply_scale?    parent.pose_apply_scale  : 1;
			
			pose_apply_posit[0] += pose_local_posit[0];
			pose_apply_posit[1] += pose_local_posit[1];
			pose_apply_rotate   += pose_local_rotate;
			pose_apply_scale    *= pose_local_scale;
		}
		
		var ldx = lengthdir_x(distance, direction) + pose_posit[0];
		var ldy = lengthdir_y(distance, direction) + pose_posit[1];
		
		pose_direction = point_direction(0, 0, ldx, ldy) + pose_local_rotate;
		pose_distance  = point_distance(0, 0, ldx, ldy)  * pose_local_scale;
		
		pose_angle     = angle  + pose_apply_rotate;
		pose_length    = length * pose_apply_scale;
		
		array_foreach(childs, function(c) /*=>*/ {return c.setPoseTransform()});
	}
	
	////- IK
	
	static setIKconstrain = function() {
		if(IKlength > 0 && IKTarget != noone) {
			var points  = array_create(IKlength + 1);
			var lengths = array_create(IKlength);
			var bones   = array_create(IKlength);
			var bn      = IKTarget;
			
			for( var i = IKlength; i > 0; i-- ) {
				var _p = bn.getTail();
				bones[i - 1] = bn;
				points[i] = { x: _p.x, y: _p.y };
				bn = bn.parent;
			}
			
			if(bn == noone) return;
			_p = bn.getTail();
			points[0] = { x: _p.x, y: _p.y };
			
			for( var i = 0; i < IKlength; i++ ) {
				var p0 = points[i];
				var p1 = points[i + 1];
				
				lengths[i] = point_distance(p0.x, p0.y, p1.x, p1.y);
			}
			
			var p  = parent.getHead();
			var px = p.x + lengthdir_x(pose_distance, pose_direction);
			var py = p.y + lengthdir_y(pose_distance, pose_direction);
			
			FABRIK(bones, points, lengths, px, py);
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
			FABRIK_backward(bones, points, lengths, dx, dy);
			FABRIK_forward(bones, points, lengths, sx, sy);
			
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
			var _b = bones[i];
			var p0 = points[i];
			var p1 = points[i + 1];
			
			var dir  = point_direction(p0.x, p0.y, p1.x, p1.y);
			var dis  = point_distance( p0.x, p0.y, p1.x, p1.y);
			
			_b.pose_angle = dir;
		
			FABRIK_result[i] = p0;
		}
		
		FABRIK_result[i] = p1;
		
	}
	
	static FABRIK_backward = function(bones, points, lengths, dx, dy) {
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
	
	static FABRIK_forward = function(bones, points, lengths, sx, sy) {
		var tx = sx;
		var ty = sy;
		
		for( var i = 0, n = array_length(points) - 1; i < n; i++ ) {
			var _b  = bones[i];
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
		if(is_main) return noone;
		
		var p0 = bone_head_pose;
		var p1 = bone_tail_pose;
		
		var x0 = min(p0.x, p1.x);
		var y0 = min(p0.y, p1.y);
		var x1 = max(p0.x, p1.x);
		var y1 = max(p0.y, p1.y);
		
		return [ x0, y0, x1, y1, 0, 0 ];
	}
	
	static bbox = function() {
		var _bbox = __getBBOX();
		
		for( var i = 0, n = array_length(childs); i < n; i++ ) {
			var _bbox_ch = childs[i].bbox();
			
			if(is_array(_bbox)) {
				_bbox[0] = min(_bbox[0], _bbox_ch[0]);
				_bbox[1] = min(_bbox[1], _bbox_ch[1]);
				_bbox[2] = max(_bbox[2], _bbox_ch[2]);
				_bbox[3] = max(_bbox[3], _bbox_ch[3]);
				
			} else _bbox = _bbox_ch;
		}
		
		if(is_array(_bbox)) {
			_bbox[4] = _bbox[2] - _bbox[0];
			_bbox[5] = _bbox[3] - _bbox[1];
		}
		
		return _bbox;
	}
	
	////- Serialize
	
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
		
		bone.constrains = array_map(constrains, function(c) /*=>*/ {return c.serialize()});
		
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
		
		self.node	= node;
		
		IKlength	= bone.IKlength;
		IKTargetID	= struct_try_get(bone, "IKTargetID", "");
		
		apply_rotation	= bone.apply_rotation;
		apply_scale		= bone.apply_scale;
		
		if(struct_has(bone, "constrains")) {
			__b = self;
			constrains = array_filter(array_map(bone.constrains, function(c) /*=>*/ {return new __Bone_Constrain(__b).deserialize(c)}), function(c) /*=>*/ {return c != noone});
		}
		
		childs = [];
		for( var i = 0, n = array_length(bone.childs); i < n; i++ ) 
			addChild(new __Bone().deserialize(bone.childs[i], node));
		
		return self;
	}
	
	static connect = function() {
		IKTarget = noone;
		if(parent != noone && IKTargetID != "") 
			IKTarget = parent.findBone(IKTargetID);
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].connect();
			
		return self;
	}
	
	static clone = function() {
		var _b = new __Bone(parent, distance, direction, angle, length);
		
		_b.angle     = angle;
		_b.length    = length;
		_b.distance  = distance;
		_b.direction = direction;
		
		_b.ID		     = ID;
		_b.name		     = name;
		_b.is_main	     = is_main;
		_b.parent_anchor = parent_anchor;
		
		_b.IKlength		 = IKlength;
		_b.IKTargetID	 = IKTargetID;
		
		_b.apply_rotation	 = apply_rotation;
		_b.apply_scale		 = apply_scale;
		
		
		for( var i = 0, n = array_length(childs); i < n; i++ )
			_b.addChild(childs[i].clone());
			
		__b = _b;
		_b.constrains = array_map(constrains, function(c) /*=>*/ {return new __Bone_Constrain(__b).deserialize(c.serialize())});
		
		return _b;
	}
	
	////- Actions
	
	static toString = function() { return $"Bone {name} [{ID}] : [{direction}, {distance}] / [{angle}, {length}]"; }
	
	static toArray = function(arr = []) {
		if(!is_main) array_push(arr, self);
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childs[i].toArray(arr);
			
		return arr;
	}

	static getHash = function() {
		var childHash = "";
		for( var i = 0, n = array_length(childs); i < n; i++ )
			childHash += childs[i].getHash() + ",";
		
		var h = $"{name} [{ID}] : {parent_anchor}, [{IKlength}, {IKTargetID}], [{apply_scale}, {apply_rotation}], [{childHash}]";
	    return sha1_string_unicode(h);
	}
	
}