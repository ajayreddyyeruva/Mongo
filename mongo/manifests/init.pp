class mongo( $port, $replSet, $master, $master_port=undef, ) {

  $mongo_data_dir="/data/mongo/${replSet}_${port}"

  $public_ip = $::ipaddress

  $server_pkg_name = $::osfamily ? {
    debian => 'mongodb-10gen',
    redhat => 'mongo-10gen-server',
  }


  user { 'mongo':
    ensure => present,
    managehome => false,
  }

  file { 'data':
    path => '/data',
    ensure => directory, 
  }

  file { 'mongo_logs':
    path => '/var/log/mongo/',
    owner => mongo,
    group => mongo,
    ensure => directory,
    require => User['mongo'],
    before => Package['mongodb'],
  }

  file { [ "/data/mongo", "${mongo_data_dir}"]:
    owner => mongo,
    group => mongo,
    ensure => directory,
    require => [ User['mongo'], File['data'], ],
    before => Package['mongodb'],
    recurse => true,
  }

  package { 'mongodb':
    name => "${server_pkg_name}",
    ensure => present,
  }

  file { 'mongo_conf':
    content => template('mongo/mongod_tempalte.conf'),
    path   => "${mongo_data_dir}/mongod.conf",
  }

  Exec {
    path => [
      '/usr/local/bin',
      '/opt/local/bin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin'],
      logoutput => true,
  }

  file { 'mongo_restart_file':
    source => "puppet:///modules/mongo/restart_mongo.sh",
    path    => "${mongo_data_dir}/restart_mongo.sh",
    mode    => '755',
  }

  exec { "${mongo_data_dir}/restart_mongo.sh ${mongo_data_dir}":
    require   => [Package['mongodb'],File['mongo_conf'], File['mongo_restart_file']],
    user      => mongo,
    command   => "${mongo_data_dir}/restart_mongo.sh ${mongo_data_dir}",
    logoutput => true,
    before    => Exec['replicaset'],
  }

   $replicaset_file = "${master}" ? {
         master     => 'mongo/master_replicaset.cmd',
             slave => 'mongo/slave_replicaset.cmd',
   }

  file { 'replicaset_file':
    content => template("${replicaset_file}"),
    path    => "${mongo_data_dir}/replicaset.cmd",
    before  => Exec['replicaset'],
  }


  exec { 'replicaset':
    user      => mongo,
    command => "mongo --port ${master_port} < ${mongo_data_dir}/replicaset.cmd",
    logoutput => true,
  }

}
