define [
  'chaplin'
  'views/site_view'
], (Chaplin, SiteView) ->
  'use strict'

  class Controller extends Chaplin.Controller
    beforeAction: ->
      super
      @reuse 'site', SiteView
