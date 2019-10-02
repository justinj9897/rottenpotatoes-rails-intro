class Movie < ActiveRecord::Base
  def self.get_ratings
    ['G','PG','PG-13','R']
  end
  
  def self.with_ratings(ratings)
      Movie.where(:rating => ratings.map(&:upcase))
  end
end
