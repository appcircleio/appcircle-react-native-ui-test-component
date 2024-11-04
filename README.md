# Appcircle React Native UI Test Component

Run React Native UI tests with Detox.

## Required Input Variables

- `$AC_REPOSITORY_DIR`: Specifies the cloned repository directory.
- `$AC_OUTPUT_DIR`: Specify the output directory for test results.
- `$AC_RN_DETOX_CONFIGURATION`: Specify the Detox configuration name to used when building and running the tests.

## Optional Input Variables

- `$AC_RN_DETOX_ARGS`: Specify the Detox extra arguments to add the test command. The arguments will be executed by appending `detox test --configuration<configname>` to the end of the command. For more information, see the Detox test [CLI options](https://wix.github.io/Detox/docs/19.x/api/detox-cli/#test).

## Output Variables

- `$AC_TEST_RESULT_PATH`: Path to the test result file.