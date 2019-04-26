class KrakenChannel < ApplicationCable::Channel

  def subscribed

    stream_from "kraken_channel"

    puts "KrakenChannel subscribed !!!"
  end


  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    puts "KrakenChannel unsubscribed !!!"
  end
end
