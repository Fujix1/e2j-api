#!/bin/bash
######################################################################
## What's new J 全文検索 API 用 Zola 用 Markdown 生成スクリプト
######################################################################

# プロジェクトの絶対パス取得
export PROJECT_HOME=$(cd $(dirname $0)/../../; pwd)
# 共通環境設定
. ${PROJECT_HOME}/script/dictionary/common.sh

######################################################################
## 検索結果 Markdown 生成
######################################################################

find ${WHATSNEW_DIR} -name ${WHATSNEW_NAME} | while read whatsnewj
do
    # 形態素解析したテキストと同じ正規化したテキストに対して検索し
    # 改行をまたいだ単語を検索できるようにする。（TODO: 英単語の場合は要スペース挿入）
    SEARCH_DIC_TMP_JUSTFY=$(mktemp)
    sed -z -r 's/([亜-熙ぁ-んァ-ヶー])\n\s*/\1/g' ${whatsnewj} > ${SEARCH_DIC_TMP_JUSTFY}
    fisrtline="true"
    grep '堕落天使' ${SEARCH_DIC_TMP_JUSTFY} | while read line
    do
        if [[ ${fisrtline} = "true" ]]
        then
            # 検索結果の本文が入っているテキストファイル名（ここにリンク）
            filename=`basename ${whatsnewj}`
            echo ${filename}
            fisrtline=false
        fi
        # 正規化した行から最大80桁取得し正規化前のファイルから再検索して
        # 出力行を取得（改行をまたがったワードは最初の出現行となる）
        serach_line=$(echo $line | awk '{ print substr($0, 1, 80) }')
        grep -3 -n -F "${serach_line}" ${whatsnewj} | awk '
            BEGIN {
                findline = 0;
            }
            /^[0-9]+:/ {
                # 単語出現行
                findline = substr($0, 1, match($0, ":") - 1)
                print substr($0, match($0, ":") + 1, length($0) - 1);
            }
            /[0-9]+-/ {
                # 単語出力行の前後
                print substr($0, match($0, "-") + 1, length($0) - 1);
            }
            END {
                print findline
            }
        '
    done
    rm ${SEARCH_DIC_TMP_JUSTFY}
done

exit 0
