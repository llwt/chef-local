#!/usr/bin/env bash
set -e
knife upload /cookbooks
sudo chef-client
