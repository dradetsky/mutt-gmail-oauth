#!/bin/bash
#
# awful wrapper for my awful hack on top of
#
# https://gitlab.com/muttmua/mutt/-/blob/master/contrib/mutt_oauth2.py).
#
# hopefully i can replace this soon
this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# from thunderbird
export MUTT_OAUTH2_GOOGLE_CLIENT_ID={{ mgo_oauth_client_id }}
export MUTT_OAUTH2_GOOGLE_CLIENT_SECRET={{ mgo_oauth_client_secret }}

email={{ mgo_email }}
token_file={{ mgo_oauth_token_file }}

${this_dir}/mutt_oauth2.py ${token_file} -r google -e ${email} --authflow localhostauthcode -a
