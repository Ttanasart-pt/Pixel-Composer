function getGradientData(gradient, data) {
	var _grad_color = [];
	var _grad_time  = [];
	for(var i = 0; i < ds_list_size(gradient); i++) {
		_grad_color[i * 4 + 0] = _color_get_red(gradient[| i].value);
		_grad_color[i * 4 + 1] = _color_get_green(gradient[| i].value);
		_grad_color[i * 4 + 2] = _color_get_blue(gradient[| i].value);
		_grad_color[i * 4 + 3] = _color_get_alpha(gradient[| i].value);
		_grad_time[i]  = gradient[| i].time;
	}
	
	return [_grad_color, _grad_time];
}