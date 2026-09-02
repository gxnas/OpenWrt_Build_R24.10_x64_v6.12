#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: 2410_x64_full_diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# 添加源仓库
sed -i '/helloworld/d' feeds.conf.default
sed -i '/small/d' feeds.conf.default
sed -i '/passwall/d' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default
sed -i '$a src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '$a src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
sed -i '$a src-git openclaw https://github.com/10000ge10000/luci-app-openclaw.git;main' feeds.conf.default

# 添加 adguardHome
git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome

# 添加 argon 主题
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 添加 Lucky
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# 添加 netdata
git clone https://github.com/sirpdboy/luci-app-netdata package/luci-app-netdata

# 添加 oaf
git clone https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter

# 添加 openclaw
# git clone https://github.com/10000ge10000/luci-app-openclaw.git package/luci-app-openclaw

# 移除 openwrt feeds 自带的核心库
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/xiaorouji/openwrt-passwall-packages package/passwall-packages

# 添加 poweroffdevice
git clone https://github.com/sirpdboy/luci-app-poweroffdevice.git package/luci-app-poweroffdevice

# 添加 istore
git clone https://github.com/linkease/istore-ui package/luci-app-store-ui
git clone https://github.com/linkease/istore package/luci-app-store

echo "=========================================="
echo "替换 MosDNS 为 sbwml MosDNS v5"
echo "=========================================="
# 删除 feeds 安装进来的旧 MosDNS
rm -rf package/feeds/small/luci-app-mosdns
rm -rf package/feeds/small/mosdns
rm -rf package/feeds/small/v2ray-geodata
rm -rf package/feeds/packages/mosdns
rm -rf package/feeds/packages/v2ray-geodata
rm -rf package/feeds/luci/luci-app-mosdns
# 删除可能已经存在的本地版本
rm -rf package/mosdns
rm -rf package/v2ray-geodata
# 安装 MosDNS v5
git clone --depth=1 -b v5 \
https://github.com/sbwml/luci-app-mosdns.git \
package/mosdns
# 安装对应 geodata
git clone --depth=1 \
https://github.com/sbwml/v2ray-geodata.git \
package/v2ray-geodata
echo "===== MosDNS 来源检查 ====="
find package -maxdepth 4 -type f -path "*mosdns*/Makefile" -print
find package -maxdepth 4 -type f -path "*v2ray-geodata*/Makefile" -print
