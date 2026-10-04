#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: 2410_x64_mainrouter_diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

echo "开始 DIY2 配置……"
echo "========================="
build_date=$(TZ=Asia/Shanghai date "+%Y.%m.%d")
build_name="主路由版"

# 默认地址
sed -i 's/192.168.1.1/192.168.18.1/g' package/base-files/files/bin/config_generate

# 最大连接数
sed -i '/customized in this file/a net.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# 设置密码为空
sed -i '/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF./d' package/lean/default-settings/files/zzz-default-settings 2>/dev/null || true

# 调整 x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore 2>/dev/null || true

# 设置ttyd免帐号登录
sed -i 's/\/bin\/login/\/bin\/login -f root/' feeds/packages/utils/ttyd/files/ttyd.config 2>/dev/null || true

# 设置argon为默认主题
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap 2>/dev/null || true
sed -i 's/Bootstrap theme/Argon theme/g' feeds/luci/collections/*/Makefile 2>/dev/null || true
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/*/Makefile 2>/dev/null || true

# 更改argon主题背景 & footer
[ -f $GITHUB_WORKSPACE/personal/bg1.jpg ] && cp -f $GITHUB_WORKSPACE/personal/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
[ -f $GITHUB_WORKSPACE/personal/argon/footer.ut ] && cp -f $GITHUB_WORKSPACE/personal/argon/footer.ut package/luci-theme-argon/ucode/template/themes/argon/footer.ut
[ -f $GITHUB_WORKSPACE/personal/argon/footer_login.ut ] && cp -f $GITHUB_WORKSPACE/personal/argon/footer_login.ut package/luci-theme-argon/ucode/template/themes/argon/footer_login.ut

# 显示增加编译时间
sed -i "s/DISTRIB_REVISION='R[0-9]\+\.[0-9]\+\.[0-9]\+'/DISTRIB_REVISION='@R$build_date'/g" package/lean/default-settings/files/zzz-default-settings 2>/dev/null || true
sed -i "s/LEDE/OpenWrt_2410_x64_${build_name} by GXNAS build/g" package/lean/default-settings/files/zzz-default-settings 2>/dev/null || true

# 修改右下角脚本版本信息和登录页版本信息
sed -i "s/OpenWrt_2410_x64_build_name by GXNAS build @R build_date/OpenWrt_2410_x64_${build_name} by GXNAS build @R${build_date}/g" \
  package/luci-theme-argon/ucode/template/themes/argon/footer.ut \
  package/luci-theme-argon/ucode/template/themes/argon/footer_login.ut 2>/dev/null || true

# 修改欢迎banner
[ -f $GITHUB_WORKSPACE/personal/banner ] && cp -f $GITHUB_WORKSPACE/personal/banner package/base-files/files/etc/banner

# 修复 netdata 自动启动
if [ -f package/luci-app-netdata/root/etc/init.d/netdata ]; then
  chmod +x package/luci-app-netdata/root/etc/init.d/netdata
fi
mkdir -p package/base-files/files/etc/rc.d
ln -sf ../init.d/netdata package/base-files/files/etc/rc.d/S99netdata 2>/dev/null || true
mkdir -p package/base-files/files/etc/netdata
cat << 'EOF' > package/base-files/files/etc/netdata/netdata.conf
[global]
    run as user = root
    memory mode = ram
[cloud]
    enabled = no
EOF
mkdir -p package/base-files/files/etc/uci-defaults
cat << 'EOF' > package/base-files/files/etc/uci-defaults/99-netdata
#!/bin/sh
[ -x /etc/init.d/netdata ] && /etc/init.d/netdata enable && /etc/init.d/netdata restart
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-netdata

# 修复 ustream-ssl 源（统一替换）
find . -type f \( -name "Makefile" -o -name "*.mk" \) -exec sed -i \
  -e 's#https://git.openwrt.org/#https://github.com/openwrt/#g' \
  -e 's#https://github.com/openwrt/project/ustream-ssl.git#https://github.com/openwrt/ustream-ssl.git#g' \
  -e 's#https://git.openwrt.org/project/ustream-ssl.git#https://github.com/openwrt/ustream-ssl.git#g' {} +
rm -rf dl/ustream-ssl-* build_dir/target-*/ustream-ssl-* 2>/dev/null || true

# 移除 UPnP 相关
find package -type f -name "Makefile" | xargs sed -i \
  -e '/luci-app-upnp/d' \
  -e '/luci-i18n-upnp/d' \
  -e '/miniupnpd/d' 2>/dev/null || true
rm -f tmp/.package_install 2>/dev/null || true

# 自定义系统设置（hostname / 时区 / 语言）
mkdir -p package/base-files/files/etc/uci-defaults
cat << 'EOF' > package/base-files/files/etc/uci-defaults/99-system
#!/bin/sh
uci set system.@system[0].hostname='OpenWrt-GXNAS'
uci set system.@system[0].zonename='Asia/Shanghai'
uci set system.@system[0].timezone='CST-8'
uci -q delete system.ntp.server
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='time1.cloud.tencent.com'
uci add_list system.ntp.server='time.apple.com'
uci add_list system.ntp.server='time.windows.com'
uci commit system
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-system

cat << 'EOF' > package/base-files/files/etc/uci-defaults/99-luci
#!/bin/sh
uci set luci.main.lang='zh_cn'
uci commit luci
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-luci

echo "========================="
echo " DIY2 配置完成……"
