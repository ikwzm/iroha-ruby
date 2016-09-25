require 'pp'
require_relative '../lib/iroha'
require_relative '../lib/iroha/builder/simple'

DEBUG=false

def test(target_file_name, original_file_name)
  original = `cat  #{original_file_name}`
  result   = `ruby #{target_file_name}`
  o = original.gsub(/\s+/, " ").gsub(/\s+\(/, " (").gsub(/\(\s*/, "(").gsub(/\s*\)/, ")").gsub(/\)\s*\(/, ") (").gsub(/\)\s*$/, ")")
  r = result.gsub(  /\s+/, " ").gsub(/\s+\(/, " (").gsub(/\(\s*/, "(").gsub(/\s*\)/, ")").gsub(/\)\s*\(/, ") (").gsub(/\)\s*$/, ")")
  if o != r then
    puts ">>>>"
    puts o
    puts "<<<<"
    puts r
    puts "!!!! NG !!!! #{target_file_name}"
    return 1
  else
    puts r if DEBUG == true
    puts "==== OK ==== #{target_file_name}"
    return 0
  end
end

error = 0
Dir::glob("../examples/*.rb").each do |target_file_name|
  original_file_name = target_file_name.gsub(/\.rb$/, ".iroha")
  error += test(target_file_name, original_file_name)
end
if error > 0 then
    puts "!!!! NG !!!! DONE"
else
    puts "==== OK ==== DONE"
end
