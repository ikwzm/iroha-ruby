require 'pp'
require_relative '../lib/iroha/builder/exp'

DEBUG=false

def test(target_file_name)
  parser   = Iroha::Builder::Exp::ExpParser.new
  original = `cat  #{target_file_name}`
  result   = parser.parse(original)
  if !result then
    puts parser.failure_reason
    puts "!!!! NG !!!! #{target_file_name}"
    return 1
  end
  root     = result.get
  result   = root.to_exp("")
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
Dir::glob("../examples/*.iroha").each do |target_file_name|
  error += test(target_file_name)
end
if error > 0 then
    puts "!!!! NG !!!! DONE"
else
    puts "==== OK ==== DONE"
end
