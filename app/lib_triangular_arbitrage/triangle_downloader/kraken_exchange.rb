module TriangleDownloader

  class KrakenExchange < Exchange
    # ------------- CONSTANTS -------------
    # Taker fee on Kraken varies based on specific pair which means
    # there is no global TAKER_FEE

    # There is also no endpoint which gives all the pairs info we need.
    # Thus we need to create that string and make a constant from it
    PAIRS_INFO = "https://api.kraken.com/0/public/AssetPairs"


    def initialize
      # Helper which helps to translate weird pair names which are returned
      # by Kraken ticker. It is a hash with key value pairs like this:
      # {weird_name_key: nice_name_value}
      @pairs_dictionary = Hash.new
    end

    # ------------- PROTECTED METHODS -------------
    protected

    def set_endpoint
      set_request(PAIRS_INFO)
      download_data_from_exchange

      @endpoint = "https://api.kraken.com/0/public/Ticker?pair="
      @html_body_parsed["result"].each do |pair_name, pair_obj|
        # We do not support Dark Pool
        # https://support.kraken.com/hc/en-us/articles/360001391906-Dark-Pool
        if pair_name.end_with?(".d")
          next
        else
          @endpoint.concat(pair_name, ",")
        end
      end
      # delete last "," from the string
      @endpoint.chop!
    end


    # Creates hash of available pairs, e.g. "BCH-XXBT".
    def create_pairs
      set_request(PAIRS_INFO)
      download_data_from_exchange

      #set pairs Hash in order to update data effectively later
      @pairs = Hash.new
      @html_body_parsed["result"].each do |pair_name, pair_obj|
        # We do not support Dark Pool
        if pair_name.end_with?(".d")
          next
        end

        combined_name = "#{pair_obj["base"]}-#{pair_obj["quote"]}"
        # ...,"fees":[[0,0.26],.....],... This means 0.26 % taker fee with this pair.
        fee = pair_obj["fees"][0][1] / 100
        @pairs[combined_name] =
                    Structures::Pair.new(combined_name, 0, 0, fee)

        add_to_pairs_dictionary(pair_name, combined_name)
      end
      # from now on, there will be only ask/bid updates in update_pairs
      set_request(@endpoint)
    end

    # Update data of all available pairs, e.g. "BCH-XXBT".
    def update_pairs
      download_data_from_exchange

      @html_body_parsed["result"].each do |pair_name, pair_obj|
        nice_name = @pairs_dictionary[pair_name]
        bid = pair_obj["b"][0].to_f
        ask = pair_obj["a"][0].to_f
        if bid == 0.0 || bid == nil || ask == 0.0 || ask == nil
          @pairs[nice_name].is_valid = false
          next
        end
        @pairs[nice_name].is_valid = true
        @pairs[nice_name].bid_best = bid
        @pairs[nice_name].ask_best = ask
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
            is_reversed_array[0] = true
          else
            first_pair = "#{second}-#{first}"
            is_reversed_array[0] = false
          end

          @currencies[second].each do |third, is_third_ordered|
            # do not want A - B - A pattern
            if third == first
              next
            elsif @pairs.key?("#{third}-#{first}")
              third_pair = "#{third}-#{first}"
              is_reversed_array[2] = true
            elsif @pairs.key?("#{first}-#{third}")
              third_pair = "#{first}-#{third}"
              is_reversed_array[2] = false
            # there is no connection between the last and first currency
            else
              next
            end

            if is_third_ordered
              second_pair = "#{second}-#{third}"
              is_reversed_array[1] = true
            else
              second_pair = "#{third}-#{second}"
              is_reversed_array[1] = false
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
    # Adds pairs (key: weird ticker pair name, value: object with nice name)
    # into helper @pairs_dictionary
    def add_to_pairs_dictionary(weird_name, nice_name)
      @pairs_dictionary[weird_name] = nice_name
    end

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


  end # end of class
end # end of module
