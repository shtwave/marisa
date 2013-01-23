#!/bin/bash

# uwsgiのstatsからリクエストカウンターをパースする
# カウンターの値をGrowthForecastにポストする

# 監視対象のホスト(配列)
HOSTS=(host1 host2 host3)


for target_host in ${HOSTS[@]}

do
    COUNTER=`nc $target_host 4111 | grep "\"requests" | awk -F'\t' '{print $4}' | cut -d ":" -f2 | sed -e '/^$/d' | sed -e 's/\,//g' | awk 'BEGIN{n=0}{n += $1}END{print n}'`
    echo $target_host $COUNTER
    curl -F number=$COUNTER mode=derive https://gf.exsample.com/api/uwsgi/requests/$target_host
done

