function Node_RM(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "RM";
	is_3D = NODE_3D.sdf;
	
	temp_surface = [ noone, noone ];
	environ = new RM_Environment();
	object  = noone;

	attribute_interpolation(true);
		
	attributes.texture_size = 1024;
	array_push(attributeEditors, "Raymarching");
	array_push(attributeEditors, Node_Attribute("Texture size",  function() /*=>*/ {return attributes.texture_size}, function() /*=>*/ {return textBox_Number(function(i) /*=>*/ {return setAttribute("texture_size", i)})}));
	
	static drawOverlay3D = function(active, _mx, _my, _params) {}
	
}