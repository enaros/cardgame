width = $(window).width();
height = $(window).height();

console.log(width, height)
@camera = new Plane parent: null, width: width, height: height
@table = new Plane parent: @camera, width: width, height: height
camera.translateZ(-1000).do(1000)
camera.rotateX(-40).do(1000)
@table.rotateX(90).do(1000)

#############
# cards
#############

@cards = []

grid = ()-> 
    cardsCount = 40
    columns = 10
    for i in [0 .. cardsCount - 1]
        plane = new Plane parent: @table, width: 100, height: 153, resolution: .75
        plane            
            .translateX( (i % columns * 100) + "%" )
            .translateY( Math.floor(i / columns) * 100 + "%" )
            .delay(10 * i)
            .ease(d3.ease("bounce"))
            .do(100 * i)
        
        @cards.push(plane)

grid()

Template.main.rendered = =>

    window.viewport = d3.select ".viewport"
    render = -> window.webkitRequestAnimationFrame( () -> draw(); render() )
    render()
    #render = -> window.setTimeout( (() -> draw(); render() ),16)

    ############## DEMO #############
    $("#hole #button").on "click", ()->
 # draw function
#-------------------------------------------------------------------
@draw = -> 
    timestamp = +new Date();
    d3table = viewport.selectAll(".table").data([@table])
    d3table.enter()
        .append("div")
        .attr("class", "table")
        .style("width", (d) -> d.width * d.resolution + "px")
        .style("height", (d) -> d.height * d.resolution + "px")
        .on("click", (d) ->
            #table.do({ rotate:{z:180}, around:{x:width/2 , y:height/2} })
        )
    d3table
        .style("-webkit-transform", (d) -> d.absoluteMatrix(timestamp).scale(1/d.resolution))
    

    d3cards = viewport.selectAll(".card").data(@cards)        
    d3cardsEnter = d3cards.enter()
        .append("div")
        .attr("class", "card")
        .style("width", (d) -> d.width * d.resolution + "px")
        .style("height", (d) -> d.height * d.resolution + "px")
    d3cardsEnter
        .append("div")
        .attr("class", "front")
    d3cardsEnter
        .append("div")
        .attr("class", "back")


    d3cards
        .style("-webkit-transform", (d) -> d.absoluteMatrix(timestamp).scale(1/d.resolution))
        .style("z-index", (d) -> 1
            #todo compute distance and set z-index to fix chrome aparently missing z-buffer 
        )

    d3cards.exit()
        .transition()
        .style("opacity", 0)
        .remove()
 
$(document).keydown (e) -> 

    if not e.shiftKey and not e.altKey
        switch e.keyCode
            when 37  
                table.rotateZ(30).do(1000);
            when 38  
                camera.rotateX(30).do(1000);
            when 39  
                table.rotateZ(-30).do(1000);
            when 40  
                camera.rotateX(-30).do(1000);
    if not e.shiftKey and e.altKey
        switch e.keyCode
            when 37  
                camera.rotateZ(180).do(1000);
            when 38  
                camera.rotateX(10).do(1000);
            when 39  
                camera.rotateZ(-180).do(1000);
            when 40  
                camera.rotateX(-10).do(1000);
    if e.shiftKey and not e.altKey
        switch e.keyCode
            when 37  
                camera.translateX(10).do(1000);
            when 38  
                camera.translateZ(10).do(1000);
            when 39  
                camera.translateX(-10).do(1000);
            when 40  
                camera.translateZ(-10).do(1000);
