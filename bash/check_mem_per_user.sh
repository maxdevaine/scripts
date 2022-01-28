#!/bin/bash
# author: Max Devaine <maxdevaine@gmail.com>
# license: GNU GPLv3

# create list of users from running processes
USER_LIST=`ps ax o user:16 | awk 'NR>1 {print $1}' | sort -u`
# add list to array
declare -a arr=($USER_LIST)

for i in "${arr[@]}"; do
  TOTAL=`ps -U $i -o size,command --sort -size | awk '{ hr=$1/1024 ; sum +=hr} END {printf "%0.f",sum}'`
  array+=( "$(echo User: $i, Total memory: $TOTAL MiB)" )
  # list all process for specific user sorted by memory allocation
  #  ps -U $i -o size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }'
done

# print array sorted by number in collumn with memory allocation:
printf '%s\n' "${array[@]}" |sort -rk5 -n
