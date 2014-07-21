class Reporter

  def self.report(results, out)
    results.each do |r|
      expr = "#{r[:left].table} == #{r[:right].table}"
      if r[:result]
        out.puts "OK: #{expr}"
      else
        out.puts "NG: #{expr}"
        out.puts "      left: #{r[:left].table}"
        show_columns(r[:left].columns, out)
        out.puts "      right: #{r[:right].table}"
        show_columns(r[:right].columns, out)
      end
    end
    show_summary(results, out)
  end

  def self.show_columns(cols, out)
    cols.each do |col|
      out.puts "         #{col.to_s}"
    end
  end

  def self.show_summary(results, out)
    total = results.size
    ok = results.select { |r| r[:result] }.size
    ng = total - ok
    out.puts "TOTAL:#{total}, OK:#{ok}, NG:#{ng}"
  end

end
