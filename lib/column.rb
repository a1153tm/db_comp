module DBComp

  class Column
  
    attr_accessor :name, :type, :length, :nullable
  
    def self.find(table)
      self.select_col_defs(table).map do |col_def|
        Column.new(col_def)
      end
    end
  
    def initialize(col_def)
      @name = col_def[:name].strip.downcase
      @type = col_def[:type]
      @length = col_def[:length] ? col_def[:length].to_i : ''
      @nullable = col_def[:nullable] ? true : false
    end
  
    def ==(other)
      @name == other.name and @type == other.type and @length == other.length and @nullable == other.nullable
    end

    def <=>(other)
      @name <=> other.name
    end

    def to_s
      [@name.ljust(20, ' '), @type.to_s.ljust(10, ' '), @length.to_s.ljust(5, ' '), @nullable.to_s].join
    end
  
  end

  class RedshiftColumn < Column
    
    def self.select_col_defs(table)
      query = "select * from information_schema.columns
               where table_catalog = '#{@database}' and table_name = '#{table}' order by ordinal_position"
      rs = @conn.create_statement.execute_query(query)
      col_defs = []
      col_type_map = {
        "character" => :char,
        "character varying" => :varchar,
        "integer" => :int,
        "boolean" => :bool,
        "date" => :date,
        "smallint" => :smallint,
        "timestamp without time zone" => :timestamp,
        "timestamp wit time zone" => :timestamp
      }
      while (rs.next) do
        col_def = {}
        col_def[:name] = rs.getString('column_name')
        type = rs.getString('data_type')
        col_def[:type] = col_type_map[type] || type
        col_def[:length] = rs.getInt('character_maximum_length') if [:char, :varchar].include?(col_def[:type])
        col_def[:nullable] = rs.getString('is_nullable') == 'YES' ? true : false
        col_defs << col_def
      end
      col_defs
    end

  end

  class MySQLColumn < Column
    
    def self.select_col_defs(table)
      query = "show columns from #{table}"
      rs = @conn.create_statement.execute_query(query)
      col_defs = []
      col_type_map = {
        "char" => :char,
        "varchar" => :varchar,
        "int" => :int,
        "smallint" => :smallint,
        "tinyint" => :bool,
        "date" => :date,
        "timestamp" => :timestamp
      }
      while (rs.next) do
        col_def = {}
        col_def[:name] = rs.getString('Field').strip
        type_len = rs.getString('Type').strip.match(/^(\w+)\(?(\d*)\)?$/)
	type_len = [nil, rs.getString('Type').strip, ''] unless type_len
        col_def[:type] = col_type_map[type_len[1]] || type_len[1]
        if [:int, :smallint, :bool].include? col_def[:type]
          col_def[:length] = nil
        else
          col_def[:length] = type_len[2].empty? ? nil : type_len[2].to_i
        end
        col_def[:nullable] = rs.getString('Null').strip == 'YES' ? true : false
        col_defs << col_def
      end
      col_defs
    end

  end

end
