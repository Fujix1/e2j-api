######################################################################
## 共通環境設定
######################################################################

# 検索窓用の JSON インデックス
SEARCH_INDEX_JSON=${PROJECT_HOME}/generator/static/mametan.json
# 検索窓用の JSON インデックス
RELEASE_JSON=${PROJECT_HOME}/generator/static/releases.json
# 生成元ルート
export MAME_HOME=${PROJECT_HOME}/mame
# WHAT'S NEW J (UTF-8版) ディレクトリ
export WHATSNEW_DIR=${MAME_HOME}/whatsnewJ
# WHAT'S NEW J ファイル名パターン
export WHATSNEW_NAME='whatsnewJ*.txt'
# 辞書ディレクトリー
export DIC_DIR=${MAME_HOME}/dictionary

# AWK が LANG により動作を変更するため日本語に設定
export LANG=ja_JP.UTF-8

# 形態素解析時のテキスト整形正規表現
export REGEXP_TEXT='s/([亜-熙ぁ-んァ-ヶー])\n +([亜-熙ぁ-んァ-ヶー]+)/\1\2/g'

######################################################################
## 共通関数
######################################################################

# awk で生成した JSON ファイルの最後のカンマを外して書き戻す
#  $1: 変換ファイル
function delete_last_comma_json {
    sed -i -zr 's/,([^,]*$)/\1/' $1
}
