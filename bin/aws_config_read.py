#!/usr/bin/env python3
# vim: set ft=python

import configparser
import pathlib
import json


def main():
    config = configparser.ConfigParser()

    file_path = pathlib.PosixPath('~/.aws/config').expanduser()

    config.read(file_path)

    sso_sessions = {
        section_key.split(" ")[1]: section
        for section_key, section in config._sections.items()
        if 'sso-session' in section_key
    }

    profiles = {
        section_key.split(" ")[1]: section
        for section_key, section in config._sections.items()
        if 'profile' in section_key
    }

    result = dict(
        sso_sessions=sso_sessions,
        profiles=profiles
    )
    print(json.dumps(result, indent=4))


if __name__ == '__main__':
    main()
