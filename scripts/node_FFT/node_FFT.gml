function Node_FFT(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "FFT";
	setDimension(96, 72);
	setDrawIcon();
	
	newInput( 0, nodeValue_Float(   "Data", [])).setArrayDepth(1).setVisible(true, true);
	
	////- =Preprocess
	newInput( 1, nodeValue_EScroll( "Preprocess Function",  0, [ "None", "Hann", "Blackman" ] ));
	// 2
		
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.float, [])).setArrayDepth(1);
	
	input_display_list = [  0, 
		[ "Preprocess", false ],  1, 
	];
	
	////- Node
	
	__use_ext = true;
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dat = _data[ 0];
			
			var _pre = _data[ 1];
			
		#endregion
		
		var  N  = array_length(_dat);
		
		if(N <= 1) return [];
		
		if(__use_ext) {
			var _args   = buffer_create(1, buffer_grow, 1);
			var bData   = buffer_create(1, buffer_grow, 1);    buffer_to_start(bData);
			var bOutput = buffer_create(N*8, buffer_grow, 1);  buffer_to_start(bOutput);
			
			for( var i = 0; i < N; i++ )
				buffer_write(bData, buffer_f64, _dat[i]);
			
			buffer_to_start(_args);
			buffer_write(_args, buffer_u64, buffer_get_address(bData));
			buffer_write(_args, buffer_u64, buffer_get_address(bOutput));
			
			buffer_write(_args, buffer_u32, N);
			buffer_write(_args, buffer_u32, _pre);
			
			var oLen = cfunc_FFT(buffer_get_address(_args));
			var _res = array_create(oLen);
			
			buffer_to_start(bOutput);
			for( var i = 0; i < oLen; i++ )
				_res[i] = buffer_read(bOutput, buffer_f64);
			
			buffer_delete(_args);
			buffer_delete(bData);
			buffer_delete(bOutput);
			
			return _res;
		}
		
		var _N  = 1 / (N - 1);
		var tau = pi * 2;
		
		var _datCom = array_create(N);
		
		switch(_pre) {
			case 0 : 
				for( var i = 0; i < N; i++ )
					_datCom[i] = new Complex(_dat[i]);
				break;
			
			case 1 : 
				for( var i = 0; i < N; i++ ) {
					var d = _dat[i];
					var v = d * .5 * (1 - cos(tau * i * _N));
					_datCom[i] = new Complex(v);
				}
				break;
				
			case 2 :
				for( var i = 0; i < N; i++ ) {
					var d = _dat[i];
					var v = d * (.42 - .5 * cos(tau * i * _N) + .08 * cos(2 * tau * i * _N));
					_datCom[i] = new Complex(v);
				}
				break;
		}
		
		var _fft = FFT(_datCom);
		var _res = array_create(array_length(_fft));
		
		for( var i = 0, n = array_length(_fft); i < n; i++ )
			_res[i] = sqrt(sqr(_fft[i].re) + sqr(_fft[i].im));
		
		return _res;
	}
}

/*[cpp]
#define _USE_MATH_DEFINES

#include <cmath>
#include <cstdint>

using namespace std;

struct Complex {
    double re;
    double im;
};

struct FFTArgs {
    void* data;
    void* output;

    uint32_t length;
    uint32_t windowFn;
};

Complex* _fft(Complex* data, uint32_t length) {
    uint32_t halfLength = length / 2;
    double theta = 2 * M_PI / static_cast<double>(length);

    if (length <= 1)
        return data;

    Complex* even = new Complex[halfLength];
    Complex* odd = new Complex[halfLength];

    for (uint32_t i = 0; i < halfLength; i++) {
        even[i] = data[i * 2];
        odd[i]  = data[i * 2 + 1];
    }

    even = _fft(even, halfLength);
    odd  = _fft(odd, halfLength);

    Complex* output = new Complex[length];

    for (uint32_t k = 0; k < halfLength; ++k) {
        Complex t;
        t.re = cos(-theta * k) * odd[k].re - sin(-theta * k) * odd[k].im;
        t.im = sin(-theta * k) * odd[k].re + cos(-theta * k) * odd[k].im;

        output[k].re = even[k].re + t.re;
        output[k].im = even[k].im + t.im;
        output[k + halfLength].re = even[k].re - t.re;
        output[k + halfLength].im = even[k].im - t.im;
    }

    delete[] even;
    delete[] odd;
    return output;
}

cfunction double cfunc_FFT(FFTArgs* args) {
    FFTArgs* fftArgs  = args;

    double* data      = static_cast<double*>(fftArgs->data);
    double* output    = static_cast<double*>(fftArgs->output);

    uint32_t length   = fftArgs->length;
    uint32_t windowFn = fftArgs->windowFn;

    Complex* complexData = new Complex[length];

    double TAU  = 2 * M_PI;
    double iLen = 1. / static_cast<double>(length);

    switch(windowFn) {
        case 1 : // Hann
            for (uint32_t i = 0; i < length; i++) {
                double window = .5 * (1 - cos(TAU * i * iLen));
                complexData[i].re = data[i] * window;
                complexData[i].im = 0.;
            }
            break;

        case 2 : // Hamming
            for (uint32_t i = 0; i < length; i++) {
                double window = .42 - .5 * cos(TAU * i * iLen) + .08 * cos(2 * TAU * i * iLen);
                complexData[i].re = data[i] * window;
                complexData[i].im = 0.;
            }
            break;

        default : // no window
            for (uint32_t i = 0; i < length; i++) {
                complexData[i].re = data[i];
                complexData[i].im = 0.;
            }
            break;

    }

    double logLen = log2(static_cast<double>(length));
    if(logLen == 0) return 0;
    
    uint32_t padLen = static_cast<uint32_t>(pow(2, ceil(logLen)));

    Complex* paddedData = new Complex[padLen];
    for (uint32_t i = 0; i < length; i++) 
        paddedData[i] = complexData[i];
    
    for (uint32_t i = length; i < padLen; i++) {
        paddedData[i].re = 0.;
        paddedData[i].im = 0.;
    }

    Complex* rawResult = _fft(paddedData, padLen);
    uint32_t resultLength = padLen / 2 + 1;
    
    for (uint32_t i = 0; i < resultLength; i++) {
        Complex c = rawResult[resultLength - 1 - i];
        
        float len = sqrt(c.re * c.re + c.im * c.im);
        output[i] = len;
    }
    
    delete[] rawResult;
    delete[] paddedData;

    return resultLength;
}
*/