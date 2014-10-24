class Slider

   constructor: (items) ->
      @items = items ? []
      @input = @createInputElement()

   createInputElement: ->
      input = document.createElement 'input'
      input.type = 'range'
      input.min = 0
      input.max = @items.length - 1

      $(input).on 'input', =>
         @sendViewChangedEvent @items[$(@input).val()].name

      return input

   sendViewChangedEvent: (id) ->
      $(document).trigger 'vis:viewChanged', id
      toggle_view id


# Slider-objektin luominen
slider = new Slider [
   {name:"1980"}
   {name:"1990"}
   {name:"2000"}
   {name:"2013"}
   {name:"2020"}
   {name:"2040"}
]

$('#view_selection').after slider.input
