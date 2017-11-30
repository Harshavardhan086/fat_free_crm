
jQuery ($) ->

  $(document).on("click",".remove_referral", ->
    referral_id = $(this).attr("id")
    console.log("the source id is " + referral_id)
    $. get "/remove_referral",
      id: referral_id
    return
  )
