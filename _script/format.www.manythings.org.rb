

class Formatter
  def format(lines)
    @raw_lines = lines
    @formatted_lines = []
    append_head
    format_body
    append_tail
    @formatted_lines
  end

  private
    def add_formatted_line(line)
      @formatted_lines << line
    end

    def append_head
      add_formatted_line "# The Making of a Nation"
      add_formatted_line ""
    end

    def format_body
      @episode_no = 1
      @in_quote = false
      @raw_lines.each_with_index do |line, index|
        if is_headline? index
          add_formatted_line format_headline(line)
        elsif is_blank? index or is_plain? index
          add_formatted_line line
        elsif is_quote? index
          add_formatted_line format_quote(line)
        else
          add_formatted_line format_episode(line)
          add_formatted_line ""
        end
      end
    end

    def is_headline?(index)
      not @raw_lines[index+1].nil? and @raw_lines[index+1].strip.empty?
    end

    def is_blank?(index)
      @raw_lines[index].strip.empty?
    end

    def is_plain?(index)
      @raw_lines[index].strip == "These are not included in the count at the top of the page."
    end

    def is_quote?(index)
      line = @raw_lines[index].strip

      if line.start_with? '"'
        @in_quote = true
      end

      quoted = @in_quote

      if line.end_with? '"'
        @in_quote = false
      end

      quoted
    end

    def format_headline(line)
      "## " + line
    end

    def format_quote(line)
      "> " + line
    end

    def format_episode(line)
      episode_line = ""
      if @episode_no < 252
        episode_line = "#{@episode_no}\\. #{line}"
        @episode_no += 1
      else
        episode_line = "* #{line}"
      end
      episode_line
    end

    def append_tail
      add_formatted_line ""
      add_formatted_line "This file was transformed from http://www.manythings.org/voa/history/ "
    end
end



def do_format(input, output)
  output_file = File.new(output, 'w')
  begin
    raw_lines = File.readlines input
    formatted_lines = Formatter.new.format raw_lines
    formatted_lines.each { |line| output_file.puts line }
  ensure
    output_file.close
  end
end

# main
input = "manythings.org.voa.history.raw"
output = "manythings.org.voa.history.md"
do_format input, output
