class RecordsController < ApplicationController

  def index
    start_of_today = DateTime.now.utc.beginning_of_day
    end_of_today = start_of_today.end_of_day
    # show records of today only
    @records = Record.where('date > ? AND date < ?', start_of_today, end_of_today)
  end

  def create
    @selected_date = params[:record][:date]
    # no date was chosen
    if @selected_date.length == 0
      # show records of today only
      redirect_to records_path
      return
    end
    # no need for utc conversion
    start_of_selected_day = DateTime.parse(@selected_date)
    end_of_selected_day = start_of_selected_day.end_of_day
    @records = Record.where('date > ? AND date < ?', start_of_selected_day, end_of_selected_day)
    render 'index'
  end

end
