#!/bin/bash
#
# WARP が作成する utun の MTU を監視して自動でクランプする常駐スクリプト。
#
# 背景:
#   本回線の経路 MTU は 1280。WireGuard のカプセル化オーバーヘッド約 60 バイト
#   (外側IP 20 + UDP 8 + WGヘッダ 16 + 認証タグ 16) が加算されるため、
#   トンネル側の MTU は 1220 以下である必要がある。
#   WARP は utun を 1500 または 1280 で作るため超過して通信が破棄される。
#
# 判定条件:
#   起動時に存在しなかった utun が現れたら、MTU を読まずに即座に設定する。
#
#   IPv4 の付与も MTU の読み取りも待たない。WARP の utun は接続失敗時
#   0.2 秒未満で破棄されることがあり、読んでから判断すると競り負ける
#   (実測: "失敗 utun1: mtu 1280 -> (空)" = 設定直後に消滅)。
#
# 副作用:
#   起動後に macOS の NetworkExtension が utun を新規作成した場合、それも
#   対象になる。ただし当該 utun は IPv4 も経路も持たず通信を運んでおらず、
#   そもそも本回線の経路 MTU が 1280 であるため実害はない。
#
set -u

CLAMP_MTU="${CLAMP_MTU:-1200}"
INTERVAL=0.05
LOGFILE="/var/log/warp-mtu-clamp.log"

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOGFILE"; }

rotate() {
  [ -f "$LOGFILE" ] || return 0
  sz=$(stat -f '%z' "$LOGFILE" 2>/dev/null || echo 0)
  if [ "$sz" -gt 1048576 ]; then
    tail -500 "$LOGFILE" > "${LOGFILE}.tmp" && mv "${LOGFILE}.tmp" "$LOGFILE"
  fi
}

# 起動時に存在する utun を「既存」として記録する。これ以降に現れたものが対象。
BASELINE=" $(ifconfig -l 2>/dev/null | tr ' ' '\n' | grep '^utun' | tr '\n' ' ')"

rotate
log "=== 監視開始 (clamp=${CLAMP_MTU} interval=${INTERVAL}s / 即時設定モード) ==="
log "既存 utun (対象外):${BASELINE}"

SEEN=" "
TICK=0

while :; do
  for u in $(ifconfig -l 2>/dev/null | tr ' ' '\n' | grep '^utun'); do
    case "$BASELINE" in
      *" $u "*) continue ;;   # 起動時から存在したものは触らない
    esac

    # 読まずに即設定する。既に目的の値でも ifconfig は無害。
    ifconfig "$u" mtu "$CLAMP_MTU" 2>/dev/null

    # 初回検知だけログに残す (0.05 秒ごとの出力で埋まるのを防ぐ)
    case "$SEEN" in
      *" $u "*) ;;
      *)
        SEEN="${SEEN}${u} "
        now=$(ifconfig "$u" 2>/dev/null | sed -n 's/.*mtu \([0-9]*\).*/\1/p' | head -1)
        addr=$(ifconfig "$u" 2>/dev/null | awk '/inet /{print $2; exit}')
        log "検知 $u: 設定後 mtu=${now:-(消滅)} addr=${addr:-なし}"
        ;;
    esac
  done

  # 消えたら記録から外し、再作成時に再度ログを出せるようにする
  for s in $SEEN; do
    [ -z "$s" ] && continue
    if ! ifconfig "$s" >/dev/null 2>&1; then
      SEEN=$(echo "$SEEN" | sed "s/ $s / /")
      log "消滅 $s"
    fi
  done

  TICK=$((TICK + 1))
  [ $((TICK % 72000)) -eq 0 ] && rotate   # 約1時間ごと

  sleep "$INTERVAL"
done
