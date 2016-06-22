class Main < ActiveRecord::Base
  attr_accessor :format, :columns, :raw_sheet

  def initialize
    @format = {}
    @columns = []
    @rows = []
    @raw_sheet = []
  end

  def run(file)
    process_sheet(file)
  end

  private

  def process_sheet(file)
    row_num = 0
    CSV.foreach(file.path) do |row|
      if row.any?
        @raw_sheet.push(row)
        case row_num
          when 0
            process_overall_format(row)
          when 1
            process_columns(row)
          else
            hash = prepare_maps_hash(row)
            response = make_maps_request(hash)
            insert_response_values(response, row_num)
        end
        row_num += 1
      end
    end
    insert_headers
    @raw_sheet
  end

  def insert_headers
    start_index = @columns.find_index('Transit Mode') + 1
    @raw_sheet[0][start_index] = 'Output'
    @raw_sheet[1][start_index] = 'Status'
    @raw_sheet[1][start_index+1] = 'Duration in Traffic'
    @raw_sheet[1][start_index+2] = 'Distance'
  end

  def insert_response_values(response, row_num)
    body_hash = JSON.parse(response.body)
    results = body_hash['rows'][0]['elements'][0]
    status = results['status']
    start_index = @columns.find_index('Transit Mode') + 1
    if status == 'OK'
      duration = results['duration_in_traffic']['text']
      distance = results['distance']['text']
      @raw_sheet[row_num][start_index+1] = duration
      @raw_sheet[row_num][start_index+2] = distance
    end
    @raw_sheet[row_num][start_index] = status
  end

  def prepare_maps_hash(row)
    hash = {}
    hash = add_addresses(hash, row)
    hash = add_api_key(hash, row)
    add_inputs(hash, row)
  end

  def add_inputs(hash, row)
    time = row[@columns.find_index('Time')].downcase
    time = (time.include?'am') ? DateTime.now.change({hour: time.gsub('am','').to_i}).strftime('%s') : DateTime.now.change({hour: time.gsub('pm','').to_i+12}).strftime('%s')
    row[@columns.find_index('Arrival/Departure')] == 'arrival' ? hash[:arrival_time] = time : hash[:departure_time] = time
    hash[:traffic_model] = row[@columns.find_index('Traffic Model')] unless hash[:departure_time].nil?
    hash[:mode] = row[@columns.find_index('Transit Mode')]
    hash[:units] = 'imperial'
    hash
  end

  def add_api_key(hash, row)
    hash[:key] = row[@columns.find_index('API Key')]
    hash
  end

  def add_addresses(hash, row)
    origin = @format[:origin]
    destination = @format[:destination]
    hash[:origins] = row[origin[:index]..origin[:index]+origin[:following]].join(' ')
    hash[:destinations] = row[destination[:index]..destination[:index]+destination[:following]].join(' ')
    hash
  end

  def process_columns(row)
    @columns = row
  end

  def process_overall_format(row)
    prev_valid_cell = nil
    prev_valid_index = 0
    index = -1
    following = 0
    row.each do |cell|
      index += 1
      if cell.nil?
        following += 1
      else
        @format[prev_valid_cell.parameterize.underscore.to_sym] = { index: prev_valid_index, following: following } unless prev_valid_cell.nil?
        following = 0
        prev_valid_cell = cell
        prev_valid_index = index
      end
    end
    @format[prev_valid_cell.parameterize.underscore.to_sym] = { index: prev_valid_index, following: following }
  end

  def make_maps_request(hash)
    url = create_url(hash)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.request(Net::HTTP::Get.new(uri.request_uri))
  end

  def create_url(hash)
    url = "https://maps.googleapis.com/maps/api/distancematrix/json?"
    hash.each { |k, v|  url += add_param(k, v) }
    url
  end

  def add_param(k, v)
      "&#{k}=#{v}"
  end

  # def self.open_spreadsheet(file) #multiple formats
  #   case File.extname(file.original_filename)
  #     when '.csv' then CSV.new(file.path)
  #     # when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
  #     # when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
  #     else raise "Unknown file type: #{file.original_filename}"
  #   end
  # end
end