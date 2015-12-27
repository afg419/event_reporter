require 'csv'

class EventReporter

  attr_reader :opened_file, :queue

  def find(column_name, row_value)
    @queue = opened_file.select do |row|
      cleanse(row[column_name.to_sym]) == cleanse(row_value)
    end
  end

  def cleanse(string)
    string.downcase.strip
  end

  def load(file = nil)
    file = "lib/event_attendees.csv" if file == ""
    csv_file = CSV.open(file, headers: true, header_converters: :symbol)
    @opened_file = csv_file.to_a.map(&:to_h)
  end

  def help(second_command)
    if second_command == ""
      available_methods.join("\n")
    else
      help_commands[second_command]
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
    second_command = commands[1..-1].join(" ")

    send(initial_command, second_command)
  end
end

# e = EventReporter.new
#
# loop do
#   x = gets
#   p x
#   e.ultimate_method(x)
# end
