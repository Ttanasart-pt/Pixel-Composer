function Node_DynaSurf(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "Dynamic Surface";
	color = COLORS.node_blend_dynaSurf;
	icon  = THEME.pixel_builder;
	
	reset_all_child = true;
	draw_input_overlay = false;
	
	outputs[| 0] = nodeValue("DynaSurf", self, JUNCTION_CONNECT.output, VALUE_TYPE.dynaSurf, noone);
	
	custom_input_index  = ds_list_size(inputs);
	custom_output_index = ds_list_size(outputs);
	
	if(!LOADING && !APPENDING && !CLONING) {
		var _input  = nodeBuild("Node_DynaSurf_In",  -256, -32, self);
		var _output = nodeBuild("Node_DynaSurf_Out",  256, -32, self);
		
		var _yy   = -32 + 24;
		var _nx   = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("x");		_output.inputs[| 1].setFrom(_nx  .outputs[| 0]);  _yy += 24;
		var _ny   = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("y");		_output.inputs[| 2].setFrom(_ny  .outputs[| 0]);  _yy += 24;
		var _nsx  = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("sx");		_output.inputs[| 3].setFrom(_nsx .outputs[| 0]);  _yy += 24;
		var _nsy  = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("sy");		_output.inputs[| 4].setFrom(_nsy .outputs[| 0]);  _yy += 24;
		var _nang = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("angle");	_output.inputs[| 5].setFrom(_nang.outputs[| 0]);  _yy += 24;
		var _nclr = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("color");	_output.inputs[| 6].setFrom(_nclr.outputs[| 0]);  _yy += 24;
		var _nalp = nodeBuild("Node_PCX_fn_var",  128, _yy, self).setDisplayName("alpha");	_output.inputs[| 7].setFrom(_nalp.outputs[| 0]);  _yy += 24;
		
		_yy += 64;
		var _outW   = nodeBuild("Node_DynaSurf_Out_Width",   256, _yy, self) _yy += 64;
		var _outH   = nodeBuild("Node_DynaSurf_Out_Height",  256, _yy, self) _yy += 64;
		UPDATE |= RENDER_TYPE.full; 
	}
	
	static update = function() {
		var _dyna = new Compute_DynaSurf();
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
	}
}