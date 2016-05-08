#!/bin/bash
# This script deploys an API to a specified zOs Connect instance. It should be a very rare occasion when this script needs to be modified!

# Input Parameters
# --l zosconnect_install_dir    - The location of zconnect installation directory
# --s servername	   			- The z-Connect Server Name
# --f filename      			- Package filename containing the AAR file
# --c command		   			- deploy or undeploy

zosconnect_install_dir=${zosconnect_install_dir}
servername=${servername}
filename=${filename}
command=${command}

# Do user input function
function usage() {
cat << EOF
usage: $0 options

This script publishes an api into an API Connect

OPTIONS:
	-h		Help
	-l      The location of zconnect installation home
	-s      z-Connect Server Name
	-p      filename
	-c      Installation commands : [deploy][undeploy]
EOF
}

function executCommand() {
# API Archive File Installation
unzip "${zipfilename}.zip"

$zosconnect_install_dir/bin/apideploy -${command} -a "${zipfilename}.aar" -p "/var/zosconnect/servers/${servername}/resources/zosconnect/apis/"

	# api deployment status
	result=$?
	if [[ $result -ne 0 ]]
	then
		echo "Deployment of API archive $zipfilename.aar failed."
		exit 1
	fi

echo "Deploying server includes"

case $command in
deploy)
	cp server-includes/${servername}/*.xml "/var/zosconnect/servers/${servername}"
	echo "server includes copied..."
	ls -altr 
	;;
esac	
}


function undeployAAR() {
# API Archive File Installation
unzip "zipfilename.zip"

$zosconnect_install_dir/bin/apideploy -${command} -a "${zipfilename}.aar" -p "/var/zosconnect/servers/${servername}/resources/zosconnect/apis/"

	# api deployment status
	result=$?
	if [[ $result -ne 0 ]]
	then
		echo "Deployment of API archive $zipfilename.aar failed."
		exit 1
	fi
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
apicLogout

exit 0