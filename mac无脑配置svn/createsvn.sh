#!/usr/bin/env bash

echo -n '请输入仓库文件夹名称(默认test_svnserver):'

read  svnserver_name

echo -n '请输入仓库名称(默认test_repository):'

read repository_name

if [ ! -n "$svnserver_name" ]; then
	svnserver_name="test_svnserver"
fi
if [ ! -n "$repository_name" ]; then
	repository_name="test_repository"
fi

if [ ! -d "$HOME/$svnserver_name" ]; then
	mkdir $HOME/$svnserver_name
fi

cd $HOME/$svnserver_name

if [ ! -d "$repository_name" ]; then
	svnadmin create $repository_name
fi

time=$(date "+%Y%m%d%H%M%S")
backupname=".backup_${time}"
#echo $svnserver_name
#echo $repository_name

error="rm -rf $HOME/$svnserver_name"
echo -e "\033[0;31;1m$error\033[0m"


echo -e "\033[0;32;1mcreate repository success please wait seconds\033[0m"

sleep 2s

filepath="$HOME/$svnserver_name/$repository_name/conf/svnserve.conf"

sed -i "${backupname}" "s/a/a/g" $filepath

echo "[general]
anon-access = read
auth-access = write
password-db = passwd
authz-db = authz
[sasl]" > $filepath

filepath="$HOME/$svnserver_name/$repository_name/conf/passwd"
sed -i "${backupname}" "s/a/a/g" $filepath
echo "[users]
root = 123
stone = 123" > $filepath

filepath="$HOME/$svnserver_name/$repository_name/conf/authz"

sed -i "${backupname}" "s/a/a/g" $filepath
echo "[aliases]
[groups]
mygroup = stone,root
[/]
@mygroup = rw
* = r" > $filepath

ps -ef | grep svnserve | awk -F " " '{if($3==1)print $2}' | xargs kill -9

svnserve -d -r $HOME/$svnserver_name/$repository_name

if [ ! -d "$HOME/svn_test_folder" ]; then
	mkdir $HOME/svn_test_folder
fi

echo "Hello SVN" >> $HOME/svn_test_folder/hellosvn.txt

cd $HOME/svn_test_folder

echo -e "\033[0;33;1msvn import . svn://localhost/$repository_name/svn_test_folder --username=root --password=123 -m \"初始化导入\"\033[0m"

svn import . svn://localhost/$repository_name/svn_test_folder --username=root --password=123 -m "初始化导入"

echo -e "服务器地址:\033[0;32;1msvn://root@127.0.0.1/$repository_name\033[0m"

echo -e "\033[0;33;1mroot用户默认密码123\033[0m"
echo -e "\033[0;33;1m$HOME/$svnserver_name/$repository_name/conf 目录下添加用户修改密码就行\033[0m"
