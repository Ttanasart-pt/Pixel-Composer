function Node_Armature_Sample(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Armature Sample";
	setDimension(96, 72);
	
	inputs[| 0] = nodeValue("Armature", self, JUNCTION_CONNECT.input, VALUE_TYPE.armature, noone)
		.setVisible(true, true)
		.rejectArray();
		
	inputs[| 1] = nodeValue("Bone name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
		
	inputs[| 2] = nodeValue("Sample point", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Position", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	#region ++++ attributes ++++
	attributes.display_name = true;
	attributes.display_bone = 0;
	
	array_push(attributeEditors, "Display");
	array_push(attributeEditors, ["Display name", function() { return attributes.display_name; }, 
		new checkBox(function() { 
			attributes.display_name = !attributes.display_name;
		})]);
	array_push(attributeEditors, ["Display bone", function() { return attributes.display_bone; }, 
		new scrollBox(["Octahedral", "Stick"], function(ind) { 
			attributes.display_bone = ind;
		})]);
	#endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _b	  = getInputData(0);
		
		if(_b == noone) return;
		_b.draw(attributes, false, _x, _y, _s, _mx, _my);
	} #endregion
	
	static update = function() { #region
		var _bone = getInputData(0);
		var _name = getInputData(1);
		var _prog = getInputData(2);
		
		if(_bone == noone) return;
		
		_name = string_trim(_name);
		
		var _b = _bone.findBoneByName(_name);
		if(_b == noone) {
			outputs[| 0].setValue([0, 0]);
			return;
		}
		
		var _p = _b.getPoint(_prog);
		outputs[| 0].setValue([_p.x, _p.y]);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_armature_sample, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}