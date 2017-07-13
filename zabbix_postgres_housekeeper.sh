#! /bin/bash

re='^[0-9]+([.][0-9]+)?$'

exec_manual () {
 echo "Please enter the timestamp before which you want to delete history data:"
 read DEL_DATE
 if ! [[ $DEL_DATE =~ $re ]] ; then
  echo "error: this \"timestamp\" is not a not a timestamp" ; exit 1
 fi
 HR_DATE=$(date -d @$DEL_DATE)
 for i in "history" "history_uint" "history_str" "history_text"; do
  CURRENT_TABLE_SIZE=$(sudo -u postgres psql -d zabbix -c "SELECT pg_size_pretty( pg_total_relation_size( '$i' ) );" 2>/dev/null | grep -A 1 "-" | grep -v "-" | tr -d " ")
  echo 'Table' $i 'size is' $CURRENT_TABLE_SIZE 'all data before' $HR_DATE 'will be deleted'
 done
 read -r -p "Are you sure? [y/N] " response
 if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
 then
  echo 'Deleting process started. It will take some time'
  for i in "history" "history_uint" "history_str" "history_text"; do
   sudo -u postgres psql -d zabbix -c "DELETE FROM $i WHERE clock < '$DEL_DATE';" 2>/dev/null
   sudo -u postgres psql -d zabbix -c "VACUUM FULL VERBOSE $i;" 2>/dev/null
  done
 else
  echo 'aborted'; exit 1
 fi
 for i in "history" "history_uint" "history_str" "history_text"; do
  CURRENT_TABLE_SIZE=$(sudo -u postgres psql -d zabbix -c "SELECT pg_size_pretty( pg_total_relation_size( '$i' ) );" 2>/dev/null | grep -A 1 "-" | grep -v "-" | tr -d " ")
  echo 'Table' $i 'size reduced to' $CURRENT_TABLE_SIZE
 done
}

exec_force () {
 if ! [[ $DEL_DATE =~ $re ]] ; then
  echo "error: this \"timestamp\" is not a not a timestamp" ; exit 1
 fi
 HR_DATE=$(date -d @$DEL_DATE)
 for i in "history" "history_uint" "history_str" "history_text"; do
  CURRENT_TABLE_SIZE=$(sudo -u postgres psql -d zabbix -c "SELECT pg_size_pretty( pg_total_relation_size( '$i' ) );" 2>/dev/null | grep -A 1 "-" | grep -v "-" | tr -d " ")
  echo 'Table' $i 'size is' $CURRENT_TABLE_SIZE 'all data before' $HR_DATE 'will be deleted'
 done
 echo 'Deleting process started. It will take some time'
 echo 'stopping zabbix server'
 systemctl stop zabbix-server.service
 echo -e "Zabbix server stopped\nhousekeeping started" | mutt -s "Housekeeping" pharlan@mail.ru
 for i in "history" "history_uint" "history_str" "history_text"; do
  sudo -u postgres psql -d zabbix -c "DELETE FROM $i WHERE clock < '$DEL_DATE';" 2>/dev/null
  sudo -u postgres psql -d zabbix -c "VACUUM FULL VERBOSE $i;" 2>/dev/null
 done
 systemctl start zabbix-server.service
 for i in "history" "history_uint" "history_str" "history_text"; do
  CURRENT_TABLE_SIZE=$(sudo -u postgres psql -d zabbix -c "SELECT pg_size_pretty( pg_total_relation_size( '$i' ) );" 2>/dev/null | grep -A 1 "-" | grep -v "-" | tr -d " ")
  echo 'Table' $i 'size reduced to' $CURRENT_TABLE_SIZE
 done
 systemctl status zabbix-server.service
 if [ $(systemctl status zabbix-server.service >/dev/null ; echo $?) -ne 0 ] ; then
  echo -e "Zabbix server could not start!!!\nSummon admins!" | mutt -s "Housekeeping" pharlan@mail.ru ; else
  echo -e "Zabbix server started\nHousekeeping is done" | mutt -s "Housekeeping" pharlan@mail.ru
 fi
}

if [ $# -gt 0 ] ; then
 case "$1" in
 -h|--help)
  echo "This script deletes specified rows of all history tables in PostgreSQL DB of Zabbix Server"
  echo "options:"
  echo "-h, show brief help"
  echo "-t, timestamp for force mode"
  echo "-m, manual mode"
  exit 0
  ;;
 -t)
  while getopts ":t:" opt; do
   case $opt in
   t)
      DEL_DATE=$OPTARG
      exec_force       
      ;;
   \?)  
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
   :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
   esac
  done 
  ;;
 -m)
  echo "manual mode executed"
  exec_manual 
  ;;
 esac
else
 echo "This script deletes specified rows of all history tables in PostgreSQL DB of Zabbix Server"
 echo "options:"
 echo "-h, show brief help"
 echo "-t, timestamp for force mode"
 echo "-m, manual mode"
 exit 0
fi
