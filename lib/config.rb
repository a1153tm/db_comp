module DBComp

  class Config
  
    attr_reader :redshift, :mysql
  
    def initialize
      @redshift = DatabaseConfig.new
      @mysql = DatabaseConfig.new
    end
  
  end
  
  class DatabaseConfig
  
    attr_accessor :url, :user, :password
  
    def connection
      db = @url.match(/\/(\w+)$/)[1]
      return @url, @user, @password, db
    end

  end

end
