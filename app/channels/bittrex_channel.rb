class BittrexChannel < ApplicationCable::Channel

  def subscribed
    stream_from "bittrex_channel"

    puts "BittrexChannel subscribed !!!"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    puts "BittrexChannel unsubscribed !!!"
  end

end
