function getGradientData(gradient, data) {
	var _grad_color = [];
	var _grad_time  = [];
	for(var i = 0; i < ds_list_size(gradient); i++) {
		_grad_color[i * 4 + 0] = color_get_red(gradient[| i].value) / 255;
		_grad_color[i * 4 + 1] = color_get_green(gradient[| i].value) / 255;
		_grad_color[i * 4 + 2] = color_get_blue(gradient[| i].value) / 255;
		_grad_color[i * 4 + 3] = 1;
		_grad_time[i]  = gradient[| i].time;
	}
	
	return [_grad_color, _grad_time];
}