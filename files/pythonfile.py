#!/usr/bin/env python

import json
import os
import subprocess

def load_gmail_token_file(email, token_file, key='refresh_token'):
    # just in case
    token_path = os.path.expanduser(token_file)
    with open(token_path) as fp:
        token = json.load(fp)
    return token[key]

# slightly less dumb version that will keep refreshing the token as necessary
# when checking mail.
#
# it just calls out to a script since we already have one
def run_refresh_script(script_path, email):
    result = subprocess.run([script_path, email],
                            capture_output=True)
    access_token = result.stdout.decode().strip()
    return access_token
