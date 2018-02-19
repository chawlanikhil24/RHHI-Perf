#!/bin/bash

inp_PATH=$1
out_PATH=$2
stat_PATH=$3
final_out=""
slash="/"
device=/mnt$slash$4$slash

echo $device

run_FIO()
{
  fio $1 --output=$2
}

get_outfile_path()
{
  final_out=""
  ext=".out"
  out="$(cut -d'/' -f 4 <<<$1)"
  out="$(cut -d'.' -f 1 <<<$out)"
  final_out=$out$ext
}

get_stats()
{
  iostat_file=$1$slash"iostat/"$2
  mpstat_file=$1$slash"mpstat/"$2
  top_file=$1$slash"top/"$2
  vmstat_file=$1$slash"vmstat/"$2
  sar_file=$1$slash"sar/"$2
  iostat -dktxz -c 3 > $iostat_file &
  mpstat -P ALL 3 > $mpstat_file &
  vmstat -a -n 3 > $vmstat_file &
  top -b -d 3 > $top_file &
  # sar > $sar_file &
}

kill_stats()
{
  pkill iostat
  pkill vmstat
  pkill top
  pkill mpstat
  # pkill sar
}

for filename in $inp_PATH/*; do
  echo "3" > /proc/sys/vm/drop_caches
  rm -rf $device*
  ls $device
  echo "Device CLeared"
  echo $filename
  get_outfile_path $filename
  get_stats $stat_PATH $final_out
  run_FIO $filename $out_PATH$slash$final_out
  kill_stats
  echo "done"
  sleep 30s
done


