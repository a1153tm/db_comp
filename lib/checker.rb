require 'lib/layout'

module DBComp

  class Checker
  
    attr_reader :results, :cache

    def initialize
      @results = []
      @cache = {}
      Derivable.class_eval do
        alias :_derivedLayout :derivedLayout
        def derivedLayout(name, columns)
          layout = _derivedLayout(name, columns)
          layout.results = @results
          layout
        end
      end
    end

    def execute(code)
      eval code
      @results
    end
  
    def redshift
      layout = RedshiftLayout.new
      layout.results = @results
      layout
    end
  
    def mysql
      layout = MySQLLayout.new
      layout.results = @results
      layout
    end
  
  end

  class Layout

    attr_accessor :results

    alias :equals :==

    def ==(other)
      result = equals(other)
      @results << { result: result, left: self, right: other }
    end

  end

end

