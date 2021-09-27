def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")
# FILL YOUR CODE HERE.
def parse_dns(init)
  init = init.map(&:strip)
  init = init.reject { |line| line.empty? }
  init = init.reject { |line| line.start_with?("#") }
  #init = init.reject { |line| line.start_with?("$") }
  arr = init.map { |line| line.strip.split(", ") }
  arr = arr.reject { |record| record.length!= 3 }
  dns_records = arr.each_with_object({}) do |record, records| records[record[1]] =
    { type: record.first, target: record.last } end
    dns_records
end

def resolve(dns_records, lookup_chain, domain)
  rec = dns_records[domain]

  if (rec==nil)
    lookup_chain << "Error: Record not found for " + domain
    return lookup_chain
  end

  if (rec[:type] == "A")
    lookup_chain << rec[:target]
    return lookup_chain
  end

  if (rec[:type] == "CNAME")
    lookup_chain << rec[:target]
    resolve(dns_records, lookup_chain, rec[:target])
    return lookup_chain
  end

  lookup_chain << "Invalid record type for " + domain
  return lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
