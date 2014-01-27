# skybox: http://en.wikibooks.org/wiki/Game_Creation_with_XNA/3D_Development/Skybox
# 
width = 1024
height = 768


@camera = new Plane parent: null
@table = new Plane parent: @camera


@skybox = [
    # (new Plane parent: @camera).do translate:{ x: 0  , y: 0, z:100}, duration: 0
    # (new Plane parent: @camera).do translate:{ x: 0  , y: 0, z:100}, duration: 0
    # (new Plane parent: @camera).do translate:{ x: 0  , y: 0, z:100}, duration: 0
    # (new Plane parent: @camera).do translate:{ x: 0  , y: 0, z:100}, duration: 0
    # (new Plane parent: @camera).do translate:{ x: 0  , y: 0, z:100}, duration: 0
    # (new Plane parent: @camera).do translate:{ x: 0  , y: 0, z:100}, duration: 0
]
#############
#cards*****
##########
#
@cards = []

cilinder = () -> 
    loops = 3
    radius = 200 
    cardsCount = 40#
    for i in [9..cardsCount-1]
        plane = new Plane parent: @table
        plane.do({
            translate:{
                x: 200
                y: 200
                z: Math.floor(loops / cardsCount * i)*200
            }
            rotate: {
                z: loops * 360 / cardsCount * i
            }
            around: {
                x: 200
            }
            # translate: { 
            #     x: Math.sin(+i*loops/cardsCount) * radius
            #     y: Math.cos(+i*loops/cardsCount) * radius
            #     z: +i / loops *20
            # }, 
            duration: 100 *i,
            delay: 10*i,
            ease: d3.ease("cubic-in-out")
        })
        plane.do({
            rotate: {
                x:90
                z:90
            }
        })
        
        @cards.push (plane)
        
# cilinder()

grid = ()-> 
    cardsCount = 40
    columns = 10
    for i in [0..cardsCount-1]
        plane = new Plane parent: @table
        plane.do({
            translate:{
                x: width/2
                y: height/2
                z: 1
            }
            duration: 0,
        })
        plane.do({
            translate:{
                x: 110 * (i % columns ) - width/2
                y: Math.floor(i / columns) * 160 - height/2
            }
            duration: 100 *i,
            delay: 10*i,
            ease: d3.ease("bounce")
        })
        @cards.push (plane)
grid()
#
########
camera.do translate: { z: -800}
Template.main.rendered = =>
    width= $(".viewport").width()
    height= $(".viewport").height()
    @table.do rotate:{ x:45 }, around:{ y:height/2 }

    window.viewport = d3.select ".viewport"
    setInterval (()-> draw()), 16

    ############## DEMO #############
    $("#hole #button").on "click", ()->
        table.do({rotate:{z:180*5}, around:{x:width/2 , y:height/2}, duration: 25000 })
        cardsCount = 40
        columns = 10
        for card, i in cards
            card.transformQueue = []
            card.ownMatrix = new WebKitCSSMatrix()
            card.do({
                translate:{
                    x: width/2
                    y: height/2
                    z: 1
                }
                duration: 0,
            })
            card.do({
                translate:{
                    x: 110 * (i % columns ) - width/2
                    y: Math.floor(i / columns) * 160 - height/2
                }
                duration: 100 *i,
                delay: 10*i,
                ease: d3.ease("bounce")
            })
            ((i, card) -> 
                setTimeout ( () -> 
                    card.parent = null
                    if (i%2)
                        card.do(
                            rotate   : { x:  180 * 3 }
                            around   : { y: 153/2 }
                            duration : 1000
                        )
                ), 8000 - 200 * i
                setTimeout ( () -> card.parent = table), 2000 + 200 * i + 10000 
                setTimeout ( () -> 
                    card.do(
                        translate: { z: 153/2 *(1 -2* (i%2))}
                        duration : 500
                        ease : d3.ease("cubic-in")
                    )
                    card.do(
                        translate:{ z: -153/2 *(1 -2* (i%2))}
                        duration : 1000
                        delay    : 500
                        ease : d3.ease("bounce")
                    )
                    card.do(
                        rotate   : { x:  180 * 1 + (i%2) * 180 }
                        around   : { y: 153/2 }
                        duration : 1000
                    )
                ), 30 * i + 20000
                setTimeout ( () -> 
                    loops = 3
                    radius = 200 
                    cardsCount = 40#
                    card.do(unmatrix(card.ownMatrix.inverse()))
                    card.do({
                        translate:{
                            x: 200
                            y: 200
                            z: Math.floor(loops / cardsCount * i)*200
                        }
                        rotate: {
                            z: loops * 360 / cardsCount * i
                        }
                        around: {
                            x: 200
                        }
                        # translate: { 
                        #     x: Math.sin(+i*loops/cardsCount) * radius
                        #     y: Math.cos(+i*loops/cardsCount) * radius
                        #     z: +i / loops *20
                        # }, 
                        duration: 100 *i,
                        delay: 1000+10*i,
                        ease: d3.ease("cubic-in-out")
                    })
                    card.do({
                        rotate: {
                            x:90
                            z:90
                        }
                    })
                    
                ), 30 * i + 25000
            )(i, card)

    ############# END DEMO ####################
 # draw function
#-------------------------------------------------------------------
@draw = -> 

    d3table = viewport.selectAll(".table").data([@table])
    d3table.enter()
        .append("div")
        .attr("class", "table")
        .on("click", (d) ->
            #table.do({ rotate:{z:180}, around:{x:width/2 , y:height/2} })
        )
    d3table
        .style("-webkit-transform", (d) -> d.absoluteMatrix())
    
    d3skybox = viewport.selectAll(".skybox").data(@skybox)
    d3skybox.enter()
        .append("div")
        .attr("class", (d, i) -> "skybox nth"+i)
        
    d3skybox
        .style("-webkit-transform", (d) -> d.absoluteMatrix())

    d3cards = viewport.selectAll(".card").data(@cards)        
    d3cardsEnter = d3cards.enter()
        .append("div")
        .attr("class", "card")
        .on("click", (d) ->
            d.clicked ?= -1
            d.standing ?= 1
            if d3.event.shiftKey or d3.event.touches?.length == 2
                d.parent = switch d.parent
                    when table then null
                    when null then table
                    when camera then table

            else if d3.event.altKey or d3.event.touches?.length == 3
                d.standing *= -1                
                d.do(
                    rotate   : { x:  90 * d.standing * d.clicked}
                    around   : { y: 0 }
                    duration : 500
                    ease    : d3.ease("bounce")
                    #ease   : (x)-> Math.sin(x*Math.PI*15)
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
                    duration : 1000
                    delay    : 500
                    ease : d3.ease("bounce")
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
        .style("z-index", (d) -> 1
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

        
