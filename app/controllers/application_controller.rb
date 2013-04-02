require 'open-uri'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  def convert
    render :text => "Nothing to convert", :status => 404 and return if !params[:uri]
    chosen_format = params[:format] || "fb2"
    @ebook = Ebook.find_or_create(params[:uri])
    send_data File.open(@ebook.filename(chosen_format)).read, :filename => File.basename(@ebook.filename(chosen_format))
  end
end
