width = 0
height = 0


@camera = new Plane parent: null
@table = new Plane parent: @camera
@cards = [
    (new Plane parent: @table).do translate:{ x: 0  , y: 20, z:1}, duration: 0
    (new Plane parent: @table).do translate:{ x: 150, y: 20, z:1}, duration: 0
    (new Plane parent: @table).do translate:{ x: 300, y: 20, z:1}, duration: 0
]

camera.do translate: { z: -800}
Template.main.rendered = =>
    width= $(".viewport").width()
    height= $(".viewport").height()
    @table.do rotate:{ x:45 }, around:{ y:height/2 }

    window.viewport = d3.select ".viewport"
    setInterval (()-> draw()), 16


 # draw function
#-------------------------------------------------------------------
@draw = -> 

    d3table = viewport.selectAll(".table").data([@table])
    d3table.enter()
        .append("div")
        .attr("class", "table")
    d3table
        .style("-webkit-transform", (d) -> d.absoluteMatrix())

    d3cards = viewport.selectAll(".card").data(@cards)        
    d3cardsEnter = d3cards.enter()
        .append("div")
        .attr("class", "card")
        .on("mousedown", (d) ->
            d.clicked ?= -1
            d.standing ?= 1

            if d3.event.shiftKey
                d.parent = switch d.parent
                    when table then null
                    when null then table
                    # when camera then table

            else if d3.event.altKey
                d.standing *= -1                
                d.do(
                    rotate   : { x:  90 * d.standing * d.clicked}
                    around   : { y: 0 }
                    duration : 1000
                )
            else
                d.clicked *= -1
                d.do(
                    translate: { z: 153/2 *d.clicked }
                    duration : 500
                    ease : d3.ease("cubic-in")
                )
                .do(
                    translate:{ z: -153/2 * d.clicked }
                    duration : 500
                    delay    : 500
                    ease : d3.ease("cubic-out")
                )
                d.do(
                    rotate   : { x:  180 }
                    around   : { y: 153/2 }
                    duration : 1000
                )
        );
    d3cardsEnter
        .append("div")
        .attr("class", "front")
    d3cardsEnter
        .append("div")
        .attr("class", "back")


    d3cards
        .style("-webkit-transform", (d) -> d.absoluteMatrix())
        .style("z-index", (d) -> 
            #todo compute distance and set z-index to fix chrome aparently missing z-buffer 
        )

    d3cards.exit()
        .style("opacity", 0)
        .remove()

$(document).keydown (e) -> 

    if not e.shiftKey and not e.altKey
        switch e.keyCode
            when 37  
                table.do({rotate:{z:180}, around:{x:width/2 , y:height/2} })
            when 38  
                table.do({rotate:{x:10}, around:{x:width/2 , y:height/2} })
            when 39  
                table.do({rotate:{z:-180}, around:{x:width/2 , y:height/2} })
            when 40  
                table.do({rotate:{x:-10}, around:{x:width/2 , y:height/2} })
    if not e.shiftKey and e.altKey
        switch e.keyCode
            when 37  
                camera.do({rotate:{z:180}, around:{x:width/2 , y:height/2} })
            when 38  
                camera.do({rotate:{x:10}, around:{x:width/2 , y:height/2} })
            when 39  
                camera.do({rotate:{z:-180}, around:{x:width/2 , y:height/2} })
            when 40  
                camera.do({rotate:{x:-10}, around:{x:width/2 , y:height/2} })
    if e.shiftKey and not e.altKey
        switch e.keyCode
            when 37  
                camera.do translate:{x:10}
            when 38  
                camera.do translate:{z:10}
            when 39  
                camera.do translate:{x:-10}
            when 40  
                camera.do translate:{z:-10}
