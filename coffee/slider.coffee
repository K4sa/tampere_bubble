class Slider

   isPlaying: false

   constructor: (items) ->
      @items = items ? []
      @el = @createElement()
      @$el = $(@el)
      @$input = @$el.find 'input'

      $(@).on 'play:started', =>
         @setPlayControlText '❚❚'
         @isPlaying = true

         # Siirtää slideria eteenpäin
         incrementSlider = =>
            if @$input.val() is @$input.attr('max')
               $(@).trigger 'play:stopped'
               return
            @sendViewChangedEvent @items[~~@$input.val() + 1].name

         @animationId = setInterval(incrementSlider, 2300)

         # Play aloittaa vuodet alusta
         @sendViewChangedEvent @items[0].name

      $(@).on 'play:stopped', =>
         @setPlayControlText '▶'
         @isPlaying = false
         clearInterval @animationId

   createElement: ->
      el = document.createElement 'div'
      el.className = 'year-select-container'
      el.appendChild @createPlayControls()
      el.appendChild @createInputElement()
      return el

   createPlayControls: ->
      controls = document.createElement 'div'
      controls.className = 'play-controls'

      play = document.createElement 'span'
      play.className = 'play-control'
      play.innerText = '▶'

      $(play).on 'click', =>
         if @isPlaying then $(@).trigger 'play:stopped'
         else $(@).trigger 'play:started'

      controls.appendChild play
      return controls

   setPlayControlText: (text) ->
      $('.play-control').html text

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
