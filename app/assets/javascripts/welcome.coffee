# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'submit', 'form[name="signup"]', (e) ->
  offset = new Date().getTimezoneOffset()
  timezone = Math.floor(-(offset / 60))
  $(this).append('<input type="hidden" name="user[timezone]" value="'+timezone+'">')

$(document).on 'click', '.switch-form', (e) ->
  if ($(this).hasClass('switch-form-selected'))
    return false

  $('.switch-form').toggleClass('switch-form-selected')

  if ($(this).hasClass('switch-form-login'))
    $('form[name="login"]').show()
    $('form[name="signup"]').hide()
  else
    $('form[name="login"]').hide()
    $('form[name="signup"]').show()
