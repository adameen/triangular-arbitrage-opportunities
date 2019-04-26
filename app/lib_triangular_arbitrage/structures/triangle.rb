module Structures

  class Triangle
    attr_reader  :triangle_pairs, :is_reversed
    attr_accessor  :profit

    def initialize(triangle_pairs, is_reversed, profit = 0)
      @triangle_pairs = Array.new()
      @is_reversed = Array.new()
      @profit = profit

      for i in 0..triangle_pairs.length-1
        @triangle_pairs.push(triangle_pairs[i])
        @is_reversed.push(is_reversed[i])
      end
    end

    def as_json(options)
      super(:except => "is_reversed")
    end

  end

end
