// triggers a search for the search text
$("#search_meetup").click(function() {
  if($("#search_text").val() != ""){
    $("#display-search").html('Request is being processed...');
    $.ajax({
      type: 'GET',
      url: '/meetups/search',
      data: { search_text: $("#search_text").val() },
      dataType: 'script',
      success: function(){
        console.log("polling...");
      }
    });
  }
});

// loads all the meetups and then stops polling, when all the results are fetched
let loadMeetups = function(){
  if($("#search_text").val() == "")
    return;
  $.ajax({
  url: '/meetups/search_result',
  data: { search_text: $("#search_text").val() },
  method: 'GET',
  dataType: 'script',
  success: function(result) {
    console.log("successful polling...");
    if($("#results_fetched").val() == 'true')
      stopPolling();
  }
});
}

let startPolling = function(){
  console.log('startPolling');
  return setInterval(loadMeetups, 1000); 
}
let stopPolling = function() {
    console.log("stopPolling");
    clearInterval(PollingID);
}