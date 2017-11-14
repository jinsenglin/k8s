#!/bin/bash

set -e

function release() {
    source rc
    openstack server delete $M1
    openstack server delete $M2
    openstack server delete $M3
    openstack server delete $M4
    openstack server delete $M5
    openstack server delete $M6
}

release
