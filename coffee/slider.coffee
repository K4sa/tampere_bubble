class Slider

   constructor: (items) ->
      @items = items ? []
      @el = @createElement()
      @$el = $(@el)
      @$input = @$el.find 'input'

   createElement: ->
      el = document.createElement 'div'
      el.className = 'year-select-container'
      el.appendChild @createInputElement()
      return el

   createInputElement: ->
      input = document.createElement 'input'
      input.className = 'year-select'
      input.type = 'range'
      input.min = 0
      input.max = @items.length - 1

      $(input).on 'input', (e) =>
         @sendViewChangedEvent @items[e.currentTarget.value].name

      $(document).on 'vis:viewChanged', (e, id) =>
         @$input.val @indexOfItem id

      return input

   sendViewChangedEvent: (id) ->
      $(document).trigger 'vis:viewChanged', id
      toggle_view id

   indexOfItem: (year) ->
      return @items.indexOf item for item in @items when item.name is year


# Slider-objektin luominen
slider = new Slider [
   {name:"1980"}
   {name:"1990"}
   {name:"2000"}
   {name:"2013"}
   {name:"2020"}
   {name:"2040"}
]

$('#view_selection').after slider.el
