window.Slider = class Slider

   constructor: (items) ->
      @items = items ? []
      @el = document.createElement 'ul'
      elements = []
      @el.appendChild @createElement(item) for item in @items

   createElement: (item) ->
      a = document.createElement 'a'
      a.href = '#'
      a.innerText = item.year

      li = document.createElement 'li'
      li.appendChild a
      li.className = 'ye'
      li.id = item.year

      return li
