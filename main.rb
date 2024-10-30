require 'open3'
require 'os'

def get_env_variable(key)
  return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

def env_has_key(key)
  value = get_env_variable(key)
	return value unless value.nil? || value.empty?

	abort("Input #{key} is missing.")
end

$output_path = env_has_key("AC_OUTPUT_DIR")
$repo_path = env_has_key("AC_REPOSITORY_DIR")
$detox_configuration = env_has_key("AC_RN_DETOX_CONFIGURATION")

def run_command(command)
  puts "@@[command] #{command}"
  stdout_str, stderr_str, status = Open3.capture3(command)

  if status.success?
    puts stdout_str unless stdout_str.empty?
    puts stderr_str unless stderr_str.empty?
    return stderr_str.empty? ? stdout_str : stderr_str
  else
    return stderr_str
  end
end

def runTests

    if OS.mac?
      run_command("brew tap wix/brew && brew install applesimutils")
    end 

    yarn_or_npm = "npm"
    if File.file?("#{$repo_path}/yarn.lock")
      yarn_or_npm = "yarn"
    end

    puts "Detox Configuration used is #{$detox_configuration}"

    run_command("cd #{$repo_path} && #{yarn_or_npm} detox clean-framework-cache")
    run_command("cd #{$repo_path} && #{yarn_or_npm} detox build-framework-cache --configuration #{$detox_configuration}")
    run_command("cd #{$repo_path} && #{yarn_or_npm} detox build --configuration #{$detox_configuration}")
    run_command("cd #{$repo_path} && #{yarn_or_npm} detox test --configuration #{$detox_configuration} --take-screenshots all")
    run_command("cp #{$repo_path}/test-reports/*-report.xml #{$output_path}")    
    run_command("cp -rp #{$repo_path}/artifacts/* #{$output_path}/test_attachments")     
    
    File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
       f.puts "AC_TEST_RESULT_PATH=#{$output_path}"
    end

    puts "Tests completed successfully"
end

runTests()