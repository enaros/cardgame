/*
Copyright (c) 2014 David Buezas. Based on http://dev.w3.org/csswg/css3-transforms/#matrix-decomposing
 and work from Stanislav Sopov (jquery unmatrix) and Jason Davies (d3 vector module)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or 
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT 
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
(function(S){

  d3.vector = {};

    
    // Returns an object with transform properties.
    function getTransform(cssTransform) {
        // Check if transform is 3d.
        var is3d = Boolean(cssTransform.match(/matrix3d/));

        // Convert matrix values to array.
        cssTransform = cssTransform.match(/\(([\d\.\,\s-]+)\)/)[1];
        var values = cssTransform.split(",");

        // Convert values to floats. 
        for (var i = 0, l = values.length; i < l; i++) {
            values[i] = parseFloat(values[i]).toFixed(2);
        }

        // Matrix columns become arrays.
        // Create 4x4 3d matrix.
        var matrix = is3d ? [
            [values[0], values[1], values[2], values[3]],
            [values[4], values[5], values[6], values[7]],
            [values[8], values[9], values[10], values[11]],
            [values[12], values[13], values[14], values[15]]]
        // Create 4x4 2d matrix.
        : [
            [values[0], values[1], 0, 0],
            [values[2], values[3], 0, 0],
            [0, 0, 1, 0],
            [values[4], values[5], 0, 1]];

        return unmatrix(matrix);
    }

    // Returns null if the matrix cannot be decomposed, an object if it can.
    function unmatrix(matrix) {
        var rotateX;
        var rotateY;
        var rotateZ; 
        var scaleX;
        var scaleY;
        var scaleZ;
        var skew;
        var skewX;
        var skewY;
        var x; 
        var y;
        var z;

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
        x = matrix[3][0];
        //matrix[3][0] = 0;
        y = matrix[3][1];
        //matrix[3][1] = 0;
        z = matrix[3][2];
        //matrix[3][2] = 0;

        // Now get scale and shear. 'row' is a 3 element array of 3 component vectors.
        var row = [[],[],[]];

        for (var i = 0; i < 3; i++) {
            row[i][0] = matrix[i][0];
            row[i][1] = matrix[i][1];
            row[i][2] = matrix[i][2];
        }

        // Compute X scale factor and normalize first row.
        scaleX = length(row[0]);
        row[0] = normalize(row[0]);

        // Compute XY shear factor and make 2nd row orthogonal to 1st.
        skew = dot(row[0], row[1]);
        row[1] = combine(row[1], row[0], 1.0, -skew);

        // Now, compute Y scale and normalize 2nd row.
        scaleY = length(row[1]);
        row[1] = normalize(row[1]);
        skew /= scaleY;
        
        // Compute XZ and YZ shears, orthogonalize 3rd row.
        skewX = dot(row[0], row[2]);
        row[2] = combine(row[2], row[0], 1.0, -skewX);
        skewY = dot(row[1], row[2]);
        row[2] = combine(row[2], row[1], 1.0, -skewY);

        // Next, get Z scale and normalize 3rd row.
        scaleZ = length(row[2]);
        row[2] = normalize(row[2]);
        skewX /= scaleZ;
        skewY /= scaleZ;
        
        // At this point, the matrix (in rows) is orthonormal. Check for a coordinate system flip. If the 
        // determinant is -1, then negate the matrix and the scaling factors.
        var pdum3 = cross(row[1], row[2]);
        
        if (dot(row[0], pdum3) < 0) {
            for (var i = 0; i < 3; i++) {
                scaleX *= -1;
                row[i][0] *= -1;
                row[i][1] *= -1;
                row[i][2] *= -1;
            }
        }

        // Get the rotations.
        rotateY = Math.asin(-row[0][2]);
        if (Math.cos(rotateY) != 0) {
            rotateX = Math.atan2(row[1][2], row[2][2]);
            rotateZ = Math.atan2(row[0][1], row[0][0]);
        } else {
            rotateX = Math.atan2(-row[2][0], row[1][1]);
            rotateZ = 0;
        }
        
        return {
            rotate: [rotateX, rotateY, rotateZ], 
            scale: [scaleX, scaleY, scaleZ],
            skew: [skewX, skewY],
            translate: [x, y, z]
        };
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


d3.vector.interpolate = function(a, b) {
  if (!String(a).match(/^matrix/) || !String(b).match(/^matrix/)) return null;
  a = getTransform(a);
  b = getTransform(b);
  var translate = d3.interpolateArray(a.translate, b.translate),
      rotate = d3.interpolateArray(a.rotate, b.rotate),
      skew = d3.interpolateArray(a.skew, b.skew),
      scale = d3.interpolateArray(a.scale, b.scale);
  return culo=function(t) {
    var r = rotate(t);
    return (
      "translate3d(" + translate(t).join("px,") + "px)" +
      "skew(" + skew(t).join("rad,") + "rad)" +
      "rotateZ(" + r[2].toFixed(20) + "rad)" +
      "rotateY(" + r[1].toFixed(20) + "rad)" +
      "rotateX(" + r[0].toFixed(20) + "rad)" +
      "scale3d(" + scale(t) + ")");
  };
}

d3.interpolators.push(d3.vector.interpolate);

})(Sylvester)