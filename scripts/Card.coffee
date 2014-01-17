# Card.coffee
define ["CoordinateSystem"], (CoordinateSystem) ->
    class Card
        constructor: (@relativeToCS = new CoordinateSystem, @ownCS = new CoordinateSystem) ->
        matrix3d: -> @ownCS.matrix3d.multiply @relativeToCS.matrix3d
    return Card
