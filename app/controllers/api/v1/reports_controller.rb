require 'nokogiri'
require 'open-uri'

class Api::V1::ReportsController < ApplicationController
  def index
  	@reports = current_user.reports
  	if !params[:adword_present].nil?
  		byebug
  		@reports = @reports.where("'#{params[:adword_present]}' ILIKE ANY (top_adwords_url) OR '#{params[:adword_present]}' ILIKE ANY (right_adwords_url)")
  	end
  	respond_to do |format|
  		format.html
  		format.any(:xml, :json) { render request.format.to_sym => @reports }
  	end
  end

  def show
  	@report = Report.find(params[:id])
  	respond_to do |format|
  		format.html
  		format.any(:xml, :json) { render request.format.to_sym => @report }
  	end
  end

  def new
  	@report = current_user.reports.new
  end

  def create
  	keywords = open_spreadsheet(params[:file])

  	unless keywords.nil?
  		keywords = keywords.row(1)
  		keywords.each do |keyword|
  		  reformat_keyword = keyword.gsub(" ","+")
          doc = Nokogiri::HTML(open('http://www.google.com/search?q='+reformat_keyword))
          report = current_user.reports.new
          report.keyword = keyword

          # Top adwords
          top_array = []
		  doc.css('div#tads ol li cite').each do |link|
		  	top_array << link.text
		  end
		  report.top_adwords_url  = top_array

		  # Right adwords
		  right_array = []
		  doc.css('div#mbEnd ol li cite').each do |link|
		  	right_array << link.text
		  end
		  report.right_adwords_url  = right_array

		  # Non adwords
		  non_adwords_array = []
		  doc.css('div#ires ol li cite').each do |link|
		  	non_adwords_array << link.text
		  end
		  report.non_adwords_url  = non_adwords_array

		  # Result stats
		  report.total_results = doc.css('div#resultStats').text

		  #  Page cache
		  report.page_cache = PGconn.escape_bytea(doc.to_s)

		  report.save
  		end
  	end

	respond_to do |format|
		format.html {redirect_to api_v1_reports_index_url}
  		# format.any(:xml, :json) { render request.format.to_sym => @people }
  	end
  end

  private
   # To check uploaded file is CSV or not
  def open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def report_params
    params.require(:report).permit(:keyword, :top_adwords_url, :right_adwords_url, :non_adwords_url, :total_results, :page_cache)
  end
end
