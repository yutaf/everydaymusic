# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'submit', 'form', (e) ->
  offset = new Date().getTimezoneOffset()
  timezone = Math.floor(-(offset / 60))
  $(this).append('<input type="hidden" name="user[timezone]" value="'+timezone+'">')