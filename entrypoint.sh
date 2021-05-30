#!/bin/bash

set -e

sudo service docker start > /dev/null 2>&1
sudo service jenkins start > /dev/null 2>&1
bash -l
