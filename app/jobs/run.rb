# require 'pry'
# class RunJob < ProgressJob::Base
#   def initialize(sheet)
#     max = sheet[:rows].length
#     super progress_max: max
#     @rows = sheet[:rows]
#   end
#
#   def perform
#     # binding.pry
#     Rails.logger.info "Rows: #{@rows}"
#     puts "puts Rows: #{@rows}"
#     update_stage('Calculating Drive Times')
#     step = 0
#     @rows.each do |row|
#       #hit Google Maps
#       step++
#       update_progress
#     end
#     # csv_string = CSV.generate do |csv|
#     #   @users.each do |user|
#     #     csv << user.to_csv
#     #   end
#     # end
#     # File.open('path/to/export.csv', 'w') { |f| f.write(csv_string) }
#   end
# end