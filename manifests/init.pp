# = Class: redmine
#
# This is the main redmine class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, redmine class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $redmine_myclass
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, redmine main config file will have the param: source => $source
#   Can be defined also by the (top scope) variable $redmine_source
#
# [*source_dir*]
#   If defined, the whole redmine configuration directory content is retrieved
#   recursively from the specified source
#   (source => $source_dir , recurse => true)
#   Can be defined also by the (top scope) variable $redmine_source_dir
#
# [*source_dir_purge*]
#   If set to true (default false) the existing configuration directory is
#   mirrored with the content retrieved from source_dir
#   (source => $source_dir , recurse => true , purge => true)
#   Can be defined also by the (top scope) variable $redmine_source_dir_purge
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, redmine main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   Can be defined also by the (top scope) variable $redmine_template
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $redmine_options
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $redmine_absent
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $redmine_audit_only
#   and $audit_only
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: false
#
# Default class params - As defined in redmine::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*config_dir*]
#   Main configuration directory. Used by puppi
#
# [*config_file*]
#   Main configuration file path
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include redmine"
# - Call redmine as a parametrized class
#
# See README for details.
#
#
class redmine (
  $db_type             = params_lookup( 'db_type' ),
  $db_adapter          = params_lookup( 'db_adapter' ),
  $db_name             = params_lookup( 'db_name' ),
  $db_user             = params_lookup( 'db_user' ),
  $db_password         = params_lookup( 'db_password' ),
  $db_host             = params_lookup( 'db_host' ),
  $webserver_type      = params_lookup( 'webserver_type' ),
  $vhost_template      = params_lookup( 'vhost_template' ),
  $server_name         = params_lookup( 'server_name' ),
  $template_passenger  = params_lookup( 'template_passenger' ),
  $ssl                 = params_lookup( 'ssl' ),
  $ssl_protocol        = params_lookup( 'ssl_protocol' ),
  $ssl_cipher_suite    = params_lookup( 'ssl_cipher_suite' ),
  $ssl_cert            = params_lookup( 'ssl_cert' ),
  $ssl_cert_src        = params_lookup( 'ssl_cert_src' ),
  $ssl_cert_key        = params_lookup( 'ssl_cert_key' ),
  $ssl_cert_key_src    = params_lookup( 'ssl_cert_key_src' ),
  $ssl_ca_cert_chain   = params_lookup( 'ssl_ca_cert_chain' ),
  $ssl_ca_cert         = params_lookup( 'ssl_ca_cert' ),
  $ssl_ca_cert_src     = params_lookup( 'ssl_ca_cert_src' ),
  $ssl_ca_cert_chain   = params_lookup( 'ssl_ca_cert_chain' ),
  $ssl_ca_cert_chain_src = params_lookup( 'ssl_ca_cert_chain_src' ),
  $install_dir         = params_lookup( 'install_dir' ),
  $install_deps        = params_lookup( 'install_deps' ),
  $smtp_domain         = params_lookup( 'smtp_domain' ),
  $smtp_server         = params_lookup( 'smtp_server' ),
  $plugins             = params_lookup( 'plugins' ),
  $version             = params_lookup( 'version' ),
  $ruby_version        = params_lookup( 'ruby_version' ),
  $passenger_version   = params_lookup( 'passenger_version' ),
  $owner               = params_lookup( 'owner' ),
  $group               = params_lookup( 'group' ),
  $my_class            = params_lookup( 'my_class' ),
  $source              = params_lookup( 'source' ),
  $source_dir          = params_lookup( 'source_dir' ),
  $source_dir_purge    = params_lookup( 'source_dir_purge' ),
  $template            = params_lookup( 'template' ),
  $db_template         = params_lookup( 'db_template' ),
  $options             = params_lookup( 'options' ),
  $absent              = params_lookup( 'absent' ),
  $audit_only          = params_lookup( 'audit_only' , 'global' ),
  $noops               = params_lookup( 'noops' ),
  $config_dir          = params_lookup( 'config_dir' ),
  $config_file         = params_lookup( 'config_file' )
  ) inherits redmine::params {

  $config_file_mode=$redmine::params::config_file_mode
  $config_file_owner=$redmine::params::config_file_owner
  $config_file_group=$redmine::params::config_file_group

  $bool_source_dir_purge=any2bool($source_dir_purge)
  $bool_absent=any2bool($absent)
  $bool_audit_only=any2bool($audit_only)
  $bool_noops=any2bool($noops)

  ### Definition of some variables used in the module
  $manage_file = $redmine::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $redmine::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $redmine::bool_audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $redmine::source ? {
    ''        => undef,
    default   => $redmine::source,
  }

  $manage_file_content = $redmine::template ? {
    ''        => undef,
    default   => template($redmine::template),
  }

  $manage_db_file_content = $redmine::db_template ? {
    ''        => undef,
    default   => template($redmine::db_template),
  }

  ### Managed resources
  user { $redmine::owner:
    ensure     => 'present',
    home       => $redmine::install_dir,
    managehome => true,
    shell      => "/bin/bash",
  }

  $src_url = "${redmine::install_url_base}/redmine-${redmine::version}.tar.gz"
  puppi::netinstall { 'redmine':
    url             => $src_url,
    destination_dir => $redmine::install_dir,
    owner           => $redmine::owner,
    group           => $redmine::group,
    require         => User[$redmine::owner],
  }
  file { 'redmine_link':
    ensure  => 'link',
    target  => "${redmine::install_dir}/redmine-${redmine::version}",
    path    => "${redmine::install_dir}/redmine",
    require => Puppi::Netinstall['redmine'],
  }

  file { 'redmine.conf':
    ensure  => $redmine::manage_file,
    path    => $redmine::config_file,
    mode    => $redmine::config_file_mode,
    owner   => $redmine::config_file_owner,
    group   => $redmine::config_file_group,
    require => File['redmine_link'],
    content => $redmine::manage_file_content,
    replace => $redmine::manage_file_replace,
    audit   => $redmine::manage_audit,
    noop    => $redmine::bool_noops,
  }

  file { 'redmine-database.conf':
    ensure  => $redmine::manage_file,
    path    => $redmine::db_config_file,
    mode    => $redmine::config_file_mode,
    owner   => $redmine::config_file_owner,
    group   => $redmine::config_file_group,
    require => File['redmine_link'],
    content => $redmine::manage_db_file_content,
    replace => $redmine::manage_file_replace,
    audit   => $redmine::manage_audit,
    noop    => $redmine::bool_noops,
  }

  # The whole redmine configuration directory can be recursively overriden
  if $redmine::source_dir {
    file { 'redmine.dir':
      ensure  => directory,
      path    => $redmine::config_dir,
      require => File['redmine_link'],
      source  => $redmine::source_dir,
      recurse => true,
      purge   => $redmine::bool_source_dir_purge,
      force   => $redmine::bool_source_dir_purge,
      replace => $redmine::manage_file_replace,
      audit   => $redmine::manage_audit,
      noop    => $redmine::bool_noops,
    }
  }

  ### Include custom class if $my_class is set
  if $redmine::my_class {
    include $redmine::my_class
  }

  if $redmine::install_deps {
    include redmine::dependencies
  }

  # Setup database
  include "redmine::${redmine::db_type}"

  rbenv::install { $redmine::owner:
    home    => $redmine::install_dir,
    require => User[$redmine::owner],
  }

  rbenv::compile { "${redmine::owner}/${redmine::ruby_version}":
    user    => $redmine::owner,
    home    => $redmine::install_dir,
    ruby    => $redmine::ruby_version,
    global  => true,
    require => Rbenv::Install[$redmine::owner],
    notify  => Exec['Update gems environment bundler'],
  }

  $path = [ 
    "${redmine::install_dir}/.rbenv/shims",
    "${redmine::install_dir}/.rbenv/bin",
    '/bin', '/usr/bin', '/usr/sbin'
  ]
  $redmine_home = "${redmine::install_dir}/redmine"
  exec { 'Update gems environment bundler':
    command     => 'bundle update',
    user        => $redmine::owner,
    cwd         => $redmine_home,
    path        => $path,
    refreshonly => true,
    notify      => Exec['Install gems using bundler'],
    require     => File['redmine-database.conf'],
  }
  exec { 'Install gems using bundler':
    command     => 'bundle install --without development test',
    user        => $redmine::owner,
    cwd         => $redmine_home,
    path        => $path,
    refreshonly => true,
    notify      => Exec['Generate secret token'],
  }

  exec { 'Generate secret token':
    command     => 'bundle exec rake generate_secret_token',
    user        => $redmine::owner,
    cwd         => $redmine_home,
    path        => $path,
    refreshonly => true,
    notify      => Exec['Run database migration'],
  }

  exec { 'Run database migration':
    command     => 'bundle exec rake db:migrate',
    user        => $redmine::owner,
    cwd         => $redmine_home,
    path        => $path,
    environment => [ "RAILS_ENV=production" ],
    refreshonly => true,
  }

  exec { 'Insert default data set':
    command     => 'bundle exec rake redmine::load_default_data',
    user        => $redmine::owner,
    cwd         => $redmine_home,
    path        => $path,
    environment => [ "RAILS_ENV=production", "REDMINE_LANG=en" ],
    refreshonly => true,
  }

  # Setup webserver
  if $redmine::webserver_type != undef {
    include "redmine::${redmine::webserver_type}"

    Class["::redmine::${redmine::db_type}"]->
    Class["::redmine::${redmine::webserver_type}"]
  }

  if $redmine::plugins != undef and is_hash($redmine::plugins) {
    create_resources("::redmine::plugin", $redmine::plugins)
  }
}

# vim: set et sw=2:
