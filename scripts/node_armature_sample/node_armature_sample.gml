function Node_Armature_Sample(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Sample";
	setDimension(96, 72);
	
	newInput(0, nodeValue_Armature())
		.setVisible(true, true)
		.rejectArray();
		
	newInput(1, nodeValue_Text("Bone name"));
		
	newInput(2, nodeValue_Slider("Sample point", 0));
	
	newOutput(0, nodeValue_Output("Position", VALUE_TYPE.integer, [ 0, 0 ]))
		.setDisplay(VALUE_DISPLAY.vector);
	
	attributes.display_name = true;
	attributes.display_bone = 0;
	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Display name", function() /*=>*/ {return attributes.display_name}, new checkBox(function() /*=>*/ {return toggleAttribute("display_name")})]);
	array_push(attributeEditors, ["Display bone", function() /*=>*/ {return attributes.display_bone}, new scrollBox(__txts(["Octahedral", "Stick"]), function(i) /*=>*/ {return setAttribute("display_bone", i)})]);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _b = getInputData(0);
		
		if(_b == noone) return;
		_b.draw(attributes, false, _x, _y, _s, _mx, _my);
	}
	
	static update = function() {
		var _bone = getInputData(0);
		var _name = getInputData(1);
		var _prog = getInputData(2);
		
		if(_bone == noone) return;
		
		_name = string_trim(_name);
		
		var _b = _bone.findBoneByName(_name);
		if(_b == noone) {
			outputs[0].setValue([0, 0]);
			return;
		}
		
		var _p = _b.getPoint(_prog);
		outputs[0].setValue([_p.x, _p.y]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_armature_sample, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}