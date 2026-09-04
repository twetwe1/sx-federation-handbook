#!/bin/bash
# ===== 绍兴装饰联合会·电子手册 一键部署（腾讯云 OpenCloudOS Nginx） =====
set -e
BASE=/usr/share/nginx/html
mkdir -p $BASE/images
cd $BASE

echo ">>> [1/4] 下载手册页面..."
for u in \
 "https://cdn.jsdelivr.net/gh/twetwe1/sx-federation-handbook@main/index.html" \
 "https://fastly.jsdelivr.net/gh/twetwe1/sx-federation-handbook@main/index.html" \
 "https://raw.githubusercontent.com/twetwe1/sx-federation-handbook/main/index.html" ; do
  if curl -fsSL --connect-timeout 15 -o index.html "$u" && grep -q "绍兴装饰联合会" index.html; then echo "  HTML OK: $u"; break; fi
done
grep -q "绍兴装饰联合会" index.html || { echo "!! 页面下载失败，截图发闺女"; exit 1; }

echo ">>> [2/4] 下载8张商家图片..."
dl(){ curl -fsSL --connect-timeout 20 -o "images/$1" "$2" && echo "  $1 OK" || echo "  $1 FAIL"; }
dl nq01.png  "https://www.coze.cn/s/1KY1Y50eHI0/"
dl nq02.jpg  "https://www.coze.cn/s/2TO_OIa-uqI/"
dl nq04.jpg  "https://www.coze.cn/s/2FuX1gGcFm0/"
dl hw01.jpg  "https://www.coze.cn/s/HFVR3-icrGo/"
dl hw02.png  "https://www.coze.cn/s/FksWp8NY7cs/"
dl nfl01.jpg "https://www.coze.cn/s/IddXPdT0X0U/"
dl nfl05.jpg "https://www.coze.cn/s/HbRGp7PwkH8/"
dl nfl12.jpg "https://www.coze.cn/s/RzT2ZE2z2UA/"

echo ">>> [3/4] 修复权限..."
chmod -R 755 $BASE
chown -R nginx:nginx $BASE 2>/dev/null || chown -R www-data:www-data $BASE 2>/dev/null || true
if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" = "Enforcing" ]; then restorecon -R $BASE 2>/dev/null || true; fi

echo ">>> [4/4] 重载 Nginx..."
nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || nginx -s reload 2>/dev/null || true

echo ""
echo "============================================"
echo "✅ 部署完成！微信打开：http://shouce.guangyubc.cn/"
echo "============================================"
