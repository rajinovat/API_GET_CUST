#!/bin/bash
# This script deploys an API to a specified zOs Connect instance. It should be a very rare occasion when this script needs to be modified!

# Input Parameters
# --l zosconnect_install_dir    		- The location of zconnect installation directory
# --s servername	   			- The z-Connect Server Name
# --f filename      				- Package filename containing the AAR file
# --c command		   			- deploy or undeploy

zosconnect_install_dir=
servername=
filename=
command=

user_profiles_home="/var/zosconnect/servers"
apis_resource_loc="resources/zosconnect/apis/"

# Do user input function
function usage() {
cat << EOF
usage: $0 options

This script publishes an api into an API Connect

OPTIONS:
	-h	Help
	-l      z-Connect installation home
	-s      z-Connect Instance Name
	-p      Package name
	-c      Installation commands : [deploy][undeploy]
EOF
}

function executeCommand() {
# API Archive File Installation

${zosconnect_install_dir}/bin/apideploy -${command} -a "${filename}.aar" -p "${user_profiles_home}/${servername}/${apis_resource_loc} -w"

	# api deployment status

	result=$?
	if [[ $result -ne 0 ]]
	then
		echo "${command} of API archive $filename.aar failed."
		exit 1
	fi

case $command in
deploy)
	
	echo "Copying server includes into ${user_profiles_home}/${servername}"

	cp server-includes/${servername}/*-*.xml "${user_profiles_home}/${servername}"

	echo "server includes copied..."
	
	#Uncomment below steps to overwrite server.xml..
	
	#echo "Copying server.xml into /var/zosconnect/servers/${servername}"
	#cp server-includes/${servername}/server.xml /var/zosconnect/servers/${servername}
	#echo "server.xml copied..."
	
	ls -altr  "${user_profiles_home}/${servername}"
	;;
esac
	
}



function parseParameters() {
	while getopts “l:s:p:c:” OPTION
	do
	     case $OPTION in
	        h)
	             usage
	             exit 1
	             ;;
	        l)
	            zosconnect_install_dir=$OPTARG
	             ;;
	        s)
	            servername=$OPTARG
	             ;;
	        p)
	            filename=$OPTARG
	             ;;
	        c)
	            command=$OPTARG
	             ;;
	        ?)
	             usage
	             exit
	             ;;
	     esac
	done
	
	# ensure required params are not blank
	
	echo "zosconnect_install_dir=$zosconnect_install_dir,servername=$servername,filename=$filename,command=$command"
	if [[ -z $zosconnect_install_dir ]] || [[ -z $servername ]] || [[ -z $filename ]] || [[ -z $command ]]
	then
		usage
		exit 1
	fi
	
}


# start of main pogram
parseParameters $@
executeCommand


# Deployment complete
echo "Deployment of API archive $filename.aar is complete."

exit 0
