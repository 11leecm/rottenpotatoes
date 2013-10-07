class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings # retrieve all ratings
    if !session[:ratings] # if new session, create a Hash for session
      session[:ratings] = Hash.new(true)
      @all_ratings.each do |movie_rating| # Hash with value 1, but no need to use values (explained in part 2)
        session[:ratings][movie_rating] = '1'
      end
    end

    if params[:ratings] # save ratings on session
      session[:ratings] = params[:ratings]
    end

    if params[:sort_order] # save sort order on session
      session[:sort_order] = params[:sort_order]
    end

    params_ratings = params[:ratings]
    session_ratings = session[:ratings]
    params_sort_order = params[:sort_order]
    session_sort_order = session[:sort_order]

    if (!params_ratings) or ((!params_sort_order) and (session_sort_order)) # redirect to new URl with appropriate parameters
      if flash[:notice] # we need flash[] to survive across more than a single redirect
        flash.keep
      end
      redirect_to(movies_path({:ratings => session_ratings, :sort_order => session_sort_order}))
    end

    if session_sort_order == 'title' # check for sort order by title
      @movies = Movie.find(:all, :conditions => ["rating in (?)", session_ratings.keys], :order => 'title ASC')
      @title_class = 'hilite'
    elsif session_sort_order == 'release_date' # check for sort order by release date
      @movies = Movie.find(:all, :conditions => ["rating in (?)", session_ratings.keys], :order => 'release_date ASC')
      @release_date_class = 'hilite'
    else # check for no sort order
      @movies = Movie.find(:all, :conditions => ["rating in (?)", session_ratings.keys])
    end

    @checked_ratings = Hash.new(true) # include checked rating boxes in the session for next time
    @all_ratings.each do |movie_rating|
      @checked_ratings[movie_rating] = session_ratings.include?(movie_rating)
    end

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
