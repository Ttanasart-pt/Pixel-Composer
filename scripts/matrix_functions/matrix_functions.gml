function __matrix_determinant(matrix, size) {
    if (size == 1) return matrix[0];
    if (size == 2) return matrix[0] * matrix[3] - matrix[1] * matrix[2];
        
    var det = 0;
    for (var i = 0; i < size; i++) {
        var subMatrix = [];
        for (var j = 1; j < size; j++)
        for (var k = 0; k < size; k++) {
            if (k == i) continue;
            array_push(subMatrix, matrix[j * size + k]);
        }
        
        det += matrix[i] * __matrix_determinant(subMatrix, size - 1) * (i % 2 == 0 ? 1 : -1);
    }
    
    return det;
}

function __matrix_inverse(matrix, size) {
    var det = __matrix_determinant(matrix, size);
    if (det == 0) return matrix; // Matrix is not invertible
    
    var inverse = array_create(size * size, 0);
    if (size == 1) {
        inverse[0] = 1 / matrix[0];
        
    } else if (size == 2) {
        inverse[0] =  matrix[3] / det;
        inverse[1] = -matrix[1] / det;
        inverse[2] = -matrix[2] / det;
        inverse[3] =  matrix[0] / det;
        
    } else {
        for (var i = 0; i < size; i++)
        for (var j = 0; j < size; j++) {
            var subMatrix = [];
            for (var k = 0; k < size; k++) {
                if (k == i) continue;
                
                for (var l = 0; l < size; l++) {
                    if (l == j) continue;
                    array_push(subMatrix, matrix[k * size + l]);
                }
            }
            
            inverse[j * size + i] = __matrix_determinant(subMatrix, size - 1) * ((i + j) % 2 == 0 ? 1 : -1) / det;
        }
    }
    
    return inverse;
}

function __matrix_transpose(matrix, size2) {
    var transpose = array_create(size2[0] * size2[1], 0);
    for (var i = 0; i < size2[1]; i++)
    for (var j = 0; j < size2[0]; j++)
        transpose[j * size2[1] + i] = matrix[i * size2[0] + j];
    
    return transpose;
}