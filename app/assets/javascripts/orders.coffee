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

  $(document).on("change",".business_rule_filter", ->
    console.log("looking for the change" + ($("#order_request_type").val()))
    if $('#order_request_type').val() != '' and $('#order_state_of_incorporate').val() != ''
      state = $('#order_state_of_incorporate').val()
      request_type = $('#order_request_type').val()
      $.post '/populate_amount',
        state: state,
        type: request_type
      return
    return
  )

  $(document).on("change",".opportunity_amount", ->
    console.log("the value of the amount is :" + ($("#opportunity_amount").val()))
    if $("#opportunity_amount").val() != ''
      amount =  $("#opportunity_amount").val()
      other = $("#opportunity_other_amount").val()
      discount = $("#opportunity_discount").val()
      $.post '/populate_total_amount',
        amount: amount,
        other: other,
        discount: discount
      return
    return
  )

  $(document).on("click",".create_order_invoice", ->
    console.log("in the create_order_invoice** Order id is: " + ($(this).attr("id")))
    order_id = $(this).attr("id")
    $. post "/create_order_invoice",
      order_id: order_id
    return
  )
