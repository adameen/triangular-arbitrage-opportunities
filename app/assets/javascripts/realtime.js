// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on('turbolinks:load', function() {
  var pathname = window.location.pathname;
  if(pathname === "/realtime" || pathname === "/"){


    console.log("Text from realtime.js");

    if(App.realtime){
      console.log("App.realtime already EXISTS");
      App.cable.subscriptions.remove(App.realtime);
      App.realtime = null;
    }
    setTimeout(function(){
      console.log("Creating App.realtime");
      // everyone connects to Bittrex by default
      App.realtime = App.cable.subscriptions.create({channel: "BittrexChannel"}, {received: receivedData});
      console.log("Just created App.realtime");
    },500);


    // ================= FUNCTIONS =================
    function receivedData(data) {
      console.log("***** SOMETHING CAME FROM CHANNEL *****");

      if(data.error != ""){
        showError(data);
        return
      }

      let listOfTriangles = JSON.parse(data.message);
      let table = getTableHeader();

      // if radio button Best chosen then take first half of data
      if( $('#show-best').prop('checked')){
        listOfTriangles = listOfTriangles.slice(0, listOfTriangles.length/2);
      }
      // radio button Worst chosen then take second half of data
      else{
        listOfTriangles = listOfTriangles.slice(listOfTriangles.length/2,
                                                listOfTriangles.length);
        // Data are sorted in descending order so need to reverse it to
        // have the worst data as first.
        listOfTriangles.reverse();
      }

      let classOfNumber = "";
      console.log("===== DATA BEGINNING =====");

      for (let triangle of listOfTriangles) {
        console.log(triangle[0] + " ---- " + triangle[1].profit);
        triangle[1].profit > 0 ? classOfNumber = "positive-number"
                               : classOfNumber = "negative-number";
        table += getTableRow(triangle, classOfNumber);
      }
      console.log("===== DATA END =====");
      $('#realtimeTable').show();
      $('#realtimeTable').html(table);
      $('div.error-container').hide();
    }


    function getTableHeader(){
      return "<tr> \
                <th>Triangle<\/th><th>Pair #1<\/th><th>Pair #2<\/th> \
                <th>Pair #3<\/th><th>Profit (%) incl. fees<\/th> \
              <\/tr>";
    }


    function getTableRow(triangle, classOfNumber){
      return '<tr><td class="record-triangle-name">' + triangle[0] + '</td>' +
                '<td>' + triangle[1].triangle_pairs[0].name + '</td>' +
                '<td>' + triangle[1].triangle_pairs[1].name + '</td>' +
                '<td>' + triangle[1].triangle_pairs[2].name + '</td>' +
                '<td class="' + classOfNumber + '">' + triangle[1].profit +
              '</td></tr>';
    }

    function showError(data){
      let error = "<p class='error-message'>" +
                      data.error + "<br><br>" + data.message +
                  "</p>"

      $('div.error-container').show();
      $('div.error-container').html(error);
      $('#realtimeTable').hide();
    }

    // ================= EVENTS TRIGGERED =================

    // User chooses an exchange.
    $(document).on('click', '.container-exchanges', function(event) {
      // if user chose exchange recently then the buttons are disabled for a while
      if($('div.container-exchanges input[name=exchange]').prop('disabled')){
        return
      }
      // disable buttons for a while (1 sec)
      $('div.container-exchanges input[name=exchange]').attr("disabled", true);
      setTimeout(function(){
        $('div.container-exchanges input[name=exchange]').attr("disabled", false);
      },1000);

      let checkedChannel = $(".container-exchanges input[name='exchange']:checked").attr('id');
      // firt letter to uppercase
      checkedChannel = checkedChannel.charAt(0).toUpperCase() + checkedChannel.slice(1);
      checkedChannel = checkedChannel + "Channel";

      // if some channel was already subscribed
      if(App.realtime){
        App.cable.subscriptions.remove(App.realtime);
        App.realtime = null;
      }
      // There must be some delay between subscribing and unsubscribing
      // especially when user wants to subscribe the same channel.
      setTimeout(function(){
        App.realtime = App.cable.subscriptions.create({channel: checkedChannel},
                                                      {received: receivedData});
        console.log("after new initialization:");
        console.log(App.realtime);
      },500);
    });




  }
});



// User clicks on History button.
$(document).on('click', '.button-history', function(event) {
  console.log("============== History button clicked =============");
  App.cable.subscriptions.remove(App.realtime);
  App.realtime = null;
  console.log("============== UNSUBSCRIBED NOW =============");
});
