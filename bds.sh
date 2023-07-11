#!/data/data/com.termux/files/usr/bin/bash

install_bds() {
    if [ ! -d "$HOME/BDS/ubuntu-rootfs" ]; then
        # 安装必要软件包
        pkg install proot wget jq -y

        # 创建 BDS 文件夹
        cd ~
        mkdir BDS && cd BDS

        # 下载 Ubuntu 镜像
        echo "正在下载 Ubuntu 镜像..."
        git clone https://jihulab.com/hmsjy2017/ubuntu-rootfs
        cd ubuntu-rootfs

        # 解压 Ubuntu 镜像
        echo "正在解压 Ubuntu 镜像..."
        proot --link2symlink tar -xJf ubuntu-rootfs.tar.xz --exclude="dev"||:
        rm ~/BDS/ubuntu-rootfs/ubuntu-rootfs.tar.xz

        # 下载启动脚本并赋予执行权限
        cd ..
        wget https://raw.gitmirror.com/hmsjy2017/bdsmgr/main/start-ubuntu.sh
        chmod +x start-ubuntu.sh
        wget https://raw.gitmirror.com/hmsjy2017/bdsmgr/main/startbds -O $HOME/BDS/ubuntu-rootfs/usr/bin/startbds
        chmod +x ./ubuntu-rootfs/usr/bin/startbds
        echo "Ubuntu 容器已安装完成"

        # 在容器中下载并安装 Minecraft 基岩版
        echo "正在安装 BDS..."
        cd ~/BDS/ubuntu-rootfs/root/
        mkdir mc && cd mc
        LATEST_VERSION=`curl -s https://raw.gitmirror.com/Bedrock-OSS/BDS-Versions/main/versions.json | jq -r '.linux.stable'`
        echo "Linux BDS 最新版： [${LATEST_VERSION}]"
        DOWNLOAD_URL=`curl -s https://raw.gitmirror.com/Bedrock-OSS/BDS-Versions/main/linux/${LATEST_VERSION}.json | jq -r '.download_url'`
        echo "正在下载最新版 BDS 压缩包..."
        wget ${DOWNLOAD_URL}
        unzip bedrock-server-${LATEST_VERSION}.zip
        rm bedrock-server-${LATEST_VERSION}.zip
        chmod +x bedrock_server

        echo "BDS 已在 Ubuntu 容器中安装完成。"
    else
        echo "检测到已安装 BDS，退出"
    fi
    exit
}

run_bds() {
    if [ ! -d "$HOME/BDS/ubuntu-rootfs" ]; then
        echo "请先安装 BDS。"
    else
        echo "正在进入容器..."
        echo "请在容器中执行 startbds 命令启动 BDS，需要停止 BDS 时执行 stop 命令 。"
        cd ~/BDS
        ./start-ubuntu.sh
    fi
    exit
}

update_bds() {
    if [ ! -d "$HOME/BDS/ubuntu-rootfs" ]; then
        echo "请先安装 BDS。"
    else
        echo "正在备份游戏数据..."
        cd ~/BDS/ubuntu-rootfs/root/mc
        tar -czvf ../bds-backup.tar.gz allowlist.json Dedicated_Server.txt permissions.json server.properties worlds/
        echo "正在删除旧版 BDS..."
        rm -rf *
        LATEST_VERSION=`curl -s https://raw.gitmirror.com/Bedrock-OSS/BDS-Versions/main/versions.json | jq -r '.linux.stable'`
        echo "Linux BDS 最新版：[${LATEST_VERSION}]"
        DOWNLOAD_URL=`curl -s https://raw.gitmirror.com/Bedrock-OSS/BDS-Versions/main/linux/${LATEST_VERSION}.json | jq -r '.download_url'`
        echo "正在下载最新版 BDS 压缩包..."
        wget ${DOWNLOAD_URL}
        unzip bedrock-server-${LATEST_VERSION}.zip
        rm bedrock-server-${LATEST_VERSION}.zip
        chmod +x bedrock_server
        echo "正在恢复备份..."
        tar -zxvf ../bds-backup.tar.gz -C .
        echo "更新成功！"
    fi
    exit
}

uninstall_bds() {
    read -p "你确定要卸载 BDS 吗？(y/n): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        # 删除 Ubuntu 根文件系统
        rm -rf ~/BDS/ubuntu-rootfs
        # 删除启动脚本
        rm ~/BDS/start-ubuntu.sh
        rm -rf ~/BDS
        echo "BDS 已成功卸载。"
    else
        echo "取消卸载操作。"
    fi
    exit
}

# 脚本向导
while true; do
    clear
    printf "\nMinecraft 基岩版服务端（BDS）管理脚本\n"
    printf "（此脚本仅适用于 Termux）\n"
    printf "https://github.com/hmsjy2017/bdsmgr\n\n"
    echo "请选择操作："
    echo "1. 安装 BDS"
    echo "2. 运行 BDS"
    echo "3. 更新 BDS"
    echo "4. 卸载 BDS"
    echo "5. 退出脚本"
    read -p "输入操作编号： " option

    case $option in
        1) install_bds ;;
        2) run_bds ;;
        3) update_bds ;;
        4) uninstall_bds ;;
        5) exit ;;
        *) printf "\n无效的选项。\n" ;;
    esac
done
