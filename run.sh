#!/usr/bin/env bash

knife upload /cookbooks
sudo chef-client
