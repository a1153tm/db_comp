class Reporter

  def initialize(out)
    @out = out
    @results = []
  end

  def <<(result)
    report(result)
    @results << result
  end

  def report_summary
    total = @results.size
    ok = @results.select { |r| r[:result] }.size
    ng = total - ok
    @out.puts "TOTAL:#{total}, OK:#{ok}, NG:#{ng}"
  end

  private

  def report(result)
    expr = "#{result[:left].table} == #{result[:right].table}"
    if result[:result]
      @out.puts "OK: #{expr}"
    else
      @out.puts "NG: #{expr}"
      @out.puts "      left:"
      show_columns(result[:left].columns)
      @out.puts "      right:"
      show_columns(result[:right].columns)
    end
  end

  def show_columns(cols)
    cols.each do |col|
      @out.puts "         #{col.to_s}"
    end
  end

end
