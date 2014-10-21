window.Slider = class Slider

   constructor: (items) ->
      @items = items ? []
      @el = document.createElement 'ul'
      @el.appendChild @createElement(item) for item in @items
      @input = @createInputElement()

   createElement: (item) ->
      a = document.createElement 'a'
      a.href = '#'
      a.innerText = item.year

      li = document.createElement 'li'
      li.appendChild a
      li.className = 'ye'
      li.id = item.year

      return li

   createInputElement: ->
      input = document.createElement 'input'
      input.type = 'range'
      input.min = 0
      input.max = @items.length - 1

      $(input).on 'change', =>
         console.log @items[$(input).val()]

      return input
