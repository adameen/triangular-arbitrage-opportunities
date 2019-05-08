class BittrexChannel < ApplicationCable::Channel

  def subscribed
    stream_from "bittrex_channel"

    puts "[BittrexChannel] A user has just been subscribed"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    puts "[BittrexChannel] A user has just been unsubscribed"
  end

end
