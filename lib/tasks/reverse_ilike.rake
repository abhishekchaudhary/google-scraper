namespace :reverse_ilike do
	desc "This task adds reverse ilike function for sql"
 	task run: :environment do
    	sql_one = "create function reverse_ilike(text, text) RETURNS boolean AS 'select $2 ilike $1;' LANGUAGE SQL IMMUTABLE RETURNS NULL ON NULL INPUT;  "
		sql_two = "create operator ~~*^ (PROCEDURE = reverse_ilike, LEFTARG = text, RIGHTARG = text);  "
		ActiveRecord::Base.establish_connection
		ActiveRecord::Base.connection.execute(sql_one)
		ActiveRecord::Base.connection.execute(sql_two)
  	end
end
