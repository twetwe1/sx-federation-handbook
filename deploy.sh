#!/bin/bash
# ===== 绍兴装饰联合会·电子手册 一键部署 v3（国内节点优先） =====
set -e
BASE=/usr/share/nginx/html
mkdir -p $BASE/images
cd $BASE
V=20260904d
REPO="twetwe1/sx-federation-handbook"
COZE="https://www.coze.cn/s"

dl(){  # dl <本地路径> <coze短链ID> <仓库相对路径>
  local out="$1" cid="$2" rel="$3" ok=0
  local urls=(
    "$COZE/$cid/"
    "https://cdn.jsdelivr.net/gh/$REPO@main/$rel?v=$V"
    "https://fastly.jsdelivr.net/gh/$REPO@main/$rel?v=$V"
    "https://raw.githubusercontent.com/$REPO/main/$rel"
  )
  for u in "${urls[@]}"; do
    if curl -fsSL --connect-timeout 15 --max-time 120 -o "$out.tmp" "$u"; then
      mv "$out.tmp" "$out"; echo "  ✅ $rel"; ok=1; break
    fi
  done
  if [ $ok -ne 1 ]; then echo "  ⚠️ 下载失败: $rel（截图发闺女）"; rm -f "$out.tmp"; fi
}

echo ">>> [1/3] 下载手册页面（方图版）..."
dl index.html "8ovZZBlEIqA" "index.html"
grep -q "绍兴装饰联合会" index.html || { echo "!! 页面异常，截图发闺女"; exit 1; }
grep -q "HANDBOOK-V2-SQUARE" index.html && echo "  ✅ 方图版页面确认" || echo "  ⚠️ 页面版本可能不是最新，截图发闺女"

echo ">>> [2/3] 下载8张1:1商家图..."
dl images/nq01.jpg "5vbXUt620vc" "images/nq01.jpg"
dl images/nq02.jpg "-wpdRyDNt9g" "images/nq02.jpg"
dl images/nq04.jpg "8mZxLTi5i58" "images/nq04.jpg"
dl images/hw01.jpg "85gEr_ZCghA" "images/hw01.jpg"
dl images/hw02.jpg "AaaRXSyyea8" "images/hw02.jpg"
dl images/nfl01.jpg "8qgMFlFEy0A" "images/nfl01.jpg"
dl images/nfl05.jpg "90Qct608k1o" "images/nfl05.jpg"
dl images/nfl12.jpg "8h4U2At8b9s" "images/nfl12.jpg"

echo ">>> [3/3] 清理旧图、权限与重载..."
rm -f images/nq01.png images/hw02.png 2>/dev/null || true
chmod -R 755 $BASE
chown -R nginx:nginx $BASE 2>/dev/null || chown -R www-data:www-data $BASE 2>/dev/null || true
nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || nginx -s reload 2>/dev/null || true

echo ""
echo "============================================"
echo "✅ 部署完成！微信打开：http://shouce.guangyubc.cn/"
echo "============================================"
