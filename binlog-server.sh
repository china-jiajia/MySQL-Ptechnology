#定义本地文件地址
LOCAL_BIN=/usr/local/mysql/bin/mysqlbinlog
LOCAL_BAK_DIR=/data/mysql/binlog_bak/3306_ip06
LOG=/data/mysql/binlog_bak/3306_ip06/backuplog
#定义远程数据库
REMOTE_IP=192.168.1.6
REMOTE_PORT=3306
REMOTE_USER=repl
REMOTE_PASS=repl123
FIRST_BINLOG=mysql-bin.000018
#错误等待时间
SLEEP_SECONDS=10
#防止备份文件夹未创建导致备份失败
mkdir -p ${LOCAL_BAK_DIR}
cd ${LOCAL_BAK_DIR}
#测试注释是否影像行数
#运行while循环，连接断开后会会执行echo错误代码到log的操作，等待10秒后重新执行while循环
while true
do
  if [ `ls -A "${LOCAL_BAK_DIR}"|grep -v backuplog|wc -l` -eq 0 ]; then
  LAST_FILE=${FIRST_BINLOG}
  else
#测试注释是否影响行数  
LAST_FILE=`ls -l ${LOCAL_BAK_DIR} | grep -v backuplog |tail -n 1 |awk '{print $9}'`
  fi
${LOCAL_BIN} --raw --read-from-remote-server --stop-never --host=${REMOTE_IP} --port=${REMOTE_PORT} --user=${REMOTE_USER} --password=${REMOTE_PASS} ${LAST_FILE}
echo "`date +%F_%H:%M:%S` mysqlbinlog停止，返回代码：$?"|tee -a ${LOG}
echo "${SLEEP_SECONDS}秒后再次连接并继续备份"|tee -a ${LOG}
sleep ${SLEEP_SECONDS}
done