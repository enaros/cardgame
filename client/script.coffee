table = new Card 
cards = [
    new Card table.ownCS
    new Card table.ownCS
    new Card table.ownCS
]

table.ownCS.matrix3d = table.ownCS.matrix3d.rotate 45, 0, 0

Template.main.rendered = ->
    window.viewport = d3.select ".viewport"
    draw()

# draw function
#-------------------------------------------------------------------
draw = -> 

    d3table = viewport.selectAll(".table").data([table])
    d3table.enter()
        .append("div")
        .attr("class", "table")
        .style("-webkit-transform-origin", "500px 500px")
    d3table.style("-webkit-transform", (d) -> d.matrix3d())
    width= $(".table").width()
    height= $(".table").height()

    console.log cards
    d3cards = viewport.selectAll(".card").data(cards)        
    d3cards.enter()
        .append("div")
        .attr("class", "card")
        .style('left', (d,i) -> (i * 110) + "px")

    d3cards
        .style("-webkit-transform-origin", (d,i) -> 
            position = $(this).position()
            console.log this, position
            (500-110*i)+"px "+ (500-0)+"px "
        )
        .style("-webkit-transform", (d) -> d.matrix3d())

@do1 = -> table.ownCS.matrix3d=new WebKitCSSMatrix() ; draw()
@do2 = -> cards[0].relativeToCS =new CoordinateSystem() ; draw()
@do3 = -> table.ownCS.matrix3d=new WebKitCSSMatrix().rotate 45, 0, 0 ; draw()

# yo.cards[0].relativeToCS.matrix3d=yo.cards[0].relativeToCS.matrix3d.rotate(-75,0,0);yo.draw()