#! /usr/bin/env bash

function docker_cleanup(){
    docker stop m1                      2>&1 1>/dev/null
    docker rm   m1                      2>&1 1>/dev/null
    docker stop artb-3pg-cont-proto     2>&1 1>/dev/null
    docker rm   artb-3pg-cont-proto     2>&1 1>/dev/null
    docker stop artb-3pg-cont-fonicy    2>&1 1>/dev/null
    docker rm   artb-3pg-cont-fonicy    2>&1 1>/dev/null
    docker rmi  artb-3pg-img-fonicy:1.0 2>&1 1>/dev/null
}

# clean-up html
rm -f my_fonicy.zip
rm -Rdf fonicy-html
# setup
curl -s https://www.free-css.com/assets/files/free-css-templates/download/page293/fonicy.zip --output my_fonicy.zip
unzip -q my_fonicy.zip
sed -i 's/demo@gmail.com/arthur.bugorski@3pillarglobal.com/' fonicy-html/index.html


docker_cleanup


# start
docker pull --quiet nginx > /dev/null
docker pull --quiet mysql > /dev/null

proto_sha=$( docker create --name artb-3pg-cont-proto -p 8080:80 nginx );
docker cp $(pwd)/fonicy-html/. artb-3pg-cont-proto:/usr/share/nginx/html
img_sha=$( docker commit artb-3pg-cont-proto artb-3pg-img-fonicy:1.0 )

img=$( docker run --name artb-3pg-cont-fonicy -p 8080:80 -d artb-3pg-img-fonicy:1.0 )

sleep 5
email=$( curl -s http://localhost:8080 | grep 'Email : ' | sed 's/[[:space:]]//g' | head -n 1 | cut --delim : -f 2 ) ;
if [[ "$email" == 'arthur.bugorski@3pillarglobal.com' ]]; then
    echo 'it is up!!!';
else
    echo "web no is up";
fi


m1_sha=$( docker run --name m1 -e MYSQL_PASSWRD='p4ssw0rd' --link artb-3pg-cont-fonicy:web -d mysql );

sleep 1
m1_links=$( docker inspect -f '{{ .HostConfig.Links }}' m1 )
if [[ "$m1_links" == '[/artb-3pg-cont-fonicy:/m1/web]' ]]; then
    echo "database 'm1' linked to server 'artb-3pg-cont-fonicy' as 'web'";
else
    echo "m1's links are: $m1_links";
fi


# Do not clean up because we need the image for lab2b.sh
# docker_cleanup
