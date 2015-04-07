require 'nokogiri'
require 'open-uri'

# Controller for Reports
class ReportsController < ApplicationController
	before_filter :authenticate_user!
	#  List of reports
  def index
  	@reports = current_user.reports
  	if !params[:adword_present].nil?
  		@reports = @reports.where("'%#{params[:adword_present]}%' ~~*^ ANY (top_adwords_url) OR '%#{params[:adword_present]}%' ~~*^ ANY (right_adwords_url)")
  	end

  	if !params[:url_present].nil?
  		@reports = @reports.where("'#{params[:url_present]}' ~~*^ ANY (non_adwords_url)")
  	end
  end

  # Show report
  def show
  	@report = Report.find(params[:id])
  end

  # New report
  def new
  	@report = current_user.reports.new
  end

  # Create report
  def create
  	keywords = open_spreadsheet(params[:file])

  	unless keywords.nil?
  		keywords = keywords.row(1)
  		begin
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
  		rescue Exception => exc
  			logger.error("Message for the log file #{exc.message}")
  			flash[:notice] = "Unable to process keywords"
  			redirect_to reports_url
  		end
  	end
  	@reports = current_user.reports
  	redirect_to reports_url, notice: "Reports are successfully created"
  end

  private
   # To check uploaded file is CSV or not
  def open_spreadsheet(file)
    case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
    end
  end

  # Only allow a trusted parameter "white list" through.
  def report_params
    params.require(:report).permit(:keyword, :top_adwords_url, :right_adwords_url, :non_adwords_url, :total_results, :page_cache)
  end
end
