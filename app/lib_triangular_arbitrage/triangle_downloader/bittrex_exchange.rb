module TriangleDownloader

  class BittrexExchange < Exchange
    # ------------- CONSTANTS -------------
    # Taker fee on Bittrex is 0.25%
    TAKER_FEE = 0.0025

    # ------------- PROTECTED METHODS -------------
    protected

    def set_endpoint
      @endpoint = "https://api.bittrex.com/api/v1.1/public/getmarketsummaries"
    end

    # Creates hash of available pairs, e.g. "BTC-LTC".
    def create_pairs
      set_request(@endpoint)
      download_data_from_exchange

      @pairs = Hash.new

      @html_body_parsed["result"].each do |pair_JSON|
        #set pairs Hash in order to update data effectively later
        @pairs[pair_JSON["MarketName"]] =
                    Structures::Pair.new(pair_JSON["MarketName"],
                                         pair_JSON["Bid"],
                                         pair_JSON["Ask"],
                                         TAKER_FEE)
      end
    end


    # Update data of all available pairs, e.g. "BTC-LTC".
    def update_pairs
      download_data_from_exchange

      @html_body_parsed["result"].each do |pair_JSON|
        pair_name = pair_JSON["MarketName"]
        bid = pair_JSON["Bid"]
        ask = pair_JSON["Ask"]
        if bid == 0.0 || bid == nil || ask == 0.0 || ask == nil
          @pairs[pair_name].is_valid = false
          next
        end
        @pairs[pair_name].is_valid = true
        @pairs[pair_name].bid_best = bid
        @pairs[pair_name].ask_best = ask
      end
    end


    # Creates hash of all the possible triangles which make sense.
    # These triangles are then used to check new triangular arbitrage opportunities.
    def create_triangles
      create_helpers
      is_reversed_array = []
      @triangles = Hash.new

      @currencies.each do |first, hash_of_seconds|
        hash_of_seconds.each do |second, is_second_ordered|
          if is_second_ordered
            first_pair = "#{first}-#{second}"
            is_reversed_array[0] = false
          else
            first_pair = "#{second}-#{first}"
            is_reversed_array[0] = true
          end

          @currencies[second].each do |third, is_third_ordered|
            # do not want A - B - A pattern
            if third == first
              next
            elsif @pairs.key?("#{third}-#{first}")
              third_pair = "#{third}-#{first}"
              is_reversed_array[2] = false
            elsif @pairs.key?("#{first}-#{third}")
              third_pair = "#{first}-#{third}"
              is_reversed_array[2] = true
            # there is no connection between the last and first currency
            else
              next
            end

            if is_third_ordered
              second_pair = "#{second}-#{third}"
              is_reversed_array[1] = false
            else
              second_pair = "#{third}-#{second}"
              is_reversed_array[1] = true
            end
            @triangles["#{first}-#{second}-#{third}"] =
                  Structures::Triangle.new(
                        [@pairs[first_pair], @pairs[second_pair], @pairs[third_pair]],
                        is_reversed_array)
          end
        end
      end
      remove_duplicate_triangles
    end


    # ------------- PRIVATE METHODS -------------
    private

    # Creates hash of hashes where one can find
    # e.g. "BTC" --> "LTC" --> true/false thanks to that.
    def create_helpers
      @currencies = Hash.new

      @pairs.each do |pair_name, pair_value|
        single_currencies = pair_name.split("-")
        unless @currencies.key?(single_currencies[0])
          @currencies[single_currencies[0]] = Hash.new
        end
        unless @currencies.key?(single_currencies[1])
          @currencies[single_currencies[1]] = Hash.new
        end
        # Set if the currencies in the new pair are swapped
        @currencies[single_currencies[0]][single_currencies[1]] = true
        @currencies[single_currencies[1]][single_currencies[0]] = false
      end
    end

  end # end of BittrexExchange class
end # end of module
