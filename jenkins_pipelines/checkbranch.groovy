//!groovy

// Integration steps to run on 29+
def integration(branch) {
    // Touch file to ensure the workspace dir exists..
    writeFile file: 'touch', text: 'me'

    def local_ci = "${env.JENKINS_HOME}/git_repositories/moodle_ci_site/local/ci"

    // Global variables.
    env.WORKSPACE = pwd()
    // Paths.
    env.composerdirbase = "${env.JENKINS_HOME}/composer_base"
    env.npmbase = "${env.JENKINS_HOME}/npm_base"
    // Hopefully we can get rid of these being required..
    env.phpcmd = "php"
    env.psqlcmd = "psql"
    env.mysqlcmd = "mysql"
    env.npmcmd = "npm"
    env.gitcmd = "git"
    env.composercmd = "composer"
    env.extrapath = "/usr/local"

    // Operate in $branch
    ws("git_repositories/${branch}") {
        stage 'Fetch changes'
        git  branch: "${branch}", url: 'git://git.moodle.org/integration.git'
        env.gitbranch = "${branch}"
        env.gitdir = pwd()

//        echo "Branch: ${env.GIT_BRANCH}"
//        echo "From: ${env.GIT_PREVIOUS_COMMIT}"
//        echo "To: ${env.GIT_COMMIT}"

//        stage 'Check for illegal whitespace'
//        sh "${local_ci}/illegal_whitespace/illegal_whitespace.sh"
//
//        stage 'Detect conflicts'
//        sh "${local_ci}/detect_conflicts/detect_conflicts.sh"
//
//        stage 'Check savepoints'
//        sh "${local_ci}/check_upgrade_savepoints/check_upgrade_savepoints.sh"
//
//        stage 'Check version.php files'
//        sh "${local_ci}/versions_check_set/versions_check_set.sh"
//
//        stage 'grunt'
//        sh "${local_ci}/grunt_process/grunt_process.sh"

        stage 'php -l'
        sh "${local_ci}/php_lint/php_lint.sh"

        // Start unit tests..
        // We don't actually  get newlines in the output here, but oh well!
        def extraconfig = \
        "\
        define('TEST_SESSION_REDIS_HOST', 'redis0');\
        define('TEST_SEARCH_SOLR_HOSTNAME', 'solr0');\
        define('TEST_SEARCH_SOLR_PORT', '8983');\
        define('TEST_SEARCH_SOLR_INDEXNAME', 'unittest');\
        "

        withEnv(['dblibrary=native', "extraconfig=${extraconfig}"]) {
            stage 'phpunit (postgres)'
            withEnv(['dbtype=pgsql', 'dbhost=pg0', 'dbuser=postgres', 'dbpass=moodle']) {
                sh "${local_ci}/run_phpunittests/run_phpunittests.sh"
            }

            stage 'phpunit (oracle)'
            withEnv(['dbtype=oci', "dbhost=oracle-${branch}", 'dbuser=system', 'dbpass=oracle']) {
                sh "${local_ci}/run_phpunittests/run_phpunittests.sh"
            }

            stage 'phpunit (mysql)'
            withEnv(['dbtype=mysqli', 'dbhost=mysql0', 'dbuser=root', 'dbpass=moodle', "extraconfig=${extraconfig}"]) {
                sh "${local_ci}/run_phpunittests/run_phpunittests.sh"
            }
        }

    }
}

return this;
