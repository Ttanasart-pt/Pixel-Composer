function __Bone(parent = noone, distance = 0, direction = 0, angle = 0, length = 0) constructor {
	self.name = "New bone";
	self.distance	= distance;
	self.direction	= direction;
	self.angle		= angle;
	self.length		= length;
	
	self.is_main = false;
	self.parent_anchor = true;
	self.childs = [];
	
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
			
			if(edit && distance_to_line(_mx, _my, p0.x, p0.y, p1.x, p1.y) <= 6) //drag bone
				hover = [ self, 2 ];
			
			if(!parent_anchor) {
				if(edit && point_in_circle(_mx, _my, p0.x, p0.y, ui(12))) { //drag head
					draw_sprite_colored(THEME.anchor_selector, 0, p0.x, p0.y); 
					hover = [ self, 0 ];
				} else	
					draw_sprite_colored(THEME.anchor_selector, 2, p0.x, p0.y);
			}
			
			if(edit && point_in_circle(_mx, _my, p1.x, p1.y, ui(12))) { //drag tail
				draw_sprite_colored(THEME.anchor_selector, 0, p1.x, p1.y);
				hover = [ self, 1 ];
			} else	
				draw_sprite_colored(THEME.anchor_selector, 2, p1.x, p1.y);
		}
		
		if(child)
		for( var i = 0; i < array_length(childs); i++ ) {
			var h = childs[i].draw(edit, _x, _y, _s, _mx, _my, true, hovering)
			if(hover == noone && h != noone)
				hover = h;
		}
		
		return hover;
	}
	
	static serialize = function() {
		var bone = {};
		
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
	
	static deserialize = function(bone) {
		name		= bone.name;
		distance	= bone.distance;
		direction	= bone.direction;
		angle		= bone.angle;
		length		= bone.length;
	
		is_main			= bone.is_main;
		parent_anchor	= bone.parent_anchor;
		
		childs = [];
		for( var i = 0; i < array_length(bone.childs); i++ ) {
			var _b = new __Bone().deserialize(bone.childs[i]);
			addChild(_b);
		}
		
		return self;
	}
}