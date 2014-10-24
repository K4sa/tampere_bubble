
class BubbleChart
  constructor: (data) ->
  #Visualisaation korkeus
    @data = data
    @width = 1200
    @height = 1800 

	#Määrittää halutun datatyypin(vuoden)
    @data_type = 1

    @tooltip = CustomTooltip("gates_tooltip", 240)

	#Koordinaatit, joihin kappaleet tai tekstit hakeutuvat
    @center = {x: @width / 2, y: @height / 2}
    @main_height = 380
    @location_centers = {
      "Luoteinen": {x: 420, y: 300},
      "Pohjoinen": {x: @width / 2, y: 300},
      "Koillinen": {x: @width - 420, y: 300},
      "Keskinen": {x: @width / 2, y: 400},
      "Lounainen": {x: 420, y: 460},
      "Eteläinen": {x: @width / 2, y: 480},
      "Kaakkoinen": {x: @width - 420, y: 460}
    }
    @location_text = {
      "Luoteinen": {x: 140, y: 80},
      "Pohjoinen": {x: @width / 2, y: 20},
      "Koillinen": {x: @width - 140, y: 80},
      "Lounainen": {x: 140, y: 660},
      "Eteläinen": {x: @width / 2, y: 720},
      "Kaakkoinen": {x: @width - 140, y: 660}	  
    }
    @tre_text = { 
      "1980: 170 000 asukasta": {x: 330, y: 60},
      "1990: 180 000 asukasta": {x: 240, y: 165},
      "2000: 190 000 asukasta": {x: 200, y: 270},
      "2013: 210 000 asukasta": {x: 200, y: 375},
      "2020: 210 000 asukasta": {x: 220, y: 480},
      "2040: 210 000 asukasta": {x: 280, y: 585},
      "TARKASTELE Tampereen väkiluvun jakaantumista": {x: 960, y: 60}, 
      "ja sen kehitystä vuosittain kaaviossa,": {x: 940, y: 80},
      "jossa jokainen kuplaa vastaa eri asuinaluetta.": {x: 990, y: 100},
      "VERTAILE kuplien kokoa,": {x: 990, y: 190},
      "joka määrittyy alueen väkiluvun": {x: 1030, y: 210},
      "suhteesta Tampereen väkilukuun.": {x: 1050, y: 230},
      "JÄRJESTÄ kuplat joko suuralueiden,": {x: 1070, y: 320},
      "sijainnin tai suuruuden mukaan.": {x: 1055, y: 340},
      "PAINA kuplaa saadaksesi": {x: 1010, y: 430},
      "sen alueesta tarkempaa tietoa.": {x: 1010, y: 450},
      "ENNUSTA Tampereen väkiluvun kehitystä": {x: 1025, y: 540},
      "vuosien 2020 ja 2040 ennusteilla,": {x: 975, y: 560},
      "jotka on laadittu aikaisempien vuosien perusteella": {x: 1005, y: 580}  
    }

    #Kartan koordinaatit
    @location_map = {
      1: {x: 600, y: 460}, 2: {x: 700, y: 420}, 3: {x: 680, y: 520}, 
      4: {x: 740, y: 460}, 5: {x: 780, y: 420}, 6: {x: 800, y: 470},
      7: {x: 740, y: 540}, 8: {x: 780, y: 580}, 9: {x: 600, y: 580},
      10: {x: 680, y: 560}, 11: {x: 670, y: 600}, 12: {x: 480, y: 460},
      13: {x: 400, y: 520}, 14: {x: 300, y: 480}, 15: {x: 380, y: 420},
      16: {x: 400, y: 350}, 17: {x: 780, y: 300}, 18: {x: 760, y: 280},
      19: {x: 760, y: 260} }
    # Gravitaaiossa käytettyjä arvoja
    @layout_gravity = -0.01
    @layout_gravity_groups = -0.01
    @damper = 0.1

    @vis = null
    @nodes = []
    @force = null  
    @circles = null

    #Skaalataan ja väritetään suuralueen mukaan
    @fill_color = d3.scale.ordinal()
      .domain(["low", "medium", "high"])
      .range(["#1d8281", "#44bf87", "#fbd258", "#f29a3f", "#db634f", "#124f4e", "#db4930" ])

    # use the max total_amount in the data as the max in the scale's domain


    this.set_range(@data_type)
    this.create_nodes(@data_type)
    this.create_vis()

	#Luodaan kuplien alkiot
  create_nodes: (data_type) =>
    @nodes = []
    @data.forEach (d) =>
      node = {
        id: d.id
        radius: @radius_scale(parseInt(d.total_amount))
        value: d.total_amount
        people: d.total_amount
        people_80: d.total_80
        people_90: d.total_90
        people_00: d.total_00
        people_20: d.total_20
        people_40: d.total_40
        jobs: d.jobs_amount
        students: d.students_amount
        old: d.old_amount
        name: d.location_name
        postal: d.postal_code
        group: d.group_name
        area: d.area
        x: Math.random() * 900
        y: Math.random() * 800
      }
      @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value

	#Päivitetään alkiot vaihtamalla uusi value ja lasketaan uusi säde
  update_all_nodes: (data_type) =>
    if (data_type == 1)
       @nodes.forEach (d) =>
          d.value = d.people
          d.radius = @radius_scale(parseInt(d.value))
    else if (data_type == 3)
       @nodes.forEach (d) =>
          d.value = d.students
          d.radius = @radius_scale(parseInt(d.value))
    else if (data_type == 4)
       @nodes.forEach (d) =>
          d.value = d.old
          d.radius = @radius_scale(parseInt(d.value))
    else if (data_type == 5)
       @nodes.forEach (d) =>
          d.value = d.people_80
          d.radius = @radius_scale(parseInt(d.value))
    else if (data_type == 6)
       @nodes.forEach (d) =>
          d.value = d.people_90
          d.radius = @radius_scale(parseInt(d.value))
    else if (data_type == 7)
       @nodes.forEach (d) =>
          d.value = d.people_00
          d.radius = @radius_scale(parseInt(d.value))
    else if (data_type == 8)
       @nodes.forEach (d) =>
          d.value = d.people_20
          d.radius = @radius_scale(parseInt(d.value))
    else if (data_type == 9)
       @nodes.forEach (d) =>
          d.value = d.people_40
          d.radius = @radius_scale(parseInt(d.value))
    else
       @nodes.forEach (d) =>
          d.value = d.jobs
          d.radius = @radius_scale(parseInt(d.value))
    @nodes.sort (a,b) -> b.value - a.value


    #Määritetään asteikon min ja max. Nyt käytössä kiinteä max, pois kommentoituna skaalautuva max
  set_range: (data_type) =>
    # if (data_type == 1)
       # max_new = d3.max(@data, (d) -> parseInt(d.total_amount))
    # else if (data_type == 3)
       # max_new = d3.max(@data, (d) -> parseInt(d.students_amount))
    # else if (data_type == 4)
       # max_new = d3.max(@data, (d) -> parseInt(d.old_amount))
    # else if (data_type == 5)
       # max_new = d3.max(@data, (d) -> parseInt(d.total_80))
    # else if (data_type == 6)
       # max_new = d3.max(@data, (d) -> parseInt(d.total_90))
    # else if (data_type == 7)
       # max_new = d3.max(@data, (d) -> parseInt(d.total_00))
    # else
       # max_new = d3.max(@data, (d) -> parseInt(d.jobs_amount))
    max_new = 25000
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, max_new]).range([2, 85])

  # Luodaan visualisaatio atribuutteineen
  create_vis: () =>
    @vis = d3.select("#vis").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("id", "svg_vis")

    #Luodaan alkioista kuplia
    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    that = this

	#Piirretään kuplat initiaalisessa säteellä 0 ja määritetään toiminnot
    @circles.enter().append("circle")
      .attr("r", 0)
      .attr("fill", (d) => @fill_color(d.group))
      .attr("stroke-width", 5)
      .attr("id", (d) -> "bubble_#{d.id}")
      .on "mouseover", (d,i) -> 
         that.show_details(d,i,this)
         that.circles
            .filter( (circle) => circle.id != d.id)
            .transition().duration(500)
            .style('opacity', 0.3)
      .on "mouseout", (d,i) ->
         that.hide_details(d,i,this)
         that.circles
            .transition().duration(500)
            .style('opacity', 1)
      .on "click", (d,i) ->
         mymodal = $('#population_modal')
         element = this
         mymodal.on 'hide.bs.modal', () ->
            that.hid_modal()
         that.display_modal(d,i,element)
         that.get_wiki_info(d.name)
         $(element).data('center', true)
         mymodal.modal 'show'
 
    #Animoidaan kuplan säteen muutos 0 -> radius
    @circles.transition().duration(2000).attr("r", (d) -> d.radius)

	#Päivitetään visualisaatio kun jotkin arvot muuttuneet
  update_vis: () =>
    @circles = null 
  
    @circles = @vis.selectAll("circle")
       .data(@nodes, (d) -> d.id)
    @circles.transition().duration(3000).attr('r', (d) -> d.radius)
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
    @force.start()

	#Voima joka määrittää kuplien hylkimisen (ei päällekäisiä kuplia)
  charge: (d) ->
    -Math.pow(d.radius, 2.0) / 7

  #Aloittaa voimat
  start: () =>
    @force = d3.layout.force()
      .nodes(@nodes)
      .size([@width, @height])

  #Näyttää kaikki keskellä
  display_group_all: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_center(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

	#Piiloitetaan tekstit näkyvillä ja näytetään uusi teksti
    this.hide_location()
    this.display_tre()

  #Liikutetaan kuplat uutta painovoimapistettä kohden. Painovoima-arvot määrittävät liikkeen sulavuuden
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (@main_height - d.y) * (@damper + 0.02) * alpha

	#Näytetään suuralueittain
  display_by_group: () =>
    @force.gravity(@layout_gravity_groups)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_group(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()
    this.hide_location()
    this.display_locations()

  #Kohti useaa pistettä 
  move_towards_group: (alpha) =>
    (d) =>
      target = @location_centers[d.group]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

	  #Näytetään lokaatiotekstit
  display_locations: () =>
    location = @location_text
    location_data = d3.keys(location)
    loc = @vis.selectAll(".groups")
      .data(location_data)

    loc.enter().append("text")
      .attr("class", "groups")
      .attr("x", (d) => location[d].x )
      .attr("y", (d) => location[d].y )
      .attr("text-anchor", "middle")
      .text((d) -> d)

	  #Piiloitetaan tekstit
  hide_location: () =>
    loc = @vis.selectAll(".groups").remove()
    tre = @vis.selectAll(".tredata").remove()

	#näytetään aloitussivun tekstit
  display_tre: () =>
    tre_size = @tre_text
    tre_data = d3.keys(tre_size)
    tre = @vis.selectAll(".tredata")
       .data(tre_data)

    tre.enter().append("text")
       .attr("class", "tredata")
       .attr("x", (d) => tre_size[d].x)
       .attr("y", (d) => tre_size[d].y)
       .attr("text-anchor", "middle")
       .text((d) -> d)

	   #Näytetään järjestyksessä
  display_by_order: () =>
    @force.gravity(@layout_gravity_groups)
      #.charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        next_y = 240
        next_x = 150
        number = 1
        @circles.each(this.move_towards_order(e.alpha, next_x, next_y, number))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

    this.hide_location()
 
	#LAsketaan painovoimapisteet ja siirretään kohti niitä (tiedot valmiiksi järjestyksessä). Kaunis if-lause
  move_towards_order: (alpha, next_x, next_y, number) =>
    (d) =>
       if (number == 9 || number == 17 || number == 25 || number == 33 || number == 41 || number == 49 || number == 57 || number == 65 || number == 73 || number == 81 || number == 89 || number == 97 || number == 105)  
          next_x = 250
          next_y = next_y + 100
          d.x = d.x + (next_x - d.x) * (@damper + 0.02) * alpha * 1.1
          d.y = d.y + (next_y - d.y) * (@damper + 0.02) * alpha * 1.1
       else
          next_x = next_x + 100
          d.x = d.x + (next_x - d.x) * (@damper + 0.02) * alpha * 1.1
          d.y = d.y + (next_y - d.y) * (@damper + 0.02) * alpha * 1.1
       ++number   

	   #Näytetään kartalla
  display_by_area: () =>
    @force.gravity(@layout_gravity_groups)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_area(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()
    this.hide_location()
 
 #Siirretään kohti 19 karttapistettä
  move_towards_area: (alpha) =>
    (d) =>
      target = @location_map[d.area]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1
 
 #Näytetään tooltipin infot
  show_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) => d3.rgb(@fill_color(d.group)).darker())
    content = "<span class=\"title\"> #{data.name}</span><br/>"
    content +="<span class=\"name\"> #{data.value}</span><span class=\"name\"> asukasta</span><br/>"
    @tooltip.showTooltip(content,d3.event)

	#Piiloitetaan tooltipin info
  hide_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) => d3.rgb(@fill_color(d.group)))
    @tooltip.hideTooltip()

 get_wiki_info: (name) =>
    modal = $('#population_modal')
    if (name == "Tammela" || name == "Kaleva" || name == "Petsamo" || name == "Rahola" || name == "Leinola" || name == "Koivistonkylä" || name == "Viiala" || name == "Uusikylä" || name == "Niemi" || name == "Tulli")
       name = name + " (Tampere)"
    else if (name == "Lappi" || name == "Turtola" || name == "Kumpula" || name == "Polso" || name == "Myllypuro")
       name = name + " (Tampere)"
    else if (name == "Tampella")
       name = name + "n alue"
    else if (name == "Tammerkoski" || name == "Finlayson")
       name = name + " (kaupunginosa)"
    else if (name == "Tesomajärvi")
       name = "Tesoma"
    else if (name == "Pappila" || name == "Ristimäki" || name == "Nurmi" || name == "Rusko" || name == "Ojala") 
       modal.find('#wiki').append("<div id='wiki-field'>" + 'Asuinalueesta ei ole tietoja' + "</div>")
       return
    else
      name = name

    wiki_url = 'http://fi.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&exsentences=15&exlimit=10&exintro=&titles=' + name + '&callback=?'
    $.getJSON wiki_url, (wiki_data) ->
       console.log(wiki_data.query.pages[Object.keys(wiki_data.query.pages)[0]].extract);
       wiki_text = wiki_data.query.pages[Object.keys(wiki_data.query.pages)[0]].extract
       if (typeof wiki_text == "undefined")
          modal.find('#wiki').append("<div id='wiki-field'>" + 'Asuinalueesta ei ole tietoja' + "</div>")
          return
       modal.find('#wiki').append("<div id='wiki-field'>" + wiki_text + "</div>")

	#Poistetaan modaalin visualisaatio kun modaali suljetaan
  hid_modal: () =>
     re_chart = $('#population_modal').find(".bar_chart")
     re_chart.remove()
     re_wiki = $('#population_modal').find("#wiki-field")
     re_wiki.remove()

	 #Näytetään modaali ja luodaan sille sisältö
  display_modal: (data, i, element) =>
    modal = $('#population_modal')
    modal.find('#place_name').text(data.name)
	
	#Luodaan modaalin visualisaatiolla (bar chart) tiedot
    bar_data = [data.people_80, data.people_90, data.people_00, data.people, data.people_20, data.people_40]
    year_names = ["1980", "1990", "2000", "2013", "2020", "2040"]
    
    color = @fill_color(data.group)

	#Määritetään koko ja lasketaan maksimi (kertaa 1.1, jotta palkkien yläreunaan jää tilaa)
    w_bar = 95;
    h_bar = 300;
    domain_hi = d3.max(bar_data, (d) -> parseInt(d)) * 1.1
    console.log(bar_data)
    console.log(domain_hi)

    #x-arvon jakaminen niin, että se kattaa koko x-akselin
    bar_max_x = d3.scale.linear()
       .domain([0, 1])
       .range([0, w_bar])

    #datan skaala y-akselille
    bar_max_y = d3.scale.linear()
       .domain([-1, domain_hi])
       .rangeRound([0, h_bar])

     #Luodaan visualisaatio
    bar_chart = d3.select('#year_2040')
       .append("svg:svg")
          .attr("class", "bar_chart")
          .attr("width", w_bar * bar_data.length - 1)
          .attr("height", h_bar)

     #Luodaan palkit arvoineen, animoidaan arvosta y = 300 -> y.data
    bar_chart.selectAll("rect")
          .data(bar_data)
       .enter().append("svg:rect")
          .attr("fill", color)
          .attr "x", (d,i) -> 
             bar_max_x(i) - 0.5
          .attr("y", 300)
          .attr("width", w_bar)
          .attr "height", (d) ->
             bar_max_y(d)
          .transition().duration(1500).attr "y", (d) -> 
                                        h_bar - bar_max_y(d) - 0.5

     #Luodaan palkkien päälle tekstit ja animoidaan arvosta -10
    bar_chart.selectAll("text")
         .data(bar_data)
      .enter().append("svg:text")
         .attr "x", (d,i) ->
            bar_max_x(i) + 65
         .attr("y", -10)
         .attr("dx", -3)
         .attr("dy", ".35em")
         .attr("text-anchor", "end")
         .text(String)
      .transition().duration(1500).attr "y", (d) -> 
                                        h_bar - bar_max_y(d) - 6




root = exports ? this

#Päivitetään visuaalisaatiota kutsumalla funktioita 
$ ->
  chart = null 

  render_vis = (csv) ->
    chart = new BubbleChart csv, 1
    chart.start()
    root.display_all()
  root.display_all = () =>
    chart.display_group_all()
  root.display_group = () =>
    chart.display_by_group()
  root.display_order = () =>
    chart.display_by_order()
  root.display_area = () =>
    chart.display_by_area()
  root.toggle_view = (view_type) =>
    if view_type == 'group'
      root.display_group()
    else if view_type == 'order'
      root.display_order()
    else if view_type == 'areas'
      root.display_area()
    else if view_type == '2013'
      chart.set_range(1)
      chart.update_all_nodes(1)
      chart.update_vis()
      #chart.start()
      #root.display_all()
    else if view_type == '1980'
      chart.set_range(5)
      chart.update_all_nodes(5)
      chart.update_vis()
      #chart.start()
      #root.display_all()
    else if view_type == '1990'
      chart.set_range(6)
      chart.update_all_nodes(6)
      chart.update_vis()
      #chart.start()
      #root.display_all()
    else if view_type == '2000'
      chart.set_range(7)
      chart.update_all_nodes(7)
      chart.update_vis()
      #chart.start()
      #root.display_all()
    else if view_type == '2020'
      chart.set_range(8)
      chart.update_all_nodes(8)
      chart.update_vis()
      #chart.start()
      #root.display_all()
    else if view_type == '2040'
      chart.set_range(9)
      chart.update_all_nodes(9)
      chart.update_vis()
      #chart.start()
      #root.display_all()
    else if view_type == 'jobs'
      chart.set_range(2)
      chart.update_all_nodes(2)
      chart.update_vis()
      #chart.start()
      #root.display_all()
    else if view_type == 'students'
      chart.set_range(3)
      chart.update_all_nodes(3)
      chart.update_vis()
      #chart.start()
      #root.display_all()
    else if view_type == 'old'
      chart.set_range(4)
      chart.update_all_nodes(4)
      chart.update_vis()
      #chart.start()
      #root.display_all()
    else
      root.display_all()

  d3.csv "data/tampere_data.csv", render_vis
