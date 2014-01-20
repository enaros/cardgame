class @CoordinateSystem
 constructor: ({@parent, @ownMatrix}) ->
 	# todo: I want to have named parameters with default values, how???
 	@parent ?= null
 	@ownMatrix ?= new WebKitCSSMatrix()
 parent: null
 ownMatrix: new WebKitCSSMatrix()
 absoluteMatrix: ->     	
 	if @parent?
 		@parent.absoluteMatrix().multiply @ownMatrix
 	else 
 		@ownMatrix
 do: ({rotate, around, translate}) -> 
 	rotate ?= {}; rotate.x ?= 0; rotate.y ?= 0; rotate.z ?= 0
 	around ?= {}; around.x ?= 0; around.y ?= 0; around.z ?= 0
 	translate ?= {}; translate.x ?= 0; translate.y ?= 0; translate.z ?= 0

 	@ownMatrix = @ownMatrix
 		.translate(around.x, around.y, around.z)
 		.rotate(rotate.x, rotate.y, rotate.z)
 		.translate(-around.x, -around.y, -around.z)
 		.translate(translate.x, translate.y, translate.z)
 	@