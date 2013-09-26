require 'sinatra'

require 'sinatra'
require 'data_mapper'
require 'sinatra/flash'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/recall.db")

enable :sessions  

get '/' do  
    @notes = Note.all :order => :id.desc  
    @title = 'All Notes'  
    if @notes.empty?  
        flash[:error] = "No notes found. Add your first below."
    end   
    erb :home  
end  

post '/' do  
    n = Note.new  
    n.content = params[:content]  
    n.created_at = Time.now  
    n.updated_at = Time.now  
    if n.save  
    	flash[:notice] = "Note created successfully." 
    else  
    	flash[:error] = "Failed to save note."
    end
  redirect '/'   
end  

get '/:id' do  
  @note = Note.get params[:id]  
  @title = "Edit note ##{params[:id]}"  
  if @note
  	erb :edit
  else
  	flash[:error] = "Note not found."
  	redirect '/'
  end  
end 

put '/:id' do  
  n = Note.get params[:id]  
  unless  n
  	flash[:error] = "Note not found."
  	redirect '/'
  end
  n.content = params[:content] 
  #value of checkbox only submitted if checked
  #so checking for the existence 
  n.complete = params[:complete] ? 1 : 0  
  n.updated_at = Time.now  
  if n.save  
  	flash[:notice] = "Note updated successfully."
  else
  	flash[:error] = "Error updating note."
  end
  redirect '/' 
end  

get '/:id/delete' do
	@note = Note.get params[:id]
	@title = "Confirm deletion of note ##{params[:id]}"
  if @note
	 erb :delete
  else
    flash[:error] = "Note not found."
    redirect '/'
  end
end

delete '/:id' do  
  n = Note.get params[:id]  
  if n.destroy  
    flash[:notice] = "Note deleted successfully."
  else
    flash[:error] = "Error deleting note."
  end
  redirect '/' 
end 

get '/:id/complete' do  
  n = Note.get params[:id] 
  unless n
    flash[:error] = "Note not found." 
    redirect '/'
  end 
  n.complete = n.complete ? 0 : 1 # flip it  
  n.updated_at = Time.now  
  if n.save  
    flash[:notice] = "Note marked as complete."
  else
    flash[:error] = "Error marking note as complete."
  end 
  redirect '/' 
end 

###########################################################
#Set up new SQLite3 db in current directory named recall.db
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")  
  
#NDataMapper creates table as 'Notes'
class Note  
  include DataMapper::Resource  
  property :id, Serial  
  property :content, Text, :required => true  
  property :complete, Boolean, :required => true, :default => false  
  property :created_at, DateTime  
  property :updated_at, DateTime  
end  
  
#Tell DataMapper to automatically update
#db to contain tables and fields we've set
#and do so again if we make changes to schema  
DataMapper.finalize.auto_upgrade!  

helpers do
	include Rack::Utils
	alias_method :h, :escape_html
end