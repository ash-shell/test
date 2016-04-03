#!/bin/bash

Test__MODULE_TEST_FILE="test.sh"

##################################################
# This function will run the test.sh file located
# in the module passed in
#
# @param $1: The name of the module to test.  This
#   can either be the alias, or the full package
#   name.
#
# @returns $?: A 1 if any test has failed,
#   or a 0 if all tests have succeeded.
##################################################
Test__callable_main() {
    # Params
    local module_to_test="$1"

    # Get module directory
    local module_directory="$(Ash__find_module_directory "$module_to_test" "1")"
    if [[ "$module_directory" = "" ]]; then
        Logger__error "Module $module_to_test does not exist"
        return 1
    fi

    # Loading in name of module, as if Ash core loaded it
    Ash_load_callable_file "$module_to_test"
    Ash__import "$module_to_test" "1"

    # Load test file
    local test_file="$module_directory/$Test__MODULE_TEST_FILE"
    if [[ ! -f "$test_file" ]]; then
        Logger__error "There is no $Test__MODULE_TEST_FILE file in $module_to_test"
        return 1
    fi
    . $test_file

    # Loading in config
    local config="$module_directory/$Ash__CONFIG_FILENAME"
    if [[ ! -f "$config" ]]; then
        Logger__error "There is no $Ash__CONFIG_FILENAME file in $module_to_test"
        return 1
    fi
    eval $(YamlParse__parse "$config" "Test_module_config_")

    # Getting test prefix
    local test_prefix="$Test_module_config_test_prefix"
    local test_function_prefix="$test_prefix"__test_

    # Loading tests
    tests=$(declare -F | grep "$test_function_prefix" | sed 's/declare\ -f\ //g')

    # Call all methods
    local success="$Ash__TRUE"
    for t in $tests
    do
        local to_find="$test_prefix"__
        local test_name=$(echo "$t" | sed "s/$to_find//g")
        # Can't make this local, as I need to capture the exit status...
        # local itself has an exit status!
        test_output=$($t)
        if [[ $? -eq 0 ]]; then
            Test__print_green_check
            echo " $test_name"
        else
            success="$Ash__FALSE"
            Test__print_red_x
            echo " $test_name"

            # Log output, if any
            if [[ "$test_output" != "" ]]; then
                local red="\033[1;31m"
                local clear="\033[1;0m"
                test_output="$(Test__print_red_rightwards_arrow) $red$test_output$clear"
                test_output="$(echo "${test_output}" | sed "s/^/    /g")"
                test_output="$(echo "${test_output}" | awk '/^/{if (M!=""){sub("","    ")}else{M=1}}{print}')"
                echo -e "$test_output"
            fi
        fi
    done

    # Success
    if [[ "$success" = "$Ash__TRUE" ]]; then
        return 0
    else
        return 1
    fi
}

##################################################
# This function will download the most recent
# travis.yml file and set it in the current module.
#
# Fetches the most recent travis.yml file from:
# https://github.com/ash-shell/travis-buildpack
##################################################
Test__callable_travis() {
    file_location=$Ash__CALL_DIRECTORY/travis.yml
    if [[ ! -f "$file_location" ]]; then
        Logger__alert "Downloading most recent Buildpack..."
        curl https://raw.githubusercontent.com/ash-shell/travis-buildpack/master/travis.yml > "$file_location"
        if [[ $? -eq 0 ]]; then
            Logger__success "travis.yml file is set up in the current directory!"
        else
            Logger__error "Failed to download the most recent Buildpack... Check your network and try again."
            rm "$file_location"
        fi
    else
        Logger__error "There is already a travis.yml file located in the current directory"
    fi
}
