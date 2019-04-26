module Structures

  class CaughtError
    attr_accessor  :error_class_name, :error_message

    def initialize(error_class_name, error_message)
      @error_class_name = error_class_name
      @error_message = error_message
    end
  end

end
