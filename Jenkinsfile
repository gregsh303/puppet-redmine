node ('sl6') {
  def workspace = pwd()
  try {
    git poll:true, credentialsId: '5eb69815-afdc-47ab-8ccf-d3ef271af6c1', url: 'git@gitlab.devops.geointservices.io:DevOps-InfraAsCode/Puppet-Redmine.git'
    stage 'Build Setup'
    withEnv(["GEM_HOME=${workspace}", "PATH=${workspace}/bin:$PATH"]) {
      sh 'gem install bundler'
      sh 'bundle install --deployment'

      stage 'Lint'
      sh 'bundle exec rake lint || true'

      stage 'Validate'
      sh 'bundle exec rake validate || true'

      stage 'Spec'
      sh 'bundle exec rake spec || true'
    }
    //stage 'Sonar'
    // TODO Make Sonar stage

    // Downstream job
    build job: 'DevOps-InfraAsCode/Puppet-Control/Control_test', wait: false
  } catch (err) {
    echo "Failed: ${err}"
    step([$class: 'Mailer', recipients: 'gshepherd@solidyn.com'])
    currentBuild.result = 'FAILURE'
  }
}
