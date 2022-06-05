#!/usr/bin/env python

import json
import os

def load_gmail_token_file(email, token_file, key='refresh_token'):
    # just in case
    token_path = os.path.expanduser(token_file)
    with open(token_path) as fp:
        token = json.load(fp)
    return token[key]
