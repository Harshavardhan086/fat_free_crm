# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


jQuery ($) ->

  parse_account_id = (id) ->
    account_id = id.split("_")[4]
    return account_id
  console.log("IN the orders.js.coffee")
  $(document).on("click", ".active-result", ->
    console.log("clicked on the active-result")
    account_id = parse_account_id($(this).attr('id'))
    account_name = $(this).text()
    console.log("THE ACCOUNT name IS: "+ account_name)
    $.post '/copy_account_details',
      account_name: account_name
    return
  )

  $(document).on("click",".remove_attachment", ->
    attachment_id= $(this).attr("id")
    console.log("attacment_id is: "+ attachment_id)
    $.post '/remove_attachment',
      attachment_id: attachment_id
    return
  )

  $(document).on("click", ".send_invoice", ->
    order_id = $(this).attr("id")
    console.log("THE Order id is: " + order_id)
    $.post '/send_invoice',
      order_id: order_id
    return
  )