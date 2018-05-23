These set of ANSIBLE Playbooks are intended to automate the performance evaluation of Red Hat Hyperconverged Infrastructure(RHHI) using fio tool. These scripts are also capable of generating numbers with deduplication and compression provided by Virtual Data Optimizer(VDO),which is key feature of RHEL 7.5 and RHHI 2.0 . 

How to run ?

1. Add the RHHI Hostnames in [rhhihosts ]and VM hostname in the [vm] in the Ansible inventory file.
2. Also mention the VM Hostname in the "groups/all" as the value of "fio_vm" key.
3. Now all the user parameters are setup. Time to fire UP the scripts.
4. There are 2 ways to fire up the scripts:

    -   To run fio and capture the statistics normally, run:
    
        ```ansible-playbook firePlay.yaml -i inventory -e volume=normal``` 

    -   To run fio and capture the vdo related statistics with other statistics, run:
    
        ```ansible-playbook firePlay.yaml -i inventory -e volume=vdo -e vdo_volume_name=<vdo_volume_name>```
