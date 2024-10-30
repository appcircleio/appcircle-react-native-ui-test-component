require 'open3'
require 'os'

def env_has_key(key)
  !ENV[key].nil? && ENV[key] != '' ? ENV[key] : abort("Missing #{key}.")
end

$output_path = env_has_key("AC_OUTPUT_DIR")
$repo_path = env_has_key("AC_REPOSITORY_DIR")
$detox_configuration = env_has_key("AC_RN_DETOX_CONFIGURATION")

def run_command(command)
    puts "@@[command] #{command}"
    stdout_str = nil
    stderr_str = nil
    status = nil
  
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      stdout.each_line { |line| puts line }
      stdout_str = stdout.read
      stderr_str = stderr.read
      status = wait_thr.value
    end
  
    if status.success?
      return true, stdout_str
    else
      return false, stderr_str
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

    results.each_with_index do |(success, result), index|
      unless success
        abort("Command #{index + 1} failed: #{result}")
      end
    end
    puts "Tests completed successfully"
end

runTests()