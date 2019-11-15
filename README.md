# 服务节点配置指南

常用链接：[联系我们](https://github.com/CampusVideo/forwarder/blob/master/contact.md) | [防火墙配置指南](https://github.com/CampusVideo/forwarder/blob/master/firewall.md)

本文档指导您进行面向最终用户提供服务的节点服务器的安装与配置工作。

## 选取上游节点

建议您选择当地教育网分发节点作为您的资源来源。您可在 QQ 或微信群中咨询您所在地区的教育网节点院校是否提供了视频分发节点服务，或者通过 [联系我们](https://github.com/CampusVideo/forwarder/blob/master/contact.md) 发送邮件并提供您的单位名称，获取节点选择的相关建议。

**需要注意的是，视频源节点与分发节点一般都具有防火墙保护资源内容。您需要先联系相应节点管理员，报备您的节点 IP 地址以开通访问权限。**

## 自动安装脚本

为了方便使用，提供了基于全新安装的 CentOS 7/8 操作系统下的自动安装配置脚本。

您可在操作系统安装完成并且成功配置网络连接后通过以下方式使用：

```bash
sh -c "$(curl -sSL https://raw.githubusercontent.com/CampusVideo/frontend/master/installer.sh)"
```

> 脚本交互中会要求您填入视频源地址，请使用以下格式之一：
> * 域名：example.com
> * IPv4 协议 IP 地址：192.0.2.1
> * IPv6 协议 IP 地址：[2001:0db8:85a3:0000:0000:8a2e:0370:7334]

在自动安装脚本执行完成后，您通过访问 `http://您的服务器 IP 地址/` 应当即可访问频道列表与正常观看直播。

如果您需要在服务器配置防火墙以限制您的业务访问范围，可以参考我们的相关文档： [防火墙配置指南](https://github.com/CampusVideo/forwarder/blob/master/firewall.md) 。

如果您需要自己手工操作，可参阅下方的步骤介绍。自动安装脚本执行的操作与以下步骤相同。

## 手工操作步骤

### 1. 安装操作系统并配置网络连接

请在您的服务器上全新安装 CentOS 7/8 操作系统。安装过程中 Software Selection 选项建议选择 Minimal Install 。

*如有其它喜好与需要，您亦可自行选用其它基于 Linux 内核的操作系统，但下述步骤的具体操作命令可能会不同。*

请在安装过程中或安装完成后配置系统的网络连接，使其能够正常访问互联网。

### 2. 安装所需软件包

请登录操作系统后，在终端执行以下命令，以安装需要使用的软件包。

```bash
yum install wget net-tools chrony git epel-release -y
yum install nginx -y
```

### 3. 关闭 SELinux

您可以通过关闭 SELinux 来避免可能出现的一些权限问题。

该步骤为可选步骤，但如果您选择不关闭 SELinux ，可能需要手工解决后续可能出现的权限问题。

操作步骤如下：

* 将当前实例的 SELinux 置为被动模式：

```bash
setenforce 0
```

* 修改配置文件在重新启动后禁用 SELinux ：

```bash
sed -i "s/SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config
```

### 4. 开启 NTP

NTP 服务用于通过网络时钟服务校准您的服务器系统时间。建议您开启该项服务。

```bash
systemctl start chronyd
systemctl enable chronyd
```

### 5. 配置 WEB 内容

我们为您提供了一版简单的 WEB 页面，供您快速开启服务。

建议您通过 Git 来获取以利于后续更新：

```bash
mkdir /var/www
cd /var/www
git clone git@github.com:CampusVideo/frontend-src.git
```

*当后续需要更新时（例如更新频道列表或更新样式），您可以进入 `/var/www/frontend-src/` 目录下，执行 `git pull` 命令。*

### 6. 配置 Nginx 

服务节点通过 Nginx 程序对用户提供 WEB 服务。我们提供的配置文件中已经包含获取电视源和提供 WEB 服务的完整配置，您下载配置文件后，替换其中的 `[视频源地址]` 为您上游视频源的 IP 地址或域名即可。

> 上游源的 IP 地址或域名的填入格式如下：
> * 域名：example.com
> * IPv4 协议 IP 地址：192.0.2.1
> * IPv6 协议 IP 地址：[2001:0db8:85a3:0000:0000:8a2e:0370:7334]

```bash
wget -O nginx.conf.frontend https://raw.githubusercontent.com/CampusVideo/frontend/master/nginx.conf
sed -i 's/\[视频源地址\]/上游源的 IP 或域名/g' nginx.conf.frontend
cp -f nginx.conf.frontend /etc/nginx/
mv -f /etc/nginx/nginx.conf.frontend /etc/nginx/nginx.conf
```

配妥 Nginx 配置文件后，启动 Nginx 服务：

```bash
systemctl start nginx
systemctl enable nginx
```

### 7. 观看效果

在安装配置完成后，关闭系统防火墙：

```bash
systemctl stop firewalld
systemctl disable firewalld
```

通过访问 `http://您的服务器 IP 地址/` 应当即可访问频道列表与正常观看直播。

如果您需要在服务器配置防火墙以限制您的业务访问范围，可以参考我们的相关文档： [防火墙配置指南](https://github.com/CampusVideo/forwarder/blob/master/firewall.md) 。


