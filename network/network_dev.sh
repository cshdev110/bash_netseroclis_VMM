#!/bin/bash

#Virtual Machine Manager tool to create easly a infrastructure for testing purpose

declare name_distro
declare virtual_cpus
declare virtual_memory
declare os_type

function createNewVM {
    #Install libosinfo-bin to use osinfo-query to check --os-variant
    #However, it will be empty so that the software will choose a generic variant.
    virt-install --name $name_distro --vcpus $virtual_cpus --memory virtual_memory --os-type=$os_type 
}