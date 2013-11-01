Neighborly.Projects = {} if Neighborly.Projects is undefined
Neighborly.Projects.Updates = {} if Neighborly.Projects.Updates is undefined

Neighborly.Projects.Updates.Index =
  init: Backbone.View.extend _.extend(
    el: '.updates'
    events:
      "ajax:success .list .update": "onDestroy"
      "ajax:success form#new_update": "onCreate"

    onCreate: (e, data) ->
      #$(".ghost-flash").addClass("flash").removeClass "hide", "ghost-flash"
      #this.$('.flash.ghost').appendTo('header')
      @$results.prepend data

    onDestroy: (e) ->
      $target = $(e.currentTarget)
      $target.remove()
      #@parent.$("a#updates_link .count").html " (" + @updates().length + ")"

    initialize: ->
      this.$loader = this.$('.updates-loading img')
      this.$loaderDiv = this.$('.updates-loading')
      this.$results = this.$('.list')
      this.path = this.$el.data('path')
      this.filter = { page: 2 }
      this.setupScroll()
      this.$el.on 'scroll:success', this.parseXFBML

    parseXFBML: ->
      FB.XFBML.parse() if this.$el.is(":visible")

    , Neighborly.InfiniteScroll)
