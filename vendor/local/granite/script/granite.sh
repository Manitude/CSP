#!/bin/sh

apps=(app_launcher baffler community eschool license_server ollc sappy tracking update_service usarmy_reporter viper)

function run_command {
  if [ -n "$2" ]; then
    run_granite_command_on_app $2 $1
  else
    for app in ${apps[@]}
    do
      run_granite_command_on_app $app $1
    done
  fi
}

function run_granite_command_on_app {
    app=$1
    cmd=$2

    app_base_dir=/usr/website/$app/current
    if [ -e $app_base_dir/config/granite_agents.defaults.yml ]; then
      echo "calling granite:$cmd for $app"
      sudo -E -u deploy -H /bin/sh -c "cd $app_base_dir; RAILS_ENV=production $app_base_dir/rake granite:$cmd" &
    fi
}

case $1 in
  start|stop|status|kill)
    run_command $1 $2
    ;;
  restart)
    run_command stop
    run_command start
    ;;
  *)
    echo "usage: $0 start|stop|restart|kill|status [<application name>]" >&2
    exit 1
    ;;
esac

