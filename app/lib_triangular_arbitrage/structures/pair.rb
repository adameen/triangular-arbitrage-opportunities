module Structures

  class Pair
    attr_reader  :name, :taker_fee
    attr_accessor  :bid_best, :ask_best

    def initialize(name, bid, ask, fee)
      @name = name
      @bid_best = bid
      @ask_best = ask
      @taker_fee = fee
    end

    def as_json(options)
      super(:only => "name")
    end

  end

end
