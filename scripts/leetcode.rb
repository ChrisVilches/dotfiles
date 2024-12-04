#!/usr/bin/env ruby

require 'yaml'

def nested_number_array?(value)
  return false unless value.is_a?(Array)
  return false unless value.first.is_a?(Array)
  return false unless value.first.first.is_a?(Numeric)

  true
end

def get_type(value)
  return :number if value.is_a?(Numeric)
  # TODO: Misses the type "empty array"
  return :number_nested_array if nested_number_array?(value)
  return :number_array if value.is_a?(Array) && value.first.is_a?(Numeric)
  return :string if value.is_a?(String)
  return :bool if [true, false].include?(value)

  raise "Invalid type: #{value.class} (#{value.inspect})"
end

def cpp_output_value(var_name, type)
  case type
  when :number
    "cout << #{var_name} << endl;"
  # when :string
  #   "cout << "#{var_name}" << endl;"
  when :bool
    'cout << (res ? "true" : "false") << endl;'

  when :number_array
    "for (auto x : #{var_name}) { cout << x << ' '; }; cout << endl;"
  else
    raise "CPP cannot output type: #{type}"
  end
end

def cpp_arg_definition(var_name, value)
  type = get_type(value)

  case type
  when :number
    "int #{var_name} = #{value};"
  when :string
    "string #{var_name} = \"#{value}\";"
  # when :bool
  #   "cout << "#{value ? 'true' : 'false'}" << endl;"
  when :number_nested_array
    str = value.to_s.gsub('[', '{').gsub(']', '}')
    "vector<vector<int>> #{var_name}#{str};"
  when :number_array
    str = value.to_s.gsub('[', '{').gsub(']', '}')
    "vector<int> #{var_name}#{str};"
  else
    raise "CPP cannot create value of type: #{type}"
  end
end

def expected_answer_to_plain_file(value)
  type = get_type(value)

  case type
  when :number
    value
  # when :string
  #   "cout << "#{value}" << endl;"
  when :bool
    value ? 'true' : 'false'
  when :number_array
    value.join ' '
  else
    raise "Cannot serialize type to plain file: #{type}"
  end
end

def test_case_to_s(method_name, test_case)
  arg_names = test_case['args'].map.with_index do |_, idx|
    "arg_#{idx}"
  end

  args = test_case['args'].map.with_index do |arg, idx|
    cpp_arg_definition(arg_names[idx], arg)
  end

  call = "Solution().#{method_name}(#{arg_names.join(', ')})"

  output = cpp_output_value('res', get_type(test_case['expected']))
  "{\n#{args.join("\n")}\nauto res = #{call};\n#{output}\n}"
end

def create_main_fn(data, original_code)
  method_name_key = 'method_name'
  # method_name = data[method_name_key] || find_main_method_name(original_code)
  # TODO: Due to the current yaml structure, now it's not possible to add the method_name
  # (without doing a major structure revamp), so it relies 100% on this heuristic method.
  # Maybe a hack is to add the key like this:
  # leetcode/program_path.cpp#method_name
  # It'd work, it just wouldn't be very idiomatic.
  method_name = find_main_method_name(original_code)

  raise "Could not find main method (add it manually with the key #{method_name_key})" if method_name.to_s.empty?

  all_test_cases_str = data.map do |test_case|
    test_case_to_s(method_name, test_case)
  end.join("\n")

  "int main() {\n#{all_test_cases_str}\n}"
end

def get_expected_answers(data)
  data.map do |test_case|
    expected_answer_to_plain_file test_case['expected']
  end
end

def find_main_method_name(code)
  lines = code.split("\n")
  idx = lines.find_index { _1.strip.start_with?('public:') }

  return if idx.nil?

  lines_after_public = lines[(idx + 1)..]
  first_non_empty = lines_after_public.find { !_1.strip.empty? }

  return if first_non_empty.nil?

  left = first_non_empty.split('(').first

  left.split(' ').last
end

def main
  config, program_path, cpp_code_output, plain_txt_expected_values = ARGV

  original_code = File.read(program_path)
  data = YAML.load_file(config)

  File.open(cpp_code_output, 'w') do |file|
    file.write("#{original_code}\n#{create_main_fn(data[program_path], original_code)}")
  end

  File.open(plain_txt_expected_values, 'w') do |file|
    file.write(get_expected_answers(data[program_path]).join("\n"))
  end
end

main
