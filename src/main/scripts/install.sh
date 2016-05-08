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
	-p      zipfilename
	-c      deploy or undeploy
EOF
}

function deployAAR() {
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
echo "Deploying server includes"

cp  ${servername}/
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
	while getopts “l:s:c:u:p:” OPTION
	do
	     case $OPTION in
	        h)
	             usage
	             exit 1
	             ;;
	        m)
	            managementServer=$OPTARG
	             ;;
	        o)
	            organization=$OPTARG
	             ;;
	        c)
	            catalog=$OPTARG
	             ;;
	        u)
	            username=$OPTARG
	             ;;
	        p)
	            password=$OPTARG
	             ;;
	        ?)
	             usage
	             exit
	             ;;
	     esac
	done
	
	# ensure required params are not blank
	echo "organization=$organization,managementServer=$managementServer,catalog=$catalog,username=$username,password=$password"
	if [[ -z $managementServer ]] || [[ -z $organization ]] || [[ -z $catalog ]] || [[ -z $username ]] || [[ -z $password ]]
	then
		usage
		exit 1
	fi
}


# start of main pogram
parseParameters $@
apicLogin
apicPushDraft
apicPublishToCatalog

# Deployment complete
echo "Deployment of API $apiName version $apiVersion to catalog $catalog is complete."
apicLogout

exit 0