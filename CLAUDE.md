# CLAUDE.md（website：会社のホームページ）

共通のルールは `~/.claude/CLAUDE.md`（`dotfiles` リポジトリ）にある。ここには、このリポジトリのことだけを書く。

このリポジトリは公開する（GitHub Pages）。会社名・事業内容など会社の情報は公開してよい（2026-11-06 オーナー）。
ただし、社員の名前・生年月日・給料、応募者の情報、取引先の情報、給与の基準（社外秘）は書かない。

ビルド・リント・テストのコマンドはない。HTML・CSS・JavaScript をそのまま公開する。

## Git に入れてはいけない言葉の確認

取引先・人の名前とメールアドレスが Git に入らないように、`tools/hooks/` で自動で調べる（2026-11-26 オーナー。一度 GitHub に送った記録は、送り直しても履歴に残り、自分では消せないため）。company と同じ仕組み（`check-ng-words.sh` は company と同じもの。片方を直したら、もう片方にも写す）。

- はじめに1回（作業フォルダ・PC ごと）: `git config core.hooksPath tools/hooks`
- `pre-commit`（足した行とファイル名）・`commit-msg`（記録の説明）・`pre-push`（GitHub に送る記録すべてとブランチ名）が調べ、見つかったら止める
- 言葉の一覧は company の `private/git-ng-words.txt`（ドライブ。Git に入れない）を、となりの作業フォルダ（`../company/`）から読む。社名は公開してよいので `[自社]` の区切りは調べない
- Codespace（ドライブがない）では、一覧の中身を Codespaces のシークレット `GIT_NG_WORDS` に入れる。ないと記録が止まる
- プルリクエストの題名・説明は、作る前に文章をファイルに書いて `NG_SKIP_SECTIONS=自社 bash tools/hooks/check-ng-words.sh <ファイル> 説明` で調べる
- 止められたら直してから記録し直す。`--no-verify` で飛ばさない

## 構成

- `index.html`: トップ（事業内容・強み・会社概要・お問い合わせ）
- `recruit.html`: 求人と応募フォーム
- `privacy.html`: 個人情報の取り扱い
- `robots.txt`・`sitemap.xml`: 検索エンジン向け（検索エンジンに読んでよいことと、ページの一覧を知らせる）。ページを増やしたら `sitemap.xml` に足す。各ページの `<head>` には正式な住所（`canonical`）と、SNS で共有したときの表示（`og:`）を書く。`index.html` には会社名・所在地を検索エンジン向けの書き方（JSON-LD）でも書いている（会社概要を直したら合わせる）
- `assets/style.css`: 見た目（全ページ共通。スマホは幅760px以下）
- 上の帯: 左上の三本線で左から一覧（ページへのリンク）が出る、言語はプルダウン。従業員専用ページと自動販売機オンラインの帯は company の `StaffHeader.html` で同じ見た目にしている（直すときは両方そろえる）
- `assets/i18n.js`: 言語の切り替え（日本語・English・မြန်မာ）。HTML には日本語を書き、`data-i18n="キー"` の要素を選んだ言語の文に置き換える。訳は `I18N` に足す。固有名詞（会社名など）は訳さない
- `assets/config.js`: 応募フォームの送り先（`APPLY_URL`）と、従業員専用ページの URL（`STAFF_URL`）・下請け専用ページの URL（`PARTNER_URL`）
- 下請け専用（2026-11-20）: 帯の「従業員専用」のとなりに白い枠のボタン、三本線の一覧の「協力会社の方へ」、下の帯の「協力会社の方へ」。帯に入りきらない幅（1100px 以下）とミャンマー語では、帯のボタンは出さない（一覧と下の帯から入る）
- `assets/form.js`: 応募フォームを送る。郵便番号から市区町村を自動で入れる（yubinbango-data。https://yubinbango.github.io/yubinbango-data/ の公開データを、郵便番号の頭3けたごとに読む。JSON として読むだけでプログラムとしては動かさない）

## つながる仕組み（company リポジトリ。非公開）

- 応募フォームの送り先: `company/recruit-form/`（Apps Script。応募はオーナーのスプレッドシートにだけ保存し、メールで知らせる）
- 下請け専用ページ: `company/timecard/public/partner/`（https://staff-timecard-8181e.web.app/partner/ 。協力会社・一人親方が、取引基本契約・見積書・注文書・請求書・支払明細書をやり取りする）
- 従業員専用ページ: `company/timecard/`（Firebase。https://staff-timecard-8181e.web.app/ 。メールアドレスとパスワードで入る。2026-11-11 に、合言葉と名前・生年月日で入る `company/pay-standards/` から切り替えた）

## 見た目を確かめる

`file:///workspaces/website/index.html?lang=ja`（`lang` は `ja`・`en`・`my`）をブラウザで開く。

## 公開

- GitHub Pages（`main` ブランチのいちばん上）。住所: https://www.shimojoukoumuten-01.com/（`CNAME` ファイルで設定。DNS は Squarespace の CNAME `www` → `shimojo-company.github.io`。https://shimojo-company.github.io/website/ はここへ転送される。2026-11-08 に会社の GitHub アカウント `shimojo-company` へ移した。Enforce HTTPS は有効）
- Google Search Console（Google の検索に載せるための管理画面）に `https://www.shimojoukoumuten-01.com/` を登録した（2026-11-11。持ち主の確認は自動で済んでいた）。同じ日にサイトマップ（`sitemap.xml`）を送り、トップのインデックス登録（検索結果に載せてもらう申し込み）をした。載ったかは `site:www.shimojoukoumuten-01.com` で検索するか、Search Console の「ページ」で見る
- www なしの住所（A レコード）は設定していない（2026-11-07）
- 2026-11-07 本番として公開した（`assets/config.js` の `TEST: false`、noindex を外した）。テスト版に戻すときは `TEST: true` にし、各ページに `<meta name="robots" content="noindex, nofollow">` を入れる
- 変更は `main` から作業ブランチを切り、プルリクエストでマージする（マージすると数分でページに反映される）

## 仮の内容

- 電話・メールは、オーナーの指示で載せていない（2026-11-06）
- 求人の勤務地・給与・待遇は仮（2026-11-06 オーナーが「仮で作成」と指示）。決まったら直す
- 写真・ロゴは、あとでオーナーが用意する。それまでは骨組みの絵（SVG）
