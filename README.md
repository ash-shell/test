# Test

Test is an [Ash](https://github.com/ash-shell/ash) module that offers easy unit testing, with simple CI integrations.

## Running Tests

You can run tests by running the following command:

```sh
ash test $module-to-test
```

Where `$module-to-test` is either a module alias, or a module package.

## Hooking Up a Module to Travis

You can generate the `.travis.yml` file by running the following command while in your modules directory:

```
ash test:travis
```

If your tests are already written, there is no further configuration you need to do beyond enabling your repository on Travis.

## Writing Tests

### The `ash_config.yaml` File

To get started with writing tests, you must first add a `test_prefix` key to your modules [ash_config.yaml](https://github.com/ash-shell/ash#ash_configyaml) file.

For example, if our module was named `Slugify`, we would add this line here:

```yaml
test_prefix: Slugify
```

### The `test.sh` File

Now that we're ready to start writing tests, we'll have to create the `test.sh` file at the root of our module.

> If you'd like to check out what a fully built test.sh file looks like before we jump in, check out [Slugify's](https://github.com/ash-shell/slugify/blob/master/test.sh)

In the `test.sh` file, you can create functions that start with `"$test_prefix"__test_`, and those will get run when we run our tests.

Following our previous example, if our module was named `Slugify`, the functions that we would want to test would have to start with `Slugify__test_"

When writing these functions, if at any point there is a failure you should return 1.  When everything succeeds don't return anything.

Here is a test from Slugify:

```sh
Slugify__test_slugify_spaces(){
    # Space in the middle of a sentence
    Slugify_test_single_slugify "Brandon Romano" "brandon-romano"
    if [[ $? -ne 0 ]]; then return 1; fi

    # Multiple Spaces
    Slugify_test_single_slugify "Radical   Ricky" "radical-ricky"
    if [[ $? -ne 0 ]]; then return 1; fi
}
```

## Conventions to Follow to Write Great Tests

Test provides some really great tools to help you write really great tests, but you should definitely follow a few conventions.

Before jumping into this section, I will provide a screenshot that displays what a test looks like (with a forced failure):

![Imgur](http://i.imgur.com/6d5HlX8.png)

> All that fancy indentation is handled for you

### Provide Concise Names for Tests

The name of your actual test method has to start with `"$test_prefix"__test_` by requirement, but anything after that is up for you to decide.

Your test names should describe the module you are testing, as the test name is used in the output of the tests.

For example, if we had a test `Slugify__test_slugify_spaces`, when running the test we would see `test_slugify_spaces` in both success and failure cases.

The names are very important, as this is the only piece of information we see during a successful run of a test (as you can see above).

### Provide a Fluent Failure Description

For a failing test, we should always provide a description of what went wrong.  The error message should be written for the context of the error message above (The first line with the unicode red arrow is the `Description`, the lines below it are the details).  These descriptions should be concise.

Failure descriptions are the first line that is echoed out in a test function.

For example:

```bash
Slugify__test_slugify_spaces(){
    local result="$(Slugify__slugify "Radical    Ricky")"
    if [[ "$result" != "radical-ricky" ]]; then
        # This line below is our failure description
        echo "Slugify__slugify should convert 'Radical    Ricky' into 'radical-ricky'
        return 1
    fi
}
```

### Provide Futher Details if Needed

I would argue that most of the time further details are actually needed.  Any additional lines echoed out are further details.

Following our previous example, we probably would want to know the _actual_ result of the output if it weren't what we were expecting:

```bash
Slugify__test_slugify_spaces(){
    local result="$(Slugify__slugify "Radical    Ricky")"
    if [[ "$result" != "radical-ricky" ]]; then
        # This line below is our failure description
        echo "Slugify__slugify should convert 'Radical    Ricky' into 'radical-ricky'
        # This lines below are our failure details.  We can have as many (or as little) of these as we want
        echo "Actual Result: '$result'"
        echo "Wow, another detail!"
        return 1
    fi
}
```

## License

[MIT](LICENSE.md)
