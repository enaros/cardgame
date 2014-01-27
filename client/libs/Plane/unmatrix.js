/*
Copyright (c) 2014 David Buezas. Based on jquery unmatrix plugin (from Stanislav Sopov https://github.com/stassop/unmatrixk) and d3.vector.js 
(Jason Davies) both of which are based on http://dev.w3.org/csswg/css3-transforms/#matrix-decomposing, 
which in term is based on Graphics Gems II, edited by Jim Arvo
*/

(function(S){

    // Returns null if the matrix cannot be decomposed, an object if it can.
    window.unmatrix = function(matrix) {
        // todo: export unmatrix in a less nasty way?
        var matrix = [
            [matrix.m11, matrix.m12, matrix.m13, matrix.m14],
            [matrix.m21, matrix.m22, matrix.m23, matrix.m24],
            [matrix.m31, matrix.m32, matrix.m33, matrix.m34],
            [matrix.m41, matrix.m42, matrix.m43, matrix.m44]
        ]
        // d = decomposition
        var d = {
            rotate:     { x: null, y: null, z: null }, 
            scale:      { x: null, y: null, z: null },
            skew:       { x: null, y: null          },
            translate:  { x: null, y: null, z: null }
        }
        
        var skew;
        
        // Normalize the matrix.
        if (matrix[3][3] == 0) {
            return null;
        }

        for (var i = 0; i < 4; i++) {
            for (var j = 0; j < 4; j++) {
                matrix[i][j] /= matrix[3][3];
            }
        }
        
        // perspectiveMatrix is used to solve for perspective, but it also provides an easy way to test for 
        // singularity of the upper 3x3 component.
        var perspectiveMatrix = matrix;

        for (var i = 0; i < 3; i++) {
           perspectiveMatrix[i][3] = 0;
        }

        perspectiveMatrix[3][3] = 1;

        if (determinant(perspectiveMatrix) == 0) {
           return null;
        }

        // First, isolate perspective.
        var perspective;
        if (matrix[0][3] != 0 || matrix[1][3] != 0 || matrix[2][3] != 0) {
            // rightHandSide is the right hand side of the equation.
            var rightHandSide = new Array();
            rightHandSide[0] = matrix[0][3];
            rightHandSide[1] = matrix[1][3];
            rightHandSide[2] = matrix[2][3];
            rightHandSide[3] = matrix[3][3];

            // Solve the equation by inverting perspectiveMatrix and multiplying rightHandSide by the inverse.
            inversePerspectiveMatrix = inverse(perspectiveMatrix);
            transposedInversePerspectiveMatrix = transpose(inversePerspectiveMatrix);
            perspective = multiplyVectorMatrix(rightHandSide, transposedInversePerspectiveMatrix);
            
            // Clear the perspective partition.
            matrix[0][3] = matrix[1][3] = matrix[2][3] = 0;
            matrix[3][3] = 1;
        } else {
            // No perspective.
            perspective = new Array();
            perspective[0] = perspective[1] = perspective[2] = 0;
            perspective[3] = 1;
        }

        // Next take care of translation.
        d.translate.x = matrix[3][0];
        //matrix[3][0] = 0;
        d.translate.y = matrix[3][1];
        //matrix[3][1] = 0;
        d.translate.z = matrix[3][2];
        //matrix[3][2] = 0;

        // Now get scale and shear. 'row' is a 3 element array of 3 component vectors.
        var row = [[],[],[]];

        for (var i = 0; i < 3; i++) {
            row[i][0] = matrix[i][0];
            row[i][1] = matrix[i][1];
            row[i][2] = matrix[i][2];
        }

        // Compute X scale factor and normalize first row.
        d.scale.x = length(row[0]);
        row[0] = normalize(row[0]);

        // Compute XY shear factor and make 2nd row orthogonal to 1st.
        skew = dot(row[0], row[1]);
        row[1] = combine(row[1], row[0], 1.0, -skew);

        // Now, compute Y scale and normalize 2nd row.
        d.scale.y = length(row[1]);
        row[1] = normalize(row[1]);
        skew /= d.scale.y;
        
        // Compute XZ and YZ shears, orthogonalize 3rd row.
        d.skew.x = dot(row[0], row[2]);
        row[2] = combine(row[2], row[0], 1.0, -d.skew.x);
        d.skew.y = dot(row[1], row[2]);
        row[2] = combine(row[2], row[1], 1.0, -d.skew.y);

        // Next, get Z scale and normalize 3rd row.
        d.scale.z = length(row[2]);
        row[2] = normalize(row[2]);
        d.skew.x /= d.scale.z;
        d.skew.y /= d.scale.z;
        
        // At this point, the matrix (in rows) is orthonormal. Check for a coordinate system flip. If the 
        // determinant is -1, then negate the matrix and the scaling factors.
        var pdum3 = cross(row[1], row[2]);
        
        if (dot(row[0], pdum3) < 0) {
            for (var i = 0; i < 3; i++) {
                d.scale.x *= -1;
                row[i][0] *= -1;
                row[i][1] *= -1;
                row[i][2] *= -1;
            }
        }

        // Get the rotations.
        d.rotate.y = deg(Math.asin(-row[0][2]));
        if (Math.cos(d.rotate.y) != 0) {
            d.rotate.x = deg(Math.atan2(row[1][2], row[2][2]));
            d.rotate.z = deg(Math.atan2(row[0][1], row[0][0]));
        } else {
            d.rotate.x = deg(Math.atan2(-row[2][0], row[1][1]));
            d.rotate.z = 0;
        }
        
        return d;
    }

    // Converts radians to degrees. 
    function deg(rad) {
        return rad * (180 / Math.PI);
    }

    // Returns determinant of matrix. 
    function determinant(matrix) {
        return S.Matrix(matrix).determinant();
    }         
    
    // Returns inverse of matrix. 
    function inverse(matrix) {
        return S.Matrix(matrix).inverse().elements;
    }         

    // Returns transpose of matrix. 
    function transpose(matrix) {
        return S.Matrix(matrix).transpose().elements;
    }

    // Multiplies vector by matrix and returns transformed vector.
    function multiplyVectorMatrix(vector, matrix) {
        return S.Matrix(matrix).multiply(vector).elements;
    }

    // Returns length of vector. 
    function length(vector) {
        return S.Vector(vector).modulus();
    }   

    // Normalizes length of vector to 1. 
    function normalize(vector) {
        return S.Vector(vector).toUnitVector().elements;
    }

    // Returns dot product of points. 
    function dot(vector1, vector2) {
        return S.Vector(vector1).dot(vector2);
    }

    // Returns cross product of vectors.
    function cross(vector1, vector2) {
        return S.Vector(vector1).cross(vector2).elements;
    }
    
    function combine(a, b, ascl, bscl) {
        var result = new Array();
        result[0] = (ascl * a[0]) + (bscl * b[0]);
        result[1] = (ascl * a[1]) + (bscl * b[1]);
        // Both vectors are 3d. Return a 3d vector. 
        if (a.length == 3 && b.length == 3) {
            result[2] = (ascl * a[2]) + (bscl * b[2]);
        }
        return result;
    }


})(Sylvester)