#!/bin/bash
# Git に入れてはいけない言葉（取引先・人の名前・社名など）とメールアドレスが、文章に入っていないか調べる。
# company と website で同じもの（片方を直したら、もう片方にも写す）。
# 使い方: bash tools/hooks/check-ng-words.sh <調べる文章のファイル> [何を調べたか]
#
# 言葉の一覧（1行に1つ。# で始まる行は説明。[名前] の行から下は、その区切りの言葉）を、次の順に探す:
#   1. 環境変数 NG_WORDS_FILE のファイル
#   2. <作業フォルダ>/private/git-ng-words.txt（company。Google ドライブへのリンク）
#   3. 作業フォルダのとなりの company/private/git-ng-words.txt（website から）
#   4. 環境変数 GIT_NG_WORDS（一覧の中身そのもの。Codespace では Codespaces のシークレットに入れる）
# 環境変数 NG_SKIP_SECTIONS（空白区切り。例: "自社"）の区切りは調べない（website は社名を公開してよいため）。
# 見つかったら 1 で終わる（Git の記録・送信が止まる）。一覧がないときも止める。

file="$1"
what="${2:-文章}"
top="$(git rev-parse --show-toplevel)"

list=""
for f in "$NG_WORDS_FILE" "$top/private/git-ng-words.txt" "$top/../company/private/git-ng-words.txt"; do
  if [ -n "$f" ] && [ -f "$f" ]; then list="$f"; break; fi
done
tmplist=""
if [ -z "$list" ] && [ -n "$GIT_NG_WORDS" ]; then
  tmplist="$(mktemp)"; printf '%s\n' "$GIT_NG_WORDS" > "$tmplist"; list="$tmplist"
fi
if [ -z "$list" ]; then
  echo "【止めました】言葉の一覧（git-ng-words.txt）が見つかりません。ドライブのリンクが切れていないか、Codespace ならシークレット GIT_NG_WORDS があるかを確かめてください。" >&2
  exit 1
fi

found=0
n=0
section=""
while IFS= read -r w || [ -n "$w" ]; do
  n=$((n + 1))
  w="${w%$'\r'}"
  [ -z "$w" ] && continue
  case "$w" in
    \#*) continue ;;
    \[*\]) section="${w#\[}"; section="${section%\]}"; continue ;;
  esac
  skip=0
  for s in $NG_SKIP_SECTIONS; do [ "$s" = "$section" ] && skip=1; done
  [ "$skip" = 1 ] && continue
  if LC_ALL=C grep -F -q -- "$w" "$file"; then
    echo "【止めました】${what}に、Git に入れてはいけない言葉が入っています（一覧の ${n} 行目の言葉）。" >&2
    found=1
  fi
done < "$list"
[ -n "$tmplist" ] && rm -f "$tmplist"

# メールアドレス（GitHub の代わりのアドレス、Claude の共同作成者の行の noreply@anthropic.com、見本の example.com は除く）
if LC_ALL=C grep -E -o '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$file" \
   | grep -v -E '@users\.noreply\.github\.com$|^noreply@anthropic\.com$|@example\.(com|org|net)$' | grep -q .; then
  echo "【止めました】${what}に、メールアドレスが入っています。" >&2
  found=1
fi

if [ "$found" = 1 ]; then
  echo "名前は Firestore・ドライブ・Private.gs など Git に入れない場所に置き、ここには書かないでください。" >&2
fi
exit $found
