/*
Copyright (c) 2014 David Buezas.
Based on jquery unmatrix plugin (from Stanislav Sopov https://github.com/stassop/unmatrixk) 
and d3.vector.js (from Jason Davies https://github.com/jasondavies/d3/blob/78ab78e58e37e26deb82cdd2d3a9604baa93ba59/d3.vector.js)
both of which are based on http://dev.w3.org/csswg/css3-transforms/#matrix-decomposing, 
which in term is based on Graphics Gems II, edited by Jim Arvo
*/

+function(){

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

        if (Sylvester.$M(perspectiveMatrix).determinant() == 0) {
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
            inversePerspectiveMatrix = Sylvester.$M(perspectiveMatrix).inverse().elements;
            transposedInversePerspectiveMatrix = Sylvester.$M(inversePerspectiveMatrix).transpose().elements;

            perspective = Sylvester.$M(transposedInversePerspectiveMatrix).multiply(rightHandSide).elements;
            
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
        d.scale.x = Sylvester.$V(row[0]).modulus();
        row[0] = Sylvester.$V(row[0]).toUnitVector().elements;

        // Compute XY shear factor and make 2nd row orthogonal to 1st.
        skew = Sylvester.$V(row[0]).dot(row[1]);
        row[1] = combine(row[1], row[0], 1.0, -skew);

        // Now, compute Y scale and normalize 2nd row.
        d.scale.y = Sylvester.$V(row[1]).modulus();
        row[1] = Sylvester.$V(row[1]).toUnitVector().elements;
        skew /= d.scale.y;
        
        // Compute XZ and YZ shears, orthogonalize 3rd row.
        d.skew.x = Sylvester.$V(row[0]).dot(row[2]);
        row[2] = combine(row[2], row[0], 1.0, -d.skew.x);
        d.skew.y = Sylvester.$V(row[1]).dot(row[2]);
        row[2] = combine(row[2], row[1], 1.0, -d.skew.y);

        // Next, get Z scale and normalize 3rd row.
        d.scale.z = Sylvester.$V(row[2]).modulus();
        row[2] = Sylvester.$V(row[2]).toUnitVector().elements;
        d.skew.x /= d.scale.z;
        d.skew.y /= d.scale.z;
        
        // At this point, the matrix (in rows) is orthonormal. Check for a coordinate system flip. If the 
        // determinant is -1, then negate the matrix and the scaling factors.
        var pdum3 = Sylvester.$V(row[1]).cross(row[2]).elements;
        
        if (Sylvester.$V(row[0]).dot(pdum3) < 0) {
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

}()