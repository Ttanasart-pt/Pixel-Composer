function FFT(array_in) {
	var amo = array_length(array_in);
	if(amo == 0) return [];
	
	if(log2(amo) != 0) {
		var lft = power(2, ceil(log2(amo))) - amo;
		repeat(lft) array_push(array_in, new Complex());
	}
	
	var fq = _FFT(array_in);
	array_resize(fq, array_length(fq) / 2);
	fq = array_reverse(fq)
	return fq;
}
	
function _FFT(array_in) {
	var n  = array_length(array_in);
	var nh = n div 2;
	var theta = (2 * pi) / n;

	if (n == 1)
	    return array_in;

	var even = array_create(nh, 0);
	var odd  = array_create(nh, 0);

	for (var i = 0; i < nh; i++) {
	    even[i] = array_in[i * 2];
	    odd[i]  = array_in[(i * 2) + 1];
	}

	var evenFFT = _FFT(even);
	var oddFFT  = _FFT(odd);
		
	//print($"> {evenFFT}, {oddFFT}");
	
	var array_out = array_create(n);
		
	for (var i = 0; i < nh; i++) {
		var t = new Complex(
			cos(-theta * i),
			sin(-theta * i)
		);
			
		var oddK = new Complex(
			oddFFT[i].re * t.re - oddFFT[i].im * t.im,
			oddFFT[i].re * t.im + oddFFT[i].im * t.re,
		);
			
	    array_out[i] = new Complex(
			evenFFT[i].re + oddK.re,
			evenFFT[i].im + oddK.im,
		);
			
	    array_out[i + nh] = new Complex(
			evenFFT[i].re - oddK.re,
			evenFFT[i].im - oddK.im,
		);
	}
		
	//show_debug_message($" |  {array_out}");
	//show_debug_message("=====")
		
	return array_out;
};