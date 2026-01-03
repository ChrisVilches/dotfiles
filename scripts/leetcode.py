#!/usr/bin/env python3

import json
import sys
import re


# Checks if a value is a nested array of numbers (list of lists of int/float)
# Parameters: value - any Python object
# Returns: True if value is a non-empty list of non-empty lists of numbers, False otherwise
def nested_number_array(value):
    if not isinstance(value, list):
        return False
    if not value or not isinstance(value[0], list):
        return False
    if not value[0] or not isinstance(value[0][0], (int, float)):
        return False
    return True


# Checks if a value is a nested array of strings (list of lists of str)
# Parameters: value - any Python object
# Returns: True if value is a non-empty list of non-empty lists of strings, False otherwise
def nested_string_array(value):
    if not isinstance(value, list):
        return False
    if not value or not isinstance(value[0], list):
        return False
    if not value[0] or not isinstance(value[0][0], str):
        return False
    return True


# Determines the type of a value for LeetCode test case classification
# Parameters: value - any Python object (int, float, str, bool, list of numbers, list of strings, etc.)
# Returns: string representing the type ('number', 'string', 'bool', 'number_array', 'bool_array',
#          'string_array', 'number_nested_array', 'string_nested_array')
# Raises: ValueError if the type is not recognized
def get_type(value):
    if isinstance(value, (int, float)):
        return 'number'
    if nested_number_array(value):
        return 'number_nested_array'
    if isinstance(value, list) and value and isinstance(value[0], (int, float)):
        return 'number_array'
    if isinstance(value, list) and value and isinstance(value[0], bool):
        return 'bool_array'
    if nested_string_array(value):
        return 'string_nested_array'
    if isinstance(value, list) and value and isinstance(value[0], str):
        return 'string_array'
    if isinstance(value, str):
        return 'string'
    if isinstance(value, bool):
        return 'bool'
    raise ValueError(f"Invalid type: {type(value)} ({repr(value)})")


# Generates C++ code to output a variable of a given type
# Parameters: var_name - string name of variable to output
#             type_ - string type identifier (as returned by get_type)
# Returns: C++ statement(s) as a string that prints the variable to cout
# Raises: ValueError if the type is not supported for output
def cpp_output_value(var_name, type_):
    mapping = {
        'number': f'cout << {var_name} << endl;',
        'string': f'cout << {var_name} << endl;',
        'bool': 'cout << (res ? "true" : "false") << endl;',
        'number_array': f'for (auto x : {var_name}) {{ cout << x << \' \'; }}; cout << endl;',
        'bool_array': f'for (auto x : {var_name}) {{ cout << (x ? "true" : "false") << \' \'; }}; cout << endl;',
        'string_array': f'for (auto x : {var_name}) {{ cout << x << \' \'; }}; cout << endl;',
        # TODO: Not sure if this would throw compilation error because it's copying "x" instead
        # of using references.
        'string_nested_array': f'for(auto& row : {var_name}) {{ for(auto x : row) {{ cout << x << \' \';}}; cout<<endl;}}',
        'number_nested_array': f'for(auto& row : {var_name}) {{ for(auto x : row) {{ cout << x << \' \';}}; cout<<endl;}}',
    }
    if type_ not in mapping:
        raise ValueError(f"CPP cannot output type: {type_}")
    return mapping[type_]


# Generates C++ variable definition and initialization for a given value
# Parameters: var_name - string name of variable to define
#             value - Python value (int, float, str, bool, list, etc.)
# Returns: C++ statement as a string that defines and initializes the variable
# Raises: ValueError if the type is not supported for C++ definition
def cpp_arg_definition(var_name, value):
    type_ = get_type(value)
    if type_ == 'number':
        return f'int {var_name} = {value};'
    if type_ == 'string':
        return f'string {var_name} = "{value}";'
    if type_ == 'number_nested_array':
        s = str(value).replace('[', '{').replace(']', '}')
        return f'vector<vector<int>> {var_name}{s};'
    if type_ == 'number_array':
        s = str(value).replace('[', '{').replace(']', '}')
        return f'vector<int> {var_name}{s};'
    if type_ == 'string_nested_array':
        s = json.dumps(value).replace('[', '{').replace(']', '}')
        return f'vector<vector<string>> {var_name}{s};'
    if type_ == 'string_array':
        s = json.dumps(value).replace('[', '{').replace(']', '}')
        return f'vector<string> {var_name}{s};'
    raise ValueError(f"CPP cannot create value of type: {type_}")


# Converts an expected answer value to plain text format for file output
# Parameters: value - Python value (int, float, str, bool, list, etc.)
# Returns: string representation suitable for plain text file (spaces for arrays, newlines for nested arrays)
# Raises: ValueError if the type cannot be serialized
def expected_answer_to_plain_file(value):
    type_ = get_type(value)
    if type_ == 'number':
        return str(value)
    if type_ == 'string':
        return value
    if type_ == 'bool':
        return 'true' if value else 'false'
    if type_ == 'number_array':
        return ' '.join(str(x) for x in value)
    if type_ == 'bool_array':
        return ' '.join('true' if x else 'false' for x in value)
    if type_ == 'string_array':
        return ' '.join(value)
    if type_ == 'string_nested_array':
        return '\n'.join(' '.join(row) for row in value)
    if type_ == 'number_nested_array':
        return '\n'.join(' '.join(str(x) for x in row) for row in value)
    raise ValueError(f"Cannot serialize type to plain file: {type_}")


# Converts a single test case to C++ code block
# Parameters: method_name - string name of the method to call
#             test_case - dict with 'args' list and 'expected' value
# Returns: C++ code block as a string that defines arguments, calls method, and prints result
def test_case_to_s(method_name, test_case):
    arg_names = [f'arg_{idx}' for idx in range(len(test_case['args']))]
    args = [cpp_arg_definition(arg_names[idx], arg)
            for idx, arg in enumerate(test_case['args'])]
    call = f'Solution().{method_name}({", ".join(arg_names)})'
    output = cpp_output_value('res', get_type(test_case['expected']))
    return f"{{\n{chr(10).join(args)}\nauto res = {call};\n{output}\n}}"


# Creates the main() function C++ code that runs all test cases
# Parameters: data - list of test case dicts
#             method_name - string name of the method to test
# Returns: C++ main function as a string
def create_main_fn(data, method_name):
    if not method_name:
        raise ValueError('Method name cannot be empty')
    all_test_cases_str = '\n'.join(
        test_case_to_s(method_name, tc) for tc in data)
    return f'int main() {{\n{all_test_cases_str}\n}}'


# Converts all expected answers in test data to plain text format
# Parameters: data - list of test case dicts
# Returns: list of strings, each being the plain text representation of expected answer
def get_expected_answers(data):
    return [expected_answer_to_plain_file(tc['expected']) for tc in data]


# Extracts the method name and parameter count from C++ Solution class code
# Parameters: code - string containing C++ code with a class Solution
# Returns: tuple (method_name, param_count) or None if no public method found
def find_main_method_name(code):
    lines = code.split('\n')
    try:
        idx = next(i for i, line in enumerate(lines)
                   if line.strip().startswith('public:'))
    except StopIteration:
        return None
    lines_after_public = lines[idx + 1:]
    first_non_empty = next(
        (line for line in lines_after_public if line.strip()), None)
    if not first_non_empty:
        return None
    sig_line = first_non_empty.strip()
    if '{' in sig_line:
        sig_line = sig_line.split('{')[0].strip()
    method_name = sig_line.split('(')[0].split()[-1]
    # param count: count commas in the public block's first method signature up to ')'
    # This is a simplification; may need to parse better
    public_block = code.split('public:')[1]
    # Find the first method signature up to ')'
    first_paren = public_block.find(')')
    if first_paren == -1:
        param_count = 0
    else:
        signature = public_block[:first_paren]
        param_count = signature.count(',') + 1 if signature.strip() else 0
    return method_name, param_count


# Parses a single line from LeetCode config file as JSON
# Parameters: line - string line from config file
# Returns: parsed Python value (int, float, str, bool, list, etc.), empty string if line is empty
# Raises: ValueError if line is not valid JSON
def parse_line(line):
    stripped = line.strip()
    if not stripped:
        return stripped
    try:
        return json.loads(stripped)
    except json.JSONDecodeError as e:
        raise ValueError(
            f'Invalid line format: {line!r}. Must be valid JSON (numbers, booleans, arrays, quoted strings). Error: {e}')


# Parses LeetCode config file to extract test inputs and outputs for a specific program
# Parameters: config_path - path to config file (e.g., leet.txt)
#             target_program_path - path identifier (e.g., 'leetcode/another-problem.cpp')
# Returns: dict with 'inputs' and 'outputs' lists parsed from the config file
# Raises: ValueError if target program block not found or parsing fails
def parse_leet_file(config_path, target_program_path):
    with open(config_path, 'r') as f:
        content = f.read()
    lines = [ln.rstrip('\n') for ln in content.splitlines()]
    blocks = []
    current_block = []
    for line in lines:
        line_stripped = line.strip()
        if not line_stripped:
            continue
        if line_stripped.startswith('leetcode/'):
            if current_block:
                blocks.append(current_block)
            current_block = [line_stripped]
        else:
            current_block.append(line_stripped)
    if current_block:
        blocks.append(current_block)
    target_block = None
    for block in blocks:
        if block[0] == target_program_path:
            target_block = block
            break
    if not target_block:
        raise ValueError(f"No block found for program {target_program_path}")
    return parse_leet_block(target_block)


# Parses a single block of LeetCode config lines (program path, inputs, outputs)
# Parameters: block_lines - list of strings representing a block (first line is program path)
# Returns: dict with 'inputs' and 'outputs' lists parsed from the block
# Raises: ValueError if missing separator '*' or no outputs
def parse_leet_block(block_lines):
    # First line is program path (already matched)
    input_lines = []
    output_lines = []
    stage = 'inputs'  # 'inputs' until '*', then 'outputs'
    for line in block_lines[1:]:
        if line.strip() == '*':
            stage = 'outputs'
            continue
        if stage == 'inputs':
            input_lines.append(line)
        else:
            output_lines.append(line)
    if stage == 'inputs':
        raise ValueError("Missing '*' separator in block")
    if not output_lines:
        raise ValueError("No output lines after '*'")
    inputs = [parse_line(ln) for ln in input_lines]
    outputs = [parse_line(ln) for ln in output_lines]
    return {'inputs': inputs, 'outputs': outputs}


# Groups flat input and output lists into structured test cases based on parameter count
# Parameters: inputs - flat list of input values
#             param_count - number of parameters the method expects
#             outputs - list of expected output values
# Returns: list of dicts with 'args' (list of arguments) and 'expected' (expected value)
# Raises: ValueError if input/output counts are inconsistent with param_count
def group_test_cases(inputs, param_count, outputs):
    total_inputs = len(inputs)
    total_outputs = len(outputs)
    if param_count == 0:
        test_case_count = total_outputs
        if total_inputs != 0:
            raise ValueError(
                f"Number of inputs ({total_inputs}) does not match zero parameters")
    else:
        if total_inputs % param_count != 0:
            raise ValueError(
                f"Total inputs ({total_inputs}) not divisible by param_count ({param_count})")
        test_case_count = total_inputs // param_count
    if total_outputs != test_case_count:
        raise ValueError(
            f"Number of outputs ({total_outputs}) does not match number of test cases ({test_case_count})")
    test_cases = []
    if param_count == 0:
        for i in range(test_case_count):
            test_cases.append({'args': [], 'expected': outputs[i]})
    else:
        for i in range(test_case_count):
            start_idx = i * param_count
            args = inputs[start_idx:start_idx + param_count]
            test_cases.append({'args': args, 'expected': outputs[i]})
    return test_cases


# Main entry point: reads config and C++ program, generates test driver and expected values
# Expects four command-line arguments: config file, program path, output C++ file, output plain text file
# Reads the C++ Solution class, extracts method name and parameter count, parses test data,
# generates C++ test driver code, and writes expected values to a plain text file.
def main():
    if len(sys.argv) != 5:
        print('Usage: leetcode.py config program_path cpp_code_output plain_txt_expected_values')
        sys.exit(1)
    config, program_path, cpp_code_output, plain_txt_expected_values = sys.argv[1:]
    with open(program_path, 'r') as f:
        original_code = f.read()
    method_name_param = find_main_method_name(original_code)
    if not method_name_param:
        raise ValueError(f"Could not find method name in {program_path}")
    method_name, param_count = method_name_param
    parsed = parse_leet_file(config, program_path)
    inputs = parsed['inputs']
    outputs = parsed['outputs']
    test_cases = group_test_cases(inputs, param_count, outputs)
    with open(cpp_code_output, 'w') as f:
        f.write(f"{original_code}\n{create_main_fn(test_cases, method_name)}")
    with open(plain_txt_expected_values, 'w') as f:
        f.write('\n'.join(get_expected_answers(test_cases)))


if __name__ == '__main__':
    main()
