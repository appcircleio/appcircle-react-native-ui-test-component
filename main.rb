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
$detox_params = get_env_variable("AC_RN_DETOX_ARGS")


$exit_status_code = 0
def run_command(command, skip_abort)
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
        puts stderr_str
        unless skip_abort
            exit 1
        end
        $exit_status_code = 1
    end
end

def runTests

    if OS.mac?
      run_command("brew tap wix/brew && brew install applesimutils", false)
    end 

    yarn_or_npm = "npm"
    if File.file?("#{$repo_path}/yarn.lock")
      yarn_or_npm = "yarn"
    end

    puts "Detox Configuration used is #{$detox_configuration}"

    run_command("cd #{$repo_path} && #{yarn_or_npm} detox clean-framework-cache", true)
    run_command("cd #{$repo_path} && #{yarn_or_npm} detox build-framework-cache --configuration #{$detox_configuration}", true)
    run_command("cd #{$repo_path} && #{yarn_or_npm} detox build --configuration #{$detox_configuration}", false)
    test_command = "detox test --configuration #{$detox_configuration} #{$detox_params}"

    run_command("cd #{$repo_path} && #{yarn_or_npm} #{test_command}", true)
    run_command("cp #{$repo_path}/test-reports/*-report.xml #{$output_path}", false)    
    run_command("cp -rp #{$repo_path}/artifacts/* #{$output_path}/test_attachments", false)     
    
    File.open(ENV['AC_ENV_FILE_PATH'], 'a') do |f|
       f.puts "AC_TEST_RESULT_PATH=#{$output_path}"
    end

    puts "Tests completed successfully"
end

runTests()
exit $exit_status_code