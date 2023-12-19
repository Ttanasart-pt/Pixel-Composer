function Node_DynaSurf(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "Dynamic Surface";
	color = COLORS.node_blend_dynaSurf;
	
	reset_all_child = true;
	draw_input_overlay = false;
	
	outputs[| 0] = nodeValue("dynaSurf", self, JUNCTION_CONNECT.output, VALUE_TYPE.dynaSurface, noone);
	
	custom_input_index  = ds_list_size(inputs);
	custom_output_index = ds_list_size(outputs);
	
	if(!LOADING && !APPENDING && !CLONING) { #region
		var _input  = nodeBuild("Node_DynaSurf_In",  -256, -32, self);
		var _output = nodeBuild("Node_DynaSurf_Out",  256, -32, self);
		
		_output.inputs[| 0].setFrom(_input.outputs[| 0]);
		
		var _yy   = -32 + 24;
		var _nx   = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("x");		_output.inputs[| 1].setFrom(_nx  .outputs[| 0]);  _yy += 24;
		var _ny   = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("y");		_output.inputs[| 2].setFrom(_ny  .outputs[| 0]);  _yy += 24;
		var _nsx  = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("sx");		_output.inputs[| 3].setFrom(_nsx .outputs[| 0]);  _yy += 24;
		var _nsy  = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("sy");		_output.inputs[| 4].setFrom(_nsy .outputs[| 0]);  _yy += 24;
		var _nang = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("angle");	_output.inputs[| 5].setFrom(_nang.outputs[| 0]);  _yy += 24;
		var _nclr = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("color");	_output.inputs[| 6].setFrom(_nclr.outputs[| 0]);  _yy += 24;
		var _nalp = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("alpha");	_output.inputs[| 7].setFrom(_nalp.outputs[| 0]);  _yy += 24;
		
		_nsx.inputs[| 0].setValue(1);
		_nsy.inputs[| 0].setValue(1);
		_nclr.inputs[| 0].setValue(c_white);
		_nalp.inputs[| 0].setValue(1);
		
		_yy += 64;
		var _outW   = nodeBuild("Node_DynaSurf_Out_Width",   256, _yy, self) 
		var _surW   = nodeBuild("Node_PCX_fn_Surface_Width", 128, _yy, self) 
		
		_surW.inputs[| 0].setFrom(_input.outputs[| 0]);
		_outW.inputs[| 0].setFrom(_surW.outputs[| 0]);
		
		_yy += 64;
		var _outH   = nodeBuild("Node_DynaSurf_Out_Height",   256, _yy, self) 
		var _surH   = nodeBuild("Node_PCX_fn_Surface_Height", 128, _yy, self) 
		
		_surH.inputs[| 0].setFrom(_input.outputs[| 0]);
		_outH.inputs[| 0].setFrom(_surH.outputs[| 0]);
		
		RENDER_ALL 
	} #endregion
	
	static setRenderStatus = function(result) { #region
		rendered = result;
		
		if(result)
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var _n = nodes[| i];
			
			if(!is_instanceof(_n, Node_DynaSurf_Out) && 
			   !is_instanceof(_n, Node_DynaSurf_Out_Width) &&
			   !is_instanceof(_n, Node_DynaSurf_Out_Height))
				continue;
				
			if(_n.rendered) continue;
			rendered = false;
			break;
		}
		
		if(rendered) exitGroup();
		
		if(!result && group != noone) 
			group.setRenderStatus(result);
	} #endregion
	
	static setDynamicSurface = function() { #region
		var _dyna = new compute_dynaSurf();
		
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var _n = nodes[| i];
			
			if(is_instanceof(_n, Node_DynaSurf_Out))
				_dyna.drawFn   = _n.outputs[| 0].getValue();
			if(is_instanceof(_n, Node_DynaSurf_Out_Width))
				_dyna.widthFn  = _n.outputs[| 0].getValue();
			if(is_instanceof(_n, Node_DynaSurf_Out_Height))
				_dyna.heightFn = _n.outputs[| 0].getValue();
		}
		
		outputs[| 0].setValue(_dyna);
	} #endregion
	
	static update = function() {}
}

function dynaSurf_output_getNextNode() { #region
	if(!is_instanceof(group, Node_DynaSurf)) return [];
		
	var junc  = group.outputs[| 0];
	var nodes = [];
	for(var j = 0; j < array_length(junc.value_to); j++) {
		var _to = junc.value_to[j];
		if(!_to.node.isRenderActive()) continue;
			
		if(!_to.node.active || _to.isLeaf()) 
			continue; 
		if(_to.value_from.node != group)
			continue; 
			
		array_push(nodes, _to.node);
	}
		
	return nodes;
} #endregion
	