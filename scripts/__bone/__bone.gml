function __Bone(parent = noone, distance = 0, direction = 0, angle = 0, length = 0, attributes = {}) constructor {
	id = UUID_generate();
	self.name = "New bone";
	self.distance	= distance;
	self.direction	= direction;
	self.angle		= angle;
	self.length		= length;
	
	pose_angle = 0;
	pose_scale = 1;
	pose_posit = [ 0, 0 ];
	
	self.is_main = false;
	self.parent_anchor = true;
	self.childs = [];
	
	tb_name = new textBox(TEXTBOX_INPUT.text, function(_name) { name = _name; });
	tb_name.font = f_p2;
	tb_name.hide = true;
	
	self.attributes = attributes;
	updated = false;
	
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
		for( var i = 0; i < array_length(childs); i++ )
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
		
		for( var i = 0; i < array_length(childs); i++ )
			childs[i].freeze();
	}
	
	static getPoint = function(distance, direction) {
		if(parent == noone)
			return new Point(lengthdir_x(self.distance, self.direction), lengthdir_y(self.distance, self.direction))
						.add(lengthdir_x(     distance,      direction), lengthdir_y(     distance,      direction));
		
		if(parent_anchor) {
			var p = parent.getPoint(parent.length, parent.angle);
			return p.add(lengthdir_x(distance, direction), lengthdir_y(distance, direction));
		}
		
		var p = parent.getPoint(self.distance, self.direction);
		return p.add(lengthdir_x(distance, direction), lengthdir_y(distance, direction));
	}
	
	static draw = function(edit = false, _x = 0, _y = 0, _s = 1, _mx = 0, _my = 0, child = true, hovering = noone) {
		var hover = noone;
		
		var p0 = getPoint(0, 0);
		var p1 = getPoint(length, angle);
		
		p0.x = _x + p0.x * _s;
		p0.y = _y + p0.y * _s;
		p1.x = _x + p1.x * _s;
		p1.y = _y + p1.y * _s;
		
		if(parent != noone) {
			var aa = (hovering != noone && hovering[0] == self && hovering[1] == 2)? 1 : 0.75;
			draw_set_color(COLORS._main_accent);
			if(!parent_anchor && parent.parent != noone) {
				var _p = parent.getPoint(0, 0);
				_p.x = _x + _p.x * _s;
				_p.y = _y + _p.y * _s;
				draw_line_dashed(_p.x, _p.y, p0.x, p0.y, 1);
			}
			
			draw_set_alpha(aa);
			draw_line_width2(p0.x, p0.y, p1.x, p1.y, 6, 2);
			draw_set_alpha(1.00);
			
			if(attributes.display_name) {
				if(abs(p0.y - p1.y) < abs(p0.x - p1.x)) {
					draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_accent);
					draw_text((p0.x + p1.x) / 2, (p0.y + p1.y) / 2 - 4, name);
				} else {
					draw_set_text(f_p2, fa_left, fa_center, COLORS._main_accent);
					draw_text((p0.x + p1.x) / 2 + 4, (p0.y + p1.y) / 2, name);
				}
			}
			
			if(edit && distance_to_line(_mx, _my, p0.x, p0.y, p1.x, p1.y) <= 12) //drag bone
				hover = [ self, 2 ];
			
			if(!parent_anchor) {
				if(edit && point_in_circle(_mx, _my, p0.x, p0.y, ui(20))) { //drag head
					draw_sprite_colored(THEME.anchor_selector, 0, p0.x, p0.y); 
					hover = [ self, 0 ];
				} else	
					draw_sprite_colored(THEME.anchor_selector, 2, p0.x, p0.y);
			}
			
			if(edit && point_in_circle(_mx, _my, p1.x, p1.y, ui(20))) { //drag tail
				draw_sprite_colored(THEME.anchor_selector, 0, p1.x, p1.y);
				hover = [ self, 1 ];
			} else	
				draw_sprite_colored(THEME.anchor_selector, 2, p1.x, p1.y);
		}
		
		if(child)
		for( var i = 0; i < array_length(childs); i++ ) {
			var h = childs[i].draw(edit, _x, _y, _s, _mx, _my, true, hovering);
			if(hover == noone && h != noone)
				hover = h;
		}
		
		return hover;
	}
	
	static drawInspector = function(_x, _y, _w, _m, _hover, _focus) {
		var _h = ui(28);
		
		//draw_sprite_stretched(THEME.node_bg, 0, _x, _y, _w, _h);
		draw_sprite_ui(THEME.bone, 0, _x + 12, _y + 12,,,, COLORS._main_icon);
		tb_name.setFocusHover(_focus, _hover);
		tb_name.draw(_x + 24, _y + 2, _w - 24 - 8, _h - 4, name, _m);
		
		_y += _h;
		
		draw_set_color(COLORS.node_composite_separator);
		draw_line(_x + 16, _y, _x + _w - 16, _y);
		
		for( var i = 0; i < array_length(childs); i++ ) 
			_y = childs[i].drawInspector(_x + ui(16), _y, _w - ui(16), _m, _hover, _focus);
		
		return _y;
	}
	
	static resetPose = function() {
		pose_angle = 0;
		pose_scale = 1;
		pose_posit = [ 0, 0 ];
		
		for( var i = 0; i < array_length(childs); i++ )
			childs[i].resetPose();
	}
	
	static setPose = function(_position = [ 0, 0 ], _angle = 0, _scale = 1) {
		if(is_main) {
			for( var i = 0; i < array_length(childs); i++ )
				childs[i].setPose(_position, _angle, _scale);
			return;
		}
		
		pose_posit[0] += _position[0];
		pose_posit[1] += _position[1];
		pose_angle += _angle;
		//pose_scale = _scale;
		
		var _x = lengthdir_x(distance, direction) + pose_posit[0];
		var _y = lengthdir_y(distance, direction) + pose_posit[1];
		
		direction = point_direction(0, 0, _x, _y);
		distance  = point_distance(0, 0, _x, _y);
		
		angle  += pose_angle;
		length *= pose_scale;
		
		for( var i = 0; i < array_length(childs); i++ )
			childs[i].setPose(_position, _angle, _scale);
	}
	
	static serialize = function() {
		var bone = {};
		
		bone.id			= id;
		bone.name		= name;
		bone.distance	= distance;
		bone.direction	= direction;
		bone.angle		= angle;
		bone.length		= length;
		
		bone.is_main		= is_main;
		bone.parent_anchor	= parent_anchor;
		
		bone.childs = [];
		for( var i = 0; i < array_length(childs); i++ )
			bone.childs[i] = childs[i].serialize();
			
		return bone;
	}
	
	static deserialize = function(bone, attributes) {
		id			= bone.id;
		name		= bone.name;
		distance	= bone.distance;
		direction	= bone.direction;
		angle		= bone.angle;
		length		= bone.length;
	
		is_main			= bone.is_main;
		parent_anchor	= bone.parent_anchor;
		
		self.attributes = attributes;
		
		childs = [];
		for( var i = 0; i < array_length(bone.childs); i++ ) {
			var _b = new __Bone().deserialize(bone.childs[i], attributes);
			addChild(_b);
		}
		
		return self;
	}
	
	static clone = function(attributes) {
		var _b = new __Bone(parent, distance, direction, angle, length, attributes);
		_b.id = id;
		_b.name = name;
		_b.is_main = is_main;
		_b.parent_anchor = parent_anchor;
		
		for( var i = 0; i < array_length(childs); i++ )
			_b.addChild(childs[i].clone(attributes));
		
		return _b;
	}
}