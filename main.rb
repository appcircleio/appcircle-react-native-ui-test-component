require 'find'
require 'json'
require 'open3'

def env_has_key(key)
    return (ENV[key] == nil || ENV[key] == "") ? nil : ENV[key]
end

$output_path = env_has_key("AC_OUTPUT_DIR") || abort("Missing AC_OUTPUT_DIR.")
$repo_path = env_has_key("AC_REPOSITORY_DIR") || abort("Missing AC_REPOSITORY_DIR.")
$detox_configuration = env_has_key("AC_RN_DETOX_CONFIGURATION") || abort("Missing AC_RN_DETOX_CONFIGURATION.")

def run_command(command)
    puts "@@[command] #{command}"
    status = nil
    stdout_str = nil
    stderr_str = nil
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        stdout.each_line do |line|
            puts line
        end
        stdout_str = stdout.read
        stderr_str = stderr.read
        status = wait_thr.value
    end
  
    unless status.success?
        abort(stderr_str)
    end
end

def runTests
    run_command("brew tap wix/brew")
    run_command("brew install applesimutils")

    yarn_or_npm = "npm"
    if File.file?("#{$repo_path}/yarn.lock")
        yarn_or_npm = "yarn"
    end

    puts "Detox Configuration used is #{$detox_configuration}"

    run_command("cd #{$repo_path} && #{yarn_or_npm} detox clean-framework-cache")
    run_command("cd #{$repo_path} && #{yarn_or_npm} detox build-framework-cache --configuration #{$detox_configuration}")

    run_command("cd #{$repo_path} && #{yarn_or_npm} detox build --configuration #{$detox_configuration}")
    run_command("cd #{$repo_path} && #{yarn_or_npm} detox test --configuration #{$detox_configuration}")
    
    # copy test results to output directory for downloadable artifacts
    run_command("cp #{$repo_path}/test-reports/*-report.xml #{$output_path}")
    

    # Write AC_TEST_RESULT_PATH reserved variable to the ENV file for test report component
    File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
        f.puts "AC_TEST_RESULT_PATH=#{$output_path}"
    end
    
end


runTests()