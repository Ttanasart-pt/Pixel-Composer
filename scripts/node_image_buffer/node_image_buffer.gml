function Node_Image_Buffer(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Image";
	
	newOutput(0, nodeValue_Output("Surface", VALUE_TYPE.surface, noone));
	
	attributes.data   = noone;
	attributes.width  = 1;
	attributes.height = 1;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {}
	
	static update = function() {
		var _surf = outputs[0].getValue();
		_surf = surface_verify(_surf, attributes.width, attributes.height);
		
		if(buffer_exists(attributes.data))
			buffer_set_surface(attributes.data, _surf, 0);
		
		outputs[0].setValue(_surf);
	}
	
	static attributeSerialize = function() { 
		var _buff = buffer_serialize(attributes.data);
		return { buffer: _buff }; 
	}
	
	static attributeDeserialize = function(attr) {
		struct_override(attributes, attr, true); 
		
		var _buff = attr.buffer;
		attributes.data = buffer_deserialize(_buff);
	}
}
