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
    find="false"
    grep -2 -n '堕落天使' ${whatsnewj} | while read line
    do
        if [[ ${find} = "false" ]]
        then
            # 検索結果の本文が入っているテキストファイル名（ここにリンク）
            filename=`basename ${whatsnewj}`
            # バージョンからリリース日取得
            versions=$(echo ${filename} | sed 's/whatsnewJ_//g' | sed 's/.txt//g')
            echo ${versions} | awk -F "_" '{ print $1 }' | while read v
            do
                echo $v;
            done
            echo ${filename}:${version}
            find=true
        fi
        echo $line
    done
done

exit 0
