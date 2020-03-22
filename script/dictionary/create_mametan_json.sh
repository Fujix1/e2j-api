#!/bin/bash
######################################################################
## What's new J 全文検索 API 用 辞書 JSON 生成スクリプト
######################################################################

# プロジェクトの絶対パス取得
export PROJECT_HOME=$(cd $(dirname $0)/../../; pwd)
# 共通環境設定
. ${PROJECT_HOME}/script/dictionary/common.sh

######################################################################
## 検索結果 JSON 生成
######################################################################

# 検索対象を正規化しテンポラリーディレクトリに格納
SEARCH_DIC_TMP_REGEX_DIR=$(mktemp -d)
find ${WHATSNEW_DIR} -name ${WHATSNEW_NAME} | while read whatsnewj
do
    # 形態素解析したテキストと同じ正規化したテキストに対して検索し
    # 改行をまたいだ単語を検索できるようにする。（TODO: 英単語の場合は要スペース挿入）
    sed -z -r 's/([亜-熙ぁ-んァ-ヶー])\n[ |　]*([亜-熙ぁ-んァ-ヶー]+)/\1\2/g' \
        ${whatsnewj} > ${SEARCH_DIC_TMP_REGEX_DIR}/$(basename ${whatsnewj})
done

# Python で JSON 化する前に高速な grep コマンドで検索し
# テンポラリーファイルとして出力し、結果を Python から取得する。
if [[ "$1" = "" ]]
then
    # シェル引数 $1 がない場合は /tmp に作成し処理後に削除
    SEARCH_DIC_TMP_REGEX=$(mktemp)
else
    # シェル引数 $1 がある場合は指定のパスにファイル出力（テスト用）
    SEARCH_DIC_TMP_REGEX=$1
fi
# 単語帳 JSON を 1語ごとに検索
cat ${SEARCH_INDEX_JSON} | jq -r '.[]' | while read word
do
    grep -1 -n --ignore-case -F "${word}" ${SEARCH_DIC_TMP_REGEX_DIR}/${WHATSNEW_NAME} | awk -v word="${word}" '
        BEGIN {
            filename = ""
            lineno = 0
            buffer = ""
        }
        /^--$/ {
            print "@" word "@" filename ":" lineno "@\n"
            print buffer
            filename = ""
            buffer = ""
        }
        /^\/tmp/ {
            # ファイル名取得
            if(filename == "") {
                ibeg = match($0, "whatsnewJ");
                iend = match($0, "-") - ibeg;
                filename = substr($0, ibeg, iend);
            }
            # コンテンツ取得
            match($0, /[\-|:][0-9]+[\-|:]/);
            buffer = buffer substr($0, RSTART + RLENGTH, length($0) - 1) "\n";
        }
        END {
            # 最終行
            print "@" word "@" filename ":" lineno "@\n"
            print buffer
        }
    ' >> ${SEARCH_DIC_TMP_REGEX}
done

# テンポラリーディレクトリを削除
rm -Rf ${SEARCH_DIC_TMP_REGEX_DIR}

# Python

# Python 処理後にテンポラリーファイルを削除
if [[ "$1" = "" ]]
then
    rm -f ${SEARCH_DIC_TMP_REGEX}
fi

exit 0
