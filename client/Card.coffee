class @Card
    constructor: (@relativeToCS = new CoordinateSystem, @ownCS = new CoordinateSystem) ->
    matrix3d: -> @ownCS.matrix3d.multiply @relativeToCS.matrix3d

console.log 'test'