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
    grep -1 -n --ignore-case -F \
        "${word}" ${SEARCH_DIC_TMP_REGEX_DIR}/${WHATSNEW_NAME} | awk -v word="${word}" '
        BEGIN {
            filename = ""
            lineno = 0
            buffer = ""
        }
        /^--$/ {
            # grep 区切り文字処理
            # buffer が空でない場合は出力（TODO:）
            if(match(buffer, "\\S")) {
                print "@" word "@" filename "@" lineno "@\n"
                print buffer
            }
            filename = ""
            buffer = ""
        }
        /^\/tmp/ {
            # ファイル名取得
            if(filename == "") {
                ibeg = match($0, "whatsnewJ");
                iend = match($0, ":[0-9]+:") - ibeg;
                filename = substr($0, ibeg, iend);
            }
            # TODO: オリジナルの whatsnewJ*.txt とソースマッピングして lineno を設定
            # コンテンツ取得
            match($0, /[\-|:][0-9]+[\-|:]/);
            add = substr($0, RSTART + RLENGTH, length($0) - 1)
            # 空行でなければ追加（/S: 改行・空白以外の文字）
            if(match(add, "\\S")) {
                buffer = buffer add "\n";
            }
        }
        END {
            # 最終行バッファフラッシュ
            if(match(buffer, "\\S")) {
                print "@" word "@" filename "@" lineno "@\n"
                print buffer
            }
        }
    ' >> ${SEARCH_DIC_TMP_REGEX}
done

# テンポラリーディレクトリを削除
rm -Rf ${SEARCH_DIC_TMP_REGEX_DIR}

# JSON 生成
${PROJECT_HOME}/script/dictionary/create_mametan_json.py ${SEARCH_DIC_TMP_REGEX} > ${SEARCH_DIC_JSON}
# .xz 圧縮（TODO: 定数化）
(cd ${PROJECT_HOME}/generator/static/ && tar Jcvf whatsnewj.tar.xz whatsnewj.json)
# 圧縮前のファイル削除
rm -f ${SEARCH_DIC_JSON}

# テンポラリーファイルを削除
if [[ "$1" = "" ]]
then
    rm -f ${SEARCH_DIC_TMP_REGEX}
fi

exit 0
