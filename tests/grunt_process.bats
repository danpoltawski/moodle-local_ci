#!/usr/bin/env bats

load libs/shared_setup


setup () {
    create_git_branch MOODLE_31_STABLE v3.1.0

    export extrapath=.
}

@test "grunt_process: normal" {
    cd $BATS_TEST_DIRNAME/../grunt_process/
    run ./grunt_process.sh
    assert_success
    assert_output --partial "Done, without errors."
    assert_output --partial "OK: All modules are perfectly processed by grunt"
}

@test "grunt_process: Uncommited .less change" {
    # Create css change.
    cd $gitdir
    $gitcmd am $BATS_TEST_DIRNAME/fixtures/31-grunt-less-unbuilt.patch

    # Run test
    cd $BATS_TEST_DIRNAME/../grunt_process/
    run ./grunt_process.sh

    # Assert result
    assert_failure
    assert_output --partial "Done, without errors." # Grunt shouldn't have an issue here.
    assert_output --partial "ERROR: Some modules are not properly processed by grunt. Changes detected:"
    assert_output --regexp "GRUNT-CHANGE: (.*)/theme/bootstrapbase/style/moodle.css"
}

@test "grunt_process: Uncommited .js change" {
    # Create js change.
    cd $gitdir
    $gitcmd am $BATS_TEST_DIRNAME/fixtures/31-grunt-js-unbuilt.patch

    # Run test
    cd $BATS_TEST_DIRNAME/../grunt_process/
    run ./grunt_process.sh

    # Assert result
    assert_failure
    assert_output --partial "Done, without errors." # Grunt shouldn't have an issue here.
    assert_output --partial "ERROR: Some modules are not properly processed by grunt. Changes detected:"
    assert_output --regexp "GRUNT-CHANGE: (.*)/lib/amd/build/url.min.js"
}
