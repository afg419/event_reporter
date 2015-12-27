require 'csv'
require 'terminal-table'

class EventReporter

  attr_reader :opened_file, :current_queue

  def find(column_name_and_row_value)
    column_name, row_value = column_name_and_row_value
    @current_queue = opened_file.select do |row|
      cleanse(row[column_name.to_sym]) == cleanse(row_value)
    end
  end

  def queue(secondary_commands)
    second_command = secondary_commands[0]
    case second_command
    when "count"
      current_queue.count
    when "clear"
      @current_queue = []
    when "print"
      print_table
    end
  end

  def print_table
    rows = @current_queue.map do |row|
      row.values[2..-1]
    end
    rows.unshift(:separator)
    headers = ["FIRST NAME","LAST NAME","EMAIL","PHONE","CITY","STATE","ADDRESS","ZIPCODE"]
    rows.unshift(headers)

    puts Terminal::Table.new :rows => rows
  end

  def cleanse(string)
    string.downcase.strip
  end

  def load(file = nil)
    file = file[0]
    file = "lib/event_attendees.csv" if file.nil?
    csv_file = CSV.open(file, headers: true, header_converters: :symbol)
    @opened_file = csv_file.to_a.map(&:to_h)
  end

  def help(secondary_commands)
    help_query = secondary_commands.join(" ")
    if help_query == ""
      available_methods.join("\n")
    else
      help_commands[help_query]
    end
  end

  def help_commands
    available_methods.zip(
    ["outputs a description of how to use <command>.",
      "erase any loaded data and parse <filename>.  If no filename given default to event_attendees.csv.",
      "output number of records in current queue.",
      "empty the queue.",
      "print out a tab delimited data table.",
      "print the data table sorted by <attribute>.",
      "export current queue to <filename> as csv.",
      "load the queue with all records matching <criteria> for <attribute>."
    ]).to_h
  end

  def available_methods
    ["help <command>",
    "load <filename>",
    "queue count",
    "queue clear",
    "queue print",
    "queue print by <attribute>",
    "queue save to <filename.csv>",
    "find <attribute> <criteria>"]
  end

  def ultimate_method(cli_input)
    commands = cli_input.split

    initial_command = commands.first
    secondary_commands = commands[1..-1]

    send(initial_command, secondary_commands)
  end
end

# e = EventReporter.new
#
# loop do
#   x = gets
#   p x
#   e.ultimate_method(x)
# end
