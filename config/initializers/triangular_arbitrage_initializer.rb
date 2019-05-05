
class TriangularArbitrageInitializer

  def start_all_channels
    Thread.new do
      start_broadcast_to_all_channels
    end
  end

  def start_broadcast_to_all_channels
    @exchanges = Hash.new
    # Dictionary where keys are nice names and values are channel names.
    # e.g.: (Bittrex -> bittrex_channel)
    @exchange_to_channel = Hash.new
    # Hash where key is nice exchange name and value is object from which is
    # then created the model object (database record). e.g.: Kraken -> {...}
    @highest_profits = Hash.new
    # last hour saved in the model (database)
    @last_hour = DateTime.now.utc.hour
    prepare_all_channels
    # main infinite loop
    i = 0 # seconds counter
    error_text = "There was a problem with getting data from"
    while true do
      check_hours
      @exchanges.each do |exchange_name, ex|
        begin
          puts "\n\n\n\n\n----------------- #{exchange_name}\t#{i} sec -----------------\n"
          ex.execute
        rescue StandardError => e
          ActionCable.server.broadcast @exchange_to_channel[exchange_name],
                                       { error: "#{error_text} #{exchange_name}. Try it later, please.",
                                         message: "#{e.class.name}: #{e.message}" }
        else
          ActionCable.server.broadcast @exchange_to_channel[exchange_name],
                                       { error: "",
                                         message: "#{ex.triangle_profits.to_json}" }
          check_highest_profit(exchange_name, ex)
        end
      end
      puts "\n\n@highest_profit Bittrex: #{@highest_profits["Bittrex"]}"
      puts "@highest_profits Kraken: #{@highest_profits["Kraken"]}\n\n"
      # now I have triangle_profits arrays of all the exchanges prepared
      sleep 1
      i = i + 1
    end
  end



  # Prepares and sets all exchanges (exchnage objects)
  def prepare_all_channels
    @template_profit = {:triangle_name => "ab", :pair1 => "cd", :pair2 => "ef",
                        :pair3 => "gh", :profit => -999999.0, :exchange => "ij",
                        :date => DateTime.now}

    # ---------------------------------------
    # Put other exchanges here:
    @bittrex_downloader = TriangleDownloader::BittrexExchange.new
    @exchanges["Bittrex"] = @bittrex_downloader
    @exchange_to_channel["Bittrex"] = "bittrex_channel"

    @kraken_downloader = TriangleDownloader::KrakenExchange.new
    @exchanges["Kraken"] = @kraken_downloader
    @exchange_to_channel["Kraken"] = "kraken_channel"


    # ---------------------------------------

    @exchanges.each do |exchange_name, ex|
      @highest_profits[exchange_name] = @template_profit.clone
      ex.prepare
    end
  end

  def check_hours
    puts "\nchecking hours\n"
    current_hour = DateTime.now.utc.hour
    # if it is next hour
    if current_hour != @last_hour
      puts "\nIT IS NEW HOUR\n"
      @exchanges.each do |exchange_name, exchange_object|
        if @highest_profits[exchange_name][:profit] != @template_profit[:profit]
          save_last_hour_record(exchange_name)
        end
        # If it equals, the exchange has no results from the past hour ->
        # it means this exchange's blackout lasts more than 1 hour.
      end
      @last_hour = current_hour
    end
  end

  # Check if the present best profit is better then the so far best
  def check_highest_profit(exchange_name, exchange)
    puts "\ncheck_highest_profit for #{exchange_name}"

    current_best_triangle = exchange.triangle_profits[0]
    puts "current_best_triangle: #{current_best_triangle}"
    # if the present profit is better than the up to now best one
    # then set it as the best one
    if current_best_triangle[1].profit > @highest_profits[exchange_name][:profit]
      @highest_profits[exchange_name][:triangle_name] = current_best_triangle[0]
      @highest_profits[exchange_name][:pair1] = current_best_triangle[1].triangle_pairs[0].name
      @highest_profits[exchange_name][:pair2] = current_best_triangle[1].triangle_pairs[1].name
      @highest_profits[exchange_name][:pair3] = current_best_triangle[1].triangle_pairs[2].name
      @highest_profits[exchange_name][:profit] = current_best_triangle[1].profit
      @highest_profits[exchange_name][:exchange] = exchange_name
      @highest_profits[exchange_name][:date] = DateTime.now.utc
    end
  end

  # Saves the best record from the last 1 hour time window to database.
  def save_last_hour_record(exchange_name)
    record = Record.new(@highest_profits[exchange_name])
    puts "Created model record: #{record}"
    if record.save
      puts "\n\n\nRECORD WAS SUCCESSFULLY SAVED TO DATABASE\n\n\n"
    else
      puts "\n\n\nRECORD WAS NOT SUCCESSFULLY SAVED TO DATABASE\n\n\n"
    end
    @highest_profits[exchange_name] = @template_profit.clone
  end


end

# Create starter object and start broadcasting.
TriangularArbitrageInitializer.new.start_all_channels
