#!/bin/bash

inp_PATH=$1
out_PATH=$2
stat_PATH=$3
final_out=""
slash="/"
mountpoint=$4$slash

echo $mountpoint

run_FIO()
{
  fio --name=writetest --ioengine=sync --rw=write --direct=0 --create_on_open=1 --fsync_on_close=1 --bs=128k --directory=/mnt/vdo_vol/ --output=$2 --filesize=16g --size=16g --numjobs=4 --dedupe_percentage=$3 --scramble_buffers=1 --group_reporting=1
  #fio $1 --output=$2
}

get_outfile_path()
{
  final_out=""
  ext=".out"
  out="$(cut -d'/' -f 2 <<<$1)"
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
  #vdostat_file=$1$slash"vdostat/"$2
  #vdostat_file2=$1$slash"vdostat2/"$2
  iostat -dktxz -c 3 > $iostat_file &
  mpstat -P ALL 3 > $mpstat_file &
  vmstat -a -n 3 > $vmstat_file &
  top -b -d 3 > $top_file &
  #vdo status  -n vdo_vol > $vdostat_file &
  #vdostats --verbose|grep bios|egrep -v 'par|co|ack|pr|use|f' > $vdostat_file2 &
  # sar > $sar_file &
}

get_vdo_stats()
{
  vdostat_file=$1$slash"vdostat/"$2
  vdostat_file2=$1$slash"vdostat2/"$2
  echo $vdostat_file2 "VDOSTATA"
  vdo status  -n vdo_vol > $vdostat_file 
  vdostats --verbose|grep bios|egrep -v 'par|co|ack|pr|use|f' > $vdostat_file2 
}

kill_stats()
{
  pkill iostat
  pkill vmstat
  pkill top
  pkill mpstat
  # pkill sar
}

for dedup_perc in $(seq 0  5  100); do
  echo "Caches CLeared for write "$dedup_perc
  filename="dedupe_percentage_"$dedup_perc"_write.conf"
  echo $filename
  get_outfile_path $filename
  get_stats $stat_PATH $final_out
  run_FIO $filename $out_PATH$slash$final_out $dedup_perc
  get_vdo_stats $stat_PATH $final_out
  kill_stats
  echo "done"
  sleep 5s
  sync; echo 3 > /proc/sys/vm/drop_caches
  echo "Caches CLeared for READ "$dedup_perc
  filename="dedupe_percentage_"$dedup_perc"_read.conf"
  echo $filename
  get_outfile_path $filename
  get_stats $stat_PATH $final_out
  run_FIO $filename $out_PATH$slash$final_out $dedup_perc
  get_vdo_stats $stat_PATH $final_out
  kill_stats
  echo "done"
  rm -rf /mnt/vdo_vol/*
  sleep 5s
done
