function Node_Pixel_Builder(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "Pixel Builder";
	color = COLORS.node_blend_feedback;
	icon  = THEME.pixel_builder;
	
	reset_all_child = true;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	custom_input_index  = ds_list_size(inputs);
	custom_output_index = ds_list_size(outputs);
	
	if(!LOADING && !APPENDING && !CLONING) {
		var input  = nodeBuild("Node_PB_Layer", -256, -32, self);
		UPDATE |= RENDER_TYPE.full; 
	}
	
	static getNextNodes = function() {
		var allReady = true;
		for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i].from;
			if(!_in.isRenderActive()) continue;
			
			allReady &= _in.isRenderable()
		}
		
		if(!allReady) return [];
		
		return __nodeLeafList(getNodeList());
	}
	
	static checkComplete = function() {
		for( var i = 0; i < ds_list_size(nodes); i++ )
			if(!nodes[| i].rendered) return [];
		
		buildPixel();
		
		var _nodes = [];
		var _tos  = outputs[| 0].getJunctionTo();
			
		for( var j = 0; j < array_length(_tos); j++ ) {
			var _to = _tos[j];
			array_push(_nodes, _to.node);
		}
		
		return _nodes;
	}
	
	static update = function() {
		var _dim     = getInputData(0);
		
		for( var i = 0; i < ds_list_size(nodes); i++ ) {
			var _n = nodes[| i];
			
			if(!is_instanceof(_n, Node_PB_Layer))
				continue;
			
			var _layer = _n.getInputData(0);
			
			var _box = new __pbBox();
			_box.layer	 = _layer;
			_box.w		 = _dim[0];
			_box.h		 = _dim[1];
			_box.layer_w = _dim[0];
			_box.layer_h = _dim[1];
			
			_n.outputs[| 0].setValue(_box);
		}
		
		outputs[| 0].setValue(surface_create(_dim[0], _dim[1]));
	}
	
	static buildPixel = function() {
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render, $"================== BUILD PIXEL ==================");
		LOG_BLOCK_START();
		
		var _dim     = getInputData(0);
		var _surfs   = ds_map_create();
		
		for( var i = 0; i < ds_list_size(nodes); i++ ) {
			var _n = nodes[| i];
			
			for( var j = 0; j < ds_list_size(_n.outputs); j++ ) {
				var _out = _n.outputs[| j];
				
				if(_out.type != VALUE_TYPE.pbBox) continue;
				var _to  = _out.getJunctionTo();
				if(array_length(_to)) continue;
				
				var _pbox = _n.outputs[| j].getValue();
				
				if(!is_array(_pbox)) 
					_pbox = [ _pbox ];
			
				for( var k = 0; k < array_length(_pbox); k++ ) {
					var _box = _pbox[k];
					if(!is_instanceof(_box, __pbBox)) continue;
					if(!is_surface(_box.content)) continue;
					
					var _layer = _box.layer;
					if(!ds_map_exists(_surfs, _layer))
						_surfs[? _layer] = [];
					array_push(_surfs[? _layer], _box);
				} 
			}
		}
		
		var _outSurf = outputs[| 0].getValue();
		surface_array_free(_outSurf);
		
		if(ds_map_empty(_surfs)) {
			ds_map_destroy(_surfs);
			outputs[| 0].setValue(surface_create(_dim[0], _dim[1]));
			return;
		}
		
		var _layers = ds_map_keys_to_array(_surfs);
		
		array_sort(_layers, true);
		
		_outSurf = surface_create(_dim[0], _dim[1]);
		surface_set_target(_outSurf);
		DRAW_CLEAR
			
		for( var k = 0; k < array_length(_layers); k++ ) {
			var _s = _surfs[? _layers[k]];
				
			for( var j = 0; j < array_length(_s); j++ ) {
				var _box = _s[j];
				draw_surface_safe(_box.content, _box.x, _box.y);
			}
		}
			
		surface_reset_target();
		
		ds_map_destroy(_surfs);
		
		outputs[| 0].setValue(_outSurf);
	}
	
	PATCH_STATIC
}