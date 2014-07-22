require 'lib/column'

module DBComp

  module Derivable

    def derivedLayout(name, columns)
      DerivedLayout.new(name, columns)
    end

  end

  module Caluratable

    include Derivable

    def +(layout_or_columns)
      if layout_or_columns.kind_of?(Array)
        to_add = layout_or_columns.map { |col_hash| Column.new(col_hash) }
      elsif layout_or_columns.kind_of?(Layout)
        to_add = layout_or_columns.columns
      else
        raise "Invalid calcuration. '+' only support Array of Hash or Layout intance."
      end
      add(to_add)
    end

    def -(array_of_hash_or_name)
      col_names = array_of_hash_or_name.map do |elem|
        elem.kind_of?(Hash) ? elem[:name] : elem
      end
      columns = @columns.select { |col| not col_names.include?(col.name) }
      derivedLayout("(calcurated #{table})", columns)
    end

    private

    def add(to_add)
      columns = @columns.dup
      to_add.each do |col|
        columns << col unless columns.map { |c| c.name }.include? col.name
      end
      derivedLayout("(calcurated #{table})", columns)
    end

  end

  module Sortable

    include Derivable

    def sort
      derivedLayout("#{table}[sorted]", @columns.sort)
    end

  end

  module Overridable

    include Derivable

    def override(col_name_and_overrides)
      col_name = col_name_and_overrides[:column]
      overrides = col_name_and_overrides.dup
      overrides.delete(:column)
      columns = @columns.dup
      if col_name == "all"
        columns.each do |col|
          _override(col, overrides)
        end
      else
        col = columns.find { |c| c.name == col_name }
        raise "#{col_name} not found in #{table}." unless col
        _override(col, overrides)
      end
      derivedLayout("#{table}[overridden]", columns)
    end

    private

    def _override(column, attrs)
      attrs.each do |attr, val|
        method = attr.to_s + "="
        raise "Undefine attribute #{attr.to_s} in #{table}." unless Column.method_defined?(method)
        column.send(method, val)
      end
    end

  end

  class Layout

    attr_reader :columns
  
    def ==(other)
      @columns == other.columns
    end
  
  end
  
  class DBLayout < Layout

    include Caluratable, Sortable, Overridable

    def table
      "#{database}.#{@table_name}"
    end

    def method_missing(name)
      set_table_name_and_columns(name.to_s)
      self
    end
  
    protected

    def set_table_name_and_columns(table_name)
      @table_name = table_name
      set_columns
    end

  end

  class RedshiftLayout < DBLayout

    protected

    def database
      "redshift"
    end

    def set_columns
      @columns = RedshiftColumn.find(@table_name)
      raise "#{@table_name} not found in #{database}." if @columns.empty?
    end
  
  end
  
  class MySQLLayout < DBLayout
  
    protected

    def database
      "mysql"
    end

    def set_columns
      @columns = MySQLColumn.find(@table_name)
      raise "#{@table_name} not found in #{database}." if @columns.empty?
    end
  
  end

  class DerivedLayout < Layout

    include Caluratable, Sortable, Overridable

    attr_reader :table

    def initialize(table, columns)
      @table = table
      @columns = columns
    end

  end

end

