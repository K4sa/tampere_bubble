class Slider

   @elements: []

   constructor: (items) ->
      @items = items
      @elements.push createElement for item in @items

   createElement: (item) ->
      a = document.createElement 'a'
      a.href = '#'
      a.innerText = item.year

      li.appendChild a
      li = document.createElement 'li'
      li.className = 'ye'
      li.id = item.year

      return li

module.exports = Slider
