Test__MODULE_TEST_FILE="test.sh"

##################################################
# This function is an alias for `ash self:help`.
#
# @param $1: The name of the module to test
##################################################
Test__callable_main() {
    # Params
    local module_to_test="$1"

    # Get module directory
    local module_directory="$(Ash__find_module_directory "$module_to_test" "1")"
    if [[ "$module_directory" = "" ]]; then
        Logger__error "Module $module_to_test does not exist"
        return
    fi

    # Loading in name of module, as if Ash core loaded it
    Ash_load_callable_file "$module_to_test"
    Ash__import "$module_to_test" "1"

    # Load test file
    local test_file="$module_directory/$Test__MODULE_TEST_FILE"
    if [[ ! -f "$test_file" ]]; then
        Logger__error "There is no $Test__MODULE_TEST_FILE file in $module_to_test"
        return
    fi
    . $test_file

    # Loading in config
    local config="$module_directory/$Ash__CONFIG_FILENAME"
    if [[ ! -f "$config" ]]; then
        Logger__error "There is no $Ash__CONFIG_FILENAME file in $module_to_test"
        return
    fi
    eval $(YamlParse__parse "$config" "Test_module_config_")

    # Getting test prefix
    local test_prefix="$Test_module_config_test_prefix"
    local test_function_prefix="$test_prefix"__test_

    # Loading tests
    tests=$(declare -F | grep "$test_function_prefix" | sed 's/declare\ -f\ //g')

    # Call all methods
    local success="$Ash__TRUE"
    local to_find="$test_prefix"__
    for t in $tests
    do
        local test_name=$(echo "$t" | sed "s/$to_find//g")
        Logger__alert "Running $test_name... " -n

        test_output=$($t) # Can't make this local, as I need to capture the exit status!
        if [[ $? -eq 0 ]]; then
            Test__print_green_check
        else
            success="$Ash__FALSE"
            Test__print_red_x

            # Log output, if any
            if [[ "$test_output" != "" ]]; then
                echo -n "    "
                Test__print_red_rightwards_arrow
                echo -n " "
                echo -ne '\033[1;31m'
                echo "${test_output}"
                echo -ne '\033[1;0m'
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
