function Node_Matrix_Eigen(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Eigen";
	color = COLORS.node_blend_number;
	setDrawIcon(s_node_matrix_eigen);
	setDimension(96, 48);
	
	newInput(0, nodeValue_Matrix("Matrix", new Matrix(3))).setVisible(true, true);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Eigenvector", VALUE_TYPE.float, [] )).setArrayDepth(1);
	newOutput(1, nodeValue_Output("Eigenvalue",  VALUE_TYPE.float,  0 ));
	
	////- Nodes
	
	square_label       = new Inspector_Label("");
	input_display_list = [ 0, square_label ];
	
	static processData = function(_outData, _data, _array_index = 0) {
		var _mat = _data[0];
		square_label.text = _mat.isSquare()? "" : "Cannot find eigenvalues for non-square matrix.";
		if(!_mat.isSquare()) return _outData;
		
		var siz = _mat.size[0];
		var arr = _mat.raw;
		
		// Compute eigenvalues and eigenvectors using Power Iteration method
		// I did not write this code myself -MakhamDev
		var eigenvalues    = [];
		var eigenvectors   = [];
		var max_iterations = 1000;
		var tolerance      = .00001;

		var A = array_clone(arr);
		for(var i = 0; i < siz; i++) {
			var b_k = array_create(siz, 1);
			var eigenvalue = 0.0;
			
			for(var iter = 0; iter < max_iterations; iter++) {
				// Matrix-vector multiplication
				var b_k1 = array_create(siz, 0);
				for(var row = 0; row < siz; row++)
				for(var col = 0; col < siz; col++)
					b_k1[row] += A[row * siz + col] * b_k[col];
				
				// Normalize the vector
				var norm = 0.0;
				for(var j = 0; j < siz; j++)
					norm += b_k1[j] * b_k1[j];
				if(is_nan(norm)) { noti_warning("Eigenvalue computation failed."); return; }
				
				norm = sqrt(norm);
				for(var j = 0; j < siz; j++)
					b_k1[j] /= norm;
				
				// Rayleigh quotient for eigenvalue
				var eigenvalue_new = 0.0;
				for(var row = 0; row < siz; row++) {
					var temp = 0.0;
					for(var col = 0; col < siz; col++)
						temp += A[row * siz + col] * b_k1[col];
					eigenvalue_new += b_k1[row] * temp;
				}

				// Check for convergence
				if(abs(eigenvalue_new - eigenvalue) < tolerance)
					break;

				eigenvalue = eigenvalue_new;
				b_k = b_k1;
			}

			eigenvalues[i]  = eigenvalue;
			eigenvectors[i] = array_clone(b_k);

			// Deflation
			var outer_product = array_create(siz * siz, 0.0);
			for(var row = 0; row < siz; row++)
			for(var col = 0; col < siz; col++)
				outer_product[row * siz + col] = b_k[row] * b_k[col];
			
			for(var row = 0; row < siz; row++)
			for(var col = 0; col < siz; col++)
				A[row * siz + col] -= eigenvalue * outer_product[row * siz + col];
		}

		_outData[0] = eigenvectors;
		_outData[1] = eigenvalues;
		
		return _outData;
	}
	
}