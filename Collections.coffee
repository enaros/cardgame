return
@CardsCollection = new Meteor.Collection("cards");

if (Meteor.isClient)
    @addCard = (name) -> CardsCollection.insert name: name
    @emptyCards = -> 
        CardsCollection.find().forEach (card) ->
            CardsCollection.remove card._id
    @showCards = -> CardsCollection.find().forEach (card) -> console.log card
    @fetchCards = -> CardsCollection.find().fetch()

    Meteor.autorun ->
        window.cards = []
        fetchCards().forEach (c) ->
            @cards.push new Card table.ownCS
            console.log 'tete'
        draw()