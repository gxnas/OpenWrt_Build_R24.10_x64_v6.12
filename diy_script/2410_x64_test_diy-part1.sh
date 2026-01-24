#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: 2410_x64_test_diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# 添加源仓库
sed -i "/helloworld/d" feeds.conf.default
sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
sed -i '2i src-git small https://github.com/kenzok8/small' feeds.conf.default
#sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages' feeds.conf.default
#sed -i '$a src-git passwall https://github.com/xiaorouji/openwrt-passwall' feeds.conf.default
sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default
sed -i '$a src-git istore https://github.com/linkease/istore;main' feeds.conf.default
sed -i '$a src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '$a src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
sed -i '$a src-git passwall2_luci https://github.com/Openwrt-Passwall/openwrt-passwall2.git;main' feeds.conf.default

# 添加 Lucky
git clone  --depth=1 -b main https://github.com/gdy666/luci-app-lucky.git package/lucky

# 添加 netdata
git clone https://github.com/sirpdboy/luci-app-netdata package/luci-app-netdata

# argon 主题
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
