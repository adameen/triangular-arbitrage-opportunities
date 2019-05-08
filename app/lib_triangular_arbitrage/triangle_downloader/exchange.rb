require 'json'
require 'net/http'
require 'uri'


module TriangleDownloader

  class Exchange
    attr_reader  :triangle_profits, :triangles
    # ------------- CONSTANTS -------------
    # number of triangles passed to client (first half are the best ones
    # and second half are the worst ones, sorted in descending order)
    RESULT_LENGTH = 40

    # ------------- PUBLIC METHODS -------------
    def execute
      update_pairs
      triangulate
    end

    def prepare
      set_endpoint
      create_structures
    end

    # ------------- PROTECTED METHODS -------------
    protected

    # Sets network objects in order to connect to the endpoint.
    def set_request(endpoint)
      puts "\nSet request to: #{endpoint}\n\n"
      @url = URI(endpoint)
      @http = Net::HTTP.new(@url.host, @url.port)
      @http.use_ssl = true
      @request = Net::HTTP::Get.new(@url)
    end

    # Downloads (usually) JSON file from exchange and save HTML body.
    def download_data_from_exchange
      begin
        response = @http.request(@request)
        @html_body = response.read_body
        # Parses downloaded HTML body into Ruby object.
        @html_body_parsed = JSON.parse(@html_body)
      rescue StandardError => e
        @error = Structures::CaughtError.new(e.class.name, e.message)
        raise
      end
    end

    # Creates strucutres needed for iterating over real-time data afterwards.
    def create_structures
      create_pairs
      create_triangles
    end

    # Removes all the duplicate triangles which would give us the same
    # outcome in terms of triangular arbitrage. These are the same ones:
    # A-B-C, B-C-A, C-A-B
    def remove_duplicate_triangles
      @triangles.delete_if do |name, obj|
        splitted = name.split("-")
        variation1 = "#{splitted[2]}-#{splitted[0]}-#{splitted[1]}"
        variation2 = "#{splitted[1]}-#{splitted[2]}-#{splitted[0]}"

        if @triangles.key?(variation1) || @triangles.key?(variation2)
          true
        else
          false
        end
      end
    end

    # Computes profit of all triangles, sort it in descending order
    # and saves top 20 and 20 worst of them in @triangle_profits array.
    def triangulate
      @triangles.each do |name, obj|
        obj.profit = compute_triangle_profit(obj)
      end

      @triangle_profits = @triangles.sort{ |x, y|
        y[1].profit <=> x[1].profit
      }
      #now it is array of arrays [[triangle_name, object],....]
      @triangle_profits.slice!(RESULT_LENGTH/2..@triangles.length-RESULT_LENGTH/2-1)
    end

    # Computes profit for a particular triangle (sequence of currencies
    # in general) including the fees. Profit is returned in % rounded on
    # 4 decimalal places (e.g. 1.23456789 -> 1.2346)
    def compute_triangle_profit(triangle)
      profit = 1.0
      triangle.triangle_pairs.each_index do |i|
        if triangle.is_reversed[i]
          profit = profit * triangle.triangle_pairs[i].bid_best
        else
          profit = profit / triangle.triangle_pairs[i].ask_best
        end
        profit = profit - (profit * triangle.triangle_pairs[i].taker_fee)
      end
      return ((profit - 1) * 100).round(4)
    end

    def set_endpoint
      raise "set_endpoint method NOT implemented in TriangleDownloader::Exchange"
    end

    def create_pairs
      raise "create_pairs method NOT implemented in TriangleDownloader::Exchange"
    end


    def update_pairs
      raise "update_pairs method NOT implemented in TriangleDownloader::Exchange"
    end


    def create_triangles
      raise "create_triangles method NOT implemented in TriangleDownloader::Exchange"
    end

  end # end of Exchange class
end # end of module
