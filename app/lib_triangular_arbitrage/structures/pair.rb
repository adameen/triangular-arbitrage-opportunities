module Structures

  class Pair
    attr_reader  :name, :taker_fee
    attr_accessor  :bid_best, :ask_best, :is_valid

    def initialize(name, bid, ask, fee)
      @name = name
      @bid_best = bid
      @ask_best = ask
      @taker_fee = fee
      @is_valid = true
      if @ask_best == 0.0 || @ask_best == nil ||
         @bid_best == 0.0 || @bid_best == nil
          @is_valid = false
      end
    end

    def as_json(options)
      super(:only => "name")
    end

  end

end
