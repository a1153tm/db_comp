require 'lib/layout'

module DBComp

  class Checker
  
    def initialize(reporter)
      @reporter = reporter
      Derivable.class_eval do
        alias :_derivedLayout :derivedLayout
        def derivedLayout(name, columns)
          layout = _derivedLayout(name, columns)
          layout.reporter = @reporter
          layout
        end
      end
    end

    def execute(code)
      eval code
      @reporter
    end
  
    def redshift
      layout = RedshiftLayout.new
      layout.reporter = @reporter
      layout
    end
  
    def mysql
      layout = MySQLLayout.new
      layout.reporter = @reporter
      layout
    end
  
  end

  class Layout

    attr_accessor :reporter

    alias :equals :==

    def ==(other)
      result = equals(other)
      @reporter << { result: result, left: self, right: other }
    end

  end

end

