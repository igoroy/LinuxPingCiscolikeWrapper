#!/bin/bash
#
# Cisco-like ping wrapper by Igor_Y
#
# Parsed ICMP messages:
#64 bytes from 192.168.248.51: icmp_seq=1 ttl=128 time=0.547 ms
#64 bytes from 93.158.134.3: icmp_seq=4 ttl=54 time=21.312 ms	<-- mac os x
#From 192.168.248.103 icmp_seq=1 Destination Host Unreachable
#From 172.24.0.134 icmp_seq=8 Packet filtered
#From 212.1.97.206 icmp_seq=1 Time to live exceeded
# Assuming that sequence conter is in sync
#72 bytes from 172.26.22.10: icmp_seq=2 ttl=251 (truncated)
#From 192.168.0.52: icmp_seq=9 Source Quench
# Sequence counter is not in sync
#From 10.0.0.4: icmp_seq=1 Redirect Host(New nexthop: 10.0.0.17)
#From 10.0.0.17: icmp_seq=2 Redirect Network(New nexthop: 10.0.0.23)
#From 195.137.185.66 icmp_seq=2 Frag needed and DF set (mtu = 1460)

echo "Legend:"
echo " ! - Reply recieved			. - Reply lost"
echo " < - Reply sequence from the past	x - Time to live exceeded"
echo " t - Reply truncated			q - Source Quench"
echo ""

echo "Start: " `date "+%H:%M:%S %d/%m/%Y"`

#trap 'echo -e "\nCatched SIGINT"' SIGINT
trap '' SIGINT

n=1
count=1
err=""
param="$*"
numpackets=$(expr "$param" : '.*-c \?\([0-9]*\).*')
deadline=$(expr "$param" : '.*-w \?\([0-9]*\).*')

if [[ "$numpackets" == "" && "$deadline" == "" ]]; then param="-c 5 ${param}"; fi

while read line
do
# ICMP event detection
#64 bytes from 192.168.248.51: icmp_seq=1 ttl=128 time=0.547 ms
#64 bytes from 93.158.134.3: icmp_seq=4 ttl=54 time=21.312 ms   <-- mac os x
num=$(expr "$line" : '^[0-9]\+ bytes from .*: icmp_[rs]eq=\([0-9]\+\) ttl=[0-9]\+ time=.*$')
unr=$(expr "$line" : '^From .* icmp_[rs]eq=\([0-9]\+\) Destination Host Unreachable$')
fil=$(expr "$line" : '^From .* icmp_[rs]eq=\([0-9]\+\) Packet filtered$')
ttl=$(expr "$line" : '^From .* icmp_[rs]eq=\([0-9]\+\) Time to live exceeded$')
# Assuming that sequence conter is in sync
trc=$(expr "$line" : '^[0-9]\+ bytes from .*: icmp_[rs]eq=\([0-9]\+\) ttl=[0-9]\+ (truncated)$')
qnc=$(expr "$line" : '^From .*: icmp_[rs]eq=\([0-9]\+\) Source Quench$')
# Sequence counter is not in sync
hst=$(expr "$line" : '^From .*: icmp_[rs]eq=\([0-9]\+\) Redirect Host(New nexthop: .*)$')
net=$(expr "$line" : '^From .*: icmp_[rs]eq=\([0-9]\+\) Redirect Network(New nexthop: .*)$')
fra=$(expr "$line" : '^From .* icmp_[rs]eq=\([0-9]\+\) Frag needed and DF set (mtu = .*)$')

# Normal echo reply
if [[ "$num" ]]
  then
    if [[ "$num" -lt "$n" ]]
      then
        echo -n "<"
        n=$(( n - 1 ))
    fi
    if [[ "$num" -gt "$n" ]]
      then
        dif=$(( num - n ))	# let "dif=$num-$n"
        for ((a=1; a <= dif ; a++))
        do
          echo -n "."
          if (( count % 80 == 0 )); then echo " $count"; fi
          (( n++ ))
          (( count++ ))
        done
    fi
    if [[ "$num" -eq "$n" ]]
      then
        echo -n "!"
    fi
    if (( count % 80 == 0 )); then echo " $count"; fi
    (( n++ ))
    (( count++ ))
fi

# Destination unreachable
if [[ "$unr" ]]
  then
#    # Do not know if this check is needed
#    if [[ "$unr" -lt "$n" ]]
#      then
#        echo -n "<"
#        n=$(( n - 1 ))
#    fi
    if [[ "$unr" -gt "$n" ]]
      then
        dif=$(( unr - n ))	# let "dif=$unr-$n"
        for ((a=1; a <= dif ; a++))
        do
          echo -n "."
            if (( count % 80 == 0 )); then echo " $count"; fi
            (( n++ ))
            (( count++ ))
        done
    fi
    if [[ "$unr" -eq "$n" ]]
      then
        echo -n "u"
    fi
    if (( count % 80 == 0 )); then echo ""; fi
    (( n++ ))
    (( count++ ))
fi

# Packet filtered
if [[ "$fil" ]]
  then
#    # Do not know if this check is needed
#    if [[ "$fil" -lt "$n" ]]
#      then
#        echo -n "<"
#        n=$(( n - 1 ))
#    fi
    if [[ "$fil" -gt "$n" ]]
      then
        dif=$(( fil - n ))	# let "dif=$fil-$n"
        for ((a=1; a <= dif ; a++))
          do
            echo -n "."
            if (( count % 80 == 0 )); then echo " $count"; fi
            (( n++ ))
            (( count++ ))
          done
    fi
    if [[ "$fil" -eq "$n" ]]
      then
        echo -n "f"
    fi
    if (( count % 80 == 0 )); then echo " $count"; fi
    (( n++ ))
    (( count++ ))
fi

# Time to live exceeded
if [[ "$ttl" ]]
  then
#    # Do not know if this check is needed
#    if [[ "$ttl" -lt "$n" ]]
#      then
#        echo -n "<"
#        n=$(( n - 1 ))
#    fi
    if [[ "$ttl" -gt "$n" ]]
      then
        dif=$(( ttl - n ))	# let "dif=$ttl-$n"
        for ((a=1; a <= dif ; a++))
          do
            echo -n "."
            if (( count % 80 == 0 )); then echo " $count"; fi
            (( n++ ))
            (( count++ ))
          done
    fi
    if [[ "$ttl" -eq "$n" ]]
      then
        echo -n "x"
    fi
    if (( count % 80 == 0 )); then echo " $count"; fi
    (( n++ ))
    (( count++ ))
fi

# Echo reply is truncated
if [[ "$trc" ]]
  then
#    # Do not know if this check is needed
#    if [[ "$trc" -lt "$n" ]]
#      then
#        echo -n "<"
#        n=$(( n - 1 ))
#    fi
    if [[ "$trc" -gt "$n" ]]
      then
        dif=$(( trc - n ))	# let "dif=$trc-$n"
        for ((a=1; a <= dif ; a++))
          do
            echo -n "."
            if (( count % 80 == 0 )); then echo " $count"; fi
            (( n++ ))
            (( count++ ))
          done
    fi
    if [[ "$trc" -eq "$n" ]]
      then
        echo -n "t"
    fi
    if (( count % 80 == 0 )); then echo " $count"; fi
    (( n++ ))
    (( count++ ))
fi

# Source Quench
if [[ "$qnc" ]]
  then
#    # Do not know if this check is needed
#    if [[ "$qnc" -lt "$n" ]]
#      then
#        echo -n "<"
#        n=$(( n - 1 ))
#    fi
    if [[ "$qnc" -gt "$n" ]]
      then
        dif=$(( qnc - n ))	# let "dif=$qnc-$n"
        for ((a=1; a <= dif ; a++))
          do
            echo -n "."
            if (( count % 80 == 0 )); then echo " $count"; fi
            (( n++ ))
            (( count++ ))
          done
    fi
    if [[ "$qnc" -eq "$n" ]]
      then
        echo -n "q"
    fi
    if (( count % 80 == 0 )); then echo " $count"; fi
    (( n++ ))
    (( count++ ))
fi

# Some ICMP messages are being captured in "err" variabe.
if [[ "$hst" || "$net" || "$fra" || "$ttl" || "$trc" || "$qnc" ]]
  then
    if [[ "$err" ]]
      then
        err=$(echo -e "$err""\n$line")
      else
        err="$line"
    fi
fi

# Displaying any lines that do not match preassigned filters.
if [[ "$num" == "" && "$unr" == "" && "$fil" == "" && "$ttl" == "" && "$trc" == "" && "$qnc" == "" && "$hst" == "" && "$net" == "" && "$fra" == "" ]]
  then echo "$line"
  #else
    # Debug output
    #echo " num=$num unr=$unr fil=$fil ttl=$ttl trc=$trc qnc=$qnc hst=$hst net=$net fra=$fra"
fi

# This is called "Process Substitution"
done < <(ping $param)

# Echo all unususl lines captured during ping session.
if [[ "$err" ]]
  then
    echo ""
    echo "ICMP messages:"
    echo "$err"
fi
echo ""
echo "Finish: " `date "+%H:%M:%S %d/%m/%Y"`
exit 0