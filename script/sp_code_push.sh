
###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
#--- Logger stuff has to exist before called, so make it early
LOGFILE="/tmp/ss_codeupdate.log"

logmsg()
{
	echo "$(date): ${1}" 2>&1 | tee -a ${LOGFILE}
}

###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
#--- Globals

SPHOME="/home/spapi"
GEM="/usr/local/bin/gem"
SSTUDIO="${SSHOME}/stack-core"

###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
#--- functions for use to keep the main line clean

install_stackcore()
{
	#--- cd into <API dir>/stack-core/
	cd ${SPHOME}

	#--- get the code
	logmsg "Unpacking stackcore tar..."
	sudo tar xvzf "stackcore.tar.gz"
	rm "stackcore.tar.gz"
	logmsg "stack-core upacked"
}

set_sc_permissions()
{
	#--- Change permissions to allow apache access to API files
	logmsg "Setting stack-core directory permissions..."
	cd "${SPHOME}"
	sudo chmod 755 ${SPHOME}
	sudo find ${SPHOME} -type d -exec chmod 755 {} \;
	sudo find ${SPHOME} -type f -exec chmod 644 {} \;
	sudo chown -R spapi:spapi stack-core

}

run_sc_bundle_update()
{
	#--- run bundle update
	cd "${SPHOME}/stack-core"
	source /etc/profile.d/rvm.sh
	bundle install --without development test --path .
}

run_sc_tasks()
{
	#--- run bundle update
	cd "${SPHOME}/stack-core"
	source /etc/profile.d/rvm.sh
	bundle exec rake db:truncate_mappings
	bundle exec rake db:seed
}

tail_logs()
{
	#cd ${SSHOME}/ToughUI
	#tail log/production.log

	logmsg "Tailing access logs..."
	sudo tail "/var/log/httpd/stackstudio-access_log"
	logmsg "Tailing error logs..."
	sudo tail "/var/log/httpd/stackstudio-error_log"
	logmsg "Tailing production log..."
	sudo tail "${SSTUDIO}/log/production.log"
}

restart_server()
{
    sudo /etc/init.d/${SP_WEB_SERVER} restart
}

update_stackplace()
{
	echo "echo \"Installing gems\"" >> "/tmp/update_api.sh"
	echo "su -c \"cd ${SPHOME}/stack-core; bundle install --without test development --path /home/spapi/stack-core/ruby\" - spapi" >> "/tmp/update_api.sh"
	chmod +x "/tmp/update_api.sh"
	sudo "/tmp/update_api.sh"
}


run_tasks()
{
	#--- run cloud migration
	cd ${SSHOME}/ToughUI
	
	echo "echo \"Run necessary tasks\"" >> "/tmp/run_tasks.sh"
	echo "cd ${SSHOME}/ToughUI; bundle exec rake tmp:clear --trace" > "/tmp/run_tasks.sh"
	#echo "cd ${SSHOME}/ToughUI; bundle exec rake api:add_image_mappings --trace" >> "/tmp/run_tasks.sh"

	chmod +x "/tmp/run_tasks.sh"
	sudo "/tmp/run_tasks.sh"
}

###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
#--- Make some 'niceties' in for logins

###### ###### ###### ###### ###### ###### ###### ###### ###### ###### ######
#--- Configure general OS level files.
export PATH="${PATH}:/usr/local/bin"

logmsg "Starting stack-core install ..."
install_stackcore
set_sc_permissions
run_sc_bundle_update
#run_rails_migrations
#update_stackplace
#run_tasks
restart_server
#tail_logs
logmsg "... finished stack-core install."


