#!/usr/bin/env python3

import json
import pathlib
import configparser

aws_config_file = pathlib.PosixPath('~/.aws/config').expanduser()

config = configparser.ConfigParser()

config.read(aws_config_file)

sso_sessions = {
    section_key.split(" ")[1]: section.get("sso_region")
    for section_key, section in config._sections.items()
    if 'sso-session' in section_key
}

profiles = {
    section_key.split(" ")[1]: section.get("region")
    for section_key, section in config._sections.items()
    if 'profile' in section_key and 'test' not in section_key
}

result = dict(
    sso_sessions=sso_sessions,
    profiles=profiles
)

print(json.dumps(result, indent=4))
