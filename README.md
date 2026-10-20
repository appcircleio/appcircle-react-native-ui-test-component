# Appcircle React Native UI Test Component

Run React Native UI tests with Detox.

## Required Input Variables

- `$AC_REPOSITORY_DIR`: Specifies the cloned repository directory.
- `$AC_OUTPUT_DIR`: Specify the output directory for test results.
- `$AC_RN_DETOX_CONFIGURATION`: Specify the Detox configuration name to used when building and running the tests.

## applesimutils

On macOS the step needs [applesimutils](https://github.com/wix/AppleSimulatorUtils). If it is on `PATH` (for example installed in the runner image), the step uses it; otherwise it installs it with `brew tap wix/brew && brew install applesimutils`, which needs internet access.

## Package manager

The step runs the Detox CLI with `yarn` if the repository has a `yarn.lock`, and with `npx` otherwise.

## Optional Input Variables

- `$AC_RN_DETOX_ARGS`: Specify the Detox extra arguments to add the test command. The arguments will be executed by appending `detox test --configuration<configname>` to the end of the command. For more information, see the Detox test [CLI options](https://wix.github.io/Detox/docs/19.x/api/detox-cli/#test).

## Output Variables

- `$AC_TEST_RESULT_PATH`: Path to the test result file.