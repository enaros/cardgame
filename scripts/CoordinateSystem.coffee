define [], ->
    class CoordinateSystem
        constructor: ->
        matrix3d: new WebKitCSSMatrix()
        webkitTransformOrigin: null
    return CoordinateSystem