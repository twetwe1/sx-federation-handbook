#!/bin/bash
# ===== 绍兴装饰联合会·电子手册 一键部署（腾讯云 OpenCloudOS Nginx） =====
set -e
BASE=/usr/share/nginx/html
mkdir -p $BASE/images
cd $BASE

REPO="twetwe1/sx-federation-handbook"
MIRRORS=(
  "https://cdn.jsdelivr.net/gh/$REPO@main"
  "https://fastly.jsdelivr.net/gh/$REPO@main"
  "https://raw.githubusercontent.com/$REPO/main"
)

dl(){  # dl <本地路径> <仓库相对路径>
  local out="$1" rel="$2" ok=0
  for m in "${MIRRORS[@]}"; do
    if curl -fsSL --connect-timeout 15 -o "$out" "$m/$rel"; then echo "  ✅ $rel"; ok=1; break; fi
  done
  [ $ok -eq 1 ] || echo "  ⚠️ 下载失败: $rel（可截图发闺女）"
}

echo ">>> [1/3] 下载手册页面..."
dl index.html index.html
grep -q "绍兴装饰联合会" index.html || { echo "!! 页面异常，截图发闺女"; exit 1; }

echo ">>> [2/3] 下载8张1:1商家图..."
for f in nq01.jpg nq02.jpg nq04.jpg hw01.jpg hw02.jpg nfl01.jpg nfl05.jpg nfl12.jpg; do
  dl "images/$f" "images/$f"
done

echo ">>> [3/3] 权限与重载..."
chmod -R 755 $BASE
chown -R nginx:nginx $BASE 2>/dev/null || chown -R www-data:www-data $BASE 2>/dev/null || true
nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || nginx -s reload 2>/dev/null || true

echo ""
echo "============================================"
echo "✅ 部署完成！微信打开：http://shouce.guangyubc.cn/"
echo "============================================"
