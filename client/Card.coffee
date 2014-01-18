class @Card
    constructor: (@relativeToCS = new CoordinateSystem, @ownCS = new CoordinateSystem) ->
    matrix3d: -> @relativeToCS.matrix3d.multiply @ownCS.matrix3d

console.log 'test'