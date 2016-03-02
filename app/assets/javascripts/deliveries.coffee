# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'click', '#like_artist', ->
  is_checked = $(this).prop('checked')
  url = '/account/delete_artist'
  if is_checked
    url = '/account/add_artist'

  artist_id = $(this).val()
  post_data = {artist_id: artist_id}

  jqXHR = $.ajax({
    async: true
    url: url
    type: 'post'
    data: post_data
    dataType: 'json'
    cache: false
  })

  jqXHR.done (data, stat, xhr) ->
    console.log { done: stat, data: data, xhr: xhr }
#    data.forEach (obj) ->
#      $(".rc#{obj.axis_slug}").append("<div class=\"center-block\"><a href=\"/coordinates/show/#{obj.id}\">#{obj.id}</a></div>")

  jqXHR.fail (xhr, stat, err) ->
    console.log { fail: stat, error: err, xhr: xhr }
#    alert xhr.responseText

#  jqXHR.always (res1, stat, res2) ->
#    console.log { always: stat, res1: res1, res2: res2 }
#    alert 'Ajax Finished!' if stat is 'success'