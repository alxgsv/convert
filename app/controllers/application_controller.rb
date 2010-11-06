require 'open-uri'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  def convert
    render :text => "Nothing to convert", :status => 404 and return if !params[:uri]
    @ebook = Ebook.find_or_create(params[:uri])
    send_file @ebook.filename(params[:format])
  end
end
