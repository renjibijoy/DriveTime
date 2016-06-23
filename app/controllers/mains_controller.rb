require 'net/http'
require_relative '../jobs/run'
class MainsController < ApplicationController
  respond_to :csv, :html

  def index
  end

  def run
    session = Main.new
    @output = session.run(params[:file])
    flash[:notice] = 'Successfully processed spreadsheet!'
    respond_to do |format|
      format.html
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"#{'(Completed) ' + params[:file].original_filename}\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  rescue Exception => e
    flash[:alert] = 'ERROR: ' + e.message
    request.format = :html
    headers['Content-Type'] ||= 'text/html'
    response.content_type ||= Mime::HTML
    respond_with do |format|
      format.html { render :index }
    end
  end

  # def download_csv
  #   @output = params[:csv]
  #   respond_to do |format|
  #     format.html
  #     format.csv do
  #       headers['Content-Disposition'] = "attachment; filename=\"user-list\""
  #       headers['Content-Type'] ||= 'text/csv'
  #     end
  #   end
  # end

  # def run #Google Sheet
  #   api_key = params[:main][:api_key]
  #   sheet_id = params[:main][:sheet_id]
  #   url = "https://sheets.googleapis.com/v4/spreadsheets/#{sheet_id}?key=#{api_key}"
  #   uri = URI.parse(url)
  #   http = Net::HTTP.new(uri.host, uri.port)
  #   http.use_ssl = true
  #   http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  #   response = http.request(Net::HTTP::Get.new(uri.request_uri))
  #   @result = response.body
  #   # sheet = {rows: [1,2,3]}
  #
  #
  #   # @job = Delayed::Job.enqueue RunJob.new(sheet)
  # end
end
