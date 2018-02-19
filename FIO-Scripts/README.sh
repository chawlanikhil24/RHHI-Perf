How to use this script ? 

Clone this repository
Specify 4 Paramters while running on the STDIN :

Fio Conf Path - where to find the FIO job files ?
Fio's Output Path - where to store the FIO job outputs ?
Performance Stats - where to keep the performance data ?
Mountpoint - Mountpoint of the storage device on which FIO jobs is going to be executed 

EXAMPLE:

./fio-eval.sh <fio-confs> <outputs> <PERF_LOGS> <mountpoint>
