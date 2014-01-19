width = 0
height = 0


@camera = new CoordinateSystem parent: null
@table = new CoordinateSystem parent: @camera
@cards = [
    (new CoordinateSystem parent: @table).do translate:{ x: 0  , y: 20}
    (new CoordinateSystem parent: @table).do translate:{ x: 150, y: 20}
    (new CoordinateSystem parent: @table).do translate:{ x: 300, y:20}
]

camera.do translate: { z: -800}
Template.main.rendered = =>
    width= $(".viewport").width()
    height= $(".viewport").height()
    @table.do rotate:{ x:45 }, around:{ y:height/2 }

    window.viewport = d3.select ".viewport"
    draw()
    @changePlayer()


 # draw function
#-------------------------------------------------------------------
@draw = -> 

    d3table = viewport.selectAll(".table").data([@table])
    d3table.enter()
        .append("div")
        .attr("class", "table")
    d3table
        # .transition()
        # .duration(1000)
        .style("-webkit-transform", (d) -> d.absoluteMatrix())

    d3cards = viewport.selectAll(".card").data(@cards)        
    d3cardsEnter = d3cards.enter()
        .append("div")
        .attr("class", "card")
        .on("mousedown", (d) ->
            if d3.event.shiftKey
                d.showing = !d.showing
                d.parent = if d.showing then table else new CoordinateSystem parent: null 
            else
                d.clicked = !d.clicked
                d.do rotate:{ x:  (if d.clicked then 90 else -90 ) }
            draw()
        );
    d3cardsEnter
        .append("div")
        .attr("class", "front")
    d3cardsEnter
        .append("div")
        .attr("class", "back")


    d3cards
        # .transition()
        # .duration(1000)
        .style("-webkit-transform", (d) -> d.absoluteMatrix())

    d3cards.exit()
        # .transition()
        # .duration(1000)
        .style("opacity", 0)
        .remove()

$(document).keydown (e) -> 
    if !e.shiftKey
        switch e.keyCode
            when 37  
                table.do({rotate:{z:10}, around:{x:width/2 , y:height/2} })
            when 38  
                table.do({rotate:{x:10}, around:{x:width/2 , y:height/2} })
            when 39  
                table.do({rotate:{z:-10}, around:{x:width/2 , y:height/2} })
            when 40  
                table.do({rotate:{x:-10}, around:{x:width/2 , y:height/2} })
    else
        switch e.keyCode
            when 37  
                camera.do translate:{x:10}
            when 38  
                camera.do translate:{z:10}
            when 39  
                camera.do translate:{x:-10}
            when 40  
                camera.do translate:{z:-10}
    draw()
    e.preventDefault()



showCardActive = no
@showCard = -> 
    cards[0].parent = if showCardActive then table else new CoordinateSystem parent: null 
    draw()
    showCardActive = not showCardActive

player = 0
@changePlayer1 = -> 
    player = (player+1) % 2
    table.do({rotate:{z:179.999}, around:{x:width/2 , y:height/2} })
    draw()

@changePlayer = -> 
    # todo: think how to use d3 to interpolate transformations in a sound way
    player = (player+1) % 2
    steps = 50;
    i=0
    while i++ < steps
        setTimeout ->
                table.do({rotate:{z:180/steps}, around:{x:width/2 , y:height/2} })
                draw()
            , 16*i
# yo.@cards[0].parent.matrix3d=yo.@cards[0].parent.matrix3d.rotate(-75,0,0);yo.draw()