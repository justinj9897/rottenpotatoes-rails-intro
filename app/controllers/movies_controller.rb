class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # reset_session
    # @all_ratings = ['G','PG','PG-13','R']
    @all_ratings = Movie.get_ratings
    @selected_ratings = []
    
    @sort_filter = ""
    @use_session = false

    if (params[:sort]) 
      @sort_filter = params[:sort]
      session[:sort] = @sort_filter
    elsif (session[:sort])
      @sort_filter = session[:sort]
      @use_session = true
    else 
      @sort_filter = nil
    end
    
    if (params[:ratings])
      params[:ratings].each {|key, value| @selected_ratings << key}
      session[:ratings] = @selected_ratings
    elsif (session[:ratings])
      @selected_ratings = session[:ratings]
      @use_session = true
    else
      @selected_ratings = nil
    end
    
    if (@selected_ratings)
      @selected_ratings.map(&:upcase).each do |rating|
        params[rating] = true
      end
    end
    
    if (@sort_filter == 'title')
      @title_hilite = 'hilite'
    elsif (@sort_filter == 'release_date')
      @release_hilite = 'hilite'
    end
      
    if (@use_session)
      redirect_to movies_path :ratings=>@selected_ratings, :sort=>@sort_filter
    else
      if (@selected_ratings)
        # @movies = Movie.where(:rating => @selected_ratings).order(@sort_filter)
        @movies = Movie.with_ratings(@selected_ratings).order(@sort_filter)
      elsif (@sort_filter)
        @movies = Movie.order(@sort_filter)
      else
        @movies = Movie.all
      end
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
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
