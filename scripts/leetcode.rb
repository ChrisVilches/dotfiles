#!/usr/bin/env ruby

require 'json'

def nested_number_array?(value)
  return false unless value.is_a?(Array)
  return false unless value.first.is_a?(Array)
  return false unless value.first.first.is_a?(Numeric)

  true
end

def nested_string_array?(value)
  return false unless value.is_a?(Array)
  return false unless value.first.is_a?(Array)
  return false unless value.first.first.is_a?(String)

  true
end

def get_type(value)
  return :number if value.is_a?(Numeric)
  # TODO: Misses the type "empty array"
  return :number_nested_array if nested_number_array?(value)
  return :number_array if value.is_a?(Array) && value.first.is_a?(Numeric)
  return :bool_array if value.is_a?(Array) && (value.first.is_a?(TrueClass) || value.first.is_a?(FalseClass))
  return :string_nested_array if nested_string_array?(value)
  return :string_array if value.is_a?(Array) && value.first.is_a?(String)
  return :string if value.is_a?(String)
  return :bool if [true, false].include?(value)

  raise "Invalid type: #{value.class} (#{value.inspect})"
end

def cpp_output_value(var_name, type)
  case type
  when :number
    "cout << #{var_name} << endl;"
  when :string
    "cout << #{var_name} << endl;"
  when :bool
    'cout << (res ? "true" : "false") << endl;'
  when :number_array
    "for (auto x : #{var_name}) { cout << x << ' '; }; cout << endl;"
  when :bool_array
    "for (auto x : #{var_name}) { cout << (x ? \"true\" : \"false\") << ' '; }; cout << endl;"
  when :string_array
    "for (auto x : #{var_name}) { cout << x << ' '; }; cout << endl;"
  when :string_nested_array
    "for(auto& row : #{var_name}) { for(auto x : row) { cout << x << ' ';}; cout<<endl;}"
  when :number_nested_array
    "for(auto& row : #{var_name}) { for(auto x : row) { cout << x << ' ';}; cout<<endl;}"
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
  when :string_nested_array
    str = value.to_s.gsub('[', '{').gsub(']', '}')
    "vector<vector<string>> #{var_name}#{str};"
  when :string_array
    str = value.to_s.gsub('[', '{').gsub(']', '}')
    "vector<string> #{var_name}#{str};"
  else
    raise "CPP cannot create value of type: #{type}"
  end
end

def expected_answer_to_plain_file(value)
  type = get_type(value)

  case type
  when :number
    value
  when :string
    value
  when :bool
    value ? 'true' : 'false'
  when :number_array
    value.join ' '
  when :bool_array
    value.join ' '
  when :string_array
    value.join ' '
  when :string_nested_array
    value.map { _1.join ' ' }.join "\n"
  when :number_nested_array
    value.map { _1.join ' ' }.join "\n"
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

def create_main_fn(data, method_name)
  raise 'Method name cannot be empty' if method_name.to_s.empty?

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

  # Extract method signature line (might contain '{' at end)
  sig_line = first_non_empty.strip
  # Remove everything after '{' if present
  sig_line = sig_line.split('{').first.strip if sig_line.include?('{')
  # Method name is before '('
  method_name = sig_line.split('(').first.split(' ').last

  # Extract parameter list between '(' and ')'
  if sig_line.include?('(') && sig_line.include?(')')
    param_list = sig_line.match(/\((.*?)\)/)[1]
    param_count = param_list.empty? ? 0 : param_list.count(',') + 1
  else
    param_count = 0
  end

  [method_name, param_count]
end

def parse_line(line)
  # Remove leading/trailing whitespace
  stripped = line.strip
  # Handle empty string (should not happen as blank lines filtered)
  return stripped if stripped.empty?

  # Parse as JSON (supports numbers, booleans, arrays, strings)
  JSON.parse(stripped)
rescue JSON::ParserError => e
  # If parsing fails, treat as string (but strings must be quoted per spec)
  raise "Invalid line format: #{line.inspect}. Must be valid JSON (numbers, booleans, arrays, quoted strings). Error: #{e.message}"
end

def parse_leet_file(config_path, target_program_path)
  content = File.read(config_path)
  lines = content.lines.map(&:chomp)

  blocks = []
  current_block = []
  in_block = false
  lines.each do |line|
    # Check for dash separator line (only dashes, at least 3)
    if line.strip == "---"
      raise "Dash separator line must have at least 3 dashes, got '#{line}'" if line.length < 3

      # Found dash separator
      if in_block
        # Finalize current block
        blocks << current_block unless current_block.empty?
        current_block = []
        in_block = false
      end
      next
    # elsif line =~ /-/
    #   # line contains dash but also other characters
    #   raise "Dash separator line contains non-dash characters: '#{line}'"
    end
    # Skip blank lines outside blocks? Actually blank lines inside blocks are ignored
    # We'll collect non-blank lines to define block boundaries
    if line.strip.empty?
      # Blank line, ignore
      next
    end

    # Non-blank line
    in_block ||= true
    current_block << line
  end
  # Add last block if any
  blocks << current_block unless current_block.empty?

  target_block = blocks.find { |block| block.first == target_program_path }
  raise "No block found for program #{target_program_path}" unless target_block

  # Parse block
  parse_leet_block(target_block)
end

def parse_leet_block(block_lines)
  # First line is program path (already matched)
  input_lines = []
  output_lines = []
  stage = :inputs # :inputs until '*', then :outputs
  block_lines[1..].each do |line|
    if line.strip == '*'
      stage = :outputs
      next
    end
    case stage
    when :inputs
      input_lines << line
    when :outputs
      output_lines << line
    end
  end

  # Validate we have both inputs and outputs
  raise "Missing '*' separator in block" if stage == :inputs
  raise "No output lines after '*'" if output_lines.empty?

  # Parse each line to Ruby objects
  inputs = input_lines.map { |ln| parse_line(ln) }
  outputs = output_lines.map { |ln| parse_line(ln) }

  # Now we need to group inputs by parameter count (caller must provide param_count)
  # This function returns raw inputs and outputs; grouping will be done elsewhere
  { inputs: inputs, outputs: outputs }
end

def group_test_cases(inputs, param_count, outputs)
  total_inputs = inputs.length
  total_outputs = outputs.length
  if param_count == 0
    # Each test case has zero parameters? Actually zero parameters means no inputs per test case.
    # In LeetCode, a method with zero parameters still has zero inputs per test case.
    # But there will be zero input lines? Probably there are zero input lines, but we still have outputs.
    # We'll assume inputs empty, each test case has zero inputs.
    # So number of test cases = total_outputs
    test_case_count = total_outputs
    raise "Number of inputs (#{total_inputs}) does not match zero parameters" unless total_inputs == 0
  else
    # Each test case has param_count inputs
    unless total_inputs % param_count == 0
      raise "Total inputs (#{total_inputs}) not divisible by param_count (#{param_count})"
    end

    test_case_count = total_inputs / param_count
  end
  unless total_outputs == test_case_count
    raise "Number of outputs (#{total_outputs}) does not match number of test cases (#{test_case_count})"
  end

  test_cases = []
  if param_count == 0
    test_case_count.times do |i|
      test_cases << { 'args' => [], 'expected' => outputs[i] }
    end
  else
    test_case_count.times do |i|
      start_idx = i * param_count
      args = inputs[start_idx, param_count]
      test_cases << { 'args' => args, 'expected' => outputs[i] }
    end
  end
  test_cases
end

def main
  config, program_path, cpp_code_output, plain_txt_expected_values = ARGV

  original_code = File.read(program_path)
  method_name, param_count = find_main_method_name(original_code)
  raise "Could not find method name in #{program_path}" unless method_name

  parsed = parse_leet_file(config, program_path)
  inputs = parsed[:inputs]
  outputs = parsed[:outputs]

  test_cases = group_test_cases(inputs, param_count, outputs)

  File.open(cpp_code_output, 'w') do |file|
    file.write("#{original_code}\n#{create_main_fn(test_cases, method_name)}")
  end

  File.open(plain_txt_expected_values, 'w') do |file|
    file.write(get_expected_answers(test_cases).join("\n"))
  end
end

main
