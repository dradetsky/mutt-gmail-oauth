#!/bin/bash
#
# This is the (default) script which manages tokens for smtp.
#
# NOTE: This script is INTENTIONALLY INSECURE. You can override it with another
# script. Some examples to work from include
#
# https://github.com/tenllado/dotfiles/blob/master/config/msmtp/oauth2token
# https://github.com/harriott/ArchBuilds/blob/master/jo/mail/oauth2tool.sh

# msmtp will pass in the email addr it is trying to send mail for. In theory
# this (and other params) could be used to look up the token in an encrypted
# password store.
email=$1

# now we insecurely get or refresh the access token
refresh_script={{ mgo_oauth_refresh_script_path }}
token_file={{ mgo_oauth_token_file }}
access_token=$(jq -r '.access_token' $token_file)
expires_at=$(jq -r '.access_token_expiration' $token_file)
# XXX: should be utc?
secs_now=$(date +%s)

refresh_access_token() {
    client_id="406964657835-aq8lmia8j95dhl1a2bvharmfk3t1hgqj.apps.googleusercontent.com"
    client_secret="kSmqreRr0qwBWJgbf5Y-PjSU"
    refresh_token=$(jq -r '.refresh_token' $token_file)

	{ IFS= read -r tokenline && IFS= read -r expireline; } < \
	<(${refresh_script} --user=${email} \
	--client_id=${client_id} \
	--client_secret=${client_secret} \
	--refresh_token=${refresh_token})

    secs_now=$(date +%s)
	access_token=${tokenline#Access Token: }
	expires_in=${expireline#Access Token Expiration Seconds: }
    expires_at=$((secs_now + expires_in))

    jq --arg at "${access_token}" --arg te "${expires_at}" \
        '.access_token=$at | .access_token_expiration=$te' \
        ${token_file} > ${token_file}.tmp
    mv ${token_file}.tmp ${token_file}
}

if [[ ${secs_now} -lt ${expires_at} ]] ; then
    echo $access_token
else
    refresh_access_token
    echo $access_token
fi
