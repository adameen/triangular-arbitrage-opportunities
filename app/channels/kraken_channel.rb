class KrakenChannel < ApplicationCable::Channel

  def subscribed
    stream_from "kraken_channel"

    puts "[KrakenChannel] A user has just been subscribed"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    puts "[KrakenChannel] A user has just been unsubscribed"
  end
  
end
