width = $(window).width();
height = $(window).height();

console.log(width, height)
@camera = new Plane parent: null, width: width, height: height
@table = new Plane parent: @camera, width: width, height: height
camera.translate("50%")
camera.rotateX(40).aroundY('50%').translateZ(-200).do()
@table.rotateX(90).aroundY('50%').do()

#############
# cards
#############

@cards = []

grid = ()-> 
    cardsCount = 80
    columns = 15
    for i in [0 .. cardsCount - 1]
        plane = new Plane parent: @table, width: 100, height: 153, resolution: .75
        plane            
            .translateX( (i % columns * 100) + "%" )
            .translateY( Math.floor(i / columns) * 100 + "%" )
            .duration(100 * i)
            .delay(10 * i)
            .ease(d3.ease("bounce"))
            .do()
        
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
        .style("-webkit-transform", (d) -> d.absoluteMatrix().scale(1/d.resolution))
    

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
        .style("-webkit-transform", (d) -> d.absoluteMatrix().scale(1/d.resolution))
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
                camera.rotateY(10).aroundXY('50%').do(1000);
            when 38  
                camera.rotateX(10).aroundXY('50%').do(1000);
            when 39  
                camera.rotateY(-10).aroundXY('50%').do(1000);
            when 40  
                camera.rotateX(-10).aroundXY('50%').do(1000);
    if not e.shiftKey and e.altKey
        switch e.keyCode
            when 37  
                camera.rotateZ(180).aroundXY('50%').do(1000);
            when 38  
                camera.rotateX(10).aroundXY('50%').do(1000);
            when 39  
                camera.rotateZ(-180).aroundXY('50%').do(1000);
            when 40  
                camera.rotateX(-10).aroundXY('50%').do(1000);
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

        
