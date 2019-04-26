// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on('turbolinks:load', function() {
  var pathname = window.location.pathname;
  if(pathname === "/records"){


    console.log("Text from records.js");

    setDatePicker();
    // dataset_name: dataset
    let myDatasets = {};
    // array for days: 0,1,2,...,23
    let indexArray = [];
    let hoursInDay = 24;
    let selectedDay = $("tr.history-record > td").first().text();

    selectedDay = selectedDay.substr(0, 10);
    if(selectedDay.length == 0){
      selectedDay = "selected date";
    }
    let graphTitle = "Best profit during each hour on " + selectedDay;

    for (let i = 0; i < hoursInDay; i++) {
      indexArray[i] = i;
    }
    // put record data into datasets and label record profits as positive/negative
    $("tr.history-record").each(function( index ) {
      let exName = $(this).children("td.record-exchange-name").text();
      let recordProfit = parseFloat($(this).children("td.record-profit").text());
      let recordDate = new Date ($(this).children("td.record-date").text());
      let recordHour = recordDate.getUTCHours();

      if(myDatasets[exName] === undefined){
        myDatasets[exName] = createDataset(exName);
      }
      myDatasets[exName]["data"][recordHour] = recordProfit;

      if (recordProfit < 0){
        $(this).children("td.record-profit").addClass("negative-number");
      }
      else{
        $(this).children("td.record-profit").addClass("positive-number");
      }
    });

    let myChart = createChart(indexArray, graphTitle);
    Object.keys(myDatasets).forEach(function(key) {
      myChart.data.datasets.push(myDatasets[key]);
    });
    myChart.update();


    // ================= FUNCTIONS =================

    // Sets datepicker (https://jqueryui.com/datepicker/).
    function setDatePicker(){
      $('#record_date').datepicker({dateFormat: 'yy-mm-dd',
                                    // first date possible to choose
                                    minDate: new Date(2019, 4 - 1, 21),
                                    // last date is today
                                    maxDate: 0,
                                    duration: "fast"});
      // cannot write into datepicker input
      $("#record_date").attr('readOnly', 'true');
      // submit disabled until user chooses date
      $('div.input-datepicker input[type="submit"]').attr("disabled", true);
    }

    // Creates dataset for including it into chart.
    function createDataset(exchangeName){
      return {
        "label": exchangeName,
        "data": [],
        "borderColor": random_color(),
        "fill": false,
        "borderWidth": 4
      }
    }

    // Generates random rgb color.
    function random_color() {
        var x = Math.floor(Math.random() * 256);
        var y = Math.floor(Math.random() * 256);
        var z = Math.floor(Math.random() * 256);
        var color = "rgb(" + x + ", " + y + ", " + z + ")";
        return color;
    }

    // Creates line chart (https://www.chartjs.org/).
    function createChart(hoursArray, graphTitle){
      var ctx = $('#data-chart');
      Chart.defaults.global.defaultFontSize = 20;
      var historyChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: indexArray,
            datasets: []
        },
        options: {
          legend: {
            display: true,
            position: 'top',
            labels: {
              // fontSize: 20,
            }
          },
          title: {
            display: true,
            fontSize: 26,
            text: graphTitle,
            fontFamily: 'Helvetica Neue',
            fontStyle: "normal"
          },
          responsive: true,
          scales: {
            yAxes: [{
              ticks: {
                beginAtZero: true,
                // fontSize: 20
              },
              scaleLabel: {
                display: true,
                // fontSize: 20,
                labelString: "Profit in % including fees",
              }
            }],
            xAxes: [{
              ticks: {
                // fontSize: 20
              },
              scaleLabel: {
                display: true,
                // fontSize: 20,
                labelString: "UTC Time (specific hour of the selected day)",
              }
            }]
          }
        }
      });
      return historyChart;
    }

    // ================= EVENTS TRIGGERED =================

    // Enable submit button as soon as a date was chosen.
    $("div.input-datepicker input[type=text]").change(function() {
        $('div.input-datepicker input[type="submit"]').attr("disabled", false);
    });



  }
});
