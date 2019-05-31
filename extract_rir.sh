#!/bin/bash
# This script runs the roomsimove_single.py script in parallel. 

nj=30
cmd=queue.pl
echo "$0 $@"

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh || exit 1;

input_dir=$1
output_dir=$2
logdir=$output_dir/log
scp=$input_dir/rir_info

mkdir -p $logdir
mkdir -p $output_dir

output_dir=`perl -e '($dir,$pwd)= @ARGV; if($dir!~m:^/:) { $dir = "$pwd/$dir"; } print $dir; ' $output_dir ${PWD}`
for n in $(seq $nj); do
    split_scps="$split_scps $output_dir/rir_info.$n.scp"
done

utils/split_scp.pl $scp $split_scps || exit 1;

$cmd JOB=1:$nj $logdir/extract_rir.JOB.log \
  roomsimove_single.py $output_dir/rir_info.JOB.scp $output_dir/JOB
