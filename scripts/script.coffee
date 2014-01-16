define ["moment", "d3", "jquery-private", "Card", "CoordinateSystem"], (moment, d3, $, Card, CoordinateSystem) ->
    table = new Card 
    cards = [
        new Card table.ownCS
        new Card table.ownCS
        new Card table.ownCS
    ]
    
    table.ownCS.matrix3d = table.ownCS.matrix3d.rotate 45, 0, 0

    viewport = d3.select ".viewport"


    

    draw = -> 

        d3table = viewport.selectAll(".table").data([table])
        d3table.enter()
            .append("div")
            .attr("class", "table")
            .style("-webkit-transform-origin", "500px 500px")
        d3table.style("-webkit-transform", (d) -> d.matrix3d())
        width= $(".table").width()
        height= $(".table").height()

        d3cards = viewport.selectAll(".card").data(cards)        
        d3cards.enter()
            .append("div")
            .attr("class", "card")
            .style('left', (d,i) -> (i * 110) + "px")
            # .style('left', (d,i) -> (i * 110) + "px")
            
        d3cards
            .style("-webkit-transform-origin", (d,1) -> 
                position = $(this).position()
                console.log this, position
                (500-110*i)+"px "+ (500-0)+"px "
            )
            .style("-webkit-transform", (d) -> d.matrix3d())

    
    window.yo = {
        table
        cards
        draw
        CoordinateSystem
        do1 : -> yo.table.ownCS.matrix3d=new WebKitCSSMatrix() ; draw()
        do2 : -> yo.cards[0].relativeToCS =new CoordinateSystem() ; draw()
        do3 : -> yo.table.ownCS.matrix3d=new WebKitCSSMatrix().rotate 45, 0, 0 ; draw()
    }

    window.$ = $
    draw()
    # yo.cards[0].relativeToCS.matrix3d=yo.cards[0].relativeToCS.matrix3d.rotate(-75,0,0);yo.draw()